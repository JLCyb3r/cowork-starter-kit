#!/usr/bin/env bash
# vendor-prune.sh — delete vendored/agency-agents/ files that cowork.lock.json no longer carries.
#
# ADR-080 identifies the disk->lock direction as the one thing scripts/vendor-agency.sh
# structurally lacks: it only ever `mkdir -p`s and writes, never deletes. This script is that
# repair (docs/architecture.md ADR-100 D5). It is intended to run immediately after
# vendor-agency.sh, inside sync-agency.yml, so every future sync PR arrives with orphans already
# gone rather than leaving a stale third-party file on disk for a human to notice and delete by
# hand (the mechanism by which the two engineering/ security-persona copies this cycle repairs
# went stale in the first place).
#
# S1 (docs/internal/security/security-review-v2.19.16.md, CRITICAL — binding on this file).
# A naive `find ... | while IFS= read -r vfile` loop is LINE-oriented: a vendored filename
# containing a newline byte splits into two iterations, and the second iteration's `$vfile` is
# the text after the newline, resolved RELATIVE TO THE WORKING DIRECTORY (the repo root in CI) —
# not constrained by `$ROOT` in any way, because the prefix-stripping (`${vfile#"${ROOT}"/}`)
# never runs on the raw `find` line. Measured on a fixture outside this repo: such a filename
# caused `rm -f -- "$vfile"` to delete a file at the REPO ROOT and the script exited 0, reporting
# success. It repeats on every run, because `rm -f` on the already-missing truncated first half
# also exits 0. Two independent controls close this, either one of which alone would have stopped
# the demonstrated attack:
#   1. NUL-delimited enumeration (`find -print0` / `read -r -d ''`) closes the CLASS — a newline
#      can no longer split a `find` result into two lines.
#   2. A `"$ROOT"/*` prefix assertion on every candidate closes the INSTANCE — even a path that
#      arrived through some other means (a future refactor, a different enumeration) is refused
#      before any `rm` runs.
# See tests/vendor-prune-firing-controls.md for the four required controls (positive, negative,
# refusal, and the S1 newline-plus-surviving-sentinel reproduction), each run against a fixture
# tree outside this repo — never against this repo's own working tree.
#
# Usage: bash scripts/vendor-prune.sh   (run from the repo root)
# Exit:  0 = pruned zero or more orphans; the lock had at least one entry
#        1 = usage/precondition failure (missing lock, empty lock, or a candidate path outside
#            $ROOT) — in every failure case, zero files are deleted before the script exits.

set -euo pipefail

LOCK="cowork.lock.json"
ROOT="vendored/agency-agents"

if [ ! -f "$LOCK" ]; then
  echo "::error::vendor-prune: ${LOCK} not found — run from the repo root." >&2
  exit 1
fi

# Zero-lock refusal: `files: []` (or an unparseable `.files`) must delete NOTHING and exit
# non-zero, making "an empty lock deletes the corpus" structurally unreachable — the same vacuity
# failure ADR-080's other guards exist to close, now guarded inside the only script that can
# cause it (docs/architecture.md ADR-100 D5).
LOCK_N=$(jq '.files | length' "$LOCK" 2>/dev/null || echo -1)
if [ "$LOCK_N" -le 0 ]; then
  echo "::error::vendor-prune: ${LOCK} has ${LOCK_N} files[] entries — refusing to prune against an empty or unreadable lock." >&2
  exit 1
fi

LOCK_PATHS="$(jq -r '.files[].path' "$LOCK")"

if [ ! -d "$ROOT" ]; then
  echo "vendor-prune: '${ROOT}' does not exist — nothing to prune."
  exit 0
fi

PRUNED=0
while IFS= read -r -d '' vfile; do
  # Prefix assertion (S1 remedy, control 2) — checked independently of the NUL-delimited
  # enumeration above, so either control alone would still stop the demonstrated attack.
  case "$vfile" in
    "$ROOT"/*) ;;
    *)
      echo "::error::vendor-prune: refusing to act on '${vfile}' — outside ${ROOT}." >&2
      exit 1
      ;;
  esac

  rel="${vfile#"${ROOT}"/}"
  # `set -e` does not abort here: `grep` is not the final command in this `&&` list, so its
  # non-zero exit (no match — the file IS an orphan) is exempt, and control falls through to the
  # `rm` below. Verified this session against a hand-built case before relying on it.
  printf '%s\n' "$LOCK_PATHS" | grep -qxF "$rel" && continue

  rm -f -- "$vfile"
  PRUNED=$((PRUNED + 1))
  echo "vendor-prune: removed orphan ${vfile}"
done < <(find "$ROOT" ! -name LICENSE \( -type f -o -type l \) -print0)

echo "vendor-prune: ${PRUNED} orphan(s) removed."
