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

> ### AMENDMENT — 2026-08-20, after Phase 2 returned FAIL (0 CRITICAL, 2 BLOCKER)
>
> **Both BLOCKERs were in this document's own Phase-1 corrections, not in the Phase-0 ACs.** One
> amendment round; nothing was implemented, so this is not a redesign. Amended on
> `release/v2.19.10-plain-language` @ `d306e17`.
>
> | ID | Sev | Where it lives now |
> |---|---|---|
> | **S1** — AC-PL-6's fixtures self-destruct on this cycle's own mandated AC-PL-1 rewrite | **BLOCKER** | §C.6 (fixtures replaced + validity guard), §E.7, ADR-087 §Decision (1)/(2) |
> | **S2** — F-1's remedy freezes the announcement, not the guarantee | **BLOCKER** | §C.7 (scoped instrument), §E.8, ADR-087 §Decision (3) |
> | **S3** — AC-PL-3 × AC-PL-7 row 6 collide on `WIZARD.md:123`; @dev was not told | HIGH | §C.3 warning box |
> | **S4** — 14 internal reports ship in the public archive | HIGH | §E.9 — **REPORTED, retrofit NOT bundled**; free in-cycle remedy bound in §D.1 |
> | **S5** — §C.3's anchor-uniqueness claim named 1 exception; there are 2 | MED | §C.3 (corrected table) |
> | **S6** — AC-PL-7 row 2's "all unique in their file" is false; margin is 2 tokens, not 5 | MED | §C.7 |
> | **S7** — §C.6's "both legs fire independently" is false at instrument level | MED | §C.6 (claim fixed, **no parser added**) |
> | **S8** — F-6 verifies the pointer's string but not that it is DATED | MED | §C.4 (leg 2b added) |
> | **S9** — `grep -cF` counts LINES, used as an occurrence test on paragraph-length lines | MED | §C.0 (method standardized) |
> | **S10** — CODEOWNERS AC-E3-2 deferral was silent | LOW | §H (recorded deferral) |
> | **S11/S12** — unquoted YAML pin; `set -u` local-run trap | INFO | §C.6 |
>
> **Method, binding and followed:** every amended instrument was run against the **pre-fix** tree and
> observed **RED** before being relied on, and then against @security's **own retained fixtures** —
> not against reconstructions, and not accepted on description. Results in §C.6, §C.7, §E.7, §E.8.
>
> **No AC's requirement was changed.** Every item is an instrument fix or a record correction. S4 —
> the one item whose full remedy would change scope — is reported, not actioned.
>
> **Amendment self-grep (`docs/architecture.md`, ADR-087 adds one `§Maturation Path` block):**
>
> ```text
> **Future-state options:**      → 54 → 55  (+1)
> **Concrete revisit triggers:** → 54 → 55  (+1)
> **Risk knowingly accepted:**   → 54 → 55  (+1)
> ```
>
> Each header incremented by exactly 1, copied verbatim from the template slot.

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

**Amendment addition — validation now covers the tree THIS CYCLE CREATES, not only the tree it starts
from.** Running an instrument against the live tree was necessary and not sufficient: it is exactly
what the original §C.6 did, and it is what let S1 through. Every instrument is now additionally run
against a **simulated post-edit tree** — the live tree with this cycle's own mandated AC-PL-1 rewrite
applied — and, where @security supplied fixtures, against **those fixtures directly** rather than
against reconstructions of them. Two-tree control tables in §C.6 and §C.7.

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

### C.0 — Counting method, standardized (amendment, Phase-2 finding S9)

**Every "unique in its file" claim in the original design rested on `grep -cF`, which counts LINES, not
occurrences — used as an occurrence test, on files written in paragraph-length lines.** `WIZARD.md:123`
is a single ~600-character line; the entire F4 closing message is line `:339`. **Two occurrences inside
one paragraph report as `1`.** Every uniqueness claim in this document was therefore made with an
instrument that could not have detected the condition that would falsify it.

**Re-run at the amendment with `grep -oF … | wc -l` (occurrences), all claims HOLD** — the findings were
sound; the method was not. That distinction is the point: a right answer from a wrong instrument is
luck, and luck does not survive the next file.

**Binding for this cycle, for @dev and @qa alike:**

