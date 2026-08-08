#!/usr/bin/env bash
# scripts/verify-vendored-orphans.sh — the disk→lock direction (ADR-080 decision 2 /
# docs/spec.md AC-C1-1, AC-C1-2).
#
# Every OTHER integrity check in this repo iterates forward from cowork.lock.json only
# (quality.yml:1614/:1637, scripts/verify-lock-content-sha.sh:53/:77) — their sole
# presence test is lock→disk, so a file that exists under vendored/agency-agents/ with NO
# lock entry is invisible to all of them. No disk-side enumeration existed anywhere in
# this repo before this script (verified: `grep -rn "find vendored\|find \"vendored\|find
# .*agency-agents" scripts/ .github/` returned no output). This script is that missing
# reverse direction, and per docs/design-v2.19.7.md §D it is built FIRST and is the
# instrument that proves a B5-style removal actually happened on disk — a forward-only
# check structurally cannot prove that.
#
# Usage: scripts/verify-vendored-orphans.sh [--vendored-dir DIR] [--lock FILE]
#   --vendored-dir DIR  defaults to "vendored/agency-agents" (relative to cwd — run from
#                        the repo root, matching this repo's other release/lock scripts).
#                        Override is a TEST SEAM for fixture-based negative controls; the
#                        two real call sites (quality.yml, publish-release.sh) never pass it.
#   --lock FILE          defaults to "cowork.lock.json". Same test-seam rationale.
#
# Enumeration predicate (AC-C1-1 — binding, do not narrow): `find "$VENDORED_DIR"
# ! -name LICENSE \( -type f -o -type l \)`. NEVER `-name '*.md'` — an extension filter is
# blind to a non-Markdown orphan (a stray .py/.sh/.json landing in the vendored tree),
# which is precisely the defect class this script exists to close. LICENSE is excluded
# because it is already verified against license_file_sha256 (quality.yml:1640-1650) —
# excluded because it is checked elsewhere, not because it is unimportant.
#
# [S23 fix — Phase 6 @security] `-type f` alone matches regular files only — a SYMLINK is
# `-type l` and was invisible to this enumeration. `git archive` includes symlinks in both
# release archives regardless, and the forward check (quality.yml's vendored-integrity-
# check, `[ ! -f "$vfile" ]`) FOLLOWS symlinks rather than rejecting them, so it does not
# catch this either — an orphaned symlink could ship in a release archive with neither
# conjunct in ADR-080's soundness argument (lock⊆disk, disk⊆lock) ever seeing it. `-type l`
# is added alongside `-type f`, not in place of it.
#
# Exit: 0 = every file under $VENDORED_DIR (except LICENSE) has a cowork.lock.json
#           files[] entry
#       1 = usage error, unreadable inputs, or one or more orphans found

set -euo pipefail

VENDORED_DIR="vendored/agency-agents"
LOCK_FILE="cowork.lock.json"

while [ $# -gt 0 ]; do
  case "$1" in
    --vendored-dir)
      VENDORED_DIR="${2:-}"; shift 2 ;;
    --lock)
      LOCK_FILE="${2:-}"; shift 2 ;;
    *)
      echo "ERROR: verify-vendored-orphans: unknown argument '$1' (usage: --vendored-dir DIR --lock FILE)" >&2
      exit 1 ;;
  esac
done

if [ ! -d "$VENDORED_DIR" ]; then
  echo "ERROR: verify-vendored-orphans: '${VENDORED_DIR}' is not a directory." >&2
  exit 1
fi
if [ ! -r "$LOCK_FILE" ]; then
  echo "ERROR: verify-vendored-orphans: cannot read lock file '${LOCK_FILE}'." >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: verify-vendored-orphans: 'jq' not available." >&2
  exit 1
fi

# Build the lock's path set once, newline-delimited, for a fast per-file membership test.
LOCK_PATHS="$(jq -r '.files[].path' "$LOCK_FILE")"

FAIL=0
CHECKED=0
ORPHANS=0

while IFS= read -r vfile; do
  [ -z "$vfile" ] && continue
  CHECKED=$((CHECKED + 1))
  # Strip the vendored-dir prefix (and any leading slash) to get the lock's path form,
  # e.g. "vendored/agency-agents/marketing/foo.md" -> "marketing/foo.md".
  rel="${vfile#"${VENDORED_DIR}"/}"
  if ! printf '%s\n' "$LOCK_PATHS" | grep -qxF "$rel"; then
    echo "::error::verify-vendored-orphans: ORPHAN — ${vfile} exists on disk with no cowork.lock.json files[] entry (path '${rel}')." >&2
    FAIL=1
    ORPHANS=$((ORPHANS + 1))
  fi
done < <(find "$VENDORED_DIR" ! -name LICENSE \( -type f -o -type l \))

# A zero-scan run must never silently report success — same house pattern as
# quality.yml's vendored-integrity-check and lock-content-sha-cross-check (a check that
# never checked anything is not a passing check).
if [ "$CHECKED" -eq 0 ]; then
  echo "::error::verify-vendored-orphans: CHECKED=0 — no files found under '${VENDORED_DIR}' (excluding LICENSE). A zero-entry run must never report success." >&2
  exit 1
fi

if [ "$FAIL" -ne 0 ]; then
  echo "::error::verify-vendored-orphans: FAILED — ${ORPHANS} orphan(s) found out of ${CHECKED} vendored file(s) scanned." >&2
  exit 1
fi

echo "verify-vendored-orphans: PASS — ${CHECKED} vendored file(s) scanned, 0 orphans."
exit 0
