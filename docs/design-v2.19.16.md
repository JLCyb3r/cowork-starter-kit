# Design — v2.19.16 "The Sync That Can't Land"

> *ISO 15288 — Technical Management: Project Planning Process.*

**Cycle:** v2.19.16 · **Phase:** 1 (Design) · **Mode:** full
**Classification:** SECURITY-SENSITIVE — Tier A · COMPLIANCE-SENSITIVE = NO (re-derived at §Classification Re-Run; one conditional flip named there)
**Working path:** `/Users/macbookpro/claude-cowork-config`
**Branch:** `release/v2.19.16-sync-repair` · **Base:** `24e1b583b21b177cd58b15a139f06321d8e1172f`

**Evidence base.** Every number in this document was re-run by @architect during Phase 1 against the
branch checkout at `24e1b58` and against the live GitHub API (read-only GETs only). `/usr/bin/grep`
by absolute path — the bare `grep` in this harness is a ugrep shim that honours `.gitignore` and
under-counts. Host is UTC+4; every timestamp is `date -u '+%Y-%m-%dT%H:%M:%SZ'`, never hand-typed.
Lock facts are read from the **PR head** via the Contents API at
`c43d56f438ee820af427c889e1fff6cc6294fb25`, never from a local `main` checkout.

**Numbers handed to this phase were re-run, not adopted.** The Phase-0 spec survived three adversarial
passes and its "Settled facts" block is accurate: MISSING **44**, MISMATCH **15**, ORPHAN **2**, head
lock **150**, disk **108**, common **106** — all four re-derived here by independent set arithmetic
and a local strip-and-hash pass (§C.0). The rename asymmetry is confirmed hash-for-hash. **Four
claims did not survive re-run, and two of them change what this cycle has to build.** They are
recorded at §0 before anything else, because two are load-bearing on the spec's own decomposition.

---

## Table of contents

- **§0 — Where the spec's decomposition does not survive contact with design** (read first)
- §A — Phase 1 Design Header (mandatory records)
- §B — The lock-state coupling, and what it forces
- §C — Technical design, item by item
- §D — File-by-File Implementation Plan + `scope_allow_delta`
- §E — B1 verification
- **Classification Re-Run** (mandatory gate record)
- §F — Residuals carried forward

---

## §0 — Where the spec's decomposition does not survive contact with design

> *ISO 15288 — Technical: Stakeholder Needs and Requirements Definition Process.*

The spec is good. It is wrong in four places, two of them structural. Stated plainly here rather than
designed around, per the brief's own instruction.

### §0.1 — BLOCKER: `AC-VENDOR-1` is necessary but not sufficient. A third assertion the spec never names will still fail.

`Vendored Integrity Check (audit F-7)` is a **three-step job**. The spec addresses step 1 (the
lock→disk forward check) and is aware of step 2 (the orphan check). **Step 3 has never been mentioned
in this cycle** and cannot pass on PR #125's head under any D1 alternative:

```
quality.yml:2343  - name: Assert vendored count == 108 and the two v2.19.7 removals are complete (AC-B5-1, AC-B5-4)
quality.yml:2365    if [ "$LOCK_COUNT" -ne 108 ]; then
quality.yml:2369    if [ "$DISK_COUNT" -ne 108 ]; then
```

Measured this session:

| | value | source |
|---|---|---|
| `LOCK_COUNT` at PR head `c43d56f` | **150** | Contents API |
| `LOCK_COUNT` on `main` @ `24e1b58` | 108 | local checkout |
| `DISK_COUNT` (the job's own `find` expression) | 108 | local checkout |

So on PR #125's head the job fails at `AC-B5-1` (`150 ≠ 108`) **even with zero MISSING and zero
MISMATCH**, and after a correct re-vendor it fails again on the disk side (`150 ≠ 108`). The reason the
cycle never saw this error is that step 1 exits 1 and GitHub aborts the job — steps 2 and 3 never ran.
**`AC-VENDOR-1` as written can be fully satisfied while the check it names stays red.** Amending it is
recorded in `docs/spec.md` §Architectural Modifications.

The constant is not incidental. Its own comment states the hazard a bump creates:

> *"AC-B5-1's `== 108` is a CONSTANT that legitimately moves on the next upstream addition — bumping it
> is exactly the moment a re-introduction could hide inside a 'the count changed for a good reason'
> commit. AC-B5-4's per-path assertions are what survive that."*

That check was therefore run before proposing any bump. **Both v2.19.7 permanent removals are ABSENT
from the 150-entry head lock** — `marketing/marketing-carousel-growth-engine.md` → `ABSENT`,
`project-management/project-manager-senior.md` → `ABSENT`; firing control
`academic/academic-historian.md` → index `2` (present), so the test discriminates. Nothing is hiding
inside the count.

### §0.2 — BLOCKER: `AC-RATCHET-1`'s prescribed fix shape is unsatisfiable. A new `RATCHET_SHA` alone cannot work.

`AC-RATCHET-1` says *"select a new, earlier `RATCHET_SHA`"* and treats the path set as fixed. Measured,
that is impossible. Leg 3(c)'s fixture guard requires the poisoned path's content at `RATCHET_SHA` to
**differ from the `content_sha256` stored in the `cowork.lock.json` of the commit CI is running on** —
and this cycle has **two** such commits with different locks (§B). For the hardcoded poison path
`marketing/marketing-content-creator.md` there are exactly two reachable content states in the window
where the current `RATCHET_PATHS` all exist:

| candidate `RATCHET_SHA` | date | marketing hash | vs `main` lock | vs PR-head lock | `academic/academic-historian.md` |
|---|---|---|---|---|---|
| `7f171ae0` | 2026-03-15 | `676c536d…` | **COLLIDES** | differs | HTTP 200 |
| `6d58ad4c` | 2026-03-10 | `676c536d…` | **COLLIDES** | differs | **HTTP 404** |
| `0e22704e` | 2026-03-05 | `6a638eb6…` | differs | differs | **HTTP 404** |
| `783f6a72` | 2026-04-12 | `676c536d…` | **COLLIDES** | differs | HTTP 200 |
| `c89557f7` (current) | 2026-07-30 | `26ddce44…` | differs | **COLLIDES** | HTTP 200 |
| `9f3e401c` | 2026-07-09 | `26ddce44…` | differs | **COLLIDES** | HTTP 200 |

The only two-sided-safe content state (`0e22704e`) **predates the `academic/` division**, created
2026-03-15 by `7f171ae0` — so both `academic/` paths 404 there and `curl -sf` in the fetch loop kills
the step. **No `(RATCHET_SHA, current RATCHET_PATHS)` tuple is green on both commits.** The fix must
move the SHA *and* the path set. §C.4 selects and verifies a concrete triple.

The spec's own candidate, `783f6a72…`, is the trap in the clearest possible form: it is `main`'s
current pin, so adopting it makes the fixture guard collide on **this cycle's own PR** — the fix would
break the branch carrying it. That is the same shape as v2.19.15's required-context lockout.

### §0.3 — The spec's `AC-APPROVAL-1` verification instrument has a blind spot, and would pass over a surviving false claim.

`AC-APPROVAL-1` under D3(a) is verified by
`/usr/bin/grep -nE '2 (separate )?(maintainer|CODEOWNERS) approvals?'` returning **no** matches. Run
against the live files it matches 3 lines. A wider instrument finds **4**:

```
CONTRIBUTING.md:358      **Agency-sync PRs require 2 separate maintainer approvals before merge.**
.github/CODEOWNERS:4     # Supply-chain-critical files require 2 maintainer approvals.
.github/CODEOWNERS:5     # agency-sync PRs (labeled 'agency-sync') MUST have 2 CODEOWNERS approvals
.github/CODEOWNERS:10    # Supply-chain integrity files — 2 approvals required for all PRs touching these
```

`CODEOWNERS:10` says *"2 approvals required"* with no intervening `maintainer`/`CODEOWNERS` token, so
the spec's regex **cannot match it**. Fix all three sites, run the spec's instrument, get exit 1, and
declare the AC met — with the false claim still standing. A fifth false assertion sits beside them and
is about *enforcement* rather than count: `CONTRIBUTING.md:359-360` says *"This rule is enforced via
CODEOWNERS"*, while live protection reads `require_code_owner_reviews: false` and
`required_approving_review_count: 0`. Both corrections are folded into §C.6 and recorded as spec
modifications.

### §0.4 — H1 is not a hypothesis. It is provable by set arithmetic, before any re-run.

The spec asks for H1 (*"the undeclared removals and the orphans are the same two files"*) to be proven
by re-running the checks. It is already provable from the artefacts:

```
disk path-set              108
main-lock path-set         108
comm -3 main-lock disk  -> (empty)          # the two sets are IDENTICAL
                           firing control: comm -3 main-lock prhead -> 46 lines
ORPHAN  = disk ∖ head-lock       = {engineering-security-engineer.md, engineering-threat-detection-engineer.md}
REMOVED = main-lock ∖ head-lock  = {engineering-security-engineer.md, engineering-threat-detection-engineer.md}
```

Because the disk path-set and the ledger's base path-set are *the same set*, the orphan set and the
removal set are identical **by construction**, not by coincidence. One upstream rename produces two
red checks, necessarily. The re-run is still worth doing as an observation, but the cycle should not
treat H1 as open.

H2 is a genuine hypothesis and is left as one — see §C.3.

---

## §A — Phase 1 Design Header (mandatory records)

> *ISO 15288 — Technical Management: Decision Management Process.*

### A.0 Worktree discipline

**Worktree discipline: ENFORCED (SECURITY-SENSITIVE / Tier A).** First action executed before any read
or write: `git -C /Users/macbookpro/claude-cowork-config rev-parse HEAD` →
`24e1b583b21b177cd58b15a139f06321d8e1172f`, matching the pinned base exactly; branch
`release/v2.19.16-sync-repair`. `COUNCIL_EXPECTED_BASE_SHA` was **unset** in this spawn context
(fail-open per F6), so the pinned base from the spawn prompt was used as the comparand.

This cycle works **in place on the branch**, not in a nested `.worktrees/` directory as v2.19.13 did.
Consequence recorded rather than assumed: the checkout is not a live parallel-session surface for this
slug (the session pin `.claude/projects/.session-pin-12307` is the only live pin), and a recursive grep
from the repo root traverses no nested worktree, so counts are not doubled. Verified: no `.worktrees/`
directory exists.

**Read-only discipline on GitHub was maintained throughout Phase 1.** Every `gh` invocation in this
document is a GET. No merge, no push, no setting mutated, no interaction with PR #125.

### A.1 Production validation

**Production validation: N/A — no repo-artifact parsing in this design.** This cycle contains no logic
that parses `pipeline.md`, `roadmap.md`, `registry.json`, `retro.md` or any Council guard-read file, so
the cross-project loop does not apply.

**The equivalent obligation — running candidate logic against the REAL artefacts rather than against
fixtures — was discharged, and it changed the design twice.** Both §0.1 and §0.2 are consequences of
running the guards' own expressions against the real head lock rather than reasoning about them:

- The `find`/`jq` count expressions at `quality.yml:2363-2364` were executed verbatim against the real
  tree and the real head lock. A fixture would have been built at whatever count the fixture author
  chose and would never have surfaced the `108` pin.
- Leg 3(c)'s fixture guard was evaluated against **both** real lock states, which is the only way the
  two-sided constraint becomes visible. Evaluating against one lock — which is what "verify it is
  uncollided against the live lock" invites — yields a green answer for `783f6a72` and ships the trap.

**One local-reproduction pitfall, recorded because it produced a false 106/106 MISMATCH here first.**
The integrity strip `sed "1,/^${END_MARK}$/d" | sed '1{/^$/d}'` is GNU-sed syntax. BSD `sed` (macOS)
rejects `1{/^$/d}` with *"extra characters at the end of d command"*, the second `sed` produces no
output, and every file hashes to `e3b0c44298fc1c14…` — the SHA-256 of the empty string — so **every**
file reports MISMATCH. CI runs GNU sed and is unaffected. Anyone reproducing locally on macOS must
write `sed '1{/^$/d;}'`. The tell that the instrument is broken, not the corpus, is `e3b0c442…`
appearing as every stripped hash.

### A.2 Reuse Radar (4-source lookup)

| # | Source | Result |
|---|---|---|
| 1 | `docs/reuse-registry.md` (Council) | **Not present** in this repo and not applicable to an external-project cycle. Recorded and skipped, not silently dropped. |
| 2 | `examples/scaffolds/INDEX.md` (Council) | **Not present.** Recorded and skipped. |
| 3 | `docs/architecture.md` `Reusability:` ADR tags (this repo) | Present. **ADR-080** (removal ledger, `Reusability: candidate-constituent`) is the direct predecessor and is **EXTENDED**, not rebuilt. **ADR-024** (attribution block) is the surface D1(c) would amend. **ADR-099** supplies the `workflow_dispatch` mechanism D1(b)/(c) verification depends on and is **REUSED unchanged**. |
| 4 | `.claude/projects/ecosystem/sos-interfaces.json` (Council) | Present. 0 matches for `cowork|vendor|ratchet|allowlist` — no existing interface contract covers this capability. |

**Reuse Scan**

| Component | Registry hit (grep pasted) | OSS candidate (name+license+health) | Scaffold | Decision | Basis |
|---|---|---|---|---|---|
| Vendoring step inside `sync-agency.yml` (D1 b/c) | none — registry absent | n/a — no OSS action vendors a lock-pinned corpus with this repo's attribution contract; adding a third-party action to a supply-chain ingestion path is the opposite of this cycle's posture | n/a | **REUSE** | Invokes the **existing** `scripts/vendor-agency.sh` unchanged. Zero new code for the write path. |
| Vendored-tree prune (delete-what-the-lock-dropped) | none | n/a — `rsync --delete` is available but pulling a deletion primitive into a supply-chain writer for ~8 lines of `comm`+`rm` is a larger surface, not a smaller one | n/a | **BUILD** | No hit. ~10 lines. It is the one direction `vendor-agency.sh` structurally lacks (ADR-080 §Context (3)), and it is a security control, so it is a core differentiator, not commodity. |
| Ratchet fixture pair (`RATCHET_SHA` + `RATCHET_PATHS`) | none | n/a — fixture data, not a component | n/a | **REUSE (data-only)** | No logic changes at all. Four literal values move. This is deliberate: see §C.4. |
| Cardinality count expression | none | n/a — `grep`/`wc` already present; the zero-dependency constraint on this workflow forbids adding any | n/a | **REUSE (pattern)** | Adopts the in-repo house-standard `|| true` form already used at 7 sibling sites, established by ADR-099 AMEND-1. Not a new invention. |
| `blocked_files[]` entries (D2 b) | none | n/a — data | n/a | **REUSE (pattern)** | Matches the 3 existing entries' schema exactly, with one field value changed (`permanent: false`). |

**Buy-vs-Build: 5 components scanned — REUSE 4 / ADOPT 0 / EXTEND 0 / BUILD 1**

No ADOPT rows, therefore: no dep-scan flag owed, no L1/L1b license gate owed, no `ATTRIBUTIONS.md` row
owed, no AC-D1.9 prompt-injection screen owed. **One conditional exception:** if the owner selects
**D2(a)**, the cycle ingests 12 upstream `security/` files, which *is* an ADOPT of third-party content
and does trigger the content-scan obligation `AC-ALLOWLIST-3` already names. That is registered here
so the Reuse Scan does not silently disagree with the classification record.

### A.3 EARS check

All 16 ACs were re-checked against `.claude/skills/architect/ears-requirements.md`.

**EARS check: 3 HIGH-severity findings — 3 OQs generated.** All three are testability defects, not
syntax defects: each AC as written can be satisfied while the outcome it names remains false.

| AC | Finding | `[EARS-REVISED]` |
|---|---|---|
| **AC-VENDOR-1** | HIGH — the subject ("Vendored Integrity Check reports zero MISSING and zero MISMATCH") names two of the job's three failure modes. Satisfiable while the check is red (§0.1). | *The `Vendored Integrity Check (audit F-7)` **job** SHALL reach `conclusion=success` against the corrected commit — all three steps, not the forward check alone — with zero MISSING, zero MISMATCH, zero orphans, and `LOCK_COUNT`/`DISK_COUNT` satisfying the cardinality assertion in whatever form §C.1 lands.* |
| **AC-RATCHET-1** | HIGH — prescribes a fix shape ("select a new, earlier `RATCHET_SHA`") that is unsatisfiable with the path set held fixed (§0.2). An AC may not mandate an impossible remedy. | *The fix SHALL select a `RATCHET_SHA` **and a `RATCHET_PATHS` set** such that (i) every path in the set resolves HTTP 200 at that SHA, and (ii) the poisoned path's content at that SHA differs from its `content_sha256` in the lock of **every commit this cycle causes CI to run on** — enumerated, not assumed to be one.* |
| **AC-APPROVAL-1** | HIGH — the verification instrument cannot match one of the four live assertion sites, so the AC can pass over a surviving false claim (§0.3). | *…verified by `/usr/bin/grep -rnE '\b2 [A-Za-z-]* ?(maintainer\|CODEOWNERS)? ?approvals?'` returning no matches (exit 1) against both files, **and** by `/usr/bin/grep -nF 'enforced via CODEOWNERS' CONTRIBUTING.md` returning no matches, with a firing positive control on the pre-fix files (currently 4 and 1 matches respectively).* |

Advisory (MEDIUM, not OQs): `AC-VENDOR-3` is correctly an Event-driven requirement rather than
Ubiquitous — its trigger is "a sync-shaped commit driven through `workflow_dispatch`" — but it is
labelled Ubiquitous. Harmless; noted for consistency. `AC-SEQ-2` is a State-driven precondition
correctly worded as one.

### A.4 SoS classification + UAF viewpoints

**N/A — single-project design.** The design touches exactly one registered project
(`claude-cowork-config`). The upstream `msitarzewski/agency-agents` repository is an *external
dependency* read at a pin, not a constituent system under any shared management authority — it has no
awareness of this repo, no negotiated interface, and no shared objective, which fails all three parts
of the Constituent System definition.

| UAF viewpoint | Record |
|---|---|
| Operational | N/A — single-project design |
| Resources | N/A — single-project design |
| Services | N/A — single-project design |
| Personnel | N/A — single-project design |

One cross-repo note, recorded because it has been mis-transferred before: the Council's own
`docs/pipeline-policy.md §PostOQClassificationReRun` places `.github/workflows/` at **Tier B** in the
Council's *self-improvement* governance, citing `security-sensitive-guard.yml`, which does not exist in
this repo. It does not transfer and does not change this cycle's Tier A verdict.

### A.5 Reliability analysis

**Reliability Analysis: N/A per NEVER-APPLY (no external API provider in any request path, no failover
or fallback mechanism, and no SLA or availability claim anywhere in the spec).**

Recorded as a near-miss rather than silently: `sync-agency.yml` and `vendor-agency.sh` both fetch from
`raw.githubusercontent.com`, and `vendor-agency.sh` carries a 3-attempt retry. That is a *build-time*
dependency with no availability claim attached — a failed fetch fails the job closed, which is the
designed behaviour — so the WHEN-TO-APPLY criteria are not met. If D1(b)/(c) is selected, per-sync
network calls **do not increase**: §C.1 reuses the existing `vendor-agency.sh` fetch rather than adding
a second one, and the fetch count is unchanged from today's manual path.

### A.6 Heuristics check (Rechtin)

| Heuristic | Signal produced this cycle |
|---|---|
| *"In partitioning, choose the elements so that they are as independent as possible."* | **Fired, and it falsified the spec's partition.** The spec declares Items 1, 2, 4, 5, 6 mutually independent. Items 1, 2, 3 and 4 are in fact coupled through a shared hidden variable — *which `cowork.lock.json` state CI evaluates* (§B). Items 5 and 6 are genuinely independent and are the only two that can be verified on this cycle's own PR with no fixture branch. |
| *"The choice between two architectures may well depend on which set of drawbacks can be handled better."* | **Fired, decisively, on Item 4.** (4-A) risks a data value going stale — a **loud** failure with a self-naming error message, as this very cycle demonstrates. (4-B) edits guard logic in a Tier-A fixture whose whole purpose is to prove a verifier fails closed — a **silent** failure mode if wrong. Where one option's drawback is silence, it is not a symmetric trade. (4-A) selected. |
| *"A model is not reality."* | **Fired twice, both against this phase's own inputs.** The brief asserted that D1(c) "changes the exact byte layout `vendor-agency.sh`'s round-trip hash verification depends on"; running a mutated copy shows the stripped hash is **byte-identical** (§C.1.3). And this phase's own first `|| echo` audit regex returned 0 on a file containing the defect (§C.5) — a check that could not fire, caught only because a control was run first. |
| *"Build in and maintain options as long as possible."* | **Fired.** D1 and D2 are left genuinely open for the owner: §C.1 and §C.2 make **all three** alternatives of each implementable rather than narrowing to a recommendation and quietly stranding the rest. The one alternative that does *not* survive design is named as such rather than left on the menu (D3(c)). |
| *"Simplify. Simplify. Simplify."* | **Fired as a constraint on the remedy.** Item 4's fix is reduced from a guard-logic edit to **four literal values**. Item 1's fix under D1(b) is reduced to *invoking a script that already exists*, plus a ~10-line prune. The one place simplification was **rejected**: the `108` pin cannot be simplified away by a smaller constant, because no constant is valid on both commits (§C.1.1). |
| *"Don't assume that the original statement of the problem is necessarily the best."* | **Fired.** The spec frames Item 4 as "the fixture rotted, re-pin it" and Item 1 as "re-vendor". Both restatements are correct but incomplete: the fixture rots *by construction* against a monotonically advancing pin, and the count constant rots by the same mechanism. Named at §C.1.1 and §C.4.2 rather than re-pinned silently a second time. |

### A.7 Maturation Path self-grep (ADR-100)

Baseline before ADR-100 was appended, then after — branch checkout, `/usr/bin/grep` (BSD grep,
GNU-compatible), `-cF` fixed-string:

```
**Future-state options:**         69 -> 70
**Concrete revisit triggers:**    69 -> 70
**Risk knowingly accepted:**      70 -> 71
```

Each header increased by **exactly 1**, confirming the section was COPIED from the template slot and
not paraphrased. Gate PASSES. (The pre-existing 70/69/69 asymmetry is inherited, not introduced here;
one historical ADR carries an extra `Risk knowingly accepted:` line. Not repaired — `docs/architecture.md`
is append-only.)

### A.8 B1 verification (header record)

**B1 verification: PASS (by construction) @ 2026-08-30T18:13:40Z.** `scope_allow_delta:` block
present and well-formed — **18** `add` entries, empty `remove`, validated as parsing YAML. Full
reasoning, including why the cross-reference is structurally inapplicable to an external-project
cycle rather than merely passing, is at **§E**. Recorded here as well because the record is a Phase-2
precondition and must be findable from the design header alone.

---

## §B — The lock-state coupling, and what it forces

> *ISO 15288 — Technical: System Architecture Definition Process.*

This is the cycle's central structural fact and it is in no prior document.

**Two commits, two locks.** This cycle causes CI to run on commits with *different* `cowork.lock.json`
contents:

| commit class | `pinned_commit_sha` | `files[]` | disk |
|---|---|---|---|
| the **v2.19.16 PR** (cut from `main` @ `24e1b58`) | `783f6a72…` | **108** | 108 |
| the **PR #125 evidence branch** / any fixture built from its tree | `3c958888…` | **150** | 108 today, 150 after re-vendor |

**Four of this cycle's assertions read that variable**, and three are pinned to a single value:

| assertion | reads | pinned? |
|---|---|---|
| `AC-B5-1` cardinality (`quality.yml:2365,2369`) | `LOCK_COUNT`, `DISK_COUNT` | **YES — hardcoded `108`** |
| Leg 3(c) fixture guard (`quality.yml:2196`) | `cowork.lock.json` hash for the poisoned path | **YES — via a hardcoded `RATCHET_SHA`** |
| `verify-lock-removals.sh` removal set | base lock ∖ head lock | no — relative |
| `verify-vendored-orphans.sh` orphan set | disk ∖ lock | no — relative |

**Consequence: no single hardcoded value satisfies both commits.** `108 ≠ 150`. And §0.2 proves no
`RATCHET_SHA` works for both with the current path set. A fix pinned to the 150 state turns the
v2.19.16 PR red; a fix pinned to the 108 state leaves PR #125 red. The cycle cannot merge over red CI.

**Three resolutions. The design adopts X2 and records the others as real options.**

| | resolution | consequence |
|---|---|---|
| **X1** | Pin everything to 150 and have the v2.19.16 PR **carry the lock bump and the re-vendored tree itself**. | One lock state, everything green. But v2.19.16 then becomes a third-party content-ingestion PR — 150 vendored files and a 42-entry lock growth in a cycle scoped as a CI repair. Escalates the security review materially and makes PR #125 redundant without merging it. Owner-visible, not an implementation detail. |
| **X2** *(adopted)* | Make the pinned assertions **lock-state-relative** so both commits are green, and verify Items 1/2/3 on a fixture branch built from PR #125's tree. | The v2.19.16 PR carries only guard fixes, docs and the allowlist change — no third-party content. Costs one structural edit to the cardinality assertion (§C.1.1) and a two-sided-safe ratchet pair (§C.4). Removes the rot that caused this cycle, rather than re-pinning into it. |
| **X3** | Close PR #125 as superseded and re-drive the sync after the fix lands. | Cleanest end state, but the brief forbids touching PR #125 and it is the evidence base. Named for completeness; not proposed. |

**What X2 requires of Phase 4/5, stated so it is not discovered late.** `AC-VENDOR-1`, `AC-VENDOR-3`,
`AC-ALLOWLIST-1/2` and `AC-RELEASE-1` are **not verifiable on the v2.19.16 PR** — that branch has no
drift, no orphans and no lock removals, so those checks pass *vacuously*. They must be observed on a
fixture branch built from PR #125's tree with this cycle's fixes applied. **A green v2.19.16 PR is not
evidence for any of those five ACs**, and @qa should refuse it as such. This is the same
check-that-cannot-fail shape the repo has caught four times; it is pre-empted here rather than found
at Phase 5.

**Security note on the fixture branch, owed to @security at Phase 2.** Building it means placing
PR #125's 150-entry lock and a re-vendored 150-file tree on a branch of this repository. That is
third-party content ingestion on a branch — strictly less exposure than merging PR #125 (no path to
`main`, no release archive, `main` protection untouched), but it is not zero, and it is a *write* to
the remote. It is named here rather than assumed benign.

