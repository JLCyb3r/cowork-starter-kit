# QA Report — v2.19.9 "Truth Repair: the entry point that never fired"

## Phase: 5 (Testing)
## Date: 2026-08-11
## Tree graded: `release/v2.19.9-truth-repair` @ `968cf4c` (pushed, local == remote)
## CI: run `31547431604` — conclusion `success`, 34 jobs total, 0 failed, 3 legitimately `skipped`
## (`lock-content-sha-cross-check`, `/sync-agency Dry-Run`, `Vendored Removal Ledger` — all
## conditional/path-gated, independently confirmed via `gh run view`), `Starter Sync Check` `success`.

## Status: PASS

---

## 1. Render-layer falsifier — every normative-correction and annotate-only site, final tree

Bounded 3-question form (fixed at 2.D): **Q1** implies `CLAUDE.md` loads without explicit user
action? **Q2** implies setup/wizard fires without a paste or explicit message? **Q3** states the
actual mechanism (attach-as-source / best-effort read on request)? FAIL = any Yes on Q1/Q2, or No
on Q3. Per Phase-5 instruction: ambiguous reads are graded against the full rendered unit (prose +
any adjoining diagram/table, exactly as the falsifier was specified at 2.D), and a genuinely
unresolved ambiguity is called out explicitly rather than silently passed.

| # | Site | Q1 | Q2 | Q3 | Verdict | Note |
|---|---|---|---|---|---|---|
| 1 | `README.md:91` prose | N | N* | Y | **PASS (close call)** | See §1a — recorded explicitly, not silently passed. |
| 2 | `README.md` ASCII diagram (`:96-118`) | N | N | Y | **PASS** | Shows attach → start conversation → goal question; no auto-read step depicted. Byte-position invariant (byte 2/39 `|`) independently re-verified, 0 offenders. |
| 3 | `README.md` Route 1 step 3 (`:42`) | N | N | Y | **PASS** | "ask Cowork to read `CLAUDE.md` if setup does not begin on its own." |
| 4 | `SETUP-CHECKLIST.md:10` | N | N | Y | **PASS** | Same hedge as Route 1, verbatim structure. |
| 5 | `SETUP-CHECKLIST.md:24` | N | N | Y | **PASS** | Token-clean (`primary`, `manual fallback`, `substitutes for`, `auto-load` all 0 hits in file). |
| 6 | `SETUP-CHECKLIST.md:61` | N/A | N/A | Y | **PASS** | Correctly distinguishes cloud-session auto-discovery (true) from local-session behavior (not auto-discovery) — this is now an accurate statement, not a defect. |
| 7 | `.claude/skills/skill-studio/SKILL.md:137` | N | N/A | Y | **PASS** | "a best-effort, inspection-class write... its read at Cowork session start is not guaranteed." |
| 8 | `.claude/skills/skill-studio/SKILL.md:178` (advisory, spoken aloud) | N | N/A | Y | **PASS** | "which isn't guaranteed every session." Highest-value line in the cycle, correctly hedged. |
| 9 | `TRUST.md:23` | N/A | N/A | Y | **PASS** | Split cleanly — makes no read-mechanism claim at all now, only the word-ceiling claim. |
| 10 | `WIZARD.md:3` | N | N | Y | **PASS** | Matches Route 1 exactly. |
| 11 | `.claude/skills/setup-wizard/SKILL.md:47` | N/A | N/A | Y | **PASS** | No auto-load/auto-discover claim remains; describes wizard-installed files only. |
| 12 | `CONTRIBUTING.md:48` | N | N/A | Y | **PASS** | "its read at session start is best-effort, not guaranteed" — S4's mitigation basis preserved on corrected grounds. |
| 13 | `docs/internal/process/OUTPUT-STRUCTURE.md` prose (`:9-13`) | N | N | Y | **PASS** | "not guaranteed on the very first message." |
| 14 | `docs/internal/process/OUTPUT-STRUCTURE.md` table row (`:58`) | N | N | Y | **PASS (fixed since 4.D)** | Now carries its own inline hedge — "not guaranteed on the first message — ask Cowork to read it if it doesn't" — independent of the prose paragraph above it. |
| 15 | `docs/internal/planning/assumptions.md` new `A2` entry | N | N/A | Y | **PASS** | Explicit withdrawal of "primary delivery channel," names the two mechanisms as never having been one claim. |
| 16 | `docs/research/cowork-evolution-discovery-brief.md:123` annotation | N | N/A | Y | **PASS** | Annotation now accurately self-describes as "annotated here, not stripped or edited" — flagged sentence confirmed byte-preserved (§3). |

