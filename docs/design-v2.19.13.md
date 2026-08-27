# Design — v2.19.13 "Citation Repair + Registry-Row Integrity"

> *ISO 15288 — Technical Management: Project Planning Process.*

**Cycle:** v2.19.13 · **Phase:** 1 (Design) · **Mode:** full
**Classification:** SECURITY-SENSITIVE — Tier A · COMPLIANCE-SENSITIVE = NO
**Worktree:** `/Users/macbookpro/claude-cowork-config/.worktrees/v2.19.13-citation-repair`
**Branch:** `release/v2.19.13-citation-repair` · **Base:** `9f6ddc2e60e443297b3f1e9bbc7f9e70852b7922`

**Evidence base for every number in this document.** All measurements were re-run by @architect
during Phase 1 against the **worktree** at `9f6ddc2` (`git -C <wt> status --porcelain` → 0 lines),
never against `/Users/macbookpro/claude-cowork-config` (the `main` checkout, which is a live
parallel-session surface). Binary: `/usr/bin/grep` = **BSD grep (GNU compatible) 2.6.0-FreeBSD**,
invoked by absolute path because the bare `grep` in this harness is a ugrep shim that under-counts.
Shell: `zsh`, with `/bin/bash` cross-checked explicitly wherever shell semantics were load-bearing.

**The standing rule this cycle produced, applied to this document's own inputs:**

> A number inherited from a reviewer is not verified until the recipient re-runs it.

Every number in `phase1-binding-conditions-v2.19.13.md` was **re-run, not adopted** — including the
numbers @architect itself wrote in Round 1 and Round 2. Three inherited numbers did not survive
re-measurement; they are recorded in §B.2 with the commands that falsified them.

---

## Table of contents

- §A — Phase 1 Design Header (mandatory records)
- §B — Binding-conditions disposition + defects found IN the conditions file
- §C — Technical design
- §D — File-by-File Implementation Plan + `scope_allow_delta`
- §E — B1 verification
- **Classification Re-Run** (mandatory gate record)
- §F — Residuals carried forward

---

---

## §A — Phase 1 Design Header (mandatory records)

> *ISO 15288 — Technical Management: Decision Management Process.*

### A.0 Worktree discipline

**Worktree discipline: ENFORCED (SECURITY-SENSITIVE / Tier A).**
First action executed before any read or write:
`git -C /Users/macbookpro/claude-cowork-config/.worktrees/v2.19.13-citation-repair rev-parse HEAD`
→ `9f6ddc2e60e443297b3f1e9bbc7f9e70852b7922`, matching the pinned base exactly.
`COUNCIL_EXPECTED_BASE_SHA` was **unset** in this spawn context (fail-open per F6), so the pinned
base from the spawn prompt was used as the comparand instead. Worktree tree state at Phase 1 start:
clean (`status --porcelain` → 0 lines).

**All measurements in this cycle were taken inside the worktree, never against
`/Users/macbookpro/claude-cowork-config`.** That path is `main` and is a live parallel-session
surface; asserting numbers against it would violate the moving-corpus discipline. This also matters
mechanically: the worktree is nested *inside* the main checkout, so a naive recursive grep run from
`main` would traverse `.worktrees/` and double every count. Verified the worktree contains no nested
`.worktrees/` directory, so it is a clean measurement surface.

### A.1 Production validation

**Production validation: N/A — no Council-registered-project repo-artifact parsing in this design.**
This cycle contains no logic that parses `pipeline.md`, `roadmap.md`, `registry.json`, `retro.md` or
any Council guard-read file, so the cross-project loop does not apply.

**The equivalent obligation for this cycle — running candidate logic against the REAL artifacts
rather than against fixtures — was discharged, and it changed the design.** The candidate whole-line
matcher was executed read-only against **every** guard-form citation in the repository (15 files,
22 file/anchor pairs), not only the 4 tuples in scope. Two facts surfaced that appear in no spec, no
review and no condition, and both are load-bearing:

1. **`.github/workflows/quality.yml` — the guard's own source — carries the citation form**, with the
   extracted "anchor" being its own uninterpolated variable. Any self-integrity count over the guard
   form must include it and must not self-exclude by accident.
