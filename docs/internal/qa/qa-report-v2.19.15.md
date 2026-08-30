# QA Report — Cowork v2.19.15 "The Gate That Isn't On" (Phase 5)

**Repo:** `/Users/macbookpro/claude-cowork-config` · Branch `release/v2.19.15-enforce-the-gate` · Base **`94bca8f`** · Uncommitted working tree · **SECURITY-SENSITIVE / Tier A**
**Reviewed:** 2026-08-30T06:06:04Z (host is UTC+4; `date -u`)
**Verdict: PASS** — 0 blocking, 2 INFO.

> **Provenance + one correction (orchestrator).** Persisted by the orchestrator from `@qa`'s returned
> text — `docs/internal/qa/qa-report-v2.19.15.md` is not writable under `@qa`'s scope rules (the
> `internal/` path component defeats every allow-list arm). `@qa` did not attempt the write and did not
> route around it.
> **`@qa`'s returned header cited base `94bc879`. That SHA does not resolve** (`git rev-parse --verify`
> → `fatal: Needed a single revision`). The real base is **`94bca8f`**, confirmed as both `main` and the
> merge-base. Corrected above. `@qa`'s verification ran against the working tree rather than against that
> SHA, so no finding is affected — but a SHA written from memory inside a Tier A report is this cycle's
> own defect class, and is recorded rather than silently fixed.

---

## 1. Findings

| id | severity | summary | BLOCKS Phase 6 |
|---|---|---|---|
| F-1 | INFO | `.github/CODEOWNERS`'s new comment reads as if required checks are path-scoped; they are branch-wide. Wording nit, not a functional defect. | No |
| F-2 | INFO | B1's API-only derivation canary and B4's `strict: true` are **post-merge** obligations, correctly tracked as unchecked `AC-CIGATE-1` / `AC-REQCHECK-1` / `AC-SEQ-1` boxes. Flagged only so they are not lost at Phase 7/merge. | No |

**No BLOCKER or CRITICAL.** Every claim in ADR-099 and both amendment records that was independently
re-derived reproduced exactly as stated.

> `@qa`'s own note, retained: *"Unlike the three prior review passes (each of which falsified the one
> before it), my independent re-execution did not falsify anything — I am not manufacturing a finding to
> match that pattern."*

---

## 2. Item verification

**(b) Duplicate structurally gone.** `on:` is `pull_request` + `workflow_dispatch`; all 9 remaining
`push` hits are comments/prose, **0** are trigger declarations. The other three workflows were checked
directly — none triggers on `pull_request`, they contribute 4 job names total, and overlap with
quality.yml's 35 is the **empty set**, so no name collision is reachable on a PR SHA. The one residual
duplicate class is exactly the documented one (repeat manual dispatch; `ef89dedee308` carries 3
check-runs under one name). No second, undocumented duplicate path found.

**(c) Guards.** Allow-list form → **3** (at `:1977`, `:2229`, `:2441`), old `== 'pull_request'` form →
**0**. Each preceded by the identical explanatory comment, all three hunks read. Fails **closed** on a
future event absent from the array.

**(d) Job-name round-trip, all 35, PyYAML 6.0.3.** 35 parsed, 35 source literals extracted independently
by regex over the raw file, compared pairwise: **0 mismatches, 0 non-string values.** The repaired name
resolves to `Verbatim Attribution Rule Check (ADR-024 / #15)`, length 47 — the `#15)` suffix survives.

**(e) `actions: write` isolation.** One real `permissions:` key at `:687` inside `dispatch-quality`;
`sync-upstream`'s block (`:40-42`) carries only `contents: write` / `pull-requests: write`. Both diffs
read end-to-end: every value crossing into a `run:` (`TARGET_BRANCH`, `GH_TOKEN`, `BASE_REF`) goes
through `env:` and is referenced as `"$VAR"`, never `${{ }}` into shell text.

