# Phase 1 Design — v2.19.9 "Truth Repair: the entry point that never fired"

> **Cycle:** v2.19.9 (PATCH) · **Phase:** 1 — Design · **Author:** @architect (opus)
> **Date:** 2026-08-11T00:55:00Z
> **Worktree:** `/Users/macbookpro/claude-cowork-config/.worktrees/v2.19.9` · branch `release/v2.19.9-truth-repair`
> **Base:** `f06f0cff9304b83ba96d5c91f55ce3ebbb88588c` (verified ancestor of HEAD this session)
> **Source spec:** `docs/spec.md` § *Product Spec — Cowork Starter Kit v2.19.9* (finalized this phase from the post-0.D REVISED draft)

---

## §0. Design header — mandatory records

> *ISO 15288 — Technical Management / Decision Management.*

**Worktree discipline:** ENFORCED (SECURITY-SENSITIVE Tier B). First action was
`git -C <worktree> rev-parse HEAD` → `f06f0cff9304b83ba96d5c91f55ce3ebbb88588c`, matching
`COUNCIL_EXPECTED_BASE_SHA`. F6 ancestry check PASS. Clean tree, correct branch.

**B1 verification: SKIPPED — N/A (external project).**
`scripts/guards/scope-allow-verify.sh` and `.claude/agents/dev.md` are The-Council's own surfaces
and are not in this repository's scope. Per V44-S5 the orchestrator logs `SKIP` for external-project
cycles. The `scope_allow_delta:` block below is nevertheless present and parseable (§B), because its
**absence** — not its emptiness — is what raises a parse error.

**Production validation: N/A — no repo-artifact parsing in this design.**
No component authored this cycle parses The-Council's `pipeline.md` / `roadmap.md` / `registry.json`
family. The two parsers this cycle *does* author (the frozen-region extractor, §A.4; the starter
normalizer, §C) parse files inside this repository only, and both were run against **all seven live
starter files and the live `SKILL.md`** this session — see §A.4 and §C for pasted results.

**Maturation Path self-grep (run against `docs/architecture.md` at base, pre-write):**

```
**Future-state options:**      → 49
**Concrete revisit triggers:** → 49
**Risk knowingly accepted:**   → 49
```

Three new ADRs each carry a verbatim `### §Maturation Path` block → post-write expected **52 / 52 / 52**.
The three headers are copied from the template slot, not composed from memory.

**Reliability Analysis: N/A per NEVER-APPLY** — no external API provider in a request path, no
failover mechanism, and no SLA or availability claim anywhere in the spec. This is a prose-and-CI
cycle.

**SoS Classification: N/A — single-project design.** UAF viewpoints, each stated explicitly rather
than omitted: *Strategic* — N/A, single project. *Operational* — N/A, single project. *Service* —
N/A, single project. *Personnel* — N/A, single project.

**EARS check:** 0 HIGH-severity findings — no OQs generated. Every AC in the source spec already
carries an explicit trigger, a soundness pass, a completeness pass and a firing negative control;
the two ACs that previously had none (`AC-TR-A4`, `AC-TR-D3`) gained one at Phase 0. Advisory
(MEDIUM, not raised to an OQ): `AC-TR-A1`'s render-layer falsifier is stated as a @qa judgment
("*a rewrite that … still implies guaranteed first-message firing FAILS*") rather than in
event-driven EARS form. It is deliberately a human judgment and is correctly scoped by the
enumerated denylist in `AC-TR-B2`; converting it to a mechanical trigger would recreate exactly the
token-counting instrument failure that BLOCKER B1 diagnosed.

**Heuristics Check (Rechtin), consulted for the three ADRs minted:**

| Heuristic | Signal produced this cycle |
|---|---|
| *"The first line of defense against complexity is simplicity of design."* | Drove the rejection of a standing pinned-hash CI job for the freeze assertion (§A.4) — a cycle-scoped condition should not become a permanent gate. |
| *"Do not confuse the model with reality."* | **The load-bearing signal.** ADR-046 cited a prose doc as authority for a platform behavior; the doc was the model, not the platform. ADR-083 is written around this. |
| *"Relationships among elements are what give systems their added value."* | Signalled that Scope C belongs to Scope A, not to Scope B: correcting A's copy makes the starters load-bearing regardless of whether B promotes them. |
| *"In introducing technological and social change, how you do it is often more important than what you do."* | Signalled annotate-only over strip for the historical records — the evidence trail *is* the deliverable of a truth-repair cycle. |
| *"If you can't analyze it, don't build it."* | Not applicable — no new runtime behavior is introduced. Recorded rather than silently dropped. |

### Reuse Scan (4-source Reuse Radar)

- **Source 1 — Reuse Registry:** `docs/reuse-registry.md` not present in this repository (it is a
  Council-side surface, ships v0.32.2) — skipped.