- Uniqueness and occurrence claims use **`grep -oF "<literal>" <file> | wc -l`**, never `grep -cF`.
- `grep -cF` remains correct where the quantity genuinely IS lines (e.g. "how many lines match").
- **Name the unit on every number** (`docs/patterns.md:56`, a live instance — WATCH 2/3 this cycle):
  write *"2 occurrences"* or *"2 lines"*, never a bare *"2"*.

Where this document quotes an older `grep -c` figure inside an append-only record (§E findings,
`docs/architecture.md` ADRs), the figure is left as written — those are historical records — and the
corrected occurrence-based measurement is stated alongside it.

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
| `grep -n '\*\*Add from full pool:\*\*' WIZARD.md` | quoted — **IN** | rewrite; `pool` is on the Jargon List. **`25` must survive verbatim** |
| `grep -n 'Remove:\*\* Name any skill to drop it' WIZARD.md` | quoted — **IN** | already plain; likely no change |
| `grep -n 'Done / keep all' WIZARD.md` | quoted — **IN** | already plain; likely no change |
| `grep -n "That's not in the current pool" WIZARD.md` | `say:` — **IN** | rewrite; `pool` is on the Jargon List |
| `grep -n 'No URL paste, no external source' WIZARD.md` (the F4 line, `:123`) | `respond:` — **IN**, but **CONSTRAINED — read the box below before touching it** | **additive rewrite of the TAIL ONLY**; `pool` is on the Jargon List |
| `grep -n 'Installed skills will help you with' WIZARD.md` | `Display as:` — **IN** | already plain; likely no change |
| `### F4 — Bundle customization` heading | meta-prose — **OUT** | byte-unchanged |
| `the user has a proposed skill bundle` | meta-prose — **OUT** | byte-unchanged |
| `For each skill in the final bundle` | meta-prose — **OUT** | byte-unchanged |
| `**Pool boundary (C-v2.4-7, v2.6 update):**` label and the `(25 slugs)` clause | meta-prose — **OUT** | byte-unchanged |

> ### ⚠ AC-PL-3 × AC-PL-7 row 6 COLLIDE ON `WIZARD.md:123`. READ THIS BEFORE EDITING THAT LINE.
>
> This is the one line in the cycle where a **correct-looking plain-language rewrite fails CI**. It was
> missing from this table until the amendment (Phase-2 finding S3); a bare *"rewrite; `pool` is on the
> Jargon List"* instruction would have led @dev straight into it.
>
> The `respond:` string on `:123` has two halves, and **only the second may change**:
>
> `"Installing skills from external sources isn't supported yet` **← FROZEN, byte-for-byte**
> ` — the wizard installs only from the local, vetted pool."` **← may be extended, ADDITIVELY ONLY**
>
> **The only compliant shape is to APPEND an inline definition after `…vetted pool`.** Measured at the
> amendment:
>
> | edit | AC-PL-7 row 6 | note |
> |---|---|---|
> | append inline definition after `…vetted pool` | **GREEN** | **the only compliant shape** |
> | rewrite the opening into plainer English (e.g. *"You cannot add skills from the internet yet"*) | **RED** | fails on correct-looking work |
> | delete the tail clause | **RED** | this is the S2 defect the amended instrument now catches |
>
> **A plain-language pass WILL reach for that opening** — Q2 may well flag `external sources` as an
> undefined term. Do not. Under §C.7's stated precedence, **AC-PL-7 WINS: inline-define the term,
> never compress or reword the sentence.** If the opening genuinely reads as jargon, define
> `external sources` in the appended tail; leave the opening alone.

**Anchor uniqueness, verified per anchor — applying ADR-086 §Decision (4) to this design's own
citations.** **Corrected at the amendment (Phase-2 finding S5): the original claim named ONE exception;
there are TWO.** Re-measured by occurrence (`grep -oF … | wc -l`):

| anchor | occurrences | status |
|---|---|---|
| `Add from full pool` (bare) | **2** | **NOT unique** — 2nd is a Path C cross-reference (`grep -n 'Then route into F4' WIZARD.md`), outside the F4 region. Use the bolded form `**Add from full pool:**` → **1**. |
| `Installing skills from external sources` | **2** | **NOT unique** — `:27` (Network & Offline Rule) and `:123` (F4 Pool boundary). This non-uniqueness is the entire subject of §C.7 two pages later, yet the anchor sat in this table claiming uniqueness. Use the scoped form: `grep -n 'No URL paste, no external source' WIZARD.md` → **1**. |
| all 8 other anchors in the table | **1** each | unique — verified individually, not assumed |

