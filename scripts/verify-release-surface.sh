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
# shellcheck disable=SC1091  # see scripts/publish-release.sh's identical comment — this
# repo's ShellCheck CI job never passes -x, so this include can never be followed there.
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

# --- Destination-repo guard (@qa Phase 5 §9.5, docs/qa-report-v2.19.6.md — the "ninth
#     instance"). The original destination-repo BLOCKER fix (§3) touched publish-release.sh
#     only; this script's own `evidence_body()` makes an equally GH_REPO-redirectable
#     `gh release view` call that shipped with no guard at all. Read-only, so a redirect
#     here cannot itself publish anywhere — but it can make the standing gate report a
#     FALSE PASS: `GH_REPO=cli/cli` demonstrated live that `gh release view v2.18.0`
#     returns cli/cli's own release notes, which happen to contain the literal substring
#     "2.18.0" via GitHub's auto-generated "Full Changelog: .../compare/v2.17.0...v2.18.0"
#     footer — coincidentally satisfying body_names_version() for a completely unrelated
#     repository. A false MISSING-RELEASE is noisy but safe; a false PASS is the one
#     outcome that makes this gate worse than not having it, in the exact artifact this
#     cycle exists to make trustworthy.
#
#     Shared implementation: scripts/release-predicate.sh's refuse_if_gh_redirect_env_set()
#     — the SAME function publish-release.sh calls, not a second hand-copied check. Runs
#     UNCONDITIONALLY, HERE, before evidence_tags()/evidence_body()/evidence_latest() are
#     even defined, regardless of --evidence-dir: in evidence-injected mode no `gh` call
#     happens at all, so this check is provably inert there rather than merely assumed
#     to be — it costs nothing and closes the door on a future edit accidentally adding a
#     live fallback inside the evidence-dir branch without this guard already covering it.
#     The seam cannot be used to route AROUND this guard: --evidence-dir controls where
#     evidence is READ from, not whether this check runs.
refuse_if_gh_redirect_env_set "$EXPECTED_REPO" || exit 2

# --- Destination-repo POSITIVE assertion (@security Phase 6, S-A2, docs/security-audit-
#     v2.19.6.md — "the right remedy"). Same rationale as publish-release.sh's identical
#     call — see that file's comment for the full argument. Gated on EVIDENCE_DIR being
#     unset: this assertion needs a live, authenticated `gh api` call, which would defeat
#     the entire point of --evidence-dir (offline, no-network fixture testing) if forced
#     onto that path too. In evidence-dir mode, no `gh` call of any kind occurs — the free
#     env-var refusal above already covers that path completely (it is provably inert
#     there rather than merely unneeded), and this positive assertion adds nothing further
#     to guard because there is nothing left to redirect.
if [ -z "$EVIDENCE_DIR" ]; then
  assert_gh_destination_repo "$EXPECTED_REPO" || exit 2
