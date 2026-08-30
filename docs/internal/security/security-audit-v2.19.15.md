# Security Audit — Cowork v2.19.15 "The Gate That Isn't On"

## Phase: 6 (Code Audit)
## Date: 2026-08-30T06:24:23Z (host UTC+4; all timestamps from `date -u`)
## Status: **PASS WITH WARNINGS** — 0 CRITICAL, 4 WARNING, 4 INFO
## Verdict: **MERGE** · Post-merge arming conditions as written: **NOT SUFFICIENT** (§6)

> **Provenance (orchestrator).** Persisted from a **fresh** `@security` instance's returned text —
> deliberately not the instance that ran Phases 2 / 2.R1 / 2.R2. The path is not writable under its
> scope rules; it did not attempt the write and did not tunnel it. Every `gh` call was a GET;
> `required_status_checks` is still `null` — **the toggle has not happened.**

**Repo:** `/Users/macbookpro/claude-cowork-config` · branch `release/v2.19.15-enforce-the-gate` ·
HEAD = `94bca8fc5f298c0ab8d91f0e9f9657df73f0fd99` (= base; changes uncommitted) · Tier A.

---

## 1. Findings

| ID | Sev | Surface | Description | BLOCKS MERGE |
|----|-----|---------|-------------|--------------|
| S1 | WARNING | configuration | Arming uses `PUT …/branches/main/protection`, which **replaces** the protection object. `required_pull_request_reviews` is a **live non-null object**; a call omitting it silently drops "require a PR before merging". The named read-back diffs only *contexts*, so it is blind to this. | No — blocks **arming** |
| S2 | WARNING | configuration | B1's binding derivation uses `per_page=100` with **no pagination and no `total_count` assertion**. Truncation is silent. Proven with a firing control. | No — blocks **arming** |
| S3 | WARNING | external-api | `dispatch-quality`'s target branch is **reconstructed by string concatenation** rather than read from the action's own `pull-request-branch` output, which exists at the pinned SHA. Two constructions, no assertion binding them. | No |
| S4 | WARNING | configuration | A `workflow_dispatch` run checks out the **branch head**, not `refs/pull/N/merge`. On the sync path the 33 contexts certify the branch head, not the merge result. **`strict: true` is load-bearing for correctness, not only coverage** — not recorded as such anywhere. | No |
| S5 | INFO | configuration | ADR-099's "proven … lands on the correct SHA under the correct name" is over-scoped: the mechanism is proven **generically**, but 0 of 9 repo-wide dispatch runs were of `quality.yml`, on a non-default ref, or token-initiated. | No |
| S6 | INFO | permissions | `dispatch-quality` holds `actions: write` and **no `contents: read`**. Workflow-resolution under that exact set is unexercised. Fails closed if wrong. | No |
| S7 | INFO | ui | CODEOWNERS' new clause reads as if required checks are path-scoped; they are branch-wide. (Independently reproduces @qa's F-1.) | No |
| S8 | INFO | external-api | The `GITHUB_OUTPUT` write of `latest_sha` is newly load-bearing (it selects a dispatch ref) and unvalidated. Not exploitable without compromising `api.github.com`; no shell-injection path. | No |

---

## 2. The two arming findings, with their controls

**S1 — the arming call replaces rather than patches.** The live GET returns
`required_pull_request_reviews` as a **non-null object** (`required_approving_review_count: 0`,
`require_code_owner_reviews: false`), `enforce_admins: true`, and every optional boolean `false`.

*Control:* the optional booleans are **already** `false`, so a PUT omitting them is harmless — which is
precisely what makes `required_pull_request_reviews` the *only* live hazard rather than one of eight.
The same GET discriminates the two classes.

**Why it matters here specifically:** A1's cost justification is that dropping `push` is safe *because*
this repo requires a PR before merging. That premise **is** this object. Drop it in the arming call and
`quality.yml` — which no longer runs on `push` — cannot report on a direct push at all. Honest read on
harm: this fails **closed** (`main` becomes push-locked, not unguarded). It is an unintended protection
change, not a hole.

**S2 — silent truncation, with a firing control.**

```
?per_page=100 → {"total_count":70,"returned":70,"distinct":35}
?per_page=50  → {"total_count":70,"returned":50,"distinct":35}   ← no error, exit 0
```

`returned: 50` against `total_count: 70`, and `--jq` computes `unique` over the truncated array without
complaint. Under the shipped `on:`, a PR head carries 35 check-runs, so `per_page=100` holds for one run
plus one re-run — **a third suite on one SHA is 105 and crosses the boundary**, and a third suite on one
SHA is already documented. The canary catches a *lost name*, so this is fail-closed — but the command
never announces that it read only part of the population. **That is the exact defect class this cycle
exists to end.**

