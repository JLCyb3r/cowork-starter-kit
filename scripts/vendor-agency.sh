#!/usr/bin/env bash
# vendor-agency.sh — materialize the lock-pinned upstream library into vendored/agency-agents/.
#
# Fetches every cowork.lock.json files[] entry from msitarzewski/agency-agents at the
# pinned commit SHA, verifies its SHA-256 against content_sha256 (fail-closed), injects
# the ADR-024 6-field attribution block, and writes the result under vendored/agency-agents/.
# Also fetches and hash-verifies the upstream LICENSE.
#
# Run this after every /sync-agency lock bump — the vendored-integrity-check CI job fails
# any PR where vendored/ and cowork.lock.json disagree.
#
# Requirements: bash, curl, jq, sha256sum. Run from the repo root:
#   bash scripts/vendor-agency.sh

set -euo pipefail

LOCK="cowork.lock.json"
OUT_ROOT="vendored/agency-agents"
START_MARK="<!-- COWORK-AGENCY-ATTRIBUTION-START -->"
END_MARK="<!-- COWORK-AGENCY-ATTRIBUTION-END -->"

if [ ! -f "$LOCK" ]; then
  echo "ERROR: $LOCK not found — run from the repo root." >&2
  exit 1
fi

UPSTREAM=$(jq -r '.upstream' "$LOCK")
PINNED=$(jq -r '.pinned_commit_sha' "$LOCK")
LICENSE_SHA=$(jq -r '.license_file_sha256' "$LOCK")

echo "Upstream: ${UPSTREAM} @ ${PINNED}"

# --- LICENSE: fetch + verify (fail-closed) ---
TMP_LICENSE=$(mktemp)
trap 'rm -f "$TMP_LICENSE"' EXIT
curl -sf "https://raw.githubusercontent.com/${UPSTREAM}/${PINNED}/LICENSE" -o "$TMP_LICENSE"
ACTUAL_LICENSE_SHA=$(sha256sum "$TMP_LICENSE" | awk '{print $1}')
if [ "$ACTUAL_LICENSE_SHA" != "$LICENSE_SHA" ]; then
  echo "ERROR: LICENSE hash mismatch — lock=${LICENSE_SHA} fetched=${ACTUAL_LICENSE_SHA}" >&2
  exit 1
fi
mkdir -p "$OUT_ROOT"
cp "$TMP_LICENSE" "${OUT_ROOT}/LICENSE"
echo "LICENSE verified and vendored."

LICENSE_TEXT=$(cat "$TMP_LICENSE")

# --- Files: fetch + verify + inject attribution (fail-closed per file) ---
COUNT=0
TOTAL=$(jq '.files | length' "$LOCK")

while IFS='|' read -r path stored_hash; do
  if [ -z "$stored_hash" ] || [ "$stored_hash" = "null" ]; then
    echo "ERROR: ${path} has no content_sha256 in lock — refusing to vendor unverifiable content." >&2
    exit 1
  fi

  TMP_FILE=$(mktemp)
  ok=0
  for attempt in 1 2 3; do
    if curl -sf "https://raw.githubusercontent.com/${UPSTREAM}/${PINNED}/${path}" -o "$TMP_FILE"; then
      ok=1
      break
    fi
    echo "  retry ${attempt} for ${path}..." >&2
    sleep $((attempt * 2))
  done
  if [ "$ok" -ne 1 ]; then
    echo "ERROR: failed to fetch ${path} after 3 attempts." >&2
    rm -f "$TMP_FILE"
    exit 1
  fi

  ACTUAL=$(sha256sum "$TMP_FILE" | awk '{print $1}')
  if [ "$ACTUAL" != "$stored_hash" ]; then
    echo "ERROR: integrity mismatch on ${path} — lock=${stored_hash} fetched=${ACTUAL}" >&2
    rm -f "$TMP_FILE"
    exit 1
  fi

  DEST="${OUT_ROOT}/${path}"
  mkdir -p "$(dirname "$DEST")"

  # ADR-024 6-field attribution block, amended v2.19.16 (D1(c), docs/architecture.md ADR-024
  # amendment): the field is now `Content SHA-256: ${stored_hash}` (per-file) rather than a
  # global `Pinned commit: ${PINNED}` repeated in every file — so a file's header changes only
  # when ITS OWN content changes, not on every corpus-wide sync. `Full license:` now points at
  # the vendored, hash-verified LICENSE (checked above against license_file_sha256) rather than a
  # pin-scoped GitHub URL. The corpus-level pin is unchanged as the record of authority: it stays
  # in cowork.lock.json's pinned_commit_sha and THIRD-PARTY-NOTICES.md (format matches
  # quality.yml attribution-survives-render).
  {
    printf '%s\n' "$START_MARK"
    printf '%s\n' "<!--"
    printf '%s\n' "Agency Source — ${UPSTREAM}"
    printf '%s\n' "Source: https://github.com/${UPSTREAM}"
    printf '%s\n' "Upstream path: ${path}"
    printf '%s\n' "Content SHA-256: ${stored_hash}"
    printf '%s\n' "Lock file source: cowork.lock.json (cowork-starter-kit)"
    printf '%s\n' "Copyright (c) ${UPSTREAM} contributors"
    printf '\n%s\n\n' "$LICENSE_TEXT"
    printf '%s\n' "Full license: ${OUT_ROOT}/LICENSE"
    printf '%s\n' "Derivative work: this file has been adapted for use with cowork-starter-kit"
    printf '%s\n' "-->"
    printf '%s\n' "$END_MARK"
    printf '\n'
    cat "$TMP_FILE"
  } > "$DEST"
  rm -f "$TMP_FILE"

  # Round-trip check: stripping the block must reproduce the upstream hash exactly,
  # guaranteeing the vendored-integrity-check CI job passes for this file.
  ROUNDTRIP=$(sed "1,/^${END_MARK//\//\\/}\$/d" "$DEST" | sed '1{/^$/d}' | sha256sum | awk '{print $1}')
  if [ "$ROUNDTRIP" != "$stored_hash" ]; then
    echo "ERROR: round-trip strip mismatch on ${path} — vendored file would fail CI." >&2
    exit 1
  fi

  COUNT=$((COUNT + 1))
  echo "[${COUNT}/${TOTAL}] vendored: ${path}"
done < <(jq -r '.files[] | "\(.path)|\(.content_sha256 // "")"' "$LOCK")

echo "Done — ${COUNT}/${TOTAL} files vendored to ${OUT_ROOT}/ (all hash-verified)."
