# Security Audit — v2.19.7 "Finish the Storefront, Ship What We Read"

## Phase: 6 (Code Audit)
## Date: 2026-08-08
## Scope: `git diff main..bf2704f` — 6 commits, 31 files
## Status: PASS WITH WARNINGS — no CRITICAL, no BLOCKER

> Authored by `@security` and landed by the orchestrator. `@security` declined to write this file itself: its output contract permits `docs/security-review.md` and `docs/pipeline.md` only, and a coordinator instruction does not widen it. That refusal is correct and is recorded here rather than worked around.

---

## 1. Verdict

**PASS WITH WARNINGS.** Nothing here should stop the merge.

**S1 — the Phase-2 CRITICAL — is genuinely closed**, and it is the strongest implementation of a Phase-2 finding in this repo to date: the fix did not merely add a guard, it **split the two capabilities the old exemption had silently merged**.

---

## 2. Phase-2 findings, as built

Each verified by running the check, not by reading the AC.

| # | Built? | Evidence |
|---|---|---|
| **S1** | **CLOSED, correctly** | `publish-release.sh:150` `assert_version_at_target` reads `git show "${target_sha}:VERSION"` — the **commit object**, not the working tree. Called at `:325`, `:337`, `:368` — all three branches, before every asset write. The body-repair exemption is retained but **explicitly severed from asset upload** (`:330-335`). |
| **S2** | **CLOSED** | Ledger job: `fetch-depth: 0`, `--base "origin/${BASE_REF}"` passed via `env:` not inline `${{ }}`. `verify-lock-removals.sh:102-117` — four separate `git show` calls, each `if ! … ; then exit 1`. No `\|\| echo '{}'` anywhere; the header names the forbidden idiom explicitly. |
| **S3** | **CLOSED** | NC re-scoped; verified returns **1** today. |
| **S4** | **CLOSED** | Both `.zip` and `.tar.gz` asserted, at both call sites. |
| **S5** | **CLOSED** | No DROP-without-KEEP path exists; prefix is argument `$2`, never re-derived. |
| **S6** | **CLOSED** (residual S23) | `-type f ! -name LICENSE` in both places. |
| **S7** | **CLOSED** | Both ACs are real CI steps, **verified executing and passing** in run `31257755812`. |
| **S10** | **CLOSED, beyond what was asked** | `architecture.md:13345-13357` retracts "load-bearing" **by name**, states the live probe values, and records: *"the Phase-1 draft committed the exact overclaim it documents two sections below… Diagnosing a false-enforcement claim in someone else's text is not the same as not writing one."* |
| **S12** | **CLOSED** | `contents: read`; `softprops` step deleted. `AC-A1-2a` is now structural, not behavioural. |
| **S8/S9** | Adopted | Shrink check and MOVED classification present. |

Also verified live: **F1/F2** (allowlist full paths + basename patterns), **F3** (both `$GITHUB_OUTPUT` sites use random-delimiter heredocs; the `run:` sink converted to `env:`), **C2** (real `exit 1`), **E2** (`rc=2`, well-formed comparisons unaffected), **H-2** (14 corrupted headings per file, exactly as disclosed). No hardcoded secrets in the diff.

---

## 3. New findings — all five since remediated

