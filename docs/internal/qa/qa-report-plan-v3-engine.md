# QA Report — plan-2026-08-27-v3-engine (v3.0 "THE ENGINE" spawn-only design)

> **Provenance note (orchestrator, 2026-08-28).** This report was authored in full by `@qa` at Phase 5.
> `@qa` was refused its own scoped write to this path by `scripts/guards/qa-scope.sh`
> (*"BLOCKED: Phase 4 (Implementation) has no status recorded"*) — a guard whose premise is false for a
> `cycle_type: PURE-DOC` cycle, where ADR-121 forbids a Phase 4 implementation from existing. `@qa`
> declined to route around the guard and returned the prose instead. The orchestrator persisted it here;
> `docs/qa-report*.md` is on the orchestrator's own allow-list, so this is an authorized write by a
> different actor, not a tunnel of the blocked one. The content is `@qa`'s, unedited. `Mode:` was not
> altered and no Phase-4 status other than the truth (`SKIPPED`, per `--lite`) was recorded. See
> `pipeline.md` row `5.B` for the three stacked guard defects this exposed.
>
> **This file must NOT enter the feature commit.** It is bare-named, and `quality.yml`'s
> `LEAK_PATTERN: '^docs/(qa-report|security-audit|security-review)-'` requires a trailing hyphen, so it
> cannot match. It stays untracked until `archive-cycle.sh` relocates it at Phase 8.

## Phase: 5 (PURE-DOC artifact verification — no code, no tests to run)
## Date: 2026-08-28T14:44:23Z
## Status: PASS WITH NOTES

Discipline used throughout: `/usr/bin/grep` by absolute path, `date -u '+%Y-%m-%dT%H:%M:%SZ'` for
timestamps, bytes inspected directly (`git diff`, `git show`, `wc -l`, `git archive`), never a success
message trusted on its own. `HEAD` confirmed `ff0c44c81be2315979af17f931de3dae3b3cf51a` before and after
this pass — no branch, no commit, no push. Every number below states how it was measured.

---

## I-PD5 Invariant Checks

