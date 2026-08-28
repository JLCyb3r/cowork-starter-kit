# Security Review — plan-2026-08-27-v3-engine (v3.0 "THE ENGINE", spawn-only design)

## Phase: 2
## Date: 2026-08-28T13:09:56Z
## Status: PASS WITH WARNINGS (APPROVE WITH CONDITIONS — 2 CRITICAL conditions must be discharged before the Phase 3 gate closes / before any commit)

Base: `ff0c44c`, VERSION `2.19.13`. Working tree at review time: 6 files, all under `docs/`
(`git status --porcelain`, re-run by @security, not inherited).
**This is the first adversarial reading of this design. Zero deliberation rounds ran (0.D did not
execute; deviation recorded at the pipeline's `1.X 0.D deviation` row). Nothing below was caught by a
prior pass, because there was no prior pass.**

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | CRITICAL | 2 | logging | `docs/carry-forwards.md` newly publishes internal security-finding content into the public release archive; the aggregated content exists in ZERO shipping files at base |
| S2 | CRITICAL | 2 | permissions | ADR-095 D8's migration writes live bytes to an existing user space with no staging leg; the "exceed, never relax the v2.16 gate" obligation is unmet for that path, and `AC-SF2` answers `SF-2` on the path where the risk is absent |
| S3 | WARNING | 2 | schema | Composition leg: the one security-shaped check named in ADR-095 §Context (privilege differential parent→child) is absent from D1's four checks; "instruction-collision detection" has no definition or failure criterion |
| S4 | WARNING | 2 | configuration | `quality.yml` `LEAK_PATTERN` misses bare report filenames; all 3 canaries are versioned, so the gate's own self-test cannot detect the gap. Confirmed by execution |
| S5 | WARNING | 2 | file-upload | Staging path and quarantine path are named but never specified — location, permissions, and reachability by the apply loop are unassessable as written |
| S6 | WARNING | 2 | permissions | D7 removes co-location as the discovery mechanism but specifies no card-enumeration mechanism; `space_path` is an unconstrained absolute path the hub is told to follow |
| S7 | WARNING | 2 | none | ADR-095's "`SECGATE-B1` appears in exactly 3 files repo-wide" is falsified by this cycle's own Phase 1 write (now 4); population not stated as "at base" |
| S8 | WARNING | 2 | schema | "Atomic rename" assumes same-filesystem staging and an absent target; neither is stated, and the verify→rename window is unaddressed |
| S9 | WARNING | 2 | logging | `docs/architecture.md` migration note publishes internal security-finding labels into the shipping archive (lesser form of S1) |
| S10 | WARNING | 2 | none | `docs/risk-register.md` carries 5 stale pre-move report citations; ADR-093's "source wins" rule would propagate them back over `carry-forwards.md`'s corrected paths |
| S11 | INFO | 2 | none | ADR-095 D3's comparison table lists only axes on which SSC wins; the axis it loses (user comprehension of what is authorized) is omitted |
| S12 | INFO | 2 | none | `AC-SPAWN-SEC` enumerates no controls; the two highest-value ones are unnamed |
| S13 | INFO | 2 | none | ADR-095 §Maturation Path revisit trigger is internally incoherent and would fire on the fix for S3 |

**Counts: 2 CRITICAL · 8 WARNING · 3 INFO.**

---

## Classification Re-Run

*Owed by the Phase Log header, scoped to 0.D, which did not run. Derived here, not inherited. The header
requires fail-closed if this subsection is absent; it is present.*

**Write surface, measured — `git status --porcelain` at `/Users/macbookpro/claude-cowork-config`,
re-run by @security:**

| Tier trigger surface | Writes this cycle |
|---|---|
| `scripts/guards/` | **0** |
| `.claude/settings.json` | **0** |
| `docs/pipeline-policy.md` | **0** |
| any `scope_allow:` block | **0** |
| `.github/workflows/` | **0** |
| `.claude/commands/*.md` | **0** |
| `docs/` | 6 (5 modified, 1 new) |

**VERDICT: SECURITY-SENSITIVE = YES (retained) · Tier = NEITHER A NOR B · Guard Change Summary = NOT OWED.**

**The rule this rests on: Tier attaches to the WRITE SURFACE; classification attaches to the SUBJECT.
They are independent axes, and this cycle is the clean case that separates them — maximal subject,
minimal surface.** Ceremony (worktree / PR / GCS) is a control over *which bytes land in enforcement
surfaces*. It cannot be triggered by what a document is *about*, or every security design document
would be Tier A and the tier would stop discriminating. Conversely SECURITY-SENSITIVE drives *review
depth*, and this design is the specification of a security gate on the largest blast radius in the
kit's history, so full OWASP treatment applies and @security is mandatory at Phase 2 and Phase 6.

**I disagree with nothing in the provisional grounds; I am settling the part they left open.** The
grounds recorded at open were correct on both facts. The unsettled Tier resolves to *neither*, which
was not one of the two options offered — that is the finding, not an evasion of it.

**Branch + PR is still required** and is unaffected by this: the pipeline banner already declares
`design/v3.0-engine` → PR. Tier only governs whether a GCS rides with it. It does not.

**CONDITIONAL RE-ESCALATION — binding.** This verdict holds *for the cycle as scoped*. If the
disposition of **S4** (or any other finding) is discharged in-cycle by editing
`.github/workflows/quality.yml` or `.gitattributes`-adjacent enforcement, that edit is **Tier B** and
re-triggers the Tier-B ceremony. It must be split into its own cycle rather than folded in here. See
S4's disposition — I recommend carry-forward precisely so this re-escalation never fires.

### Scope-Allow Re-Walk

PURE-DOC cycle with no `§D File-by-File Implementation Plan` and no code surface, so the B2 re-walk has
no file list to walk. The equivalent check was performed instead: the six written paths were tested
against the tier-trigger surfaces above. **Result: PASS (6/6 files verified `docs/`-only; 0 files
touch any guard, workflow, settings, or scope_allow surface).**

---

## The primary question: does the Staged Spawn Ceremony genuinely exceed the v2.16 gate?

**Judgment: the D2 argument HOLDS. It is not a rationalization for a cheaper gate. But the "exceeds"
conclusion is over-claimed on one axis and outright unmet on one path (S2).**

### Why the argument holds — I tried to break it and could not

The claim under test is D2: per-file confirmation is weaker because Loop 1's verifier is diff-shaped
and a generated tree has no referent. I verified the premise independently rather than accepting it.
`tests/self-upgrade-firing-controls.md` describes Loop 1's gate throughout in pre-image terms —
rollback from a predecessor, a proposed change to a known file. That verifier genuinely has no defined
behavior against a file with no prior state.

The stronger form of the argument, which the ADR makes but could make harder: **for a creation,
per-file confirmation is not merely useless — it is actively worse.** A per-file loop means files go
live incrementally, which manufactures exactly the partially-live window that has no analogue in
v2.16's single-file case. So the rejected option is not "the same gate, N times"; it is "a weaker
containment posture, N times." SSC's lower click-count is a *consequence* of a stronger containment
choice, not a trade against it. That is the opposite of confirmation theater, and the ADR is right.

Containment is also the correct measure for a creation. For a modification, the user's protection is
"I can see what changed and undo it." For a creation there is nothing to diff and nothing to undo
except deletion — which D5 correctly identifies as itself destructive. So "was anything ever live"
becomes the only meaningful safety property, and staging + one rename answers it optimally.

**So: not a cheaper gate wearing a principle. A genuinely stronger containment posture that happens to
cost fewer clicks.** I say this plainly because the cycle prompt asked me to test it rather than accept
it, and testing it made it stronger, not weaker.

### Where it is over-claimed (S11)

D3's table compares SSC to v2.16 on five axes and SSC wins all five. **The axis it loses is missing:
informed consent.** v2.16's user is shown a diff of a file they already know. SSC's user is shown
"what will be created, where, from which pool versions" — a manifest of paths and version strings, not
the instruction text that is about to become their agent's operating instructions. Nobody reads that
text. On comprehension, SSC is strictly weaker than v2.16, and D2 even supplies the standard that
convicts it: *"a gate the user clicks through without reading is weaker than one gate they actually
read."* SSC provides no mechanism ensuring its one confirmation is read, and a path-and-version
itemization is the archetypal skimmed surface.

The honest claim — which I would accept — is: **SSC exceeds v2.16 on containment, is weaker on
comprehension, and is net-stronger because containment is the property that matters for a creation.**
That is defensible. Presenting a table of only the winning axes is not. Fix by adding the losing row
and the reason it is outweighed.

### Where it is unmet (S2 — CRITICAL)

See S2 below. The ceremony exceeds v2.16 **on the spawn path**. The same rung ships a second write path
— D8's migration — that touches live bytes in a space the user already trusts, under one confirmation,
with no staging, no two legs, and no stated gate at all.

---

## CRITICAL

### S1 — `docs/carry-forwards.md` publishes internal security findings into the public release archive

**Surface: logging · OWASP A01 (Broken Access Control, egress boundary) · A09**

`docs/internal/` is `export-ignore`d. `docs/carry-forwards.md` is **not**, and `docs/` ships (27 entries
in `git archive HEAD`, verified). The new register aggregates rows sourced from the export-ignored
report family and reproduces their **finding content and open status**, not merely their paths.

Rows `:167-172` reproduce five findings from `docs/internal/security/security-audit-v2.5.md`, every one
marked **ORPHANED** — i.e. the file advertises a curated list of known-open, unowned security weaknesses:

- `CF-v2.5-B` — `scripts/install-pre-commit.sh` has no Cowork-checkout identity guard. *"Judged an
  acceptable opt-in trust model; never revisited."*
- `CF-v2.5-E` — markdownlint MD035 sentinel so a body-level `---` cannot confuse the frontmatter-counting
  walk. Unowned. (A live parser-confusion vector, stated.)
- `CF-v2.5-D` — GitHub 2FA on the contributor account behind upstream PR #521. *"no owner."*
- `CF-v2.5-F` — **ORPHANED — OVERDUE**, escalation date passed, *"never been performed."*
- `CF-v2.5-G` — MF-3 `ALLOWED`-list governance, *"Directly load-bearing on v3.0."*

**Measured, not asserted — this is new egress, not existing practice:**

```
git grep -l 'Cowork-checkout identity guard' ff0c44c
  → docs/internal/security/security-audit-v2.5.md          (ONE file; export-ignored)

git grep -l 'Cowork-checkout identity guard' ff0c44c -- <all shipping docs>
  → exit 1 (ZERO shipping files)

git grep -ln 'PR #521' ff0c44c
  → CHANGELOG.md, docs/internal/qa/…, docs/internal/security/…, docs/retro.md
    (ALL FOUR export-ignored — currently 100% withheld from the archive)
```

**I checked the obvious refutation and it does not hold.** `docs/architecture.md` already ships with 96
`docs/internal/` citations, so citing internal *paths* is pre-existing practice. That is not what this
is. Those are path references; these are **finding descriptions plus unremediated status**. The content
above appears in **zero** shipping files at base and would ship for the first time.

**Both existing controls are blind to it.** `.gitattributes` does not name the file, and `LEAK_PATTERN`
cannot match `docs/carry-forwards.md` (it is not report-shaped, and correctly so). The v2.19.12 cycle
moved the *reports*; this cycle re-publishes their *contents* in aggregated form. The aggregation is
arguably worse than the original exposure, because it distils 14 scattered reports into one ranked list
of what is still broken and unowned.

**Nothing has leaked.** `HEAD` is `ff0c44c`, no branch, no commit — cost of fixing now is zero.

**Required before commit (choose one, (a) preferred):**
- **(a)** Relocate to `docs/internal/carry-forwards.md`. Inherits the directory-prefix `export-ignore`
  that is the layer demonstrably working, rather than adding an individually-named rule — and S4 is the
  evidence that individually-named rules rot.
- **(b)** Add `docs/carry-forwards.md export-ignore` to `.gitattributes`. Weaker, for the S4 reason.
- **(c)** Redact the security/QA rows. **Rejected** — destroys the register's purpose, which ADR-093 is
  right about.

Note (a) and (b) touch only `docs/` or `.gitattributes`; neither re-triggers Tier A/B.

### S2 — D8's migration is an unstaged live-write path, and `AC-SF2` answers `SF-2` on the wrong path

**Surface: permissions · OWASP A01 · A04 (Insecure Design)**

The cycle's binding obligation is that the spawn gate must **exceed, never relax**, the v2.16 apply
gate. ADR-095 D1-D3 discharge that for spawn. **D8 introduces a second write path in the same rung and
leaves it ungoverned.** D8's migration does three things to an **existing, live, user-trusted space**
under **one** itemized confirmation:

1. stamps `kit_version` to the v3.0 value;
2. writes a space card;
3. **installs the spawn capability.**

There is no staging area, no provenance leg, no composition leg, and no atomic rename — D8 states none,
and §Maturation Path option (d) ("extend SSC to cover the v2.19 upgrade path itself") confirms by
implication that today it does not. So **item (3) installs the very machinery this ADR exists to gate,
into a live space, without the gate.** The ADR never says which gate governs D8. Presumably Loop 1's
v2.16 apply — the gate v3.0 was required to exceed.

**This also inverts `AC-SF2`, which is the sharper half of the finding.** `SF-2` asks whether a Class-2
self-integrity check runs before an ordinary Class-1 engine-file write against the same target. It was
accepted as INFO at v2.19.0 *because `self-upgrade` had no live target* (`docs/risk-register.md:8`,
read directly). D6 answers it structurally — Class-2 checks run against the staging area, and a rename
cannot interleave. **But D8's migration has no staging area, and D8's migration is precisely what gives
`self-upgrade` its first live target.** The ADR says so itself: *"the project's first real forward-walk
target."*

So `AC-SF2` binds the check to the path where the risk is structurally absent (spawn, staged) and is
silent on the path that makes the risk live (migration, unstaged). **That is an AC worded against the
mechanism that was convenient to prove rather than the obligation** — the failure mode the cycle prompt
asked me to look for, and the only place I found it squarely.

**Required before Phase 7 (documentation, in-scope, no code):**
1. State explicitly which gate governs D8's three writes, and whether that gate meets or fails the
   "exceed, never relax" obligation. If it is the v2.16 apply gate, say so and record the asymmetry as
   a knowingly accepted risk with grounds — do not leave it unstated.
2. Re-word `AC-SF2` to bind the **migration** path as well as the spawn path, since that is where
   `SF-2` becomes live. Its current text is satisfiable in full while `SF-2` remains unaddressed on the
   only path that can exercise it.
3. Either pull §Maturation Path option (d) forward into v3.0's scope, or record why one rung shipping
   two self-modifying write paths with different gate strengths is acceptable.

---

## WARNING

### S3 — The composition leg's only security-shaped check is absent from the Decision

**Surface: schema · OWASP A04 · A08 (Data Integrity Failures) · LLM01 (Prompt Injection)**

**This is the composition leg's weakest point, and I was asked to scrutinize it hardest.**

ADR-095 §Context defines what composition must answer:

> *colliding `CLAUDE.md` instructions, dangling references, **a skill mis-scoped once given more trust
> in a new space than it had in the parent***

D1.3 then enumerates what it actually checks:

> *manifest completeness, no dangling cross-references between generated files, valid frontmatter on
> every generated file, and instruction-collision detection between the seeded `CLAUDE.md` and the
> skills it activates*

**The privilege-differential check — trust gained crossing the parent→child boundary — appears in
Context and vanishes from the Decision.** It is the *only* item in either list that is a security
property rather than a structural one. Of D1.3's four checks, three (manifest completeness, dangling
references, frontmatter validity) are lint. They belong in QA, not in the answer to *"does the assembled
whole do something nobody intended."*