2. **`docs/internal/security/security-review-v2.19.11.md` carries three historical security-test
   payloads in the citation form**, whose anchors are shell command-substitution and quote-breakout
   strings. They are legitimate Class-B records that must not be edited. This makes
   **glob-and-resolve unsafe on the current tree** and is now the primary recorded reason for
   explicit tuple enumeration — a stronger reason than the fixture-RED-leg argument that had been
   carried, which re-measurement also showed to be weaker than stated (those fixtures are
   unbackticked and invisible to the extraction regex).

A fixture-only validation would have surfaced neither.

### A.2 Reuse Radar (4-source lookup)

| # | Source | Result |
|---|---|---|
| 1 | `docs/reuse-registry.md` (Council) | Present. Grepped for `citation\|anchor\|sanitiz\|matcher\|heading\|log-injection\|tripwire` → 4 hits, **all Council-internal registry-parsing prose, zero component candidates.** |
| 2 | `examples/scaffolds/INDEX.md` (Council) | **Not present** — scaffold index not yet materialized. Recorded and skipped, not silently dropped. |
| 3 | `docs/constituent-systems.md` + `Reusability:` ADR tags | Present. Target repo's own ADR-090 is the direct predecessor and is **EXTENDED**, not rebuilt. |
| 4 | `.claude/projects/ecosystem/sos-interfaces.json` | Present. 0 matches for `cowork\|citation\|anchor` — no existing interface contract covers this capability. |

**Reuse Scan**

| Component | Registry hit | OSS candidate | Scaffold | Decision | Basis |
|---|---|---|---|---|---|
| Anchor-resolution matcher (inline shell) | none (grep pasted above) | n/a — `grep`/`awk` are already present, zero-dependency constraint forbids adding any | n/a | **EXTEND** | Extends ADR-090's existing inline guard. The zero-dependency / no-network constraint on this workflow forbids adding a dependency at all. |
| `ANCHOR_SAFE` sanitizer | none | n/a — same constraint | n/a | **BUILD** | No hit; ~6 lines of `tr`; adding a dependency is forbidden by the workflow's own constraint. Core to the security posture. |
| Citation-site tripwire | none | n/a | n/a | **REUSE (pattern)** | Reuses the in-repo `PARSER_COPIES` / `AC_PL_6_EXPECTED_HEX_ROWS` pinned-count shape verbatim. |
| W1 pipe-injection legs | none | n/a | n/a | **REUSE (pattern)** | Reuses the existing `pipe-sa`/`pipe-pg` runtime `awk` generator and `check_row()` shared function. **No new committed files** — these fixtures are generated into `mktemp -d` at CI time. |
| NC-5 + S15 control fixtures | none | n/a | n/a | **BUILD** | Two small committed files under `tests/`. Must be files, not shell one-liners — see §C.3. |

**Buy-vs-Build: 5 components scanned — REUSE 2 / ADOPT 0 / EXTEND 1 / BUILD 2**

No ADOPT rows, therefore: no dep-scan flag owed, no L1/L1b license gate owed, no `ATTRIBUTIONS.md`
row owed, no AC-D1.9 prompt-injection screen owed.

### A.3 EARS check

All 9 ACs (B0, S14, W1, CF-A, S5a, S5b, S11, S15, CF-B) were re-checked. **8 are Ubiquitous**
(falsifiable by absence); **AC-S5b is correctly Unwanted-behaviour**, being the one AC with a genuine
external runtime trigger rather than "the fix itself".

**EARS check: 0 HIGH-severity findings — no OQs generated.**

Two MEDIUM advisory findings from Round 2 were **resolved in this pass rather than carried**, because
both were testability defects rather than syntax defects: AC-S14 item 5 and AC-CF-A item 5 each placed
a non-behavioral obligation (a documentation carry-forward; a PR-authoring instruction) under a
behavioral Ubiquitous subject — a CI step cannot state a carry-forward. Both moved to Technical
Constraints. **EARS syntax 9/9 PASS; EARS testability 9/9 PASS** (was 6/8 at Round 2).

### A.4 SoS classification + UAF viewpoints

**N/A — single-project design.** The design touches exactly one registered project
(`claude-cowork-config`). The Council-side guard bundle is a *prerequisite to work around*, not a
constituent of this design, and no cross-project interface is created or modified.