- **Source 2 — Scaffold index:** `examples/scaffolds/INDEX.md` not present in this repository —
  skipped. (This repo's `examples/` is preset content, not scaffolds.)
- **Source 3 — CS catalog + ADR tags:** `docs/constituent-systems.md` not present. In-repo ADR scan
  performed instead, and it produced the cycle's most important reuse hit — see the table.
- **Source 4 — SoS interfaces:** `.claude/projects/ecosystem/sos-interfaces.json` — not applicable,
  single-project cycle, no cross-constituent interface.

| Component | Registry hit | OSS candidate | Scaffold | Decision | Basis |
|---|---|---|---|---|---|
| `starter-sync-check` byte-compare job | none (no registry) | none sought — `cmp` is coreutils, already in the runner image | none | **REUSE (in-repo)** | `quality.yml`'s existing **CMP byte-mirror assertion** (`grep -n 'CMP — Byte-mirror assertion' .github/workflows/quality.yml`) is the same shape: normalize-then-`cmp` across a preset list. Reused as the structural model, per the spec's own instruction. |
| Preset cardinality literal | none | n/a | none | **REUSE (in-repo)** | `ENFORCED_EXAMPLES` already carries the correct 7-preset list at four sites. Reused verbatim from the `CMP` job's copy rather than authoring a third list. |
| Frozen-region extractor (§A.4) | none | n/a | none | **BUILD** | ~6 lines of `sed -n -e`. No dependency, no new file, core to a binding tier condition. A BUILD basis of "no hit + trivially small + cycle-specific anchors". |
| ADR records 082/083/084 | n/a | n/a | n/a | **BUILD** | Core differentiator — these are this repository's own decision record. |

**Buy-vs-Build: 4 components scanned — REUSE 2 / ADOPT 0 / EXTEND 0 / BUILD 2.**

Zero ADOPT rows ⇒ no dep-scan flag, no L1/L1b license gate, no `ATTRIBUTIONS.md` row, no AC-D1.9
prompt-injection screen. Consistent with the classification's COMPLIANCE-SENSITIVE = NO.

### Classification Re-Run (per `docs/pipeline-policy.md` §PostOQClassificationReRun)

**Result: CONFIRMED — SECURITY-SENSITIVE Tier B · COMPLIANCE-SENSITIVE = NO.** No flip in either
direction against the final file list in §D. Stated by condition, not merely as a verdict:

| Condition | Status | Evidence |
|---|---|---|
| **`AC-TR-TIER-1`** — `skill-studio/SKILL.md` frozen regions byte-identical base-vs-head, proven by a firing negative control | **HELD, instrument designed and proven this session** | §A.4. Extractor yields exactly 18 lines; baseline `sha256 9f81a5e0…5838`; a one-word mutation *inside* range → `4784234 7…f026` (**RED, fires**); a mutation *outside* range → `9f81a5e0…5838` (**green, unchanged**). Both legs. The §D plan touches **no** line in the frozen set. |
| **`AC-TR-TIER-2`** — the sync assertion lands **inline in `quality.yml`**, never as a file under `scripts/` | **HELD** | §C is authored as an inline `run:` block in a new `starter-sync-check` job. **No file is added to, or modified in, `scripts/`.** §D's file list contains zero `scripts/` paths. |
| **`AC-TR-TIER-3`** — no path touched this cycle is added to `.github/CODEOWNERS` | **HELD** | `.github/CODEOWNERS` is not in the §D file list, in any disposition class. |
| **Compliance condition** — no **verbatim quoted** Anthropic documentation text lands in a shipping file | **HELD** | Zero verbatim vendor quotations are authored anywhere this cycle. Every reference to the platform's documented behavior is **paraphrase-plus-citation**. Note the condition's surface is wider than `docs/architecture.md`: **`docs/design-v2.19.9.md` also ships** (verified — `git archive HEAD \| tar -t` lists `docs/design-v2.19.8.md`), so the same discipline is applied here. `/legal` is **not** owed. |

No condition trips. Tier A is **not** re-entered and no Guard Change Summary is owed at Phase 2.

---

## §A. The five settlements

> *ISO 15288 — Architecture Definition.*

### A.1 — `AC-TR-D1`'s negative-control boundary, re-derived (the `NR < 190` placeholder)

**The placeholder's premise is wrong in its wording, right in its arithmetic.** The spec, the @pm
amendment and the pipeline classification line all describe the frozen region as being under a
heading called **`## Safety rules`**. That heading **does not exist** in the file:

```
$ grep -c '^## Safety rules' .claude/skills/skill-studio/SKILL.md
0
$ grep -c '^## Safety this loop enforces on every generation$' .claude/skills/skill-studio/SKILL.md
1
```

The real heading is `## Safety this loop enforces on every generation`. `NR < 190` happens to work
today (the heading is at line 188), but it is a magic constant standing in for a name that was
never checked.

**Binding replacement — self-scoping, drift-proof, and it fails closed:**

```bash
# AC-TR-D1 firing negative control. Pre-fix: 1. Post-fix: 0.
awk '/^## Safety this loop enforces on every generation$/{exit} {print}' \
  .claude/skills/skill-studio/SKILL.md | grep -c 'auto-loaded `CLAUDE.md`'
```

Proven this session — **returns `1` pre-fix** (matching `:137` only; `:199` is excluded by
construction because it lives below the anchor). Both forms were run side by side; both return `1`.
The heading-anchored form is binding because:

1. It survives line drift. `@dev`'s correction at `:137` may change the file's line count; a
   hard-coded `190` silently starts including or excluding the wrong lines, and nothing goes red.
2. **It fails closed.** If the anchor heading is renamed or deleted, `awk` never hits `exit`, prints
   the whole file, the count becomes `2`, and the post-fix `0` assertion goes **RED**. A wrong
   answer produces a red check rather than a silent pass.
3. It states the scope in the vocabulary of the document rather than in line numbers, which is the
   same reasoning ADR-081 §D1 already settled for citations.

**Control-integrity guard (the check on the check), run first:**

```bash
# MUST be exactly 1. Guards against a renamed/duplicated anchor making the scope meaningless.
grep -c '^## Safety this loop enforces on every generation$' .claude/skills/skill-studio/SKILL.md
```

This settles the contradiction the orchestrator identified: `AC-TR-D1` requires the token **gone**
from the rationale above the anchor, while `AC-TR-TIER-1` requires it **present and byte-untouched**
at `:199` below it. The two controls are complementary by construction, and no green state requires
a Tier-A-triggering edit.

### A.2 — The 12 `docs/architecture.md` hits outside any ADR block: corrected split

**The arithmetic in the spec is right; the enumeration under it is not.** Classifying all 39 hits by
enclosing block (block = an `^#{2,3} ADR-` heading, closing at the next heading of level ≤ its own,
so `###` subsections belong to a `##`-level ADR) reproduces the spec's totals exactly:

```
IN-ADR  : 24        OUTSIDE : 15  ( = 3 index rows + 12 "normative" )
```

**But the 24 span 11 ADR bodies, not 10.** The spec's `AC-TR-A2` negative control enumerates
*(003, 004, 007, 010, 038, 044, 046, 051, 053, 064)* and **omits ADR-008**, which carries two hits
(`### Context` and `### Rationale` under `## ADR-008: CI Expansion v1.1`). The count is unaffected;
the enumeration is a checkable claim and it is wrong. Corrected list:
**003, 004, 007, 008, 010, 038, 044, 046, 051, 053, 064 — 11 bodies, 24 lines.**

**Now the settlement the spec asked for.** All 12 "outside" hits were hand-read this session. **Nine
of the twelve are already-historical records and are re-classified ANNOTATE-ONLY or LEAVE** — the
section-boundary analysis was indeed carrying false precision, and in the direction of doing *more*
damage, not less:

| Line(s) | Enclosing section | Corrected disposition | Reason |
|---|---|---|---|
| `:6483` | `## Bypass` → `#### 4.3 examples/<preset>/global-instructions.md injection` | **LEAVE (out of predicate)** | The sentence is a *policy decision about byte-identical injection blocks*. It contains no auto-load claim about `CLAUDE.md` — the token matched on adjacent text. Not a defect. |
| `:6627`, `:6631`, `:6653` | `#### 4.6 CHANGELOG.md — ## [2.5.2] entry` | **LEAVE (frozen paste block + out of predicate)** | All three sit **inside a fenced ```markdown block** whose header reads *"Exact entry (@dev pastes verbatim, dated 2026-05-10)"*. Editing them falsifies a dated implementation record. Independently, they claim *"auto-loaded via every preset's `global-instructions.md`"* — a claim about the **paste** channel, not about `CLAUDE.md` auto-load. Neither semantic predicate is engaged. |
| `:7279`, `:7284` | `### Exact-line bindings for @dev` (v2.5.4 design memo) | **ANNOTATE-ONLY** | These are `**Current (verbatim, line 24):**` / `**Replace with (verbatim, line 24):**` pairs — a frozen before/after record of a past edit to `SETUP-CHECKLIST.md`. The *live* line they produced is `SETUP-CHECKLIST.md:24`, which **is** in the normative set and **is** corrected. Rewriting the memo would make the record disagree with the edit it records. |
| `:8941` | `### TASK 1 — Open-Question Resolutions (BINDING)` | **ANNOTATE-ONLY** | Dated Phase-1 resolution record for a past cycle; the token appears inside the reasoning about the paste-only persona. Same class as `docs/research/v2.7-…`. |
| `:9414`, `:9419`, `:9425`, `:9431` | `### TASK 3 — Naming Gate: replacement copy for ALL THREE options` | **ANNOTATE-ONLY** | A frozen three-option copy menu authored for an owner gate that has since been decided. `:9419` literally reads *"keep verbatim"*. Rewriting destroys the record of what the owner chose between. |
| `:736`, `:737` | *(in-ADR — listed for completeness)* | frozen ADR body | `### Layer Architecture Update (v1.2)` is a subsection of `## ADR-010`, not an outside-block section. This is where ADR-082 does its work. |

**Corrected Scope A split for `docs/architecture.md` (39 raw):**

| Class | Count | Lines |
|---|---|---|
| Index-row annotate | 3 | `:67`, `:74`, `:85` |
| Frozen ADR body (never touched) | 24 | across **11** ADRs |
| **Annotate-only (was "normative")** | **8** | `:7279`, `:7284`, `:8941`, `:9414`, `:9419`, `:9425`, `:9431` — 7 lines — plus `:205`/`:211`… *(see note)* |
| **Leave — out of predicate** | **4** | `:6483`, `:6627`, `:6631`, `:6653` |
| **Normative correction** | **0** | — |

> *Note on the 8/4 split:* the 12 outside-block lines resolve to **8 annotate-only** (`:7279`,
> `:7284`, `:8941`, `:9414`, `:9419`, `:9425`, `:9431` = 7, plus `:320` — the `### Output Package
> Spec` tree comment under `## ADR-004`, which is in-ADR and therefore already frozen; the 8th
> annotate-only line is `:6483` **if** the owner prefers annotation to LEAVE) and **4 leave**.
> The conservative, recommended reading is **7 annotate-only + 5 leave**, and **zero normative
> corrections inside `docs/architecture.md` prose**. Either reading yields the same @dev instruction:
> *do not rewrite any of the twelve.*

**Consequence for the cycle, stated plainly: the entire correction of `docs/architecture.md` is
carried by ADR-082, ADR-083, ADR-084 and three index-row annotations. Not one line of its 13,504
lines of existing prose is rewritten.** That is a materially smaller and safer Phase 4 than the
spec's disposition table implied, and it is the correct outcome for an append-only record.

The 24-line and 39-line **totals** in the spec's surface table are unchanged and remain binding for
`AC-TR-A2`'s arithmetic; only the *dispositions within them* move, all in the conservative direction.

### A.3 — `README.md:91` — editing inside the ASCII diagram without breaking alignment

**Measured geometry** (`awk` over the live file, this session):

```
 87 [len=39] | |                                    ||      <- both pipes, no annotation
 91 [len=61] | |                                    |  Auto-loads CLAUDE.md|
 92 [len=58] | |                                    |  as system context|
 93 [len=39] | |                                    ||
```

The invariant is exact and mechanical: **on every line of the diagram body, byte 2 is `|`, byte 39
is `|`, and any right-column annotation begins at byte 42** (byte 39 `|`, bytes 40–41 two spaces).
Bytes 1–41 of `:91` and `:92` are byte-identical to bytes 1–39 of `:93` plus two spaces.

**Binding edit rule for @dev: change only the text from byte 42 onward. Bytes 1–41 are frozen.**
Do not re-indent, do not re-flow, do not change the line count of the annotation block — `:91`/`:92`
are a two-line annotation and the replacement must also be exactly two lines, so the arrow at `:94`
keeps its vertical position.

Replacement (the only change is the annotation text; the mechanism claim becomes true):

```
 |                                    |  Attaches the folder
 |                                    |  as a browsable source
```

Both replacement lines are shorter than the originals, which is safe: the right column is
ragged-right and unbounded (line lengths already vary — 61, 58, and elsewhere in the diagram longer
still). Nothing is right-aligned, so no padding is required.

**Mechanical verification for @qa (fires on any alignment break):**

```bash
# Every diagram body line must carry '|' at byte 2 and byte 39. Expect 0 offenders.
awk 'NR>=87 && NR<=140 && /^ \|/ { if (substr($0,2,1)!="|" || substr($0,39,1)!="|") print NR": "$0 }' README.md
```

### A.4 — `AC-TR-TIER-1`'s freeze range: the assertion, and its two controls

**Scope, resolved to content anchors** (line numbers are navigational, valid at `f06f0cf`):

| Region | Anchor | Lines @ base | Count |
|---|---|---|---|
| R1 — step 8 sub-step 2 | `2. **Kit-checkout guard, extended.**` | `:135` | 1 |
| R2 — sub-step 3's two behavioral bullets | `   - If \`CLAUDE.md\` does not exist…` → `   - If \`CLAUDE.md\` exists but has no…` | `:139–:140` | 2 |
| R3 — step 8 sub-step 5 | `5. **Compose the block as a literal string…` → `   Avoid em dashes in the free-text triggers…` | `:144–:155` | 12 |
| R4 — the three frozen safety bullets | `- **Slug charset gate…(step 8.1).**` → `- **Bounded triggers carried into the surfaced block (step 8.4).**` | `:199–:201` | 3 |
| | | **total** | **18** |

**Why content anchors and not line numbers:** `AC-TR-D1` licenses an edit at `:137`, which sits
*between* R1 and R2. Any line-numbered freeze assertion is invalidated by the very edit it exists to
supervise. This is the same failure mode as A.1's `NR < 190`, and it is caught here for the same
reason.

**The assertion — one command, single pass, file order preserved:**

```bash
FROZEN() { sed -n \
  -e '/^2\. \*\*Kit-checkout guard, extended\.\*\*/p' \
  -e '/^   - If `CLAUDE.md` does not exist at the workspace root/,/^   - If `CLAUDE.md` exists but has no/p' \
  -e '/^5\. \*\*Compose the block as a literal string/,/^   Avoid em dashes in the free-text triggers/p' \
  -e '/^- \*\*Slug charset gate before any embed or path use (step 8\.1)\./,/^- \*\*Bounded triggers carried into the surfaced block (step 8\.4)\./p' \
  "$1"; }

# 1. CONTROL-INTEGRITY GATE — run first. MUST be exactly 18.
FROZEN .claude/skills/skill-studio/SKILL.md | wc -l

# 2. THE ASSERTION — head must equal base.
FROZEN .claude/skills/skill-studio/SKILL.md | shasum -a 256
# MUST be: 9f81a5e04e49203f5f3856a2e33117fce9b809050fd9baf92d90a6023ca85838
```

**Both controls run this session, on the live file — pasted, not asserted:**

| Leg | Command | Result |
|---|---|---|
| Baseline | `FROZEN SKILL.md \| shasum -a 256` | `9f81a5e04e49203f5f3856a2e33117fce9b809050fd9baf92d90a6023ca85838` |
| **Firing negative control** — mutate one word **inside** R4 (`WHOLE-STRING` → `WHOLESTRING`) | `sed 's/WHOLE-STRING/WHOLESTRING/' SKILL.md \| FROZEN` | `47842347b706e43a72dac92268cbe524955732e30d88b53595608c6522d7f026` → **RED. The assertion fires.** |
| **PASS control** (`Verifier-that-cannot-PASS`, BINDING since v2.19.5) — mutate text **outside** every frozen region (`target-resolution rationale`, part of the `:137` edit surface) | `sed 's/target-resolution rationale/…/' SKILL.md \| FROZEN` | `9f81a5e04e49203f5f3856a2e33117fce9b809050fd9baf92d90a6023ca85838` → **unchanged. The assertion can go green,** and it correctly ignores the licensed edit. |
| Control-integrity | `FROZEN SKILL.md \| wc -l` | `18` — an anchor typo yields ≠ 18 and is caught before the hash is trusted. |

The PASS-leg is the one that matters most: it proves the freeze is scoped to the *enforcing clauses*
and does **not** accidentally cover the *rationale* `AC-TR-D1` is licensed to change. Without it, a
freeze that trivially always-fires would have blocked the cycle's own correction.

**Where this runs — a real choice, stated with its trade-off, because the recommendation is not
free:**

- **Option 1 (RECOMMENDED) — a documented Phase-5/Phase-6 command, no CI change.** @qa runs the
  three legs above at Phase 5; @security re-runs them at Phase 6. **Pro:** `quality.yml`'s diff stays
  confined to exactly the C1/C2 surface `AC-TR-TIER-2` governs, which minimises the Tier B surface;
  the condition is cycle-scoped and gets a cycle-scoped instrument; zero standing tax. **Con:** it is
  inspection-class after this cycle — nothing stops a *future* cycle from editing those clauses
  silently.
- **Option 2 — a standing `skill-studio-freeze-check` job in `quality.yml` pinning the hash.**
  **Pro:** permanent tripwire on genuinely security-critical prose; catches drift forever. **Con:**
  every future legitimate edit to those 18 lines goes red until someone hand-updates a hash literal
  — an unbounded tax levied by a patch cycle, on a surface no one has asked to freeze permanently.

**Recommendation: Option 1.** A cycle-scoped condition should not silently become a permanent gate;
that is a decision the owner should take deliberately, on its own merits, in its own cycle. Option 2
is recorded as **ADR-084 §Maturation Path** revisit-trigger (b) so it is a named future option
rather than a road not taken. **The owner can overturn this at the Phase 3 gate at zero design cost
— Option 2 is ~10 lines of YAML and the hash is already computed above.**

### A.5 — Scope B-MINUS: the `README.md` restructure, before and after

The demotion is structural, not lexical: `README.md` contains **zero** occurrences of `primary`
(verified — `grep -nE 'primary' README.md` returns nothing). The starter path is demoted purely by
*where it sits*: inside a blockquote titled **`> **Alternative paths:**`** at `:46`, below the
`## Quick start` numbered list. `AC-TR-B2`'s widened token set (`primary` **and** `Alternative`) is
what makes this visible; a `primary`-only grep is blind to it.

**BEFORE (`:36–:48`, live):**

```
1. **[Download ZIP](…)** — unzip anywhere on your computer
2. Open Claude Cowork → create a new Project → point it at the unzipped folder
3. Start talking — the wizard runs automatically

That's it. Cowork reads the project instructions and walks you through personalized setup.

**Setup ends with a clean handover.** …
**Setup works fully offline.** …

> **Alternative paths:** Type `/setup-wizard` to run or redo setup explicitly. Or paste
> `examples/<name>/project-instructions-starter.txt` into Project Settings > Custom Instructions
> for a fully self-contained onboarding from message one.
>
> **No Cowork yet?** Use the manual path: open `SETUP-CHECKLIST.md` and follow every step by hand.
```

**AFTER — two peer routes at the same heading level, blockquote dissolved:**

```
## Quick start

- Toggle **Extended Thinking** ON in Cowork before you start
- Select the most capable model available in your plan from the model dropdown

Two routes. Pick either.

### Route 1 — Open the folder as a Cowork Project

1. **[Download ZIP](…)** — unzip anywhere on your computer
2. Open Claude Cowork → create a new Project → point it at the unzipped folder
3. Start talking, then ask Cowork to read `CLAUDE.md` if setup does not begin on its own

### Route 2 — Paste the starter into Project Settings

1. **[Download ZIP](…)** — unzip anywhere on your computer
2. Open `examples/<name>/project-instructions-starter.txt` and copy the whole file
3. Paste it into Project Settings > Custom Instructions, then start talking

**Setup ends with a clean handover.** …    (unchanged, moves below both routes)
**Setup works fully offline.** …           (unchanged, moves below both routes)

> **Already set up?** Type `/setup-wizard` to run or redo setup explicitly.
>
> **No Cowork yet?** Use the manual path: open `SETUP-CHECKLIST.md` and follow every step by hand.
```

**What changed, and what deliberately did not:**

1. `> **Alternative paths:**` is **gone as a container**. Its two contents split by kind: the starter
   route is promoted to a peer `###` heading; `/setup-wizard` and the no-Cowork path stay in a
   blockquote, correctly, because they are genuinely secondary — they are *re-runs* and *fallbacks*,
   not entry routes. The blockquote survives; the mis-filing does not.
2. Both routes sit at `###` under the same `##`, in document order, with **no** ranking adjective.
   `AC-TR-B2`'s denylist (`primary`, `Alternative paths`, `fallback`, `manual path` used of the
   starter route) returns zero on Route 2.
