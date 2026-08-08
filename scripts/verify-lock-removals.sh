#!/usr/bin/env bash
# scripts/verify-lock-removals.sh — the removal ledger (ADR-080 decisions 3, 4, 5, 6 /
# docs/spec.md AC-B5-7, AC-B5-7a, AC-B5-8, AC-B5-9).
#
# Asserts, across two revisions of cowork.lock.json:
#   1. Subset invariant (ADR-080 §Amendment): every path present in the OLD revision's
#      files[] and absent from the NEW revision's is present in the NEW revision's
#      .cowork-allowlist.json blocked_files[].path — UNLESS it is classified MOVED (6).
#      Subset, not equality: nexus-strategy.md is in blocked_files but was never in the
#      lock (blocked at fetch time), and on a cycle with no removals the removed set is
#      empty while blocked_files is not — equality fails on day one.
#   2. blocked_files itself may not silently shrink (AC-B5-8): no path present in the OLD
#      revision's blocked_files[].path may be absent from the NEW revision's.
#   3. A rename is classified MOVED, not laundered into a removal (AC-B5-9): where a path
#      absent from the new lock has a content_sha256 that reappears under a DIFFERENT
#      path in the new lock, it is MOVED and does NOT require a blocked_files entry.
#
# This is a NOTIFICATION, not a gate (ADR-080 §Consequences, stated precisely): live probe
# shows required_status_checks absent, require_code_owner_reviews: false,
# required_approving_review_count: 0. An undeclared removal becomes visible in CI and in
# the diff; it is not prevented. It becomes blocking only if the owner enables required
# status checks — an owner-side decision no agent makes (same dependency as OQ-2).
#
# Two invocation modes:
#
#   GIT-REF MODE (the real CI call, .github/workflows/quality.yml, pull_request only):
#     scripts/verify-lock-removals.sh --base <git-ref> --head <git-ref>
#       [--lock-file PATH] [--allowlist-file PATH]
#     Reads cowork.lock.json / .cowork-allowlist.json via `git show <ref>:<path>` at both
#     refs. [CRITICAL — Phase 2 S2 / AC-B5-7a] The caller MUST checkout with
#     fetch-depth: 0 — at default depth 1, `git show origin/<base>:...` cannot resolve on
#     a pull_request event. Failure to resolve either blob at either ref is a HARD, NAMED
#     failure. `|| echo '{}'` (or any equivalent silent empty-default) is FORBIDDEN — it
#     yields an empty previous lock, an empty removed set, and a false PASS, reproducing
#     this project's dominant defect family inside the control written to end it.
#
#   FILE MODE (test seam — fixture-based negative controls, no git commits required):
#     scripts/verify-lock-removals.sh --base-lock F --base-allowlist F \
#                                      --head-lock F --head-allowlist F
#     Reads the four JSON documents directly from disk. Neither CI call site uses this
#     mode; it exists so the firing negative controls in docs/spec.md can be exercised
#     against plain fixture files.
#
# Exit: 0 = ledger PASS
#       1 = usage error, unresolvable base/head revision, or one or more assertions failed

set -euo pipefail

BASE_REF=""
HEAD_REF=""
LOCK_FILE="cowork.lock.json"
ALLOWLIST_FILE=".cowork-allowlist.json"
BASE_LOCK_PATH=""
BASE_ALLOWLIST_PATH=""
HEAD_LOCK_PATH=""
HEAD_ALLOWLIST_PATH=""
MODE=""
REPO_DIR="."

