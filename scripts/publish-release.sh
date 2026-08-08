#!/usr/bin/env bash
# publish-release.sh — pre-publish a populated GitHub Release before the tag exists, AND
# attach both release archives itself on every branch (ADR-079, v2.19.7 Scope A1).
#
# ADR-076 D1 (unchanged rationale). release-assets.yml triggers on `push: tags` and
# GitHub runs a tag-push-triggered workflow AT THE CODE STATE OF THE PUSHED REF — it
# cannot retroactively apply a fix that has not yet been merged to whatever commit the
# tag happens to point at. Tagging chronologically after a fix lands on main gives ZERO
# protection under that constraint if the tag targets an older commit (see AC-REL-BODY-3).
#
# ADR-079 (v2.19.7): `softprops/action-gh-release` took its CREATE path when no Release
# existed and its UPDATE path when one did (CF-v2.19.6-A, proven by direct comparison of
# two real run logs). Pre-creating the Release — the entire point of ADR-076 D1 — forced
# the update path, which failed with a 403. This script now attaches the assets ITSELF,
# on all three branches (idempotent-skip, repair, create), so there is no second actor
# whose create/update-path split can disagree with this one. release-assets.yml is
# narrowed to verification-only (downloads the published asset, re-asserts DROP/KEEP).
#
# Usage: scripts/publish-release.sh [<version>]
#   <version>  x.y.z form (no leading "v"). Defaults to the VERSION file's
#              current content.
#
# Env:
#   PUBLISH_BACKFILL_CAVEAT=1   Opt-in. Prepends a fixed caveat block (docs/spec.md
#                                AC-A2-5/-6/-7) to the release notes, naming the v2.19.7
#                                B1/B2 permanent removals and pointing at vendored/
#                                README.md's disclosure section. Used ONLY for the two
#                                v2.19.7 Scope A2 backfill publishes (v2.19.5, v2.19.6) —
#                                never for v2.19.7 itself. Refuses if the target Release
#                                already exists (see AC-A2-7 note below).
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
PROVENANCE_STATUS="$(git -C "$MAIN_REPO_ROOT" status --porcelain -- scripts/publish-release.sh scripts/release-predicate.sh scripts/release-archive-assert.sh scripts/verify-vendored-orphans.sh 2>&1)" || {
  echo "ERROR: producer-provenance check failed — '${MAIN_REPO_ROOT}' is not a readable git checkout." >&2
  exit 1
}
if [ -n "$PROVENANCE_STATUS" ]; then
  echo "ERROR: refusing to publish — one or more of this script's own control files" >&2
  echo "  (publish-release.sh, release-predicate.sh, release-archive-assert.sh," >&2
  echo "  verify-vendored-orphans.sh) have uncommitted or untracked changes in" >&2
  echo "  ${MAIN_REPO_ROOT}:" >&2
  echo "$PROVENANCE_STATUS" >&2
  echo "  These files must be tracked and clean (no ad-hoc local edit) at whatever" >&2
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

# --- [AC-A1-0] Shared preconditions, gating every ASSET WRITE (create-with-assets or
#     upload --clobber) on EVERY branch. Body-only edits on the pre-floor repair path are
#     the one retained exemption (ADR-079 decision 1a) — see the repair branch below.
#
#     (a) VERSION AT THE COMMIT OBJECT, never the working tree. `git show
#         "$TARGET_SHA":VERSION` — not `< VERSION` (the working-tree file) — so a dirty or
#         stale working tree cannot pass this check by accident.
#     (b) Where a Release already exists for the tag, its tag commit equals $TARGET_SHA.
#         Resolved via `gh api repos/{repo}/commits/{tag}`, which returns the underlying
#         COMMIT sha for both lightweight and annotated tags (unlike `git rev-parse`
#         against an annotated tag, which returns the tag OBJECT's sha).
#
#     Concrete path this closes, no malice required: running `publish-release.sh 2.19.5`
#     from a checkout whose HEAD is v2.19.7 used to reach the idempotent-skip branch
#     UNGUARDED and would replace v2.19.5's public assets with v2.19.7 content. Both (a)
#     and (b) below must pass before that replacement can happen.
assert_version_at_target() {
  local requested_version="$1" target_sha="$2"
  local version_at_target
  version_at_target="$(git show "${target_sha}:VERSION" 2>/dev/null | tr -d '[:space:]')" || {
    echo "ERROR: refusing to write release assets — could not read VERSION at commit ${target_sha}." >&2
    return 1
  }
  if [ "$version_at_target" != "$requested_version" ]; then
    echo "ERROR: refusing to write release assets — VERSION at commit ${target_sha} is '${version_at_target}'," >&2
    echo "  requested '${requested_version}'. Asset upload is gated on the checked-out commit's OWN" >&2
    echo "  VERSION matching the tag being published (AC-A1-0) — checkout the exact commit you" >&2
    echo "  intend to tag before re-running." >&2
    return 1
  fi
  return 0
}