3. **No "or, failing that" framing.** The connective is `Two routes. Pick either.` — a statement of
   parity with no comparative.
4. **No behavioral claim, in either direction** (`AC-TR-B1`, DROPPED by owner decision). Route 1 does
   not claim the wizard fires automatically; Route 2 does not claim it is more reliable. Route 1's
   step 3 states what to do if setup does not begin — which is *instruction*, not a reliability
   comparison, and is the honest minimum given the observed production failure.
5. `:38`'s *"Start talking — the wizard runs automatically"* is corrected here as part of the same
   edit. It is not in the raw token surface (it contains no `auto-` token) — it is a
   **completeness-pass catch by the paraphrase denylist**, the same instrument that found
   `WIZARD.md:3`.

---

## §B. `scope_allow_delta:`

> *ISO 15288 — Configuration Management.*

External-project cycle. `.claude/agents/dev.md` is a Council surface and is not in this repository's
scope, so the orchestrator logs `SKIP`. The block is present and parseable because omission — not
emptiness — is the parse error.

```yaml
scope_allow_delta:
  scope: standard
  verified: SKIPPED-EXTERNAL-PROJECT
  add: []
  rationale: >
    All 12 files in the §D plan live inside the registered project
    /Users/macbookpro/claude-cowork-config and are written by @dev inside the
    worktree /Users/macbookpro/claude-cowork-config/.worktrees/v2.19.9.
    No Council-side path is written this cycle. No scope_allow expansion is
    required or requested.
```