**14/14 normative/annotate-only sites graded PASS.**

### 1a. Non-blocking finding — `README.md:91` is context-dependent, not self-contained

Graded PASS, but the PASS is load-bearing on adjacent context, and that needs to be on the record
rather than folded silently into a clean-looking row above.

Read in **isolation**, the sentence — *"Cowork attaches it as a browsable source, and the setup
wizard begins once it reads `CLAUDE.md` — ask Cowork to read it if setup doesn't begin on its
own"* — never states that the user must send a message before any of this happens. It resolves to
PASS only because the ASCII diagram immediately below it (rows 96–118) depicts an explicit "Start
conversation" step between folder-attach and the goal question. My own falsifier's stated method is
to read the **rendered passage**, which for this site is prose-plus-diagram as one unit — so PASS is
the correct grade under the instrument as specified. But a reader who doesn't render the diagram (a
text-only export, a screen reader that skips fenced code blocks, a partial quote of just this
sentence elsewhere) would not see the gate at all, and would be left with exactly the unhedged
"begins once it reads `CLAUDE.md`" framing this cycle exists to correct.

**Recommendation (non-blocking, does not gate this cycle's PASS):** fold an explicit trigger clause
into the prose sentence itself, matching Route 1's own already-correct structure a few lines above
(`:42`, *"Start talking, then ask Cowork to read `CLAUDE.md` if setup does not begin on its
own"*) — e.g., *"...and the setup wizard begins once you start talking and it reads `CLAUDE.md`..."*
— so the guarantee is self-contained and does not depend on the reader also parsing the diagram.
**Candidate carry-forward item for v2.19.10.**

---

## 2. Negative-control inventory — fired/passed against the final tree, independently re-run

| Control | Method | Result |
|---|---|---|
| `AC-TR-A1` scans, corrected scope (normative-correction lines only, per hub's spec correction) | Per-file token + denylist scan on §1's normative sites | **0 hits, all sites.** (Whole-12-file literal form independently confirmed still returns 61 legitimate hits outside the corrected scope — the corrected scope is the right one to grade against.) |
| `AC-TR-A2` — 0 modified/deleted lines inside any ADR body block | Block-boundary-aware diff, `f06f0cf..968cf4c`, `docs/architecture.md` (not a whole-file line diff — scoped to `^#{2,3} ADR-` ranges) | **0.** The 4 raw deleted lines in the file diff are all index-table rows (ADR-010/046/053/064), outside every body range — correctly outside the control's scope. |
| §A.2 corrected enumeration — 24 hit-lines / 11 pre-existing ADR bodies | Independent Python re-derivation of ADR body ranges + token scan, excluding ADR-082/083/084 (this cycle's own new, legitimately-topical ADRs) | **24 lines, 11 bodies exactly: 003, 004, 007, 008, 010, 038, 044, 046, 051, 053, 064.** Matches the design doc's E.2-corrected figure precisely. |
| `AC-TR-A3` (`TRUST.md`) | grep `400` present + auto-load language absent | **PASS**, both legs. |
| `AC-TR-A4` (`WIZARD.md:3`) | grep `automatically`/`primary entry point` post-fix | **0 hits**, both terms. |
| `AC-TR-B2` (no "primary"/"Alternative paths" ranking) | grep across `README.md`, `SETUP-CHECKLIST.md`, `WIZARD.md` | **0 hits** in all three. |
| `AC-TR-C1` (cardinality agreement) | Inspected `starter-file-check`/`starter-safety-rule-check` — both now derive `EXPECTED` from the single `ENFORCED_EXAMPLES` literal via `wc -w`; no `6` digit remains anywhere, including error strings | **PASS.** (Not re-run destructively against the live tree — inspected the derivation logic directly, which is the more informative check post-fix; the firing leg was already proven pre-fix at Phase 1/2.D.) |
| `AC-TR-C2` firing NC (real drift) + PASS control | All 7 starters normalized and `cmp`'d by hand, independent of the CI job's own code | **All 7 byte-identical post-normalization.** Drift is gone; PASS control holds. |
| `AC-TR-C3` — slot-presence + positive data-locality allow-list | Ran `NORMALIZE()` against all 7 files by hand; checked `## Data locality` presence/absence | **PASS**, both legs (PA has exactly 1, other six have exactly 0). |
| `AC-TR-C4` word budget | `wc -w` on all 7 starters | study 374, research 374, project-management 375, writing 373, creative 373, business-admin 374, **personal-assistant 397/400.** All under cap. |
| `AC-TR-D1` (`skill-studio` target-resolution) | Anchored `awk` control re-run | **1 pre-fix → 0 post-fix**, confirmed against the live corrected file (informational — this leg was already proven at Phase 1; independently re-confirmed here). |
| `AC-TR-D3` (risk-register row) | Unique-anchor firing control | **0 pre-fix / 1 post-fix.** Row `v2.19.9-SKILLSTUDIO-TARGET` present, all 6 required elements verified present, correctly attributes the 2.D verdict as PROCEED-WITH-CONDITIONS. |
| `AC-TR-D2` render-layer falsifier (documentation analog) | Read `docs/retro.md`'s two dated corrections directly | **PASS** — both carry the "S4 closure was already prose-only, independent of the premise" honesty note and "The exposure did not fall. The attention did." verbatim, standalone-legible without the PR description. |
| `AC-TR-TIER-1` FROZEN v2 — control-integrity, baseline, 4 attack legs, 2 PASS legs | Full instrument re-implemented and re-run independently (not copy-pasted from the design doc) | **Control-integrity: 80. Baseline: `5f243f28…cafb` — exact match.** All 4 attack legs (8.1 slug-gate revert, 8.6 token-scan weaken, 8.7 confirm-drop, 8.8 idempotency weaken) fire RED (hash changes, confirmed independently — my own mutation text differs from the design doc's but the property holds identically). Both PASS legs proven implicitly: the live post-`:137`/`:178` file reproduces the exact claimed baseline hash, so the freeze does not trip on its own cycle's licensed edits. |
| §A.6 six-row exact-count table | All 6 `grep -cF` commands re-run against final tree | **2, 1, 1, 3, 1, 3 — exact match**, reconciling to 7 annotate-only + 4 leave. |
| ADR-082 D1 index-scoped annotated-row count | Exact landed `awk`/`grep`/`awk` pipeline re-run | **8 at `f06f0cf`, 12 at `968cf4c` — exact match.** The "returns 6" bug reported mid-cycle is not present in what shipped. |
| S2 (`permissions: {contents: read}` on `starter-sync-check`) | Inspected job YAML | **Present**, job-level, matches the four pre-existing blocks' value. |
| `starter-sync-check`'s `set -e`/`grep -c` guard | Traced every `grep -c`/`grep -cF` call under the runner's default `bash -eo pipefail` | **All three guarded with `\|\| true`.** No unguarded exit-1-on-zero path remains. |
| Roster duplicate check (new, closing part of the 4.D `AREA`-slot finding) | Extracted the exact shipped logic, ran three probes: (a) duplicate within `core`, (b) duplicate across `core`/`optional` in the same preset, (c) clean file (PASS control) | **(a) fires**, naming the repeated skill. **(b) fires**, naming the repeated skill. **(c) returns empty** — proven not to false-positive on clean input. Both directions proven, not asserted. |
| `AC-TR-TIER-2` (inline in `quality.yml`, never `scripts/`) | `git diff --name-only f06f0cf..968cf4c` | **0 `scripts/` paths.** Now fully checkable — no longer provisional, since the diff has actually landed. |
| `AC-TR-TIER-3` (no CODEOWNERS addition) | Same diff | **`.github/CODEOWNERS` absent from the file list.** |
| EXCLUDE class byte-identity (`WIZARD.md:214`, `examples/personal-assistant/cowork-profile-starter.md:15`, `context/README.md:3`, `PROMOTE.md:101`) | `git diff f06f0cf..968cf4c` per file | **`cowork-profile-starter.md`, `context/README.md`, `PROMOTE.md`: zero diff hunks, fully byte-unchanged.** `WIZARD.md` changed only at line 3; line 214's "It is not auto-loaded" text independently confirmed unchanged. |

**Every control I could re-run, fired or passed as claimed. I went looking for a seventh unable-to-fire/unable-to-pass instrument (six were already caught this cycle) and did not find one in the final tree** — the closest candidate, the `AREA`-slot roster-coverage gap I found at 4.D, was addressed with an honestly-labeled partial close (see §5), not silently left as a broken control.

---

## 3. Four-way disposition boundary — final diff

- **Normative correction:** `README.md` (:36-48 restructure, :83, :91-92 diagram, :154), `SETUP-CHECKLIST.md` (:10, :24, :61), `.claude/skills/skill-studio/SKILL.md` (:137, :178), `TRUST.md` (:23), `WIZARD.md` (:3), `.claude/skills/setup-wizard/SKILL.md` (:47), `CONTRIBUTING.md` (:48), `docs/internal/process/OUTPUT-STRUCTURE.md` (whole-section rewrite). All independently re-graded in §1 — 0 residual claims.
- **Annotate-only:** `docs/architecture.md` 4 index-row status annotations (:24 ADR-010, :67 ADR-046, :74 ADR-053, :85 ADR-064 — original row description text confirmed byte-unchanged, only the status column gains text) + 3 new index rows (ADR-082/083/084) + 7 design-memo lines (§A.2, `:7289/94`, `:8957`, `:9437`, `:9442/48/54`) + `docs/internal/planning/assumptions.md` (new dated entry, now with the in-place forward pointer on the old entry) + `docs/research/v2.7-usercase-test-and-improvement-research.md` + `docs/research/cowork-evolution-discovery-brief.md:123` (confirmed byte-preserved, §2). All original flagged text confirmed preserved verbatim where the class requires it.
- **Frozen ADR body (never touched):** 24 lines across 11 bodies (003, 004, 007, 008, 010, 038, 044, 046, 051, 053, 064) — independently re-derived in §2, exact match to the design doc.
- **Leave (out of predicate):** `:6483`, `:6627/31/53` — 4 lines, confirmed by §A.6's own count reconciliation (rows 5-6 sum to 4); not separately re-diffed line-by-line this pass, but the count control covers regression on these.
- **Exclude (byte-unchanged):** `WIZARD.md:214`, `examples/personal-assistant/cowork-profile-starter.md:15`, `context/README.md:3`, `PROMOTE.md:101` — all 4 independently confirmed zero-diff in §2.

No file landed in a disposition class inconsistent with its declared one. `assumptions.md`'s WARNING from 4.D (discoverability of the correction for a reader who stops at the old entry) is closed — the forward pointer is in place, in-line, non-destructive.

---

## 4. Count reproducibility ledger

Every number I could locate a written-down predicate for, I re-ran it myself rather than trusting the prose:

| Count | Predicate | Claimed | Reproduced |
|---|---|---|---|
| Frozen-ADR-body hit-lines / bodies | Python block-boundary scan, §A.2 corrected list | 24 / 11 | **24 / 11 — exact** |
| §A.6 six anchor counts | `grep -cF` × 6 | 2,1,1,3,1,3 | **2,1,1,3,1,3 — exact** |
| ADR-082 D1 index-scoped annotated rows | `awk`/`grep`/`awk` pipeline, base and HEAD | 8 / 12 | **8 / 12 — exact** |
| FROZEN v2 line count / hash | `sed`-based extraction | 80 / `5f243f28…cafb` | **80 / `5f243f28…cafb` — exact** |
| Starter word counts (7 files) | `wc -w` | 374/374/375/373/373/374/397 | **exact, all 7** |
| CI job total / non-success | `gh run view` | 34 total, 0 failed | **34 total, 3 skipped (conditional, not failures), 0 failed — exact** |

No count I checked failed to reproduce. I did not independently re-derive every number in `docs/design-v2.19.9.md`'s narrative prose (e.g., the §C.1 five-hunk diff description, the historical `git show --stat 33fd22c` citations) — those are Phase-1 design evidence, already spot-verified at 2.D, and re-deriving all of them again here would be re-litigating settled Phase 1 work rather than grading Phase 4's output. The counts graded above are the ones load-bearing for Phase 4/5 acceptance.

---

## 5. `AREA`/roster residue — honesty check

Confirmed independently: `weekly-review` is in `selection-presets.md`'s `optional_skills` for `project-management` (`:52`) and `personal-assistant` (`:88`), and absent from both presets' prose rosters in `examples/*/project-instructions-starter.txt` — reproducing ADR-084 §Maturation Path (f)'s cited gap exactly. The stated limitation — "this does not assert the roster's exact content against `selection-presets.md`" — is accurate, not understated. The stated reason for not closing it (strict parity would fail CI against the current word-budget-frozen tree, and no canonical slug→display-name source exists) is checkable and I did not find a cheaper fix available this cycle. The duplicate-skill check that *was* shipped is proven firing in both directions (§2). **This is an honest partial close, correctly labeled as partial, with a concrete revisit trigger** — not a silently narrowed claim.

### 5a. Phase 6 addendum — two gaps found in the roster duplicate check (§2), fix in progress

`@security`'s Phase 6 audit found two defects in the duplicate-skill check this report proved
*firing* in §2, both narrower than what "proven firing" should be read to cover:

- The comparison is case-sensitive and comma-separated only, so a `Note-Taking` / `note-taking` pair
  in the same preset's roster passes undetected — the check proves duplicates are caught, not that
  *all* duplicate forms are caught.
- The line extraction (`ROSTER_LINE=$(grep …)`) is unguarded, inconsistent with the two sibling
  extractions immediately around it in the same job, which do carry the `|| true` guard this report
  verified in §2.

Both are being fixed at implementation. Noted here so this report's own §2/§5 entries for the
duplicate check aren't read as a completeness claim beyond what was actually tested — the check
fires on the case it was tested against; it was not tested against a case-variant duplicate, and
that gap is real.

---

## 6. Process finding — a false BLOCK from external tooling, root-caused and fixed at the input

During this grading pass, my write to this file was blocked with `BLOCKED: Phase 4 (Implementation)
status is '—', not DONE`, by the external pipeline tooling that orchestrates this repo's AI
development cycles (not a check that ships inside this repository) — even though Phase 4 was DONE
and CI was green throughout. Root cause (diagnosed by the orchestrator, not guessed): a
status-parsing gap in that external tooling. An unrelated provenance annotation, recorded purely to
log spawn parameters, was close enough in shape to a real phase-status entry that the parser could
not tell them apart, and its placeholder value was read as the phase's actual status. The parser was
reading exactly what was given to it; **the input was wrong, not the parser.** Fixed by correcting
the input — the annotation was reworded so it no longer resembles a status entry — rather than by
editing a status field to satisfy the check.

Recorded here because it's a real Phase-5 finding about this cycle's own process integrity, not
because it's a defect in anything this repository ships. Deliberately left at that level of detail:
the lesson (verify whether a failing check or its input is wrong before touching either — the same
discipline applied to every negative control in §2) doesn't require reproducing the failing check's
own matching logic, and a public report is not the place to do so. Recommended as a candidate for
this project's process retrospective.

---

## Verdict

**PASS.** Recommend proceeding to Phase 6 (`/audit`). One non-blocking finding (§1a, `README.md:91`) recorded as a v2.19.10 carry-forward candidate; one process finding (§6) recommended for the Phase 8 retro's pattern-candidate list.
