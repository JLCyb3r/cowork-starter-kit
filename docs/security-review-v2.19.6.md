# Security Review — v2.19.6 "Publish What Shipped"

## Phase: 2
## Date: 2026-08-07T00:00:00Z
## Reviewer: @security (opus)
## Target: `claude-cowork-config` @ `release/v2.19.6-publish-what-shipped` / `6b58781`
## Status: AMEND

**Worktree discipline:** SKIPPED — `COUNCIL_EXPECTED_BASE_SHA` unset (fail-open per F6).
**Classification:** SECURITY-SENSITIVE (Tier B) — CONFIRMED independently, see §Classification.
**Guard Change Summary:** NOT REQUIRED (zero Tier A files). The CODEOWNERS deferral is upheld — see S10.

This review treats the cycle as a **release-integrity and supply-chain surface**, not a docs change:
it performs three irreversible `gh release create` calls against a **public** repository whose
`homepageUrl` is `/releases/latest`, days before an announcement. Nothing here rolls back cleanly.

All probes were **read-only**. No `gh release create`, `gh release edit`, tag write, or push was
executed. `AC-PUB-13`'s documentation-only status is honored.

---

## Findings Summary

| ID | Severity | Surface | Location | Description |
|----|----------|---------|----------|-------------|
| S1 | HIGH | release-integrity | `spec.md:6619-6622` | `AC-PUB-14`'s negative control uses `2.0.2`, whose **live** path is repair, not create. The control is GREEN only because `gh` is removed from `PATH`. Its stated claim is false with `gh` present. |
| S2 | HIGH | supply-chain | `design-v2.19.6.md:269-282`, `spec.md:6474-6495` | The four-assertion pre-flight verifies the **worktree** but never the **invoked producer**. `publish-release.sh` and `release-predicate.sh` are read from the operator's main checkout; nothing asserts they are the as-merged, uncommitted-clean code the spec requires. |
| S3 | HIGH | release-integrity | `publish-release.sh:80-90` vs `release-assets.yml:133` | The body post-condition completes **before** `softprops/action-gh-release` runs. Nothing re-verifies the body afterward. At `5fee6f9` the pre-upload populated-body precondition is **absent entirely**. |
| S4 | HIGH | release-integrity | `spec.md:6652-6657` | The Primary success metric is `/releases/latest`. **No AC asserts it.** Verified live that "Latest" tracks creation order, so ascending order is load-bearing but unasserted. |
| S5 | WARNING | schema | `semver-compare.sh:63-67` | Measured fail-**open**: an oversized integer component passes both regexes, `[ -gt ]` errors, and the comparator returns `1`/"false" — silently bucketed SKIP. Contradicts ADR-078 D1's load-bearing "fails closed" claim. |
| S6 | WARNING | configuration | `design-v2.19.6.md:366-371`, ADR-078 D7 | Evidence-seam containment holds for the **live gate**, but the script does not self-identify when running on injected evidence. The design applies "label a non-check" to the local-tag conjunct and not to the seam. |
| S7 | WARNING | permissions | `.github/CODEOWNERS`, `spec.md:6374-6378` | The deferral is correctly scoped to two paths, but this cycle adds **three** new uncovered release-critical paths. Deferring the old two while silently adding three shrinks coverage relative to logic. |
| S8 | WARNING | release-integrity | `spec.md:6428-6433` | The Scope-A stop condition halts on asset-poll failure, but a halted run leaves a **tag + Release already created**. The standing gate does not check assets, so it reports GREEN on a known-incomplete release. `v2.12.0` is live proof this persists. |
| S9 | WARNING | logging | `design-v2.19.6.md:315-320` | `AC-PUB-15`'s negative control (the RED window) is perishable evidence with no capture requirement. |
| S10 | INFO | permissions | `spec.md:6374-6378` | CODEOWNERS deferral **upheld**. Rows are inert (`require_code_owner_reviews=false`, verified live). Classification stays Tier B; no GCS. |
| S11 | INFO | configuration | ADR-078 D4 | `workflow_run` rejection **CONFIRMED** as correct, with a refinement to the stated reason. |
| S12 | INFO | external-api | `design-v2.19.6.md:315-330` | Injection through CHANGELOG content is structurally contained by the COMPARABLE filter — provided that filter precedes every command use. Recommend making that ordering a binding requirement rather than an emergent property. |
| S13 | INFO | schema | `publish-release.sh:43-51` | `awk -v ver="$VERSION"` interpolates the version into a regex without escaping `.`. Unexploitable today; noted for completeness. |

**Counts:** 0 CRITICAL · 4 HIGH · 5 WARNING · 4 INFO.

---

## Scope-Allow Re-Walk (B2, independent)

Independently re-walked the §D 20-file plan against `dev.md scope_allow.standard` plus the §E
`scope_allow_delta.add[]` block. Files 12-14 are Phase-1 artifacts already written; the remaining
Phase-4 write paths each match a delta entry, with the eleven fixture files covered by the
`^tests/fixtures/release-surface/` prefix.

**Scope-Allow Re-Walk: PASS (19/19 files verified).** Concurs with the orchestrator's
`VERIFY-RESULT: PASS` without relying on it. No file is absent from both sets.

---