assert_tag_commit_matches() {
  local tag="$1" target_sha="$2"
  local existing_tag_commit="" gh_stderr rc
  # [S19 — Phase 6 @security] `gh api repos/{repo}/commits/{tag}` returns exit 1 for BOTH
  # "the tag does not exist yet" (a real HTTP 422, "No commit found for SHA: <tag>" —
  # verified live against this repo) AND for a transient failure (network, auth,
  # rate-limit). Those are NOT the same outcome: the former is legitimately vacuous (no
  # existing tag to conflict with — proceed); the latter must be fatal, never a silent
  # empty default, or this precondition degrades into exactly the `|| <empty default>`
  # shape verify-lock-removals.sh's own header names and forbids for the identical
  # reason, 170 lines away in the same cycle. Distinguish by inspecting stderr for the
  # specific "HTTP 422" this repo's API genuinely returns for a not-yet-existing tag —
  # anything else (no HTTP status at all, a different status, a timeout) is fatal.
  gh_stderr="$(mktemp)"
  existing_tag_commit="$(gh api "repos/${EXPECTED_REPO}/commits/${tag}" --jq '.sha' 2>"$gh_stderr")"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    if grep -q 'HTTP 422' "$gh_stderr"; then
      existing_tag_commit=""   # vacuous: tag genuinely does not exist yet — proceed
    else
      echo "ERROR: refusing to write release assets for ${tag} — could not determine whether an" >&2
      echo "  existing tag conflicts with this checkout. 'gh api repos/${EXPECTED_REPO}/commits/${tag}'" >&2
      echo "  failed for a reason other than 'tag does not exist' (no HTTP 422 in its output), so this" >&2
      echo "  is treated as a hard failure, not a silent vacuous pass (S19). Raw gh output:" >&2
      sed 's/^/    /' "$gh_stderr" >&2
      rm -f "$gh_stderr"
      return 1
    fi
  fi
  rm -f "$gh_stderr"
  if [ -n "$existing_tag_commit" ] && [ "$existing_tag_commit" != "$target_sha" ]; then
    echo "ERROR: refusing to write release assets for ${tag} — the EXISTING tag points at commit" >&2
    echo "  ${existing_tag_commit}, but this checkout is at ${target_sha}. Uploading assets built" >&2
    echo "  from a different commit than the published tag would silently replace that Release's" >&2
    echo "  binaries with content from the wrong tree-ish (AC-A1-0)." >&2
    return 1
  fi
  return 0
}

# --- 1. Extract the dated CHANGELOG section. Fails if missing or empty. ---
NOTES_FILE="$(mktemp)"
EXISTING_BODY_FILE="$(mktemp)"
ARCHIVE_DIR="$(mktemp -d)"
trap 'rm -f "$NOTES_FILE" "$EXISTING_BODY_FILE"; rm -rf "$ARCHIVE_DIR"' EXIT

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

# --- 1a. Append a "Full changelog" link section (Scope D / docs/spec.md AC-D1-1).
#     templates/public-artifact/release-body.md already carries a "## Full changelog"
#     section for hand-CURATED bodies; this makes the SCRIPT-GENERATED (raw CHANGELOG
#     excerpt) bodies carry it too, for every release this script creates or repairs
#     going forward. `release-predicate.sh`'s body_names_version() is satisfied by a bare
#     dotted-version match alone, which is exactly why a body can pass that check while
#     still failing the storefront-truth strategy this AC closes.
#
#     Anchor derived from the header line using GitHub's own heading-slug algorithm
#     (lowercase; strip everything except [a-z0-9 _-]; spaces -> hyphens) — verified
#     against this repo's own documented example (release-predicate.sh's comment):
#     "## [2.18.0] - 2026-07-22" -> "2180---2026-07-22". ---
HEADER_LINE="$(head -1 "$NOTES_FILE")"
ANCHOR="$(printf '%s' "$HEADER_LINE" | sed 's/^## //' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 _-]//g' | tr ' ' '-')"
{
  echo ""
  echo "## Full changelog"
  echo ""
  echo "[CHANGELOG.md#${ANCHOR}](CHANGELOG.md#${ANCHOR})"
} >> "$NOTES_FILE"
echo "Appended Full-changelog link section (anchor: ${ANCHOR})."

