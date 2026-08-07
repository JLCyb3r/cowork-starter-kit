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

# --- Load the shared release-body predicate (ADR-077 §D2). Resolved BASH_SOURCE-relative
#     to the INVOKED script, not to $PWD: Scope A (docs/spec.md AC-PUB-2/-3) runs this
#     script with `cwd` inside a detached worktree at a historical commit where this file
#     does not exist, so a cwd-relative source would silently fail to find it there and
#     succeed by accident everywhere else. Fail-closed, never a silent inline fallback.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./release-predicate.sh
# shellcheck disable=SC1091  # this repo's ShellCheck CI job (ludeeus/action-shellcheck)
# never passes -x/--external-sources, so `source=` above is honored only by a local
# `shellcheck -x` run — in CI the include can never be followed, and SC1091 would
# otherwise fire on that fact alone (info-level, but this job's default severity shows
# every level). House pattern for exactly this: quality.yml:442/:472 disable SC2034 the
# same way, for the same reason (a real, reasoned suppression, not a blanket ignore).
. "${SCRIPT_DIR}/release-predicate.sh" || {
  echo "ERROR: ${SCRIPT_DIR}/release-predicate.sh not found beside $0 — refusing to publish." >&2
  exit 1
}

# --- Producer provenance (S2 — docs/security-review-v2.19.6.md). Scope A invokes this
#     script with `cwd` inside a detached worktree while the EXECUTABLE code (this file
#     and release-predicate.sh) is read from the operator's main checkout via the
#     BASH_SOURCE resolution above. Every ref-facing assertion elsewhere in this
#     procedure verifies the COMMIT being tagged; none verified the CODE being run. This
#     narrows that gap: the two files about to execute must be tracked and clean at
#     whatever commit is currently checked out in the checkout they live in. `git status
#     --porcelain` reports an uncommitted edit AND an untracked file both as non-empty
#     output, so this one check covers both hazards.
#
#     S-A5 (@security Phase 6, docs/security-audit-v2.19.6.md): this proves "tracked and
#     clean," which is NOT the same claim as "as-merged" — a checkout sitting on a stale
#     feature branch, or an older `main`, passes this exact check just as cleanly as one on
#     the true HEAD the operator intends. The error message below is deliberately scoped to
#     what is actually enforced rather than the broader claim an earlier version of this
#     comment made. Neither this check nor `AC-PUB-2`'s pre-flight (which asserts the
#     DETACHED WORKTREE's ref, not this checkout's) currently assert MAIN_REPO_ROOT is at
#     the expected merge commit — recorded as an open gap, not silently strengthened here.
MAIN_REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROVENANCE_STATUS="$(git -C "$MAIN_REPO_ROOT" status --porcelain -- scripts/publish-release.sh scripts/release-predicate.sh 2>&1)" || {
  echo "ERROR: producer-provenance check failed — '${MAIN_REPO_ROOT}' is not a readable git checkout." >&2
  exit 1
}
if [ -n "$PROVENANCE_STATUS" ]; then
  echo "ERROR: refusing to publish — scripts/publish-release.sh and/or scripts/release-predicate.sh" >&2
  echo "  have uncommitted or untracked changes in ${MAIN_REPO_ROOT}:" >&2
  echo "$PROVENANCE_STATUS" >&2
  echo "  These two files must be tracked and clean (no ad-hoc local edit) at whatever" >&2
  echo "  commit is checked out in ${MAIN_REPO_ROOT}. This does NOT by itself confirm that" >&2
  echo "  commit is the expected merge commit — verify that separately (docs/spec.md" >&2
  echo "  Scope A / docs/security-audit-v2.19.6.md S-A5)." >&2
  exit 1
fi