## Classification (independent re-run)

`.github/workflows/release-surface.yml` (NEW) and `.github/workflows/quality.yml` (EDIT) are both in
the Phase-4 write set. `.github/workflows/` is a **direct, unconditional** Tier B match. No
`scripts/guards/`, no `.claude/settings.json`, no `docs/pipeline-policy.md`, no `.claude/agents/*.md`.

**CONFIRMED: SECURITY-SENSITIVE (Tier B), zero Tier A, no Guard Change Summary.** This matches
@architect's §F re-run; I reached it from the file list, not from the record.

**On the load-bearing CODEOWNERS deferral — my review does NOT require those rows to land this
cycle.** Verified live: `require_code_owner_reviews` is `false` and the repository has **zero**
rulesets, so every CODEOWNERS row in this repo is presently **inert**. Landing the rows would change
no enforcement while escalating the cycle to Tier A and mandating a GCS — cost with no security
benefit, and precisely the inert-rows trap v2.19.5 just corrected. **Deferral upheld. Tier B stands.**
S7 records the one condition attached to that: the deferred bundle's scope must grow with this
cycle's new files.

---

## The five items @architect referred for confirmation

### 1. The `--evidence-dir` seam — reasoning CONFIRMED for the live gate, with one gap (S6)

Assessed against **this** repo, verified live rather than assumed:

| Control | Live value |
|---|---|
| Rulesets | `[]` — none |
| `required_status_checks` | **absent** — zero required checks |
| `required_approving_review_count` | `0` |
| `require_code_owner_reviews` | `false` |
| `enforce_admins` | `true` |
| `allow_force_pushes` / `allow_deletions` | `false` |
| `quality.yml` triggers | `on: [push, pull_request]` — no paths filter, so CI **does** run on every PR |

A correction to the standing context in my tasking: CI **does** run on every PR here (`quality.yml`
has no paths filter). What is true is that **no check is required to merge** — CI is advisory. So the
merge gate is: open a PR, self-merge, zero approvals, zero checks.

**@architect's residual argument holds for the live gate.** Passing `--evidence-dir` in the live
invocation requires editing `release-surface.yml`; deleting the gate requires editing the same file.
Both need write+merge on `main`. The seam therefore confers **no privilege that editing the workflow
does not already confer**, and the `quality.yml` meta-check closes the in-workflow abuse specifically.
I independently confirm this rather than inherit it.

Two refinements, neither overturning the conclusion:

- The seam is not the weakest link in gate scope. The gate derives its scope from `CHANGELOG.md`, so
  **deleting a `## [x.y.z]` section silences the gate for that version** without touching the workflow
  at all, and `version-consistency-check` only inspects the top header. This is inherent to a
  content-derived scope, is the same privilege class, and I am **not** asking for it to be fixed —
  I raise it so the seam is not mistaken for the sharpest edge.
- **The real residual is evidence provenance, not privilege** (S6). Gate output will be pasted into
  the retro and cited as proof of State C. A run under `--evidence-dir` produces output that looks
  identical to a live run. The design already established the governing principle for exactly this
  shape — *"A check that cannot fail must be labelled as not-a-check, not quietly counted as a pass"*
  (`design-v2.19.6.md:354`, applied to the local-tag conjunct) — and then did not apply it to the
  seam. Applying it is cheap: see AMEND 6.

### 2. `workflow_run` rejection — CONFIRMED (S11)

Correct against actual GitHub semantics. A `workflow_run` workflow executes in the context of the
**default branch** with the repository's normal `GITHUB_TOKEN` and **access to secrets** — unlike a
fork `pull_request` run, which gets a read-only token and no secrets. This is the documented
privileged-workflow shape behind the `pull_request_target` / `workflow_run` escalation family.

One refinement: the hazard is not privilege *per se*, it is **privileged context that ingests
untrusted output from the triggering run** (artifacts, PR numbers, checked-out fork code). This design
would ingest nothing, so `workflow_run` would not have been exploitable here. The rejection is
therefore **conservative rather than strictly necessary** — but it is the right call, because the
non-ingesting property is an invariant nobody would be maintaining deliberately, and `push: main`
gives the same signal with none of it. Uphold the rejection; ADR-078 D4's wording is directionally
accurate and I would not weaken it.

### 3. `AC-PUB-14`'s negative control runs with `gh` removed from `PATH` — CONFIRMED as *written*, but the control is defective (S1)

**Written as specified:** `spec.md:6620-6622` — *"The control is executed with `gh` unavailable on
`PATH`"* — and restated at `design-v2.19.6.md:430`. Not merely intended. Confirmed.

The `PATH` removal also works mechanically. With the guard present, `publish-release.sh:62`'s
`gh release view` fails (127), the `if` takes the else branch, the guard fires, exit `1`. With the
guard regressed, control reaches `gh release create`, which is also absent → exit `127` under
`set -e`. A test asserting exit `1` distinguishes the two. The loud-failure intent is satisfied.

**But the chosen token makes the control prove something other than what the spec says it proves.**
Verified live:

```
$ gh release view v2.0.2 --json tagName,body,isDraft,createdAt
{"body":"","createdAt":"2026-05-07T07:34:31Z","isDraft":false,"tagName":"v2.0.2"}
$ git ls-remote --tags origin refs/tags/v2.0.2
4ffb2b26873dfdeb8fc159195368b5262d1c27b0	refs/tags/v2.0.2
```

