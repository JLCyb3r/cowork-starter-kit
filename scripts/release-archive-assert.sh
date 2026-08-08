#!/usr/bin/env bash
# scripts/release-archive-assert.sh — sole home of the release-archive DROP/KEEP lists
# (ADR-079 decision 3 / docs/spec.md AC-A1-2b, AC-A1-2c, AC-A1-4).
#
# Two copies of a negative list drift, and a drifted DROP list fails OPEN — this repo
# already states that pattern at verify-release-surface.sh:95-96 ("the SAME function
# publish-release.sh calls, not a second hand-copied check"). This script is the same
# idea applied to the release-archive content assertion: ONE definition, called from two
# sites —
#   (a) PREVENTION (authoritative) — scripts/publish-release.sh, immediately before
#       `gh release create` / `gh release upload`, against the exact archive files about
#       to be attached, with no rebuild in between.
#   (b) DETECTION (post-hoc) — .github/workflows/release-assets.yml, against the archive
#       bytes downloaded from the published Release (what GitHub actually serves).
#
# Usage: scripts/release-archive-assert.sh <archive-file> <prefix>
#   <archive-file>  path to a .zip or .tar.gz release archive
#   <prefix>        the archive's internal top-level prefix, e.g. "cowork-starter-kit-2.19.7/"
#                    ALWAYS supplied by the caller — never re-derived here (AC-A1-2c), so
#                    the assertion and the artifact cannot disagree about what they inspect.
#
# Exit: 0 = both DROP and KEEP assertions pass
#       1 = usage error, unreadable archive, unsupported format, or an assertion failure
#
# [S5 / AC-A1-2c] There is NO flag, mode, or code path that runs the DROP loop without
# also running the KEEP loop. The DROP loop fails only when it FINDS a match — a wrong
# prefix (or a wrong archive) then matches nothing and DROP reports a false PASS. KEEP
# (which fails when it does NOT find a match) is what catches that wrong-prefix case, so
# KEEP is not optional additional coverage — it is load-bearing for DROP's own
# correctness. Both loops always run, unconditionally, in this order, every invocation.
#
# Bash portability (@security S16): this script runs under bash 5 in CI (ubuntu-latest)
# AND under bash 3.2 on an operator's macOS via publish-release.sh. No mapfile/readarray,
# no associative arrays, and every array expansion is written so it is safe even if bash
# ever evaluated it with an empty array under `set -u`.

set -euo pipefail

if [ $# -ne 2 ]; then
  echo "ERROR: usage: release-archive-assert.sh <archive-file> <prefix>" >&2
  exit 1
fi

ARCHIVE="$1"
PREFIX="$2"

if [ ! -f "$ARCHIVE" ]; then
  echo "ERROR: release-archive-assert: archive not found: ${ARCHIVE}" >&2
  exit 1
fi
if [ -z "$PREFIX" ]; then
  echo "ERROR: release-archive-assert: prefix argument must not be empty." >&2
  exit 1
fi

# --- Negative assertions — these MUST NOT appear in the archive. ---
# v2.8.0 WS5 (ADR-037): the ~10 individually-named docs/ entries collapsed to a single
# docs/internal/ prefix-match, which covers the whole 40-file subtree
# (docs/internal/{qa,security,compliance,process,planning}/) plus any future file placed
# there. docs/research/ and docs/project-audit-v2.6.1.md REMOVED (now public, see
# KEEP_PATHS below). docs/patterns.md ADDED (Council-tooling exempt, still internal).
DROP_PATHS=(
  ".gitignore"
  ".markdownlint.jsonc"
  ".markdownlintignore"
  "CHANGELOG.md"
  "CONTRIBUTING.md"
  ".github/"
  "tests/"
  "upstream-contribution/"
  "scripts/install-pre-commit.sh"
  "docs/spec.md"
  "docs/retro.md"
  "docs/patterns.md"
  "docs/internal/"
  ".gitattributes"
)

# --- Positive assertions — these MUST be present (guards against over-greedy
#     export-ignore). v2.8.0 WS5: docs/research/, docs/project-audit-v2.6.1.md,
#     docs/how-it-works.md, docs/faq.md, and TRUST.md added — all newly public
#     credibility assets. ---
KEEP_PATHS=(
  "VERSION"
  "README.md"
  "LICENSE"
  "WIZARD.md"
  "SETUP-CHECKLIST.md"
  "cowork.lock.json"
  "CLAUDE.md"
  "TRUST.md"
  "scripts/setup-folders.sh"
  "scripts/setup-folders.ps1"
  "docs/architecture.md"
  "docs/project-audit-v2.6.1.md"
  "docs/research/v2.2-skill-landscape.md"
  "docs/research/v2.7-usercase-test-and-improvement-research.md"
  "docs/how-it-works.md"
  "docs/faq.md"
  "vendored/agency-agents/LICENSE"
)

# --- List archive contents. [S4] Both .zip and .tar.gz are supported — the tarball
#     shipped entirely unasserted before this script existed (release-assets.yml only
#     ever ran `unzip -Z1` against the .zip). Format is detected from the filename, not
#     guessed from content, so a misnamed file fails loudly rather than silently. ---
case "$ARCHIVE" in
  *.zip)
    if ! command -v unzip >/dev/null 2>&1; then
      echo "ERROR: release-archive-assert: 'unzip' not available to list ${ARCHIVE}." >&2
      exit 1
    fi
    LISTING="$(unzip -Z1 "$ARCHIVE")"
    ;;
  *.tar.gz | *.tgz)
    if ! command -v tar >/dev/null 2>&1; then
      echo "ERROR: release-archive-assert: 'tar' not available to list ${ARCHIVE}." >&2
      exit 1
    fi
    LISTING="$(tar -tzf "$ARCHIVE")"
    ;;
  *)
    echo "ERROR: release-archive-assert: unsupported archive format: ${ARCHIVE} (expected .zip or .tar.gz)." >&2
    exit 1
    ;;
esac

FAIL=0

# --- DROP loop — fails when a match IS found. ---
for path in "${DROP_PATHS[@]}"; do
  if printf '%s\n' "$LISTING" | grep -E "^${PREFIX}${path}" >/dev/null; then
    echo "FAIL: DROP-list path present in ${ARCHIVE}: ${path}" >&2
    FAIL=1
  fi
done

# --- KEEP loop — fails when a match is NOT found. This is what catches a wrong PREFIX
#     (or a wrong archive) making the DROP loop above pass for the wrong reason. ---
for path in "${KEEP_PATHS[@]}"; do
  if ! printf '%s\n' "$LISTING" | grep -E "^${PREFIX}${path}\$" >/dev/null; then
    echo "FAIL: KEEP-list path missing from ${ARCHIVE}: ${path}" >&2
    FAIL=1
  fi
done

if [ "$FAIL" -ne 0 ]; then
  echo "release-archive-assert: FAILED for ${ARCHIVE} (prefix '${PREFIX}')." >&2
  exit 1
fi

echo "release-archive-assert: PASS — ${ARCHIVE} (prefix '${PREFIX}', DROP=${#DROP_PATHS[@]}, KEEP=${#KEEP_PATHS[@]})."
exit 0