# --- Destination-repo guard (BLOCKER fix — @qa Phase 5, docs/qa-report-v2.19.6.md §3;
#     shared implementation as of §9.5's follow-up — see scripts/release-predicate.sh's
#     refuse_if_gh_redirect_env_set() for the full rationale, the `gh help environment`
#     audit, and why this is now ONE definition rather than a second hand-copied check).
#
#     The PRIOR form of THIS script's own guard called `gh repo view --json nameWithOwner`
#     and compared it to EXPECTED_REPO — a no-op against its own threat model, since
#     `gh repo view` resolves from the git remote and IGNORES `GH_REPO` while the commands
#     it existed to protect (`gh release view/create/edit`) DO honor it. Verified live both
#     directions before this was replaced.
#
#     Needs no `gh` call itself (a pure environment-variable read), so it runs
#     UNCONDITIONALLY, HERE, before the first `gh` call anywhere in this script (the
#     idempotence check a few lines below) — a guard called only right before create/edit
#     would still leave that earlier read exposed to a redirected repo.
EXPECTED_REPO="jmlozano1990/Cowork-Starter-Kit"
refuse_if_gh_redirect_env_set "$EXPECTED_REPO" || exit 1

# --- Destination-repo POSITIVE assertion (@security Phase 6, S-A2, docs/security-audit-
#     v2.19.6.md — "the right remedy"). The refusal above is a deny-list over GH_REPO/
#     GH_HOST; it does not reach `gh`'s INHERITED resolution surface (git-config injection
#     via GIT_CONFIG_COUNT/KEY/VALUE, which could redirect `git ls-remote` too — mechanism
#     confirmed, composed chain unverified) or GH_CONFIG_DIR (confirmed to fail closed
#     today; false-PASS potential unverified), and it cannot see an operator's own aliased
#     wrapper that injects `--repo` onto every `gh` call. A deny-list is the wrong
#     instrument for a surface that can grow. This is the actual close: a POSITIVE
#     assertion via `gh api "repos/{owner}/{repo}"`, which resolves through the SAME
#     implicit path `gh release view/create/edit` use (confirmed live) — true by
#     construction against every vector above, including the aliased-`--repo` case (the
#     alias would apply to THIS call too, and the comparison would then fail). Costs one
#     authenticated API call, so it runs second, after the free env check above, not
#     instead of it.
assert_gh_destination_repo "$EXPECTED_REPO" || exit 1

VERSION="${1:-$(tr -d '[:space:]' < VERSION)}"
TAG="v${VERSION}"
TARGET_SHA="$(git rev-parse HEAD)"

if ! printf '%s' "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "ERROR: '${VERSION}' is not a x.y.z semver — refusing to publish." >&2
  exit 1
fi

# --- 1. Extract the dated CHANGELOG section. Fails if missing or empty. ---
NOTES_FILE="$(mktemp)"
EXISTING_BODY_FILE="$(mktemp)"
trap 'rm -f "$NOTES_FILE" "$EXISTING_BODY_FILE"' EXIT

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
#        repair an existing empty-bodied one instead of duplicating.
#
#     S-A6 fix (@security Phase 6, docs/security-audit-v2.19.6.md): this used to redirect
#     to a fixed, predictable /tmp path (`/tmp/publish-release-existing-body.txt`) — on the
#     one script in this repo that performs irreversible public writes. CWE-59/CWE-377: a
#     symlink pre-planted at that name causes `>` to truncate-and-write through to the link
#     target as the invoking user, and a redirect that merely FAILS (path exists, owned by
#     someone else) silently defeats this idempotence check rather than erroring loudly.
#     `NOTES_FILE` three lines above already used `mktemp` — the inconsistency was the
#     tell. EXISTING_BODY_FILE is `mktemp`'d alongside it and cleaned by the same trap. ---
if gh release view "$TAG" --json body -q '.body' > "$EXISTING_BODY_FILE" 2>/dev/null; then
  EXISTING_BODY="$(cat "$EXISTING_BODY_FILE")"
  if [ -n "$EXISTING_BODY" ] && [ "$EXISTING_BODY" != "null" ]; then
    echo "Release ${TAG} already exists with a non-empty body — skipping publish (idempotent), still verifying post-conditions."
  else
    echo "Release ${TAG} exists with an empty body — repairing via 'gh release edit'."
    gh release edit "$TAG" --notes-file "$NOTES_FILE"
  fi