while [ $# -gt 0 ]; do
  case "$1" in
    --base) BASE_REF="${2:-}"; MODE="git"; shift 2 ;;
    --head) HEAD_REF="${2:-}"; MODE="git"; shift 2 ;;
    --lock-file) LOCK_FILE="${2:-}"; shift 2 ;;
    --allowlist-file) ALLOWLIST_FILE="${2:-}"; shift 2 ;;
    --repo-dir) REPO_DIR="${2:-}"; shift 2 ;;
    --base-lock) BASE_LOCK_PATH="${2:-}"; MODE="file"; shift 2 ;;
    --base-allowlist) BASE_ALLOWLIST_PATH="${2:-}"; MODE="file"; shift 2 ;;
    --head-lock) HEAD_LOCK_PATH="${2:-}"; MODE="file"; shift 2 ;;
    --head-allowlist) HEAD_ALLOWLIST_PATH="${2:-}"; MODE="file"; shift 2 ;;
    *)
      echo "ERROR: verify-lock-removals: unknown argument '$1'" >&2
      exit 1 ;;
  esac
done

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: verify-lock-removals: 'jq' not available." >&2
  exit 1
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

if [ "$MODE" = "git" ]; then
  if [ -z "$BASE_REF" ] || [ -z "$HEAD_REF" ]; then
    echo "ERROR: verify-lock-removals: git-ref mode requires both --base and --head." >&2
    exit 1
  fi
  if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: verify-lock-removals: 'git' not available." >&2
    exit 1
  fi
  BASE_LOCK_PATH="${WORKDIR}/base-lock.json"
  BASE_ALLOWLIST_PATH="${WORKDIR}/base-allowlist.json"
  HEAD_LOCK_PATH="${WORKDIR}/head-lock.json"
  HEAD_ALLOWLIST_PATH="${WORKDIR}/head-allowlist.json"

  # [AC-B5-7a] Each `git show` is asserted individually and explicitly — no `|| echo`
  # fallback of any kind. A failure here is a named, fatal error, never a degraded empty
  # document.
  if ! git -C "$REPO_DIR" show "${BASE_REF}:${LOCK_FILE}" > "$BASE_LOCK_PATH" 2>"${WORKDIR}/err"; then
    echo "::error::verify-lock-removals: could not read ${LOCK_FILE} at base ref '${BASE_REF}' — refusing to default to an empty lock. $(cat "${WORKDIR}/err")" >&2
    exit 1
  fi
  if ! git -C "$REPO_DIR" show "${BASE_REF}:${ALLOWLIST_FILE}" > "$BASE_ALLOWLIST_PATH" 2>"${WORKDIR}/err"; then
    echo "::error::verify-lock-removals: could not read ${ALLOWLIST_FILE} at base ref '${BASE_REF}' — refusing to default to an empty allowlist. $(cat "${WORKDIR}/err")" >&2
    exit 1
  fi
  if ! git -C "$REPO_DIR" show "${HEAD_REF}:${LOCK_FILE}" > "$HEAD_LOCK_PATH" 2>"${WORKDIR}/err"; then
    echo "::error::verify-lock-removals: could not read ${LOCK_FILE} at head ref '${HEAD_REF}'. $(cat "${WORKDIR}/err")" >&2
    exit 1
  fi
  if ! git -C "$REPO_DIR" show "${HEAD_REF}:${ALLOWLIST_FILE}" > "$HEAD_ALLOWLIST_PATH" 2>"${WORKDIR}/err"; then
    echo "::error::verify-lock-removals: could not read ${ALLOWLIST_FILE} at head ref '${HEAD_REF}'. $(cat "${WORKDIR}/err")" >&2
    exit 1
  fi
elif [ "$MODE" = "file" ]; then
  if [ -z "$BASE_LOCK_PATH" ] || [ -z "$BASE_ALLOWLIST_PATH" ] || [ -z "$HEAD_LOCK_PATH" ] || [ -z "$HEAD_ALLOWLIST_PATH" ]; then
    echo "ERROR: verify-lock-removals: file mode requires --base-lock, --base-allowlist, --head-lock, and --head-allowlist." >&2
    exit 1
  fi
else
  echo "ERROR: verify-lock-removals: usage: --base REF --head REF  OR  --base-lock F --base-allowlist F --head-lock F --head-allowlist F" >&2
  exit 1
