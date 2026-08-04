# lock-entry.jq — single source of the cowork.lock.json files[] entry shape (ADR-075 D4).
#
# Invoked as:
#   jq -nc \
#     --arg path "$FILE_PATH" \
#     --arg sha256 "$FILE_SHA256" \
#     --arg spdx "MIT" \
#     --argjson requires_review "$FILE_REQUIRES_REVIEW" \
#     --arg content_sha256 "$FILE_SHA256" \
#     -f .github/jq/lock-entry.jq
#
# content_sha256 is sourced from the SAME $FILE_SHA256 variable that
# populates sha256 — one compute, two fields, structurally incapable of
# divergence (D4). The sha256/content_sha256 redundancy is a real finding,
# tracked as CF-v2.19.5-A and deliberately not collapsed this cycle (a
# $schema_version bump AC-SYNC-5 forbids).
#
# Invoked from both sync-agency.yml's advance-loop accumulator and
# quality.yml's sync-verify-ratchet Leg 3 — the ratchet exercises the real
# writer, not a hand-written imitation of it. One source, one behavior
# (the same anti-copy-drift argument that governs scripts/verify-lock-content-sha.sh).

{
  path: $path,
  sha256: $sha256,
  spdx: $spdx,
  requires_review: $requires_review,
  content_sha256: $content_sha256
}