`v2.0.2` has a tag **and** a Release with an **empty** body. With `gh` present,
`publish-release.sh 2.0.2` takes the **repair** branch at `:67-70` and fires a real
`gh release edit`. `AC-PUB-14` is create-path-only and does **not** apply there. So the spec's
sentence — *"`publish-release.sh 2.0.2` on `main` … aborts before any `gh` write"* — is **false**
whenever `gh` is on `PATH`. The control only reaches the create path because removing `gh` forces it
there.

This is the same defect the cycle itself diagnosed in `v2.19.1`'s stray dotted digit
(`spec.md:6268-6270`): **a check that passes for a reason unrelated to the property it tests.**
`design-v2.19.6.md:241-242` already knows this — *"that is luck, not containment"* — but `AC-PUB-14`,
which is what @dev implements and @qa verifies, carries no such caveat.

**A live create-path token exists and should be used instead.** Verified: `## [1.1.1]` at
`CHANGELOG.md:991` and `## [1.0.0]` at `CHANGELOG.md:1038` both have dated sections, and
`git ls-remote --tags origin` returns **no** `refs/tags/v1.0.0` or `refs/tags/v1.1.1`. So
`publish-release.sh 1.0.0` on `main` today, with `gh` present and authenticated, reaches the
**create** branch and would tag `v1.0.0` at today's `main` on a public repo. That is the real live
hazard, `AC-PUB-14` genuinely contains it, and with `1.0.0` the control's `gh`-absent run and its
`gh`-present run take the **same** branch. See AMEND 1.

### 4. The `BASH_SOURCE`-relative predicate include — adversarial read (S2)

ADR-077 §D2's core argument is sound and I endorse it: **one definition cannot drift; two copies plus
a `cmp` gate can drift and merely be detected.** Given that producer/gate predicate disagreement *is*
this cycle's defect class one level up, one shared definition is the correct call.

The resolution mechanism is also correct for the stated hazard. In
`(cd /tmp/backfill-2194 && bash <MAIN_CHECKOUT>/scripts/publish-release.sh 2.19.4)`, `BASH_SOURCE[0]`
is the absolute path, so `${BASH_SOURCE[0]%/*}` resolves to `<MAIN_CHECKOUT>/scripts` regardless of
`cwd`. Fail-closed on absence. Correct.

**The adversarial finding is what that resolution implies, not whether it works.** It means the
**executable code** comes from the operator's main checkout **working tree**, while the **data**
(`VERSION`, `CHANGELOG.md`, `git rev-parse HEAD`) comes from the worktree. The pre-flight asserts the
worktree is clean (`git -C /tmp/backfill-2194 status --porcelain`) and asserts the predicate file is
merely `-r` **readable** — it never asserts anything about the *content or provenance* of the two
files that will actually execute.

Scope A's own binding requirement is *"using the **as-merged** v2.19.6 script (no ad-hoc local
edit)"* (`spec.md:6299-6300`). **Nothing enforces that sentence.** An operator with an uncommitted
edit to `publish-release.sh` or `release-predicate.sh` — including a half-finished fix from debugging
the previous publish — executes unreviewed code on the cycle's only irreversible path, and every
current assertion still passes. `-r` is also the weakest possible predicate-file check: it proves a
file exists, not that it is the reviewed one.

Two lesser notes, both fail-closed and neither blocking: `${BASH_SOURCE[0]%/*}` is a no-op when the
script is invoked with no slash (`cd scripts && bash publish-release.sh`), yielding a confusing
`publish-release.sh/release-predicate.sh` path — it fails closed, so it is a usability wart, not a
vulnerability. And `%/*` does not canonicalize symlinks; also fail-closed.

### 5. The fifth assertion — YES, one is needed. I name two, ranked (S2, S4)

The existing four all answer **"am I at the right ref?"** Nothing answers **"am I running the right
code?"** or **"am I writing to the right place?"** For an irreversible write to a public surface,
those are not lesser questions.

**Fifth (strongly recommended) — assert the producer's provenance.** Before the irreversible call:
the main checkout is at the expected merge commit, its working tree is clean for
`scripts/publish-release.sh` and `scripts/release-predicate.sh`, and both files are tracked at
`HEAD`. This converts `spec.md:6299`'s stated requirement into an enforced one, exactly as
`AC-PUB-14` did for `CONTRIBUTING.md:309`. It is the same move the design already made once, applied
to the one input it left unguarded.

**Sixth (recommended, cheaper) — assert the destination repository.** `gh` honors the `GH_REPO`
environment variable, which overrides repository resolution from the git remote. If `GH_REPO` is
exported in the operator's shell, all four current assertions pass and the release is created in a
**different repository**. Assert `gh repo view --json nameWithOwner` equals
`jmlozano1990/Cowork-Starter-Kit` (or `unset GH_REPO`) in the pre-flight. Low likelihood, trivial
cost, and it is the only assertion that guards the *destination* of an irreversible public write
rather than its content.