---

## §C — Technical design, item by item

> *ISO 15288 — Technical: Design Definition Process.*

### §C.0 — Settled facts, re-derived (not adopted)

| fact | spec value | re-derived here | method |
|---|---|---|---|
| head lock `files[]` | 150 | **150** | Contents API @ `c43d56f` |
| disk files (excl. LICENSE) | 108 | **108** | the job's own `find` expression |
| common | 106 | **106** | `comm -12` |
| MISSING | 44 | **44** | `comm -23 head-lock disk` |
| ORPHAN | 2 | **2** | `comm -13 head-lock disk` — and they are exactly the two renamed files |
| MISMATCH | 15 | **15** | local strip-and-hash over the 106 common paths, GNU-compatible `sed '1{/^$/d;}'` |
| threat-detection rename | byte-identical | **byte-identical** — `83bfaabe485d…` on both sides | raw fetch at both pins |
| security-engineer → architect | content changed | **changed** — `d6ce02769f3d…` → `b1a68e9614f7…` | raw fetch at both pins |
| old paths at new pin | renamed away | **HTTP 404** both; firing control `engineering-backend-architect.md` → **200** | Contents/raw |
| MOVED can fire today? | no | **no** — neither old hash appears anywhere in the head lock; firing control on a hash that *is* present returns its path | `jq` membership over `files[].content_sha256` |
| `security/` paths in head lock | 0 | **0** | `jq` |
| collaborators | 1 | **1** (`jmlozano1990`) | `gh api …/collaborators` |
| `main` protection | unchanged | `required_status_checks` **ABSENT**, `enforce_admins: true`, `required_approving_review_count: 0`, `require_code_owner_reviews: false`, force-push/deletion `false`, **0 rulesets** | `gh api …/branches/main/protection`, `…/rulesets` |
| PR #125 | OPEN | **OPEN**, head `c43d56f…`, `mergeable: true`, labels `agency-sync` + `security-review-required` | `gh api …/pulls/125` |