**The fourth check is a name, not a mechanism.** "Instruction-collision detection" has no definition, no
decision procedure, and no failure criterion anywhere in the ADR, the HLD amendment, or the roadmap. Is
a collision two instructions that contradict? Semantically contradict? That is an unbounded natural-language
problem being introduced as a security control on the highest-blast-radius surface in the kit — and
**undefined is not fail-closed**, a phrase this repo's own risk register uses (`v2.19.11-PULL-ROW-1`)
about exactly this failure shape.

So the answer to the prompt's question — *is it specified precisely enough to be implementable and
testable, or is it a name for a gap?* — is: **three-quarters lint, one-quarter a name for a gap, with
the load-bearing security check dropped in transit.** The leg is not yet a security mechanism.

**Remedy (documentation, in-scope):** restore the privilege-differential check to D1's enumeration as a
fifth check, and give instruction-collision a decision procedure and a failure criterion, or rename it
to what it can actually do (e.g. duplicate-directive detection over a defined key set) so the ADR does
not claim more than it specifies.

### S4 — `LEAK_PATTERN` misses bare report filenames, and its canary self-test cannot detect that

**Surface: configuration · OWASP A05 (Security Misconfiguration) · A09**

**Verified independently by execution, not by reading.** `.github/workflows/quality.yml:2372`:

```
LEAK_PATTERN: '^docs/(qa-report|security-audit|security-review)-'
```

Executed against candidate paths:

```
docs/security-review.md            → NO MATCH
docs/security-audit.md             → NO MATCH
docs/qa-report.md                  → NO MATCH
docs/security-review-v2.19.11.md   → match
docs/qa-report-v2.16.0.md          → match
```

