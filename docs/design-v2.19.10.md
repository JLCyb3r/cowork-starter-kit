# Phase 1 Design — v2.19.10 "Plain Language: say it the way she'd say it"

> **Cycle:** v2.19.10 (PATCH) · **Phase:** 1 — Design · **Author:** @architect (opus)
> **Date:** 2026-08-20T01:40:00Z
> **Branch:** `release/v2.19.10-plain-language`, in-tree at `/Users/macbookpro/claude-cowork-config`
> (this repo uses branches, not separate worktrees — `git worktree list` shows only `main`)
> **Base:** `fd00dd24a85e24ca0ec64462e191b4de99ff6a1e` (verified ancestor of HEAD this session)
> **Source spec:** `docs/spec.md` § *Product Spec — Cowork Starter Kit v2.19.10*, finalized this phase
> from the post-0.D R3 FINAL draft including orchestrator corrections C-1/C-2/C-3.
>
> Citations are **content-anchored** per ADR-081 §D1 — each is a re-runnable
> `grep -n '<anchor>' <named-file>`. Line numbers, where given, are navigational only and pinned to
> `fd00dd24a85e24ca0ec64462e191b4de99ff6a1e`.

---

## §0. Design header — mandatory records

> *ISO 15288 — Technical Management / Decision Management.*

**Worktree discipline: ENFORCED (SECURITY-SENSITIVE Tier B).** First action was
`git -C /Users/macbookpro/claude-cowork-config rev-parse HEAD` →
`fd00dd24a85e24ca0ec64462e191b4de99ff6a1e`, matching `COUNCIL_EXPECTED_BASE_SHA=fd00dd2`. F6 ancestry
check (`git merge-base --is-ancestor fd00dd2 HEAD`) PASS. Correct branch, clean tree at entry.

**B1 verification: SKIPPED — N/A (external project).** `scripts/guards/scope-allow-verify.sh` and
`.claude/agents/dev.md` are The-Council's own surfaces and are not in this repository's scope. The
`scope_allow_delta:` block is nevertheless present and parseable (§B) — its **absence**, not its
emptiness, is what raises a parse error.

**Production validation: N/A — no repo-artifact parsing in this design.** No component authored this
cycle parses The-Council's `pipeline.md` / `roadmap.md` / `registry.json` family. The one parser this
cycle *does* author (the AC-PL-6 inline `awk`, §C.6) parses a file inside this repository only, and it
was run against the **live** `curated-skills-registry.md` plus two damage fixtures built from it this
session — results pasted in §C.6.

**Maturation Path self-grep (run against `docs/architecture.md` at base, pre-write):**

```text
**Future-state options:**      → 52
**Concrete revisit triggers:** → 52
**Risk knowingly accepted:**   → 52
```

Two new ADRs (ADR-085, ADR-086), each carrying a verbatim `### §Maturation Path` block → post-write
expected **54 / 54 / 54**. **Re-run after writing both ADRs: 54 / 54 / 54 — CONFIRMED**, each header
incremented by exactly 2. The three headers are copied from the template slot, not composed from
memory.

**Reuse Radar — 4-source scan, 0 hits.**

| Source | State | Result |
|---|---|---|
| 1. `docs/reuse-registry.md` (Council) | present | `grep -ic 'plain.language\|jargon\|readability\|register'` → **0** |
| 2. `examples/scaffolds/INDEX.md` (Council) | **ABSENT** | skipped; no new app/service/CLI surface this cycle anyway |
| 3. `docs/constituent-systems.md` (Council) | present | `grep -in 'jargon\|plain.language\|copy.review'` → **0** |
| 4. `.claude/projects/ecosystem/sos-interfaces.json` | present | interface keys are `confidante` / `motif` producers; no copy-register capability |

**Reuse Scan** — one row per non-trivial NEW component. The prose rewrites are not components; the only
candidate is the AC-PL-6 inline gate, non-trivial by the "parser of any size" rule.

| Component | Registry hit | OSS candidate | Scaffold | Decision | Basis |
|---|---|---|---|---|---|
| AC-PL-6 inline valid-hex row-count parser (~30 lines of `awk` + `sh` inside `quality.yml`) | none (grep pasted above) | none sought | n/a (source 2 absent) | **BUILD** | No hit across all 4 sources. The thing parsed is *this repository's own* markdown registry table with a repo-specific 9-field schema and a repo-specific pin; no external tool knows that shape. Core-differentiator/no-hit basis. |

**Buy-vs-Build: 1 component scanned — REUSE 0 / ADOPT 0 / EXTEND 0 / BUILD 1**

**EARS check.** All 8 ACs were re-read against `.claude/skills/architect/ears-requirements.md`. AC-PL-1,
-2, -3, -6 are `WHEN … SHALL`; AC-PL-8 is `WHERE … SHALL`; AC-PL-5 and -7 are ubiquitous `SHALL`;
AC-PL-4 is a state-invariant `SHALL` phrased as a placement requirement. **EARS check: 0 HIGH-severity
findings — no OQs generated.** Advisory (MEDIUM, not raised as an OQ): AC-PL-4's "dated one-line
forward-pointer" leaves the date format unstated — resolved in this design at §C.4 rather than sent
back, since it is a fill-in, not an ambiguity about the requirement.

**SoS Classification + UAF: N/A — single-project design.** The cycle touches exactly one registered
project (`claude-cowork-config`). Per EC-1 the four viewpoints are emitted explicitly rather than
omitted: **Strategic — N/A, single-project design. Operational — N/A, single-project design. Service —
N/A, single-project design. Personnel — N/A, single-project design.**

**Reliability Analysis: N/A per NEVER-APPLY** (no external API provider in any request path, no
failover or fallback mechanism, no SLA or availability claim anywhere in the spec).

**Heuristics Check (Rechtin, per `architect-principles.md` §A5).**

| Heuristic | Signal produced this cycle |
|---|---|
| *"Simplify. Simplify. Simplify."* | Fired against the two-parser AC-PL-6 instrument already retired at 0.D R3; fired again in §C.7, where the corrected row-6 instrument is a **count comparison**, not a second parser. |
| *"The greatest leverage in system architecting is at the interfaces."* | The interface here is the **prose contract** between kit and user. AC-PL-7's floor exists because prose is the only place these guarantees live — no mechanical reader enforces them. |
| *"Do the hard parts first."* | Applied to sequencing: §D orders the AC-PL-6 gate to land **before** any description rewrite, so the instrument exists before the damage it detects becomes possible. |
| *"A model is not reality."* | Fired directly and produced F-1 (§E.1): a `grep -qF` presence model of "the guarantee is still there" is not the reality of a file with two copies of the string. |
| *"Relationships among elements are what give systems their added value."* | Not applicable — rationale: no new element or relationship is introduced; every edit is in-place text on existing surfaces. |