Both ambiguous anchors have been replaced in the table above with their scoped/bolded forms. A
bare-string anchor in either row would have handed @dev an ambiguous edit site.

**That Path C line is NOT a missed edit — recorded so it is not "fixed" by mistake.** It reads:
*"…**Closest pool skills (existing routing).** Say: \"Tell me the first capability you want … to start
the draft.\" Then route into F4's \"Add from full pool\" flow."* Its **spoken** text — the part inside
the `Say:` quotes — contains **no Jargon-List term**. The word `pool` appears twice on that line, both
times in Claude-facing meta-prose (the bold label, and the cross-reference naming the F4 menu item).
Under AC-PL-3's scope rule — quoted/spoken text only — the line is correctly **OUT**, and it is out on
its own merits rather than merely by being outside the region. **Leave it byte-unchanged.**

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

# Leg 2a — the pointer's STRING, scoped to the v2.5.3 row's own window.
sed -n "${ANCHOR},$((ANCHOR+3))p" docs/spec.md \
  | grep -cF 'CONTRIBUTING.md § Runtime-string register'

# Leg 2b — the pointer must be DATED (S8). AC-PL-4 requires a *dated* forward-pointer;
# leg 2a verifies only that the string is present, so on its own it accepts an undated
# pointer and the AC's date requirement would have had no instrument at all.
sed -n "${ANCHOR},$((ANCHOR+3))p" docs/spec.md | grep -cE '[0-9]{4}-[0-9]{2}-[0-9]{2}'
```

**Verified at the amendment against the live tree — both legs, both directions:**

| leg | pre-edit (required) | measured pre-edit | post-edit (required) |
|---|---|---|---|
| 2a — pointer string in window | 0 | **0** ✓ | 1 |
| 2b — `YYYY-MM-DD` in window | 0 | **0** ✓ | 1 |

Both negative controls fire (the v2.19.10 prose mentions are ~7,100 lines away and cannot reach the
window; the window carries no date today). The resolved anchor is `docs/spec.md:824`, window
**824–827**.

**Record correction (S8) — the file-wide count drifted again during Phase 1.** F-6 (§E.6) recorded the
file-wide `grep -c 'CONTRIBUTING.md § Runtime-string register' docs/spec.md` as **1**. Re-measured at
the amendment: **2**, at `docs/spec.md:8020` and `:8193`. Every additional Phase-1 sentence that quotes
the instrument moves it again. This does not weaken F-6 — **it strengthens it**: the file-wide count is
not merely wrong-by-one, it is *unstable by construction*, which is precisely why leg 2 had to be
scoped to a window rather than re-pinned to a bigger number. The scoped legs above are unaffected by
the drift (both still measure 0 pre-edit), which is the property that makes them sound.

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

**Validation scope — stated to what was actually executed, not wider. REVISED at the amendment.**

**Executed, against BOTH the live tree and a simulated post-AC-PL-1 tree:** the `awk` counting parser,
the field-2-anchored `awk` fixture construction verbatim as written below, the `sed` reflow, the
`cmp -s` fixture-validity guard, and every resulting count (two-tree table further down). The same
amended fixture was additionally run against **@security's own retained `rewritten.md` fixture** — not
a reconstruction of it — returning **29**, where the superseded `sed` form returned 30.

**NOT executed as a unit:** the surrounding bash wrapper — `mktemp -d`, `trap`, the `for` loops, and
the `if`/`else` branching. The agent-scope guard in this environment refused every attempt to stage a
runnable script, so the wrapper is asserted on structural grounds only: it mirrors the fault-injection
step already in production immediately above it in this same job. **@dev must run this step locally
once before pushing** (see the `export` note above — `set -u` will otherwise abort on the unset pin)
and confirm the three fixture lines print; do not treat the wrapper as pre-verified.

**What the original version of this paragraph got wrong, recorded because it is the lesson.** It said
"executed against the live tree," which was true — and insufficient. Every instrument here is now
validated against **the tree this cycle creates**, not only the tree it starts from. Validating against
the starting tree is precisely what let S1 through.

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
      # Quoted (S11): the value is consumed only as a shell string compared with `-ne`.
      # Unquoted it parses as a YAML integer — harmless today, but quoting removes the
      # question rather than leaving a reader to re-derive the answer.
      AC_PL_6_EXPECTED_HEX_ROWS: "30"
```

