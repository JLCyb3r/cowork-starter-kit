#!/usr/bin/env bash
# publish-release.sh — pre-publish a populated GitHub Release before the tag exists.
#
# ADR-076 D1. release-assets.yml triggers on `push: tags` and GitHub runs a
# tag-push-triggered workflow AT THE CODE STATE OF THE PUSHED REF — it
# cannot retroactively apply a fix that has not yet been merged to whatever
# commit the tag happens to point at. Tagging chronologically after a fix
# lands on main gives ZERO protection under that constraint if the tag
# targets an older commit (see AC-REL-BODY-3).
#
# This script sidesteps the whole problem: it creates the tag AND a
# populated Release in a single `gh release create` API call. There is
# therefore no interval in which the tag exists without its Release, and no
# window for release-assets.yml to reach the empty-body create path
# (CF-v2.19.3-A, reported closed once at v2.19.2 without touching this
# producer, and regenerated on the very next tag push).
#
# Usage: scripts/publish-release.sh [<version>]
#   <version>  x.y.z form (no leading "v"). Defaults to the VERSION file's
#              current content.
#
# Requires: gh (authenticated with repo + release scopes), git, jq. Run from
# the repo root at the commit you want the tag to point at.

set -euo pipefail

VERSION="${1:-$(tr -d '[:space:]' < VERSION)}"
TAG="v${VERSION}"
TARGET_SHA="$(git rev-parse HEAD)"

if ! printf '%s' "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "ERROR: '${VERSION}' is not a x.y.z semver — refusing to publish." >&2
  exit 1
fi

# --- 1. Extract the dated CHANGELOG section. Fails if missing or empty. ---
NOTES_FILE="$(mktemp)"
trap 'rm -f "$NOTES_FILE"' EXIT

# The section runs from its own "## [x.y.z] - date" header (included, so the
# post-condition assertion at step 4 has a version string to match against)
# to the next "## [" header (or EOF).
awk -v ver="$VERSION" '
  BEGIN { insection = 0 }
  /^## \[/ {
    if (insection) exit
    if ($0 ~ "^## \\[" ver "\\]") { insection = 1; print; next }
    next
  }
  insection { print }
' CHANGELOG.md > "$NOTES_FILE"

if [ ! -s "$NOTES_FILE" ] || ! grep -q '[^[:space:]]' "$NOTES_FILE"; then
  echo "ERROR: CHANGELOG.md has no non-empty '## [${VERSION}]' section — refusing to publish with an empty body." >&2
  exit 1
fi

echo "Extracted CHANGELOG section for ${VERSION} ($(wc -l < "$NOTES_FILE" | tr -d ' ') lines)."

# --- 2. Idempotence: refuse (no-op) if a populated Release already exists;
#        repair an existing empty-bodied one instead of duplicating. ---
if gh release view "$TAG" --json body -q '.body' > /tmp/publish-release-existing-body.txt 2>/dev/null; then
  EXISTING_BODY="$(cat /tmp/publish-release-existing-body.txt)"
  rm -f /tmp/publish-release-existing-body.txt
  if [ -n "$EXISTING_BODY" ] && [ "$EXISTING_BODY" != "null" ]; then
    echo "Release ${TAG} already exists with a non-empty body — skipping publish (idempotent), still verifying post-conditions."
  else
    echo "Release ${TAG} exists with an empty body — repairing via 'gh release edit'."
    gh release edit "$TAG" --notes-file "$NOTES_FILE"
  fi
else
  # --- 3. Create the tag AND the populated Release in one call. ---
  echo "Creating ${TAG} at ${TARGET_SHA} with a populated body..."
  gh release create "$TAG" \
    --target "$TARGET_SHA" \
    --title "${TAG}" \
    --notes-file "$NOTES_FILE"
fi

# --- 4. Post-condition assertions — asserted, never assumed. ---
BODY="$(gh release view "$TAG" --json body -q '.body')"
if [ -z "$BODY" ]; then
  echo "ERROR: post-condition failed — Release ${TAG} has an empty body after publish." >&2
  exit 1
fi
if ! printf '%s' "$BODY" | grep -qF "$VERSION"; then
  echo "ERROR: post-condition failed — Release ${TAG} body does not contain the version string '${VERSION}'." >&2
  exit 1
fi
echo "Post-condition (body): PASS — non-empty, contains '${VERSION}'."

# Poll for the asset-upload workflow (release-assets.yml, triggered by the
# tag push this script just performed via `gh release create`).
#
# ADR-076 D3 [ESTIMATED, not verified]: whether a tag created through the
# Releases API raises the `push` event release-assets.yml listens on —
# every historical run in this repo was a plain `git push`. This script
# asserts rather than assumes: a missing-assets result is a loud, named
# failure with a documented, concrete remedy, not a silent gap (S8 —
# "re-push the tag" is a no-op once the tag exists, so the remedy below
# names the actual delete-and-recreate steps instead).
echo "Polling for release assets (release-assets.yml, up to 5 minutes)..."
ATTEMPTS=0
MAX_ATTEMPTS=30
ASSET_COUNT=0
while [ "$ATTEMPTS" -lt "$MAX_ATTEMPTS" ]; do
  ASSET_COUNT="$(gh release view "$TAG" --json assets -q '.assets | length')"
  if [ "$ASSET_COUNT" -eq 2 ]; then
    break
  fi
  ATTEMPTS=$((ATTEMPTS + 1))
  sleep 10
done

if [ "$ASSET_COUNT" -ne 2 ]; then
  echo "ERROR: post-condition failed — Release ${TAG} has ${ASSET_COUNT} asset(s) attached, expected exactly 2." >&2
  echo "" >&2
  echo "REMEDY (S8 — the tag already exists, so pushing it again is a no-op):" >&2
  echo "  1. Check whether release-assets.yml ran at all:" >&2
  echo "       gh run list --workflow=release-assets.yml --branch=${TAG}" >&2
  echo "  2. If it never triggered: a tag created via the Releases API may not raise" >&2
  echo "     the 'push: tags' event this script's tag-creation relies on (ADR-076 D3," >&2
  echo "     unverified). Delete and re-push the tag as a REAL git push to force it:" >&2
  echo "       git push --delete origin ${TAG} && git tag -d ${TAG}" >&2
  echo "       git tag ${TAG} ${TARGET_SHA} && git push origin ${TAG}" >&2
  echo "  3. If it ran and failed: inspect the run (gh run view <id> --log-failed)" >&2
  echo "     and re-trigger with the same delete-and-recreate steps above." >&2
  exit 1
fi

echo "Post-condition (assets): PASS — 2 archives attached."
echo "Release ${TAG} published successfully."