**Classification Re-Run (`§PostOQClassificationReRun`): see §F.** Verdict: **CONFIRMED
SECURITY-SENSITIVE Tier B**, no flip in either direction.

---

## §A. Scope confirmation — both AC-PL-1 grounds hold independently

> *ISO 15288 — Stakeholder Needs and Requirements Definition (verification of a stated requirement basis).*

Risk item 7 of the FINAL draft asks Phase 1 to confirm that AC-PL-1's two grounds hold **independently**,
not merely that the count still totals 6. Both were re-derived this session.

### A.1 — Group A's ground: discriminating, 2 of 30

```bash
awk -F'|' '{s=$8; gsub(/ /,"",s); if (s ~ /^[0-9a-f]{64}$/) {n=$2; gsub(/ /,"",n); g=$7; gsub(/^ +| +$/,"",g); split(g,a,","); print n"\t"length(a)" tags"}}' curated-skills-registry.md
```

Exactly two rows carry all 7 preset tags: **`prompt-gate`** and **`anti-ai-slop`**. Every other row
carries 1–3. The verbatim-fallback render path they feed is real and re-derived:
`grep -n 'truncated to ≤12 words' WIZARD.md` → *"fall back to the verbatim `description` (truncated to
≤12 words)"*. Ground CONFIRMED and discriminating.

### A.2 — Group B's ground: severity, and it is mechanically derivable

Group B makes **no reach claim** — the FINAL draft deleted that. What Phase 1 adds is that the severity
ground turns out to be *measurable*, not merely assertable. Jargon-hit count per description
(case-insensitive stem match against the canonical 34-term Jargon List):

| rank | hits | row |
|---|---|---|
| 1 | **8** | `self-apply` |
| 2 | **6** | `pull-updates` |
| 2 | **6** | `self-upgrade` |
| 4 | **5** | `self-archive` |
| 5 | 3 | `anti-ai-slop` |
| 6 | 2 | `prompt-gate` |
| 7–30 | **0** | *all 24 remaining rows* |

**The 6 in-scope rows are exactly the 6 rows with a non-zero jargon-hit count; the other 24 are all
zero.** The scope boundary is a clean partition, not a judgment call, and Group B occupies the top four
strictly above Group A. Ground CONFIRMED and discriminating.

**Stated to its instrument, not wider (`docs/patterns.md:55`):** this density metric is a **scope-boundary
corroborator and a direction-of-travel signal only**. It is Q1's mechanical leg alone. It is **not** the
AC-PL-1 pass criterion — that remains @qa's full 3-question read at Phase 5, because Q1 permits a listed
term that carries an inline definition in the same sentence, and Q2/Q3 are outside this metric entirely.
A post-edit count of 0 does not by itself mean PASS, and a post-edit count of 1 does not by itself mean
FAIL.

### A.3 — Corroboration: the row count reconciles with the 25-skill pool

30 registry rows = **4** `mandatory-infrastructure` rows (exactly Group B) + **26** non-infra rows,
which resolve to **25 distinct pool slugs** (`research-synthesis` appears twice — the ADR-018 study and
research variants). This independently corroborates three separate things at once: the AC-PL-6 pin of
30; the `25` numeral AC-PL-3 must preserve; and the zero-render-path claim, since
`grep -n 'the addressable set is still exactly the 25-skill pool' WIZARD.md` bounds the matching set to
the 25, which excludes all four Group B rows **by construction rather than by inspection**.

---

## §B. `scope_allow_delta:`

> *ISO 15288 — Technical Management / Configuration Management.*

```yaml
scope_allow_delta:
  add: []
  # N/A for this repository — B1 cross-reference is a Council-internal control
  # (.claude/agents/dev.md scope_allow.<scope>), and claude-cowork-config is an
  # external project. Block present-and-parseable per ADR-115: its absence, not its
  # emptiness, is the parse error.
```

---

## §C. Per-AC implementation mechanism

> *ISO 15288 — Architecture Definition / Design Definition.*

### C.1 — AC-PL-1, registry descriptions (6 rows)

**Edit site:** `curated-skills-registry.md`, the `description` cell (field 3) of six rows, located by
content anchor — `grep -n '^| self-apply |' curated-skills-registry.md` and the same form for
`self-archive`, `self-upgrade`, `pull-updates`, `prompt-gate`, `anti-ai-slop`.

**Mechanism.** Rewrite field 3 only. Fields 1, 2, 4, 5, 6, 7, 8, 9 are byte-unchanged, which is what
keeps `registry-sha256-check` and `registry-cardinality-check` green and what makes AC-PL-6's pin hold.

**Three hard constraints on the rewrite, in priority order:**

1. **No `|` character may appear in the new description text**, and the row's pipe padding
   (`| ` … ` |`) must be preserved. This is the single failure mode AC-PL-6 exists to catch, and it is
   the failure mode a plain-language rewrite most plausibly causes (a writer reaching for a
   pipe-separated list). Note the existing `self-apply` text contains `apply/verify/rollback` — slashes
   are safe; pipes are not.
2. **Group A only — matching preservation.** Each rewritten Group A description must retain ≥1
   non-stopword token shared with (a) its skill's `name` and (b) its pre-edit description. STOPWORDS is
   the 64-token list at `grep -n 'STOPWORDS list (64 tokens)' WIZARD.md`, single-sourced with F3 per
   SF-1 — do not build a second list. **Group B is functionally inert here**, not silently satisfied:
   per §A.3 those four rows are outside the addressable matching set by construction.
3. **Group A only — the ≤12-word truncation must still read as English.** The role-generation fallback
   truncates the description to ≤12 words verbatim, so the rewrite's **first 12 words must stand alone
   as a sentence a non-technical reader understands.** Phase 5 reads the truncation, not just the full
   string.

**Negative control (@qa, Phase 5):** the 3-question read against the CURRENT description **and its
≤12-word truncation** MUST fail Q1 for all six rows. §A.2's table is the pre-registered pre-edit
measurement that makes this a diff rather than a re-read.

### C.2 — AC-PL-2, wizard closing message

**Edit site:** `WIZARD.md`, the single quoted paragraph located by
`grep -n 'Setup complete. Your workspace now contains' WIZARD.md`. One line, one string.

**Mechanism.** Rewrite the prose *around* the enumerated items. Every technical term gets an inline
definition **including inside parentheticals** — the parentheticals are where the current string fails
worst (`memory-of-use ledger's apply/verify/rollback rules`, `walking your workspace's engine forward
across kit versions`).