fi

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
  # [AC-1, v2.19.11 - ADR-089] The old `2>/dev/null` discarded git own stderr, and under
  # `set -euo pipefail` the failed pipeline aborted the top-level assignment at :218 with
  # no diagnostic at all: bash exit code 128, no `::error::` line, and git own
  # "Could not resolve host" already thrown away. Mirrors evidence_body() S-A3 pattern
  # (:135-149): capture stderr in a mktemp file, read rc explicitly, surface the real
  # cause, and fail CLOSED with exit 2 (contract/tool error).
  #
  # LOAD-BEARING (ADR-089): `rc=$?` is reachable here ONLY because bash `inherit_errexit`
  # is OFF (the default; scripts/ and .github/ contain no `shopt` at all). This function
  # runs inside the `$( )` at :218, which does not inherit `set -e` while that option is
  # off; enabling it makes the assignment below abort the subshell before `rc=$?` runs,
  # silently restoring the exact opaque-128 defect this closes. DO NOT add
  # `shopt -s inherit_errexit` to this script without re-bracketing every `rc=$?` idiom
  # here and in evidence_body().
  #
  # NOT `2>&1` into the captured variable: git can exit 0 while writing to stderr
  # ("error: refs/tags/vX.Y.Z does not point to a valid object!"), and :286 tests the
  # captured evidence with `grep -qF "refs/tags/v${tok}"` against the whole line - a
  # merged stream turns a broken-ref diagnostic into a tag-exists GREEN. mktemp keeps the
  # two streams apart (S-A6: mktemp, never a fixed path).
  local ls_remote_stderr out rc
  ls_remote_stderr="$(mktemp)"
  out="$(git ls-remote --tags origin 2>"$ls_remote_stderr")"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "::error::release-surface: 'git ls-remote --tags origin' failed (exit ${rc}) —" >&2
    echo "  the origin tag set could not be read, so every MISSING-TAG finding below would" >&2
    echo "  be an artifact of this failure rather than a fact about the repository." >&2
    echo "  Failing closed. Raw git error:" >&2
    sed 's/^/    /' "$ls_remote_stderr" >&2
    rm -f "$ls_remote_stderr"
    exit 2
  fi
  rm -f "$ls_remote_stderr"
  printf '%s\n' "$out" | awk '{print $2}'
}