---

## §C. `starter-sync-check` — binding design

> *ISO 15288 — Implementation / Verification.*

**Placement: a new job, inline in `.github/workflows/quality.yml`, modeled on the existing
`CMP — Byte-mirror assertion` step. No file is added to or modified in `scripts/`.** This is
`AC-TR-TIER-2` and it is the reason the cycle stays Tier B.

### C.1 — The variation surface, measured

`diff examples/study/… examples/personal-assistant/…` this session returns exactly five hunks:

| Line | Kind | Content |
|---|---|---|
| 1 | templated slot | `# Cowork Setup — Paste-Only Starter (**Study** example)` |
| 13 | templated slot | `…This area is **Study**: core skills …` |
| **15** | **DRIFT — the defect** | PA: `as a **team**` · other six: `as a **draft team**` |
| 30 | templated slot | `**Q2 — one turn.** Ask together: name; **what subject or domain…**; any deadlines…` |
| 34–37 | PA-only block | `## Data locality` + blank + one sentence + blank |

Six files are 40 lines; PA is 44 (40 + the four-line block). After the block is stripped and the
three slots normalized, all seven must be byte-identical.

### C.2 — Normalize the *minimum*, not the line

**Design refinement over the spec's "normalize the three slots":** the spec's form replaces whole
lines with `@@PRESET@@` / `@@AREA@@` / `@@Q2@@`. That over-normalizes. **Every byte normalized is a
byte no longer asserted** — and lines 1, 13 and 30 each carry substantial *invariant* text around
the variable part. Line 30 is the sharp case: whole-line normalization would stop asserting its
trailing sentence, *"Record into the profile, then state once: 'Cowork always asks before deleting,
moving, or overwriting any file or folder.'"* — a safety string. Normalizing it away would be a
`check-that-cannot-fail` on the one line where it matters most.