**The pin — see §D.2.** The eleven backticked items and the `[list]` placeholder are pinned as a
literal list. Phase 5's no-dropped-items check is `diff` against that pin, not a re-read.

**AC-PL-7 row 5 is the floor here.** `never silently performs`, `reversibly`, and `never on its own`
must survive. All three are **unique in the file** (`grep -cF` → 1 each, verified this session), so
presence-anywhere `grep -qF` is a sound instrument for row 5 — unlike row 6 (§C.7).

### C.3 — AC-PL-3, F4 bundle menu, spoken lines only

**Edit sites, by content anchor:**

| Anchor | Spoken? | Action |
|---|---|---|
| `grep -n 'Your bundle: \[final skill list\]' WIZARD.md` | quoted — **IN** | rewrite; `bundle` is on the Jargon List |
| `grep -n 'Add from optional tier' WIZARD.md` | quoted — **IN** | rewrite; `optional tier` is on the Jargon List |
| `grep -n 'Add from cross-cutting' WIZARD.md` | quoted — **IN** | rewrite; `cross-cutting` and `bundle` are on the Jargon List |
| `grep -n 'Add from full pool' WIZARD.md` | quoted — **IN** | rewrite; `pool` is on the Jargon List. **`25` must survive verbatim** |
| `grep -n 'Remove:\*\* Name any skill to drop it' WIZARD.md` | quoted — **IN** | already plain; likely no change |
| `grep -n 'Done / keep all' WIZARD.md` | quoted — **IN** | already plain; likely no change |
| `grep -n "That's not in the current pool" WIZARD.md` | `say:` — **IN** | rewrite; `pool` is on the Jargon List |
| `grep -n "Installing skills from external sources" WIZARD.md` | `respond:` — **IN**, but see §C.7 | rewrite; `pool` is on the Jargon List |
| `grep -n 'Installed skills will help you with' WIZARD.md` | `Display as:` — **IN** | already plain; likely no change |
| `### F4 — Bundle customization` heading | meta-prose — **OUT** | byte-unchanged |
| `the user has a proposed skill bundle` | meta-prose — **OUT** | byte-unchanged |
| `For each skill in the final bundle` | meta-prose — **OUT** | byte-unchanged |
| `**Pool boundary (C-v2.4-7, v2.6 update):**` label and the `(25 slugs)` clause | meta-prose — **OUT** | byte-unchanged |

**The `25` constraint, precisely.** Six other `25` occurrences are out of scope and byte-unchanged, all
six reproduced this session (`WIZARD.md` matching line, `WIZARD.md` Pool boundary line,
`SETUP-CHECKLIST.md`, `tests/offline-smoke-test.md`, `README.md` ×2, `.claude/skills/skill-studio/SKILL.md`).
**No CI job checks this numeral** — Phase 5 is its only instrument.

**Do NOT re-run the historical `AC-CI-*` / `AC-COMP-2` verify commands recorded in
`docs/architecture.md` against this tree.** They are append-only records of a closed cycle
(`§F EXEMPT`). v2.19.9 lost time to exactly this collision.

**Unit and case-sensitivity, stated (`docs/patterns.md:56`).** The binding AC-PL-3 figure is **2
user-facing `bundle` occurrences**, measured **per occurrence**, **case-sensitively**. See F-3 (§E.3)
for why the case-sensitivity qualifier is not redundant.

### C.4 — AC-PL-4, no-jargon rule, discoverable home

**Edit site 1 — `CONTRIBUTING.md`, additive section only.** Insert a new `## Runtime-string register`
section immediately after the existing `## Registry entries — \`curated-skills-registry.md\`` section
(anchor: `grep -n '^## Registry entries' CONTRIBUTING.md`, and the section ends at the next `^## `).
Placing it there rather than at end-of-file is the whole point of the AC: it sits inside the block a
contributor editing a `description` is already reading.

**Content the section must carry** (this is the register itself, not a pointer to it):

- The enumerated runtime-string surfaces: registry `description` cells; the `WIZARD.md` closing
  message; `WIZARD.md` spoken/quoted strings; `working-rules.md` non-Safety sentences.
- The rule: **plain English, no jargon without an inline definition in the same sentence** — the same
  register the v2.5.3 row applies to SEO/positioning copy, now extended to runtime strings.
- The floor: **a rewrite may simplify wording; it may never weaken a stated guarantee** (AC-PL-7),
  including the explicit warning about weakening-by-addition (adding an exception clause while leaving
  every enumerated item intact).
- A pointer back to `docs/spec.md` § *Product Spec — Cowork Starter Kit v2.19.10* for the full ACs.

**Edit site 2 — `docs/spec.md`, one-line forward-pointer.** Immediately after the v2.5.3 row (anchor:
`grep -n 'no jargon without inline definition' docs/spec.md`), on its own line **outside the table**,
add a dated pointer. **Date format resolved here rather than sent back as an OQ:** `YYYY-MM-DD`, matching
the `vetting_date` convention already used in this repository. The line must contain the literal string
`CONTRIBUTING.md § Runtime-string register` so AC-PL-4's grep can find it.

**The v2.5.3 row itself is byte-unchanged.** Verify in `git diff`, not by eye.

**Negative controls — and AC-PL-4's second instrument had to be replaced. See F-6 (§E.6).**

Leg 1 is sound and unchanged: `grep -c "Runtime-string register" CONTRIBUTING.md` → **0** pre-edit,
**1** post-edit.

Leg 2 as written in the AC — `grep -c "CONTRIBUTING.md § Runtime-string register" docs/spec.md` = 1 —
**is already satisfied by this cycle's own Phase-1 spec append**, which quotes the instrument verbatim
while describing it. Measured after the append: **1**, before @dev writes anything. Post-edit it would
be **2**, so an `= 1` assertion would FAIL on a correct implementation, and a `>= 1` assertion would
pass with the forward-pointer entirely absent — a check that cannot fail. Both readings are broken.

**Corrected leg 2 — scope the assertion to the v2.5.3 row's own region**, applying ADR-086
§Decision (4) (a string that is not unique must not be presence-tested file-wide):

```bash
# The anchor grep now returns 3 matches (the v2.5.3 row plus two v2.19.10 prose mentions),
# so `head -1` is required — it selects the real row at the top of the file.
ANCHOR=$(grep -n 'no jargon without inline definition' docs/spec.md | head -1 | cut -d: -f1)
sed -n "${ANCHOR},$((ANCHOR+3))p" docs/spec.md \
  | grep -cF 'CONTRIBUTING.md § Runtime-string register'
```

