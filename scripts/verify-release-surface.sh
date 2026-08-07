#!/usr/bin/env bash
# scripts/verify-release-surface.sh — standing, read-only gate: for every dated CHANGELOG
# version at or above the floor, does it have a tag on origin AND a GitHub Release whose
# body names its version? ADR-078. Wired post-merge-only by
# .github/workflows/release-surface.yml — never on `pull_request` (see that file's header
# for why).
#
# Usage: scripts/verify-release-surface.sh [--floor X.Y.Z] [--changelog PATH] [--evidence-dir DIR]
# Exit:  0 = all in-scope versions pass
#        1 = one or more in-scope versions failed (findings printed, one line per failed
#            conjunct, using three stable greppable tokens: MISSING-TAG, MISSING-RELEASE,
#            DEFECTIVE-RELEASE-BODY — these are different remedies and are never collapsed
#            into one message) — plus a possible WRONG-LATEST finding (see below)
#        2 = usage, environment, or contract error — fail-closed, never a pass
#
# --evidence-dir DIR is a TEST SEAM, not dead code: it redirects the two live-data lookups
# (origin tags, Release bodies, and the /releases/latest tag) to files under DIR, which is
# what makes every acceptance criterion's negative control executable offline, against no
# live release (AC-PUB-12). CI (.github/workflows/release-surface.yml) invokes this script
# with NO flags — a quality.yml meta-check greps that workflow file to assert the live
# invocation carries neither --evidence-dir nor --changelog (C3 seam containment,
# docs/design-v2.19.6.md §C3).
#
#   --evidence-dir DIR layout:
#     DIR/tags.txt        — one "refs/tags/vX.Y.Z" per line (origin's tag set)
#     DIR/bodies/X.Y.Z.body — Release body text for that version (file absent = no Release)
#     DIR/latest.txt      — single line, the tag /releases/latest currently resolves to
#                            (absent or empty = no Release exists yet)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./release-predicate.sh
. "${SCRIPT_DIR}/release-predicate.sh" || {
  echo "::error::release-surface: ${SCRIPT_DIR}/release-predicate.sh not found beside $0." >&2
  exit 2
}
SEMVER_CMP="${SCRIPT_DIR}/semver-compare.sh"
if [ ! -r "$SEMVER_CMP" ]; then
  echo "::error::release-surface: ${SEMVER_CMP} not found beside $0." >&2
  exit 2
fi

# --- Argument parsing ---
FLOOR="2.18.0"
CHANGELOG_PATH="CHANGELOG.md"
EVIDENCE_DIR=""
while [ $# -gt 0 ]; do
  case "$1" in
    --floor)
      FLOOR="${2:-}"; shift 2 ;;
    --changelog)
      CHANGELOG_PATH="${2:-}"; shift 2 ;;
    --evidence-dir)
      EVIDENCE_DIR="${2:-}"; shift 2 ;;
    *)
      echo "::error::release-surface: unknown argument '$1' (usage: --floor X.Y.Z --changelog PATH --evidence-dir DIR)" >&2
      exit 2 ;;
  esac
done

if ! printf '%s' "$FLOOR" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "::error::release-surface: --floor '${FLOOR}' is not a x.y.z semver." >&2
  exit 2
fi
if [ ! -r "$CHANGELOG_PATH" ]; then
  echo "::error::release-surface: cannot read CHANGELOG at '${CHANGELOG_PATH}'." >&2
  exit 2
fi
if [ -n "$EVIDENCE_DIR" ]; then
  if [ ! -d "$EVIDENCE_DIR" ]; then
    echo "::error::release-surface: --evidence-dir '${EVIDENCE_DIR}' is not a directory." >&2
    exit 2
  fi
  echo "::warning::release-surface: running in EVIDENCE-INJECTED mode against '${EVIDENCE_DIR}' — this is a test seam, not a fact about this repository."
fi

EXPECTED_REPO="jmlozano1990/Cowork-Starter-Kit"

# --- Evidence seam: origin tags ---
evidence_tags() {
  if [ -n "$EVIDENCE_DIR" ]; then
    [ -f "${EVIDENCE_DIR}/tags.txt" ] && cat "${EVIDENCE_DIR}/tags.txt"
    return 0
  fi
  if ! command -v git >/dev/null 2>&1; then
    echo "::error::release-surface: git not available." >&2
    exit 2
  fi
  git ls-remote --tags origin 2>/dev/null | awk '{print $2}'
}

# --- Evidence seam: Release body for a version. Prints body (possibly empty) and returns
#     0 if a Release exists, 1 if none exists (MISSING-RELEASE). ---
evidence_body() {
  local version="$1"
  if [ -n "$EVIDENCE_DIR" ]; then
    local f="${EVIDENCE_DIR}/bodies/${version}.body"
    if [ -f "$f" ]; then cat "$f"; return 0; else return 1; fi
  fi
  if ! command -v gh >/dev/null 2>&1; then
    echo "::error::release-surface: gh not available or not authenticated." >&2
    exit 2
  fi
  gh release view "v${version}" --json body -q '.body' 2>/dev/null
}