The trailing hyphen requires a version suffix. **The orchestrator's observation is CONFIRMED.**

**The compounding fact, which the brief did not contain and which I consider the more serious half:**
`CANARY_PATHS` at `:2373` is `docs/qa-report-v9.9.9.md docs/security-audit-v9.9.9.md
docs/security-review-v9.9.9.md` — **all three canaries are versioned.** The self-test validates only
the shape the pattern already matches, so the gate reports healthy while blind to the bare form. This is
a textbook instance of this repo's own binding *check-that-cannot-fail* discipline: the negative control
cannot discriminate the defect it would need to catch.

**Bare-named files exist and are tracked** — `docs/internal/security/security-review.md`,
`docs/internal/security/security-audit.md`, `docs/internal/qa/qa-report.md`. **They are saved by the
`docs/internal/` directory `export-ignore` alone.** `git archive HEAD | tar -tf - | grep -E
'^docs/(qa-report|security-audit|security-review)'` returns nothing, so nothing has leaked — but the
protection is **single-layer**, and the CI gate built at v2.19.12 to be the second layer is inert for
exactly these three filenames.

`docs/security-review.md` — bare, top-level — **is the only path my own `scope_allow` permits me to
write.** The pipeline's own agent configuration forces the one filename the gate misses. That is why
this file must be relocated before commit, and why the relocation cannot be left to a manual step whose
CI backstop has a hole at that precise name.

**Disposition: I AGREE with the proposed carry-forward, and my agreement is load-bearing on the
Classification Re-Run above.** The fix (`(qa-report|security-audit|security-review)(-|\.)` plus a
fourth, *bare-named* canary) edits `.github/workflows/quality.yml` — **Tier B**. Folding it into a
PURE-DOC cycle would re-classify the cycle and pull a workflow edit through a gate that never reviewed
it. **Carry it forward; do not fix it here.** Two things must ride with the carry-forward or it will
recur:
1. the missing canary, not only the pattern — a pattern fix without a bare-named canary reproduces the
   check-that-cannot-fail;
2. the observation that a *directory*-prefix `export-ignore` is the layer that actually works, which
   is why S1's remedy (a) is preferred over (b).

**Interim control, this cycle:** `docs/security-review.md` MUST be relocated under `docs/internal/security/`
before any commit. Until then it is uncommitted and therefore harmless.

### S5 — Staging and quarantine paths are named but never specified

**Surface: file-upload · OWASP A01 · A04**

`staging path` occurs at `docs/architecture.md:15660` and `docs/hld.md:280`; `staging area` at `:15714`;
`quarantine path` at `:15703`. **None is ever given a location, a permission model, or a naming rule.**
The prompt's question — *does the staged directory itself become an attack surface: writable,
predictable, or reachable by the very apply loop it is meant to sit outside?* — **cannot be answered
from the design as written.** That is the finding.

Three consequences the ADR must resolve before build:

1. **Reachability by the apply loop.** If staging sits inside the parent space, any skill with write
   scope over that space — including Loop 1's apply — can modify the tree *between* the composition
   leg and the rename. The ceremony's entire value is that the gate sits outside the live tree; a
   staging path *inside* it re-admits what staging excludes.
2. **Predictability.** A predictable staging path is a plant target: write content there before the
   ceremony and it inherits the confirmation.
3. **Quarantine interacts badly with D7 (see S6).** D5 retains a failed tree **with its
   `cowork.space-card.json` intact**. If the hub enumerates cards, **a REJECTED tree stays discoverable.**
   Neither leg catches this, because it is a cross-decision interaction that no single leg is scoped to
   see — exactly the class of defect the composition leg exists for, arising between two decisions of
   the ADR that introduces it. Quarantine must strip or invalidate the card, and the ADR must say so.

### S6 — D7 removes co-location as discovery but specifies no enumeration mechanism

**Surface: permissions · OWASP A01 · A04**

D7's correction is right about the destructive-relocation problem and I endorse it. But it replaces a
working mechanism with an unspecified one:

> *Cards are the registry. Co-location is an additional property of newly-spawned siblings, not the
> discovery mechanism.* … *the hub reads the card set and follows the paths.*

**Where does the card set live?** D7 says each space has `cowork.space-card.json` — i.e. cards live
*inside* spaces. Then the hub must already know where every space is in order to read its card.
**That is circular.** For newly-spawned spaces co-location silently rescues it. For **migrated** spaces
— the exact case D7 exists to serve — there is no enumeration mechanism at all, so *"a migrated space
becomes hub-visible by gaining a card, with nothing moved"* does not follow: a card at an arbitrary
absolute path makes the space visible to nobody.

**The security dimension.** Whatever eventually enumerates cards becomes a trust-critical surface.
Because the card carries an **absolute `space_path`** and the hub is instructed to **follow the paths**,
a hostile or corrupted card is an arbitrary-path-read primitive at the hub boundary. Nothing in
`AC-FWDCOMPAT` constrains `space_path` — not to a root, not to an existence check, not to a canonicalized
form. `AC-FWDCOMPAT` is satisfiable in full by a schema-valid card pointing anywhere on the filesystem.

**Remedy:** specify the enumeration mechanism, and constrain `space_path` (canonicalize; require it to
resolve; require it to contain a matching space; decide whether it must sit under a permitted root).
This is v3.x hub work in part, but the *card schema* ships in v3.0, and a schema that cannot express the
constraint later is the harder problem to unwind.

### S7 — ADR-095's `SECGATE-B1` file count is falsified by this cycle's own Phase 1 write

**Surface: none (measurement integrity) · pattern: `Ambiguous-unit numeric claim` (BINDING in this repo)**

ADR-095 D9 states the id appears in *"exactly **3 files** repo-wide (`docs/architecture.md`,
`docs/internal/qa/qa-report-v2.16.0.md`, `docs/spec.md`)"*, prefaced *"Verified this cycle."*

**Re-run by @security. It is 4.**

```
/usr/bin/grep -rl 'SECGATE-B1' . --exclude-dir=.git
  → docs/architecture.md, docs/internal/qa/qa-report-v2.16.0.md, docs/roadmap.md, docs/spec.md

git grep -l 'SECGATE-B1' ff0c44c
  → docs/architecture.md, docs/internal/qa/qa-report-v2.16.0.md, docs/spec.md   (3 — correct AT BASE)
```

The fourth is `docs/roadmap.md:44` — **written by this cycle's own Phase 1, in the same commit as the
ADR that counts it.** The claim was true at `ff0c44c` and false by the time it was saved. The defect is
the missing population statement ("at base `ff0c44c`"), which is this repository's own BINDING
`Ambiguous-unit numeric claim` pattern firing again, this time inside a cycle whose ADR-093 is *about*
ledger measurement discipline.

**The substantive claim survives, and I verified it independently — this is a citation defect, not a
reasoning defect.** Everything load-bearing in D9 reproduces:

- `SECGATE-B1` under `tests/`: **0** (`/usr/bin/grep -rn 'SECGATE-B1' tests/ | wc -l` → `0`). ✅
- `tests/self-upgrade-firing-controls.md:86` is
  `grep -n "self-apply/SKILL.md\|SECGATE\|verifier\|rollback" skills/self-upgrade/SKILL.md | wc -l`
  — a structural string-count, and the file labels it **`AC-UPGRADE-4(b)`** in its own header at `:82`.
  It is leg (b). ✅
- The scope note at `:328-329` reads *"MF-2(b) and AC-UPGRADE-3(c)'s live-routing halves are explicitly
  named as **not yet exercised by an actual agent session**."* ✅

**@architect is right on the substance and I found the claim stronger than stated.** Reading MF-2
control (b) directly (`:97-108`): it is *"Honestly un-exercisable pre-implementation"*, bound as *"a
Phase-5 @qa re-verify item, not assumed proven"* — and it carries **no `RAN` entry**, unlike every
neighbouring control. So leg (a) is not merely undemonstrated through a second entry point; the
obligation was **recorded, deferred to Phase 5, and never discharged**. **You cannot re-fire what never
fired once.**