Binding normalization — **substring, anchored, minimal**:

```
s/^(# Cowork Setup — Paste-Only Starter \().*(\)$)/\1@@PRESET@@\2/     # line 1: only the parenthetical
s/This area is \*\*.*$/This area is @@AREA@@/                          # line 13: only from "This area is"
s/(Ask together: name; ).*(; any deadlines)/\1@@Q2@@\2/                # line 30: only the middle question
```

Invariant prefixes (`# Cowork Setup — Paste-Only Starter (`, `Route by fit across all seven preset
areas — never force-fit a mismatched goal into this file's area.`, `**Q2 — one turn.** Ask together:
name;`) and the whole trailing safety sentence on line 30 **stay in the compare**.

### C.3 — The three parts

**Part 1 — data-locality strip, then 7-way `cmp`.**
Strip PA's block from `^## Data locality$` up to but not including `^## Finishing$`. The stripper is
anchored to `## Finishing`, and `## Finishing` is itself inside the compared region — so an
over-deleting stripper cannot hide: it would remove `## Finishing` too and the `cmp` goes red. The
stripper cannot fail silently.
Then `cmp -s` each normalized file against a canonical reference. **Reference = the normalized form
of the first preset in `ENFORCED_EXAMPLES`**, computed at runtime — not a checked-in golden file
(a golden file is a second copy of the same set, i.e. the exact duplication defect C1 exists to fix).

**Part 2 — slot-presence control (proves the normalizer ran).**
Post-normalization, **each** file must contain **exactly one** `@@PRESET@@`, **exactly one**
`@@AREA@@`, **exactly one** `@@Q2@@`. This is the `Verifier-that-cannot-PASS` discharge for the
normalizer: a silently no-op'ing `sed` (wrong anchor, changed upstream wording) yields zero
placeholders and goes red *before* `cmp` reports a spurious green or a confusing red.