**Running step 1 or step 2 locally (S12).** Both steps run under `set -u` and read
`AC_PL_6_EXPECTED_HEX_ROWS` from the job-level `env:` block, which does not exist outside Actions.
Export it first:

```bash
export AC_PL_6_EXPECTED_HEX_ROWS=30
```

Without it, `set -u` aborts with an unbound-variable error that reads like a logic bug in the check
rather than a missing local export. @dev must do this for the mandated pre-push local run.

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

          # Fixture 2 — pipe injection, ANCHORED ON FIELD 2, NOT ON DESCRIPTION CONTENT.
          # A single stray '|' inside one description shifts every later field right, so
          # that row's field 8 is no longer its sha256. This is precisely the damage a
          # plain-language rewrite can do by accident.
          #
          # The anchor is field 2 (`| self-apply |`), which AC-PL-1 leaves byte-unchanged,
          # and the injection is positional — it never quotes any of the description's
          # words. A content-anchored `sed` here NO-OPS the moment AC-PL-1 rewrites the
          # description it quotes, silently turning this fixture into a copy of the clean
          # tree. See F-7 (§E.7). This is the same field-anchored shape the REAL_HASH
          # fixture already in this job uses (quality.yml:573).
          awk -F'|' 'BEGIN{OFS="|"} $2==" self-apply " {$3=$3 "| "} 1' \
            curated-skills-registry.md > "$FIX/pipe.md"

          # Fixture 3 — COMPOUND: the same positional pipe injection PLUS a reflow of the
          # row's pipe spacing. This is the case that returns a FALSE GREEN under a
          # two-parser instrument (one content-matching, one strictly positional): both
          # parsers break identically and cancel. A single parser has nothing to cancel
          # against.
          #
          # HONEST SCOPE: the reflow leg alone does NOT move this count (measured: 30 —
          # reflowing pipe SPACING does not change pipe COUNT, so field 8 is untouched).
          # The RED below comes entirely from the pipe-injection leg. Reflow-only damage
          # is caught by wizard-consistency-check (quality.yml:1966), not by this step.
          sed 's/^| self-apply |/|self-apply|/' "$FIX/pipe.md" > "$FIX/compound.md"

          # FIXTURE-VALIDITY GUARD — house pattern, mirroring the REAL_HASH guard in this
          # job's existing sha256 fault-injection step (quality.yml:573-576). A damage
          # fixture byte-identical to its source is a no-op, and a no-op fixture reports
          # downstream as "the check cannot fail" — blaming the check for the fixture's
          # own evaporation. Name the real cause instead.
          for f in pipe compound; do
            if cmp -s curated-skills-registry.md "$FIX/$f.md"; then
              echo "::error::AC-PL-6 FIXTURE SETUP FAILED — the '${f}' damage fixture was a no-op; its anchor no longer exists in the registry. Repair the FIXTURE's anchor. Do NOT relax the assertion below, and do NOT bump the pin."
              exit 1
            fi
          done

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
            echo "::error::AC-PL-6 FAILED — ${ACTUAL} rows carry a valid 64-char lowercase-hex value in field 8; expected exactly ${AC_PL_6_EXPECTED_HEX_ROWS}. A description rewrite most likely introduced a '|' character into a cell, shifting every later field right so that row's field 8 is no longer its sha256. NOTE: this check counts FIELDS — it does not detect a pure whitespace reflow of a row's pipe layout; wizard-consistency-check covers that. If this cycle intentionally added or removed a registry row, bump AC_PL_6_EXPECTED_HEX_ROWS in this job's env: block."
            exit 1
          fi
          echo "AC-PL-6 PASSED — ${ACTUAL} rows carry a valid sha256 cell in field 8 (pin: ${AC_PL_6_EXPECTED_HEX_ROWS})."