> **⚠ CORRECTION — 2026-08-07, post-Phase-5. The prescription in the paragraph immediately above is WRONG and must not be implemented as written.** It was implemented verbatim at Phase 4, and `@qa` found the result to be a **no-op against this very threat model**. Verified live and independently three times (@qa, the orchestrator, @dev):
>
> ```
> GH_REPO=cli/cli gh repo view --json nameWithOwner  →  jmlozano1990/Cowork-Starter-Kit
> GH_REPO=cli/cli gh release list --limit 1          →  v2.97.0   (cli/cli's own release)
> ```
>
> `gh repo view` **ignores** `GH_REPO` — it resolves from the git remote, and does so even with no remote present at all. `gh release create` / `edit` / `view` — the exact commands this assertion exists to protect — **honour** it. A guard built on `gh repo view` therefore reports "correct destination" at precisely the moment the write is being redirected: **it passes when the attack succeeds.**
>
> **What shipped instead** (`c33cb22`): an unconditional, `gh`-independent refusal — `[ -n "${GH_REPO:-}" ] || [ -n "${GH_HOST:-}" ]` → `exit 1` — placed **before the first `gh` call in the script**, since the idempotence check previously ran ahead of the guard and was itself unprotected. Coverage is stated rather than assumed: `GH_REPO` covered (confirmed live as the honoured vector); `GH_HOST` covered defensively (it fails closed in this single-remote checkout today, but that is a fact about this configuration, not a guarantee to lean on); `--repo`/`-R` grep-confirmed absent from every `gh` invocation in the script and explicitly **NOT** covered by an env-var guard — an operator's own aliased wrapper injecting `--repo` is a different threat model this check cannot see. No other documented `gh` environment variable affects repo/host resolution.
>
> **Why this correction is written into the review and not only into the code:** this document is what a future cycle will read to learn how the destination guard should work. Left uncorrected it would prescribe the no-op again. That is the same failure mode v2.19.6 exists to close — a record that reads as authoritative while being false — and it is the **eighth** green-for-the-wrong-reason instance in this cycle, this one authored by the security review itself.
>
> ---
>
> **⚠ CORRECTION TO THE CORRECTION — 2026-08-07, post-Phase-6.** The block above was written by the orchestrator at fix pass 1 and was itself **stale and under-scoped**. `@security` caught it at the Phase-6 audit (S-A4): it stops at `c33cb22`, and greps clean for `ninth`, `verify-release-surface`, `evidence_body`, and `refuse_if_gh_redirect`. **It therefore still teaches "guard the write" rather than "guard the hop" — the precise framing that produced the ninth instance.** Correcting a wrong prescription with an incomplete correction is the same defect one layer up, which is why this second block exists rather than a silent edit of the first.
>
> **What the first correction missed:**
>
> 1. **The guard belongs to the hop, not to one caller.** Fix pass 1 hardened `publish-release.sh` only. `verify-release-surface.sh`'s `evidence_body()` carried the identical unguarded `gh release view`, and with `GH_REPO=cli/cli` the standing gate reported **PASS** for `2.18.0` — because cli/cli's own auto-generated `Full Changelog: …/v2.17.0...v2.18.0` footer happens to contain the version string. A false **PASS** in the artifact this cycle ships as its permanent safeguard. Reproduced live. This was the **ninth** instance.
> 2. **What actually ships at `16f9c44`:** `refuse_if_gh_redirect_env_set()` lives in `scripts/release-predicate.sh` — **one definition, both callers** — and runs before the first `gh` call in each, including in `--evidence-dir` mode so the test seam cannot route around it.
> 3. **Per-call form matters and the sweep recorded it:** explicit-path `gh api repos/<owner>/<repo>` is **not** `GH_REPO`-redirectable but **is** `GH_HOST`-redirectable; `git ls-remote` reads neither variable. Calls that were already safe are named as such, so a future reader can tell "checked and clear" from "never looked at."
>
> **Still open, per `@security` S-A2 — do not read the guard as complete.** The enumeration covers `GH_REPO` and `GH_HOST`. It does **not** cover `--repo`/`-R` injected by an operator's own aliased wrapper (a different threat model, named rather than silently omitted), and `@security` proved two further surfaces the deny-list does not reach: `GH_CONFIG_DIR` (demonstrated effect fail-closed; false-PASS potential **unverified**), and **git's own config surface** — `gh` resolves its target from `remote.origin.url`, and `GIT_CONFIG_COUNT`/`KEY`/`VALUE` override that, which would redirect the `gh` calls **and** `evidence_tags()`'s `git ls-remote` together. That composed chain is **UNVERIFIED** — the harness refused every `GIT_CONFIG_*` probe.
>
> **The better remedy, verified by `@security` and not yet shipped:** assert positively rather than refusing a list. `gh api "repos/{owner}/{repo}" --jq .full_name` uses **the same implicit resolution as `gh release create/edit/view`**, so asserting it equals `jmlozano1990/Cowork-Starter-Kit` closes every vector at once — including the aliased-wrapper case the current comment excludes. A deny-list over a growing surface is the wrong shape; a positive assertion is the right one.

I would also fold in the `/releases/latest` post-condition (S4) — see AMEND 4.

---

## Also assessed

### Scope A's three-publish window and stop condition (S8)