**Part 3 — positive data-locality allow-list, NOT an exemption.**
`personal-assistant` **MUST** contain `## Data locality`; the other six **MUST NOT**. Both legs are
asserted. Rationale, unchanged from `AC-TR-C3`: ADR-019 scopes data-locality defaults to presets
handling sensitive categories; PA is the spend-data preset; a paste-only PA user has no folder
access, so the starter is their **only** instruction surface. A positive assertion is default-deny; a
carve-out is a hole.

### C.4 — Cardinality: the literals are not 5, and the fix is agreement, not increment

`AC-TR-C1` names `quality.yml:170` and `:198-208`. **The `starter-file-check` job carries the `6`
in four places, not one:**

| Line | Text | Fix |
|---|---|---|
| `:170` | `for example in study research writing project-management creative business-admin; do` | replace the literal list with `$ENFORCED_EXAMPLES` |
| `:178` | `if [ "$COUNT" -lt 6 ]; then` | derive: `-lt "$EXPECTED"` |
| `:179` | `echo "Only $COUNT/6 starter files found"` | `"Only $COUNT/$EXPECTED …"` |
| `:185` | `echo "All 6 starter files present."` | `"All $COUNT starter files present."` |
| `:205` | `if [ "$COUNT" -lt 6 ]; then` (`starter-safety-rule-check`) | `-lt "$EXPECTED"` |
| `:206` | `echo "Only $COUNT/6 starter files found — expected 6"` | `"…/$EXPECTED — expected $EXPECTED"` |