One fact the spec left open is now closed and it matters for §C.4: **upstream HEAD *is* the lock's
pin.** `compare/3c958888...main` → `status: identical`, `ahead_by: 0`, `behind_by: 0`. There is no
upstream headroom ahead of the lock, so the original fixture design — pin the ratchet *ahead* of the
lock to simulate an advance — has **zero remaining room** at this moment, not merely a stale value.

### §C.1 — Item 1: the vendoring-automation gap (D1)

#### §C.1.1 The cardinality assertion must change under every D1 alternative

Independent of which D1 alternative the owner picks, `quality.yml:2363-2375` must stop pinning `108`,
because §0.1 and §B make no constant valid. Recommended replacement — **relative, not absolute**:

```bash
LOCK_COUNT=$(jq '.files | length' cowork.lock.json)
DISK_COUNT=$(find vendored/agency-agents ! -name LICENSE \( -type f -o -type l \) | wc -l | tr -d ' ')
VENDORED_FLOOR=108          # ratchets upward only; never re-pinned downward
if [ "$LOCK_COUNT" -ne "$DISK_COUNT" ]; then ... FAIL ... fi
if [ "$LOCK_COUNT" -lt "$VENDORED_FLOOR" ]; then ... FAIL ... fi
```

Why this preserves the protection rather than weakening it, argued from the step's own comment:

- The step's stated soundness role is the **third leg** of ADR-080 (forward + orphan + count). Forward
  proves lock ⊆ disk, orphan proves disk ⊆ lock; together they already prove set equality, hence count
  equality. The **equality** assertion is therefore a fast, self-diagnosing restatement — it cannot be
  weaker than what already holds.
- The step's comment says the exact pin's real value is as a tripwire on re-introduction, and that
  *"AC-B5-4's per-path assertions are what survive that."* **AC-B5-4 is untouched.** The four per-path
  sub-assertions for both v2.19.7 removals stay exactly as written.
- A **floor** is the correct shape for a corpus that only grows by decision: it fails closed on any
  shrink (which is what a silent deletion looks like) while not rotting on every legitimate addition.
  A shrink below the floor is precisely the event the exact pin was catching.

**Required controls (both, not either):**
- *Negative:* a fixture where `DISK_COUNT ≠ LOCK_COUNT` (delete one vendored file) → step goes RED and
  names both numbers.
- *Negative:* a fixture where `LOCK_COUNT = 107` → RED on the floor.
- *Positive:* the real 150-entry lock + 150-file tree → PASS. And the real 108/108 `main` tree → PASS.
  Both sides of the boundary, per the spec's own Edge Case 1.

**Alternative the owner may prefer:** keep the exact pin and bump it to `150`, accepting that it must
be bumped by hand in every future sync PR. That is the status quo's failure mode, and it is what makes
`vendored-integrity-check` red on arrival every month. Recorded, not recommended.

#### §C.1.2 D1 alternatives, all three made implementable

**D1(a) — keep vendoring manual.** Implementable, and the spec's claim that `AC-VENDOR-3` is
unsatisfiable under it is **VERIFIED**. The mechanism is stronger than the spec states. There is no
step between the lock bump and the check under (a): `sync-agency.yml` rewrites `files[]` at `:507-539`
and never writes to `vendored/agency-agents/` — confirmed, the only two occurrences of that path in the
704-line workflow are inside PR-body markdown (`:630`, `:631`), not executed steps. `dispatch-quality`
then dispatches `quality.yml` against the sync branch immediately. So the check runs on a tree that is
inconsistent *by construction*, with no human able to intervene first. `AC-VENDOR-3`'s bar — "no human
step between the pin bump and the check" — is not merely unmet under (a); it is **definitionally
excluded**, because the human step *is* the mechanism.

Under (a) the cycle must also accept that **`AC-VENDOR-1` requires two manual acts per sync**, not one:
run `vendor-agency.sh`, *and* hand-bump the cardinality pin (or adopt §C.1.1's relative form, which is
recommended under (a) too). Item 1 is recorded as an open carry-forward, not done.

**D1(b) — fold vendoring into `sync-agency.yml`.** Two new steps after *"Update cowork.lock.json"*
(`:539`) and before *"Regenerate THIRD-PARTY-NOTICES.md"* (`:541`), both gated on
`steps.check.outputs.needs_update == 'true'`:

```yaml
      - name: Materialize vendored/agency-agents/ from the new lock (ADR-080 leg 1)
        if: steps.check.outputs.needs_update == 'true'
        run: bash scripts/vendor-agency.sh

      - name: Prune vendored files the new lock no longer carries (ADR-080 leg 2)
        if: steps.check.outputs.needs_update == 'true'
        run: bash scripts/vendor-prune.sh        # see §C.2.3
```

Three properties, each checked rather than assumed:

1. **No new code for the write path.** `scripts/vendor-agency.sh` is invoked unchanged. It already
   fetches at the lock's pin, verifies each file's SHA-256 against `content_sha256` fail-closed,
   injects the ADR-024 block, and runs a round-trip strip assertion proving the written file will pass
   `vendored-integrity-check`. That last assertion is why this is low-risk: the script refuses to write
   a file that would redden CI.
2. **No self-referential trigger loop** (spec Edge Case 4). The commit is authored by
   `peter-evans/create-pull-request` with `GITHUB_TOKEN`; GitHub does not raise workflow runs from
   `GITHUB_TOKEN` events, which is the documented fact ADR-099 established and built `dispatch-quality`
   around. Adding files to that same commit changes nothing about the trigger. The `[ESTIMATED]`
   assumption in the spec is hereby **confirmed**, not left estimated.
3. **Network cost is unchanged, and could be halved.** The sync job already fetches every allowlisted
   file to `/tmp/fetched-files/${category}/${filename}` (`:278`) and hashes it (`:287`) — the same bytes
   `vendor-agency.sh` re-fetches. A variant (b2) would vendor from `/tmp/fetched-files` and skip the
   second fetch. **Not recommended:** the second fetch is an independent re-acquisition of the same
   bytes, and comparing two independently-fetched copies against one stored hash is a real
   cross-check. (b2) would collapse it to a single fetch. Recorded as a rejected optimisation with its
   reason, so a later cycle does not "discover" it as free.

Cost, stated honestly: `vendor-agency.sh` stamps the **global** `Pinned commit:` into every file's
header (`:91`) and the pinned license URL (`:95`), so every monthly PR diff carries the full corpus —
150 files today. A reviewer cannot read "what changed" from the diff.

**D1(c) — fold vendoring in, after redesigning the attribution header. FEASIBLE, and the stated
obstacle is falsified.** The brief and the spec both hold that this "changes the exact byte layout
`vendor-agency.sh`'s own round-trip hash-verification depends on." Measured, it does not.

#### §C.1.3 The D1(c) obstacle, tested rather than reasoned about

`vendor-agency.sh:106` and `quality.yml:2308` both strip with:

```
sed "1,/^${END_MARK}$/d" "$file" | sed '1{/^$/d}' | sha256sum
```

This deletes **line 1 through the first line matching the END marker**, then one leading blank line.
It is anchored on a *delimiter*, not on the header's interior byte layout. Proven on a copy outside the
repo — the null and a mutated copy with `Pinned commit:` and `Upstream path:` rewritten (5-byte size
delta, `cmp` confirms the files differ):

```
stripped(null)    = 3130768958d3b3d38178aaec91cf789e01ecca4984c8674d4aaea446b6cba240
stripped(mutated) = 3130768958d3b3d38178aaec91cf789e01ecca4984c8674d4aaea446b6cba240
lock(main)        = 3130768958d3b3d38178aaec91cf789e01ecca4984c8674d4aaea446b6cba240
```

**Identical.** The header interior is not part of the integrity hash. D1(c) is therefore not blocked by
hashing at all. Its two constraints are elsewhere, and both are tractable:

1. **ADR-024's 6-field contract.** `quality.yml`'s `attribution-survives-render` job asserts the six
   field names, `"Pinned commit:"` among them (`:1911`). Removing that field needs an ADR-024
   amendment. **Design that avoids the amendment being a loss:** replace the global
   `Pinned commit: ${PINNED}` with the per-file `Content SHA-256: ${stored_hash}` and point
   `Full license:` at the vendored, hash-verified `vendored/agency-agents/LICENSE` instead of a
   pin-scoped URL. The block stays six fields, provenance stays per-file and becomes *more* precise,
   and the corpus-level pin remains recorded in `cowork.lock.json` (`pinned_commit_sha`) and
   `THIRD-PARTY-NOTICES.md:22`, which already carries it and is already regenerated per sync.
2. **A compliance question, not an engineering one.** Whether an attribution block may reference the
   upstream commit indirectly (via the lock and NOTICES) rather than inline is an attribution-adequacy
   judgement. It is small, but it is not @architect's call. **This is why D1(c) is presented as
   feasible-with-a-gate rather than simply recommended.**