---

## 3. Re-execution

**(a) The parser and guard changes — re-executed, not re-read.** Step body extracted mechanically, never
transcribed; fixtures built as real directory trees **outside** the repo; run under bash 5.3 (macOS's
`/bin/bash` is 3.2, lacks `mapfile`, and cannot reproduce this at all).

| Fixture | Result | Exit |
|---|---|---|
| real doc (8 fenced blocks) | `PASS: 8 regex patterns compile cleanly` | **0** |
| no fences, old-style list | `ERROR: No regex patterns found` | **1** |
| block with `(unclosed[bracket` | `ERROR: pattern failed to compile (grep exit 2)` | **1** |
| empty file | `ERROR: No regex patterns found` | **1** |

**The check can go red three independent ways.** All three sub-defects independently fixed.

*Falsification control — pre-fix body from `git show HEAD:…`, run on the real doc:* reproduced the
original defect exactly — multiline `PATTERN_COUNT`, `[` errors, `set -e` does not fire on a failing
`if` **condition**, the `exit 1` guard is never reached, `PASS` with exit **0** having examined nothing.

*grep-flavour discipline:* re-ran under `PATH=/usr/bin:/bin` (BSD grep) — identical. CI is GNU grep,
unavailable here; gap closed by inspecting the population instead — all 8 patterns are plain POSIX ERE,
so no GNU/BSD divergence is reachable, and exit 2 on an invalid ERE is POSIX-mandated in all three.

**(b) The check-run chain, attacked end to end.**

| Link | Status |
|---|---|
| 1. Dispatch reachable | **Proven** — `actions: write` exactly once; `run:` free of `${{ }}`; workflow active |
| 2. A dispatch run creates check-runs under the **job name**, on the **target SHA** | **Proven with live repo data** |
| 3. Names match the required contexts | **Proven** — PyYAML over all 4 workflows: 35 jobs / 35 unique; 39 distinct repo-wide; **0 collisions** |
| 4. Name #25 no longer truncated | **Proven both directions** — parsed shipped file gives the full string; live control on `14b41dc` gives the truncated one |
| 5. Branch protection **accepts** it | **Unprovable now** — requires arming. Correctly acknowledged by ADR-099 |
| 6. …for `quality.yml`, non-default ref, token-initiated | **Unproven** (S5) |

**Attack result — "a check-run that looks satisfying but isn't": none found in the shipped bytes.** Only
3 jobs carry a job-level `if:`, all three allow-list `workflow_dispatch`, so no required context degrades
to `skipped` (which protection treats as passing). No job-level `if:` can produce *zero* entries, so the
deadlock shape is not reachable. What exists is one step earlier, at **arming** (S1, S2), and one
semantic layer down (S4).

---

## 4. What this re-run falsified

- **ADR-099 §Consequences' "proven"** — over-scoped. Proven *generically*; not for `quality.yml`, a
  non-default ref, or a token-initiated dispatch. Zero of 9 dispatch runs exercise any of the three. (S5)
- **@qa Phase 5 §4, "nothing falsified, from any author"** — not sustained. @qa scoped its re-run to the
  shipped bytes and did not audit the post-merge arming procedure, where S1 and S2 live. **A scope gap,
  not an error** — and its refusal to manufacture a finding was the right call.
- **@qa §2(h) "no untracked files"** — there is now exactly one: @qa's own report, which did not exist
  when it ran. Immaterial; recorded because a Tier A report asserting a zero should be re-derivable.

**Upheld on independent re-execution:** every `AMEND-1` sub-defect and its ablation; the pre-fix
false-PASS; all 35 names under a real parser; the live truncated name; `actions: write` isolation;
complete `env:` indirection; the `BASE_REF` assertion; the 3-guard count;
`can_approve_pull_request_reviews: true`; `enforce_admins: true`; `required_status_checks: null`;
branch-name agreement; `pull-request-number` at the pinned action SHA.

**Prior CRITICALs re-tested, all correctly closed** — A2, B1, A1, A5.

**(d) Document overstatement — the discipline held.** No changed document claims the gate is armed or a
risk closed. CHANGELOG states the arming is explicitly not part of this PR; OT-7 and the risk row both
remain **OPEN**; CODEOWNERS is deliberately future-tense and **correct because** the live GET shows
`required_status_checks` genuinely absent; all post-merge ACs remain unchecked; ADR-099 is still
`PROPOSED`. The single over-reach anywhere is the ADR's own "proven" (S5) — an epistemic over-claim
about evidence, not a claim that the gate is on.