**Verified this session: pre-edit → 0** (the v2.19.10 mentions are ~7,100 lines away and cannot reach
the window). **Post-edit must be 1.** Firing negative control confirmed.

**Consequence for @dev:** the forward-pointer must land **within 3 lines after the v2.5.3 row**, not at
the end of the file. That is also where it belongs for a human reader.

### C.5 — AC-PL-5, `working-rules.md` × 8, an AUDIT

**Expected edits: exactly one file.** The Q1 mechanical leg was run across all 8 files this session:

```bash
for f in examples/*/context/working-rules.md templates/preset-template/context/working-rules.md; do
  printf "%-58s %s\n" "$f" "$(grep -oiFf <jargon-list> "$f" | sort | uniq -c | tr '\n' ';')"
done
```

| file | Q1 hits |
|---|---|
| `examples/business-admin/context/working-rules.md` | none |
| `examples/creative/context/working-rules.md` | none |
| **`examples/personal-assistant/context/working-rules.md`** | **1 × `APIs`** |
| `examples/project-management/context/working-rules.md` | none |
| `examples/research/context/working-rules.md` | none |
| `examples/study/context/working-rules.md` | none |
| `examples/writing/context/working-rules.md` | none |
| `templates/preset-template/context/working-rules.md` | none |

The FINAL draft's `[CONFIRMED, R3]` assumption reproduces exactly: **1 finding, not 0.** Stated to its
instrument: this is Q1 only; Q2 and Q3 remain @qa's read at Phase 5 and may surface more.

**The one edit — and it is governed by AC-PL-7, not by Q2.** The Data locality clause
(`grep -n '^## Data locality' examples/personal-assistant/context/working-rules.md`) currently ends
*"…to external services or APIs."* **Inline-define `APIs`; do not compress the sentence.** AC-PL-7's
precedence rule is binding here and is the single most likely place a well-meaning implementer does the
wrong thing — the tidy fix is to delete the word, and deleting it narrows the guarantee.

**Shape of the correct edit:** an appositive that adds a definition and removes nothing, e.g.
*"…to external services or APIs (other programs your computer talks to over the internet)."* The six
enumerated categories, `Never send`, and `decline and offer a local alternative` are all untouched, and
**no exception token is introduced** — verify with the (c) deny-list, which must stay at 0.

**Safety-sentence instrument.** `grep -qF` of the pre-edit literal *"Always ask for explicit confirmation
before deleting, moving, or overwriting any file or folder."* against each post-edit file. **NOT `cmp`**
— `cmp` would pass 8 identically-reworded files. **No line-pinned extraction:** verified this session,
the sentence is at line 7 in the seven examples and line **9** in the template.

**Synthetic negative control — executed at Phase 1, fires.** A scratch copy of
`examples/writing/context/working-rules.md` with one non-Safety sentence given a Jargon-bearing tail
(`…per the two-write-class self-integrity invariant`) returns **2 Q1 hits** where the live file returns
**0**. The instrument is proven able to fail.

**Corroboration only, NOT load-bearing:** the 9-token sweep returning 0 across all 8. That wordlist came
from a different document family, so a 0 has little discriminating power.

### C.6 — AC-PL-6, the inline `quality.yml` gate

**Status: DESIGNED, NOT IMPLEMENTED.** @dev lands it at Phase 4; Phase 1 does not write
`.github/workflows/`.

**Validation scope — stated to what was actually executed, not wider.** Executed against the live tree
this session: the `awk` parser, both `sed` fixture constructions verbatim as written below, and the
three resulting counts with their exit codes (table further down). **NOT executed as a unit:** the
surrounding bash wrapper — `mktemp -d`, `trap`, the `for` loop, and the `if`/`else` branching. The
agent-scope guard in this environment refused every attempt to stage a runnable script, so the wrapper
is asserted on structural grounds only: it mirrors the fault-injection step already in production
immediately above it in this same job. **@dev must run this step locally once before pushing** and
confirm the three fixture lines print; do not treat the wrapper as pre-verified.

**TIER-4 compliance, stated explicitly.** The control lands **entirely inside the existing
`registry-sha256-check` job** in `.github/workflows/quality.yml` (anchor:
`grep -n '^  registry-sha256-check:' .github/workflows/quality.yml`). **No file is added or modified
under `scripts/`.** The pin is declared once at **job level** via `env:`, so the fault-injection step
and the assertion step read the same value and cannot drift apart — and because both steps are in one
job, **no `needs:` and no `outputs:` plumbing is required.**

**Job-level `env:` block** — insert immediately after `runs-on: ubuntu-latest` in `registry-sha256-check`:

```yaml
    env:
      # AC-PL-6 (v2.19.10) — pinned count of registry rows carrying a valid 64-char
      # lowercase-hex sha256 in field 8.
      #
      # THIS PIN MOVES WITH THE ROW COUNT. v2.19.10 adds and removes no rows, which is the
      # only reason a hard pin is legitimate here. A future cycle that adds or removes a
      # registry row MUST bump this value in the same commit — otherwise the check either
      # fails on arrival or, worse, silently blesses a row that lost its sha256 cell.
      # Declared at job level so the fault-injection step and the assertion step below
      # cannot drift apart.
      AC_PL_6_EXPECTED_HEX_ROWS: 30
```

**Step 1 — fault injection.** Insert as the step immediately **before** the existing
`Verify curated-skills-registry.md sha256 matches …` step, matching this job's established
fault-injection-first house pattern and `docs/hld.md:37` Principle 5:

```yaml
      - name: AC-PL-6 fault injection — the pinned row-structure count MUST be able to fail
        run: |
          set -euo pipefail
          # v2.19.10 AC-PL-6. Prove the pinned-count logic CAN fail before trusting it on
          # real data — same model as this job's existing sha256 fault-injection step.
          count_hex_rows() {
            awk -F'|' '{s=$8; gsub(/ /,"",s); if (s ~ /^[0-9a-f]{64}$/) c++} END{print c+0}' "$1"
          }

          FIX="$(mktemp -d)"
          trap 'rm -rf "$FIX"' EXIT

          # Fixture 1 — clean tree. MUST equal the pin.
          cp curated-skills-registry.md "$FIX/clean.md"

          # Fixture 2 — a single stray '|' inside one description shifts every later field
          # right, so that row's field 8 is no longer its sha256. This is precisely the
          # damage a plain-language rewrite can do by accident.
          # NOTE: '/' is the sed delimiter throughout; '|' is a literal. Do NOT switch the
          # delimiter to '|' here — the pattern and replacement both contain pipes.
          sed 's/apply\/verify\/rollback machinery/apply\/verify | rollback machinery/' \
            curated-skills-registry.md > "$FIX/pipe.md"

          # Fixture 3 — COMPOUND: reword the description AND reflow the row's pipe spacing.
          # This is the case that returns a FALSE GREEN under a two-parser instrument (one
          # content-matching, one strictly positional): both parsers break identically and
          # cancel. A single parser has nothing to cancel against.
          sed 's/apply\/verify\/rollback machinery/apply | verify | undo steps/' \
            curated-skills-registry.md \
            | sed 's/^| self-apply |/|self-apply|/' > "$FIX/compound.md"

          for f in clean pipe compound; do
            n="$(count_hex_rows "$FIX/$f.md")"
            if [ "$f" = "clean" ]; then
              if [ "$n" -ne "$AC_PL_6_EXPECTED_HEX_ROWS" ]; then
                echo "::error::AC-PL-6 FIXTURE-VALIDITY FAILED — clean fixture counted ${n}, expected ${AC_PL_6_EXPECTED_HEX_ROWS}. Either the registry row count changed (bump AC_PL_6_EXPECTED_HEX_ROWS) or the parser no longer matches the table shape."
                exit 1
              fi
            else
              if [ "$n" -eq "$AC_PL_6_EXPECTED_HEX_ROWS" ]; then
                echo "::error::AC-PL-6 FAULT-INJECTION FAILED — the '${f}' fixture still counted ${AC_PL_6_EXPECTED_HEX_ROWS}. The check cannot fail on the condition it exists to catch; do not trust it."
                exit 1
              fi
            fi
            echo "AC-PL-6 fixture '${f}': ${n} valid-hex rows."
          done
          echo "AC-PL-6 fault-injection PASSED — clean=${AC_PL_6_EXPECTED_HEX_ROWS}, both damage fixtures detected."
```

**Step 2 — the assertion.** Insert immediately after step 1:

```yaml
      - name: AC-PL-6 — registry row-structure integrity (pinned valid-hex row count)
        run: |
          set -euo pipefail
          ACTUAL="$(awk -F'|' '{s=$8; gsub(/ /,"",s); if (s ~ /^[0-9a-f]{64}$/) c++} END{print c+0}' curated-skills-registry.md)"
          if [ "$ACTUAL" -ne "$AC_PL_6_EXPECTED_HEX_ROWS" ]; then
            echo "::error::AC-PL-6 FAILED — ${ACTUAL} rows carry a valid 64-char lowercase-hex value in field 8; expected exactly ${AC_PL_6_EXPECTED_HEX_ROWS}. A description rewrite most likely introduced a '|' character or reflowed a row's pipe layout. If this cycle intentionally added or removed a registry row, bump AC_PL_6_EXPECTED_HEX_ROWS in this job's env: block."
            exit 1
          fi
          echo "AC-PL-6 PASSED — ${ACTUAL} rows carry a valid sha256 cell in field 8 (pin: ${AC_PL_6_EXPECTED_HEX_ROWS})."
```

**Negative controls — all three executed at Phase 1 against the live tree:**

| fixture | construction | valid-hex rows | `exit !(c==30)` | verdict |
|---|---|---|---|---|
| clean | `curated-skills-registry.md` as-is | **30** | 0 | **GREEN** |
| pipe | one `\|` injected into `self-apply`'s description | **29** | 1 | **RED** |
| compound | reword + reflow (`\| self-apply \|` → `\|self-apply\|`) | **29** | 1 | **RED** |

Both legs of the compound fixture were confirmed to fire independently — the reflow leg alone was
verified to change the row (`grep -c '^|self-apply|'` → 1 post-`sed`), so "compound" is not a claim
wider than its instrument.

**The forbidden alternative, measured.** A bare `NF!=9` sweep scoped to pipe-bearing lines returns **9**
false positives on the clean tree
(`awk -F'|' '/\|/ && NF!=9 {c++} END{print c}' curated-skills-registry.md` → 9), caused by the 2-column
schema legend near `grep -n '^| Field | Description |' curated-skills-registry.md`. It fails its own
negative control and MUST NOT be substituted. (0.D recorded 8 from one measurement and 9 from two
others; this session measured **9**, stated as measured rather than inherited.)

### C.7 — AC-PL-7, safety-semantics preservation

**Rows 1–5 land as written in the spec.** Row 1's eight tokens, row 2's per-file folder token sets (all
7 example rows reproduced exactly this session), rows 3, 4, and 5 — all use `grep -qF`
presence-anywhere, and all their protected strings were confirmed **unique in their file**, which is
what makes presence a sound instrument for them.

**Row 6 is different, and its instrument as written CANNOT FAIL. See F-1 (§E.1).**

The external-source refusal string *"Installing skills from external sources isn't supported yet — the
wizard installs only from the local, vetted pool."* occurs **twice** in `WIZARD.md`: once in the Network
& Offline Rule (`grep -n 'I can.t reach external sites from this session' WIZARD.md`) and once in the F4
Pool boundary (`grep -n 'No URL paste, no external source' WIZARD.md`). The F4 copy is the one AC-PL-3
rewrites. **A presence-anywhere `grep -qF` therefore stays GREEN even if the F4 copy is deleted
outright** — proven this session against a fixture that replaced it: `grep -qF` → GREEN, on exactly the
condition row 6 exists to catch.

**Corrected instrument for row 6 — count equality, not presence** (pending orchestrator ratification per
F-1):

```bash
# Pre-edit and post-edit MUST be equal. Pre-edit measured this session: 2.
grep -cF "Installing skills from external sources isn't supported yet" WIZARD.md
```

Against the same fixture this returns **1** where clean returns **2** → **RED**. Proven able to fail.

This is deliberately the **same shape as AC-PL-7(c)'s set-equality**, not a new mechanism — the row-6
fix is "count, don't presence-test," which is the lesson (c) already encodes. It adds no second parser.

`No URL paste, no external source` needs no change: `grep -cF` → **1**, unique, so presence is sound.

**AC-PL-7(c), the exception-token deny list — executed at Phase 1, and it is load-bearing.**

| fixture | (a) enumeration | (b) negative guarantee | (c) deny-list count | verdict |
|---|---|---|---|---|
| clean Data locality clause | 8/8 present | present | **0** | GREEN |
| weakening-by-**addition** rewrite | **8/8 present** | **present** | **5** | **RED — only (c) sees it** |

