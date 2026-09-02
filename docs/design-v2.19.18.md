# Design — v2.19.18 "The Promise It Already Made"

**Cycle:** v2.19.18 (patch)
**Phase:** 1 — Design
**Author:** @architect (opus)
**Date:** 2026-09-02T17:37:39Z
**Branch:** `release/v2.19.18-collision-safety` (cut from `main` @ `ab16ad9`)
**Spec:** `.claude/projects/claude-cowork-config/scratchpad.md` § "Phase 0 Draft Spec — REWORK (FINAL)"
**ADR minted:** ADR-101

---

## The one sentence this cycle is about

`WIZARD.md:172` tells every user, in the wizard's own voice:

> "One thing to know: Cowork always asks before deleting, moving, or overwriting any file or folder."

The same sentence is generated into every workspace at `templates/workspace-claude-md-template.md:47`,
and — a site the spec does not name — it is also standing instruction in
`.claude/skills/setup-wizard/SKILL.md:49`, the file that executes *first*, before `WIZARD.md`'s Q1.

The promise is false today at ten-plus paths. This cycle makes it true.

---

## Table of contents

- §0 — Where the spec does not survive contact with the files (7 findings, 3 BLOCKER)
- §A — Phase 1 design header (mandatory records)
- §B — The mechanism: predicate, ledger, entry routes
- §C — Feature designs F1–F5
- §D — File-by-File Implementation Plan + `scope_allow_delta`
- §E — B1 verification
- **Classification Re-Run** (mandatory gate record)
- §F — Owner decisions OQ-1 / OQ-2 (recommend, decide neither)
- §G — Residuals carried forward

---

## §0 — Where the spec does not survive contact with the files

> *ISO 15288 — Technical: Stakeholder Needs and Requirements Definition Process.*

The spec is the strongest this project has produced: the pivot from a folder classifier to a per-path
predicate is correct and I am not reopening it. It is wrong in seven places, three of them structural.
Every claim below was re-derived this session against the files, not inherited from the spec, the
deliberation, or the orchestrator brief.

### §0.1 — BLOCKER: `context/writing-profile.md` is unguarded, and the spec's stated reason for excluding it is false

The spec lists 9 guarded paths and excludes `writing-profile.md` on the grounds that
*"`writing-profile.md`'s existing same-session skip (`:242`) is preserved **on top of** F1, not replaced
by it."* That treats `:242` as a collision guard. It is not one.

`WIZARD.md:242` is an **ordering** rule inside Step 3. Its predicate is *"did the optional Q3 voice turn
already generate a personalized profile there"* — it stops the **preset copy** from clobbering a file
**this session's Q3 just wrote**. It says nothing about a file the *user* wrote.

Q3 itself is the unguarded write. `WIZARD.md:185`:

> Generate `context/writing-profile.md` (the canonical location — see Step 3 rule) with sections: Tone &
> Voice, Style, Anti-AI Guidance, Workspace Rules, Pet Peeves. **On skip, the file still generates with
> goal-appropriate defaults.**

So Q3 writes `context/writing-profile.md` **unconditionally on every route through the interview**,
including the "skip" answer, and it does so *before* Step 3 runs. A brownfield folder containing a
user-authored `context/writing-profile.md` loses it at `:185`. `:242` cannot save it — `:242` executes
later, and by then its own predicate has flipped to true *because of the destroying write*.

**Consequence:** `context/writing-profile.md` joins the guarded set. The path count is not 9.

### §0.2 — BLOCKER: Step 4's skill writes are entirely unguarded, and they are the highest-value instruction files in the workspace

The spec's guarded set covers `cowork.install.json` (`:255`) but not a single one of the `SKILL.md`
writes that manifest describes.

- `WIZARD.md:250` — for **every slug in the confirmed bundle**: copy `skills/<slug>/SKILL.md` →
  `<user-workspace>/.claude/skills/<slug>/SKILL.md`.
- `:257`, `:259`, `:261`, `:263` — four **unconditional** copies, each phrased *"always installed,
  independent of the F4 bundle … in every workspace (Mode A and Mode B)"*: `self-apply`,
  `self-archive`, `self-upgrade`, `pull-updates`.

These are precisely *"instruction files Cowork later reads as authoritative"* — the substance on which
the spec's own SECURITY-SENSITIVE classification rests. Guarding `about-me.md` (which `:239` says the
user fills in by hand) while leaving `.claude/skills/self-apply/SKILL.md` to be overwritten without a
word is the wrong way round on severity.

Two things keep this from being a nine-to-twenty prompt explosion, and both are worth stating because
they bound the cost:

1. The `:349`/`:351` Fallback already fires when `<workspace>/.claude/skills/` *"already contains ANY
   installed skills"*, routing the common case through a menu before Step 4 is ever reached.
2. But that predicate is **skills-present**, not **path-collides**. A workspace with `.claude/skills/`
   present-but-empty, or holding non-`SKILL.md` content, falls straight through. And the asymmetry is
   already visible inside the kit: Option 2's backfill at `:361` is explicitly conditional (*"if it is
   missing"*), while `:257`'s Step-4 copy of the same file is not.

**Consequence:** the guarded set gains `.claude/skills/<slug>/SKILL.md` as a **path class** — slugs
drawn from the confirmed bundle ∪ the four mandatory skills. This stays inside the binding constraint:
the slug vocabulary is kit-controlled (the 25-slug pool plus four fixed names), never user-derived, and
membership is tested against that fixed vocabulary rather than by reading what is in the folder.

### §0.3 — BLOCKER: the naive predicate collides with the wizard's own writes

`cowork-profile.md` is written **at least three times in a single run**:

- `:134` — the F4 checkpoint writes it as a stub (*"non-optional"*).
- `:145` — *"Update this file as each later answer arrives (name, role, deadlines)"*.
- `:195` — Step 1 completes it and flips `Status:` to `complete`.

A predicate of the form *"does this path exist → confirm"* fires on the wizard's own stub at Step 1,
and again on each intermediate update. The spec's "nine possible prompts" undercounts, and worse, the
extra prompts are incoherent: *"this file already exists — replace it?"* about a file the wizard created
ninety seconds earlier, in front of the user, at their instruction.

**Consequence:** the predicate cannot be existence alone. It must be **existence AND
not-authored-by-this-run**, which requires a session write-ledger. The spec names no such mechanism;
§B designs it.

### §0.4 — The "Tier B" label is unearned (precision, not substance)

The spec concludes *"Tier B, not Tier A"*, correctly noting that `docs/pipeline-policy.md:496-516` has
no row for `WIZARD.md`, `examples/**`, or `tests/fixtures/`. Re-read this session: Tier B's rows
(`:507-512`) are `.github/workflows/`, `.claude/commands/*.md`, and non-`scope_allow:`/`hooks:` agent
contract sections. **None of them reaches this repository either.**

The honest statement is: The-Council's two-tier ceremony table does not reach *any* file in this cycle.
The ceremony conclusion — branch + PR, no Guard Change Summary — is right, but it follows from the
substance classification plus this repo's external-project convention, **not from a table row**.
Recorded so Phase 2 does not cite a row that does not exist. Carried into the Classification Re-Run.