| UAF viewpoint | Record |
|---|---|
| Operational | N/A — single-project design |
| Resources | N/A — single-project design |
| Services | N/A — single-project design |
| Personnel | N/A — single-project design |

One cross-repo note, recorded because it was mis-transferred once already: the Council's own
`docs/pipeline-policy.md §PostOQClassificationReRun` places `.github/workflows/` at **Tier B** in the
Council's *own* self-improvement governance. That rationale cites `security-sensitive-guard.yml`,
which **does not exist in this target repo**. It does not transfer, and it does not change this
cycle's verdict.

### A.5 Reliability analysis

**Reliability Analysis: N/A per NEVER-APPLY (no external API provider in any request path, no
failover or fallback mechanism, and no SLA or availability claim anywhere in the spec).**

### A.6 Heuristics check (Rechtin)

| Heuristic | Signal produced this cycle |
|---|---|
| *"In partitioning, choose the elements so that they are as independent as possible."* | **Fired.** S14 and S15 are NOT independent — same step, shared `$ANCHOR`, and S14 *creates* S15's population. Recorded as a binding Interference Constraint (combined edit). S14 × W1 **is** independent (different jobs) and is explicitly the safe pair. CF-A was wrongly folded into the combined set by the Round-2 draft; struck. |
| *"The choice between two architectures may well depend on which set of drawbacks can be handled better."* | **Fired, decisively.** Three matcher forms fail in three different directions — reddens-correct (noisy), greens-broken (silent), returns-0-on-correct (silent). Whole-line equality has none of the three. When one option's drawback is *silent* failure it is not a symmetric trade. |
| *"Build in and maintain options as long as possible."* | **Fired.** Recorded as ADR-092 §Maturation Path option (b) — a generated enumeration would dissolve the census gap — rather than forcing the choice now inside a 13th consecutive patch cycle. |
| *"A model is not reality."* | **Fired, and it is the cycle's core lesson.** Every defect generation came from reasoning about a command instead of running it. Discharged by re-running all 20 conditions; 4 were falsified. |
| *"Don't assume that the original statement of the problem is necessarily the best."* | **Not applicable — rationale:** scope was reviewed across 2 deliberation rounds and 6 reviews with **zero** scope defects found. Re-opening it at Phase 1 would be churn against a stable finding, and is an owner decision, not a Phase-1 one. |
| *"Simplify. Simplify. Simplify."* | **Fired as a constraint on the remedy.** Two proposed additions were kept (tripwire ~4 lines, `, rule 2` assertion ~3 lines) and the full census was **not** built, on cycle-size grounds. The tripwire's population was *scoped down* rather than the tripwire dropped. |

### A.7 Maturation Path self-grep (ADR-092)

Baseline before ADR-092 was appended, then after — worktree, `/usr/bin/grep` 2.6.0-FreeBSD:

```
**Future-state options:**         60 -> 61
**Concrete revisit triggers:**    60 -> 61
**Risk knowingly accepted:**      60 -> 61
```

Each header increased by **exactly 1**, confirming the section was COPIED from the template slot and
not paraphrased. Gate PASSES.

---

## §B — Binding-conditions disposition, and 4 defects found IN the conditions file

> *ISO 15288 — Technical: Stakeholder Needs and Requirements Definition Process.*

The full row-by-row disposition of all 20 conditions lives in the **Condition Ledger** appended to
`docs/spec.md` (that is the artifact @qa ticks). This section records only the four that **failed
re-measurement**, because each would have shipped a defect if implemented faithfully — which is this
project's binding failure mode, now in its 14th generation.

**Sixteen conditions reproduced exactly and are applied as written.** C1, C3, C7, C10, C12 and C17
were independently re-run and matched to the digit.

### B.1 — C13's pin of 16 REDs on this cycle's own correct tree

**Measured:** repo-wide guard-visible population = **15 files** (enumerated in §C.2). This cycle's
correct deliverables add **three**: `docs/design-v2.19.13.md` (this document — it must quote the
canonical anchor to specify the repair), the NC-5 prefix-truncation fixture, and the S15 injection
fixture. The latter two must carry the guard form or they cannot function.