One observation recorded in passing, out of scope: `attribution-survives-render` validates a sample it
writes itself at `quality.yml:1834-1864`, never the real vendored corpus. It is a check that cannot
fail for the files it is named after. Booked as a residual (§F).

**Diff-size effect of (c), measured on this sync rather than asserted:** under (b) the PR diff is
**150** files; under (c) it is the 44 additions plus the 15 content changes = **59**, and in a typical
month with no additions it is the changed files alone. That is the whole argument for (c), and it is
worth about two-thirds of the diff on this sync.

#### §C.1.4 Recommendation

**D1(c), gated on a compliance sign-off of the revised attribution block; D1(b) as the fallback if
that sign-off is not obtainable inside this cycle.** Reasoning: (b) and (c) differ only in the header,
and (c)'s header change is a ~6-line edit to `vendor-agency.sh` whose hash risk is measured at zero.
The reviewability of every future supply-chain diff is a durable property; paying a small ADR amendment
once to get it is a good trade. **D1(a) is not recommended** — it leaves `vendored-integrity-check` red
on arrival for every future sync PR, which is precisely the condition that makes arming the gate
(v2.19.17) unsafe.

### §C.2 — Item 2: the allowlist-category gap (D2)

#### §C.2.1 What is confirmed

The rename asymmetry is real and hash-verified (§C.0). Its mechanical consequence is confirmed by
reading `verify-lock-removals.sh:153-158`: the MOVED test is
`printf '%s\n' "$HEAD_SHAS" | grep -qxF "$sha"` — pure content-hash membership **within the head
lock**, blind to filenames and blind to anything the sync never fetched. With `security` unallowlisted,
neither hash is in the head lock, so MOVED cannot fire for **either** file today. If `security` were
allowlisted and the sync re-driven, MOVED would fire for the threat-detection file (`83bfaabe…`
reappears under the new path) and **would not** for security-architect (`b1a68e96…` ≠ `d6ce0276…`).

The orphan claim is likewise confirmed by reading `verify-vendored-orphans.sh`: pure disk-path-string
membership against `files[].path`, no hash, no rename awareness; and `vendor-agency.sh` contains no
deletion primitive anywhere — it only ever `mkdir -p`s and writes. **Under every D2 alternative, the two
stale `engineering/` copies survive until something explicitly deletes them.**

#### §C.2.2 D2 alternatives, made implementable

**D2(b) — declare both old paths in `blocked_files[]` and delete the stale copies. Recommended.**

Two entries appended to `.cowork-allowlist.json` `blocked_files[]`, matching the existing schema:

```json
{
  "path": "engineering/engineering-security-engineer.md",
  "permanent": false,
  "reason": "Not a content rejection. Renamed upstream into security/security-architect.md (verified: old path HTTP 404 at pin 3c958888, content changed d6ce0276→b1a68e96 — the persona's scope was narrowed and a sibling AppSec Engineer persona created upstream). The security/ category has never been allowlisted, so the sync cannot follow the rename. Declared here as a DECISION taken at v2.19.16: this repo declines to onboard a 12-file, largely unreviewed upstream category under a 2026-09-01 cron deadline. Onboarding security/ is a separate, properly-scoped cycle. permanent:false records that this is a deferral with a named owner decision behind it, not a permanent rejection on the merits."
}
```

…and the same shape for `engineering/engineering-threat-detection-engineer.md` (→
`security/security-threat-detection-engineer.md`, **byte-identical**, `83bfaabe…` both sides).

**This answers the spec's own objection to (b).** The spec says (b) *"mislabels a mechanical/convenience
outcome as a deliberate block."* It is not mechanical. Declining to ingest twelve unreviewed
third-party persona documents two days before a cron fires **is a deliberate decision**, and the
`reason` string above says exactly that. What would be a mislabel is a `reason` reading "removed
upstream" — which is false — or `permanent: true`, which would be a rejection on merits that nobody
made. `permanent: false` is the honest field value and no reader is consuming it as anything else.

Two mechanical points checked so the entries are not over- or under-built:

- **No `blocked_patterns` entries.** ADR-080 Decision 1 requires *both* lists for **permanent
  removals**. These are not permanent removals. A basename `blocked_patterns` entry would block
  `security-threat-detection-engineer.md` from ever being fetched *even after* `security/` is
  allowlisted — it would sabotage the very follow-up cycle this defers to. Verified safe to omit:
  `verify-lock-removals.sh` reads only `.blocked_files[].path`, and `AC-B5-4`'s `blocked_patterns`
  coverage assertion is scoped to the two v2.19.7 paths by name, not to all `blocked_files`.
- **`blocked_files` may only grow.** `verify-lock-removals.sh:170-180` fails closed if any base
  `blocked_files[].path` is absent from head. Adding two entries is a grow, so the shrink assertion is
  satisfied trivially — and the follow-up cycle that onboards `security/` will have to *keep* these
  entries or consciously argue past that guard. That is the ledger working as designed.

**D2(a) — allowlist `security`.** Implementable, and the design does not obstruct it, but its cost is
the highest and its completion is the least contained: 12 files ingested (10 never reviewed here), a
mandatory content scan under `AC-ALLOWLIST-3`, a re-driven sync (so a fixture branch, not a corrective
push), an *additional* `blocked_files[]` entry or manual sign-off for `security-architect.md`
specifically because its hash changed, **and** the same explicit deletion of the two stale copies.
D2(a) does not remove any step; it adds three.

**D2(c) — extend the MOVED classifier.** Implementable as a compare-API-confirmed rename branch in
`verify-lock-removals.sh`, and it would clear both files uniformly. It is also a **Tier A edit to the
guard that exists to stop content leaving silently**, and it introduces a network dependency into a
script that is currently pure-local and offline. `AC-ALLOWLIST-4`'s positive control becomes mandatory.
The deeper objection is that it generalises: it would make *every* future rename into any
un-onboarded category a non-event, starting with the security personas. That is the ADR-080 invariant
being traded away for convenience.

#### §C.2.3 The deletion step, which every alternative needs

New script `scripts/vendor-prune.sh` — the disk→lock direction `vendor-agency.sh` structurally lacks:

```bash
set -euo pipefail
LOCK=cowork.lock.json; ROOT=vendored/agency-agents
LOCK_PATHS="$(jq -r '.files[].path' "$LOCK")"
LOCK_N=$(jq '.files | length' "$LOCK")
[ "$LOCK_N" -gt 0 ] || { echo "::error::vendor-prune: lock has 0 files[] — refusing to prune."; exit 1; }
PRUNED=0
while IFS= read -r vfile; do
  rel="${vfile#"${ROOT}"/}"
  printf '%s\n' "$LOCK_PATHS" | grep -qxF "$rel" && continue
  rm -f -- "$vfile"; PRUNED=$((PRUNED+1)); echo "vendor-prune: removed orphan ${vfile}"
done < <(find "$ROOT" ! -name LICENSE \( -type f -o -type l \))
echo "vendor-prune: ${PRUNED} orphan(s) removed."
```

Safety properties, each deliberate: the zero-lock refusal makes "empty lock deletes the corpus"
unreachable — the exact vacuity failure this repo's guards are built against; `find` is rooted at
`$ROOT` so nothing outside the vendored tree is reachable; `LICENSE` is excluded by the same expression
the two existing checks use, so the three cannot silently disagree; `rm -f --` terminates option
parsing.

**Controls required (both):** *negative* — a fixture tree with one orphan → exactly 1 removed, exit 0,
and `verify-vendored-orphans.sh` subsequently passes; *positive* — a fixture where lock and disk agree
→ **0** removed and every file still present. A prune that deleted everything would satisfy the
negative alone. And a third, non-obvious one: *refusal* — a lock with `files: []` → exit 1, **0**
files removed.

**Placement is an owner-visible consequence of D1.** Under D1(b)/(c) the prune runs inside
`sync-agency.yml`, so every future sync PR arrives with orphans already gone and `AC-ALLOWLIST-2`'s
sub-step becomes automatic. Under D1(a) it is a manual step beside `vendor-agency.sh`, i.e. one more
thing to forget. **This is a real coupling between D1 and D2 that the spec's "execution-independent"
finding does not capture** — the finding is correct about the *failure signals* and incomplete about
the *remedies*.

#### §C.2.4 Recommendation

**D2(b), with `security/` onboarding booked as its own cycle.** It is the only alternative that
completes in one corrective push, exposes no new third-party content under a two-day deadline, and
leaves the ADR-080 invariant exactly as strong as it is today. D2(a) is the right *eventual* answer and
should not be lost — it is registered as a residual with a named trigger (§F).

### §C.3 — Item 3: settle `AC-PUB-14` by observation (H2)

**The design here is the observation, not a fix. The three branches are preserved verbatim.**

The mechanism is now fully traced, which sharpens the prediction without replacing it.
`publish-release.sh` runs `set -euo pipefail`. Step 2 (`:301`) invokes `verify-vendored-orphans.sh`
unconditionally and exits 1 on failure — *before* step 5's version-mismatch guard at `:385`. The
`AC-PUB-14` step (`quality.yml:2946-2968`) runs `publish-release.sh 1.0.0` under a `gh` shim and makes
three assertions in order: `RC ≠ 127`, `RC = 1`, and `grep -qF "refusing to CREATE tag"` in the output.
With 2 orphans present the run exits **1** at step 2 — satisfying the first two assertions — and the
output says *"refusing to build a release archive"*, so the **third** assertion fires. That is
character-for-character the observed error.