```

**Negative controls — executed at Phase 1 against the live tree AND, at the amendment, against a
simulated post-AC-PL-1 tree.** The second column is the one the original design omitted, and its
absence was BLOCKER S1. "post-rewrite" = the live tree with `self-apply`'s description rewritten to
remove Jargon-List term #7 (`apply/verify/rollback`), which AC-PL-1 **requires**.

| fixture | construction | clean tree | post-rewrite tree | verdict |
|---|---|---|---|---|
| clean | `curated-skills-registry.md` as-is | **30** | **30** | **GREEN** both |
| pipe *(SUPERSEDED, content-anchored `sed`)* | `sed` quoting `apply/verify/rollback machinery` | **29 RED** | **30 — fixture evaporates** | **REJECTED** |
| compound *(SUPERSEDED, content-anchored `sed`)* | same `sed` + reflow | **29 RED** | **30 — fixture evaporates** | **REJECTED** |
| pipe *(ADOPTED, field-2 `awk`)* | positional `\|` into field 3, keyed on `\| self-apply \|` | **29 RED** | **29 RED** | **ADOPTED** |
| compound *(ADOPTED)* | field-2 `awk` + reflow | **29 RED** | **29 RED** | **ADOPTED** |
| reflow-only | `\| self-apply \|` → `\|self-apply\|`, nothing else | **30 GREEN** | — | **not detected here — by design** |

**Correction (S7) — the compound fixture's two legs do NOT fire independently, and the original text
claiming they did was a claim wider than its instrument** (`docs/patterns.md:55`, WATCH 2/3 this cycle).
Measured: reflow-only returns **30 → GREEN**. Reflowing pipe *spacing* does not change pipe *count*, so
field 8 is untouched and this parser cannot see it. **The compound fixture's RED comes entirely from
the pipe-injection leg.** The earlier "verified to change the row (`grep -c '^|self-apply|'` → 1)"
measurement was real but proved only that the `sed` fired — not that the *instrument* responded to it.

**This is a gap in the claim, not in the coverage, and no second parser is being added.** Reflow-only
damage is already caught by `wizard-consistency-check` (`quality.yml:1966`), whose per-skill
`grep -qE "^\| ${slug} \|"` fails on exactly that mutation — verified at the amendment: RED on the
reflow-only fixture, GREEN on the clean tree. ADR-086's single-parser decision stands; adding a second
parser here would reintroduce the cancellation defect the ADR exists to prevent.

**The forbidden alternative, measured.** A bare `NF!=9` sweep scoped to pipe-bearing lines returns **9**
false positives on the clean tree
(`awk -F'|' '/\|/ && NF!=9 {c++} END{print c}' curated-skills-registry.md` → 9), caused by the 2-column
schema legend near `grep -n '^| Field | Description |' curated-skills-registry.md`. It fails its own
negative control and MUST NOT be substituted. (0.D recorded 8 from one measurement and 9 from two
others; this session measured **9**, stated as measured rather than inherited.)

### C.7 — AC-PL-7, safety-semantics preservation

**Rows 1–5 land as written in the spec.** Row 1's eight tokens, row 2's per-file folder token sets (all
7 example rows reproduced exactly this session), rows 3, 4, and 5 — all use `grep -qF`
presence-anywhere.

**Correction (S6) — the blanket claim "all their protected strings were confirmed unique in their
file" was FALSE for row 2, and is withdrawn.** Re-measured at the amendment by occurrence:

| file | token | occurrences |
|---|---|---|
| `examples/personal-assistant/context/working-rules.md` | `Tasks/` | **3** |
| `examples/personal-assistant/context/working-rules.md` | `People/` | **3** |
| `examples/personal-assistant/context/working-rules.md` | `Calendar/` | **2** |
| `examples/personal-assistant/context/working-rules.md` | `Finances/` | 1 |
| `examples/personal-assistant/context/working-rules.md` | `Documents/` | 1 |
| `examples/writing/context/working-rules.md` | `Voice-and-Style/` | **2** |

The extra occurrences leak in from `§ Daily briefing` and `§ Follow-ups` (and the writing preset's own
later sections) — prose mentions outside the data-locality enumeration the row protects.

**Row 2 still FIRES, and it was proven, not assumed.** Compressing the protected enumeration
(`examples/personal-assistant/context/working-rules.md:31` — *"Only access files in my Calendar/,
Finances/, Tasks/, People/, and Documents/ folders"*) down to *"my folders"* drops `Finances/` and
`Documents/` to **0 occurrences**, so `grep -qF` goes RED on both. Row 2 is therefore **contained, not
broken**, and it lands as written.

**But @qa must know the margin, because it is not what the row's shape implies.** Of row 2's five
tokens for this file, **only 2 are load-bearing** (`Finances/`, `Documents/`). The other three survive
the exact compression the row exists to catch, because their extra occurrences elsewhere in the file
keep a presence test GREEN. **The margin is 2 tokens, not 5.** Any future edit that also touches
`§ Daily briefing` or `§ Follow-ups` narrows it further, and an edit that removes the last
`Finances/` and `Documents/` prose mentions while compressing line 31 would take it to zero. Recorded
so the row's apparent 5-token redundancy is never mistaken for real redundancy.

**Row 6 is different, and its instrument as written CANNOT FAIL. See F-1 (§E.1).**

The external-source refusal string *"Installing skills from external sources isn't supported yet — the
wizard installs only from the local, vetted pool."* occurs **twice** in `WIZARD.md`: once in the Network
& Offline Rule (`grep -n 'I can.t reach external sites from this session' WIZARD.md`) and once in the F4
Pool boundary (`grep -n 'No URL paste, no external source' WIZARD.md`). The F4 copy is the one AC-PL-3
rewrites. **A presence-anywhere `grep -qF` therefore stays GREEN even if the F4 copy is deleted
outright** — proven this session against a fixture that replaced it: `grep -qF` → GREEN, on exactly the
condition row 6 exists to catch.

**Corrected instrument for row 6 — SUPERSEDED ONCE ALREADY. See F-8 (§E.8).** The first correction
(a file-wide `grep -cF` count equality, pre-edit **2**) was itself too narrow, and that was BLOCKER S2
at Phase 2. It froze only the sentence's **first clause** — the announcement that external installs
are unsupported — and left the **restriction itself** unprotected. Measured at the amendment:

```text
sed '123s/ — the wizard installs only from the local, vetted pool\.//' WIZARD.md
  → grep -oF "Installing skills from external sources isn't supported yet" | wc -l  → 2 → GREEN