A pin of 16 therefore fails on a **fully correct** v2.19.13 tree, and drifts again every subsequent
cycle as each adds a design doc.

**This is the same failure class C7 deleted the residue pin for**, six conditions later in the same
document — C7's own words: *"a pin that fails on a correct tree is the same failure class this cycle
exists to fix."* The conditions file deletes one unstable pin and mandates another.

**Resolution:** the tripwire's *purpose* is preserved exactly and its *denominator* is corrected.
Population scoped to exclude `docs/` and `tests/`; pin = **6** post-CF-A (measured 5 today). See
§C.2 for why this does not weaken the control.

### B.2 — C9's "at least 4 deferred" is wrong; the measured count is 3

A full census was run over all 23 repo-wide `Decision (3)` occurrences, with **C9's own stated
inclusion test** applied to each. Total mis-pointer loci = **6**; in scope = **3**; deferred = **3**.
Six minus three is three, which is also forced by C9's own two other figures ("census is at least 6",
"3 loci in").

The hedge is legitimate about *future* files. It is not legitimate as a lower bound on the current
tree, where the set is finite, enumerable, and was enumerated.

### B.3 — C15's and C20's remedies each break the control they repair

**C15** mandates a visible ellipsis-prefixed truncation marker inside a pipeline that C15 itself
identifies as locale-dependent. Pinned to `LC_ALL=C` — the only deterministic choice — that pipeline
**strips multibyte**, so the marker is damaged by the very step it is meant to annotate. Measured:
the ellipsis is deleted, leaving a bare `[truncated]`.
**A marker that can be silently damaged cannot signal silent damage.** ASCII-only mandated, and the
operation order (strip, collapse, truncate, mark) fixed so the marker is applied last.