The serialization and the halt-on-first-failure stop condition are correct and I endorse them.
**ADR-076 D3 is genuinely still unverified**, and I confirm @architect's claim by construction:

```
$ git log --diff-filter=A -- scripts/publish-release.sh
7c524d44fd0a233f45de2d662959cb787451dd50  v2.19.5 — Rung 1 …
```

`publish-release.sh` was **introduced at `7c524d4` and has never created a release**. Every existing
release was produced by a plain `git push` of a tag — consistent with `v2.19.1`/`v2.19.2` sharing an
identical `created_at` (a batched tag push). So the `v2.19.4` backfill really is D3's first live test.

*Unverified, offered as expectation only:* GitHub suppresses workflow triggering for events generated
by `GITHUB_TOKEN`, not for events generated by a user PAT/OAuth token. An operator-run
`gh release create` should therefore raise `push: tags`. I could not test this without publishing,
and I did not.

**The gap the stop condition does not close.** A halted run has **already created the tag and the
Release** — only the assets are missing. The standing gate checks tag + body and **never checks
assets**, so it reports that release GREEN. This is not hypothetical: `v2.12.0`'s `release-assets.yml`
run shows `completed / failure`, and `gh release view v2.12.0` returns **0 assets today**, weeks
later. An incomplete release can sit unnoticed indefinitely, and after this cycle the standing gate
would actively affirm it. The honest fix is a documented halt-state checklist (AMEND 8), not
extending the gate.

### The body-clobber window (S3) — the finding I would most want closed

Ordering, verified by line number:

- `publish-release.sh:81-90` — body post-condition (`BODY` non-empty, satisfies predicate) runs
  **immediately** after create.
- `publish-release.sh:102-129` — asset poll, up to 5 minutes.
- `release-assets.yml:104` — "Verify a populated Release already exists" precondition.
- `release-assets.yml:133-134` — `softprops/action-gh-release@b4309332…` (v3.0.0), invoked with only
  `files:` and `fail_on_unmatched_files:`.

The producer's body assertion completes **before** the third-party action touches the Release, and
**nothing anywhere re-asserts the body afterward**. The `:104` precondition runs *before* the upload,
so it does not cover the upload's own effect. And at `5fee6f9` — `v2.19.4`'s tag target — I read the
workflow directly: the `:104` precondition **does not exist**; the job goes Build → Verify archive →
Upload.

I **could not verify** whether `softprops/action-gh-release@v3.0.0` preserves an existing body when
updating a release with no `body`/`body_path` input. I did not read the pinned action's source, and I
am marking this **UNVERIFIED** rather than asserting either way. `spec.md:6414-6418` dismisses the
`v2.19.4`/`v2.19.5` workflow asymmetry as *"Benign — the Release is created populated first, so the
guarded condition cannot arise."* That reasoning addresses the action **creating** an empty-bodied
Release; it does not address the action **updating** an existing one.

The right response is not to research the action's semantics — it is to make the question moot with a
post-condition that is co-extensive with the operation, which is the design's own stated principle
(`spec.md:6556-6558`). See AMEND 3. Note that `AC-PUB-7`'s `sha256` window covers only the **five
curated bodies** (`2.18.0`–`2.19.3`), none of which is republished — so the three **new** bodies, the
only ones actually exposed to this window, are outside every existing control.

### `AC-PUB-15` — not circular, but its evidence is perishable (S9)

**No circularity.** The producer (`publish-release.sh`) and the verifier
(`verify-release-surface.sh`) are separate artifacts, and the verifier's evidence is **origin state**
(`git ls-remote`, `gh release view`) — an external fact neither artifact manufactures. State C is a
genuine observation, not a self-attestation. Both directions are demonstrated independently: State B
(exactly 2 failures) and the RED window prove RED; State C proves GREEN. A gate that could only go
green would be the concern, and this one demonstrably cannot be.

**The real weakness is evidential, not logical.** The RED window's proof is a `push: main` run that
fires automatically at the feature merge and is superseded the moment Scope A completes. If nobody
records it, the cycle's strongest evidence — *a genuine RED from the shipped artifact, on real data*
(`spec.md:6632-6633`) — evaporates. It is capturable (the run gets a durable ID); it is simply not
required to be captured. AMEND 7.

### N-1 parser-stage resolution — the exit-2 claim is GUARANTEED; a *third* bucket is not (S5)

**The `exit 2` unreachability claim holds, and it holds for a real reason.** `semver-compare.sh:43`
validates with `^([0-9]+)\.([0-9]+)\.([0-9]+)$`; the parser's COMPARABLE filter is
`^[0-9]+\.[0-9]+\.[0-9]+$`. These accept **exactly the same language**, so no token reaching the
comparator can fail its validity check. This is a genuine guarantee, not merely an assertion — I
confirmed it by comparing the two grammars directly rather than trusting the ADR.

**But the guarantee is coincidental and undefended.** Nothing in either file states that the two
regexes must remain identical, and no test compares them. `AC-PUB-11` proves the *consequence*
(comparator never invoked on a 4-component token) but not the *invariant*. Widening `parse_semver` —
to accept a `v` prefix, say — would silently break it. AMEND 5.

**And the "fails closed" property that the whole N-1 resolution rests on is FALSE for a reachable
input class.** Measured live:

```
$ bash scripts/semver-compare.sh ge 99999999999999999999.1.0 2.18.0
scripts/semver-compare.sh: line 63: [: 99999999999999999999: integer expected
scripts/semver-compare.sh: line 64: [: 99999999999999999999: integer expected
false
exit=1
```

`99999999999999999999.1.0` matches **both** regexes, so the parser classifies it COMPARABLE and hands
it to the comparator. `[ -gt ]` then fails with a bash error; because the caller disables `set -e`
around the call (`:83`), each failing `[` simply evaluates falsy and control falls through to
`return 1`. The comparator returns **"false" / exit 1**, which the gate maps to **SKIP/below-floor** —
a silent skip with error text on stderr that nothing inspects.

This is `CF-v2.19-B`'s defect one level down, now *inside* `semver-compare.sh`: an unchecked status
treated as benign. ADR-078 D1's claim that the comparator *"fails closed on exactly those inputs"* is
true for 4-component tokens and **false** for oversized 3-component ones.

Severity is WARNING, not higher: reaching it requires merging a CHANGELOG header with a ~20-digit
version component, and the outcome is a silent skip of a version that could never be published
anyway. I am **not** asking for `semver-compare.sh` to be modified — it is out of scope, reused
unchanged by design, and shared with the `self-upgrade` skill. AMEND 5 handles it in the parser.

Separately: `08.1.0` returns `true`/exit 0 (bash `test` reads it as decimal 8). Benign, noted.

### `/releases/latest` — the Primary metric has no acceptance criterion (S4)

`spec.md:6654-6656` states the Primary success metric as a visitor following `homepageUrl` seeing a
Release body that describes the version they clicked. Verified live that `homepageUrl` is
`https://github.com/jmlozano1990/Cowork-Starter-Kit/releases/latest` and that "Latest" tracks
**creation order**:

```
$ gh api repos/.../releases/latest --jq '{tag,created}'
{"created":"2026-07-27T09:23:54Z","tag":"v2.19.3"}   # the most recently created release
```

So Scope A's **ascending** order is load-bearing for the Primary metric — publishing descending would
leave `v2.19.4` as the public landing page. The spec mandates ascending (`spec.md:6300`) but justifies
it only via `publishedAt` ordering in `AC-PUB-2`'s positive control, and **no AC asserts the end
state**. `AC-PUB-1` State C asserts *0 failures* — every version has a tag and a conforming body —
which is fully satisfiable with the wrong release marked Latest. The cycle's headline outcome is
currently unverified by its own acceptance criteria. AMEND 4.

### OWASP pass, injection, and outside-contributor influence (S12, S13)

**Command injection through CHANGELOG content: structurally contained.** The parser captures
`^## \[([^]]+)\]` — nearly arbitrary text — but a token only reaches `semver-compare.sh`,
`git ls-remote --tags origin "refs/tags/v$V"`, or `gh release view "v$V"` **after** passing
`^[0-9]+\.[0-9]+\.[0-9]+$`, which admits only digits and dots. No metacharacter survives. Path
traversal into `--evidence-dir` (`DIR/<tag>.body`) is closed by the same filter — `..` cannot match.
`grep -F` on both predicate legs removes metacharacter concern from the version argument.

This is a genuinely good property, and it is **emergent from stage ordering rather than stated as a
requirement**. AMEND 9 makes it explicit so a future refactor that moves a print or a probe ahead of
classification cannot quietly open it.

**Workflow-command injection: low.** Skip reasons echo attacker-influenceable tokens into
`::notice::` lines. GitHub parses a workflow command only when a line *begins* with `::`, and
`[^]]+` cannot capture a newline, so a new command cannot be started. Recommend truncating and
stripping `::` from printed tokens as defense-in-depth (AMEND 9).

**Body content never reaches an argument.** `publish-release.sh` passes the body via
`--notes-file "$NOTES_FILE"`, not as an argument. Correct.

**Repair-path safety — a positive finding.** `publish-release.sh:65` only reaches
`gh release edit` when the existing body is empty or `"null"`. The repair path can therefore **only
ever overwrite an empty body**, which is non-destructive by construction. `AC-PUB-14`'s deliberate
exclusion of the repair path is **safe**, and the design's stated goal of preserving future
pre-floor repair costs nothing in risk. I confirm this rather than merely accept it.

**Outside-contributor reach.** A fork PR can modify `tests/fixtures/release-surface/**` and
`quality.yml`, but cannot merge, and the live gate (`release-surface.yml`) runs only on
`push: main` / `schedule` / `workflow_dispatch` — never on fork content. `permissions: contents: read`
at both levels is correct and sufficient for `gh release view`. `fetch-depth: 1` is correct given
`ls-remote` is authoritative. No fork-reachable path influences the live gate.

**Anchor predicate, independently verified.** All seven at/above-floor CHANGELOG headers use ASCII
hyphens (`## [2.19.5] - 2026-08-04` … `## [2.18.0] - 2026-07-22`), so the hardcoded `---` right
boundary is safe for the floor-scoped set. Census confirms the spec's 26 ASCII / 22 em-dash split;
`## [2.0.2] — 2026-05-07` (`CHANGELOG.md:772`) is em-dash and below the floor, which is a second
independent reason the floor stays at `2.18.0`. The `v2.18.0`/`v2.19.3` link-shape asymmetry claimed
at `design-v2.19.6.md:224-229` is real — I extracted `CHANGELOG.md#2180---2026-07-22` twice from
`v2.18.0` and `CHANGELOG.md#2193---2026-07-27` once from `v2.19.3`. The predicate matches both.