**(f) `BASE_REF` assertion proven firing.** Step body extracted byte-for-byte via PyYAML, not retyped.
`unset BASE_REF` → `::error::BASE_REF empty — refusing to run a vacuous ledger check`, **exit 1**.
`BASE_REF=main` → the real script runs, `PASS: removed=0`, exit 0. A3's own numbers independently
re-run: `git show "origin/:cowork.lock.json"` → **128**; `origin/main:` → **0**.

**(g) Document corrections — backed by live GETs, not prose.** OT-7 and `v2.19.5-CODEOWNERS-1` both
carry **both** rejection reasons. Live state re-run rather than trusted: `require_code_owner_reviews:
false`, `required_approving_review_count: 0`, `enforce_admins: true`, **no `required_status_checks` key
at all**; `can_approve_pull_request_reviews: true`; and `collaborators` → exactly one, `jmlozano1990`
(admin), confirming "sole maintainer = sole code owner" is measured, not assumed.

**CODEOWNERS future-tense phrasing: assessed and endorsed.** The live GET confirms
`required_status_checks` is genuinely absent right now, so asserting present-tense falsity *"would itself
be inaccurate"*. Naming the trigger condition is the more durable phrasing.

**(h) Version / scope / egress.** `VERSION` `2.19.15`; README badge `2.19.14`→`2.19.15`;
`## [2.19.15] - 2026-08-30` present. Exactly the 10 planned files changed, no untracked files, the
post-arming fixture confirmed **absent** (added-then-reverted as planned). `CF-v2.19.15-SCANMIRROR`
named as unowned/not-fixed-here. Latest release still `v2.19.13`; **no `v2.19.15` tag or release
exists** — nothing published. `git archive HEAD | tar -t | grep -c '^docs/internal/'` → **0**,
negative-controlled against `.gitattributes`.

---

## 3. Item (a) — `AMEND-1`, the binding condition

**PASS.** Step body extracted from `quality.yml` via PyYAML — **not transcribed** — isolated to a
standalone script and run under real `bash` against three fixtures built **outside the repo**, each a
real directory tree so the script's relative path resolves without touching the repo file.

| Fixture | Result |
|---|---|
| real doc (8 fenced `regex` blocks) | `PASS: 8 regex patterns compile cleanly`, **exit 0** |
| zero-pattern doc | `ERROR: No regex patterns found…`, **exit 1** |
| invalid-regex doc (unterminated bracket) | `ERROR: pattern failed to compile (grep exit 2)`, **exit 1** via the exit-2 path |

Exit 2 confirmed genuinely produced — with both `/usr/bin/grep` and the ugrep shim — before the harness
was trusted.

**Negative control (old, pre-fix logic), independently reconstructed:** `PATTERN_COUNT raw=[0\n0]`,
`integer expected`, **exit 0**, `PASS: 0\n0 regex patterns compile cleanly`. An independent reproduction
of the original CRITICAL, not a citation of it.

**Compositional check — "fixing any two leaves the third latent" was TESTED, not assumed.** Three
ablations off the fixed script, each reverting exactly one sub-defect:

| Ablation | Fixture | Result |
|---|---|---|
| revert extraction pattern only | real doc | `ERROR: No regex patterns found`, exit 1 — **false negative** |
| revert `\|\| true` → `\|\| echo 0` only | zero-pattern | multiline `integer expected`, **exit 0 — false PASS** |
| drop the `-lt 1` floor only | zero-pattern | `PASS: 0 …`, **exit 0 — false PASS** |

**All three sub-defects are independently necessary; none is redundant.**

---

## 4. What the re-run falsified

**Nothing, from any author.** Independently re-executed and found accurate: the `on:` diff, all three
guards (count and form), all 35 names under a real parser, the `actions: write` isolation, both
`BASE_REF` branches, A3's two exit codes, and every live-repo number OT-7 and the risk register cite.
Nothing was accepted from the documents without re-running the underlying command.

Two items deliberately **not** executed, correctly scoped post-merge in the spec: B1's API-derivation
canary and B4's `strict: true`. Faking them would require the PR to exist and be dispatched, outside a
read-only mandate.

---

## 5. Verdict

**PASS.** Recommend proceeding to `/audit`.