**C20** mandates a colon-free marker so the GREEN leg cannot be satisfied by colon-stripping alone.
Correct in purpose — but a colon-free marker **survives sanitization by construction**. Measured, the
sanitized output still contains `INJECTED-MARKER-7f3a`. So the inherited single assertion ("marker
absent from stdout") could **never** go GREEN on a correct implementation. Applying C20 to that
assertion shape converts a weak control into a permanently failing one.
**Rebuilt as two legs** — see §C.3.

### B.4 — C4's tie-breaker, on a ships-agnostic rule, mandates rewriting history

*"Where an occurrence's role is genuinely ambiguous, it is Class A"* is correct and adopted. But B0's
role rule is explicitly file- and ships-agnostic, and this repository is full of **append-only
historical records** that quote citations ambiguously — `CHANGELOG.md`'s release note for the
`self-apply` behaviour is the clearest live example, and it is export-ignored, so ships-status offers
no exemption either.

Read literally: tie-breaker plus ships-agnostic rule equals a standing obligation to **edit**
`CHANGELOG.md`, `docs/retro.md`, and every historical security audit — which this repository's own
append-only discipline forbids.

**Resolution:** the tie-breaker keeps its fail-safe direction, and B0 item 1 gains the discharge rule
it always implied: **Class A is an obligation, not an edit method.** Inside an append-only record the
obligation is discharged by a superseding cross-reference appended below, or by a recorded deferral —
never in place. This is the mechanism B0 items 3 and 4 already use; the tie-breaker simply had to say
so before it could be safely general.

### B.5 — C1 stands, with one clarification that does not weaken it

C1 is **non-waivable and is applied unchanged.** Its central claim was reproduced independently: on a
truncated anchor, the prefix form returns 1 (guard passes — false green) and the whole-line form
returns 0 (guard fails — correct).

One clarification, recorded so a later reader does not over-read the evidence: C1's two *illustrative*
live instances — `.github/CODEOWNERS` and `.github/workflows/release-assets.yml` — are genuine broken
Class-A pointers, but **neither is in the guard-visible backticked form** (measured: guard-form count
is 0 for each), so neither could ever reach the matcher under *either* implementation. They
demonstrate that prefix-shaped broken pointers exist in the wild; they are **not** demonstrations of a
false-green inside the guard. **C1 does not depend on them** — the reachable in-scope case (a
half-done CF-A repair) was reproduced directly and is sufficient alone.

---

## §C — Technical design

> *ISO 15288 — Technical: Architecture Definition Process.*

### C.1 The resolution primitive

The guard today runs a hardcoded-h3, fixed-string **substring** count against the doc — **two**
defects in one line: the heading level is pinned to h3, and the match is substring rather than
whole-line. Both are replaced by a level-agnostic whole-line loop over h1 through h6, summing
`grep -cxF` (or `awk '$0 == s'`) per level.

Three forbidden alternatives and their failure directions are recorded in ADR-092 §Decision (1).
The design consequence that matters for @dev: **`N_HEADS` must be asserted equal to 1, never
"at least 1"**, and the sum is taken across all six levels so a heading's *depth* is irrelevant while
its *text* must match exactly.

### C.2 The tripwire and its scoped population

Measured guard-visible population (files carrying the backticked form), worktree at `9f6ddc2`:

| scope | count | files |
|---|---|---|
| repo-wide | **15** | includes 10 under `docs/` |
| **excluding `docs/` and `tests/`** | **5** | `.github/workflows/quality.yml`, `CHANGELOG.md`, `PROMOTE.md`, `scripts/canonicalize-scan.sh`, `skills/self-apply/SKILL.md` |
| **pin, post-CF-A** | **6** | plus `templates/skill-template/SKILL.md`, which enters the population only once CF-A backtick-wraps it |

**Why scoping does not weaken the control.** The tripwire's job is to detect a *new live pointer*
appearing. `docs/` occurrences are Class-B quotations inside historical records, and a new one is
authored every cycle by design; `tests/` fixtures are deliberately broken controls. Neither can host
a live Class-A pointer without violating a rule already stated elsewhere. The remaining surface —
workflows, scripts, skills, templates, ceremony files — is exactly where one would appear.

**Two implementation constraints:** the guard's own source file is inside the counted set and must not
be self-excluded by accident; and the tripwire **counts files only** — it must never extract, resolve,
or re-expand a discovered anchor (§C.4).

### C.3 The sanitizer and its two-legged control

Order is binding: **strip, collapse, truncate at 80, then mark.**

```
ANCHOR_SAFE="$(printf '%s' "$ANCHOR" | tr -d '%:' | LC_ALL=C tr -cd '[:print:]')"
```

`printf '%s'` never `printf "$ANCHOR"` — the value is contributor-controlled and may contain `%`, and
passing it as a *format string* is the identical bug class to the Round-1 fixture defect. `LC_ALL=C`
is pinned because the collapse is otherwise locale-dependent (measured: `C` deletes the section sign,
UTF-8 preserves it). The lossy marker is **ASCII-only** and applied last.

**The control has two legs and both are required:**

| Leg | Assertion | What it proves |
|---|---|---|
| **A** | stdout MUST NOT contain `%0A`, and MUST NOT contain `::error::INJECTED-MARKER-7f3a` | the injection shape is neutralized |
| **B** | stdout MUST contain `INJECTED-MARKER-7f3a` | the anchor was **sanitized, not dropped** — the substantive decision of AC-S15 |

Leg B is what makes a "just delete the variable" implementation fail. Without it, the cheapest way to
pass Leg A is to destroy the only diagnostic a human gets when the guard fires.

The payload lives in a **committed fixture file**, never a shell one-liner: measured, the naive
`printf` form errors out in zsh and silently eats the percent in bash (`%0A` consumed as the
hex-float conversion, yielding `0X0P+0`), so the control would exercise a payload with no percent
sign in it — the one property it exists to test.

### C.4 Never glob-and-resolve

`docs/internal/security/security-review-v2.19.11.md` records three historical security-test payloads
**in the guard-visible citation form**, whose anchors are shell command-substitution and
quote-breakout strings. They are legitimate Class-B records and must not be edited.

Consequences: the tuple list is **enumerated, never globbed**; the tripwire **counts only**; and any
tooling that must handle a discovered anchor passes it as a **quoted argument to a fixed-string
matcher** — never into a regex, never back through a shell.

This supersedes the previously-carried rationale for enumeration (that a glob would redden the
`f2-*` canonicalization fixtures). Re-measurement shows those fixtures carry the broken citation
**unbackticked**, so the extraction regex cannot see them at all. A glob's actual damage would be
sweeping `docs/`, where `docs/architecture.md` alone carries 2 distinct anchors and would fail the
distinct-anchor assertion.

### C.5 W1 fixtures are generated, not committed

Re-measured: the existing pipe-injection fixtures are written into a `mktemp -d` directory at CI
runtime by inline `awk` generators, then compared with `cmp -s` against the real registry by a no-op
setup guard (`for f in reflow pipe-sa pipe-pg deleted`). **W1 therefore adds no committed fixture
files** — 3 generator lines, 3 self-test legs, and 3 new entries in the setup-guard list, all inline.
This is what keeps W1 compliant with the "stay INLINE, never `scripts/`" constraint.

### C.6 Anti-pattern scan

| # | Anti-pattern | Finding |
|---|---|---|
| 1 | God class/module | **Present, accepted.** The anchor-guard step grows to ~4 responsibilities (extract, resolve, self-integrity, tripwire). Splitting it would break the Interference Constraint, which is the higher-value invariant. Retirement path: ADR-092 §Maturation Path option (a). |
| 2 | Circular dependencies | None. S14 and W1 are in different jobs with no shared shell state. |
| 3 | Leaky abstraction | None introduced. |
| 4 | Premature optimization | None. |
| 5 | Over-engineering | **Actively resisted.** The full census was declined; the tripwire was scoped down rather than dropped. |
| 6 | Tight coupling | **Present by necessity and named:** S14 creates S15's population. Recorded as the Interference Constraint. |
| 7 | Missing separation of concerns | None. |
| 8 | N+1 query | N/A — no data layer in this repository. |
| 9 | Destructive migration | **None, explicitly.** No registry row added or removed (30 = 30); ADR bodies appended, never edited in place; append-only records discharged by cross-reference. |
| 10 | SoS interface discontinuity | N/A — single-project. |
| 11 | Cross-project tight coupling | None. |

---

## §D. File-by-File Implementation Plan

> *ISO 15288 — Technical: Design Definition Process.*

| # | File | Change | Owner-AC |
|---|---|---|---|
| 1 | `.github/workflows/quality.yml` | Rebuild the anchor-guard step: 4-tuple enumeration, per-tuple distinct/citation counts, whole-line level-agnostic matching, both self-integrity assertions, scoped tripwire (pin 6), `, rule 2` assertion, `ANCHOR_SAFE` sanitizer, sink handling. Widen `GATED_SLUGS` to 5 with 3 generator lines, 3 legs and 3 setup-guard entries. Add in-workflow proof items (a) through (h). **INLINE only.** | AC-S14, AC-S15, AC-W1 |
| 2 | `skills/self-apply/SKILL.md` | Correct the citation anchor; relocate `, rule 2` outside the backticks. | AC-CF-A |
| 3 | `PROMOTE.md` | Correct the citation anchor; relocate `, rule 2` outside the backticks. | AC-CF-A |
| 4 | `templates/skill-template/SKILL.md` | Backtick-wrap the citation, add the space after the section sign, move the trailing period outside. | AC-CF-A |
| 5 | `curated-skills-registry.md` | Bump `self-apply` and `pull-updates` sha256 cells; rewrite `self-archive` and `self-upgrade` description cells. No row added or removed. | AC-CF-A, AC-S5b, AC-S11 |
| 6 | `skills/pull-updates/SKILL.md` | Add the malformed-registry-row refusal clause. | AC-S5a |
| 7 | `tests/pull-updates-firing-controls.md` | NEW. Record the real invocation: model, version, date, verbatim refusal output. | AC-S5b |
| 8 | `tests/fixtures/citation/nc5-prefix-truncated.md` | NEW. Prefix-truncation negative control fixture. | AC-S14 (NC-5) |
| 9 | `tests/fixtures/citation/s15-injection-control.md` | NEW. Injection-control payload, as a file so no shell `printf` can eat it. | AC-S15 |
| 10 | `docs/risk-register.md` | Flip `v2.19.11-PULL-ROW-1` to CLOSED, naming model drift and per-slug variance as residuals. Only on AC-S5b's recorded invocation. | AC-S5b |
| 11 | `docs/architecture.md` | Append the B0 amendment record (role axis, tie-breaker, discharge rule, mechanism naming, 3 superseding cross-references, historical-example note). Append-only. | AC-B0 |
| 12 | `docs/design-v2.19.11.md` | Three corrections: RED-d transcript, Leg-2 credential-leak clause, `Decision (3)` mis-pointer. | AC-CF-B |
| 13 | `CHANGELOG.md` | Release notes for v2.19.13. | release hygiene |
| 14 | `VERSION` | `2.19.12` to `2.19.13`. | release hygiene |
| 15 | `README.md` | Version badge `2.19.12` to `2.19.13`. | release hygiene |

**Already landed at Phase 1 by @architect (not @dev's work):** `docs/spec.md` (finalized spec +
Condition Ledger), `docs/architecture.md` (ADR-092 body + index row), `docs/design-v2.19.13.md`
(this document). `docs/architecture.md` appears in both lists because Phase 1 appended the ADR and
Phase 4 appends the B0 amendment — two separate appends to an append-only file, no conflict.

**Files explicitly NOT written:** anything under `scripts/` (ADR-090 forbids it and it escalates
ceremony), and any new row in `curated-skills-registry.md`.

```yaml
scope_allow_delta:
  add:
    - .github/workflows/quality.yml
    - skills/self-apply/SKILL.md
    - skills/pull-updates/SKILL.md
    - templates/skill-template/SKILL.md
    - tests/pull-updates-firing-controls.md
    - tests/fixtures/citation/nc5-prefix-truncated.md
    - tests/fixtures/citation/s15-injection-control.md
    - docs/risk-register.md
    - docs/architecture.md
    - docs/design-v2.19.11.md
    - docs/spec.md
    - PROMOTE.md
    - CHANGELOG.md
    - README.md
    - VERSION
    - curated-skills-registry.md
  remove: []
```

**This block is a no-op for scope enforcement on this cycle.** `claude-cowork-config` is an external
registered project; `.claude/agents/dev.md`'s `scope_allow` governs Council-side writes and is not in
this cycle's scope. The block is recorded because ADR-115 requires its presence (omission is a parse
error), and every entry carries a non-wildcard prefix — `.github/`, `skills/`, `templates/`, `tests/`,
`docs/`, or a named root file. No entry is a bare wildcard.

