#!/usr/bin/env bash
# verify-lock-content-sha.sh — skip-free old-pin tamper check (ADR-075 D1-D3).
#
# Re-attests that content already pinned in a lock (or fixture) file has not
# been retroactively altered: fetches every files[] entry at .pinned_commit_sha
# (the OLD pin — never a new upstream HEAD) and compares the fetched bytes'
# SHA-256 against the stored content_sha256. This is the single
# implementation invoked by sync-agency.yml's hoisted "old-pin tamper check"
# step and by all three sync-verify-ratchet legs in quality.yml — one
# implementation, no reimplementation (D2).
#
# No skip branches (D3): absent/empty/"MISSING" content_sha256 is a hard
# error, not a grace pass; a fetch failure is a hard error, not a
# WARNING+continue (AC-SYNC-6 — one behavior, not a choice). On success,
# prints `verified=<N>` and asserts N == (.files | length) AND N > 0 before
# exiting 0 — a run that verifies nothing must never report success
# (AC-SYNC-2's positive-execution-count requirement).
#
# Usage: scripts/verify-lock-content-sha.sh <lock-or-fixture.json>
#
# Deliberately NOT parameterized by any workflow_dispatch input (D2). The $1
# file supplies its OWN .upstream — this is the intentional fixture lane: a
# fixture is a committed, reviewed file read only by a test job. The
# production sync step always passes cowork.lock.json, whose .upstream is
# the same hardcoded literal the production fetch steps use. No fixture
# value may ever reach the production fetch path — that boundary is an
# invariant, not a convenience.

set -euo pipefail

LOCK_FILE="${1:?Usage: verify-lock-content-sha.sh <lock-or-fixture.json>}"

if [ ! -f "$LOCK_FILE" ]; then
  echo "::error::verify-lock-content-sha.sh: file not found: ${LOCK_FILE}" >&2
  exit 1
fi

UPSTREAM=$(jq -r '.upstream' "$LOCK_FILE")
PINNED=$(jq -r '.pinned_commit_sha' "$LOCK_FILE")
TOTAL=$(jq '.files | length' "$LOCK_FILE")

if [ -z "$UPSTREAM" ] || [ "$UPSTREAM" = "null" ]; then
  echo "::error::verify-lock-content-sha.sh: ${LOCK_FILE} has no .upstream" >&2
  exit 1
fi
if [ -z "$PINNED" ] || [ "$PINNED" = "null" ]; then
  echo "::error::verify-lock-content-sha.sh: ${LOCK_FILE} has no .pinned_commit_sha" >&2
  exit 1
fi

VERIFIED=0

while IFS='|' read -r path stored_hash; do
  # D3: no skip branch. Absent/empty/literal "MISSING" is an error, not a
  # grace pass — the vacuity path this script exists to close.
  if [ -z "$stored_hash" ] || [ "$stored_hash" = "null" ] || [ "$stored_hash" = "MISSING" ]; then
    echo "::error::verify-lock-content-sha.sh: ${path} has no content_sha256 (absent/empty/MISSING) — cannot verify, refusing to skip" >&2
    exit 1
  fi

  TMPFILE=$(mktemp)
  if ! curl -sf "https://raw.githubusercontent.com/${UPSTREAM}/${PINNED}/${path}" -o "$TMPFILE"; then
    rm -f "$TMPFILE"
    echo "::error::verify-lock-content-sha.sh: failed to fetch ${path} at pinned SHA ${PINNED} — fail-closed (AC-SYNC-6, one behavior not a choice)" >&2
    exit 1
  fi

  ACTUAL=$(sha256sum "$TMPFILE" | awk '{print $1}')
  rm -f "$TMPFILE"

  if [ "$ACTUAL" != "$stored_hash" ]; then
    echo "::error::verify-lock-content-sha.sh: integrity mismatch on ${path} — stored content_sha256=${stored_hash} fetched=${ACTUAL}" >&2
    exit 1
  fi

  VERIFIED=$((VERIFIED + 1))
done < <(jq -r '.files[] | "\(.path)|\(.content_sha256 // "MISSING")"' "$LOCK_FILE")

# AC-SYNC-2: a positive execution count, not merely "the loop finished" —
# a run that skipped or failed every entry must never report success.
if [ "$VERIFIED" -eq 0 ]; then
  echo "::error::verify-lock-content-sha.sh: verified=0 — zero entries checked, refusing to report success" >&2
  exit 1
fi
if [ "$VERIFIED" -ne "$TOTAL" ]; then
  echo "::error::verify-lock-content-sha.sh: verified=${VERIFIED} but .files has ${TOTAL} entries — mismatch" >&2
  exit 1
fi

echo "verified=${VERIFIED}"
echo "verify-lock-content-sha.sh PASSED — ${VERIFIED}/${TOTAL} entries verified against pinned SHA ${PINNED}."