### OWASP Top 10 Assessment

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | **WARNING** | Zero required checks, zero approvals, inert CODEOWNERS — the merge gate is effectively "the maintainer". Pre-existing and owner-accepted; S7 keeps the deferred remediation honestly scoped. |
| A02 Cryptographic Failures | PASS | No secrets handled beyond `GITHUB_TOKEN` at `contents: read`. No credential is written or logged. |
| A03 Injection | PASS | Contained by the COMPARABLE filter + `grep -F` + `--notes-file`. S12/S13 are hardening, not live defects. |
| A04 Insecure Design | **AMEND** | S2 (producer provenance unasserted), S3 (post-condition not co-extensive with the operation), S4 (Primary metric unasserted). Each is a control-placement gap, not a wrong design. |
| A05 Security Misconfiguration | PASS | `contents: read` at both levels; `pull_request` correctly prohibited; `workflow_run` correctly rejected (S11). |
| A06 Vulnerable/Outdated Components | PASS | All actions SHA-pinned. `softprops/action-gh-release@b4309332…` pinned; its *behavior* is unverified (S3), not its integrity. |
| A07 Identification & Auth Failures | PASS | No new auth surface. |
| A08 Software & Data Integrity Failures | **AMEND** | The cycle's core surface. S1 (control proves the wrong thing), S3 (unguarded post-create mutation window), S8 (GREEN gate over a known-incomplete release). |
| A09 Logging & Monitoring Failures | **WARNING** | S9 (perishable RED-window evidence), S6 (injected-evidence runs indistinguishable from live ones). |
| A10 SSRF | N/A | No user-supplied URL is fetched. |

**LLM threat assessment (LLM01/02/06):** N/A — no AI feature, model call, or prompt surface is
introduced or modified by this cycle.

---

## AMEND — required before Phase 4 dispatch

Numbered and actionable. Items 1-4 are the ones I would not merge without.

1. **(S1) Re-point `AC-PUB-14`'s negative control to a live create-path token.** Replace `2.0.2` with
   `1.0.0` (or `1.1.1`) — verified to have a dated CHANGELOG section and **no** origin tag, so the
   `gh`-absent and `gh`-present runs take the same branch. Keep the `gh`-removed-from-`PATH`
   execution and the exit-`1`-not-`127` assertion; both are correct. Add one sentence to `AC-PUB-14`
   recording that `publish-release.sh 2.0.2` reaches the **repair** path with `gh` present and is
   therefore *not* an example of this guard firing — `design-v2.19.6.md:241` already knows this; the
   AC must say it too.

2. **(S2) Add a fifth pre-flight assertion — producer provenance.** Before the irreversible call,
   assert that the main checkout is at the expected merge commit and that
   `scripts/publish-release.sh` and `scripts/release-predicate.sh` are tracked and clean at `HEAD`
   (e.g. `git -C <MAIN_CHECKOUT> status --porcelain -- scripts/publish-release.sh
   scripts/release-predicate.sh` is empty). This enforces `spec.md:6299`'s "as-merged script (no
   ad-hoc local edit)", which currently has no enforcement at all. Strengthen the existing `-r`
   predicate check to ride along with it.

3. **(S3) Re-assert the body after the asset poll succeeds.** Add a final post-condition to
   `publish-release.sh` that re-runs `body_names_version` on a freshly fetched body **after** the
   asset poll returns, so the assertion becomes co-extensive with the operation. This makes the
   unverified `softprops/action-gh-release` update semantics irrelevant instead of load-bearing.
   Additionally extend `AC-PUB-7`'s `sha256` window to cover the **three new** bodies, which no
   current control touches. If this is declined, `AC-PUB-13` must record the `5fee6f9` case
   explicitly: `v2.19.4`'s tag target has **no** pre-upload populated-body precondition.

4. **(S4) Add an AC asserting the end state of the public surface.** After Scope A:
   `gh api repos/:owner/:repo/releases/latest --jq .tag_name` equals `v2.19.6`. State the reason —
   "Latest" tracks creation order, verified live — so the ascending requirement carries its
   justification rather than reading as a preference. This is the Primary success metric and it is
   currently unasserted.

5. **(S5) Defend the parser↔comparator grammar invariant in the parser, not in `semver-compare.sh`.**
   Do **not** modify the comparator. Instead: (a) add a bounded-length condition to the COMPARABLE
   filter (e.g. reject components longer than 9 digits, bucketing them SKIP with reason
   `non-x.y.z — component out of range`), and (b) extend `AC-PUB-11`'s fixture with an
   oversized-component header asserting SKIP and **zero** `integer expected` occurrences on stderr —
   the same greppable-proof shape the AC already uses. Add a comment at both regex sites naming the
   other as the paired definition.