---

## §E — B1 verification

> *ISO 15288 — Technical Management: Decision Management Process.*

### B1 verification (ADR-127 / C29)

**B1 verification: PASS @ 2026-08-27T06:21:00Z** — `scripts/guards/scope-allow-verify.sh` exit **0**.

```
VERIFY-RESULT: PASS — all 14 plan file(s) covered (72 scope_allow patterns + 16 delta entries)
```

Per-file: `.github/workflows/quality.yml`, `tests/**` (3 files), `docs/architecture.md`,
`docs/design-v2.19.11.md`, `CHANGELOG.md`, `README.md` resolved COVERED-BY-REGEX; the remaining 6
resolved COVERED-BY-DELTA.

**One tokenizer note, recorded rather than left as a silent gap:** the verifier extracted **14** of
the §D table's **15** rows. `VERSION` is not extracted, because it carries neither a path separator
nor a dot-extension and so does not match the tokenizer's file-shaped pattern. It **is** present in
`scope_allow_delta.add[]`. This is a verifier tokenizer limitation, not a coverage gap, and it does
not affect the PASS — but a reader comparing "15 rows" against "14 covered" would otherwise be
looking at an unexplained discrepancy.

---

## Classification Re-Run

*Mandatory per `docs/pipeline-policy.md` §PostOQClassificationReRun — required even when the answer is CONFIRMED. Fail closed if absent.*