**(e) Egress + scope — clean, non-vacuously.** `git archive` → 419 entries; `docs/internal/` → **0**;
control `^docs/` → **27** (listing live, matcher fires). **90 tracked files under `docs/internal/`, 0 in
the archive** — the rule is proven against a real population, not an empty one. 10 tracked files changed,
`scripts/` diff → **0**, post-arming fixture absent, latest release still `v2.19.13`, no `v2.19.15` tag.

---

## 5. Guard Change Summary

✅ **MERGE — 0 live settings changed; the gate is still off, and all 4 warnings sit in the post-merge arming step, not in what you are merging.**

**What you're approving:** the machinery that makes it safe to switch on `main`'s merge gate — **not the
switch itself.**

**What you're accepting:**

1. **Arming with a partial API call could silently drop "require a pull request before merging."** The
   arming API *replaces* the whole protection setting rather than adding to it, and the entire safety
   argument for dropping the `push` trigger depends on that setting being present. *(Possible. Medium
   harm — the one worth your attention.)* Fails safe rather than open, but the currently-planned
   verification would not notice it.
2. **The list of required checks is read one page at a time** and can quietly come back incomplete. A
   count canary stops the arming if it does — but the reading step never announces it saw only part.
   *(Unlikely. Medium harm.)*
3. **The sync robot's new CI has never actually run** — not once, in this repo's history. Everything
   checks out on inspection and the mechanism was proven with real data from this repo, but this exact
   combination has no track record. *(Possible. Low harm — fails loudly, while the gate is still off.)*
4. **Two places construct the sync branch name separately.** Identical today. *(Unlikely. Low harm —
   fails closed.)*

**What's protected.** `enforce_admins` stays `true`. Approvals stay off — permanently and deliberately,
because you are sole maintainer and sole code owner and GitHub forbids self-approval. Force-push and
deletion stay blocked. No new secret, token or credential. `actions: write` is held by exactly one new
job that never downloads upstream content and never checks out the repo, and nothing from upstream
reaches a command line. Internal reports stay out of the release archive — **90 such files, 0 in a
419-file archive**, verified with a control that fires.

**Load-bearing, named as such: the ordering rule.** The robot's CI must be seen working **before** the
gate is switched on. Get that backwards and, with admin enforcement on, nobody — including the owner —
can merge the fix.

**What to verify after merge.**
- The front-page version badge reads `2.19.15`.
- `docs/owner-tasks.md` OT-7 and the risk row **still say OPEN**. **If either says CLOSED before the
  switch is flipped, something claimed a result it did not earn** — that absence is the alarm.
- After arming: any PR's checks reach a green tick or red cross. **If every check instead sits at
  "Expected — waiting for status" and never moves, the gate is broken, not running.** That is the
  failure signature to memorise: it reads like *still working* and means *will never finish*. It happens
  if the workflow file stops parsing; the fix may need the required-checks setting temporarily removed.
- Around 1 September the monthly sync PR should appear **with** check results. It has never had any. If
  it appears with none, the robot's CI did not fire — and that is exactly the observation the ordering
  rule requires **before** the switch.

**What could not be proven:** that branch protection will **accept** a dispatched check-run. Every link
up to it was proven with real data from this repository. The final link cannot be observed until the gate
is on, because that is the thing being tested. This is why the ordering rule exists: if it fails, it is
discovered while the gate is still off, and the cost is one more PR rather than a locked repository.

---

## 6. Verdict, and the arming conditions assessed separately

### MERGE — the shipped bytes are sound
0 CRITICAL. Every prior blocking defect re-tested and closed **by execution, not by reading**. Scope
clean, egress clean, no release published, no live setting touched. All four WARNINGs are located
**after** this PR merges.

### Post-merge arming conditions as written — **NOT SUFFICIENT**. Three additions required:

1. **Read back the WHOLE protection object, not just the contexts (S1).** The PUT replaces rather than
   patches. Re-assert `enforce_admins: true`, `required_pull_request_reviews` present with
   `required_approving_review_count: 0` and `require_code_owner_reviews: false`,
   `allow_force_pushes: false`, `allow_deletions: false` — against a full GET taken immediately before
   the PUT.
2. **Prove the derivation read the whole population (S2).** Before `unique`, assert
   `total_count == (.check_runs | length)`, or use `--paginate`. A count-only canary tells you the answer
   is wrong; it does not tell you the **instrument** was truncated.
3. **`AC-CIGATE-1` stays an explicit precondition and must not be folded into the read-back.** Neither
   named condition observes what `AC-SEQ-1` requires: a real bot-opened sync PR receiving check-runs.

`strict: true` should additionally be recorded as load-bearing for **correctness** on the sync path, not
only for `main` coverage (S4) — a future cycle setting it `false` would silently downgrade sync-PR
verification from the merge result to the branch head.

**Non-blocking follow-ups for a later cycle:** S3, S6, S7, S8.