### §0.5 — The `overwrit` count is 4 only under `-i`

Re-run this session:

- `grep -n "overwrit" WIZARD.md` → **3** lines (`:172`, `:242`, `:366`), 3 occurrences.
- `grep -n -i "overwrit" WIZARD.md` → **4** lines, adding `:303` (*"**O**verwriting CLAUDE.md requires
  explicit confirmation"*).

The spec's `AC-COLLIDE-4` control already specifies `-i`, so the spec is internally consistent; the
unqualified "4 on the stem" in the orchestrator brief is the imprecise form. No design consequence.
Recorded because the count is a **control**, and a control stated one flag away from its true value is
how a later reader concludes the file changed when it did not.

The substantive finding underneath is unchanged and still the sharpest line in the spec:
`grep -n -i "overwrit" WIZARD.md | grep -iE 'about-me|working-rules|output-format'` → **zero**.

### §0.6 — A third promise site the spec's write surface does not name

`.claude/skills/setup-wizard/SKILL.md:49`:

> Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder.

Verbatim, standing, and in the file that runs **first** — `:10`'s Resume guard and `:12`'s Reset guard
both fire before `WIZARD.md`'s Q1. The spec names two promise sites (`WIZARD.md:172`,
`workspace-claude-md-template.md:47`) and lists `setup-wizard/SKILL.md` only as *"a surface to check"*.
It is not merely a surface to check; it is a promise-bearing surface, and it is the earliest one.

**Consequence:** the entry-route seeding hooks belong in that file (§B.4), and its `:49` line moves
from decorative to load-bearing.

### §0.7 — F3's basis is stronger than the spec argued, and the proof is already in the repo

The spec argues F3 (CRITICAL) from absence: the kit's `.gitignore:20-21` protects
`context/.archive/` and `context/.apply-backups/`; `.gitattributes:12` marks `.gitignore` itself
`export-ignore` so the release ZIP ships without it; and `grep -n "gitignore" WIZARD.md
skills/self-archive/SKILL.md` returns nothing. All three re-verified this session — and the third is
broader than stated: `grep -rn "gitignore" skills/ templates/ examples/` also returns **zero**. No
runtime surface in the entire kit ever writes a workspace `.gitignore`.

The repo contains something stronger than absence. `tests/self-archive-firing-controls.md:17` states the
mechanism it is validating as:

> **Mechanism:** **workspace** `.gitignore` excludes `context/.archive/` and `context/.apply-backups/`

The control it then runs (`:20-27`) executes `git check-ignore` **inside the kit repo**, against
`.gitignore:20-21`. The v2.17.0 firing control that certified archive non-publication validated a
different file from the one its own mechanism sentence names — and passed. That is a check that could
not fail on the property it claimed, the exact defect class ADR-098 and ADR-099 were minted about, and
it is why this gap survived two cycles with a green control sitting on top of it.

**Consequence:** F3 closes the gap, and `tests/self-archive-firing-controls.md:17` **must be corrected
in the same commit**. Leaving the false mechanism line in place would let the next reader re-inherit
exactly the belief that hid the defect.

---

## §A — Phase 1 design header (mandatory records)

### A.0 Worktree discipline

**SKIPPED with cause.** `COUNCIL_EXPECTED_BASE_SHA` is unset (verified: `printenv` → `UNSET`), and this
is an external-project in-place cycle. Per the orchestrator brief and the established precedent of the
last two cycles in this repo, an Agent-tool worktree would isolate The-Council, not
`/Users/macbookpro/claude-cowork-config` — the wrong-repo hazard. Work is on
`release/v2.19.18-collision-safety`, verified checked out at `ab16ad9` (`git rev-parse HEAD` ==
`git rev-parse main` == `ab16ad9449dcd43e3badcbca6a797e370acc533d`). ADR-169's pre-spawn harvest check
does not apply and is skipped with cause, not silently.

### A.1 Production validation

**Production validation: N/A — no repo-artifact parsing in this design.**

This design introduces no logic that parses, matches, or transforms Council repository artifacts
(`pipeline.md`, `roadmap.md`, `CHANGELOG.md`, `registry.json`, `retro.md`, guard-read files). Every
artifact it writes is target-repo prose executed by an LLM at the user's machine. The
read-only-loop-over-registered-projects check has nothing to run.

Its analogue *was* run, and is what §0 is made of: every load-bearing citation was re-derived against
the real `WIZARD.md`, `setup-wizard/SKILL.md`, `self-archive/SKILL.md`, `.gitignore`, `.gitattributes`,
`docs/spec.md`, and `tests/self-archive-firing-controls.md` on this branch — not against the spec's
restatement of them. Three of the seven findings only exist because the file was opened.

### A.2 Reuse Radar (4-source lookup)

- **Source 1 — Reuse Registry** (`/Users/macbookpro/The-Council/docs/reuse-registry.md`): present.
  `grep -in "collision|overwrite|brownfield|existing file"` → **0 hits**.
- **Source 2 — Scaffold index** (`examples/scaffolds/INDEX.md`): **not present** in this Council
  checkout (`ls` → No such file or directory). Recorded, not silently skipped.
- **Source 3 — CS catalog** (`docs/constituent-systems.md`): present.
  `grep -in "confirm|wizard|idempot|archive"` → **0 hits**.
- **Source 4 — SoS interfaces** (`.claude/projects/ecosystem/sos-interfaces.json`): present. Producers
  and consumers are `confidante` and `motif` only; no interface covers a workspace-installer capability.
  **0 hits.**

**Reuse Scan**

| Component | Registry hit (grep pasted) | OSS candidate (name+license+health) | Scaffold | Decision | Basis |
|---|---|---|---|---|---|
| Collision predicate + session write-ledger (F1) | `grep -in "collision\|overwrite\|brownfield\|existing file" docs/reuse-registry.md` → 0 | none — this is LLM-executed prose in a Markdown script, not code; there is no library form of "a rule the model follows" | n/a (Source 2 absent) | **EXTEND** | Extends the pattern the kit already ships at `WIZARD.md:242` (one file) and `:303` (one file) to a named rule over a fixed path set |
| `CLAUDE.md` byte preservation (F2) | 0 | n/a | n/a | **REUSE** | Reuses `skills/self-archive/SKILL.md:62-71`'s ordering (record fingerprint → copy → byte-identity verify → unlink) and its `context/.archive/<basename>.<UTC-timestamp>` destination shape. Convention reused; **skill never invoked** — see §C.2 |
| Workspace `.gitignore` seeding (F3) | 0 | n/a | n/a | **BUILD** | No hit in any source; no kit surface writes a workspace `.gitignore` (`grep -rn "gitignore" WIZARD.md skills/ templates/ examples/` → 0). Two fixed kit-authored literal lines; nothing to adopt |
| Three brownfield fixtures (F5) | 0 | n/a | n/a | **EXTEND** | Extends the existing `tests/fixtures/` + `tests/*-firing-controls.md` convention already established by `self-archive`, `self-upgrade`, `pull-updates`, `vendor-prune`, `registry-cardinality`, `mf3-tools-vocabulary-gate` |