else
  # --- create-path-only version precondition (AC-PUB-14 / ADR-077 §D3). Asserted only on
  #     THIS branch — never on the repair or idempotent-skip branches above, so repairing
  #     a pre-floor empty-bodied Release (e.g. v2.0.2 — see the note below) remains
  #     possible. CONTRIBUTING.md's written procedure already says "run on main at the
  #     commit you intend to tag"; this converts that sentence into an enforced one.
  #
  #     Security-review note (S1): the negative control for this guard is
  #     `publish-release.sh 1.0.0`, NOT `2.0.2`. `2.0.2` already has an origin tag and a
  #     live 0-byte Release (verified live), so with `gh` present it reaches the REPAIR
  #     branch above and never exercises this guard at all — a control built on it would
  #     be green for a reason unrelated to the property it tests, the exact defect class
  #     this cycle diagnosed in v2.19.1's stray dotted digit (docs/spec.md). `1.0.0` has a
  #     dated CHANGELOG section and NO origin tag (verified live), so it reaches this
  #     exact branch whether `gh` is present or absent from PATH.
  VERSION_AT_HEAD="$(tr -d '[:space:]' < VERSION)"
  if [ "$VERSION" != "$VERSION_AT_HEAD" ]; then
    echo "ERROR: refusing to CREATE tag v${VERSION} — VERSION at HEAD is '${VERSION_AT_HEAD}'." >&2
    echo "  publish-release.sh creates tags only at the commit whose VERSION matches the request" >&2
    echo "  (CONTRIBUTING.md pre-release checklist). To repair an EXISTING release's body, the tag" >&2
    echo "  must already exist — this guard does not apply on the repair path." >&2
    exit 1
  fi

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
if ! body_names_version "$BODY" "$VERSION"; then
  echo "ERROR: post-condition failed — Release ${TAG} body names neither the dotted form '${VERSION}'" >&2
  echo "  nor the house anchor form 'CHANGELOG.md#${VERSION//./}---' (ADR-077 §D2)." >&2
  echo "  A curated body is expected to carry the anchor form; a raw CHANGELOG excerpt carries the" >&2
  echo "  dotted form via its own header." >&2
  exit 1
fi
echo "Post-condition (body): PASS — non-empty, names '${VERSION}' (dotted or anchor form)."

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

# --- Final post-condition: re-assert the body AFTER the asset upload (S3 —
#     docs/security-review-v2.19.6.md). The body post-condition above (step 4) runs
#     immediately after create/repair, BEFORE release-assets.yml's
#     softprops/action-gh-release step runs (release-assets.yml:133). Nothing previously
#     re-checked the body after that third-party action touched the Release. Whether it
#     preserves an existing body when updating with no `body`/`body_path` input is
#     UNVERIFIED (S3) — this assertion makes that question moot by re-checking the actual
#     end state instead of trusting the action's undocumented update semantics. This is
#     the ONLY body check that also covers the three releases newly published this cycle
#     (AC-PUB-7's sha256 window covers only the five pre-existing curated bodies, none of
#     which is republished by this script).
FINAL_BODY="$(gh release view "$TAG" --json body -q '.body')"
if [ -z "$FINAL_BODY" ] || ! body_names_version "$FINAL_BODY" "$VERSION"; then
  echo "ERROR: post-condition failed — Release ${TAG}'s body no longer names its version AFTER" >&2
  echo "  the asset-upload workflow ran. The upload step may have overwritten it." >&2
  echo "  Inspect: gh release view ${TAG} --json body -q .body" >&2
  exit 1
fi
echo "Post-condition (body, post-upload): PASS — still names '${VERSION}' after asset upload."

echo "Release ${TAG} published successfully."