The addition fixture appended *"unless a web service is needed"*, *"except where you judge it useful"*,
*"or go ahead if it is quicker"*, and *"without checking with me first"*. All eight protected tokens
survive; the guarantee is gutted. **(c) is the only leg that fires.** (0.D predicted 4 deny-list matches;
this session measured **5** — `if it` also matches from *"or go ahead if it is quicker"*. Immaterial,
both are `> 0` and the pre/post inequality is what fires, but stated as measured rather than inherited.)

**Precedence, restated because it is where implementation goes wrong:** WHERE AC-PL-7 and the 3-question
read conflict, **AC-PL-7 WINS. Inline-define the term; never compress the sentence.**

### C.8 — AC-PL-8, template parity

Every audit and assertion under AC-PL-5 and AC-PL-7 runs over **8** files. The glob
`examples/*/context/working-rules.md` yields **7**; the template must be named explicitly. The
canonical form used throughout this design is:

```bash
for f in examples/*/context/working-rules.md templates/preset-template/context/working-rules.md; do …; done
```

**Negative control — run BOTH legs.** Reword the Safety sentence in the template only; the 8-file
comparison MUST flag it and the 7-file-only comparison MUST NOT. Running only the 8-file leg proves it
fires; running both proves the 7-file version is the one that *cannot* fail, which is the actual claim.

**CI coverage is zero, and the gap is wider than the spec recorded.** `grep -rn "preset-template"
.github/workflows/ scripts/` → **0**, reproduced this session. Phase 1 also ran
`grep -rn "working-rules" .github/workflows/` → **0**: **no CI job covers any of the 8 files**, not just
the template. AC-PL-8 plus @qa's Phase-5 read are the only instruments that exist for this entire
surface. Recorded as F-4 (§E.4).

---

## §D. File-by-file Phase-4 implementation plan

> *ISO 15288 — Implementation Process (plan).*

### D.1 — The file list

| # | File | Phase | Change | Constraint |
|---|---|---|---|---|
| 1 | `.github/workflows/quality.yml` | 4 | job-level `env:` + 2 steps inside `registry-sha256-check` | TIER-4: inline only, no `scripts/` file, no `needs:`/`outputs:` |
| 2 | `curated-skills-registry.md` | 4 | field 3 of 6 rows | no `|` in new text; all other fields byte-unchanged |
| 3 | `WIZARD.md` | 4 | closing message + 7–9 F4 spoken strings | `25` verbatim; AC-PL-7 rows 5 and 6 |
| 4 | `examples/personal-assistant/context/working-rules.md` | 4 | inline-define `APIs` in § Data locality | AC-PL-7 row 1 + (c) must stay at 0 |
| 5 | `CONTRIBUTING.md` | 4 | **NEW** `## Runtime-string register` section | additive only |
| 6 | `docs/spec.md` | 1 (done) + 4 | Phase-1 append (done); Phase-4 adds the AC-PL-4 forward-pointer | append/annotate only; v2.5.3 row byte-unchanged |
| 7 | `docs/design-v2.19.10.md` | 1 (this file) | NEW | — |
| 8 | `docs/architecture.md` | 1 | 2 ADR Index rows + cycle header + ADR-085 + ADR-086 | append-only |
| 9 | `CHANGELOG.md` / `VERSION` | 4 | v2.19.10 release rows | house convention |
| 10 | `docs/internal/qa/qa-report-v2.19.10.md` | 5 | NEW, @qa | — |

**The other 7 `working-rules.md` files are IN SCOPE FOR AUDIT and expected to receive ZERO edits.** If
@qa's Phase-5 Q2/Q3 read surfaces a finding in one of them, that is an in-scope edit, not a scope
breach — but it must be recorded as a delta against §C.5's pre-registered table.

**Sequencing is load-bearing.** File 1 lands **first**, in its own commit, before any description
rewrite. The instrument must exist before the damage it detects becomes possible. Landing them together
means the gate's first-ever run is against already-modified content, and a fixture-validity failure
would be indistinguishable from a real regression.

**Byte-mirror trap (CMP) — checked, and this cycle is clear.** Verified this session rather than
inherited:

- `find . -name "curated-skills-registry.md" -not -path './.git/*'` → **1** result (repo root). The
  registry has no mirror.
- The 21 mirrored pool skills under `examples/*/.claude/skills/` contain **none** of the six in-scope
  slugs (`self-apply`, `self-archive`, `self-upgrade`, `pull-updates`, `prompt-gate`, `anti-ai-slop`).
- No `skills/<slug>/SKILL.md` is edited at all this cycle — which is also what keeps
  `registry-sha256-check` green and TIER-1 clean.
- `working-rules.md` lives under `examples/<preset>/context/`, outside the `.claude/skills/`
  byte-mirror family entirely, and no CI job references it (§C.8).

**`docs/design-v2.19.10.md` ships in the release archive.** `docs/` is default-internal only under
`docs/internal/` (`.gitattributes:26-28`), and `docs/design-v2.19.8.md` is confirmed present in
`git archive` output per the v2.19.9 record. Zero verbatim vendor quotations are authored in this file;
the COMPLIANCE condition holds and `/legal` is not owed on this ground.

### D.2 — THE AC-PL-2 PIN (pre-edit enumeration, literal)