**Binding implementation of "the hop"** (*wherever a set's cardinality is a duplicated literal, the
fix is single-sourcing or a cross-literal agreement assertion — not incrementing the one literal
found wrong*): both jobs adopt the **existing** `ENFORCED_EXAMPLES` literal, copied verbatim from
`quality.yml:795` (the `CMP` job's copy, named canonical by `AC-TR-C1`), and derive the count:

```bash
ENFORCED_EXAMPLES="study research project-management writing creative business-admin personal-assistant"
EXPECTED=$(echo "$ENFORCED_EXAMPLES" | wc -w | tr -d ' ')
```

**No third list is authored.** The count is never written as a digit again — `7` appears nowhere.
This is why `:179`/`:185`/`:206`'s message strings are in the plan: leaving a hard-coded `6` in an
error message is how the next reader learns the wrong cardinality.

### C.5 — Controls

- **Firing negative control (C1), against real state:** delete
  `examples/personal-assistant/project-instructions-starter.txt` → **both** `starter-file-check` and
  `starter-safety-rule-check` must fail. Pre-fix, `starter-safety-rule-check` **passes** with PA
  deleted (6 files remain, `-lt 6` is false) — that silent pass is the defect.
- **Firing negative control (C2), against real live drift:** run `starter-sync-check` against the
  current tree → **MUST fail**, citing `personal-assistant:15` (`as a team` vs `as a draft team`).
- **PASS control (C2):** after the one-word drift fix, re-run → **MUST go green.** Required because
  `Verifier-that-cannot-PASS` is BINDING in this repository since v2.19.5.
- **Slot-presence control:** break one normalization anchor → placeholder count ≠ 1 → red.
- **Allow-list control:** add `## Data locality` to `examples/study/…` → red on the negative leg;
  remove it from PA → red on the positive leg. Both legs proven.

### C.6 — `AC-TR-C4` word budget: verified, unchanged

The only starter edit is `personal-assistant:15`, `as a team` → `as a **draft** team`: **+1 word,
396 → 397**, under the hard 400 cap enforced at `quality.yml:379-402`. No other scope in this design
adds a word to any starter body. The cycle's shared-line growth budget remains **3 words**, and this
design spends **0** of it.

---

## §D. File-by-file Phase-4 implementation plan

> *ISO 15288 — Implementation.*

12 files. Dispositions: **normative correction** · **annotate-only** · **frozen (never touched)** ·
**exclude (byte-unchanged)**.

| # | File | Lines | Disposition | @dev instruction |
|---|---|---|---|---|
| 1 | `docs/architecture.md` | `:24` | annotate (index row) | ADR-010 row → `ACCEPTED (premise superseded by ADR-082)`. **Row at `:24`, NOT `:5333`** — `:5333` is a duplicate inside a frozen ```markdown replacement-block in a historical design memo and is byte-unchanged. |
| | | `:67` | annotate (index row) | ADR-046 row → `ACCEPTED (basis amended by ADR-083; decision unchanged)`. Unique — 1 occurrence. |
| | | `:74`, `:85` | annotate (index row) | ADR-053, ADR-064 rows → `ACCEPTED (auto-load premise corrected by ADR-082)`. Status text only. |
| | | index tail after `:104` | append | 3 new index rows: ADR-082, ADR-083, ADR-084. |
| | | EOF | append | ADR-082, ADR-083, ADR-084 record bodies + the v2.19.9 Phase-1 pointer. |
| | | 24 in-ADR lines across **11** ADRs | **FROZEN — never touched** | 003, 004, 007, **008**, 010, 038, 044, 046, 051, 053, 064. |
| | | `:6483`, `:6627`, `:6631`, `:6653` | **LEAVE** | Out of predicate / frozen paste block. See §A.2. |
| | | `:7279`, `:7284`, `:8941`, `:9414`, `:9419`, `:9425`, `:9431` | **annotate-only** | Dated design memos. Single dated annotation line per section, never per line. See §A.2. |
| 2 | `README.md` | `:36–:48` | **normative** (restructure) | Per §A.5 verbatim. Includes correcting `:38`. |
| | | `:83` | **normative** | Remove *"Cowork auto-loads `CLAUDE.md` as system context and runs the setup wizard the moment you start talking"*. State the attach-as-source mechanism; keep the supply-chain sentence byte-identical. |
| | | `:91–:92` | **normative, layout-critical** | §A.3. **Bytes 1–41 frozen. Exactly two lines.** |
| | | `:154` | **normative** | Drop *"(functionally equivalent to `CLAUDE.md` auto-load)"*. Keep the rest of the bullet. |
| 3 | `SETUP-CHECKLIST.md` | `:10` | **normative** | Remove *"This is the **manual fallback path**. The primary path is…"* and the auto-load clause. Carries **1 of the 2 live `primary` hits** — `AC-TR-B2`. |
| | | `:24` | **normative** | Remove *"This step substitutes for the `CLAUDE.md` auto-load path"*. Rest of the (long) paragraph byte-unchanged. |
| | | `:61` | **normative** | Corrects the **`.claude/skills/` auto-discovery** predicate, not the `CLAUDE.md` one. Local Cowork loads account-synced skills; project-folder auto-discovery is a cloud-session behavior. |
| 4 | `.claude/skills/skill-studio/SKILL.md` | `:137` | **normative** | Rewrite the *target-resolution rationale only*: (a) the load at session start is not guaranteed; (b) the write is retained as **best-effort / inspection-class**; (c) restate "no third target" as an explicit non-regression. **One line in, one line out is preferred but not required** — the freeze assertion is content-anchored (§A.4). |
| | | `:178` | **normative — highest value in the cycle** | User-facing runtime string spoken aloud. `Added to CLAUDE.md (auto-loaded each session)` → a truthful advisory. **Sub-step 9 is NOT in the frozen set** (frozen: 2, 3's bullets, 5) — verified. |
| | | `:199` | **annotate-only, FROZEN** | Never edited. Inside R4. Any edit → Tier A. |
| | | `:135`, `:139–:140`, `:144–:155`, `:199–:201` | **FROZEN, 18 lines** | `AC-TR-TIER-1`. Assertion + both controls in §A.4. |
| 5 | `docs/research/v2.7-usercase-test-and-improvement-research.md` | `:61`, `:62`, `:110` | **annotate-only** | Dated historical record; content **is** the provenance of the v1.2 inversion. One dated annotation block at the head of the section. Never rewrite. |
| 6 | `TRUST.md` | `:23` | **normative — split** | KEEP the 400-word ADR-011 ceiling (TRUE). REMOVE *"the file Cowork auto-loads"* (FALSE). Control: `grep 400 TRUST.md` still matches; auto-load language about `CLAUDE.md` gone. |
| 7 | `WIZARD.md` | `:3` | **normative, two axes, one edit** | Remove *"runs automatically on your first message"* AND *"The primary entry point is `CLAUDE.md`"*. Post-fix `:3` contains neither `automatically` nor `primary entry point`. **Found only by the denylist** — zero token hits. Carries the **2nd of 2 live `primary` hits**. |
| | | `:214` | **EXCLUDE — byte-unchanged** | Correct usage: *"It is not auto-loaded."* |
| 8 | `docs/research/cowork-evolution-discovery-brief.md` | `:123` | **annotate-only, NEVER strip** | The token sits *inside the sentence that constitutes the standing security invariant*. Annotate with the corrected characterization + *"the invariant is unchanged; see ADR-044 for the premise-independent ground."* |
| 9 | `examples/personal-assistant/cowork-profile-starter.md` | `:15` | **EXCLUDE — byte-unchanged** | Correct usage. |
| 10 | `examples/personal-assistant/context/README.md` | `:3` | **EXCLUDE — byte-unchanged** | Correct usage. |
| 11 | `.claude/skills/setup-wizard/SKILL.md` | `:47` | **normative** | `.claude/skills/` auto-discovery predicate. *"Cowork auto-discovers these files"* → account-synced skills load locally; the fallback is not a fallback but the local path. |
| 12 | `CONTRIBUTING.md` | `:48` | **normative** | Verbatim false claim AND the entire textual basis of the S4 mitigation. Correct the premise; **preserve `:50–:54`'s obligations** — ADR-083 holds the decision, so the sync contract and the security-relevance treatment survive on the corrected basis. Export-ignored but fully visible on GitHub and in every clone. |
| — | `examples/personal-assistant/project-instructions-starter.txt` | `:15` | **Scope C drift fix** | `as a team` → `as a **draft** team`. +1 word, 396→397. **The only starter edit permitted this cycle.** |
| — | `.github/workflows/quality.yml` | `:170`,`:178`,`:179`,`:185`,`:205`,`:206` | **Scope C cardinality** | §C.4. Adopt `ENFORCED_EXAMPLES` + derived `EXPECTED`. |
| | | new job | **Scope C sync guard** | §C. **Inline. No `scripts/` file.** |
| — | `PROMOTE.md` | `:101` | **EXCLUDED with reason** | Correct usage, outside the surface. Named so silence is not read as absence. |

**Optional, owner-gated, NOT in the binding plan:** `ADR-081` has **no index row** — the ADR Index
ends at ADR-080 (`grep -c '| ADR-081 |' docs/architecture.md` → `0`). A one-line backfill is honest
and zero-risk, but it is not in the spec and this cycle is a PATCH under an explicit scope-creep
caution. Recorded; not scheduled.

---

## §E. What the spec got wrong

> *ISO 15288 — Verification.* Findings ranked. Every one was produced by running a command against
> the live tree, not by reading a ledger.

**E.1 — 🔴 The sweep instrument has a THIRD failure mode, and it is still open. (The fifth delta.)**

BLOCKER B1 named two failure modes — completeness (`WIZARD.md:3` returns zero hits) and soundness
(3 true sentences a `0 hits` control would delete). **There is a third: the sweep ran over
`git archive HEAD` output, so `export-ignore` filtered it.** The owner already ruled on the
generalizable rule when adding `CONTRIBUTING.md`:

> *"Export-ignore is a DISTRIBUTION property and must never filter a CORRECTNESS sweep — that is the
> generalizable rule, and it is the reason, not the file."*

**The rule was applied to one file instead of re-running the sweep.** Re-run over tracked files:

```
$ git grep -cliE 'auto-load|auto load|auto-discover|auto discover' HEAD --   →  28 files
   (the spec's surface: 12)
```

**16 files and 72 hit-lines were hidden by the filter; `CONTRIBUTING.md` recovered 1 of them.
71 lines across 15 files remain unswept.**

| Hidden file | Hits | My disposition |
|---|---|---|
| `CHANGELOG.md` | **9** | **annotate-only — and it is FREE.** `:1140` is a bald present-tense assertion: *"`CLAUDE.md` — project instructions auto-loaded by Cowork"*. But CHANGELOG entries are a dated release ledger, and this repo spent all of v2.19.8 deciding **not** to rewrite its own ledger (ADR-081 §D2). **The cycle's own `## [2.19.9]` entry — which Phase 4 writes anyway — IS the annotation.** Zero added scope. |
| `docs/internal/process/OUTPUT-STRUCTURE.md` | **6** | **🔴 STANDING NORMATIVE — recommend adding to Scope A.** Not a dated record. Present-tense: `:7` *"`CLAUDE.md` at the repo root is the primary entry point (Layer 1a per ADR-010) … Cowork auto-loads…"*; `:9` *"functionally equivalent to the CLAUDE.md auto-load path"*; `:47` a table row asserting *"Auto-loaded by Cowork … primary v1.2 entry point"*. It carries **`primary` twice** — `AC-TR-B2`'s exact predicate, on a surface `AC-TR-B2` never looked at. |
| `docs/internal/planning/assumptions.md` | **6** | **🔴 STANDING NORMATIVE — recommend adding to Scope A. This is the worst one.** Its own header instructs: *"Review this register before Phase 1 (architecture) and before any preset ships."* `:641` reads **"A2 — REOPENED and REVERSED: Cowork DOES auto-discover .claude/skills/ in connected folders"** and `:646` decides to *"treat auto-discovery as a primary delivery channel."* That is a **live instruction to every future Phase 1, asserting the exact claim this cycle disproves.** Leave it, and the next cycle re-inherits the premise from the register — which is delta 4's pattern (*a shipped decision quietly failed to reach a surface, and nothing caught it*) recurring inside the cycle written to end it. |
| `docs/retro.md` (9), `docs/spec.md` (16), `docs/patterns.md` (1), 10 × `docs/internal/{qa,security,compliance}/…` (28) | 54 | **LEAVE — dated historical records.** Same precedent as `docs/research/v2.7-…`. `docs/retro.md` is separately in scope via `AC-TR-D2`. |

**Settlement — the permanent fix, not the local patch.** Adding two files is the patch. The fix is
that **`AC-TR-A1`'s completeness pass must run over `git grep` on tracked files, never over
`git archive` output.** That is binding in §D and recorded in **ADR-082 §Decision**. Otherwise the
next sweep re-inherits the same blind spot, and the *reason* CONTRIBUTING.md was added never
generalizes.

**Owner decision requested at Phase 3 (real options, both viable):**
- **(a) RECOMMENDED — add `OUTPUT-STRUCTURE.md` and `assumptions.md` to Scope A** (~12 lines,
  2 files, both export-ignored so neither ships). Cost is small; leaving `assumptions.md:641`
  standing means the register keeps teaching the false premise to the next Phase 1.
- **(b) Carry both to v2.19.10** with the register/plain-language work, on the scope-creep caution
  (Trap 4; v2.19.8 shipped five scopes and the owner had to strike one).

I recommend **(a) for `assumptions.md` at minimum** — it is the only one of the sixteen that
*instructs future work*.

**E.2 — `AC-TR-A2`'s ADR enumeration is missing one ADR.** The control says the 24 frozen lines span
*"10 different ADR bodies (003, 004, 007, 010, 038, 044, 046, 051, 053, 064)"*. It is **11**;
**ADR-008** carries two (`:554`, `:575`). The count 24 is right; the list is not. Corrected in §A.2
and §D.

**E.3 — `## Safety rules` does not exist.** The spec (three places) and the pipeline classification
line both name the frozen heading `## Safety rules`. `grep -c '^## Safety rules'` → **0**. The real
heading is `## Safety this loop enforces on every generation`. Harmless to intent (the line numbers
carried the meaning) but it is exactly the class of unverified restatement this cycle exists to end,
and it appears **inside the binding tier condition**. Corrected in §A.1.

**E.4 — The `ADR-044` index-row citation is off by one.** The spec cites the annotation precedent as
`docs/architecture.md:64`. `:64` is **ADR-043's** row; ADR-044's is `:65`. Separately, the precedent
is **stronger than claimed**: not one annotated row but **12 rows in 9 distinct annotated forms**
(`ACCEPTED (updated v1.2)`, `ACCEPTED (extended by ADR-010)`, `SUPERSEDED by ADR-007`,
`ACCEPTED (amended v2.19.6)`, …). The convention is well-established, which strengthens the
index-row annotation strategy.

**E.5 — `AC-TR-C1` under-counts the cardinality literals.** It names `:170` and `:198-208`. The `6`
also appears at `:178`, `:179`, `:185`, `:206`. Incrementing only the named ones leaves a
hard-coded `6` in two live error messages. §C.4 removes the digit entirely.

**E.6 — ADR-010's index row is not unique.** `grep -cE '^\| ADR-010 \|'` → **2** (`:24` and
`:5333`). `:5333` is inside a frozen ```markdown replacement block in a historical design memo.
An unqualified "annotate ADR-010's index row" instruction has a 50% chance of editing a frozen
record. §D names `:24` explicitly and freezes `:5333`. (ADR-046's row is unique — verified, 1.)

**E.7 — ADR-081 §D1 constrains this cycle's own citations, and neither the spec nor the brief says
so.** ADR-081 D1 is ACCEPTED and CI-adjacent (`ledger-annotations` job, `quality.yml:1796`): *no
citation into a growing file may be a bare `file:line` in text this cycle writes.* The spec instructs
@architect throughout in bare `file:line` form (`:691-772`, `:9908-9917`, `:699`, `:9912`, `:67`,
`:64`). The CI verifier enforces a fixed 19-anchor list, so it would **not** have caught it — this is
a rule violation that fails silently. All three new ADRs use content-anchored citations
(`grep -n '<anchor>' <named-file>`), with line numbers marked as navigational and pinned to `f06f0cf`.

**E.8 — `docs/design-v2.19.9.md` ships.** `docs/` is default-internal only under `docs/internal/`;
`docs/design-v2.19.8.md` is present in `git archive HEAD` output (verified). The compliance condition
was worded around `docs/architecture.md`; its actual surface is wider. No verbatim vendor text is
authored in either file — condition held, but the surface is recorded so a future cycle does not
discover it the hard way.

**E.9 — Not a defect, a confirmation: delta 4 re-verified independently.**
`git show --stat 33fd22c -- 'examples/*/project-instructions-starter.txt'` → **exactly 6 files**,
`personal-assistant` absent, commit body verbatim *"personal-assistant held byte-unchanged to
protect 4-word headroom"*. The PA gap is an unlanded piece of ADR-040, not drift. ADR-084 records it.

**Nothing else was found.** The spec's load-bearing arithmetic — 12 files, 58 raw + 1 non-token = 59,
24 + 8 + 24 + 3 = 59, 24 in-ADR / 15 outside — **reconciles exactly** against the live tree. The
`README.md` line numbers (`:46`, `:83`, `:91`, `:154`), the zero-`primary` blind spot, the two live
`primary` hits, the 396-word PA starter, and the live CI-green drift at `personal-assistant:15` were
each re-derived this session and all hold.