```

Deleting *"— the wizard installs only from the local, vetted pool"* — the positive statement of where
skills may come from, i.e. **the actual pool boundary this row exists to protect** — left the
instrument GREEN. A count instrument is only as good as the string it counts.

**ADOPTED instrument for row 6 — anchor-scoped, then assert BOTH halves within that scope.** This is
the repo's own house remedy for a whole-file grep that wrongly passes outright
(`self-apply-deny-completeness-check`, `quality.yml:753-785`, which extracts the deny-list's own
paragraph via `awk -v RS='' -v anchor=…` rather than grepping the file), and it is the same shape
already chosen for F-6 two pages earlier in this document. **Applying scoping to F-6 and bare counting
to F-1 was the inconsistency; this removes it.**

```bash
# Leg A (primary) — scope to the F4 pool-boundary line, then require BOTH halves on it.
# Anchor verified unique at the amendment: `grep -oF 'No URL paste, no external source' WIZARD.md
# | wc -l` → 1 occurrence.
LINE=$(grep -n 'No URL paste, no external source' WIZARD.md | cut -d: -f1)
CLAUSE=$(sed -n "${LINE}p" WIZARD.md)
echo "$CLAUSE" | grep -qF "Installing skills from external sources isn't supported yet"
echo "$CLAUSE" | grep -qF "the wizard installs only from the local, vetted pool"