# --- 1b. Backfill caveat (A2 — docs/spec.md AC-A2-5/-6/-7). Opt-in via
#     PUBLISH_BACKFILL_CAVEAT=1, used ONLY for the two backfilled v2.19.7 Scope-A2
#     releases (v2.19.5, v2.19.6) — never for v2.19.7 itself. Prepended HERE, before the
#     branch dispatch below, so it can only ever reach a Release via `gh release create`
#     (never a later `gh release edit`) — AC-A2-7 REQUIRES this and this script REFUSES
#     rather than risk it landing any other way: if the flag is set and a Release for
#     this tag already exists, that is a repair/idempotent-skip situation, not a fresh
#     backfill, and the caveat has already either landed or been deliberately omitted at
#     the original create — this script will not retroactively add or skip it. ---
if [ "${PUBLISH_BACKFILL_CAVEAT:-0}" = "1" ]; then
  if gh release view "$TAG" >/dev/null 2>&1; then
    echo "ERROR: PUBLISH_BACKFILL_CAVEAT=1 but Release ${TAG} already exists." >&2
    echo "  The backfill caveat is only ever applied at 'gh release create' time (AC-A2-7) —" >&2
    echo "  never via a later 'gh release edit'. Refusing rather than risk landing it the" >&2
    echo "  wrong way, or silently skipping it, on an existing Release." >&2
    exit 1
  fi
  CAVEAT_TMP="$(mktemp)"
  cat > "$CAVEAT_TMP" <<'CAVEAT_EOF'