6. **(S6) Make injected-evidence runs self-identifying.** When `--evidence-dir` or `--changelog` is
   in effect, print a `::warning::` banner and carry an explicit marker in the summary line (e.g.
   `release-surface: … [EVIDENCE-INJECTED — not a fact about this repository]`). This applies the
   design's own local-tag-conjunct principle (`design-v2.19.6.md:354`) to the seam, and makes pasted
   gate output self-labelling. Keep the `quality.yml` meta-check as-is; it is correct.

7. **(S9) Require capture of the RED-window evidence.** Add to `AC-PUB-15`: record the
   `release-surface.yml` run ID/URL from the feature-merge `push: main` run — the one reporting
   `2.19.6 MISSING-TAG` — in the retro **before** Scope A runs. Perishable evidence that is not
   captured is not evidence.

8. **(S8) Document the halt state.** `CONTRIBUTING.md`'s Scope-A ordering note must state that a
   halt after a failed asset poll leaves a **tag and Release already created and publicly visible**,
   that the standing gate will report that version GREEN because it does not check assets, and that
   the remedy is to investigate `release-assets.yml` — **not** the tag-deletion path at
   `publish-release.sh:124-125`. Cite `v2.12.0` (0 assets today after a failed run) as the live
   precedent.

9. **(S12/S13) State the injection containment as a requirement.** Add to `AC-PUB-11` or the script
   header: no parsed token may reach any command, path, or printed line before the COMPARABLE
   classification has been applied. Truncate and strip `::` from tokens printed in `::notice::` lines.

10. **(S7) Widen the deferred CODEOWNERS bundle now, while it is free.** The v2.19.7 deferral record
    names `publish-release.sh` / `release-assets.yml`. This cycle adds `scripts/release-predicate.sh`,
    `scripts/verify-release-surface.sh`, and `.github/workflows/release-surface.yml` — all
    release-critical, none covered. Amend the deferral text in `spec.md` and `docs/risk-register.md`
    to name all five paths. **This is a text change to a deferral record and adds no Tier A file to
    this cycle** — `.github/CODEOWNERS` itself is not modified, so the classification is unaffected.

11. **(S2, optional but cheap) Assert the destination repository.** ~~Add
    `gh repo view --json nameWithOwner` equality (or `unset GH_REPO`) to the pre-flight.~~ `gh` honors
    `GH_REPO`, which would redirect an irreversible public write while all other assertions pass.
    **⚠ CORRECTED 2026-08-07 post-Phase-5 — the struck prescription is a NO-OP.** `gh repo view`
    ignores `GH_REPO` (it resolves from the git remote); `gh release create/edit/view` honour it, so
    the check passes exactly when the redirect is active. Shipped instead at `c33cb22`: an
    unconditional, `gh`-independent refusal on `GH_REPO` **or** `GH_HOST` being set, placed before the
    first `gh` call. **Do not implement the struck form.** Full account at the §S2 correction block
    above (line ~220).

---

## Summary

This is a strong design. The central architectural calls are correct and I confirm each of them
independently rather than inheriting them: the misdiagnosis of `CF-v2.19.5-F` is real and the
destructive "widen the repair branch" fix was rightly rejected; one shared predicate beats two copies
plus a `cmp` gate; parser-stage classification is the only one of the three N-1 candidates that
leaves `semver-compare.sh`'s guarantee intact; `workflow_run` is correctly rejected; the
`--evidence-dir` seam genuinely confers no privilege that editing the workflow does not; and
`AC-PUB-14` is the right control in the right place, because the hazard really is in the creator and
not the detector. The repair path is safer than the design claims — it can only overwrite an empty
body — which makes `AC-PUB-14`'s create-path-only scoping free rather than a trade.

**No finding is CRITICAL and nothing here warrants BLOCK.** The four HIGH findings share one shape:
each is a **control-placement gap on the irreversible path**, not a wrong decision. The design
asserts the *ref* four times and never asserts the *code being run* (S2) or the *destination*
(AMEND 11); it asserts the body *before* the third-party action that may mutate it rather than after
(S3); it names a Primary success metric that no acceptance criterion tests (S4); and its one guard
on the wrong-version hazard is demonstrated with a token whose live behavior takes a different branch
(S1). All four are cheap to close at Phase 2 and expensive to discover at Phase 6, after three
irreversible public writes.

The single most valuable line in the design is `design-v2.19.6.md:354` — *"A check that cannot fail
must be labelled as not-a-check, not quietly counted as a pass."* Three of my findings (S1, S6, S9)
are that principle applied to places the design did not apply it to itself.

**Two claims I could not verify and am marking as such rather than asserting:** whether
`softprops/action-gh-release@v3.0.0` preserves an existing Release body when updating with no `body`
input (S3 — I did not read the pinned action's source), and whether an API-created tag raises
`push: tags` in this repository (ADR-076 D3 — untestable without publishing; I confirmed only that
`publish-release.sh` has never created a release, so the assumption is genuinely still open).

**On the question that gates the classification:** the CODEOWNERS rows **do not** need to land this
cycle. They would be inert against `require_code_owner_reviews=false` and zero rulesets, both
verified live. The deferral is upheld, the cycle remains **Tier B**, and **no Guard Change Summary
is required**. AMEND 10 is a text-only widening of the deferral record and does not change that.

## Verdict: AMEND