# Leg B (secondary, cheap) — retained. Catches out-of-scope edits to the :27 copy, which
# leg A cannot see. Pre-edit and post-edit MUST both be 2 occurrences.
grep -oF "Installing skills from external sources isn't supported yet" WIZARD.md | wc -l
```

**Negative controls, all four executed at the amendment against real fixtures:**

| fixture | leg A half 1 | leg A half 2 | leg B (file-wide, occurrences) | verdict |
|---|---|---|---|---|
| clean tree | GREEN | GREEN | 2 | **GREEN — correct** |
| tail deleted (the S2 fixture — restriction gutted) | GREEN | **RED** | 2 | **RED — the defect leg B missed** |
| opening rewritten into plainer English | **RED** | GREEN | 1 | **RED — see the S3 warning in §C.3** |
| inline definition appended after `…vetted pool` | GREEN | GREEN | 2 | **GREEN — the compliant shape** |

Leg A alone is sufficient for row 6's own guarantee; leg B is kept because it is free and covers a
different surface. Neither adds a parser — both are `grep -F` over the same two literals.

`No URL paste, no external source` needs no change: **1 occurrence**, unique, so presence is sound —
which is what makes it usable as leg A's anchor.

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
| 10 | `docs/internal/qa/qa-report-v2.19.10.md` | 5 | NEW, @qa | **`docs/internal/` — NOT `docs/` root. See the box below.** |
| 11 | `docs/internal/security/security-audit-v2.19.10.md` | 6 | NEW, @security | **`docs/internal/` — NOT `docs/` root. See the box below.** |

> ### ⚠ BINDING — this cycle's QA and security reports land in `docs/internal/`, not `docs/` root
>
> **Applies to @qa (Phase 5) and @security (Phase 2 review + Phase 6 audit). Non-negotiable, and it
> costs nothing — it is a destination path, not extra work.**
>
> `docs/internal/` is `export-ignore`d as a directory prefix (`.gitattributes:28`), so anything there
> is excluded from the public release archive. `docs/` root is not.
>
> Measured at the amendment: `git archive HEAD | tar -tf -` ships **14** internal reports
> (`docs/qa-report-*`, `docs/security-audit-*`, `docs/security-review-*`, v2.18.0 through v2.19.9),
> while `docs/internal/` correctly yields **0** files in the archive. The repository is public and
> those documents enumerate unfixed gaps, inert controls, and zero-coverage areas.
>
> **Do not bundle a retrofit.** The 14 existing files are pre-existing and NOT caused by this cycle;
> moving them is a separate owner decision (reported, not actioned — see §E.9). This instruction binds
> **only this cycle's own new reports**, which is why it is free.
>
> **Asymmetry, stated so it is not "corrected" by mistake:** `docs/design-v2.19.*.md` shipping in the
> archive **is deliberate and recorded** (ADR-037 radical-transparency; `docs/design-v2.19.7.md` §I).
> Design docs stay where they are. Only QA and security reports move.

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

### E.7 — F-7 (BLOCKER, Phase-2 S1): AC-PL-6's fault-injection fixtures self-destruct on this cycle's own mandated edit

**Claim.** Both damage fixtures in §C.6 were anchored on the literal `apply/verify/rollback machinery`.
That string occurs **1 time** in `curated-skills-registry.md`, at line 31 — **inside `self-apply`'s
`description` cell, the exact field AC-PL-1 mandates rewriting.** `apply/verify/rollback` is term #7 on
the Jargon List, so the rewrite is not merely likely, it is **required**.

**Proof, executed at the amendment.** The live tree with `self-apply`'s description rewritten to drop
term #7, then the original `sed` fixtures re-run against it:

| fixture | clean tree | post-rewrite tree |
|---|---|---|
| clean | 30 | 30 |
| pipe (original `sed`) | **29 RED** | **30** |
| compound (original `sed`) | **29 RED** | **30** |

Post-rewrite both `sed`s no-op, both fixtures become byte-identical to the clean tree, and step 1's own
logic fires `AC-PL-6 FAULT-INJECTION FAILED; exit 1`. **§D.1 sequences `quality.yml` first, so the gate
goes GREEN on commit 1 and permanently RED on commit 2** — with an error message blaming the check when
the fixture merely evaporated.

**The 30/29/29 record in the original design reproduces exactly on the clean tree; that record was
honest.** It was simply never re-run against the tree this cycle creates. **The step-2 assertion itself
is sound** — it returns 30 on the rewritten tree, so a clean rewrite correctly stays GREEN. Only the
self-test self-destructs.

**Remedy — both halves applied, both verified (§C.6).**

1. **Content-independent fixture.** Key on field 2 (`| self-apply |`, byte-unchanged by AC-PL-1) and
   inject positionally, never quoting the description's words:
   `awk -F'|' 'BEGIN{OFS="|"} $2==" self-apply " {$3=$3 "| "} 1'`. **Verified 29 on BOTH trees.**
2. **Fixture-validity guard** (`cmp -s` before the count assertion), using the repo's own house pattern
   — the same shape the existing step already applies to `REAL_HASH` at `quality.yml:573-576`. Verified:
   fires on the no-op fixture, silent on a valid one. Converts a silent evaporation into a message
   naming the real cause.

**Severity note.** This is the **4th** instrument this cycle that cannot fail on its target condition,
and the first one located in a *correction* rather than in an original. @security's framing is accepted
verbatim: *"both corrections needed the same scrutiny as the defects they fix, and neither got it."*

### E.8 — F-8 (BLOCKER, Phase-2 S2): F-1's own remedy is narrower than the guarantee it enforces

**F-1's diagnosis is confirmed** (`grep -oF … | wc -l` → **2 occurrences**, at `WIZARD.md:27` and
`:123`). **F-1's remedy was wrong.** The file-wide count freezes only the sentence's **first clause**.

**Proof, executed at the amendment:**

```text
sed '123s/ — the wizard installs only from the local, vetted pool\.//' WIZARD.md
  → grep -oF "Installing skills from external sources isn't supported yet" | wc -l → 2 → GREEN