**Differential evidence that this is downstream, not an independent defect:** the same job is green on
`main` today (0 orphans, 108/108) and red only on PR #125's head. The only variable between them is the
lock/orphan state.

**Why it stays a hypothesis anyway.** `AC-PUB-14`'s own assertion body — that step 5 fires and says
*"refusing to CREATE tag"* — has never executed in any observed run. Prediction is not observation, and
this repo has been wrong about exactly this shape before.

**The observation, designed:**

1. **`AC-SEQ-2` precondition, observed first.** On the fixture commit, record
   `verify-vendored-orphans.sh` exit **0** and the commit SHA, from the `vendored-integrity-check`
   job's own step-2 log — not from a local run, and not inferred from the job's overall conclusion.
2. **Then** re-run `Release Predicate + Standing Gate Check` and record the outcome as **exactly one**
   of the three named branches, naming the failing line/step, not just the conclusion:
   - **(a)** reaches and passes the step-5 assertion → Item 2's fix was sufficient; `AC-PUB-14` needs no
     change.
   - **(b)** fails at or beyond `publish-release.sh:385` → a new, previously-unobserved defect in the
     version-mismatch guard; filed and triaged as a fresh finding.
   - **(c)** fails again at `publish-release.sh:302` → **Item 2 is not complete on the tested commit**;
     `AC-SEQ-2`'s precondition was not actually met and the cycle returns to Item 2.
3. Only (a) or (b) close Item 3. **(c) must not be recorded as (b).** The distinguishing artefact is the
   *line number in the output*, which is why step 2 above requires it be named.

**No code change is designed for `AC-PUB-14`.** If branch (a) holds, none is needed. Designing one now
would be building a fix for a defect not yet shown to exist.

### §C.4 — Item 4: the ratchet fixture

#### §C.4.1 The selected pair, verified against both locks

**`RATCHET_SHA = 0e22704ebe3f1543790cf7b9a4dfb0b83ca43705`** (2026-03-05, *"Preserve existing tools
field alongside new color field"*)

**`RATCHET_PATHS =`**
- `marketing/marketing-content-creator.md` ← remains the poisoned path
- `design/design-ui-designer.md` ← replaces `academic/academic-anthropologist.md`
- `engineering/engineering-backend-architect.md` ← replaces `academic/academic-historian.md`

Verification, run this session against **both** lock states:

| path | content @ `0e22704e` | `main` lock (108 @ `783f6a72`) | PR-head lock (150 @ `3c958888`) |
|---|---|---|---|
| `marketing/marketing-content-creator.md` | `6a638eb61e7d467d…` | `676c536de09bd371…` **differs** | `26ddce44f057068a…` **differs** |
| `design/design-ui-designer.md` | `4f3a807d5edcf7d8…` | `3130768958d3b3d3…` **differs** | `3130768958d3b3d3…` **differs** |
| `engineering/engineering-backend-architect.md` | `84ef72f7ea7e9c56…` | `15f9e1361f63a555…` **differs** | `18f237d054fa91f7…` **differs** |

All three differ from both locks, so **any** of the three can be the poisoned path — that is deliberate
headroom, not redundancy. All three resolve HTTP 200 at `0e22704e`, and all three are present in
**both** locks, which satisfies `AC-RATCHET-2`'s vacuity guard (`jq -r` cannot yield `null`). Selection
method: intersect the upstream tree at `0e22704e` (74 `.md` blobs) with both lock path-sets → **42**
candidates; three chosen to span three categories.

#### §C.4.2 Does it rot again? No — and the reason is the inversion the previous pin got wrong

The previous pair rotted for a specific, now-diagnosable reason: `RATCHET_SHA = c89557f7` (2026-07-30)
was chosen **ahead** of the then-current lock pin `783f6a72` (2026-04-12), to simulate an upstream
advance. A pin ahead of a monotonically advancing lock **is guaranteed to be caught up to**. It rotted
on its first live exercise, one cycle after introduction, and it will rot again on any future re-pin
that repeats the choice — this is why the spec's own instinct to "pick a different SHA still behind the
live lock's pin" (the job's error text) is right and its instruction to pick a *newer* one would be
wrong. It also has zero room today: upstream HEAD **is** the lock's pin (§C.0).

`0e22704e` is 2026-03-05 — **behind** every lock this repo will ever hold, and behind by a content
change that has already happened. The guard requires only *difference*, and an ancient content state
can be re-collided only if upstream restores a file to its exact 2026-03-05 bytes. **The rot condition
is therefore an upstream byte-exact revert of one specific file, not the passage of time.**

**Honest cost of the inversion:** Leg 3's name says *"proves RED survives an advance."* With the pin
behind the lock, what it proves is *"RED survives a divergence"* — mechanically identical, because
`verify-lock-content-sha.sh:71` is a plain string comparison of stored vs fetched hash and has no
notion of direction. The step name and comment **must be corrected to say so**; leaving a name that
asserts a property the fixture no longer has is the doc-truth defect class ADR-083 exists to forbid.

#### §C.4.3 The rejected alternative, and why

**(4-B) — synthetic poison.** Replace `OLD_HASH` (read from the checked-out lock) with a value derived
to differ from the produced hash by construction. This is *absolutely* rot-immune, needs no
`RATCHET_SHA` change at all, and loses nothing in discriminating power: the verifier does a string
compare, so a synthetic wrong hash catches a skip-branch implementation exactly as a real stale hash
does.

**Not selected**, for one reason that outweighs its elegance: it is a **guard-logic edit inside a Tier-A
fixture whose entire job is to prove a verifier fails closed**, and it retires the v2.19.5 pre-poison
tripwire in the same stroke. (4-A) achieves a rot-resistance that is empirically strong by moving
**four literal values and zero lines of logic**. Under Tier A, changing data beats changing the guard.
(4-B) is recorded as the §Maturation Path option if (4-A) ever rots.

### §C.5 — Item 5: the cardinality zero-row false-pass

**Root cause confirmed exactly as specified.** `quality.yml:562`:
`DATA_ROWS=$(grep -cE '\| (builtin|https?://)' curated-skills-registry.md || echo 0)`. `grep -c` prints
`0` **and** exits 1, so `|| echo 0` fires *in addition to* the printed `0`, producing the two-line value
`"0\n0"`. `[ "0\n0" -lt 18 ]` errors at runtime, and `set -e` does not abort on a failing `if`
**condition**, so control falls through to the pass branch at `:568`.

**Fix — the house standard, already established in this file:**

```bash
DATA_ROWS=$(grep -cE '\| (builtin|https?://)' curated-skills-registry.md || true)
```

This is not a new invention. `quality.yml:2009-2013` records ADR-099 AMEND-1 making exactly this change
for the same reason one cycle ago, and **7 sibling `$(grep -c …)` sites already use `|| true`**
(`:287`, `:324`, `:725`, `:1536`, `:1601`, `:1627`, `:1648`). Line 562 is the one that was missed.
`|| true` is correct because `grep -c` prints its own `0`; the substitution yields exactly `0` and the
numeric test works.

**Controls, both mandatory per `AC-CARD-2`/`AC-CARD-3`:**

| control | fixture | required result |
|---|---|---|
| negative (zero) | registry fixture with 0 matching rows | step **RED**, message names `0` |
| negative (boundary) | fixture with exactly **17** matching rows | step **RED** |
| positive (boundary) | fixture with exactly **18** rows | step **PASS** |
| positive (real) | real `curated-skills-registry.md`, count re-derived at fix time with `/usr/bin/grep -cE` and **exit status checked** | step **PASS** |

The positive controls are what stop a guard hardcoded to `exit 1` from satisfying this item — the
mirror-image of the defect being fixed.

#### §C.5.1 Audit of the rest of `quality.yml` — with a firing control, because the first instrument could not fire

**Result: exactly ONE live instance repo-wide. `quality.yml:562`. No other occurrence exists, so no
owner scope call is needed.**

The instrument and its control:

```
NULL    (real quality.yml + scripts/ + tests/, non-comment lines):   1   -> .github/workflows/quality.yml:562
CONTROL (identical instrument over a mutated COPY with one extra
         `$(grep -cE ... || echo 0)` appended, outside the repo):    2
```

The control fires (+1 on injection), so a second live instance would have been seen.

**The first instrument I wrote could not fire, and the control is the only reason that is known.** It
was `\$\((/usr/bin/)?grep -[a-zA-Z]*c[^)]*\|\|[[:space:]]*echo`, which returned **0** against a file
containing the defect on line 562 — because `[^)]*` stops at the `)` inside the pattern
`(builtin|https?://)`. A tally of 0 from that regex would have been reported as "no other instances"
and would have been true by accident. Recorded because it is the cycle's own instance of the rule it
is fixing: *a zero needs a control that varies the property the null turns on.*

Scope of the audit, stated so its limits are visible: `.github/`, `scripts/`, `tests/`; the pattern is
`grep -c` on the same line as `|| echo`, excluding comment lines. Three further `|| echo` matches exist
in `quality.yml` at `:2009`, `:2010` and `:2448` — all **comments** describing this defect class, and
`:2448` documents ADR-080's related prohibition on `git show … || echo '{}'`. None is executable.

### §C.6 — Item 6: the approval-rule text (D3)

**Four assertion sites, not three, plus one false enforcement claim** — see §0.3.

**D3(a) — correct the texts. Recommended.** Concretely:

| file:line | current | replacement |
|---|---|---|
| `CONTRIBUTING.md:358` | *"Agency-sync PRs require 2 separate maintainer approvals before merge."* | *"Agency-sync PRs require review by a maintainer before merge. This repository currently has one collaborator (`jmlozano1990`), so a 2-approval rule is not satisfiable; the supply-chain controls that actually gate these PRs are CI checks, which a sole maintainer can satisfy."* |
| `CONTRIBUTING.md:359-360` | *"This rule is enforced via CODEOWNERS (see `.github/CODEOWNERS`)."* | *"CODEOWNERS records ownership; it does not currently enforce approvals — `require_code_owner_reviews` is `false` and `required_approving_review_count` is `0` on `main` as of 2026-08-30."* |
| `.github/CODEOWNERS:4` | *"Supply-chain-critical files require 2 maintainer approvals."* | *"Supply-chain-critical files are owned by the maintainer below. Approval count is not enforced — see CONTRIBUTING.md §Agency-Sync PR Review."* |
| `.github/CODEOWNERS:5` | *"agency-sync PRs … MUST have 2 CODEOWNERS approvals"* | folded into the line above; the sentence is removed. |
| `.github/CODEOWNERS:10` | *"Supply-chain integrity files — 2 approvals required for all PRs touching these"* | *"Supply-chain integrity files — maintainer-owned; see CONTRIBUTING.md for what actually gates these PRs."* |

**Why (a) rather than (b), argued rather than asserted.** The rule has stood since v2.0 and has never
been satisfiable by anyone; v2.19.5 re-pointed CODEOWNERS to the sole maintainer and thereby *closed*
the only path by which it could ever have been true. Keeping the sentence with a dated
non-enforcement note (D3(b)) leaves a reader cross-referencing three documents to learn that a
security control they can read is inert — and this repo has already paid for that pattern once, in
`OT-7`'s self-congratulation about a trap that had merely moved. **A control that cannot fire should
be removed or repaired, not annotated.** D3(b) remains a legitimate owner choice if the intent is to
preserve the target for a future second maintainer; it is fully implementable as described in the spec.

**D3(c) does not survive design and is recorded as such.** Adding a second collaborator is an
organisational trust decision no pipeline agent can execute; it does not fit a 2026-09-01 deadline; and
it silently converts **19** sole-owned CODEOWNERS rows to a multi-maintainer trust model. It should be
struck from the menu as an *in-cycle* option rather than left as one the owner might pick and then find
unexecutable. It remains a valid strategic direction outside this cycle.

### §C.7 — Anti-pattern scan

| # | Anti-pattern | Finding |
|---|---|---|
| 1 | God class/module | None. `vendor-prune.sh` is ~12 lines, one responsibility. |
| 2 | Circular dependencies | None. `sync-agency.yml` → `vendor-agency.sh` → lock is acyclic; the dispatch chain to `quality.yml` is one-way. |
| 3 | Leaky abstraction | **One, pre-existing, and this cycle reduces it.** `AC-B5-1`'s `108` leaks a corpus-size fact into a guard that should express an invariant. §C.1.1 replaces it with the invariant. |
| 4 | Premature optimization | Avoided deliberately — the `/tmp/fetched-files` reuse (§C.1.2) is a real optimisation and is **rejected**, with its security reason recorded. |
| 5 | Over-engineering | Watched. Item 4's fix is data-only; Item 5's fix is one token. |
| 6 | Tight coupling | None introduced. |
| 7 | Missing separation of concerns | None. Prune is its own script, not folded into `vendor-agency.sh`, so the manual path can adopt it independently. |
| 8 | N+1 query | **Present and pre-existing** in `vendor-agency.sh` (one HTTP fetch per file, 150/run) and unchanged by this design. Not repaired: the per-file fetch is what makes per-file hash verification independent. Booked as a residual. |
| 9 | Destructive migration | **`vendor-prune.sh` deletes files** — the only destructive element in this cycle. Mitigations in §C.2.3 (zero-lock refusal, `find` rooted at the vendored tree, LICENSE excluded, three controls including a refusal control). Flagged explicitly for @security. |
| 10 | SoS interface discontinuity | N/A — single-project. |
| 11 | Cross-project tight coupling | None. |

---

## §D. File-by-File Implementation Plan

> *ISO 15288 — Technical: Design Definition Process.*

Rows marked **[D1]** / **[D2]** / **[D3]** are conditional on the owner's Phase-3 selection.

| # | File | Change | Owner-AC |
|---|---|---|---|
| 1 | `.github/workflows/quality.yml` | (i) `:562` `\|\| echo 0` → `\|\| true`. (ii) `:2363-2375` replace the `108` pin with the equality + floor form (§C.1.1); `AC-B5-4` untouched. (iii) `:2136` `RATCHET_SHA` → `0e22704e…`; `:2140-2144` `RATCHET_PATHS` → the verified triple; correct the Leg-3 step name/comment from "advance" to "divergence" (§C.4.2). | AC-CARD-1/2/3, AC-VENDOR-1, AC-RATCHET-1/2 |
| 2 | `.github/workflows/sync-agency.yml` | `:631` correct the false "no CI runs on a sync PR at all" sentence. **[D1 b/c]** add the two vendoring steps after `:539` (§C.1.2). | AC-VENDOR-4, AC-VENDOR-3 |
| 3 | `scripts/vendor-prune.sh` | **NEW.** Disk→lock prune with zero-lock refusal (§C.2.3). | AC-ALLOWLIST-2 |
| 4 | `.cowork-allowlist.json` | **[D2 b]** two `blocked_files[]` entries, `permanent: false`, with the reason strings in §C.2.2. **[D2 a]** instead: add `security` to `allowed_categories` + one entry for `security-architect.md`. | AC-ALLOWLIST-1 |
| 5 | `scripts/verify-lock-removals.sh` | **[D2 c] ONLY.** Compare-API rename branch. Not written under (a) or (b). | AC-ALLOWLIST-1, AC-ALLOWLIST-4 |
| 6 | `scripts/vendor-agency.sh` | **[D1 c] ONLY.** Replace `Pinned commit:` with `Content SHA-256:` and re-point `Full license:` at the vendored LICENSE (§C.1.3). Not written under (a) or (b). | AC-VENDOR-3 |
| 7 | `vendored/agency-agents/engineering/engineering-security-engineer.md` | **DELETE** (stale copy). Required under every D2 alternative. | AC-ALLOWLIST-2 |
| 8 | `vendored/agency-agents/engineering/engineering-threat-detection-engineer.md` | **DELETE** (stale copy). Required under every D2 alternative. | AC-ALLOWLIST-2 |
| 9 | `CONTRIBUTING.md` | **[D3 a]** rewrite `:358` and `:359-360` per §C.6. **[D3 b]** dated non-enforcement note instead. | AC-APPROVAL-1 |
| 10 | `.github/CODEOWNERS` | **[D3 a]** rewrite `:4`, `:5`, `:10` per §C.6. **[D3 b]** dated note instead. | AC-APPROVAL-1 |
| 11 | `tests/vendor-prune-firing-controls.md` | **NEW.** Records the three prune controls (negative / positive / refusal) with commands, outputs and dates. | AC-ALLOWLIST-2 |
| 12 | `tests/registry-cardinality-firing-controls.md` | **NEW.** Records the four cardinality controls (§C.5) with pre-fix and post-fix results. | AC-CARD-2, AC-CARD-3 |
| 13 | `docs/architecture.md` | ADR-100 body + ADR Index row. **[D1 c]** additionally an ADR-024 amendment record. | AC-VENDOR-2, AC-ALLOWLIST-3 |
| 14 | `docs/risk-register.md` | Row for the `security/` onboarding deferral under D2(b), with its trigger. | AC-ALLOWLIST-3 |
| 15 | `docs/internal/carry-forwards.md` | Residual rows from §F. | — |
| 16 | `CHANGELOG.md` | Release notes for v2.19.16. | release hygiene |
| 17 | `VERSION` | `2.19.15` → `2.19.16`. | release hygiene |
| 18 | `README.md` | Version badge `2.19.15` → `2.19.16`. | release hygiene |

**Already landed at Phase 1 by @architect (not @dev's work):** `docs/spec.md` (finalized v2.19.16
section + Architectural Modifications), `docs/design-v2.19.16.md` (this document). `docs/architecture.md`
is listed above because ADR-100 lands at Phase 1 and any D1(c) ADR-024 amendment lands at Phase 4 —
two separate appends to an append-only file, no conflict.