**Buy-vs-Build: 4 components scanned — REUSE 1 / ADOPT 0 / EXTEND 2 / BUILD 1.**

Zero ADOPT rows ⇒ no dep-scan flag, no L1/L1b license gate, no `ATTRIBUTIONS.md` row, no AC-D1.9
prompt-injection screen owed.

### A.3 EARS check

Applied to the spec's HIGH-severity ACs.

| AC | EARS form | Severity | Finding |
|---|---|---|---|
| `AC-COLLIDE-1` | ubiquitous + event-driven, implicit | HIGH | **HIGH-vague.** "the predicate fires on all 9 paths" names a count that §0.1/§0.2 falsify and an actor that does not exist yet. `[EARS-REVISED]` below |
| `AC-COLLIDE-2` | event-driven, implicit | HIGH | Acceptable. Trigger (`7a` overwrite), response (copy-verify-unlink), and the negative bound (does not recover pre-v2.19.18 losses) are all present |
| `AC-COLLIDE-3` | state-driven, implicit | MEDIUM | Advisory: "renders only where that archive actually exists" leaves the actor unnamed — §C.4 resolves it by assigning the rewrite to 7b |
| `AC-COLLIDE-4` | ubiquitous | HIGH | **HIGH-vague** only in its control's flag (`-i` required — §0.5). Substance sound |
| `AC-COLLIDE-5` | event-driven | HIGH | Acceptable. "before the first archive write" is a real ordering trigger, testable |
| `AC-GREENFIELD-1` | ubiquitous | HIGH | Acceptable, and now true by construction |
| `AC-FIXTURESET-1` | ubiquitous | MEDIUM | Advisory: three fixtures with three distinct controls; fine |
| `AC-QUALIFIER-1` | optional-feature (`WHERE`) | MEDIUM | Correctly EARS-optional, gated on OQ-2 |

**`[EARS-REVISED]` — `AC-COLLIDE-1`:**