```

Deleting *"— the wizard installs only from the local, vetted pool"* — **the actual restriction, the
positive statement of where skills may come from** — leaves the instrument GREEN. It protects the
**announcement**, not the **guarantee**. On the F4 pool boundary, which is the **B2** basis for this
cycle's SECURITY-SENSITIVE classification.

**The repo had already solved this class, and the original design did not cite it.**
`quality.yml:753-785` (`self-apply-deny-completeness-check`) is the house remedy for a whole-file grep
that *"wrongly PASSES OUTRIGHT"*: anchor-scoped paragraph extraction (`awk -v RS='' -v anchor=…`) plus a
fault-injection step proving the unscoped form passes. **That is also the shape chosen for F-6 in this
same document.** Applying scoping to F-6 and bare counting to F-1, two pages apart, was the
inconsistency. Accepted in full.

**Remedy — applied and verified (§C.7):** scope to the F4 line via the `No URL paste, no external
source` anchor (**1 occurrence**, verified), then assert **both halves** within that scope; retain the
file-wide occurrence count as a cheap second leg covering the `:27` copy. Four negative controls run,
including the S2 gut-tail fixture (now **RED**) and the additive-definition shape (correctly **GREEN**).

### E.9 — F-9 (HIGH, Phase-2 S4): 14 internal QA/security reports ship in every public release archive — REPORT ONLY, retrofit NOT bundled

**Claim, verified at the amendment.** `git archive HEAD | tar -tf -` lists **14** files matching
`docs/qa-report-*` / `docs/security-{audit,review}-*`; `docs/internal/` correctly yields **0**. The
repository is public, and those documents enumerate unfixed gaps, inert controls, and zero-coverage
areas.

**History, measured rather than asserted.** `docs/internal/qa/` holds **24** files and
`docs/internal/security/` **26**, the newest at **v2.9.0**; every root-level report is **v2.18.0 or
later**. The convention held for ~50 predecessor documents and then lapsed.

**One complication, recorded rather than smoothed over.** `docs/design-v2.19.7.md` §I explicitly
acknowledged root-level reports shipping as a *"conscious choice under ADR-037's radical-transparency
convention, not an oversight."* So this is not cleanly a silent regression — it was noticed once and
rationalized. **Whether radical transparency was intended to extend to QA and security reports (as
opposed to design docs) is an owner question, not an architect question**, which is exactly why the
retrofit is not bundled here.

**Pre-existing and NOT caused by this cycle. Retrofitting the 14 is a separate owner decision — NOT
actioned, NOT bundled.**

**In-cycle remedy, which costs nothing and IS in scope — applied as a binding §D.1 instruction:**
this cycle's QA and security reports are written to `docs/internal/qa/` and `docs/internal/security/`,
not `docs/` root. That is a destination path, not extra work. The asymmetry is preserved deliberately:
`docs/design-v2.19.*.md` continues to ship, per ADR-037.

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

## §H. CODEOWNERS deferral — recorded, not silent (amendment, Phase-2 finding S10)

> *ISO 15288 — Decision Management.*

`.github/CODEOWNERS:54-56` (AC-E3-2) states that owner coverage *"grows with the files THIS cycle
touches."* Followed literally, v2.19.10 would add its own touched files to `CODEOWNERS`.

**Deliberate decision: NOT followed this cycle.** Editing `.github/CODEOWNERS` is a **TIER-3** surface,
and touching it would snap v2.19.10 from **Tier B to Tier A** — owing a Guard Change Summary before the
PR opens, for a PATCH cycle whose entire subject is user-facing wording. The ceremony would exceed the
change by a wide margin, and TIER-4 clearance (§F) is otherwise clean.

**Recorded rather than omitted**, following the standard v2.19.7 set in `docs/design-v2.19.7.md` §H
(*"Recorded here so the deferral is explicit rather than an omission"*). A silent skip and a reasoned
deferral are indistinguishable in a diff; only one of them survives review. Carry-forward: the next
cycle that already touches `CODEOWNERS` for its own reasons should fold v2.19.10's touched files in at
zero marginal ceremony.

---

End of v2.19.10 Phase 1 design.