# --- Evidence seam: the tag /releases/latest currently resolves to (S4). Prints the tag
#     (e.g. "v2.19.6") or nothing if no Release exists yet. Never hard-fails on "no
#     releases at all" — that is a legitimate, if unlikely, repository state and is
#     reported as its own WRONG-LATEST finding rather than a contract error. ---
evidence_latest() {
  if [ -n "$EVIDENCE_DIR" ]; then
    [ -f "${EVIDENCE_DIR}/latest.txt" ] && tr -d '[:space:]' < "${EVIDENCE_DIR}/latest.txt"
    return 0
  fi
  if ! command -v gh >/dev/null 2>&1; then
    echo "::error::release-surface: gh not available or not authenticated." >&2
    exit 2
  fi
  gh api "repos/${EXPECTED_REPO}/releases/latest" --jq '.tag_name' 2>/dev/null || true
}

# --- Local-tag conjunct: mode-gated (ADR-078 §D5). In CI, actions/checkout at the
#     default fetch-depth fetches either no tags or exactly origin's, so a "local" tag
#     check there is either vacuously false for everything or trivially identical to the
#     origin check — not a check. Active only for an operator on a workstation with no
#     injected evidence, where "I tagged locally but never pushed" is a real edge case. A
#     check that cannot fail must be labelled as such, not silently counted as a pass.
LOCAL_TAG_ACTIVE=1
if [ -n "${CI:-}" ] || [ -n "$EVIDENCE_DIR" ]; then
  LOCAL_TAG_ACTIVE=0
  echo "::notice::release-surface: local-tag conjunct SKIPPED — the runner's local tag set is a checkout artifact, not a fact about the repository."
fi

# --- Stage 1: parse. Dash-agnostic by construction — the grammar never looks past the
#     closing bracket, so ASCII-hyphen, em-dash, and parenthetical-title headers are all
#     reached. Deliberately NOT `grep -P`: this script must also run on an operator's
#     macOS workstation, where the default /bin/grep has no -P support. ---
ALL_TOKENS="$(grep -o '^## \[[^]]*\]' "$CHANGELOG_PATH" | sed -E 's/^## \[//; s/\]$//')"

TAGS_EVIDENCE="$(evidence_tags)"

CHECKED=0
FAILED=0
SKIP_NONXYZ=0
SKIP_BELOWFLOOR=0
MAX_VERSION=""