> Extracted mechanically, not transcribed:
> `sed -n '<closing-message-line>p' WIZARD.md | grep -oE '`[^`]+`'`
> Anchor: `grep -n 'Setup complete. Your workspace now contains' WIZARD.md`.
> Phase 5's no-dropped-items check is a **diff against this list**, not a re-read.

```text
 1  `_setup-kit/`
 2  `CLAUDE.md`
 3  `project-instructions.txt`
 4  `cowork-profile.md`
 5  `context/`
 6  `connector-checklist.md`
 7  `skills-as-prompts.md`
 8  `self-apply`
 9  `self-archive`
10  `self-upgrade`
11  `pull-updates`
```

**Count: 11 backticked items.**

**Plus one un-backticked item that MUST also survive: the `[list]` placeholder**, in the clause *"your
installed skills: [list]"*. It is not backticked, so the mechanical extraction above misses it — and it
is the *entire installed-skills enumeration*. Dropping it would be the single largest possible
no-dropped-items regression while the 11-item diff stayed clean. It is pinned here as item 12 and gets
its own check: `grep -cF 'installed skills: [list]' WIZARD.md` must remain ≥ 1 (pre-edit value: 1). If
the rewrite rephrases the surrounding clause, the placeholder token `[list]` must still be present and
still bind to the installed-skills enumeration.

**Phase-5 verification recipe:**

```bash
# 1. Item diff — must be empty.
diff <(printf '%s\n' '`_setup-kit/`' '`CLAUDE.md`' '`project-instructions.txt`' \
        '`cowork-profile.md`' '`context/`' '`connector-checklist.md`' \
        '`skills-as-prompts.md`' '`self-apply`' '`self-archive`' '`self-upgrade`' \
        '`pull-updates`') \
     <(sed -n "$(grep -n 'Setup complete' WIZARD.md | cut -d: -f1)p" WIZARD.md \
        | grep -oE '`[^`]+`')

# 2. The un-backticked 12th item.
grep -cF '[list]' WIZARD.md   # pre-edit baseline recorded at Phase 1

# 3. AC-PL-7 row 5 — three unique strings, presence is sound here.
grep -cF 'never silently performs' WIZARD.md   # = 1
grep -cF 'reversibly' WIZARD.md                # = 1
grep -cF 'never on its own' WIZARD.md          # = 1
```

---

## §E. Phase-1 findings — routed to the orchestrator, NOT edited into the ACs

> *ISO 15288 — Verification Process.*
>
> Per the standing rule, @architect may not amend a requirement it is designing against. Each finding
> below is reported for orchestrator disposition. F-1 is BLOCKER-class.

### E.1 — F-1 (BLOCKER): AC-PL-7 row 6's instrument returns GREEN on the condition it exists to catch

**Claim.** The external-source refusal string occurs **twice** in `WIZARD.md`. AC-PL-7's stated
instrument is `grep -qF` presence-anywhere. Deleting or rewriting the F4 copy — the copy this cycle
actually edits — leaves the Network & Offline Rule copy intact, so the check passes.

**Proof, executed this session.** A fixture replacing the F4 copy with a plainer sentence:

```text
grep -qF "Installing skills from external sources isn't supported yet" <fixture>  → GREEN
grep -cF "Installing skills from external sources isn't supported yet" <clean>    → 2
grep -cF "Installing skills from external sources isn't supported yet" <fixture>  → 1  (RED)
```

**Severity.** This is the **third** instance this cycle of an instrument that goes GREEN on its own
target condition — after AC-PL-6's two-parser cancellation and AC-PL-7's weakening-by-addition blindness,
both of which were BLOCKERs at 0.D R2. Unlike those two, this one survived all three review rounds and
would have shipped. It sits on the F4 pool boundary — the **B2 basis for this cycle's SECURITY-SENSITIVE
classification**.

**Proposed remedy (specified in §C.7, awaiting ratification).** Replace row 6's presence test with a
pre/post **count equality** — the same shape AC-PL-7(c) already uses. Proven able to fail. No second
parser, no new mechanism.

**Recommended disposition: ADOPT.** The design is written against the corrected instrument; if the
orchestrator declines, §C.7 must be reverted to presence-testing and the gap recorded as accepted risk.

### E.2 — F-2 (INFO, changes no AC): AC-PL-4's "does not ship" rationale is falsified

**Claim.** The FINAL draft justifies choosing `CONTRIBUTING.md` over `docs/spec.md` partly on:
*"`docs/spec.md` is `export-ignore`d (`.gitattributes:31`) and does not ship — a rule living only there
has no reader."* The `docs/spec.md` half is correct. But `CONTRIBUTING.md` is **also** `export-ignore`d,
at `.gitattributes:16`. Both are absent from the release archive; both are present in a clone.

**Verified.** `cat -n .gitattributes` → `:16 CONTRIBUTING.md export-ignore`, `:31 docs/spec.md
export-ignore`, and `:2` states the mechanism affects *"only `git archive` … not `git clone` or working
tree."*

**Why the decision still stands.** The audience for AC-PL-4 is a **contributor editing a runtime
string**, who works from a clone, where `export-ignore` is irrelevant. The adjacency argument —
`CONTRIBUTING.md` already carries `## Registry entries`, `## Skill content safety`, and
`## Placeholder authoring rules` (all three verified this session) — is independently sufficient and is
the real discriminator.

**Why it is still worth reporting.** The falsified sentence would otherwise sit in the record asserting
that `CONTRIBUTING.md` ships, and a future cycle could reason from it. This is the
`docs/patterns.md:55` shape — a claim wider than its instrument. The spec's AC-PL-4 rationale has been
annotated at Phase 1 to point here; **no AC text changed.**

### E.3 — F-3 (INFO, changes no decision): C-1's `bundle` count needs a case-sensitivity qualifier

**Claim.** C-1's table gives *"total in region 5"* with 3 Claude-facing occurrences at the F4 heading,
the meta-prose line, and the role-generation line. Measured **case-sensitively**, the region contains
**4** occurrences of `bundle`, not 5 — the F4 heading reads *"### F4 — **B**undle customization"*, and
`grep`/`awk` case-sensitive matching does not count it. Case-**in**sensitively it is 5.

**Verified.** `awk 'NR>=110 && NR<=125 {t+=gsub(/bundle/,"x")} END{print t}' WIZARD.md` → **4**.

**Impact: none on any decision.** The binding AC-PL-3 figure — **2 user-facing occurrences** — is
unchanged and correct under both readings, and `bundle` is on the Jargon List regardless.

**Why reported.** C-1 exists to close a `docs/patterns.md:56` ambiguous-unit instance and states the
unit (per-occurrence vs per-line) but leaves case-sensitivity unstated — while Q1 was simultaneously
redefined as case-**in**sensitive stem matching. Two different case conventions are in play in the same
document. §C.3 states both qualifiers. **This is a refinement of an already-recorded in-cycle instance,
not a new one, and it does not increment the WATCH count.**

### E.4 — F-4 (INFO): the `working-rules.md` CI gap is wider than AC-PL-8 records

**Claim.** AC-PL-8's note records `grep -rn "preset-template" .github/workflows/ scripts/` → 0 and
concludes *"No CI job covers this file."* True. But `grep -rn "working-rules" .github/workflows/` → **0**
as well: **no CI job covers any of the 8 files**, not just the template.

**Impact.** Strengthens rather than weakens AC-PL-8, and confirms the "Safety-sentence prefix caveat"
constraint (three CI jobs assert the safety sentence, none of them against `working-rules.md`). Recorded
so the ceiling on this surface's automated coverage is stated where a future cycle will find it, rather
than rediscovered. **No AC change proposed.**

### E.5 — F-5 (INFO, out of scope): ADR-081 has no ADR Index row

`grep -n '^| ADR-081' docs/architecture.md` → **0 matches**. The index jumps ADR-080 → ADR-082 while
ADR-081 exists as a full record at `grep -n '^## ADR-081' docs/architecture.md`. Pre-existing, unrelated
to this cycle, and **not fixed here** — adding an index row is additive and therefore permissible under
the append-only convention, but it is outside this cycle's scope and belongs to whoever owns record
hygiene. Reported so it is not lost.

### E.6 — F-6 (BLOCKER-class, self-inflicted): AC-PL-4's leg-2 instrument is satisfied by the act of documenting it

**Claim.** AC-PL-4's second instrument is
`grep -c "CONTRIBUTING.md § Runtime-string register" docs/spec.md` = 1, with a stated pre-edit negative
control of 0. **Writing the AC into `docs/spec.md` at Phase 1 — which this cycle's worktree-aware
Phase-0 finalization requires — quotes that literal and makes the count 1 before any implementation
work happens.**

**Proof, measured after the Phase-1 spec append:**

```text
grep -cF 'CONTRIBUTING.md § Runtime-string register' docs/spec.md   → 1   (expected pre-edit: 0)
```

After @dev adds the real forward-pointer the count becomes **2**. So an `= 1` assertion **fails on a
correct implementation**, and relaxing it to `>= 1` **passes with the forward-pointer entirely absent**.
There is no threshold that works file-wide.

**Why this one is worth stating plainly.** It is self-inflicted — created by my own Phase-1 artifact,
not inherited from Phase 0 — and it is the same failure class as F-1 and as the two 0.D BLOCKERs: an
instrument that does not measure what it claims to measure. It is caught here only because the
negative controls were re-run against the tree **after** writing, not merely quoted from the spec.
Re-running a check after your own edit is the step that found it.

**Proposed remedy (specified in §C.4, awaiting ratification).** Scope leg 2 to a 4-line window anchored
on the v2.5.3 row, applying the rule ADR-086 §Decision (4) mints for exactly this situation. Verified
pre-edit **0**, so the negative control fires. Leg 1 (`CONTRIBUTING.md`) is unaffected and unchanged.

**Recommended disposition: ADOPT.** Unlike F-1 this changes no requirement — the *requirement* (a dated
forward-pointer next to the v2.5.3 row, that row byte-unchanged) is untouched. Only the verification
command changes. If the orchestrator prefers, an equivalent remedy is to require a distinctive marker
token in the pointer line; the scoped-window form was chosen because it needs no new convention.

---

## §F. `§PostOQClassificationReRun` record

> *ISO 15288 — Decision Management.*

**Re-evaluated against the FINAL file list in §D.1, after all Open Questions were resolved.**

**Verdict: CONFIRMED — SECURITY-SENSITIVE, Tier B. No flip in either direction.**

| Basis | Final-file-list evidence |
|---|---|
| B1 — registry is a runtime supply-chain control | `curated-skills-registry.md` is file 2. Still in. |
| B2 — F4 pool boundary is a prose safety clause | `WIZARD.md` is file 3. Still in, and F-1 makes it *more* load-bearing, not less. |
| B3 — closing message states 3 negative guarantees | `WIZARD.md` is file 3. Still in. |
| B4 — Data locality PII clause | `examples/personal-assistant/context/working-rules.md` is file 4. Still in. |
| `.github/workflows/` | `quality.yml` is file 1. Tier B on its own. |

**`CONTRIBUTING.md` — the new entrant, assessed explicitly.** It joins the list as file 5 via AC-PL-4.
It is a **contributor-facing instruction surface**, not a runtime control: nothing reads it at wizard
time, it is `export-ignore`d from the release archive (F-2), and the section added is purely additive
prose. It **does not raise** the classification. It does not introduce a `scripts/`, lock-file, or
CODEOWNERS touch. Its net effect on ceremony is nil — the cycle was already Tier B on four independent
grounds before it was added.

**Four Tier-A snapback conditions — all clear against the final file list:**

| # | Condition | Status against §D.1 |
|---|---|---|
| TIER-1 | any `scripts/` file added or modified | **CLEAR** — no `scripts/` path appears in the file list. AC-PL-6 lands inline (§C.6). No `skills/<slug>/SKILL.md` edit means no `scripts/registry-hash.sh` regeneration is triggered. |
| TIER-2 | `cowork.lock.json` / `.cowork-allowlist.json` modified | **CLEAR** — neither appears in the file list. |
| TIER-3 | `.github/CODEOWNERS` modified, incl. adding a path this cycle touches | **CLEAR** — not in the file list; no path addition proposed. |
| TIER-4 | AC-PL-6's control under `scripts/` instead of inline | **CLEAR** — §C.6 lands one job-level `env:` block and two steps, all inside the existing `registry-sha256-check` job, with no `needs:` and no `outputs:`. |

**No Guard Change Summary is owed.** Tier B holds; nothing in the design crosses into Tier A. Had it
crossed, this section would say so rather than design across the line.

**COMPLIANCE-SENSITIVE = NO — condition re-checked and holding.** The binding condition is that
`/legal` becomes owed if an edit changes the **enumerated set** of protected data categories in
§ Data locality. §C.5's designed edit is an **appositive definition of `APIs` that adds words and
removes none**; all six categories, `Never send`, and `decline and offer a local alternative` are
byte-preserved, and the AC-PL-7(c) deny-list must remain at **0**. The enumerated set is unchanged.
**`/legal` is NOT owed.**

**Standing instruction to @dev and @qa:** the (c) deny-list count on the Data locality clause is the
tripwire for this condition. If it moves off 0, or if any of the six category tokens changes, **stop and
escalate — `/legal` becomes owed before Phase 3**, and no amount of "the rewrite reads better" overrides
it.

---

## §G. Anti-pattern scan

> *ISO 15288 — Architecture Definition (design review).*

| # | Anti-pattern | Result |
|---|---|---|
| 1 | God Class/Module | N/A — no module authored |
| 2 | Circular Dependencies | N/A — no dependency graph change |
| 3 | Leaky Abstraction | N/A |
| 4 | Premature Optimization | None |
| 5 | Over-Engineering | **Actively resisted.** The single-parser pin (§C.6) and the count-equality row-6 fix (§C.7) were both chosen over adding a second mechanism. |
| 6 | Tight Coupling | **One instance, accepted and named:** `AC_PL_6_EXPECTED_HEX_ROWS` couples a CI pin to the registry's row count. Mitigated by declaring it once at job level, and by stating the coupling in the `env:` comment, in the failure message, and in ADR-085 §Maturation Path. |
| 7 | Missing Separation of Concerns | N/A |
| 8 | N+1 Query Pattern | N/A |
| 9 | Destructive Migration | N/A — no schema, no DROP, no data migration. Every edit is additive or in-place text. |
| 10 | SoS Interface Discontinuity | N/A — single-project |
| 11 | Cross-Project Tight Coupling | N/A — no dependency on another registered project's internals |

---

End of v2.19.10 Phase 1 design.