**Consequence for `AC-UPGRADE-4-LEGA`, which is otherwise the best-worded of the four ACs** (it
explicitly binds *"the obligation — the controls re-fire through `self-upgrade` — not the one string
that revealed the gap"*, which is exactly right): it carries an unstated predicate. Before v3.0 can
demonstrate the controls re-firing through the second entry point, they must exist in re-runnable form
through the **first**. The AC should bind both, or v3.0 will discover mid-build that its predicate is
absent.

### S8 — "Atomic rename" assumes facts the design never states

**Surface: schema · OWASP A04**

D1.5 and D3 rest entirely on *"one atomic rename"* and *"structurally unreachable"*. Three unstated
assumptions:

1. **Same filesystem.** `rename(2)` is atomic only within one filesystem. If staging is placed on a
   different volume (a `/tmp`-style staging path is the natural implementation, and S5 shows the
   location is unspecified), `mv` degrades to copy-then-unlink — **not atomic**, and the partially-live
   window D3 calls structurally unreachable is fully reachable. The design must *require* staging on the
   same filesystem as the live parent, and the build must assert it.
2. **Target must not exist.** Directory rename onto an existing non-empty directory fails `ENOTEMPTY`.
   The resulting behaviour — spawn fails rather than clobbers — is the *right* one, but it is accidental
   rather than stated. A slug collision with an existing space is a reachable, user-triggerable case and
   should be an explicit pre-check with a stated message, not an errno surfaced from a syscall.
3. **The verify→rename window.** Nothing states the staged tree is immutable between the composition
   leg passing and the rename occurring. With S5's unspecified location this is a genuine TOCTOU: verify
   the tree, modify the tree, rename the modified tree. The ceremony's guarantee is only as strong as
   that window is closed.

**On partial or interrupted staging** — the prompt asked directly. The design is *correct* here and
should say so explicitly: an interrupted stage leaves an incomplete tree in staging, the rename never
runs, nothing is live, and D5's quarantine retains the fragment. That is a true no-op and it is the
ceremony's best property. It is currently implied rather than stated, and it deserves to be stated
because it is the strongest claim the design can make.

### S9 — The migration note publishes internal finding labels into the shipping archive

**Surface: logging · OWASP A01** — lesser form of S1, separate remedy.

`docs/architecture.md:6085-6089` (ships) carries a mapping table whose third column, *"Unchanged id of
the other series"*, reproduces the security/QA series' descriptions: *"MF-S1 diagnostic-message
imprecision"*, *"`install-pre-commit.sh` identity guard"*, *"GitHub 2FA hardening"*, *"markdownlint
MD035 sentinel"*.

Measured: `git grep -l 'identity guard' ff0c44c -- <shipping docs>` → **exit 1, zero shipping files**.
Working tree `docs/architecture.md` → **1**. New egress.

**Materially milder than S1** — these are four-word topic labels, not findings with status and
remediation history — so this is a WARNING, not a CRITICAL. But it is the same boundary crossed by the
same cycle, and ADR-094 D4's *"keeps the old ids findable"* goal is fully served by the old→new columns
alone. **Remedy: drop the third column, or replace each description with an origin-document pointer**
(which is what ADR-094 D3's own forward-only rule asks for anyway).

### S10 — `risk-register.md` carries 5 stale pre-move citations, and ADR-093's authority rule propagates them

**Surface: none (citation integrity)**

```
/usr/bin/grep -oE 'docs/(security-audit|security-review|qa-report)-v[0-9.]+\.md' docs/risk-register.md
  → 4 × docs/security-audit-v2.19.0.md
    1 × docs/security-review-v2.19.5.md
```

Both files live at `docs/internal/security/` since v2.19.12. All five citations are dead.

**The interesting part is the interaction, not the staleness.** `docs/carry-forwards.md:95` cites the
same `SF-2` source with the **corrected** path (`docs/internal/security/security-audit-v2.19.0.md:34,53`).
ADR-093's authority rule states: *"Where this register and its source surface disagree, the source wins
and this file is regenerated."* Applied literally, **the next regeneration overwrites the register's
correct path with the source's dead one.** The authority rule propagates the error in the direction of
the error.

This is not an argument against ADR-093 — the rule is right, and a derived view must not become a second
authority. It is an argument that **"the source wins" needs an exception for provably-dead citations**,
or the register will silently re-rot on every regeneration. Cheapest fix: repair the 5 citations in
`risk-register.md` (in-scope, `docs/`-only, and the file is already being edited this cycle), which
makes the authority rule and the correct paths agree.

---

## INFO

### S11 — D3's comparison table omits the axis SSC loses
Covered above under the primary question. Add the comprehension row and the reason it is outweighed.
A table where the proposal wins every listed axis invites the reader to ask which axes were not listed.

### S12 — `AC-SPAWN-SEC` enumerates no controls
It reads *"the ceremony above, with firing negative controls that demonstrate each claim."* D1-D3 make
roughly a dozen claims; "each claim" is unbounded, so the builder decides what counts — in a repo whose
convention (`tests/*-firing-controls.md`) is explicit GREEN + negative-control pairs. **The two
highest-value controls are unnamed and should be named in the AC text:** (1) a tree failing *either* leg
does not go live and leaves nothing behind in the live path — the control that proves containment,
which is the entire claim; (2) an interrupted stage leaves no live bytes (S8). Without (1) enumerated,
`AC-SPAWN-SEC` is satisfiable by controls that demonstrate the ceremony's *happy path*.

### S13 — The §Maturation Path revisit trigger is incoherent and fires on its own fix
The trigger reads *"the composition-leg verifier grows a **third** responsibility beyond the **four**
checks named in D1."* Third against four is not parseable, and "responsibilities" are not the unit D1
enumerates. Worse: restoring the privilege-differential check (S3's required remedy) *adds* a check, so
the trigger fires on the fix for the gap — mandating option (a)'s full generalization as the price of
correcting a drafting omission. Restate as a countable predicate over D1's enumerated checks, and
exclude the S3 restoration explicitly.

---

## Can anything reach the live tree without passing both legs?

**Yes — one path, and it ships in the same rung.** D8's migration (S2): three writes to a live,
user-trusted space, one confirmation, no staging, no provenance leg, no composition leg, no rename.
One of the three installs the spawn capability itself.

On the **spawn** path specifically, I could not find a bypass, and I looked for four:

| Attempted bypass | Result |
|---|---|
| Write directly to the live sibling path | Blocked by D1.1 as written — no byte before the gate |
| Modify the staged tree after verification, before rename | **OPEN** — S8(3), TOCTOU window unaddressed; aggravated by S5 |
| Reach the staged tree via the parent's apply loop | **UNASSESSABLE** — S5, staging location unspecified |
| Re-enter through a quarantined failed tree | **OPEN** — S5(3), quarantine retains a valid space card; if the hub enumerates cards, a rejected tree stays discoverable |

Two of four are open and one is unassessable — all three because the *staging path is never specified*.
That single omission is what converts an otherwise sound ceremony into one that cannot yet be verified.

---

## OWASP Top 10 Assessment

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | **FINDINGS** | S1 (egress boundary crossed by aggregation), S2 (ungated live-write path), S5, S6, S9 |
| A02 Cryptographic Failures | PASS | Provenance leg reuses proven `sha256` machinery. See A08 for the circularity caveat |
| A03 Injection | PASS (design-level) | No code surface. LLM01 below covers the instruction-injection analogue |
| A04 Insecure Design | **FINDINGS** | S2, S3 (undefined control), S5, S6, S8 (unstated atomicity preconditions) |
| A05 Security Misconfiguration | **FINDINGS** | S4 — `LEAK_PATTERN` gap plus a canary set that cannot detect it |
| A06 Vulnerable Components | PASS | No dependency surface; PURE-DOC cycle, zero writes outside `docs/` |
| A07 Auth / Identity Failures | PASS | No auth surface. `CF-v2.5-B` (contributor identity guard) noted as pre-existing and ORPHANED — see S1 |
| A08 Software / Data Integrity | **FINDINGS** | S3; and the provenance-leg circularity below |
| A09 Logging & Monitoring | **FINDINGS** | S1, S9 — internal finding content crossing into the shipped archive |
| A10 SSRF | N/A | No network surface in this design |

**A08 — the provenance leg's unstated non-circularity assumption.** D1.2 verifies each pooled file
against *"its `cowork.lock.json` **and** curated-registry `sha256`."* In a **spawn**, the lock file is
**generated by the same act that generates the tree** — so verifying generated files against a
generated lock is circular: a compromised or buggy generator writes both the file and its hash, and the
leg passes. The `and` saves it **only if** the curated registry is an independent authority whose own
integrity is established outside the staged tree. **The ADR never states that**, and the whole
"reuse, not new mechanism" framing — which is what licenses the claim that v3.0 introduces only *one*
new security mechanism — depends on it.

Two related gaps in the same leg:

- **Provenance covers only pooled files.** Generated files (the manifest, the space card, and above all
  the **seeded `CLAUDE.md`**) have no pool provenance by definition. **The file with the greatest
  instruction authority in the entire tree is the one the provenance leg cannot touch**, and the
  composition leg only checks it for "collisions" (S3 — itself undefined). Nothing verifies the seeded
  `CLAUDE.md`'s content against anything.
- If it is template-derived via ADR-034 clone-once, instantiation performs substitution, which breaks
  byte-equality — so the existing machinery cannot verify it even in principle. The ADR flags the
  ADR-034 interaction as a build-time check, which is right, but frames it as an *idempotence* question.
  **It is also a provenance question**, and that half is unrecorded.

### LLM Threat Assessment (AI-instruction surface — this kit IS an instruction tree)

| Threat | Status | Notes |
|---|---|---|
| **LLM01 Prompt Injection** | **RISK-PRESENT** | The spawned tree *is* agent instructions. "Instruction-collision detection" (S3) is the only named control and is undefined. Content reaching a seeded `CLAUDE.md` becomes operative instruction in a new space with no diff for the user to read (S11) |
| **LLM02 Insecure Output Handling** | **RISK-PRESENT** | The generated tree is model-authored output written to disk and then trusted as instruction. This is the repo's own known failure shape — `v2.19.9-SKILLSTUDIO-TARGET` records a *"proven marker-breakout history (QA-1/v2.12.0)"* for model-authored instruction text. **v3.0 generalizes exactly that surface from one block to a whole tree, and no finding in ADR-095 cites that precedent.** It should |
| **LLM06 Excessive Agency** | **RISK-PRESENT** | Spawn is the kit's maximal self-modification. Containment is well-designed (D1/D5) — the residual is S2's ungated second path and S6's unconstrained `space_path` |
| Session-pin read surface | **PRESERVED** | No session-pin or env-var propagation change in this cycle; zero writes outside `docs/`. No new read surface |

**LLM02 deserves emphasis as the strongest thing I can add to this design.** The project already
*knows* model-authored instruction text breaks out of its markers — it has a QA finding and a live risk
row about it. v3.0 scales that surface by orders of magnitude, and the ADR's threat model does not
mention it. The composition leg is the natural home for the mitigation, which makes S3's under-specification
more consequential than it first appears.

---

## Summary

**APPROVE WITH CONDITIONS.** The design is strong and the central judgment is correct. ADR-095 D2's
rejection of a per-file confirmation loop is **sound, not a rationalization** — I attacked it and it
got stronger: for a *creation*, a per-file loop is not merely a check with an unmet precondition, it
manufactures the incremental-liveness window that staging exists to eliminate. SSC's lower click-count
is a consequence of a stronger containment posture, not a trade against it. The ADR is also unusually
honest — §Maturation Path's *"specified but unproven"* paragraph is the kind of statement most designs
omit, and it is correct.

**Three things stand between this design and its own claim.**

1. **The obligation is unmet on a path the same rung ships (S2).** SSC exceeds v2.16 for spawn. D8's
   migration writes live bytes to a trusted space with no staging and no stated gate — and installs the
   spawn capability while doing it. `AC-SF2` then answers `SF-2` on the staged path where the risk is
   structurally absent, and is silent on the migration path that makes `SF-2` live for the first time.
   That is the one AC I found worded against the convenient mechanism rather than the obligation.
2. **The composition leg is not yet a security mechanism (S3).** Three of its four checks are lint; the
   fourth is a name without a decision procedure; and the only genuinely security-shaped check —
   privilege differential across the parent→child boundary — is named in §Context and absent from the
   Decision. Combined with the LLM02 precedent the ADR does not cite, this is the highest-value fix
   available for the build cycle.
3. **The staging path is never specified (S5), and three of my four bypass attempts turn on that.**
   TOCTOU, apply-loop reachability, and quarantine-card discoverability are all open or unassessable
   for the same reason. One paragraph of specification closes all three.

**S1 is the only finding that must be discharged before a single byte is committed**, and it costs
nothing now: `HEAD` is still `ff0c44c` with no branch. `docs/carry-forwards.md` is an excellent document
— ADR-093's population definition is the best measurement discipline I have seen in this repo — and it
must not ship in the public archive carrying five ORPHANED security findings whose content appears in
zero shipping files today. Relocate it under `docs/internal/`; do not rely on an individually-named
`export-ignore`, because S4 is the standing proof that individually-named rules rot while directory
prefixes hold.

**On the egress-pattern finding (S4): confirmed by execution, and I agree with the carry-forward
disposition** — the fix is a `.github/workflows/` edit, Tier B, and folding it into a PURE-DOC cycle
would re-classify the cycle and pull a workflow change through a gate that never reviewed it. Carry it
forward **with its canary**, not just its pattern; a pattern fix alone reproduces the
check-that-cannot-fail.

**@architect's work holds up under re-measurement.** Every load-bearing figure I re-ran reproduced:
`KDQ-SPAWN-SEC` 8 occurrences / 4 files at base (2+2+1+3, exact); `status-card` and `shared-parent-dir`
zero outside `docs/`; `SECGATE-B1` zero under `tests/`; `:86` is a structural count labelled
`AC-UPGRADE-4(b)`; the scope note reads as quoted; the security/QA series byte-unchanged
(`git diff --name-only -- docs/retro.md docs/internal docs/research` → empty); the risk-register edit is
exactly 2 status cells with description and condition cells byte-identical. **One correction (S7):**
the "`SECGATE-B1` in exactly 3 files" claim was true at base and was falsified by the ADR's own cycle
writing a fourth occurrence into `docs/roadmap.md:44` — the repo's BINDING `Ambiguous-unit numeric
claim` pattern firing inside the cycle whose ADR-093 is about measurement discipline. The substance
survives intact; the population statement is missing. **And one strengthening:** MF-2 control (b) has no
`RAN` entry — leg (a) was recorded, deferred to Phase 5, and never discharged, so `AC-UPGRADE-4-LEGA`
carries an unstated predicate. You cannot re-fire what never fired once.

**Classification: SECURITY-SENSITIVE (retained) · Tier NEITHER A NOR B · no Guard Change Summary owed**
— because Tier attaches to the write surface and classification to the subject, and this cycle is the
clean case that separates them.

---

*@security — Phase 2, `plan-2026-08-27-v3-engine`. Read-only agent; findings reported, nothing fixed.
This file MUST be relocated to `docs/internal/security/` before any commit — see S4.*

---

# Security Review — plan-2026-08-27-v3-engine

## Phase: 6
## Date: 2026-08-28T15:12:48Z
## Status: PASS WITH WARNINGS

Abbreviated PURE-DOC audit per `.claude/commands/plan.md` — no code surface, no guard scan, no
`npm audit` (no dependency surface). Base `ff0c44c`, verified unchanged at audit start and end
(`git rev-parse HEAD` → `ff0c44c81be2315979af17f931de3dae3b3cf51a`), branch `main`, no commit.

**Everything below was measured against the working-tree bytes. No figure is inherited from
`docs/qa-report.md`, from pipeline row `2.R1`, or from the Phase 6 launch brief. Where a re-run
disagreed with an inherited figure, the disagreement is reported rather than reconciled silently.**

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S14 | WARNING | 6 | permissions | C1's strict-superset failure criterion is **one-directional**: it catches privilege *gain* in the child but structurally cannot catch *protection loss*, and axis (ii) deny-list membership is a protection, not a privilege |
| S15 | WARNING | 6 | none | `CF-plan-v3-engine-C1-AXIS3`'s remedy option (b) — "narrow C1 to axes (i) and (ii)" — is unsafe as written, because S14 lives in axis (ii); the carry-forward hands the build cycle a contaminated remedy menu |
| S16 | INFO | 6 | none | @qa's prescribed correction of the HLD line count ("266/336") is itself wrong — measured **360**. Superseded by @architect's better fix; recorded as the cycle's 4th instance of the same defect, again inside a correction |
| S17 | INFO | 6 | none | `SECGATE-B1` working-tree count is now **7**, not the 5 recorded at `2.R1`; 2 of the 7 are this cycle's untracked ephemera. ADR-095 D9's revision-scoped claim (3 at `ff0c44c`) is correct and reproduced exactly |
| S18 | INFO | 6 | permissions | D1a's "outside every space's write scope" rests on Loop 1's allow-list being relative-path-anchored (`AC-APPLY-3`). True today; D1a does not assert it as a precondition |

**Counts: 0 CRITICAL · 2 WARNING · 3 INFO.**

**No CRITICAL finding is open.** Both Phase 2 CRITICALs are dispositioned below — S2 discharged,
S1 mitigated (partial) with a named residual I am willing to carry at WARNING.

---

## Ruling on the S1 framing — @qa's condition for Phase 7

**I CONFIRM the re-label. "S2 discharged; S1 MITIGATED (PARTIAL)" is the accurate statement, and
the original "both CRITICALs discharged" did overstate S1. @qa is right, and right for the right
reason.**

I raised S1, so this is mine to rule on. Re-measured, not inherited:

| Check | Command | Result |
|---|---|---|
| Old path gone | `ls docs/carry-forwards.md` | No such file |
| Directory rule present | `/usr/bin/grep -n internal .gitattributes` | `docs/internal/  export-ignore` at `:28` |
| Tracked under `docs/internal/` at HEAD | `git ls-tree -r --name-only HEAD -- docs/internal` | **84** |
| Of those, in the release archive | `git archive HEAD` piped to `tar -tf -`, counting `^docs/internal/` | **0** |
| The five finding strings, in the register | five separate `/usr/bin/grep -c` runs | **0, 0, 0, 0, 0** |
| `identity guard` in shipping `architecture.md` | working tree vs `ff0c44c` | **0** now, **1** before, **0** at base |

The negative control is sound: a "0 in archive" result would be vacuous against an empty directory,
and the directory holds 84 tracked files. **The release-archive half of the harm is genuinely closed.**

**Why "discharged" would have been wrong, in my own words.** `export-ignore` is an attribute consulted
by `git archive`. It has no effect on `git clone`, on `git log`, or on GitHub's web file browser. The
repository is public. Therefore every byte of `docs/internal/carry-forwards.md` remains readable by
anyone who clones or browses, and the origin-document pointers it now carries resolve — in that same
clone — to the very reports they point at. The aggregation harm I identified was never primarily about
the release ZIP; it was that **one file distils 14 scattered reports into a single ranked list of what
is broken and unowned**. Relocation does not dissolve that. It restores *parity* with the 14 reports,
which is a real and correct thing to do, and it is not secrecy.

**What the content reduction actually bought, stated without inflation.** §G's rows now read
`Lint-sentinel hardening for a frontmatter-boundary parser` where they once read a working description
of the defect and how to reach it. The ORPHANED / OVERDUE status and the disposition survive in full —
correctly, since removing those would destroy the register's purpose, which ADR-093 is right about.
So the mitigation raises the cost of assembling an actionable target list from *read one file* to *read
one file, then read the 84 it points into*. Against opportunistic scanning that is worth something.
Against anyone who has already cloned, it is a speed bump. **@architect's own framing — pointers, not
reproduced detail — is the correct remedy and is exactly this cycle's ADR-094 §Decision (3) applied to
itself. I endorse it. I decline to call it secrecy.**

**Is "mitigated (partial)" too generous? No — and I considered that it might be.** The test I applied:
does the remedy leave the residual *worse than, equal to, or better than* the pre-cycle baseline? At
`ff0c44c` the finding content already sat in a public clone across 14 reports. After the remedy it sits
in a public clone across 14 reports **plus** one index whose rows are now topic labels. The aggregation
is a genuine increment in convenience-to-an-attacker; it is not an increment in *disclosure*, because
no fact is newly public. **A marginal convenience increase over an already-public baseline is a WARNING,
not a CRITICAL.** That is why I carry it rather than block on it.

### What would close S1 completely

One of these, and only these — none is available in a PURE-DOC cycle, which is why I do not demand it now:

1. **Make the repository private**, or move `docs/internal/` to a separate private repository. This is
   the only remedy that actually closes it. It is an owner decision with costs far beyond this finding.
2. **Stop tracking `docs/internal/` in git** (working-tree-only, `.gitignore`d, as The-Council does for
   `observations.md`). Closes the clone vector; loses the history that makes the register regenerable.
3. **Reduce §G to bare ids with no status column.** Closes the aggregation harm; destroys the register.
   I rejected this at Phase 2 as remedy (c) and I still reject it.

**Formal disposition: S1 — CRITICAL at Phase 2 → residual WARNING at Phase 6, KNOWINGLY ACCEPTED,
carried.** The accepted risk is: *in a public clone, one file provides a topic-level index of this
project's known-open, unowned security weaknesses.* Owner-visible, owner-decidable, not agent-decidable.
**It should be recorded as an accepted risk with an owner, not left as a closed finding** — and the
`2.R1` label as re-written already says so.

---

## Disposition on `CF-plan-v3-engine-C1-AXIS3` — deferral is right, the wording is not

**Deferral to the v3.0 build cycle's Phase 1: I CONCUR.** But the carry-forward as written contains a
factual error that would mislead the cycle it is addressed to, and that must be corrected before Phase 8.

### On the deferral itself

@qa asks whether a fail-open axis inside a fail-closed check is severe enough to bind here. I judge
**no**, on three grounds:

1. **Nothing is built.** This cycle's product is a design document. No user is exposed by an
   under-specified extraction procedure in a document; a user is exposed by an implementation of one.
2. **The receiving gate is real, not nominal.** The v3.0 build cycle runs its own Phase 1 design and its
   own Phase 2 @security review, and C1 is the single most conspicuous thing in ADR-095 for that review
   to land on. The carry-forward's instruction — *"record it there before Phase 2, do not rediscover it"* —
   is the correct mechanism and it is already written.
3. **Binding it here would force the wrong work.** Defining a parseable write-scope schema for a seeded
   `CLAUDE.md` is a design problem of real size. Doing it inside a cycle that cannot build or test it
   would produce exactly the artifact this repo keeps catching itself producing: a specification written
   to close a finding rather than to be implementable.

### The correction that IS owed here (S15)

The carry-forward states that axes (i) and (ii) *"are both backed by structured artifacts with extraction
already proven in this repo."*

**I tested that claim rather than accepting it, and it is half right.**

- **Axis (i), `tools:` frontmatter — CONFIRMED structured.** Population: all 29 skills under
  `/Users/macbookpro/claude-cowork-config/skills/`, as of the working tree at `ff0c44c`
  (`skills/` is unmodified this cycle — 0 of 8 changed paths lie outside `docs/`). A frontmatter walk
  yields exactly 4 distinct keys repo-wide: `description`, `name`, `tools`, `trigger_examples`.
  Negative control: 29/29 files yielded keys, minimum 4 each — the extractor read every file, so the
  key set is a real enumeration and not a silent parse failure.
- **Axis (ii), deny-list membership — CONFIRMED extractable, but NOT for the reason implied.** There is
  **no** deny-list frontmatter key on any of the 29 skills. The authoritative deny-list is **body prose**
  in `skills/self-apply/SKILL.md:53`. What rescues the axis is that *per-skill* membership reduces to the
  `self-*` reserved-prefix glob (`AC-APPLY-3`, ADR-061, MF-1a/b/c), which is determinable from a
  directory listing — `self-apply`, `self-archive`, `self-upgrade`. **@qa's conclusion holds; the stated
  ground ("structured artifact") does not.** The deny-list's non-glob members are file paths, not skills,
  so they never enter a per-skill computation. I record this because a build cycle that reads
  "structured artifact" will go looking for a schema that does not exist.

**And the part that matters more (S14, below): axis (ii) is where the check's failure criterion breaks.**
So remedy option (b) — *"narrow C1 to axes (i) and (ii)"* — does **not** yield a sound check. It yields a
check that is mechanically computable and still blind in one direction. **Option (b) must not survive
into the build cycle in its current form.**

**Required before Phase 8 (documentation, `docs/internal/`, in scope, no re-classification):** broaden
`CF-plan-v3-engine-C1-AXIS3` to carry both defects — the axis (iii) extraction gap *and* S14's
one-directional failure criterion — and strike or re-word option (b). One carry-forward, two legs.

---

## WARNING

### S14 — C1's failure criterion is one-directional and cannot catch protection loss

**Surface: permissions · OWASP A01 · A04 · LLM02**

**This is the finding I did not have at Phase 2, and it is the one I would most want the build cycle to
have.** It is not an extraction problem — it is in the decision procedure itself, which is why re-reading
C1 for extractability (as @qa correctly did) does not surface it.

C1 as written (`docs/architecture.md` ADR-095 D1.3):

> effective privilege = (i) declared `tools:` set ∪ (ii) deny-list membership ∪ (iii) `CLAUDE.md`-granted
> write scope … **if the child's effective privilege is a strict superset of the parent's for any skill,
> the leg FAILS.** Equal or narrower passes.

**A strict-superset test detects only monotone increase.** Every element of the union is treated as a
capability, so *more elements = more privilege = FAIL*. But **axis (ii) is a protection, not a
capability.** Being deny-listed means a skill's file *cannot be written* — it is machinery the apply
channel is forbidden to touch (ADR-061: *"the machinery could rewrite its own governing rules out from
under itself"*, closing REWORK-2).

So the two directions are not symmetric:

| Scenario | Child's computed union | Strict-superset test | Actual safety |
|---|---|---|---|
| Child skill gains a `tools:` entry | larger | **FAILS** ✅ | correctly caught |
| Child skill **loses** deny-list membership | **smaller** | **PASSES** ❌ | **child is strictly less safe** |

**Concretely reachable.** The spawn generates a child tree. If the child's safety skill is emitted under
a name outside the `self-*` reserved prefix, or the child's `self-apply` prose omits the `self-*` deny
rule, then in the child that machinery **is** apply-writable. C1 computes a *smaller* union for it than
the parent's, "equal or narrower passes", and the leg reports success. **The exact regression the
deny-list exists to prevent is invisible to the check named as the leg's one security control.**

**Why this is the same failure shape the ADR already fixed once, one level down.** D1.3's own precondition
— *"a skill absent from the parent is evaluated against the pool's declared default, never against 'no
constraint' — absent must not read as unconstrained"* — is precisely a guard against a missing input
reading as a pass. That precondition covers the case where a **skill** is absent from the parent. It does
**not** cover the case where a **protection** is absent from the child. Same fail-open direction, one
level down, unguarded.

**Remedy (design, owned by the v3.0 build cycle's Phase 1 — not fixable in a PURE-DOC cycle):** separate
the two kinds of term. Capabilities (`tools:`, granted write scope) are tested for *increase*; protections
(deny-list membership, reserved-prefix coverage) are tested for *decrease*. The leg FAILS on either. A
single union under a single superset test cannot express both, and no amount of extraction precision on
axis (iii) will fix it.

**LLM02 relevance.** In a spawn the child's safety-machinery prose is emitted content. This repo's own
`v2.19.9-SKILLSTUDIO-TARGET` row cites a *proven marker-breakout history* (QA-1, v2.12.0) for
model-authored instruction text. C5 gained a marker-integrity leg for exactly that reason and it was the
right addition; **C1 did not, and C1 is the leg that would have to notice a protection quietly absent
from generated machinery.**

### S15 — The carry-forward's remedy menu is contaminated by S14

**Surface: none (design-record integrity)**

Covered in the disposition above. Recorded as its own finding because it is a *document* correction owed
in this cycle, whereas S14 is a *design* problem owned by the next one. Conflating them would let the
cheap half ride to the build cycle unfixed on the grounds that the expensive half is deferred.

---

## INFO

### S16 — The prescribed HLD correction was itself wrong; the refusal was correct

`docs/qa-report.md` asks that the HLD amendment's "267 lines untouched, now 334" be corrected to
"266/336". Measured: `git show ff0c44c:docs/hld.md` counted with `/usr/bin/grep -c ''` → **266**; working
tree `/usr/bin/grep -c '' docs/hld.md` → **360**; `git diff --numstat` → `94 0 docs/hld.md`, and
266 + 94 = 360. **266 is right. 336 is wrong. The true figure is 360.**

@architect declined to apply the correction as specified and instead removed the total altogether,
recording the invariant (append-only, single hunk, zero deletions) in place of the measurement, with the
reasoning stated at `docs/hld.md:288-296`. **That was the correct call and I endorse it explicitly** —
had the prescribed "336" been applied, this cycle would have shipped a *fourth* wrong number inside the
*third* correction of the same defect. This is a clean instance of a prescribed remedy being a defect
vector, and the record already names the general lesson: *when a figure is invalidated by the act of
recording it, the remedy is not a better as-of stamp, it is recording the invariant instead.*

### S17 — `SECGATE-B1` count, re-run with an explicit population

- **At base:** `git grep -l 'SECGATE-B1' ff0c44c` → **3** files (`docs/architecture.md`,
  `docs/internal/qa/qa-report-v2.16.0.md`, `docs/spec.md`). **ADR-095 D9's claim reproduces exactly.**
- **Working tree, as of 2026-08-28T15:12:48Z:** `/usr/bin/grep -rl 'SECGATE-B1' --exclude-dir=.git` → **7**
  files. The row `2.R1` figure of 5 was correct when taken and is now stale — `docs/qa-report.md` and
  `docs/hld.md` have since acquired the string.
- **At commit time the tracked count will be 5**, since `docs/security-review.md` and `docs/qa-report.md`
  are untracked ephemera that do not enter the feature commit.

**No action.** D9 is now revision-scoped and explicitly warns the reader to expect a different number and
not to treat the difference as a correction. That is the fix working exactly as designed — the fifth
generation of this count is *not* a defect, because the claim it must match is pinned to a revision.

### S18 — D1a's containment claim rests on an unstated precondition

D1a places staging in `.cowork-staging/` at the space root, *"a sibling of the spaces, not a child of any
of them"*, and concludes it is **outside every space's write scope**. That conclusion is correct **given**
that Loop 1's allow-list resolves targets relative to the workspace root — which it does today
(`skills/self-apply/SKILL.md:57`: `.claude/skills/*/SKILL.md`, workspace-root `CLAUDE.md`, `context/*.md`,
`global-instructions.md`, all workspace-relative). A build that resolved apply targets against an absolute
space root, or that permitted `..` traversal, would void the claim silently.

D1a asserts the *same-filesystem* precondition and requires the build to check it rather than assume it —
which is exactly right, and is the model. **The reachability precondition deserves the same treatment:
state it, and have the build assert it.** Cheap, and it converts an inherited property into a checked one.

---

## Conditions from Phase 2 — verified in the artifacts, not in the reports

Each row re-measured against working-tree bytes. **"Real"** means the remedy does the security work the
finding asked for; **"nominal"** would mean the words appeared without the work.

| Finding | Verification performed | Verdict |
|---|---|---|
| **S1** CRITICAL | Old path absent; `docs/internal/ export-ignore` at `.gitattributes:28`; 84 tracked / 0 archived (non-vacuous); all 5 strings → 0 | **REAL, PARTIAL** — see ruling |
| **S2** CRITICAL | §D8a present at `architecture.md:15953`; names the v2.16 gate explicitly; additive-only ground stated; **void-on-modify condition stated**; `AC-SF2` at `roadmap.md:45` binds both paths | **REAL — and exceeds** |
| **S3** → C1-C5 | C1 restored with decision procedure + strict-superset criterion + absent-in-parent precondition; C2-C4 labelled lint; C5 renamed with enumerated key set, unknown-keys fail-closed *by construction*; marker-integrity leg citing QA-1/v2.12.0; LLM02 cited; semantic gap declared with owner + rung | **REAL — with S14 open** |
| **S5, S8** → D1a | All 3 S5 consequences and all 3 S8 assumptions addressed by sub-number; `/tmp` staging explicitly forbidden; same-device check *asserted, not assumed*; collision pre-check; verify→rename immutability; quarantine invalidates the card | **REAL** |
| **S6** → D7a | Flat `.cowork-spaces/` enumeration; all 4 `space_path` constraints present; constraint 3 (must contain slug-matching space) is stronger than I asked; "silence is not permission" | **REAL — exceeds** |
| **S7** → D9 | Population (*all tracked files, `.git` excluded*) + as-of revision (`ff0c44c`) both stated; re-run → 3, exact | **REAL** |
| **S9** | `identity guard` 0 in working tree, 1 before remedy, 0 at base; mapping table 3rd column now an origin-document pointer (`architecture.md:6086-6087`) | **REAL** |
| **S10** | Stale citations 5 → **0**; corrected 3 → **8**; delta exactly the 5 flagged, 3 pre-existing untouched; both repaired targets confirmed to exist on disk | **REAL — exactly scoped** |
| **S11** → D3 | "Informed consent (SSC LOSES)" row present at `:15846`; net claim stated; recorded as *a genuine open weakness* with no Maturation Path option closing it | **REAL — exceeds** |

**S2 deserves specific comment, because it was the finding I was most prepared to see answered
nominally.** D8a does not merely *state* which gate governs D8 — it adds constraint (2), gating item (c)
(the spawn-capability install) on the provenance leg *even though the rest of D8 is not gated*. I did not
ask for that. It closes the specific hole S2 named rather than documenting around it. And constraint (1)
carries an explicit **void condition** — *"void the moment it modifies existing user content"* — which
converts an accepted risk into one with a defined expiry. **That is the opposite of an answer in form.**

### Deletion audit — what was removed, not only what was added

`git diff --numstat`: `architecture.md` 739/6 · `hld.md` **94/0** · `risk-register.md` **7/7** ·
`roadmap.md` 12/2 · `spec.md` 416/0.

- **`hld.md` 94/0 confirms append-only** — the invariant the HLD amendment relies on. Zero deletions.
- **`risk-register.md` is 7/7 — a pure in-place modification.** All six touched ids (`SF-2`, `SF-3`,
  `SF-4`, `v2.19.5-CODEOWNERS-1`, `AC-PUB-10`, `CF-v2.19.6-A`) remain present. **No risk row was removed
  under cover of a citation repair** — I checked this specifically, because a citation-repair diff is an
  ideal place to lose a row.
- **`architecture.md`'s 6 deletions are a rename, not a removal:** the inline `CF-v2.5-A..E` list moved to
  `CF-v2.5-ARCH-*` (still present at `:6105-6106`), with the security/QA series migrating to the register.
  **Net effect is an egress *reduction*** — carry-forward content left the shipping `architecture.md`
  (confirmed present in the archive) for the non-shipping register.

### Register count — re-derived, not accepted

The register claims **41 strict / 44 broad**. My first pattern counted **46**, and the difference is
population, not error: my pattern spanned §K and the broad-count tables, which lie outside the register's
stated population of ten lettered subsections. Summing the section headers A-J: 7+6+3+2+5+2+6+5+2+3 =
**41** ✅. Spot-checked two sections against their own headers by row count: **§J → 3** (header says 3),
**§G → 6** (header says 6). **The register's arithmetic is sound and its population statement is what
makes it checkable** — which is ADR-093 working. Note pipeline row `2.R1`'s "40/43" was correct when
written and is now 41/44, the Phase 5 addition being `CF-plan-v3-engine-C1-AXIS3` itself.

---

## Classification Re-Run — re-confirmed at Phase 6

**Measured directly, per the brief's instruction not to take it on report.**
`git status --porcelain` at `/Users/macbookpro/claude-cowork-config`, 2026-08-28T15:12:48Z:

```
 M docs/architecture.md      ?? docs/internal/carry-forwards.md
 M docs/hld.md               ?? docs/qa-report.md
 M docs/risk-register.md     ?? docs/security-review.md
 M docs/roadmap.md
 M docs/spec.md
```

Paths matching `^docs/`: **8**. Paths **not** matching `^docs/`: **0** (`grep -cv '^docs/'` → 0, exit 1).
The two counts sum to the total, so the check is not vacuous.

| Tier trigger surface | Writes this cycle |
|---|---|
| `scripts/guards/` | **0** |
| `.claude/settings.json` | **0** |
| `docs/pipeline-policy.md` | **0** |
| any `scope_allow:` block | **0** |
| `.github/workflows/` | **0** |
| `.claude/commands/*.md` | **0** |
| `docs/` | **8** (5 modified, 3 untracked — 2 of which are ephemera) |

**VERDICT UNCHANGED: SECURITY-SENSITIVE = YES · Tier = NEITHER A NOR B · Guard Change Summary = NOT OWED.**

The surface changed since Phase 2 (`docs/carry-forwards.md` → `docs/internal/carry-forwards.md`, plus two
untracked ephemera) and the rule is unaffected, because **the rule keys on tier-trigger paths and the
count on every one of them is still zero**. `docs/spec.md` (416/0) was already in the Phase 2 count as the
Phase 0 product; it is not a new surface. Tier attaches to the write surface; classification attaches to
the subject. Both still hold, and the conditional re-escalation I set at Phase 2 (S4 fixed in-cycle would
be Tier B) **did not fire** — `.github/workflows/` is untouched, and `LEAK_PATTERN` remains correctly
carried forward rather than fixed here.

**Branch + PR still required and unaffected.**

---

## OWASP Top 10 Assessment — Phase 6

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | **FINDINGS** | S14 (protection loss undetected). S1 residual (public-clone read, accepted). S2/S5/S6 closed by D8a/D1a/D7a |
| A02 Cryptographic Failures | PASS | Provenance leg unchanged; A08 circularity caveat carries forward to the build cycle |
| A03 Injection | PASS (design-level) | No code surface |
| A04 Insecure Design | **FINDINGS** | S14 — a security check whose criterion cannot express one of its own axes. S3/S5/S8 remedies verified real |
| A05 Security Misconfiguration | **CARRIED** | S4 `LEAK_PATTERN` correctly *not* fixed here (Tier B). Both bare-named ephemera (`docs/security-review.md`, `docs/qa-report.md`) sit in the blind spot; row `2.R2` now names both |
| A06 Vulnerable Components | PASS | No dependency surface. `npm audit` N/A — no `package.json` in scope, PURE-DOC cycle |
| A07 Auth / Identity Failures | PASS | No auth surface. `CF-v2.5-D` (2FA) remains ORPHANED and pre-existing |
| A08 Software / Data Integrity | **CARRIED** | Provenance-leg circularity and the unverifiable seeded `CLAUDE.md` remain open, correctly, for the build cycle |
| A09 Logging & Monitoring | **MITIGATED** | S1 partial (see ruling); S9 closed and verified |
| A10 SSRF | N/A | No network surface |

### LLM Threat Assessment

| Threat | Status | Notes |
|---|---|---|
| **LLM01 Prompt Injection** | **IMPROVED, RISK-PRESENT** | C5 now has a decision procedure, an enumerated key set, and fail-closed-by-construction unknown keys. The semantic residue is declared with an owner and a target rung rather than implied away |
| **LLM02 Insecure Output Handling** | **IMPROVED, RISK-PRESENT** | C5's marker-integrity leg now cites QA-1/v2.12.0 — the precedent I said the ADR should cite, and it does. **S14 is the remaining LLM02 exposure**: generated safety machinery that quietly lacks a protection is invisible to C1 |
| **LLM06 Excessive Agency** | **IMPROVED** | D8a gates the capability install on the provenance leg; D7a constrains `space_path` four ways. Residual is S14 |
| Session-pin read surface | **PRESERVED** | No session-pin or env-var propagation change. 0 of 8 changed paths outside `docs/`. No new read surface |

---

## Summary

**PASS WITH WARNINGS — 0 CRITICAL · 2 WARNING · 3 INFO. I do not block Phase 7.**

**Every Phase 2 condition was answered in substance, and three were answered better than I asked.**
I went looking specifically for the form-not-substance failure this cycle has produced repeatedly, and
on the Phase 2 conditions **I did not find it**. D8a adds a provenance gate on item (c) that I never
requested and a void condition that gives the accepted risk an expiry. D7a's third `space_path`
constraint turns "follow the path" into a verified lookup. D3 not only added the axis SSC loses but
recorded that nothing in the ADR closes it. Those are the marks of conditions engaged with rather than
discharged.

**The one finding I bring that nobody had (S14)** is not a gap in what was written — it is a gap in what
C1 can express. Its failure criterion is a strict-superset test over a union that mixes capabilities with
a protection, and a superset test detects only increase. A child that *loses* deny-list protection
computes a smaller union and passes. The check named as the composition leg's one security control is
structurally blind to the regression that ADR-061's deny-list exists to prevent. **@qa was right that
there is a problem inside C1 and right about which axis is worst for extraction; the deeper issue in
axis (ii) is not extraction at all, which is why reading C1 for extractability does not reveal it.**

**On S1 I confirm @qa's framing and adopt it as my own ruling.** "Mitigated (partial)" is not too
generous. The release-archive half is genuinely closed and negative-controlled; the public-clone half
survives and cannot be closed by any remedy available to a documentation cycle. The remedy @architect
chose — relocation plus pointers-not-detail — is the right one, and calling it *discharged* would have
retired a CRITICAL that is still live in a public repository. **It should be carried as an accepted risk
with an owner, not closed.**

**On `CF-plan-v3-engine-C1-AXIS3` I concur with deferral and dissent on the wording.** A fail-open axis
in a fail-closed check is severe — but it is severe *in an implementation*, and there is no
implementation. The receiving gate is real. What must not travel to the build cycle is the carry-forward's
option (b): "narrow C1 to axes (i) and (ii)" reads as the safe, cheap choice and is neither, because S14
lives in axis (ii). **Broaden the carry-forward to two legs and strike option (b) before Phase 8** —
`docs/internal/`, in scope, no re-classification.

**Classification re-confirmed by direct measurement: SECURITY-SENSITIVE, Tier NEITHER A NOR B, no Guard
Change Summary owed.** 8 changed paths, 8 under `docs/`, 0 on any tier-trigger surface. The Phase 2
conditional re-escalation did not fire.

**One process note, offered because the cycle keeps proving it.** The number I was asked to be careful
about went stale a fourth time — inside @qa's own correction (S16), which prescribed a figure that was
itself wrong. @architect refused it and recorded the invariant instead. **That refusal is the most
valuable single act in this cycle's Phase 5, and it generalizes: where a figure is invalidated by the
act of recording it, prescribe the invariant, not a fresher number.**

---

*@security — Phase 6, `plan-2026-08-27-v3-engine`. Read-only agent; findings reported, nothing fixed.
Base `ff0c44c` verified unchanged at audit start and end; no branch, no commit, no push.
This file remains UNTRACKED and MUST NOT enter the feature commit — it is bare-named and `LEAK_PATTERN`
requires a trailing hyphen, so CI cannot catch it. Phase 8 archives it; `archive-regression-guard.sh`
correctly forbids moving it before then.*