| ID | Severity | Description | Status |
|----|----------|-------------|--------|
| S19 | WARNING | `assert_tag_commit_matches` failed **open** on any `gh api` error — the same `\|\| <empty default>` shape `verify-lock-removals.sh:30-35` forbids, **same cycle, 170 lines apart** | ✅ FIXED |
| S20 | WARNING | Create branch skipped part (b); `gh release create` against an existing tag with no Release **ignores `--target`** | ✅ FIXED |
| S21 | WARNING | `AC-COMPLIANCE-3` claimed verification by a CI check that **did not exist** | ✅ FIXED |
| S22 | WARNING | `release-archive-assert.sh` did not assert its own list cardinality — an emptied `DROP_PATHS` reports PASS having checked nothing | ✅ FIXED |
| S23 | WARNING | `-type f` excludes **symlinks**; invisible to the orphan check and shipped in the archive. Residual of S6's own wording | ✅ FIXED |
| S24 | INFO | MOVED matches the whole head hash set, not newly-added paths. Verified not live (zero duplicate `content_sha256`) | Accepted |
| S25 | INFO | Disclosure heading unit contradicted the intro | ✅ FIXED |
| S26 | INFO | `vendored-removal-ledger` has been **skipped on every CI run to date** — the PR is its first execution | Carried into the GCS |
| S27 | INFO | The idempotent-skip branch now performs a public write on every invocation; "idempotent" means *converges*, not *does nothing* | Accepted |

### Remediation notes

**S19** — the fix required a fact that had to be discovered, not assumed: GitHub's `/commits/{ref}` endpoint returns **HTTP 422** ("No commit found for SHA") for a nonexistent ref, **not 404**. Only that signature is treated as vacuous; every other failure is fatal. The decisive control was a *different* failure shape (nonexistent repo → HTTP 404) proven **fatal rather than swallowed**.

**S21** was closed by making the claim true (extending `claude-md-word-count-check` to cover the template) rather than by softening the wording — the stronger of the two available outcomes.

---

## 4. Audit of the deliberate RED

**The decision to document rather than code was correct.** Three reasons, each verified rather than accepted.

**(a) The false-positive reading holds.** Reproduced: the **core B5 invariant passes** — both real removals are correctly declared. The only failure is the shrink assertion, tripped by a repair that strictly *increased* protection.

**(b) Building a REPAIRED classification would have been worse.** A rule of the form *"a removed `blocked_files` path is acceptable if another entry shares its basename"* is a **general bypass**: rename any protected entry to a same-basename path and the shrink check goes quiet permanently. That trades a one-time red for a permanent hole, written under deadline, in the same cycle that introduced the control.

**(c) It self-clears — proven, not assumed.** Running the ledger with the post-merge allowlist as **both** base and head returns `PASS — removed=0 … blocked_files did not shrink`, exit 0. This is a **one-PR transitional red**, categorically different from a permanently-red gate.

`docs/risk-register.md` `v2.19.7-LEDGER-FP` documents it and — correctly — declines to file it as closed, because *the RED itself has not yet been observed by CI*. S26 confirms that caution is warranted.

---

## 5. OWASP assessment

| Category | Status |
|---|---|
| A01 Broken Access Control | PASS (S19/S20 residuals now fixed) |
| A02 Cryptographic Failures | PASS — `content_sha256` intact at 108 |
| A03 Injection | **PASS** — both `$GITHUB_OUTPUT` sites hardened; `run:` sink converted to `env:` |
| A04 Insecure Design | PASS (S22/S23 degenerate cases now guarded) |
| A05 Security Misconfiguration | **PASS** — `contents: read`, `fetch-depth: 0`, no empty-default fallback |
| A06 Vulnerable Components | **PASS+** — `softprops/action-gh-release` retired from the publish path |
| A07 Auth Failures | N/A |
| A08 Software & Data Integrity | PASS — three-leg conjunction enforced in CI and observed passing |
| A09 Logging & Monitoring | PASS — all new controls emit named failures |
| A10 SSRF | N/A |
| LLM01 Prompt Injection | **PASS** — the CRITICAL autonomous-publish persona is deleted and blocked by both list types |

---

## 6. What could not be proven

Stated as limits of the phase, not as judgements.

1. **No release was actually published.** Publishing, tagging and filing upstream PRs were forbidden this phase and remain owner-approved post-merge. End-to-end publish is verified by reading and by local runs, never by execution.
2. **The removal ledger has never run in CI.** It is `pull_request`-only and every run to date was a direct push, so it was skipped each time. It was run locally and observed both failing correctly and passing correctly, but its first real CI execution is this PR.