while IFS= read -r tok; do
  [ -z "$tok" ] && continue

  # --- Stage 2: classify (§B1 / ADR-078 §D1 — resolves N-1 at the parser stage). ---
  LC_TOK="$(printf '%s' "$tok" | tr '[:upper:]' '[:lower:]')"
  if [ "$LC_TOK" = "unreleased" ]; then
    echo "::notice::release-surface: '${tok}' SKIP — in-flight section, not yet released (counted under non-x.y.z: 'Unreleased' is not an x.y.z token either)."
    SKIP_NONXYZ=$((SKIP_NONXYZ + 1))
    continue
  fi
  if ! [[ "$tok" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "::notice::release-surface: '${tok}' SKIP — non-x.y.z, not publishable by publish-release.sh:31 (reason, not merely below-floor: the producer structurally refuses any non-x.y.z version)."
    SKIP_NONXYZ=$((SKIP_NONXYZ + 1))
    continue
  fi

  # --- Stage 3: floor. Only COMPARABLE tokens (matched ^[0-9]+\.[0-9]+\.[0-9]+$ above)
  #     ever reach semver-compare.sh, so its fail-closed `exit 2` on malformed input can
  #     never fire here through normal operation. The branch below is retained as an
  #     UNREACHABLE-BY-CONSTRUCTION assertion: if it ever prints, the parser/comparator
  #     contract has been broken elsewhere and this is a hard, loud failure — not a
  #     silently-collapsed skip (ADR-078 §D1). ---
  set +e
  GE_OUT="$("$SEMVER_CMP" ge "$tok" "$FLOOR" 2>/tmp/release-surface-semver-stderr.$$)"
  GE_RC=$?
  set -e
  if [ "$GE_RC" -eq 2 ]; then
    echo "::error::release-surface: comparator rejected '${tok}' which the parser classified COMPARABLE — parser/comparator contract violated. Fail-closed; not a routine path." >&2
    cat /tmp/release-surface-semver-stderr.$$ >&2 2>/dev/null || true
    rm -f /tmp/release-surface-semver-stderr.$$
    exit 2
  fi
  rm -f /tmp/release-surface-semver-stderr.$$
  if [ "$GE_RC" -ne 0 ]; then
    echo "::notice::release-surface: '${tok}' SKIP — below floor ${FLOOR}."
    SKIP_BELOWFLOOR=$((SKIP_BELOWFLOOR + 1))
    continue
  fi

  # --- In scope. ---
  CHECKED=$((CHECKED + 1))
  if [ -z "$MAX_VERSION" ]; then
    MAX_VERSION="$tok"
  else
    set +e
    IS_NEW_MAX="$("$SEMVER_CMP" ge "$tok" "$MAX_VERSION" 2>/dev/null)"
    set -e
    [ "$IS_NEW_MAX" = "true" ] && MAX_VERSION="$tok"
  fi

  # --- Stage 4a: TAG conjunct. ---
  ORIGIN_HAS_TAG=0
  if printf '%s\n' "$TAGS_EVIDENCE" | grep -qF "refs/tags/v${tok}"; then
    ORIGIN_HAS_TAG=1
  fi
  LOCAL_TAG_NOTE=""
  if [ "$ORIGIN_HAS_TAG" -eq 1 ] && [ "$LOCAL_TAG_ACTIVE" -eq 1 ]; then
    if ! git tag -l "v${tok}" 2>/dev/null | grep -qF "v${tok}"; then
      LOCAL_TAG_NOTE=" (origin has it; local checkout does not — tagged but never pushed?)"
      ORIGIN_HAS_TAG=0
    fi
  fi
  if [ "$ORIGIN_HAS_TAG" -eq 0 ]; then
    echo "::error::release-surface: ${tok} MISSING-TAG — no refs/tags/v${tok} on origin.${LOCAL_TAG_NOTE}" >&2
    echo "  Remedy: bash scripts/publish-release.sh ${tok} at the commit you intend to tag." >&2
    FAILED=$((FAILED + 1))
    continue
  fi

  # --- Stage 4b: RELEASE conjunct (existence + body predicate). ---
  if ! BODY="$(evidence_body "$tok")"; then
    echo "::error::release-surface: ${tok} MISSING-RELEASE — tag exists but no GitHub Release." >&2
    echo "  Remedy: same producer; it creates tag and Release atomically (ADR-076)." >&2
    FAILED=$((FAILED + 1))
    continue
  fi
  if [ -z "$BODY" ] || ! body_names_version "$BODY" "$tok"; then
    echo "::error::release-surface: ${tok} DEFECTIVE-RELEASE-BODY — Release exists but its body names" >&2
    echo "  neither \"${tok}\" nor \"CHANGELOG.md#${tok//./}---\"." >&2
    echo "  Remedy: gh release edit v${tok} --notes-file <curated body>. Do NOT regenerate from" >&2
    echo "  CHANGELOG.md — the curated editorial bodies are the house convention (ADR-077)." >&2
    FAILED=$((FAILED + 1))
    continue
  fi
done <<EOF
$ALL_TOKENS
EOF

if [ "$CHECKED" -eq 0 ]; then
  echo "::error::release-surface: 0 versions checked at or above floor ${FLOOR} — treated as fail-closed, never a silent pass." >&2
  exit 2
fi

# --- Stage 5 (S4 / AMEND 4): the Primary success metric. GitHub's /releases/latest
#     tracks CREATION order, not semver order (verified live, docs/security-review-v2.19.6.md
#     S4) — so ascending Scope-A publish order is load-bearing for a visitor following
#     homepageUrl, and AC-PUB-1's "0 failures" is satisfiable with the WRONG release
#     marked Latest. This is a distinct finding from the three per-version conjuncts
#     above: it can be RED even when every individual version has a valid tag+body. ---
ACTUAL_LATEST="$(evidence_latest)"
EXPECTED_LATEST="v${MAX_VERSION}"
if [ "$ACTUAL_LATEST" != "$EXPECTED_LATEST" ]; then
  echo "::error::release-surface: WRONG-LATEST — /releases/latest resolves to '${ACTUAL_LATEST:-<none>}', expected '${EXPECTED_LATEST}' (the highest in-scope version)." >&2
  echo "  \"Latest\" tracks creation order, not semver order — publishing out of ascending order" >&2
  echo "  leaves the wrong release as the public landing page. Remedy: publish remaining versions" >&2
  echo "  in ascending order via scripts/publish-release.sh (docs/security-review-v2.19.6.md S4)." >&2
  FAILED=$((FAILED + 1))
fi

echo "release-surface: ${CHECKED} checked, ${FAILED} failed, $((SKIP_NONXYZ + SKIP_BELOWFLOOR)) skipped (${SKIP_NONXYZ} non-x.y.z, ${SKIP_BELOWFLOOR} below-floor)."

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