> **WHEN** the wizard is about to write a guarded path (§B.1's set) **AND** that path already exists on
> disk **AND** the session write-ledger holds no `created-this-run` or `authorized` disposition for it,
> **THE wizard SHALL** obtain an explicit user confirmation naming that path before writing, **AND**
> **SHALL** leave the path byte-identical if the confirmation is declined.

**2 HIGH-vague findings, both recorded as OQs below; 2 MEDIUM advisory notes; 1 `[EARS-REVISED]`
rewrite emitted.**

**OQ-EARS-1** (from `AC-COLLIDE-1`): the AC's "9 paths" is a fixed count in an AC. §0.1/§0.2 raise it.
Resolved in-design by replacing the literal count with §B.1's named set; @qa should verify against the
set, not the number.
**OQ-EARS-2** (from `AC-COLLIDE-4`): the control must be run with `-i` or it reports 3 where the AC
expects 4.

### A.4 SoS classification + UAF viewpoints

More than one registered project is **not** involved: this design touches only
`claude-cowork-config`. Per EC-1, each viewpoint is emitted explicitly rather than omitted.

- **Maier SoS category:** N/A — single-project design.
- **UAF Strategic viewpoint:** N/A — single-project design.
- **UAF Operational viewpoint:** N/A — single-project design.
- **UAF Services viewpoint:** N/A — single-project design.
- **UAF Personnel viewpoint:** N/A — single-project design.

### A.5 Reliability analysis

**Reliability Analysis: N/A per NEVER-APPLY** — no external API provider appears in any request path,
there is no failover or fallback mechanism, and the spec makes no SLA or availability claim. All three
WHEN-TO-APPLY gates are false.

### A.6 Heuristics check (Rechtin)

| Heuristic | Signal produced |
|---|---|
| *"Simplify. Simplify. Simplify."* | **FIRED, decisively.** It is what killed the folder classifier at Phase 0.D and what kills the `scripts/` helper in §C.1: a fixed-list existence check has no failure modes a classifier has. It also constrained the ledger to the session transcript rather than a new on-disk file |
| *"Relationships among elements are what give systems their added value."* | **FIRED.** The defect is not in any one write site; it is in the relationship between a promise made at `:172` and ten writes that never consult it. That is why the remedy is one named rule with pointers, not ten inline copies |
| *"The first line of defense against complexity is a good interface."* | **FIRED.** The ledger's four dispositions (`unseen` / `created-this-run` / `authorized` / `declined`) are the interface; every write site consults it through the same four-way question |
| *"Do the hard parts first."* | **FIRED.** The hard part was not the predicate — it was §0.3's self-collision and the entry-route matrix. Both are resolved in §B before any feature text is written |
| *"In introducing technological and social change, how you do it is often more important than what you do."* | **FIRED.** Directly produces §C.3's fatigue trade-off: nine correct prompts that train click-through are worse for safety than one honest disclosure plus a per-path backstop |
| *"A model is not reality."* | **FIRED.** §0.7 — the v2.17.0 firing control modeled "workspace `.gitignore`" and tested the kit's. The model passed; reality was never checked |
| *"Build in and maintain options as long as possible."* | Not applicable this cycle — rationale: both open questions (OQ-1, OQ-2) are already framed as owner-held options rather than resolved in design, so the heuristic has nothing further to preserve |

### A.7 Maturation Path self-grep (ADR-101)

Baseline in `docs/architecture.md` **before** ADR-101:

```
**Future-state options:**       → 71
**Concrete revisit triggers:**  → 71
**Risk knowingly accepted:**    → 72
```

Required after ADR-101 lands: **72 / 72 / 73** — each header exactly +1. The pre-existing 71/71/72
asymmetry is inherited, not introduced by this cycle; it is not repaired here (see §G).

The `### §Maturation Path (per [[maturation-path-in-adr]] binding)` block in ADR-101 is copied verbatim
from the template slot, not composed from memory. Post-write verification is a Phase-1 gate and is
recorded in the Phase 1 summary.

### A.8 B1 verification (header record)

**B1 verification: PASS (by construction) @ 2026-09-02T17:37:39Z.** `scope_allow_delta:` block present
and well-formed — empty `add`, empty `remove`, no-op by design for an external-project cycle. Full
reasoning at §E, including why the cross-reference is *structurally inapplicable* rather than merely
passing. Recorded here as well because the record is a Phase-2 precondition and must be findable from
the design header alone.

---

## §B — The mechanism: predicate, ledger, entry routes

> *ISO 15288 — Technical: System Architecture Definition Process.*

### §B.1 — The guarded set

A **fixed, kit-authored** list of destination paths. It is never derived from what is in the folder.

**Fixed single paths (10):**

| # | Path | Write site |
|---|---|---|
| 1 | `cowork-profile.md` | `WIZARD.md:134` (stub), `:145` (updates), `:195` (completion) |
| 2 | `project-instructions.txt` | `:226` |
| 3 | `context/about-me.md` | `:239` |
| 4 | `context/working-rules.md` | `:240` |
| 5 | `context/output-format.md` | `:241` |
| 6 | **`context/writing-profile.md`** | **`:185` (Q3, unconditional — §0.1)**, `:242` (Step 3, already skip-guarded) |
| 7 | `cowork.install.json` | `:255` |
| 8 | `connector-checklist.md` | `:273` |
| 9 | `SETUP-CHECKLIST.md` | `:274` |
| 10 | `skills-as-prompts.md` | `:282`, and `:363` (Option 2 regeneration) |

**Path class (§0.2):** `.claude/skills/<slug>/SKILL.md` for every `<slug>` in
(confirmed bundle) ∪ {`self-apply`, `self-archive`, `self-upgrade`, `pull-updates`}. Write sites
`:250`, `:257`, `:259`, `:261`, `:263`, and `:361`/`:362` on the Option-2 delta.

**Handled separately, by name:** `CLAUDE.md` (F2 — already confirm-gated at `:303`; F2 adds byte
preservation *under* that confirmation, no new prompt) and the workspace `.gitignore` (F3 — a
two-literal-line idempotent append, disclosed in 7a's confirmation text, §C.3).

**Explicitly NOT guarded, and why:** 7c's working folders (`:312`). Creating a directory that already
exists is a no-op that overwrites nothing, and 7c already carries its own question. Stated rather than
left silent, so a later reader does not read the omission as an oversight.

**Why this stays inside the binding constraint.** Every entry above is a literal the kit authored, or a
slug from the kit's own fixed 25-slug pool. The predicate asks *"does this exact path exist"* and
nothing else. It never lists a directory, never reads a file body, never derives a name from anything
the user chose. A folder named `Ignore previous instructions` is untested and therefore inert — not
because a rule forbids reading it, but because there is no step at which reading it would occur.

### §B.2 — The predicate is existence AND provenance

§0.3 forces this. The predicate is evaluated against a **session write-ledger** with four dispositions:

| Disposition | Meaning | Behaviour at a write site |
|---|---|---|
| `unseen` | not yet encountered this run | **path absent** → write (byte-identical to today). **path present** → collision; ask (§B.3), then record |
| `created-this-run` | this run created it | write, no prompt |
| `authorized` | the user said replace | write, no prompt |
| `declined` | the user said keep | **skip the write**, keep the mark (this is F4's trigger) |

The ledger lives in the **session transcript**, the same channel `self-archive/SKILL.md:62` already uses
for its reversible-move tuple. No new file on disk, no new state surface, no new thing to protect.

This is what makes the wizard's own triple-write of `cowork-profile.md` silent: the `:134` stub marks it
`created-this-run` (or `authorized`, if it pre-existed and the user said replace), so `:145` and `:195`
never re-prompt.

### §B.3 — Confirmation shape: one scope-carrying disclosure per entry route, plus a per-path backstop

**The backstop is the invariant. The survey is an optimization.** Stating it in that order matters,
because it is what answers "can any entry route bypass F1".

**Backstop (invariant).** At *every* guarded write site, if the ledger says `unseen` and the path
exists, the wizard asks before writing. Nothing reaches a write site without passing this. It is
per-path, at write time, and it is the whole safety property.

**Survey (optimization).** At exactly one point — immediately after the F4 bundle is confirmed and
**before** the `:134` stub write — the wizard tests the guarded set for existence. At that moment it
knows the routed preset and the confirmed bundle, so every destination path is known. If the survey
finds nothing (greenfield, and also the ordinary non-Cowork document folder — see §C.3), **nothing is
shown and the run is byte-identical to today.** If it finds collisions, one turn names every one of
them and offers: keep mine / replace them / go one by one. The result seeds the ledger.

### §B.4 — Entry-route matrix: verifying the spec's "safe by construction" claim

The spec claims per-path-at-write-time firing makes every route safe. **The claim holds, but only
because of the backstop — and the spec did not have a backstop, because it had no ledger.** With §B.2
in place, here is the route-by-route check:

| Route | Reaches the survey? | Guarded writes reached | Covered by |
|---|---|---|---|
| Fresh run (Q1 → F4 → Steps 1-7a) | Yes | all | survey + backstop |
| **Fast-track** (`:147`) — *not named in the spec* | Yes (survey precedes the stub, fast-track is offered after it) | all — `:147` says *"immediately run the After-Q2 generation steps with defaults"* | survey + backstop |
| Resume / interrupted (`:412-422`) | **No** — re-enters mid-run, past the survey point | Step 1 completion, Steps 2-7a, plus `:422`'s partial-install skill re-copies | **backstop only** |
| Reset / Option 3 (`:355-357`, `:366`) | Yes — restarts from Q1 | all | survey + backstop |
| Option 2 add/remove (`:359-364`) | **No** — routes to F4 with the existing bundle, runs only Steps 4/6 + the profile line | `.claude/skills/<slug>/SKILL.md` (new slugs), `skills-as-prompts.md` (`:363`), `cowork-profile.md` bundle line (`:364`) | **backstop only** |
| Fallback menu option 1 ("keep as-is") | n/a | none | n/a |

**The claim survives.** Two routes bypass the survey; both are fully covered by the backstop, which is
the property that actually carries the promise. Recorded explicitly because "safe by construction" was
asserted in the spec without the construction being named.

**One consequence the spec did not anticipate, and it is a real cost.** Option 2's writes at `:363` and
`:364` are *mandatory correctness* writes — `:363` says `skills-as-prompts.md` *"must always reflect
what is actually installed"*. Under the backstop, both are `unseen`+present, so both now prompt. That
adds **two prompts to a flow that today has zero**. Mitigation, and it is the same technique the survey
uses: the Option-2 menu choice at `:355` becomes scope-carrying — it names the two files it will need
to update as part of the choice itself, seeding the ledger `authorized`. The user is told once, in the
sentence where they choose add/remove, instead of being interrupted twice later. If the owner prefers,
declining is still possible — but a declined `skills-as-prompts.md` is then a **stale file that lies
about what is installed**, and the wizard must say so in one line rather than silently leaving it. That
disclosure is designed in; it is not left to Phase 4.

### §B.5 — Why batching here does not violate `AC-BATCH-1`

This repo carries a standing, EARS-form, no-batching acceptance criterion, and a skill that says
*"No batching, ever."* Any design that consolidates confirmations must answer it directly rather than
hope Phase 2 does not notice.

`docs/spec.md:3895`, `AC-BATCH-1`:

> `[EARS]` WHEN >1 entry independently reaches an **apply-eligible** state in the same session or
> periodic pass, THE workspace SHALL present and require a **separate** turn-2 confirmation for EACH
> entry — never a single combined prompt.

And `docs/spec.md:3896`, `AC-BATCH-2`, binds the *"byte-identical four-part surface … plus the literal
turn-2 diff"*. `skills/self-archive/SKILL.md:58` restates it: *"No batching, ever."*

**Scope, read from the AC's own trigger.** "apply-eligible", "turn-2 confirmation", "four-part surface
(v2.15 `AC-PROPOSE-1`)" are all `self-apply`/`self-archive` vocabulary. `AC-BATCH-1` governs the
**workspace self-modification channel** — the one whose defining property is that the workspace
proposes changes *the user did not initiate*, repeatedly, over time. `AC-BATCH-2`'s whole subject is
the *Nth* occurrence: it exists because a proposal surface that shortens itself on repetition is how an
autonomous channel goes quiet.

The wizard channel is the inverse: **foreground, user-initiated, single-session, and the user asked for
exactly these files thirty seconds ago.** The kit already distinguishes the two — `WIZARD.md:310`
batches a fifteen-path *move* under a single confirmation (*"Confirm once for the batch, not per
file"*), and ADR-060 did not disturb it.

**The trade, stated plainly, because it is a real one.** A user who accepts "replace them all" gets one
prompt covering up to ~14 paths where `self-archive` would give one file a full two-turn surface. That
is weaker per-file scrutiny. I accept it, and the reason is a safety reason rather than a comfort one:
the maximum-collision case is re-running setup on an existing Cowork workspace, and that user has
**already** passed the `:349` menu and Option 3's *"This will reset your profile and re-run onboarding.
Confirm?"*. Asking fourteen more times after an explicit "start fresh" does not add scrutiny — it
trains click-through, and that habit is what makes the *next* prompt, the one that matters, unsafe. The
one-by-one option is offered every time and is never removed.

**Honest residual.** Option 3's confirmation text at `setup-wizard/SKILL.md:12` and `WIZARD.md:366` says
*"reset your **profile**"*. It does not today authorize replacing `context/about-me.md`, which `:239`
says the user fills in by hand. The survey is what makes the consolidated "replace them all" honest:
it names every path *before* the user answers. Without the survey, a batch confirmation would be
claiming an authorization the reset text never gave. **The survey is therefore not merely a fatigue
optimization — it is the thing that earns the batch.** That is why §C.3 places it before the first
write rather than anywhere more convenient.

---

## §C — Feature designs

> *ISO 15288 — Technical: Design Definition Process.*

### §C.1 — F1: where the rule lives

Four candidate homes were considered.

**Rejected — a `scripts/` helper.** `WIZARD.md:32` establishes the wizard as LLM-executed prose; there
is no runtime inside the wizard that invokes a shell script. All 17 entries in `scripts/` are
maintainer/CI tooling (`vendor-*.sh`, `verify-*.sh`, `publish-release.sh`, `release-*.sh`,
`registry-hash.sh`, `canonicalize-scan.sh`, `semver-compare.sh`, `skill-studio-validate.sh`) or
user-invoked by hand (`setup-folders.sh`/`.ps1`). A `scripts/collision-check.sh` would ship with **no
caller** — an instrument that cannot fail, the precise defect ADR-098 and ADR-099 were minted about,
and the one §0.7 just caught a live instance of. Rejected on that citation, not on taste.

**Rejected as the home — `.claude/skills/setup-wizard/SKILL.md`.** `:8` states *"**WIZARD.md is the
single script source — this file only routes into it**"*, and `WIZARD.md:34` restates the Single-source
rule. Putting the rule body there would make the router the script.

**Rejected as the only form — inline at each write site.** Ten-plus copies drift. That is precisely how
`:242` ended up being the single protected path in a file that promises to protect all of them.

**Adopted — one named rule, pointers at each site.** A new `## Collision Rule (runtime,
non-overridable)` section inserted in `WIZARD.md`'s standing-rules region, immediately after the
Network & Offline Rule (ends `:29`) and before `## Wizard Instructions` (`:32`). That region is read
before Q1 and already holds the Attribution Rule (`:15`) and the Network & Offline Rule (`:21`) — both
non-overridable runtime rules with exactly this shape. Not the Appendix: `:388` scopes the Appendix to
*"implementation contract for maintainers and CI, **not dialogue to run**"*, and F1 is dialogue to run.

Each write site gains a one-line pointer (`Guarded path — see the Collision Rule.`). Entry-route seeding
hooks go in `setup-wizard/SKILL.md` at `:10`/`:12`, pointing back — the bidirectional-pointer convention
already used by `:12` → WIZARD Fallback and `WIZARD.md:357` → the Reset guard.

### §C.2 — F2: `CLAUDE.md` preservation, at zero prompt cost

`:303` already confirms 7a's overwrite. F2 adds preservation **underneath** that existing confirmation,
so it costs **no new prompt**. Ordering at 7a, copied from `self-archive/SKILL.md:62-71`:

1. Record the fingerprint (length + checksum) of the current `CLAUDE.md` bytes **in the session
   transcript** (`self-archive:62`'s channel — never an on-disk log that the operation could itself
   corrupt).
2. Ensure the workspace `.gitignore` carries F3's two lines (**F3 runs first — §C.3**).
3. Copy the bytes to `context/.archive/CLAUDE.md.<UTC-timestamp>` (`self-archive:56`'s destination
   shape).
4. **Verify byte-identity** of the destination against the transcript-recorded fingerprint, per
   `self-archive:70`'s explicit *"checked against the out-of-band transcript tuple, never the possibly-
   untrusted on-disk log alone"*.
5. Only on PASS: write the personalized `CLAUDE.md`. On FAIL: do not overwrite; surface the failure and
   ask.

**The skill is read for convention and never invoked.** `self-archive` refuses `CLAUDE.md` three
independent ways — `:42`'s namespace floor denies *every bare workspace-root `*.md` file*, `:46`'s
positive predicate clause (c) requires the file **not** be a bare workspace-root `*.md` and states the
default is deny, and `:71`'s reference-integrity grep would fire on the workspace `CLAUDE.md` besides.
No exception is carved into it; `skills/self-archive/SKILL.md` is **not modified by this cycle**, and
§D names it as such so Phase 4 does not quietly reach for it.

**Named limitation, carried from the spec and kept:** F2 protects only 7a's own overwrite. It does not
recover a `CLAUDE.md` already lost to a pre-v2.19.18 run.

**Also corrected at `:303`:** the prompt text today promises *"The setup version stays in the archive."*
On Mode B that archive is `_setup-kit/`, created only at 7b, which is Mode-A-only and runs **after**
7a. The sentence is false at the moment it is spoken. With F2 it becomes true for a different reason —
the bytes go to `context/.archive/` — so the text is rewritten to name the destination that actually
exists.

### §C.3 — F3: the workspace `.gitignore`, and why it must run first

Order inside 7a is load-bearing: **`.gitignore` → archive copy → overwrite.** Writing the preserved
bytes first and the ignore rule second leaves a window in which the user's `git add .` tracks them.

- `.gitignore` absent → create it containing exactly the two literal lines.
- `.gitignore` present → append each of the two literal lines **only if that exact line is absent**.
  Idempotent. No reordering. No other line read for meaning or modified.

The two literals are `context/.archive/` and `context/.apply-backups/`, matching the kit's own
`.gitignore:20-21` verbatim. They are kit-authored constants, never derived from the folder, so the
binding constraint is untouched.

**This write is itself covered by the promise**, so it is disclosed rather than silent: 7a's existing
`:303` confirmation gains one clause naming the `.gitignore` create-or-append. It does not get its own
prompt — a separate prompt for a two-line append, immediately after the prompt that authorized
replacing the user's entire `CLAUDE.md`, is fatigue with no scrutiny gained.

**And the false control is corrected in the same commit.** `tests/self-archive-firing-controls.md:17`'s
*"**workspace** `.gitignore`"* mechanism line is rewritten to state what the v2.17.0 control actually
validated (the kit repo's `.gitignore`), with the workspace half now genuinely covered by F3 and its own
control. Per §0.7 this is not optional cleanup: leaving it re-teaches the belief that hid the defect.

**The fatigue answer, quantified.** The path count is ~14, but the realistic collision count is not:

| Situation | Colliding guarded paths | Prompts |
|---|---|---|
| Greenfield empty folder | 0 | **0** — byte-identical to today |
| Ordinary brownfield document folder (Notes, Papers, a client folder) | typically **0** — `cowork-profile.md`, `project-instructions.txt`, `connector-checklist.md`, `skills-as-prompts.md`, `cowork.install.json` are all Cowork-specific names a user's folder will not contain | **0** |
| Brownfield that is also a Claude Code project | `CLAUDE.md` (already prompts today at `:303`), possibly `.claude/skills/*` | **0 new**, or 1 survey turn |
| Re-run on an existing Cowork workspace | all ~14 | **1 survey turn** — and only after the user already chose "start fresh" |

The trade: one consolidated turn instead of up to fourteen, bought with the survey that names every path
before the user answers (§B.5). The per-path backstop and the one-by-one option both remain.

### §C.4 — The `_setup-kit/` falsehoods, and the ordering problem the spec left open

Four sites assert an archive that may never exist: `WIZARD.md:303` (§C.2), and
`templates/workspace-claude-md-template.md:10` (*"the setup kit is archived in `_setup-kit/`"*), `:35`
(*"the archived pool at `_setup-kit/skills/`"*), `:39` (*"the script is archived at
`_setup-kit/WIZARD.md`"*), plus `README.md:50`.

**The ordering problem:** the template is filled at **7a**, but whether `_setup-kit/` exists is decided
at **7b** — which runs *after* 7a, only in Mode A, and is *declinable* (`:308`, "Yes / keep as-is").
7a cannot know. Making the template lines conditional at 7a is therefore not implementable as written.

**Resolution — invert the dependency.** 7a writes the **Mode-B (no-archive) wording** unconditionally:
skills resolve at `.claude/skills/`, the script at `WIZARD.md`, no archive claimed. Then 7b, **on Yes
and as the final step of the move**, rewrites those three lines to the archive wording. That rewrite
targets a file the wizard created earlier in this same run, so the ledger holds it `created-this-run`
and **no prompt fires** (§B.2). Mode B and declined-7b both correctly keep the no-archive wording, with
no conditional logic needed at 7a at all.

`README.md:50` is static kit documentation, not generated output — it gets a plain rewrite naming the
archive step as something the wizard *offers*, not something it has done.

### §C.5 — F4: the `working-rules.md` qualifier (OWNER-GATED, OQ-2)

Designed implementable; **not assumed to ship**. §F states the include/exclude cleanly.

**Trigger:** the ledger holds `declined` for one or more guarded paths at the end of the run — i.e. the
wizard's own in-run memory that the user kept their own file. Never a folder classification; §B.2's
ledger already carries the fact, so F4 adds no new mechanism, only a consumer.

**Effect:** the generated `context/working-rules.md` (when it is *not* itself declined) gains one
qualifying sentence naming the kept files, so the workspace's standing rules do not describe a
configuration the workspace does not have.

**Clean cut if OQ-2 defers:** delete this subsection and `AC-QUALIFIER-1`; remove the ledger's
`declined`-consumer clause from the Collision Rule. **F1/F2/F3 are unaffected** — the `declined`
disposition is still needed by F1 itself (to skip the write), so nothing else unravels. That is what
makes this a clean include/exclude rather than a tangle.

### §C.6 — F5: three fixtures

`tests/fixtures/brownfield/{mode-a,mode-b,stale-skills}/`, following the existing `tests/fixtures/` +
`tests/*-firing-controls.md` convention (six precedents: `self-archive`, `self-upgrade`,
`pull-updates`, `vendor-prune`, `registry-cardinality`, `mf3-tools-vocabulary-gate`).

- **`mode-a`** — kit present at workspace root, so `:306`'s 7b detector is **reachable**.
- **`mode-b`** — no kit at root; proves 7b correctly stays silent **while F1 still fires**, i.e. the
  defect is independent of 7b.
- **`stale-skills`** — non-Cowork skill folders under `.claude/skills/`, giving `:349`'s Fallback
  detector a real fixture to **fire against for the first time in this repo's test history**.

**All content synthetic.** `.gitattributes:20` export-ignores `tests/` from **release ZIPs only** — this
repo is public, so `git clone` and the GitHub web UI show every fixture byte. No real user content, no
real names, no real paths.

**A finding for @security at Phase 2, arising from `stale-skills`.** `WIZARD.md:353` renders
*"Your installed skills: **[list detected skills]**"* — user-controlled folder names echoed into model
context and into the user-visible turn. This is a **pre-existing** exposure that this design does not
create and, per the binding constraint, must not "fix" by adding folder inspection. But `stale-skills`
makes it **reachable in a test for the first time**, so it should be looked at deliberately rather than
discovered by the fixture. Named here, not designed here.

### §C.7 — Anti-pattern scan (11)

| # | Anti-pattern | Result |
|---|---|---|
| 1 | God Class/Module | **Clear.** The Collision Rule has one responsibility; the ledger is 4 dispositions |
| 2 | Circular Dependencies | **Clear.** `setup-wizard/SKILL.md` → `WIZARD.md` is one-directional for authority; the back-pointers are references, not dependencies (existing convention) |
| 3 | Leaky Abstraction | **Clear.** Write sites see only the 4-way ledger question |
| 4 | Premature Optimization | **Flagged and accepted.** The survey *is* an optimization over the backstop. Accepted because §B.5 shows it also carries the honesty of the batch, not just its cost |
| 5 | Over-Engineering | **Clear**, and actively defended: the `scripts/` helper was rejected in §C.1 on exactly this ground |
| 6 | Tight Coupling | **Clear** |
| 7 | Missing Separation of Concerns | **Clear.** Rule body in the script source; entry hooks in the router; controls in `tests/` |
| 8 | N+1 Query Pattern | **Clear.** The survey is one pass over a fixed list; cost is independent of folder size |
| 9 | Destructive Migration | **Clear** — and this cycle is the *inverse*: F2 makes an existing destructive step reversible |
| 10 | SoS Interface Discontinuity | **N/A** — single-project (A.4) |
| 11 | Cross-Project Tight Coupling | **Clear.** No dependency on any other registered project |

---

## §D. File-by-File Implementation Plan

> *ISO 15288 — Technical: Implementation Process (plan only; execution is Phase 4).*

| # | File | Change | Feature |
|---|---|---|---|
| 1 | `WIZARD.md` | Insert `## Collision Rule (runtime, non-overridable)` after `:29`, before `## Wizard Instructions`. Add one-line guarded-path pointers at `:134`, `:145`, `:185`, `:195`, `:226`, `:239`, `:240`, `:241`, `:242`, `:250`, `:255`, `:257`, `:259`, `:261`, `:263`, `:273`, `:274`, `:282`, `:361`, `:362`, `:363`, `:364`. Rewrite `:303`'s prompt (archive destination + `.gitignore` clause). Add the F2 copy-verify-overwrite ordering at 7a. Add F3's `.gitignore` step ahead of it. Add 7b's template-line rewrite step. Make `:355`'s Option-2 choice scope-carrying | F1, F2, F3, C.4, B.4 |
| 2 | `.claude/skills/setup-wizard/SKILL.md` | Entry-route seeding pointers at `:10` (Resume) and `:12` (Reset/Option 3) referencing the Collision Rule; make `:12`'s reset text name what it replaces. `:49`'s promise line left verbatim (it is now true) | F1, §0.6 |
| 3 | `templates/workspace-claude-md-template.md` | `:10`, `:35`, `:39` → Mode-B (no-archive) wording as written by 7a; note that 7b rewrites them on Yes | C.4 |
| 4 | `README.md` | `:50` → archive described as offered, not done | C.4 |
| 5 | `TRUST.md` | Add the data-minimization line (closes the spec's S11 condition): the collision predicate tests kit-authored paths only and never reads or enumerates user folder content | Compliance condition |
| 6 | `tests/self-archive-firing-controls.md` | Correct `:17`'s false *"workspace `.gitignore`"* mechanism line | §0.7 |
| 7 | `tests/collision-safety-firing-controls.md` | **NEW.** Controls for `AC-COLLIDE-1..5`, `AC-GREENFIELD-1`, `AC-FIXTURESET-1`, and (if OQ-2 ships) `AC-QUALIFIER-1`. Each with GREEN + RED negative control, per house discipline | F1-F5 |
| 8 | `tests/fixtures/brownfield/mode-a/` | **NEW** — synthetic; kit present at root | F5 |
| 9 | `tests/fixtures/brownfield/mode-b/` | **NEW** — synthetic; no kit at root | F5 |
| 10 | `tests/fixtures/brownfield/stale-skills/` | **NEW** — synthetic non-Cowork skill folders | F5 |
| 11 | `docs/spec.md` | Append `## Architectural Modifications (v2.19.18 …)` — cumulative file, append only | Phase 1 record |
| 12 | `docs/architecture.md` | Append ADR-101 + its index-table row | Phase 1 record |
| 13 | `docs/design-v2.19.18.md` | This file | Phase 1 record |
| 14 | `CHANGELOG.md` | v2.19.18 entry | Phase 4 |
| 15 | `VERSION` | `2.19.16` → `2.19.18` | Phase 4 |

**NOT modified — named explicitly so Phase 4 does not reach for them:**

- **`skills/self-archive/SKILL.md`** — read for convention only (`:56`, `:62-71`), never invoked, no
  exception carved into its deny-list.
- `scripts/**` — no helper is added (§C.1).
- `.gitignore`, `.gitattributes` (kit repo) — already correct at `:20-21` and `:40-41`; F3 concerns the
  **workspace's** `.gitignore`, a different file.
- `docs/roadmap.md` — v2.19.x patches take no ladder row (`:5`).

```yaml
scope_allow_delta:
  # No-op: external-project cycle. Every plan file is inside the active project root
  # (/Users/macbookpro/claude-cowork-config), where scope-check.sh:708-713 short-circuits
  # before any scope_allow pattern is consulted. Recorded because ADR-115 requires the
  # block's PRESENCE (omission is a parse error at Phase 2), NOT because it grants anything.
  add: []
  remove: []
```

---

## §E — B1 verification

> *ISO 15288 — Technical Management: Decision Management Process.*

**B1 verification: PASS (by construction) @ 2026-09-02T17:37:39Z.**

`scripts/guards/scope-allow-verify.sh` cross-references §D plan files against
`.claude/agents/dev.md scope_allow.<scope>`. For this cycle that cross-reference is **structurally
inapplicable**, read out of the guard this session rather than inherited from the prior cycle's record:
`scripts/guards/scope-check.sh:708-713` reads

```
# --- External project: allow all writes within the project root ---
if [ -n "$ACTIVE_PROJECT_PATH" ] && [[ "$FILE" == "$ACTIVE_PROJECT_PATH/"* ]]; then
  exit 0
fi
```

— every write inside the active external project's root short-circuits to `exit 0` **before** any
`scope_allow` pattern is consulted. All 15 §D plan files are inside that root. There is no pattern set
for them to be missing from, so there is no coverage gap the verifier could report.

The `scope_allow_delta:` block is present and well-formed: empty `add`, empty `remove`, valid YAML, no
bare wildcards. ADR-115's presence requirement is satisfied.

**Recorded rather than glossed:** this is a **PASS on an inapplicable check**, not a PASS on a check
that ran and found coverage. Stating it the other way would be a check that cannot fail reported as
evidence — which is the thing §0.7 and §C.1 spend this design objecting to elsewhere.

---

## Classification Re-Run

*Mandatory per `docs/pipeline-policy.md` §PostOQClassificationReRun — required even when unchanged.*

**Result: CONFIRMED — SECURITY-SENSITIVE. Ceremony: branch + PR, no Guard Change Summary.
COMPLIANCE-SENSITIVE: NO, under two conditions, both met by §D.**

**Re-derived from the final §D file list, not inherited.**

**The surface that justifies it:** `WIZARD.md` and `.claude/skills/setup-wizard/SKILL.md` are the
scripts that write a user's standing instruction files — `CLAUDE.md`, `context/working-rules.md`,
`project-instructions.txt`, and (per §0.2, newly in scope) every `.claude/skills/<slug>/SKILL.md`,
including the four mandatory safety skills. Those are the files Cowork subsequently reads **as
authoritative instructions**. A defect in the logic that writes them is a defect in the workspace's
instruction surface. That is the substance, and it holds independently of any table.

**Not on `docs/roadmap.md:7`.** `:7` binds *"Every **rung** that writes an instruction file …"*, and
`:5` states verbatim that *"**v2.19.1 through v2.19.13 are patch-level storefront/truth-repair releases
on top of v2.19.0** — no new functional rung, no ladder row of their own."* v2.19.18 is the same class.
A rung-scoped rule does not reach a patch by its own text, and a classification escapable by "we're a
patch" would not be worth having. Re-verified this session.

**Not Tier A, and not Tier B either — the table does not reach this repo (§0.4).**
`docs/pipeline-policy.md:497-506` Tier A rows: `scripts/guards/`, `.claude/settings.json`,
`docs/pipeline-policy.md`, `.claude/agents/*.md` `scope_allow:`/`hooks:`, `.github/CODEOWNERS`,
`scripts/orchestrator/`. `:507-512` Tier B rows: `.github/workflows/`, `.claude/commands/*.md`,
non-`scope_allow:` agent-contract sections. **Zero §D files match either list.** The ceremony
conclusion (branch + PR, no GCS) is correct and unchanged; its basis is the substance classification
plus this repo's external-project convention, not a row.

**Did any file move the classification upward during design?** §0.2 added
`.claude/skills/<slug>/SKILL.md` to the guarded set — the single most instruction-authoritative surface
in a workspace. That **strengthens** an already-SECURITY-SENSITIVE call; it does not escalate the tier,
because no Tier A surface entered the list. **No upward flip. Phase 2 proceeds normally; it is not
skippable.**

**COMPLIANCE-SENSITIVE: NO**, on two conditions, both discharged in §D:

1. Fixtures are **synthetic** (§C.6). `.gitattributes:20` export-ignores `tests/` from release ZIPs
   only; this repo is public, so clone and the web UI expose every byte.
2. `TRUST.md` gets its data-minimization line (§D item 5) — the predicate tests kit-authored paths and
   never reads or enumerates user content.

---

## §F — Owner decisions (recommend; decide neither)

*The owner decides at Phase 3 from plain-language framing. Both options below are real, buildable work.*

### OQ-1 — 7b's directory-move detector: tighten now, or name the limitation?

**What is actually true today.** At `WIZARD.md:306`, the wizard decides the whole setup folder is "the
kit" on one signal: *"`WIZARD.md` present in the workspace root."* On Yes, `:310` moves `docs/`,
`scripts/`, `templates/`, `examples/`, `prompts/`, `vendored/`, `skills/`, `README.md`,
`SETUP-CHECKLIST.md`, `cowork.lock.json`, `VERSION`, and more into `_setup-kit/` — under **one** batch
confirmation. The detector proves the kit is here. It never proves *these particular directories are
the kit's*. A user who unzipped the kit into a folder that already had a `docs/` or a `scripts/` has
those moved too.

| | **Option A — document it (recommended by @pm; I concur)** | **Option B — tighten it this cycle** |
|---|---|---|
| **What ships** | A named limitation in `WIZARD.md` and `TRUST.md`, plus 7b's confirmation text listing what it is about to move so the user can see their own folder named before saying yes | Per-path verification that each moved directory is the kit's — e.g. cross-checking every path against `cowork.lock.json` / a kit manifest before including it in the move |
| **Cost** | Small. Prose + one confirmation-text change. Fits inside this cycle | Large. Needs a reliable "is this ours" test for a directory. `cowork.lock.json` covers **vendored** content, not `docs/` or `scripts/`, so a new kit-manifest surface would have to be built and kept in sync |
| **Risk it leaves open** | A user with same-named folders can still move them — but only after seeing them listed, and only by saying yes to a declinable question | Near-zero for the move itself; introduces a new manifest that can drift out of sync, which is its own future defect class |
| **The deciding argument** | Tightening 7b requires distinguishing *"these directories are the kit's"* from *"these happen to share the kit's names"* — **exactly the folder-classification problem Phase 0.D eliminated.** Re-introducing it here undoes the simplification that made this cycle safe | It is the only option that actually removes the false-positive |
| **Blast radius comparison** | 7b is **declinable** and takes **one** batch confirmation the user can refuse outright — bounded. F1-F3 address *silent, per-path* defects with no question at all. Different severity classes | — |

**Recommendation: Option A.** Not because tightening is unimportant, but because doing it here would
re-import the classifier this cycle just removed, into the one step that is already gated by a question
the user can say no to.

### OQ-2 — does F4 (the `working-rules.md` qualifier) ship this cycle?

**What it is.** When the user keeps one of their own files instead of letting setup replace it, the
generated `context/working-rules.md` gains one sentence saying so — so the workspace's standing rules
do not describe a setup the workspace does not have.

| | **Option A — ship now (recommended by @pm; I concur)** | **Option B — defer** |
|---|---|---|
| **What ships** | One extra sentence, conditionally generated, driven by the ledger §B.2 already maintains | Nothing. F1-F3, F5 ship; the qualifier waits |
| **Cost** | Small and *additive*: F1 already needs the `declined` disposition in order to skip the write, so F4 adds a **consumer**, not a mechanism. No new state, no new classification | Zero |
| **What deferring costs** | — | The workspace keeps a `working-rules.md` that describes files the user chose **not** to install. A standing instruction file that is quietly wrong about its own workspace |
| **Clean cut?** | — | **Yes.** §C.5 specifies it: delete §C.5 and `AC-QUALIFIER-1`, drop the ledger's `declined`-consumer clause. F1/F2/F3/F5 are untouched, because F1 needs `declined` for its own purposes regardless |
| **Honest counter-argument** | — | A smaller, faster cycle is a legitimate goal on its own terms, and this is the only item here that is a *nicety* rather than a *falsified promise* |

**Recommendation: Option A (ship now)** — it is the cheapest item in the cycle and the only one whose
absence leaves a newly-written instruction file saying something untrue. But it is genuinely the one
item that can be cut without touching anything else, and the design is built so that cut is one
deletion.

**If the owner does not decide OQ-2:** the spec's default posture is **deferred** (Out of scope item 8).
Phase 4 must then treat F4 as **explicitly cut, recorded as cut** — never silently unimplemented.

---

## §G — Residuals carried forward

| ID | Residual | Severity |
|---|---|---|
| `CF-v2.19.18-STALEECHO` | `WIZARD.md:353` echoes user-controlled folder names (*"[list detected skills]"*) into model context. Pre-existing; **not** created here and not fixable without folder inspection. `stale-skills` makes it test-reachable for the first time (§C.6) — flagged to @security for Phase 2 | MEDIUM |
| `CF-v2.19.18-MATGREP` | `docs/architecture.md` carries 71/71/**72** Maturation-Path headers — one ADR has a `Risk knowingly accepted:` without the sibling two. Pre-existing asymmetry, not repaired here (A.7) | LOW |
| `CF-v2.19.18-ROADSTALE` | `docs/roadmap.md:5` says *"at v2.19.13"* while `VERSION` reads `2.19.16` — the standing staleness hazard the line itself warns about, gone stale again by three releases | LOW |
| `CF-v2.19.18-PREV2` | F2 cannot recover a `CLAUDE.md` already lost to a pre-v2.19.18 run. Named limitation, carried from the spec deliberately | INFO |
| `CF-v2.19.18-UNZIP` | An extract-here unzip that collides files **before any wizard prose runs** is outside the wizard's reach entirely (spec S13). Stated, not solved | INFO |
| `CF-v2.19.18-GATE` | Whether `main`'s merge gate is armed at `ab16ad9` is not verifiable read-only from inside the clone (spec OQ-5). If unarmed, this cycle's branch+PR ceremony is convention, not enforcement | INFO |

---

## Closing note

The spec asked for a per-path collision predicate. The files asked for three more things: a
**provenance** term (the wizard collides with its own writes — §0.3), **two more path families** than
the spec enumerated (`context/writing-profile.md` and every installed `SKILL.md` — §0.1, §0.2), and an
**answer to this repo's own standing no-batching AC** before any consolidation is designed (§B.5).

The cheapest finding to state is the one that best shows why the files had to be opened:
`tests/self-archive-firing-controls.md:17` has been asserting for two cycles that a **workspace**
`.gitignore` protects the archive, while running its control against the **kit's**. It passed every
time. That is the same failure this cycle exists to fix, one layer up: a promise stated in one file, and
never checked against the file it is about.