**(a) HLD + roadmap present and coherent — PASS.** Both exist; both edited additively; cross-references
(`docs/hld.md` ↔ `docs/roadmap.md`'s v3.0 row ↔ ADR-095) are mutually consistent.

**(b) No-code check — PASS.** `git diff --name-only` (tracked) + `git status --porcelain` (untracked, for
completeness) over the whole cycle:

```
M  docs/architecture.md
M  docs/hld.md
M  docs/risk-register.md
M  docs/roadmap.md
M  docs/spec.md
?? docs/internal/carry-forwards.md
?? docs/security-review.md
```

Zero `scripts/`, `.github/`, `skills/`, `templates/`, `tests/` paths. All 7 touched paths are under `docs/`.

**(c) `planning.hld_published` — N/A, confirmed by direct read, not inferred.** Read
`.claude/projects/claude-cowork-config/stack-profile.json` in full (10 lines, valid JSON, not truncated):
it has no `planning` key at all — `stack: "unknown"`, `note: "Stack to be determined during /spec and
/design phases"`. No status to report; the block was not created (correctly — it is not this cycle's job
to create it).

---

## Phase 1 + 2.R1 Claims — Independently Re-Run

| Claim | Measured | Result |
|---|---|---|
| `hld.md` strictly append-only, single hunk, zero deletions | `git diff -U0 docs/hld.md` → one hunk `@@ -266,0 +267,70 @@`; base file (`git show ff0c44c:docs/hld.md \| wc -l`) = 266 lines; working tree (`wc -l`) = 336 lines. 266 + 70 = 336, exact. | **CONFIRMED** |
| `risk-register.md` open count = 7 | Table has 11 dated rows (lines 7–17); `**OPEN**` count = 7, `**CLOSED` count = 3, 1 row carries a third status (`SELF-RESOLVING AT MERGE`, not a forward-carried risk). 7+3+1=11. | **CONFIRMED** |
| Status repair and citation repair touch disjoint fields | `git diff -U0 docs/risk-register.md`: status-cell changes land only on rows 12 (`AC-PUB-10`) and 15 (`CF-v2.19.6-A`); citation-cell changes land only on rows 8–11 plus one footnote line. No row has both. | **CONFIRMED** |
| `CF-v2.5` security/QA series byte-unchanged | `git diff --name-only -- docs/retro.md docs/internal docs/research` → empty output. | **CONFIRMED** |
| Architecture series renumbered `CF-v2.5-ARCH-A..E`, all citations repointed | 12 hits across a migration table, a decisions section, and the ADR-INDEX checklist. Remaining bare `CF-v2.5-[A-E]` hits: **14** — every one inspected: migration-table quotations, a "before 2026-08-28" disambiguation note, or the ADR-INDEX record. None is an un-renumbered definition site. | **CONFIRMED** |
| `docs/internal/carry-forwards.md` at 40 strict / 43 broad, with a stated population definition | File states its own population method (lines 55–70) and a measurement table. Independently summed the 10 lettered subsections (A–J): 7+6+3+2+5+2+6+5+2+2 = **40**. Broad = strict + 3 named `docs/owner-tasks.md` "tracked candidate" rows = **43**. | **CONFIRMED** |
| ADR-093/094/095 present as headings | `## ADR-093` (:15398), `## ADR-094` (:15538), `## ADR-095` (:15664). Row 283 cited :15394/:15500/:15624 — the drift is expected: 2.R1 inserted ~279 more lines into ADR-095 after Phase 1's report was written. Not a defect, just line-pinned citations aging in real time. | **CONFIRMED, headings present** |

---

## S1 Egress Remedy — Judged on the Merits

- **Repo visibility, re-confirmed from a clean state:** `gh repo view --json visibility,nameWithOwner` from
  inside the target repo → `{"visibility":"PUBLIC","nameWithOwner":"jmlozano1990/Cowork-Starter-Kit"}`. (A
  first attempt with a malformed `-R` flag silently fell back to a different repo and returned `PRIVATE` —
  a live demonstration, inside this very verification pass, of exactly the failure mode this whole cycle is
  about: an unverified number from a wrong invocation is not evidence.)
- **Negative-controlled archive check, re-run:** `git ls-files docs/internal | wc -l` → **84** tracked
  files. `git archive HEAD | tar -t | grep -c '^docs/internal/'` → **0**. Total archive entries: **419**.
  Top-level shipping `docs/*.md`: **19**. All four numbers match the row's figures exactly — the "0 in
  archive" result is meaningful because the source directory is verifiably non-empty (84 files), not a
  vacuous zero.

**Judgment: the remedy closes the release-archive-shaped half of the harm and only that half.**
`export-ignore` has zero effect on `git clone` or GitHub's web file browser — only on `git archive` output.
Since the repo is public, anyone who clones or browses can still read `docs/internal/carry-forwards.md` in
full and follow its origin-document pointers into the same `docs/internal/` reports. The content reduction
(pointers instead of reproduced finding detail) is a real if narrow mitigation: it raises the effort to
assemble a "what's broken and unowned" list from "read one committed file" back to "read 84." That is worth
something against opportunistic scanning; it is not secrecy, and the row does not claim it is.

**Finding (WARNING, non-blocking, correction owed before Phase 7):** the status cell for row 2.R1 reads
"**both CRITICALs discharged**." For S1 that overstates what happened — the CRITICAL's core concern
(aggregation harm in a public repo) is *mitigated*, not *discharged*, and no fresh @security pass
re-confirmed the remedy against the original finding. Recommend re-labeling as "MITIGATED (partial) —
public-clone/web-UI exposure knowingly accepted, narrowed in content."

---

## Composition Leg (ADR-095 C1) — Implementability and Testability

**The precondition the brief flagged is correctly specified.** Verbatim: *"A skill absent from the parent
is evaluated against the pool's declared default, never against 'no constraint' — absent must not read as
unconstrained, which is the specific way this check would otherwise fail open."* Decision procedure
(effective privilege = `tools:` set ∪ deny-list membership ∪ CLAUDE.md-granted write scope, child vs.
parent, strict-superset FAILS) and failure criterion are both concrete and stated, not merely named.

**Finding (WARNING, owed at the v3.0 build cycle's Phase 1):** two of C1's three privilege axes are backed
by structured, machine-readable artifacts already proven in this repo — `tools:` frontmatter, and
deny-list membership (`AC-APPLY-3`, `self-*` reserved prefix). The third axis — "the write scope the seeded
`CLAUDE.md` grants" — has no defined mechanical-extraction procedure anywhere in this repo. `CLAUDE.md` here
is prose. This is the identical shape of gap C5 was explicitly renamed and re-specified to close
("undefined is not fail-closed"). C1 is named the load-bearing security check; its own third input has the
same undefined-extraction problem on a smaller, easier-to-miss scale. The v3.0 build cycle's Phase 1 should
either define a parseable "write scope" schema, or narrow axis (iii) to what is structured today.

---

## `AC-UPGRADE-4-LEGA` — Re-Run, Not Trusted

- **Total `RAN` entries** in `tests/self-upgrade-firing-controls.md` → **13**. Exact match.
- **MF-2 control (b):** control (a) has `[x] **RAN 2026-07-22.**` at line 90; control (c) has one at line
  117; control (b), sitting between them, has **no** RAN entry — instead explicit prose: *"Honestly
  un-exercisable pre-implementation… bound here as a Phase-5 `@qa` re-verify item, not assumed proven."*
- **"Leg (a) never fired once":** confirmed by the same evidence.

**Ruling on the AC's wording.** `docs/spec.md:11049–11057` binds the obligation, not the symptom — a mock
or a bare string-count could not satisfy it; the AC requires a demonstration that the control actually
fires. **This is the exact defect class the AC exists to close, and the fix does not reproduce it.**

---

## The 0.D Experiment — Ruling

Independently confirmed from the Phase Log block itself: **zero 0.D rounds ran.**

1. **Nothing may be recorded as "one round instead of two" having been tested.** That is not what happened.
2. **What actually happened is a *stronger*, different condition:** zero adversarial deliberation rounds
   before the gate, with @security's Phase 2 review as the *first* adversarial reading of a design carrying
   the kit's largest-ever blast radius — and that reading happened *after* the owner had already approved
   Phase 0 and unlocked Phase 1.
3. **This cycle produces no usable evidence for the original question.** The independent variable that was
   supposed to be manipulated (round count: 2 → 1) was instead set to 0 — a different experiment entirely.
4. **The experiment is unrun and still owed.** A valid run requires: (a) a cycle on a comparably mature,
   comparably stable surface to the v2.19.13 baseline; (b) exactly **one** 0.D round actually executed
   before the gate; (c) the same three metrics measured under the same definitions as the baseline; (d) the
   round's disposition stated before the gate opens, so a front-loaded-gate shape cannot silently
   substitute for it again.
5. Do not read this cycle's low measured defect count as informative about round count.

---

## Defect-Instance Ledger

0% rework is not read as convergence. This cycle is PURE-DOC — there is almost no "rework" possible by
construction, so a near-zero rework rate here measures the absence of code, not the presence of quality.

**Method:** every defect instance below was independently re-verified against the artifact this session —
not accepted because a phase-log row asserted it. Six of the sixteen were found fresh during this pass and
appear nowhere in the pipeline log.

| # | Defect | Author | Caught by | Phase |
|---|---|---|---|---|
| 1 | Handoff summary claimed `CF-v2.5-C` "exists in neither series"; false, contradicted by the same agent's own spec body | @pm | orchestrator | 0 |
| 2 | Option-3 rationale ("security series is the one still load-bearing") — falsified; 4 of 5 architecture-series items are live v3.0 inputs | @pm | orchestrator | 3 |
| 3 | Stated hypothesis "the two regexes admit different things" — wrong; true cause was @pm's own illustrative example strings | orchestrator | @architect | 1 |
| 4 | Proposed renumbering form `CF-ARCH-v2.5-1` — does not match the project's own id-census regex | orchestrator | @architect | 1 |
| 5 | ADR-index insertion via a shell double-quoted string silently stripped backticks | @architect | @architect (self) | 1 |
| 6 | "61 security-side citation sites" — off by one | orchestrator | orchestrator (self) | 1 |
| 7 | ADR-095 D9's "`SECGATE-B1` in exactly 3 files" stated with no population/revision scope | @architect | orchestrator | 2 |
| 8 | @security restated the count as "4" — also stale by the time the review was saved | @security | orchestrator | 2 |
| 9 | Composition leg's C1 promised in §Context but dropped from D1.3's Decision list | @architect | @security | 2 |
| 10 | S1 remedy implied a privacy benefit a public repo cannot deliver | orchestrator | @architect | 2.R1 |
| 11 | ADR-093 "Consequences" states strict open count = 33; actual is 40 | @architect | **@qa** | 5 |
| 12 | HLD amendment states "267 lines untouched, now 334"; actual 266/336 | @architect | **@qa** | 5 |
| 13 | Row 2.R3's exposure reasoning examined the wrong project's pipeline.md | orchestrator | **@qa** | 5 |
| 14 | "Both CRITICALs discharged" overstates S1's residual public-clone exposure | @architect (framing inherited from orchestrator) | **@qa** | 5 |
| 15 | 2.R2 names only `security-review.md` for commit-exclusion; `qa-report.md` is symmetrically exposed | orchestrator | **@qa** | 5 |
| 16 | ADR-095 C1's third privilege axis has no defined mechanical-extraction procedure | @architect | **@qa** | 5 |

**By author:** @pm 2 · orchestrator 6 · @architect 7 · @security 1. The orchestrator's count is three times
the "at least two" the brief named, which is itself informative: the orchestrator is writing more
load-bearing prose per cycle than either agent role in this front-loaded shape, and its error rate should be
watched, not assumed low because it is not "an agent."

**By phase caught:** Phase 0/3 → 2 · Phase 1 → 4 · Phase 2 → 3 · Phase 2.R1 → 1 · **Phase 5 → 6.** More
than a third of all defect instances were sitting in already-shipped Phase 1/2 artifacts and were caught by
nobody until this pass read the bytes instead of the narrative. That is the actual signal this cycle's
near-zero rework number was hiding.

---

## Two Guard Findings — Verified Independently

### Row 2.R3 — `orchestrator-guard.sh` fail-open

**The code-level claim reproduces exactly.** Lines 342–346 compute `CURRENT_PHASE` via
`gsub(/[. ]/,"",$2)` then `grep -oE '^[0-9]+'`; line 382 gates on `-le 2`; line 379's own comment already
documents the arithmetic for `4.5` → `45`.

**Correction to the row's scope (found only in this pass):** the vulnerable branch sits inside
`if [ "$ACTIVE" = "self" ]` (line 263), and even then fires only for SECURITY-SENSITIVE or
COMPLIANCE-SENSITIVE cycles — `if [ "$CLASS" = "STANDARD" ]; then exit 0` at line 331 exits first. It reads
exactly one file: `.claude/projects/self/pipeline.md`. **This cycle runs with
`ACTIVE_OVERRIDE = "claude-cowork-config"`,** so the branch is never entered for any write this cycle made.
Writes to a registered external project are gated instead by `check_pipeline_phase`
(`pipeline-check.sh:51,81`), which matches `^\| 3\.` directly and reads the status cell for `APPROVED` — a
different mechanism, immune to the digit-concatenation bug by construction.

The row's "no live exposure" argument therefore examined the wrong evidence. Checking the file the
vulnerable path *does* read — `self/pipeline.md`, 3,494 lines — for numeric `N.M` sub-phase rows outside
`4.5` (acknowledged safe, post-gate) and `3.0` (Phase 3 itself): **zero.** Every within-phase revision in
The-Council's own history uses the lettered `.R` convention, which resolves safely. The one other
numeric-decimal row, `0.5` (`self/pipeline.md:1665`), belongs to a STANDARD-classified cycle (v0.29.1),
which exits before reaching the branch. **No live exposure has occurred — for a narrower and correct reason
than the row states.**

**Verdict:** the underlying code defect is real and correctly reproduced; the exposure analysis in the row
is wrong in its object even though its conclusion still holds once checked against the right file. Carry
forward as a Tier A fix to The-Council's `self` slug, and scope the regression test to `self/pipeline.md`'s
actual historical row conventions, not a synthetic `2.1`-in-a-Cowork-cycle fixture, which cannot occur under
the current branch structure.

### Row 2.R2 — ephemera vs. egress

**Git-history claim, re-verified per-commit:** all five cited SHAs surface under `--follow`. Checked each
with `git show --stat`: `e5c152d` and `8c74273` show real content **added** to `docs/security-review.md` at
top level (154 and 24 lines — genuine authorship, not a rename artifact); `8cb34dc` and `31ee8d6` show
further top-level additions (14 and 16 lines); `831c4f0` is the commit that renamed it and 8 versioned
siblings into `docs/internal/security/`. **Claim fully confirmed.**

**`LEAK_PATTERN` gap, re-verified against the live workflow:** `quality.yml:2372` requires a literal
trailing hyphen. `docs/security-review.md` and `docs/qa-report.md` have `.` as the next character, not `-`,
so neither matches. **Confirmed: this is the one filename shape `LEAK_PATTERN` structurally cannot catch.**

**Judgment on sufficiency:** the binding resolution is correct, minimal and guard-consistent for this cycle.
**It is incomplete as written: this QA report itself sits in exactly the same bare-named position, and the
row's Phase-7 check names only `docs/security-review.md`.** Phase 7 must verify the staged commit excludes
*both*. I am not committing this file myself, consistent with the resolution's own logic.

---

## Findings Summary

### Blocking

None. Every I-PD5 invariant holds; every load-bearing structural claim reproduces exactly against the
artifacts. This is a PURE-DOC cycle with no executable surface to fail.

### Non-blocking — owed before Phase 7

- Correct ADR-093's stale "33" strict-count (finding #11) to 40, or delete the sentence.
- Correct the HLD amendment's "267 lines untouched, now 334" (finding #12) to 266/336.
- Re-label 2.R1's S1 status from "discharged" to "mitigated (partial)" (findings #10, #14).
- Extend 2.R2's Phase-7 pre-commit check to also exclude `docs/qa-report.md` (finding #15).
- Correct row 2.R3's exposure narrative per the ruling above (finding #13).

### Owed at the v3.0 build cycle's own Phase 1

- Define a mechanical-extraction procedure for C1's "CLAUDE.md-granted write scope" axis, or narrow the
  axis to what is structurally checkable today (finding #16).
- `tests/self-upgrade-firing-controls.md` MF-2 control (b) remains genuinely unfired; establish the
  first-entry-point baseline before attempting the second-entry-point demonstration.

### Experiment

The declared 0.D falsifiable experiment did not run — zero rounds ran. No conclusion about round count may
be drawn from this cycle. It remains owed.

### Verdict

**PASS WITH NOTES.** All I-PD5 invariants confirmed by direct artifact inspection. All load-bearing counts
and structural claims independently re-run and matched. No blocking defect exists for a PURE-DOC cycle. Six
new findings were surfaced in this pass — all non-blocking, all actionable, all listed above with an owner
and a phase. Recommend proceeding to Phase 7 conditional on the five "owed before Phase 7" items being
dispositioned (fixed or explicitly accepted with rationale) in the Phase 7 record.