> **Backfilled release — published as part of v2.19.7.** This tag is being published
> retroactively to repair the release surface (`/releases/latest` was resolving to an
> older, incomplete release with 0 assets). Two things are true of the tree in this
> archive that are not true of the current `main`:
>
> - **Two vendored files present in this archive were later permanently removed:**
>   `vendored/agency-agents/marketing/marketing-carousel-growth-engine.md` (a CRITICAL
>   finding — an autonomous, zero-confirmation persona instructing itself to publish
>   generated content directly to public social accounts) and
>   `vendored/agency-agents/project-management/project-manager-senior.md` (leaked
>   third-party workspace content).
> - **Five additional HIGH-severity findings in the vendored third-party tree were not
>   yet disclosed** when this tree was current — see `vendored/README.md`'s disclosure
>   section (added in v2.19.7) for the current, complete accounting.
>
> For the current, corrected release, see the latest tag on
> [`jmlozano1990/Cowork-Starter-Kit`](https://github.com/jmlozano1990/Cowork-Starter-Kit/releases/latest).

CAVEAT_EOF
  cat "$CAVEAT_TMP" "$NOTES_FILE" > "${NOTES_FILE}.with-caveat"
  mv "${NOTES_FILE}.with-caveat" "$NOTES_FILE"
  rm -f "$CAVEAT_TMP"
  echo "Backfill caveat prepended to release notes (PUBLISH_BACKFILL_CAVEAT=1)."
fi

# --- 2. Vendored orphan check — BEFORE any archive is built (AC-C1-2, ADR-080 decision
#     2). vendored/ is not export-ignore'd, so an orphan (a vendored file with no
#     cowork.lock.json entry) would ship in every release ZIP. ---
"${SCRIPT_DIR}/verify-vendored-orphans.sh" || {
  echo "ERROR: refusing to build a release archive — vendored orphan check failed (see above)." >&2
  exit 1
}

# --- 3. Build both release archives from $TARGET_SHA (AC-A1-7). `git archive
#     <tree-ish>` reads a TREE OBJECT — dirty or untracked files in the working tree
#     cannot leak in regardless of what else is sitting in this checkout. Always
#     $TARGET_SHA, NEVER HEAD or the working tree (the archive is built before the tag
#     ref exists locally on the create path, so the tree-ish is not implied by the tag).
#     --prefix is preserved byte-for-byte: a changed top-level directory name across the
#     three v2.19.7 backfilled ZIPs would be user-visible. ---
PREFIX="cowork-starter-kit-${VERSION}/"
ZIP_FILE="${ARCHIVE_DIR}/cowork-starter-kit-${VERSION}.zip"
TARGZ_FILE="${ARCHIVE_DIR}/cowork-starter-kit-${VERSION}.tar.gz"
git archive --format=zip --prefix="$PREFIX" -o "$ZIP_FILE" "$TARGET_SHA"
git archive --format=tar.gz --prefix="$PREFIX" -o "$TARGZ_FILE" "$TARGET_SHA"
echo "Built release archives at ${TARGET_SHA} (prefix '${PREFIX}')."

# --- 4. Pre-upload DROP/KEEP assertion (AC-A1-2b(a), AC-A1-3). Runs against the EXACT
#     files about to be attached, with NO rebuild between this assertion and the upload
#     calls below — the assertion and the artifact cannot silently diverge. ---
"${SCRIPT_DIR}/release-archive-assert.sh" "$ZIP_FILE" "$PREFIX" || {
  echo "ERROR: refusing to publish — release-archive-assert.sh failed on ${ZIP_FILE}." >&2
  exit 1
}
"${SCRIPT_DIR}/release-archive-assert.sh" "$TARGZ_FILE" "$PREFIX" || {
  echo "ERROR: refusing to publish — release-archive-assert.sh failed on ${TARGZ_FILE}." >&2
  exit 1
}

# --- 5. Idempotence: refuse (no-op, but still attach assets) if a populated Release
#        already exists; repair an existing empty-bodied one instead of duplicating.
#
#     S-A6 fix (@security Phase 6, docs/security-audit-v2.19.6.md): this used to redirect
#     to a fixed, predictable /tmp path (`/tmp/publish-release-existing-body.txt`) — on the
#     one script in this repo that performs irreversible public writes. CWE-59/CWE-377: a
#     symlink pre-planted at that name causes `>` to truncate-and-write through to the link
#     target as the invoking user, and a redirect that merely FAILS (path exists, owned by
#     someone else) silently defeats this idempotence check rather than erroring loudly.
#     `NOTES_FILE` above already used `mktemp` — the inconsistency was the tell.
#     EXISTING_BODY_FILE is `mktemp`'d alongside it and cleaned by the same trap. ---
if gh release view "$TAG" --json body -q '.body' > "$EXISTING_BODY_FILE" 2>/dev/null; then
  EXISTING_BODY="$(cat "$EXISTING_BODY_FILE")"
  if [ -n "$EXISTING_BODY" ] && [ "$EXISTING_BODY" != "null" ]; then
    echo "Release ${TAG} already exists with a non-empty body — skipping body publish (idempotent)."
    # [AC-A1-1] Assets are asserted/attached even on the idempotent-skip branch — this is
    # the exact CF-v2.19.6-A blind spot A1 closes: a re-run after a partial upload used
    # to hit this branch, skip assets entirely, and fail unrecoverably at the old poll.
    assert_version_at_target "$VERSION" "$TARGET_SHA" || exit 1
    assert_tag_commit_matches "$TAG" "$TARGET_SHA" || exit 1
    gh release upload "$TAG" "$ZIP_FILE" "$TARGZ_FILE" --clobber
  else
    echo "Release ${TAG} exists with an empty body — repairing via 'gh release edit'."
    # --- [ADR-079 decision 1a] Retained pre-floor body-repair exemption: this text-only
    #     edit is NOT gated by assert_version_at_target/assert_tag_commit_matches — it
    #     was sound before A1 and remains sound now, because it is reversible and admits
    #     no binary write. The asset upload immediately below it is a DIFFERENT
    #     capability and IS gated — body repair and asset upload must not share one
    #     exemption (AC-A1-0 requirement 2). ---
    gh release edit "$TAG" --notes-file "$NOTES_FILE"
    assert_version_at_target "$VERSION" "$TARGET_SHA" || exit 1
    assert_tag_commit_matches "$TAG" "$TARGET_SHA" || exit 1
    gh release upload "$TAG" "$ZIP_FILE" "$TARGZ_FILE" --clobber
  fi
else
  # --- create-path-only version precondition, RETAINED (AC-PUB-14 / ADR-077 §D3) —
  #     asserted here in addition to assert_version_at_target below, because this is the
  #     one that also governs whether a NEW TAG gets created at all, not merely whether
  #     assets get attached. Asserted only on THIS branch — never on the repair or
  #     idempotent-skip branches above, so repairing a pre-floor empty-bodied Release
  #     (e.g. v2.0.2 — see the note below) remains possible for the BODY.
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
  # [AC-A1-0] Same precondition as the repair/idempotent-skip branches, gating the asset
  # attachment about to happen in the SAME `gh release create` call below.
  #
  # [S20 fix — Phase 6 @security] This branch is reached whenever `gh release view "$TAG"`
  # fails — which is true both when the TAG is absent and when the tag exists but has NO
  # Release yet (e.g. a plain `git push --tags` with no Release ever created for it). The
  # prior comment here assumed "no Release" meant "no tag" and skipped
  # assert_tag_commit_matches as vacuous; that assumption is false, and `gh` does not
  # protect against it either: `gh release create <tag>` against an EXISTING tag reuses
  # that tag and IGNORES `--target` — so if the existing tag points at commit Y while this
  # checkout (and its passing VERSION check) is at a different commit X, the archives get
  # built from X but attached to a Release created at the tag's real commit Y. Calling
  # assert_tag_commit_matches here closes that: it already returns 0 (vacuous pass) when
  # no tag exists at all, so this is a pure widening, not a behavior change on the
  # no-tag-no-Release path that is the common case.
  assert_version_at_target "$VERSION" "$TARGET_SHA" || exit 1
  assert_tag_commit_matches "$TAG" "$TARGET_SHA" || exit 1

  # --- 6. Create the tag, the populated Release, AND attach both archives — ALL in one
  #     atomic `gh release create` call (AC-A1-1). ---
  echo "Creating ${TAG} at ${TARGET_SHA} with a populated body and 2 assets..."
  gh release create "$TAG" \
    --target "$TARGET_SHA" \
    --title "${TAG}" \
    --notes-file "$NOTES_FILE" \
    "$ZIP_FILE" "$TARGZ_FILE"
fi

# --- 7. Post-condition assertions — asserted, never assumed. ---
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

# --- 8. Asset post-condition — synchronous, no polling. A1 removed the second actor
#     (release-assets.yml's softprops step) this script used to wait on; assets are
#     attached directly, above, so their presence can be asserted immediately rather than
#     polled for up to 5 minutes. This ALSO removes AC-A1-6's destructive printed remedy
#     (the old "delete + re-push the tag" block) — that block existed only to recover
#     from a stalled/failed poll of a workflow this script no longer depends on for
#     asset delivery, and following it would have destroyed a live public Release for a
#     never-triggered case (ADR-076 D3 is now verified: an API-created tag DOES raise
#     `push: tags`, so the case that remedy addressed never occurs). ---
ASSET_COUNT="$(gh release view "$TAG" --json assets -q '.assets | length')"
if [ "$ASSET_COUNT" -ne 2 ]; then
  echo "ERROR: post-condition failed — Release ${TAG} has ${ASSET_COUNT} asset(s) attached, expected exactly 2." >&2
  echo "  This script attaches assets itself and asserts immediately — a mismatch here means the" >&2
  echo "  upload/create call above did not complete as expected. Inspect:" >&2
  echo "    gh release view ${TAG} --json assets" >&2
  exit 1
fi
echo "Post-condition (assets): PASS — 2 archives attached."

# --- 9. Final post-condition: re-assert the body AFTER the asset upload (S3 —
#     docs/security-review-v2.19.6.md). The body post-condition above (step 7) can run
#     before the asset upload on the create branch (both happen in one call, so this is
#     mostly a defensive re-check there) but strictly after it on repair/idempotent-skip.
#     This is the ONLY body check that also covers the three releases newly published
#     this cycle (AC-PUB-7's sha256 window covers only the five pre-existing curated
#     bodies, none of which is republished by this script). ---
FINAL_BODY="$(gh release view "$TAG" --json body -q '.body')"
if [ -z "$FINAL_BODY" ] || ! body_names_version "$FINAL_BODY" "$VERSION"; then
  echo "ERROR: post-condition failed — Release ${TAG}'s body no longer names its version AFTER" >&2
  echo "  the asset upload. Inspect: gh release view ${TAG} --json body -q .body" >&2
  exit 1
fi
echo "Post-condition (body, post-upload): PASS — still names '${VERSION}' after asset upload."

echo "Release ${TAG} published successfully."