**Result: CONFIRMED — SECURITY-SENSITIVE, Tier A. COMPLIANCE-SENSITIVE = NO.**

Re-evaluated against the **final** §D file list after all condition resolution, not against the
Phase-0 list.

**Rationale.** The final file list still contains `.github/workflows/quality.yml` — a CI guard
surface — plus `curated-skills-registry.md` sha256 cells and `skills/pull-updates/SKILL.md`'s safety
prose, each of which independently carries Tier A on the standing basis used at v2.19.12. Condition
resolution **added** files (two committed control fixtures under `tests/`, and
`docs/design-v2.19.11.md` gained a third correction) but removed none, and no addition is of a lower
ceremony class. Classification therefore cannot move downward, and nothing in the final list
introduces external content, third-party code, license obligations, or personal data, so
COMPLIANCE-SENSITIVE remains NO.

**No upward flip.** Tier A is already the highest ceremony tier in this repository, so Phase 2 cannot
be skipped and no orchestrator halt is triggered.

**Ceremony owed:** worktree branch (active) + PR + **one @security Guard Change Summary at Phase 2**
(owed then, not at Phase 0.D). Squash-merge only, after owner approval on the GCS. Never
fast-forward.

**Standing-rule question deliberately left open** (it is an owner decision, not a reviewer's or an
architect's): whether this target repo should carry its own standing classification table, so that a
future cycle touching only `quality.yml` does not re-litigate Tier A/B from first principles. The
Council's own policy does not transfer here — its rationale cites a workflow file that does not exist
in this repo. Recorded, not decided.

---

## §F — Residuals carried forward

> *ISO 15288 — Technical Management: Risk Management Process.*

| id | Residual | Severity | Disposition |
|---|---|---|---|
| `CF-v2.19.13-CITATION-CENSUS` | Guarded population is smaller than the obligated population; nothing reconciles them. 3 shipping files carry guard-form citations outside the 4-tuple. | MEDIUM | Named, not scheduled. Retirement path = ADR-092 §Maturation Path option (b). |
| `CF-v2.19.13-GITHUB-CLASSA` | `.github/CODEOWNERS` and `.github/workflows/release-assets.yml` carry **broken Class-A pointers today**. Both unbackticked (invisible to the guard by construction); one anchor does not exist on any single line. Both export-ignored. | MEDIUM | **Deferred by decision, named not silent.** Repairing them requires backtick-wrapping first, and one requires un-wrapping a two-line comment. |
| `CF-v2.19.13-DECISION3-RESIDUE` | 3 remaining `Decision (3)` mis-pointer loci (`security-audit-v2.19.11.md` x2, `docs/retro.md` x1). | LOW | Deferred **with a stated inclusion test** so the next auditor can re-derive the set. All export-ignored, all in append-only records. |
| `S10` | `CONTRIBUTING.md`'s malformed self-citation — no space after the section sign, invisible to the extraction regex by construction. | LOW | Named carry-forward, not scheduled. Maintainer surface (S13). |
| `A15` | Registry-row-count pin is defeatable by a compensating pair. | LOW | Stays deferred. No row added this cycle (30 = 30, re-confirmed). |
| GNU/BSD | Every local measurement is BSD grep 2.6.0-FreeBSD / BSD awk / macOS. **No GNU binary and no container runtime on the authoring host.** | HIGH until CI | Closed by proof items (a) through (h) executing on `ubuntu-latest` on this cycle's own PR. Stated as **untested**, never as passing. |
| `%0A` decoding | GitHub Actions' handling of percent-encoded newlines at error/stdout sinks remains **UNRUN by anyone**. | INFO | Explicitly **not** load-bearing for AC-S15's correctness, and less so after sanitization. Not promoted to fact. |
| Model drift + per-slug variance | AC-S5b is a one-time invocation, 1 slug of 3. | MEDIUM | Both named in the risk-register CLOSED text. The sha256 gate makes the *text* durable, not a future model's behaviour. |
| Anchor-guard step responsibility count | The step now carries ~4 responsibilities. | LOW | Accepted; splitting would break the Interference Constraint. Retirement path = ADR-092 option (a). |

---

## Closing note

The cycle's own standing rule — *a number inherited from a reviewer is not verified until the
recipient re-runs it* — was applied to the conditions file that mandated it. **Four of twenty
conditions were falsified by that re-run**, and each would have shipped a defect if implemented
faithfully: a pin that REDs on a correct tree, a deferred-count that is arithmetically impossible
against its own two neighbouring figures, a truncation marker eaten by its own pipeline, and a
tie-breaker that mandates rewriting history. Three of the four are the *same* failure class the
condition immediately above them was written to prevent.

That is the 14th generation of this project's named failure mode, and it was found in the document
whose purpose was to end it. The corrective is not more prose — it is ADR-092 §Maturation Path
option (a): make the primitive a single shared function so there is one place to be right, instead of
a new place to be wrong in every remedy.