# --- Evidence seam: Release body for a version. Prints body (possibly empty) and returns
#     0 if a Release exists, 1 if none exists (MISSING-RELEASE).
#
#     S-A3 fix (@security Phase 6, docs/security-audit-v2.19.6.md): `gh release view`
#     returns non-zero for "no such release" and for an unrelated transient failure alike
#     (expired token, rate limit, network) — `2>/dev/null` used to discard that distinction
#     entirely, so the caller printed "MISSING-RELEASE ... run publish-release.sh" even
#     when the real cause was, say, a rate limit, which is actively wrong advice. This does
#     NOT fully separate the two into different top-level tokens (that would need a new
#     greppable token and a new remedy, a larger change) — it surfaces `gh`'s own stderr
#     alongside the MISSING-RELEASE finding, so an operator reading the output sees the
#     real cause instead of being silently misdiagnosed. Uses `mktemp`, not a fixed path
#     (S-A6's same fix, applied here too, since this is new code written in the same pass). ---
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
  local gh_stderr out rc
  gh_stderr="$(mktemp)"
  out="$(gh release view "v${version}" --json body -q '.body' 2>"$gh_stderr")"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "::error::release-surface: 'gh release view v${version}' failed (exit ${rc}) —" >&2
    echo "  treated as MISSING-RELEASE below, but the real cause may not be a missing" >&2
    echo "  release. Raw gh error:" >&2
    sed 's/^/    /' "$gh_stderr" >&2
    rm -f "$gh_stderr"
    return 1
  fi
  rm -f "$gh_stderr"
  printf '%s' "$out"
  return 0
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
#     macOS workstation, where the default /bin/grep has no -P support.
#
#     `|| true` (@qa Phase 5 WARNING, docs/qa-report-v2.19.6.md §7): `grep -o` with ZERO
#     matches exits 1, and under `pipefail` that makes this whole pipeline's status 1 even
#     though `sed` itself succeeds — under `set -e`, a plain assignment aborts the script
#     right here, before the loop or the documented CHECKED==0 fail-closed branch below is
#     ever reached. Not reachable with the real CHANGELOG.md (45+ headers, always), but
#     `--changelog` is a user-facing flag on the evidence-injection seam — a malformed file
#     there deserves the documented `exit 2` diagnostic, not a silent, unexplained `exit 1`
#     from a plain variable assignment. `|| true` only neutralizes THIS pipeline's exit
#     status for the "no match" case; it does not suppress any error the loop or the
#     CHECKED==0 check below would otherwise catch — ALL_TOKENS is simply empty and the
#     loop runs zero times, exactly as if the CHANGELOG had no headers, which is the truth. ---
ALL_TOKENS="$(grep -o '^## \[[^]]*\]' "$CHANGELOG_PATH" | sed -E 's/^## \[//; s/\]$//' || true)"

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
  # S-A6 fix (@security Phase 6): `$$`-suffixed is PID-scoped, not attacker-predictable
  # across invocations, and this script never performs a write — meaningfully weaker
  # exposure than publish-release.sh's fixed-path instance, but the same class, and the
  # same one-line fix (`mktemp`) applies. Created fresh each loop iteration, removed
  # immediately after use on every exit path below.
  SEMVER_STDERR="$(mktemp)"
  set +e
  # stdout ("true"/"false") is not needed — only the exit code drives classification below;
  # stderr is kept (ShellCheck SC2034 flagged the prior form's unused capture variable).
  "$SEMVER_CMP" ge "$tok" "$FLOOR" >/dev/null 2>"$SEMVER_STDERR"
  GE_RC=$?
  set -e
  if [ "$GE_RC" -eq 2 ]; then
    echo "::error::release-surface: comparator rejected '${tok}' which the parser classified COMPARABLE — parser/comparator contract violated. Fail-closed; not a routine path." >&2
    cat "$SEMVER_STDERR" >&2 2>/dev/null || true
    rm -f "$SEMVER_STDERR"
    exit 2
  fi
  rm -f "$SEMVER_STDERR"
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
  # [E1 / AC-E1-1, v2.19.7 — @security Phase 6 S-A3] evidence_body()'s `exit 2` ("gh
  # unavailable", :151-154 above — a fail-closed hard stop) is called here inside a
  # `$( )` command substitution, which bash ALWAYS runs in a subshell — `exit 2` there
  # terminates only that subshell, and the CALLER only ever sees a non-zero return code
  # via `$?`. The prior form (`if ! BODY="$(evidence_body "$tok")"; then`) collapsed
  # EVERY non-zero return — rc=1 (a real MISSING-RELEASE) and rc=2 (a hard environment
  # error) alike — into the same MISSING-RELEASE branch, degrading a "gh not available"
  # hard stop into noisy-but-safe (fail-CLOSED, not fail-open per S-A3's calibration) per-
  # tag findings. Captured with `set +e`/`set -e` bracketing (same idiom already used
  # above for $SEMVER_CMP calls) so `$?` can be read explicitly BEFORE any other command
  # overwrites it, and rc=2 is propagated rather than silently downgraded.
  set +e
  BODY="$(evidence_body "$tok")"
  BODY_RC=$?
  set -e
  if [ "$BODY_RC" -eq 2 ]; then
    echo "::error::release-surface: evidence_body(${tok}) returned a hard environment error (rc=2) —" >&2
    echo "  propagating rather than degrading to a per-tag MISSING-RELEASE finding." >&2
    exit 2
  fi
  if [ "$BODY_RC" -ne 0 ]; then
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

# S-A8 fix (@security Phase 6, docs/security-audit-v2.19.6.md): Phase-2 AMEND 6 asked for
# TWO self-identifying signals in evidence-injected mode — the `::warning::` banner above
# (shipped) and an explicit marker in THIS summary line (did not ship). The banner is what
# survives in a full CI log; this line is what survives a copy-paste into a retro, a PR
# body, or a risk-register row — for a cycle about records that read as authoritative while
# being false, the un-shipped half was the load-bearing one.
SUMMARY_SUFFIX=""
if [ -n "$EVIDENCE_DIR" ]; then
  SUMMARY_SUFFIX=" [EVIDENCE-INJECTED — not a fact about this repository]"
fi
echo "release-surface: ${CHECKED} checked, ${FAILED} failed, $((SKIP_NONXYZ + SKIP_BELOWFLOOR)) skipped (${SKIP_NONXYZ} non-x.y.z, ${SKIP_BELOWFLOOR} below-floor).${SUMMARY_SUFFIX}"

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