fi

for f in "$BASE_LOCK_PATH" "$BASE_ALLOWLIST_PATH" "$HEAD_LOCK_PATH" "$HEAD_ALLOWLIST_PATH"; do
  if [ ! -r "$f" ]; then
    echo "ERROR: verify-lock-removals: cannot read '${f}'." >&2
    exit 1
  fi
done

FAIL=0

# --- 1 & 3: removed-path classification (REMOVED vs MOVED) + subset invariant. ---
# path<TAB>content_sha256, one per line, for base and head.
BASE_ENTRIES="$(jq -r '.files[] | "\(.path)\t\(.content_sha256 // "")"' "$BASE_LOCK_PATH")"
HEAD_ENTRIES="$(jq -r '.files[] | "\(.path)\t\(.content_sha256 // "")"' "$HEAD_LOCK_PATH")"
HEAD_PATHS="$(printf '%s\n' "$HEAD_ENTRIES" | cut -f1)"
HEAD_SHAS="$(printf '%s\n' "$HEAD_ENTRIES" | cut -f2)"
HEAD_BLOCKED_FILES="$(jq -r '.blocked_files[].path' "$HEAD_ALLOWLIST_PATH")"

REMOVED_COUNT=0
MOVED_COUNT=0
while IFS=$'\t' read -r path sha; do
  [ -z "$path" ] && continue
  if printf '%s\n' "$HEAD_PATHS" | grep -qxF "$path"; then
    continue
  fi
  REMOVED_COUNT=$((REMOVED_COUNT + 1))
  # MOVED classification: this path's OLD content_sha256 reappears under some path in
  # the NEW lock (necessarily a different path, since this path itself is absent there).
  if [ -n "$sha" ] && printf '%s\n' "$HEAD_SHAS" | grep -qxF "$sha"; then
    MOVED_COUNT=$((MOVED_COUNT + 1))
    echo "verify-lock-removals: MOVED — '${path}' (content_sha256 ${sha:0:8}... reappears under a different path in the new lock). No blocked_files entry required."
    continue
  fi
  if ! printf '%s\n' "$HEAD_BLOCKED_FILES" | grep -qxF "$path"; then
    echo "::error::verify-lock-removals: REMOVED — '${path}' is absent from the new lock but NOT present in .cowork-allowlist.json blocked_files[].path. Every lock removal must be a declared blocked_files entry." >&2
    FAIL=1
  else
    echo "verify-lock-removals: REMOVED — '${path}' correctly declared in blocked_files."
  fi
done <<EOF
$BASE_ENTRIES
EOF

# --- 2: blocked_files may not silently shrink (AC-B5-8). ---
BASE_BLOCKED_FILES="$(jq -r '.blocked_files[].path' "$BASE_ALLOWLIST_PATH")"
SHRINK_COUNT=0
while IFS= read -r bpath; do
  [ -z "$bpath" ] && continue
  if ! printf '%s\n' "$HEAD_BLOCKED_FILES" | grep -qxF "$bpath"; then
    echo "::error::verify-lock-removals: blocked_files SHRANK — '${bpath}' was present in the previous revision's blocked_files[].path and is absent from the new revision's." >&2
    FAIL=1
    SHRINK_COUNT=$((SHRINK_COUNT + 1))
  fi
done <<EOF
$BASE_BLOCKED_FILES
EOF

if [ "$FAIL" -ne 0 ]; then
  echo "::error::verify-lock-removals: FAILED (removed=${REMOVED_COUNT}, moved=${MOVED_COUNT}, blocked_files-shrink=${SHRINK_COUNT})." >&2
  exit 1
fi

echo "verify-lock-removals: PASS — removed=${REMOVED_COUNT} (moved=${MOVED_COUNT}, all non-moved removals declared in blocked_files), blocked_files did not shrink."
exit 0