**Files explicitly NOT written:** `main` branch-protection settings (DoD #5); anything under
`.github/workflows/release-surface.yml`; PR #125; `docs/owner-tasks.md`.

**Design-doc convention note.** v2.19.14 and v2.19.15 shipped **no** `docs/design-*.md` — verified with
`git show --name-only` on `2bdd050` and `6e79711`; the last one is `docs/design-v2.19.13.md`. This
document restores the v2.19.13 convention because this cycle's decomposition is genuinely wrong in two
places (§0) and an ADR alone has no room to show the work. Likewise, this repo has **no**
`docs/ADR-INDEX.md` and **no** `docs/DOCS-MAP.md` — never has, verified against full history — the ADR
index is the `## ADR Index` table inside `docs/architecture.md`, and that is where ADR-100's row goes.

```yaml
scope_allow_delta:
  # no-op: external project cycle. Recorded because ADR-115 requires the block's
  # presence (omission is a parse error), NOT because it grants anything here.
  add:
    - .github/workflows/quality.yml
    - .github/workflows/sync-agency.yml
    - .cowork-allowlist.json
    - scripts/vendor-prune.sh
    - scripts/vendor-agency.sh
    - scripts/verify-lock-removals.sh
    - vendored/agency-agents/engineering/engineering-security-engineer.md
    - vendored/agency-agents/engineering/engineering-threat-detection-engineer.md
    - tests/vendor-prune-firing-controls.md
    - tests/registry-cardinality-firing-controls.md
    - docs/architecture.md
    - docs/spec.md
    - docs/risk-register.md
    - docs/internal/carry-forwards.md
    - CONTRIBUTING.md
    - CHANGELOG.md
    - README.md
    - VERSION
  remove: []
```

**Why this block is a no-op, stated as a fact about the guard rather than a claim about jurisdiction.**
`scripts/guards/scope-check.sh:708-712` returns `exit 0` for any write inside `$ACTIVE_PROJECT_PATH`
when an external project is active, before the `scope_allow` patterns at `:714` are ever consulted. So
none of the 18 paths is evaluated against `.claude/agents/dev.md` at all. **BINDING, carried forward
from v2.19.13's §D and still true: do NOT widen The-Council's `dev.md` to "fix" a Phase-4 scope
refusal.** Those patterns are matched as unanchored substring regexes, so adding `docs/architecture.md`
or `README.md` there would grant @dev write access to **The-Council's own** files of the same name, not
scope a permission to this project. A Phase-4 scope refusal means the active-project pin broke; the
remedy is to restore the pin.

---

## §E — B1 verification

> *ISO 15288 — Technical Management: Decision Management Process.*

**B1 verification: PASS (by construction) @ 2026-08-30T18:13:40Z.**

`scripts/guards/scope-allow-verify.sh` cross-references §D plan files against
`.claude/agents/dev.md scope_allow.<scope>`. For this cycle that cross-reference is **structurally
inapplicable**, for the reason established in §D and read out of the guard rather than asserted:
`scope-check.sh:708-712` short-circuits every write inside the active external project's root before
any `scope_allow` pattern is consulted. There is no pattern set for the plan files to be missing from,
so there is no coverage gap the verifier could report — a PASS from it and this record carry the same
information.

The `scope_allow_delta:` block is present and well-formed (18 `add` entries, empty `remove`), every
entry carries a non-wildcard prefix (`.github/`, `scripts/`, `vendored/`, `tests/`, `docs/`, or a named
root file), and no entry is a bare wildcard. ADR-115's presence requirement is satisfied.

Recorded rather than glossed: this is a **PASS on an inapplicable check**, not a PASS on a check that
ran and found coverage. Stating it the other way would be exactly the "check that cannot fail" reported
as evidence, which this cycle spends §C.5.1 and §0.3 objecting to elsewhere.

---

## Classification Re-Run

*Mandatory per `docs/pipeline-policy.md` §PostOQClassificationReRun — required even when the answer is CONFIRMED. Fail closed if absent.*

**Result: CONFIRMED — SECURITY-SENSITIVE, Tier A. COMPLIANCE-SENSITIVE = NO, with one conditional flip named below.**

Re-evaluated against the **final** §D file list (18 rows), not the Phase-0 surface list.

**Rationale.** The final list still contains `.github/workflows/quality.yml` and
`.github/workflows/sync-agency.yml` — CI guard surfaces, and the latter is a third-party
content-ingestion path — plus `.cowork-allowlist.json` and (conditionally) `scripts/verify-lock-removals.sh`,
both explicitly tagged *"Classification context: SECURITY-SENSITIVE — Tier A (Guard Change Summary
required)"* in ADR-080's own header. Tier A is already this repository's highest ceremony tier, so no
upward flip is possible and no orchestrator halt is triggered.

**The file list GREW relative to Phase 0, and the additions raise the ceremony, not lower it.** Phase 0
named four surfaces (`vendored/agency-agents/`, `cowork.lock.json`, `.cowork-allowlist.json`,
`quality.yml`). Design added three of consequence:

1. **`scripts/vendor-prune.sh` (NEW) — the only file in this cycle that deletes.** A supply-chain writer
   gaining a deletion primitive is a genuine escalation within Tier A even though the tier does not
   move. §C.2.3's zero-lock refusal and three controls exist for this reason, and @security should
   treat it as the cycle's highest-risk artefact.
2. **Two vendored files are deleted outright** (`§D` rows 7-8) — third-party content leaving the
   corpus, which is precisely the event ADR-080 was built to make non-silent.
3. **`.github/workflows/sync-agency.yml` gains executed steps** under D1(b)/(c), where today it carries
   only markdown references to the vendored tree. That converts a documentation mention into a write
   into a third-party content tree on every cron.

**`cowork.lock.json` is NOT in the final file list** — the one surface Phase 0 named that design
removed, because X2 (§B) keeps the lock bump off this cycle's branch. That is a *reduction* in exposure
and is the single strongest argument for X2 over X1.

**COMPLIANCE-SENSITIVE = NO, conditionally.** No license obligation, no personal data, no new
dependency. **Two named conditions flip it to YES and must be re-run at the Phase-3 gate, not assumed:**
(i) if the owner selects **D1(c)**, the ADR-024 attribution-block format changes, which is an
attribution-adequacy question (§C.1.3) and owes an @compliance opinion; (ii) if the owner selects
**D2(a)**, 12 upstream `security/` files are ingested, which owes the `AC-ALLOWLIST-3` content scan and
an SPDX check. Under D1(a)/(b) + D2(b) + D3(a) — the recommended combination — it stays NO.

**Ceremony owed:** worktree branch (active) + PR + **one @security Guard Change Summary at Phase 2**,
mandatory under `AC-ALLOWLIST-3` regardless of which D2 alternative is selected, and additionally
covering `vendor-prune.sh`'s deletion primitive. Squash-merge only, after owner approval on the GCS.
Never fast-forward.

---

## §F — Residuals carried forward

> *ISO 15288 — Technical Management: Risk Management Process.*

| id | Residual | Severity | Disposition |
|---|---|---|---|
| `CF-v2.19.16-SECURITY-ONBOARD` | Upstream's `security/` category (**12** files at pin `3c958888`, enumerated in the spec's Settled facts) is never ingested under D2(b). Two of the twelve are personas this repo previously carried under `engineering/`. The category grew once since creation — `8237f99b` 2026-06-04 (created), `86a6695d` 2026-07-15 (+6, 2 of them security) — so it is neither frozen nor fast-moving. | MEDIUM | **Deferred by decision, named not silent.** Trigger: the next cycle after v2.19.17's arming session, or any upstream commit adding a 13th `security/` file. Requires the full `AC-ALLOWLIST-3` content scan. |
| `CF-v2.19.16-ATTRIB-SAMPLE` | `quality.yml`'s `attribution-survives-render` job asserts the six ADR-024 fields against a sample it writes itself at `:1834-1864`, never against the real vendored corpus. It is green regardless of what the 108 (or 150) shipped files actually contain. | MEDIUM | Named, not scheduled. Out of this cycle's scope; would be closed naturally by a D1(c) follow-up that has to touch the field list anyway. |
| `CF-v2.19.16-VENDOR-NPLUS1` | `vendor-agency.sh` performs one HTTP fetch per lock entry (150/run today, growing monthly) while `sync-agency.yml` has already fetched identical bytes to `/tmp/fetched-files/`. | LOW | **Deliberately not repaired** (§C.1.2). The duplication buys an independent re-acquisition of the same bytes. Revisit only if fetch cost becomes a real constraint, and only with the loss of independence stated. |
| `CF-v2.19.16-RATCHET-STRUCTURAL` | Leg 3(c)'s fixture is still a hardcoded pair. §C.4.2 makes rot conditional on an upstream byte-exact revert rather than on time, but the pair is still data a human must re-derive if that ever happens. | LOW | Retirement path = ADR-100 §Maturation Path option (a), the synthetic poison (4-B). Trigger: the fixture-setup guard firing again. |
| `CF-v2.19.16-FIXTURE-BRANCH` | Five ACs (`AC-VENDOR-1`, `-3`, `AC-ALLOWLIST-1`, `-2`, `AC-RELEASE-1`) are unverifiable on this cycle's own PR and require a fixture branch carrying PR #125's lock state (§B). | **HIGH** | **Binding on Phase 4/5, not deferred.** A green v2.19.16 PR is not evidence for any of the five. @qa must reject a claim that cites the wrong branch. |
| `CF-v2.19.16-BSDSED` | The integrity strip is GNU-sed syntax; on macOS it silently produces the empty-string hash for every file (§A.1). Anyone reproducing MISMATCH counts locally will get 106/106 and believe the corpus is destroyed. | LOW | Recorded here and in §A.1 so the next local reproduction does not lose an hour to it. |

---

## Closing note

Two of this cycle's six items were mis-scoped in a way that would have shipped red CI: `AC-VENDOR-1`
can be fully satisfied with the check it names still failing, and `AC-RATCHET-1`'s prescribed remedy is
unsatisfiable as written. Both were found by running the guards' own expressions against the real
artefacts on **both** commits this cycle touches, rather than against one. The single fact that
explains both — that this cycle causes CI to run on two different `cowork.lock.json` states, and that
three of its assertions read that state — appears in no prior document and is the thing most worth
carrying into Phase 2.

The third finding is smaller and more uncomfortable: the first instrument written here to audit
Item 5 returned zero against a file that contains the defect. It was caught by a control, not by
review. That is the cycle's own lesson applied to its own output, and it is why every count in this
document is paired with a control that was shown to fire.
