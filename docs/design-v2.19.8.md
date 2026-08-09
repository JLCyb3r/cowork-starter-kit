# Design — v2.19.8 "Polish the Carryovers"

**Cycle:** v2.19.8 (PATCH) · **Project:** `claude-cowork-config` · **Repo:** `/Users/macbookpro/claude-cowork-config`
**Branch:** `release/v2.19.8-polish-the-carryovers` · **Base:** `main` @ `c8342d7`
**Author:** @architect (opus) · **Phase 1** · 2026-08-09
**Spec:** `docs/spec.md` § *Product Spec — Cowork Starter Kit v2.19.8 "Polish the Carryovers"*

---

## Phase 1 Design Header

> *ISO 15288 — Technical Management: Decision Management.*

### Worktree discipline

`Worktree discipline: SKIPPED (COUNCIL_EXPECTED_BASE_SHA not set)` — verified by `printenv COUNCIL_EXPECTED_BASE_SHA` (exit 1, unset). This cycle is **not** a Council worktree cycle: it runs on a branch **inside the cowork repo**, mirroring v2.19.7 (`release/v2.19.7-finish-the-storefront` → PR #103). Base verified live: `git -C /Users/macbookpro/claude-cowork-config rev-parse HEAD` → `c8342d75242830c6b9691bfb44ff46ced4af11ea`, clean tree, level with `origin/main`. Running The-Council's `pre-spawn-check.sh` here would be a category error, not a skipped control — it validates Council-repo worktree branches (same reasoning recorded at v2.19.7 Phase 1).

### Buy-vs-Build

`Buy-vs-Build: 2 components scanned — REUSE 1 / ADOPT 0 / EXTEND 1 / BUILD 0`

### Reuse Scan

Four-source Reuse Radar run 2026-08-09.

- **Source 1 — Reuse Registry** (`The-Council/docs/reuse-registry.md`): present, grepped `-inE 'citation|anchor|ledger|annotation|verif|grep'`. No code row matches a ledger-annotation verifier (RA-007 = stack detection, RA-013 = LM Studio adapter). **One high-value non-code hit** — see the REUSE row below.
- **Source 2 — Scaffold index** (`The-Council/examples/scaffolds/INDEX.md`): **not present** (`ls` → No such file or directory) — skipped, not silently dropped. This cycle stands up no new app/service/CLI surface, so a scaffold would not apply regardless.
- **Source 3 — CS catalog + ADR tags** (`The-Council/docs/constituent-systems.md`): present, grepped `-inE 'citation|ledger|annotation|verif'` → **zero matches**.
- **Source 4 — SoS interfaces** (`.claude/projects/ecosystem/sos-interfaces.json`): present, 8 entries enumerated (producers: `confidante` ×4, `pillar-os`, `@cs1/substrate`, `cs-4`). **None applies** — `claude-cowork-config`'s registry entry carries `"parents": []`, so it sits under no SoS umbrella and consumes no ecosystem interface contract.

| Component | Registry hit (grep pasted) | OSS candidate | Scaffold | Decision | Basis |
|---|---|---|---|---|---|
| Content-anchored citation rule (the policy, not the code) | **HIT** — `grep -inE 'citation\|anchor' docs/reuse-registry.md` → `:16 "file:line (line numbers rot; a rotted citation still looks authoritative). See ADR-198 §Risk (1)."` and `:82 "a row's consumers cell is reproduced by a re-runnable command with its scope visible, not by frozen file:line citations."` | n/a — internal policy | n/a | **REUSE** | The-Council's ADR-198 §Decision 2 already settled this exact rule portfolio-side. This cycle adopts its **stronger** form rather than re-deriving the weaker one — see §A.3. |
| `scripts/verify-ledger-annotations.sh` | No row | No candidate — a bash verifier over this repo's own eight named annotations is not a general problem anyone has packaged; an external dependency would also violate `AC-B-VERIFY-4` (no third-party network calls) and add supply-chain surface to a truth-repair cycle | n/a | **EXTEND** | Extends three in-repo house patterns rather than starting from a blank file: `scripts/verify-vendored-orphans.sh` (zero-scan `CHECKED == 0` guard, `::error::` prefix, `--flag` test seams, `set -euo pipefail`), `scripts/verify-lock-removals.sh` (base-vs-head diffing, named-failure reporting), `scripts/release-archive-assert.sh` (single-sourced assertion invoked from two call sites). Read this session, not recalled. |

**No BUILD rows.** No new dependency is introduced; no license gate is triggered; `ATTRIBUTIONS.md` is unchanged.

### Reuse fold-in that changes the design (worth stating separately)

ADR-198's rule is **stronger than the one Phase 0 wrote**, and the difference is load-bearing. Phase 0 required a content-anchored citation. ADR-198 additionally requires that **the grep's scope be visible in the artifact**, on the strength of a real incident: a v0.32.2 claim of "9 consumers, grep-confirmed this session" was honestly verified and still wrong, because the grep was silently scoped to one subdirectory. The real count was 11. A `file:line` list would not have caught it either — *"the verification was P1-compliant and still wrong, because the grep's scope was invisible in the artifact."*

Folded into §C.2 as a hard requirement: every anchor the verifier runs records the **file it searched**, not only the pattern. A pattern that matches in some file somewhere is not the same claim as a pattern that matches in the file the annotation cites.

### EARS check

Applied per `.claude/skills/architect/ears-requirements.md` to all HIGH-severity ACs in the REVISED spec.

**2 HIGH-severity findings, both resolved in-place at Phase 1 rather than raised as OQs** — each was not merely vague but **unsatisfiable against the real artifact**, which is a defect, not an ambiguity:

| Finding | AC | Class | Resolution |
|---|---|---|---|
| **EARS-1 (HIGH)** | `AC-A3` | Unsatisfiable postcondition | `grep -c 'AC-OT3-2: ' docs/spec.md` returns **1** today, and that match is the historical v2.19.4 checkbox. "Returns exactly one of the two literal tokens" can never hold once the token is written (count → 2), and the only route to "exactly one" is deleting a historical line. `[EARS-REVISED]` → line-anchored, distinct-key form: `grep -cE '^AC-OT3-2-DISPOSITION: (DETERMINATE\|INDETERMINATE)$' docs/spec.md` == 1. |
| **EARS-2 (HIGH)** | `AC-B5-2` | Under-scoped observable | The NC `grep -n 'sync-agency.yml:[0-9]'` → 0 passes while a **second** stale citation (`architecture.md:3187`, real 3191) remains in the same string. `[EARS-REVISED]` → `grep -cE '[A-Za-z0-9_./-]+\.(md\|yml\|sh\|json):[0-9]+' .cowork-allowlist.json` == 0. |

**MEDIUM/LOW (advisory, no rewrite):** `AC-A1`'s "direct quotation ... addressing kit-vs-skill granularity" leaves *addressing* to judgment. Not rewritten — @compliance verified live at Phase 2 that GuildSkills is still silent on this, so the honest outcome is the `INDETERMINATE` branch and the judgment call is unlikely to bind. Recorded rather than engineered away.

Both HIGH findings share one shape: **an AC whose verification command was never run against the artifact it names.** That is the cycle's own thesis, reproduced inside the cycle's own spec, for the second and third time (the first was the `CHANGELOG.md:1038` inheritance caught at 0.D). Recorded in §Anti-Pattern Detection, not smoothed over.

### SoS Classification + UAF

`parents: []` in `.claude/projects/registry.json`; no ecosystem umbrella; Source-4 scan found no applicable interface.

**N/A — single-project design.**

- Strategic viewpoint: N/A — single-project design.
- Operational viewpoint: N/A — single-project design.
- Services viewpoint: N/A — single-project design.
- Personnel viewpoint: N/A — single-project design.

One cross-repo *reference* exists (`ot3-catalog-research-2026-08-02.md`, Council-side, read-only input per C-6). A read-only file path is not an interface: nothing is produced, versioned, or contracted across the boundary, and `AC-E-S8` forbids any write in that direction. It does not make this an SoS design.

### Reliability Analysis

`Reliability Analysis: N/A per NEVER-APPLY (no multi-provider request path, no failover/fallback mechanism, and no SLA or availability claim in the spec — the cycle is documentation repair plus one local bash verifier).`

### Heuristics Check (Rechtin)

| Heuristic | Signal produced this cycle |
|---|---|
| *"The first line of defense against complexity is simplicity of design."* | **FIRED — and it changed a decision.** The `v1.0.0`/`v1.1.1` backfill option requires bypassing `publish-release.sh`'s own version guard, hand-building two 2026-04 archives from a 2026-08 checkout, and absorbing a red CI run. The record-side option is text. Simplicity is decisive here, not merely preferred. See §B. |
| *"Do not confuse the model with reality."* | **FIRED, twice.** Both EARS findings are exactly this: the spec's model of `docs/spec.md` and `.cowork-allowlist.json` did not match the files. Both were found by running the command, not by reading the AC. This heuristic is the cycle's own subject matter. |
| *"Build in and maintain options as long as possible."* | **FIRED.** The chosen disposition is fully reversible — tags can still be created later. The rejected option is irreversible: deleting a published Release is itself a visible public event. Where a decision is genuinely close, take the reversible one. |
| *"In introducing technological and social change, how you do it is often more important than what you do."* | **FIRED, on the travisvn wording.** @compliance's L1 is not a legal finding; it is a finding about how a true fact gets written down. "NO KNOWN LIFT PATH" and "permanent by our own choice; owner-hand-authored path untested" describe the same world and produce different future decisions. |
| *"A model is not reality"* → **relevant duplicate**, folded into row 2 | — |
| *"Regarding the choice between advantages, choose the one that is hardest to reverse last."* | **NOT APPLICABLE** — no ordering-of-irreversibles question arises; the cycle performs zero irreversible acts by construction (`AC-C3`). Recorded rather than omitted. |

### Production-Artifact Validation

This design's logic parses **real repository artifacts** — `CHANGELOG.md`, `docs/risk-register.md`, `docs/retro.md`, `docs/owner-tasks.md`, `.cowork-allowlist.json`, `.github/workflows/sync-agency.yml`, `docs/architecture.md`, `docs/spec.md`. Every candidate anchor in §C.2 was run against the **actual current file** in this repository at `c8342d7`, read-only, before being written into the design. No fixture stood in for a real file.

`Production validation: 11/11 backward-looking anchors PASS · 8/8 forward-looking anchors correctly RED · 19 total, zero fixtures`

The Council-side cross-project loop (`for p in $(ls .claude/projects/ ...)`) is **not applicable** and was deliberately not run: this design parses no Council pipeline artifact, and running a probe across live parallel-session projects would touch other sessions' state for no evidentiary gain. The equivalent obligation — *run it against the real file, never only a fixture* — is discharged by the 12/12 table in §C.2.

Two anchors **returned a different answer than the spec assumed**, which is the entire reason this step exists: `sync-agency.yml:228` → real 238, and `architecture.md:3187` → real 3191. A fixture-based validation would have passed both.

### Classification Re-Run (§PostOQClassificationReRun)

**Result: CONFIRMED — SECURITY-SENSITIVE, Tier B (PR required, Guard Change Summary NOT required) · COMPLIANCE-SENSITIVE.**

Re-evaluated against the **final** §D file list, not against the 0.D scope. The file list **grew by one surface** since @security's Round-2 settlement (`.github/workflows/quality.yml`, per `AC-B-VERIFY-CI`). @security pre-authorised exactly this: *"a second [Tier B surface] is possible if Phase 1 wires `scripts/verify-ledger-annotations.sh` into `quality.yml` — that changes the surface COUNT, not the TIER, so the GCS answer is invariant either way."* `.github/workflows/` is a **Tier B** row in Council policy (worktree + PR required, GCS not required). No Tier A path is added.

Walked path by path against the Tier A row set:

| Tier A row | In the final file list? |
|---|---|
| `scripts/guards/` | No |
| `.github/CODEOWNERS` | **No — and `AC-B-CODEOWNERS` forbids adding it** |
| `.claude/agents/*.md` `scope_allow:` / `hooks:` blocks | No — and `AC-E-S8` forbids any Council-side write |
| `.cowork-allowlist.json` **structural region** | **No** — the touched region is `reason` prose only, and `AC-B5-TIER` is the falsifier that makes that claim testable rather than asserted |
| Branch-protection / release-gating control inputs | No — `scripts/publish-release.sh` is neither run nor modified (@security S16) |

**Direction of flip: none.** Not ESCALATED (no Tier A surface entered), not DOWNGRADED (Tier B and COMPLIANCE-SENSITIVE both persist; `/legal` already ran). Phase 2 is **not** skippable at this tier and is not being skipped.

**Two snap-back conditions, both live and both testable:**
1. `AC-B5-TIER` — if the control-bearing `jq` projection of `.cowork-allowlist.json` differs base vs head, **Tier A snaps back and a GCS is owed before merge**. Ships with a mandatory firing negative control.
2. `AC-B-CODEOWNERS` — adding `scripts/verify-ledger-annotations.sh` to `.github/CODEOWNERS` flips the tier. Verified by `git diff --numstat <base>..HEAD -- .github/CODEOWNERS` reporting **no rows at all**.

### B1 Scope-Allow Cross-Reference

`B1 verification: N/A-BY-SHORT-CIRCUIT — verified at the guard source, not assumed @ 2026-08-09T13:50:00Z`

Read `The-Council/scripts/guards/scope-check.sh` this session. At `:708-712`:

```bash
# --- External project: allow all writes within the project root ---
if [ -n "$ACTIVE_PROJECT_PATH" ] && [[ "$FILE" == "$ACTIVE_PROJECT_PATH/"* ]]; then
  # External project mode: dev and devops can write freely within the project
  exit 0
fi
```

This returns **before** `scope_allow.standard[]` is ever read. Every §D path is inside `/Users/macbookpro/claude-cowork-config/`, so the short-circuit governs all of them and `scope_allow.standard` is never consulted. This reproduces @security's v2.19.7 Phase-2 self-correction (a HIGH scope-allow finding prepared, premise checked, finding **withdrawn**, PASS 25/25).

**The `scope_allow_delta` trap, named so it is not walked into.** Populating `scope_allow_delta.add[]` with the eleven §D paths would require editing `The-Council/.claude/agents/dev.md`'s `scope_allow:` block. That block is the **literal Tier A row** in Council policy — the same shape as @security's S12 CODEOWNERS trap, one repo over. It would flip this cycle to Tier A and re-incur the GCS, **for entries the guard would never read**, and it would violate `AC-E-S8`. The correct block is empty, and the reason is a finding rather than an omission.

```yaml
scope_allow_delta:
  add: []
  rationale: >
    Empty by design, on three independent grounds, in order of decisiveness:
    (1) STRUCTURAL — scripts/guards/scope-check.sh:708-712 short-circuits `exit 0` for any
        write inside a registered external project's root, before scope_allow.standard[] is
        read. All 11 §D paths are inside /Users/macbookpro/claude-cowork-config/.
    (2) TIER — populating it means editing .claude/agents/dev.md's scope_allow: block, the
        literal Tier A row; it would flip this cycle to Tier A and re-incur a Guard Change
        Summary for entries that are never consulted.
    (3) SPEC — AC-E-S8 prohibits any agent modifying any Council-side file this cycle.
  real_control_instead: >
    The short-circuit is conditional on ACTIVE_PROJECT_PATH resolving. If the session pin
    fails to reach @dev's hook context at Phase 4, EVERY cowork write blocks with a
    MISLEADING scope_allow message (@security S18, v2.19.7; unclosed carry-forward). See
    AC-PREFLIGHT-PIN below — the orchestrator verifies pin propagation BEFORE /implement,
    not after a write unexpectedly blocks.
```

**`AC-PREFLIGHT-PIN` (binding on the orchestrator, before `/implement`):** confirm the session pin resolves in @dev's hook context, and paste the confirmation into the Phase-4 pipeline row. Failure mode if skipped: a `scope_allow`-shaped error message for what is actually a pin-resolution problem — the same misleading-signature family as `CF-COUNCIL-WORKTREE-ALLOWLIST`, which cost v2.19.7 two blocked agents.

---

## §A — Ledger truth repair

> *ISO 15288 — Technical: Architecture Definition.*

### A.1 What is actually wrong

Eight annotations, one root cause: **a claim about an artifact was carried forward instead of re-derived from the artifact.** Not eight independent errors — one habit, eight surfaces.

### A.2 Repair shape

Every repair is **additive**. Nothing is rewritten in place except `.cowork-allowlist.json`'s `reason` string (a JSON value, not a historical record) and the `AC-OT3-2-DISPOSITION:` placeholder this cycle itself introduces. `docs/retro.md`'s invented closing condition is **corrected by a dated note beside it, not by deleting it** — the false line is part of the record of how the cycle thought, and destroying it to make the file look correct is the same instinct the cycle exists to fix.

### A.3 The permanent rule, in its stronger form

Content-anchored citations only, in text this cycle writes — **plus ADR-198's scope-visibility requirement** (see Reuse fold-in above): the anchor records the **file searched**, not only the pattern. `scripts/verify-ledger-annotations.sh` is the enforcement mechanism; `AC-B-VERIFY-CI` is what makes it permanent instead of a one-cycle cleanup.

---

## §B — The `v1.0.0` / `v1.1.1` disposition

> *ISO 15288 — Technical Management: Decision Management.*

### B.1 The question, restated against evidence rather than inclination

The owner deferred the mechanism to Phase 1 with a stated inclination — *"I am inclined to make write in retro, I want it all clean and good"* — read as preferring an honest written record over fabricated retroactive tags, against a **quality bar, not a minimum**. My brief was to decide the mechanism against **how this repo's existing version history actually records things**. So I measured it rather than reasoning from the inclination.

### B.2 What this repo's version history actually does

Computed at `c8342d7`, `comm` over `grep -oE '^## \[[0-9][0-9.]*\]' CHANGELOG.md` and `git ls-remote --tags origin`:

```
== CHANGELOG sections with NO remote tag ==   1.0.0   1.1.1
== remote tags with NO CHANGELOG section ==   2.0.1
```

**Exactly three mismatches across 47 versions.** Every other version has a CHANGELOG section, a remote tag, *and* a GitHub Release. `gh release list` confirms the Releases page begins at **v1.1.0** (2026-04-16) — v1.0.0 (2026-04-15) predates the first Release by a day, and v1.1.1 shipped the same day as v1.1.0 and simply never got its own tag.

**So this repo's convention is a 1:1 CHANGELOG↔tag↔Release invariant, satisfied 44/47 times and never written down.** That is the real finding, and it reframes the question. The defect is not "two versions lack tags." The defect is **an unstated invariant with three silent violations** — which is precisely this cycle's named defect class (an authoritative artifact asserting something its own contents contradict), sitting in the version history rather than in the ledger.

Both commits exist and are unambiguous: `git show 4bfc704:VERSION` → `1.0.0`; `git show 66c09af:VERSION` → `1.1.1`. **Retroactive tagging is therefore genuinely possible.** It is rejected on grounds, not on impossibility — these are two real options.

### B.3 The two real options

**Option 1 — Retroactive tag + Release (backfill).** Tag `4bfc704`/`66c09af`, push, create Releases from the CHANGELOG bodies with a backfill caveat. Precedent exists: `PUBLISH_BACKFILL_CAVEAT=1` backfilled v2.19.5/v2.19.6 at v2.19.7.

*For:* restores the invariant to 47/47 with a mechanism this repo has used successfully within the last two days.

*Against — four costs, three of them verified live this session and one of them new:*

1. **It contradicts a locked owner decision.** Scope C is `C-CHANGELOG`, record-side only; `AC-C3` (@security S11) extends the no-live-write boundary to all three tags precisely to close this branch.
2. **`publish-release.sh` structurally refuses both.** Create path → `VERSION_AT_HEAD=2.19.7` ≠ requested → `exit 1` (0.D-verified). The script's **own comment names `publish-release.sh 1.0.0` as the negative control for that guard.** Executing the negative control as the repair mechanism is not a workaround; it is an admission the mechanism is wrong.
3. **NEW, and nobody has raised it — a tag push leaves a permanent red run on the public Actions history.** `.github/workflows/release-assets.yml` triggers on `push: tags: 'v*'` (read this session; the trigger was **deliberately retained** at v2.19.7 as *"the net for anyone who tags with a plain `git push`"*). Its first step is a fail-closed precondition: no Release for the tag → `::error::` → `exit 1`. Its second step requires **both** archives attached. So a tag-only backfill produces two permanent red runs, and a full backfill requires hand-building two 2026-04 archives from a 2026-08 checkout outside the repo's only release mechanism.
4. **It is irreversible.** A published Release can be deleted, but the deletion is itself a visible public event.

**Option 2 — Documented-unpublished (record-side).** Annotate both CHANGELOG sections with the verified fact, state the invariant and its exceptions in the CHANGELOG preamble, close `AC-PUB-10` as a recorded disposition.

*For:* honest; zero live writes; fully reversible; matches the owner's inclination; keeps the boundary `AC-C3` tests.

*Against:* the invariant stays 44/47. A future reader could still read the gap as an oversight — **unless the record makes it deliberate.** That is the whole burden of the option, and it is what the preamble note carries.

### B.4 Decision

**Option 2 — documented-unpublished. No retroactive tag, no retroactive Release, for either version.**

Three deliverables (`AC-C2`):

1. A dated `> **Release surface:**` note under each of the two CHANGELOG headings, stating the verified fact — merged to `main` at the named commit, **never tagged, never released** — anchored on `4bfc704` / `66c09af`.
2. A `## Release surface` subsection in the **CHANGELOG preamble**, above the first version section, stating the invariant and enumerating all three exceptions.
3. `docs/risk-register.md`'s `AC-PUB-10` row moves `OPEN` → `CLOSED (disposition recorded, v2.19.8)`.

**Why deliverable 2 is not optional, and why it is what makes this "all clean and good" rather than merely adequate.** A note at line 1069 of a 1,200-line CHANGELOG is honest and invisible. The owner's bar is a quality bar. Deliverable 2 puts the complete picture where a stranger actually lands, and it converts the situation from *"an undocumented invariant with three silent violations"* into *"a documented invariant with three recorded exceptions."* That is a strictly better state than Option 1 reaches: Option 1 would fix two of the three anomalies and leave the invariant **still unstated**, so the next gap would be silent all over again.

**Precision the record must carry.** These versions were **developed and merged to `main`; they were never tagged and never published as Releases.** Not "never developed," not "withdrawn." The code shipped; the release surface was never created. That distinction is the difference between an honest record and a flattering one.

**Reversibility, stated for the gate:** this decision is fully reversible. Nothing here prevents a later cycle from tagging both versions — Option 1 remains available at any time, at the costs enumerated in §B.3. The reverse is not true, which is the tiebreaker.

### §Maturation Path (per [[maturation-path-in-adr]] binding)

- **Future-state options:** (a) tag both versions and publish Releases with an explicit backfill caveat, once `publish-release.sh` grows a `--backfill-historical` mode that decouples the requested version from `VERSION_AT_HEAD` and can attach archives built from an arbitrary tree-ish; (b) extend `verify-release-surface.sh`'s floor below `v2.18.0` so the invariant is machine-checked rather than documented, once the anchor-form predicate is generalized (already named in ADR-077 §Maturation Path option (a) and ADR-078 option (b)); (c) leave both permanently unpublished and treat the preamble record as the terminal state.
- **Concrete revisit triggers:** (i) a third CHANGELOG↔tag mismatch appears — one is an accident, two is history, three is a process defect and the invariant needs enforcement rather than documentation; (ii) `publish-release.sh` gains a historical-backfill mode for any other reason, making option (a) nearly free; (iii) an external consumer (a catalog listing, a package index, a security scanner) is found to key off the tag list rather than the CHANGELOG, converting a documentation gap into a functional one; (iv) `verify-release-surface.sh`'s floor is lowered below `v2.18.0` for any reason, at which point these three become live gate findings.
- **Risk knowingly accepted:** the CHANGELOG↔tag invariant remains **44/47 in machine-checkable form** and 47/47 only in prose. A tool that enumerates tags — rather than reading `CHANGELOG.md` — still sees two versions missing, and this decision does not change that. The mitigation is documentary, not structural, and it depends on a reader reaching the preamble. Accepted because the alternative costs two irreversible public writes, a bypass of the repo's only release mechanism, and at minimum one permanent red CI run, to fix a discoverability gap in versions that are 16 weeks old and superseded 44 times.

---

## §C — `scripts/verify-ledger-annotations.sh`

> *ISO 15288 — Technical: System Requirements Definition + Design Definition.*

### C.1 Purpose and contract

One re-runnable, content-anchored command per Scope B annotation. Exit 0 iff every annotation resolves; exit 1 naming the **specific** annotation that failed.

**What it is NOT:** it does not check that an annotation says something *true*. It checks that every anchor an annotation cites still **resolves to the thing it names**. That is the rot this cycle exists to stop, and overclaiming the script's reach would be the exact false-control shape the repo has been closing for three cycles.

### C.2 The anchor table — every row run against the real file at `c8342d7`

| ID | Annotation | Anchor (file searched + pattern) | Live result | Status |
|---|---|---|---|---|
| `LA-01` | `CF-v2.19.6-A` relocated | `docs/risk-register.md` ← `CF-v2.19.6-A` | 1 match (line 14) | PASS |
| `LA-02a` | `CF-v2.19.5-B` closure cmd | `scripts/verify-vendored-orphans.sh` exists | file present | PASS |
| `LA-02b` | `CF-v2.19.5-D` closure cmd | `.github/workflows/sync-agency.yml` ← `exit 1` | matches present | PASS |
| `LA-02c` | `CF-v2.19.5-E` closure cmd | `.github/workflows/sync-agency.yml` ← `flagged_files<<` | matches present | PASS |
| `LA-03` | `S-A3`/`S-A9`/`S-A10` real location | `docs/security-audit-v2.19.6.md` ← `S-A3\|S-A9\|S-A10` | 6 matches (15, 21, 22, 202, 327, 348) | PASS |
| `LA-04a` | `AC-PUB-10` v1.0.0 anchor | `CHANGELOG.md` ← `^## \[1\.0\.0\]` | **1116** (spec said 1038) | PASS — spec corrected |
| `LA-04b` | `AC-PUB-10` v1.1.1 anchor | `CHANGELOG.md` ← `^## \[1\.1\.1\]` | **1069** (spec said 991) | PASS — spec corrected |
| `LA-05a` | allowlist reader anchor | `.github/workflows/sync-agency.yml` ← `Check blocked files` | **237** (string said 228) | PASS — **defect found** |
| `LA-05b` | allowlist false-claim anchor | `docs/architecture.md` ← `CI fails if any blocked file` | **3191** (string said 3187) | PASS — **defect found, second one** |
| `LA-06` | `v2.19.7-LEDGER-FP` row | `docs/risk-register.md` ← `v2.19.7-LEDGER-FP` | 1 match (line 13) | PASS |
| `LA-07` | retro invented condition | `docs/retro.md` ← `the next PR touching` | 1 match (line 198) | PASS |
| `LA-08` | OneSkill tracked row | `docs/owner-tasks.md` ← `ONESKILL KIT-VS-SKILL FIT` | 0 matches | **RED — correct**; Phase-4 target |

**Two anchor populations, counted separately so neither number flatters the other:**

- **Backward-looking anchors — 11 of 11 resolve against the real tree at `c8342d7`** (`LA-01` … `LA-07`, excluding `LA-08`). These describe state that already exists; every one had to resolve now, and every one does.
- **Forward-looking anchors — 8, all correctly RED at Phase 1** (`LA-04c`, `LA-05c`, `LA-08`, `LA-09`, `LA-10a`, `LA-10b`, plus the two `AC-C2` legs). These describe state Phase 4 creates. A forward anchor that passed at Phase 1 would be the bug.

`Production validation: 11/11 backward-looking anchors PASS · 8/8 forward-looking anchors correctly RED · 19 total, run against production state, zero fixtures`

`LA-05a` and `LA-05b` are why the loop exists. Both returned a **different answer than the spec assumed**, and both were invisible to any fixture. `LA-05c` is the widened control that catches the second one; it is RED today, which is how its ability to fail is known rather than claimed.

### C.3 Structure

```
scripts/verify-ledger-annotations.sh [--repo-root DIR]

SECTION 1 — STATIC ANCHORS (LA-01 .. LA-08)
  Deterministic, offline, reproducible from a clean checkout.
  Pass condition: every anchor resolves in the FILE IT NAMES.
  Failure: `::error::verify-ledger-annotations: <LA-ID> — <anchor> did not
           resolve in <file>` ; sets FAIL=1 ; CONTINUES (report all, not first).

SECTION 2 — LIVE PROBES (LP-01 ..)          [B-1 / AC-B-VERIFY-3]
  Pass condition: "probe executed, output recorded with a UTC timestamp."
  NEVER "reproduces" — live API state is not a reproducible fixture.
  A FAILURE here means THE PROBE DID NOT EXECUTE, never that a value changed.
  LP-01: `gh api repos/:owner/:repo/branches/main/protection`
         — currency evidence for v2.19.5-CODEOWNERS-1. Recorded, never asserted.

ZERO-SCAN GUARD                              [AC-B-VERIFY-2]
  CHECKED == 0 -> exit 1. House pattern, verify-vendored-orphans.sh:94-97.

EXIT  0 = every static anchor resolved AND every live probe executed
      1 = usage error, unreadable input, missing tool, zero-scan, or any failure
```

### C.4 Binding design constraints

1. **Scope visibility (ADR-198 fold-in).** Every anchor names the file it searched. `grep -q <pattern>` across the repo is forbidden; `grep -q <pattern> <named-file>` is required. A pattern matching *somewhere* is a different claim from a pattern matching *where the annotation says it is*.
2. **Null-delimited iteration** where any list is iterated, per ADR-084 (@security S15).
3. **No third-party network calls.** The only egress is `gh` against this repository's own API (`AC-B-VERIFY-4`). This keeps Scope A/E's third-party boundary out of the verification harness — a verifier that reaches guildskills.com would put the untrusted-content boundary inside the control that guards it.
4. **No line numbers in the script's own assertions.** The script must not commit the defect it detects. Its *header comments* may cite `file:line` for narrative only, and must be marked as narrative — this repo's existing verifiers do carry such comments (e.g. `verify-vendored-orphans.sh` cites `quality.yml:1614`), and that is tolerated in prose but forbidden in an assertion.
5. **Test seams via `--flag` only**, never environment variables, matching the house convention (`--vendored-dir`, `--lock`, `--base`, `--head`). Real call sites never pass them.
6. **`set -euo pipefail`**, `::error::` prefix on every failure line, bash-3.2 portable (this repo enforces bash-3.2 portability in CI).

### C.5 CI wiring (`AC-B-VERIFY-CI`)

New job in `.github/workflows/quality.yml`, modeled on `vendored-removal-ledger`:

```yaml
  ledger-annotations:
    name: Ledger Annotations (v2.19.8)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - name: Verify every ledger annotation's citation still resolves
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: bash scripts/verify-ledger-annotations.sh
```

Notes, each deliberate:

- **No `if: github.event_name == 'pull_request'`.** Unlike `vendored-removal-ledger`, this check needs no base revision — it is a point-in-time property of the working tree, so it should also run on `push`. Citation rot is not a PR-only event.
- **No `fetch-depth: 0`.** Nothing diffs against a base. Adding it would be cargo-culted from the neighbouring job.
- **`GH_TOKEN`** is required for Section 2's live probe only. Section 1 is fully offline; the script must degrade Section 2 to a recorded "probe unavailable" rather than fail the build when the token is absent — a *static-anchor* regression is the finding, and coupling it to token availability would make the important half of the check hostage to the unimportant half.
- **NOT added to `.github/CODEOWNERS`** (`AC-B-CODEOWNERS` / @security S12).
- **Not a required status check.** Branch protection remains an owner-held decision (`OT-7` step 2), unchanged here.

---

## §D — File-by-File Implementation Plan

> *ISO 15288 — Technical: Implementation (plan).*

All paths relative to `/Users/macbookpro/claude-cowork-config/`. Scope resolves with the **cowork repo as project root**, `scope_allow.standard` (**not** `self_improve`) — governed by the §708-712 short-circuit above.

| # | Path | Phase | Action | Δ | ACs | Notes |
|---|---|---|---|---|---|---|
| 1 | `docs/spec.md` | 1 ✅ | **APPEND** v2.19.8 section | +492 / **−0** | all | **Done this phase.** Asserted `git diff --numstat` → `492 0`. |
| 2 | `docs/design-v2.19.8.md` | 1 ✅ | CREATE | new | — | This file. Precedent: `docs/design-v2.19.6.md`, `docs/design-v2.19.7.md` both live in `docs/`. |
| 3 | `docs/architecture.md` | 1 ✅ | **APPEND** ADR-081 | append-only | `AC-B-APPEND` | Records §B decision + §C contract + the forward correction of the third stale `:3187` citation. Never edited in place. |
| 4 | `scripts/verify-ledger-annotations.sh` | **written at 1, COMMITTED at 4** | CREATE, `chmod +x` (`-rwxr-xr-x`, 13,715 bytes) | new | `AC-B-VERIFY-1..4` | **On disk and proven at Phase 1; deliberately left UNTRACKED — the pre-commit gate blocked it and the block is correct.** See §D.1 below. `bash -n` clean. Run against the real tree: **exit 1, 13 PASS / 6 RED**, every RED a Phase-4 target. **Not** added to CODEOWNERS. @dev commits it post-gate and owns refinement only — adding anchors is expected; loosening or deleting one is a Phase-5 finding, not a fix. |
| 5 | `.github/workflows/quality.yml` | 4 | ADD one job | +~10 | `AC-B-VERIFY-CI` | Tier B surface. Purely additive — the 30 existing jobs stay byte-identical. |
| 6 | `docs/risk-register.md` | 4 | ANNOTATE | additive | `AC-PUB-10`, `LA-01`, `LA-06`, `AC-C2` | `CF-v2.19.6-A` → Closed; `v2.19.7-LEDGER-FP` → Closed; `AC-PUB-10` citations repaired **and** row → CLOSED. Protected by `AC-B-APPEND`. |
| 7 | `docs/retro.md` | 4 | ANNOTATE | additive | `LA-07`, Scope B 2 & 9 | v2.19.5 §11 closures; dated correction beside the invented condition (**original line not deleted**); `DATA GAP` re-diagnosis. Protected by `AC-B-APPEND`. |
| 8 | `docs/security-audit-v2.19.6.md` | 4 | ANNOTATE | additive | `LA-03` | `S-A3`/`S-A9`/`S-A10` closed-by-v2.19.7. Protected by `AC-B-APPEND`. |
| 9 | `docs/qa-report-v2.19.6.md` | 4 | ANNOTATE | additive | `LA-03` | Same finding IDs, second location. Protected by `AC-B-APPEND`. |
| 10 | `docs/owner-tasks.md` | 4 | EDIT + ADD | additive | `AC-A2`, `AC-E2`, `AC-E3`, `AC-E5-NC`, `LA-08` | GUILDSKILLS status → literal string; **new** ONESKILL row; travisvn two-part reword; claudepluginhub owner flag; attestation slot. |
| 11 | `.cowork-allowlist.json` | 4 | EDIT `reason` **prose only** | ~1 line | `AC-B5-2`, `AC-B5-TIER` | **Both** stale citations removed. `AC-B5-TIER` projection MUST be sha256-identical base vs head. |
| 12 | `CHANGELOG.md` | 4 | INSERT ×3 | additive | `AC-C1`, `AC-C2` | `## [2.0.1]` between `[2.0.2]` and `[2.0.0]`; two `> **Release surface:**` notes; `## Release surface` preamble subsection. Protected by `AC-B-APPEND` (an insertion reporting deletions is a rewrite). |
| 13 | `docs/spec.md` | 4 | REPLACE placeholder in place | ±1 | `AC-A3` | `AC-OT3-2-DISPOSITION: PENDING-PHASE-4` → `DETERMINATE` / `INDETERMINATE`. **Invisible to `base..HEAD` numstat** — the line is introduced by this same cycle. See `AC-B-APPEND` measurement note. |
| 14 | `upstream-contribution/composiohq-awesome-claude-skills-submission.md` | 4 | CREATE | new | `AC-E1` | The **only** draft created. Never filed. |
| 15 | `VERSION` | 4 | `2.19.7` → `2.19.8` | ±1 | version bump | Repo convention; not append-only. |

**Files deliberately NOT touched, each with a named reason** (`audit-deletions-not-just-additions` — the protected set is diffed for *removals*, not only additions):

| Path | Why not |
|---|---|
| `.github/CODEOWNERS` | `AC-B-CODEOWNERS` / @security S12 — a row here flips the tier |
| `scripts/publish-release.sh` | @security S16 — neither run nor modified |
| `docs/architecture.md` §ADR-080 body | Append-only; the `:3187` correction goes **forward** into ADR-081, not in place |
| `docs/spec.md` v2.19.4 `AC-OT3-2` checkbox | Historical record; its `- [ ]` state was accurate then |
| `upstream-contribution/travisvn-*.md`, `claudepluginhub-*.md`, `guildskills-*.md` | `AC-E2` / `AC-E3` / `AC-E4` — `test ! -e` must hold |
| Any file under `/Users/macbookpro/The-Council/` | `AC-E-S8` |

### D.1 The pre-commit gate blocked the script, and the block is correct

Attempting to commit the four Phase-1 artifacts together produced:

```
COMMIT BLOCKED: Pipeline gate not passed
BLOCKED: Phase 3 (User Gate) has no status recorded.
Staged implementation files require Phase 3 (User Gate) APPROVED.
```

**Diagnosed at the hook rather than guessed.** `.git/hooks/pre-commit` classifies staged paths with a `case` statement: `docs/*|tests/*|.claude/projects/*|.claude/scratchpad.md|docs/pipeline.md` are early-phase outputs allowed without Phase 3; **everything else sets `HAS_IMPL_FILES=true`**. `scripts/verify-ledger-annotations.sh` is the sole trigger — the three `docs/` artifacts pass unconditionally.

**Resolution: unstage the script, commit the docs, do not route around the gate.** The script stays on disk **untracked** until Phase 4. This is not a workaround, it is the gate's designed outcome: a `scripts/*.sh` file is implementation, implementation lands post-gate, and the pipeline is right that a Phase-1 agent should not be committing executables to a registered project. Writing it to a different path to dodge the `case` statement, or committing it as a `docs/` file, would be tunnelling — the specific failure mode this repo has already recorded once (v2.19.7 Phase 1, where @architect hit a guard block and **correctly refused to route around it**).

**Nothing evidentiary is lost by the deferral.** The value of writing it at Phase 1 was the RED proof against the un-annotated tree, and that proof is **already captured above with its exact output**. The artifact that must be durable is the evidence, not the file's git status.

**Handoff, explicit:** `scripts/verify-ledger-annotations.sh` exists at `/Users/macbookpro/claude-cowork-config/scripts/verify-ledger-annotations.sh`, mode `0755`, 13,715 bytes, untracked on `release/v2.19.8-polish-the-carryovers`. It is the **first** thing @dev commits at Phase 4, before any annotation is written, so build-order step ① is preserved. A `git clean` before then destroys it — @dev re-derives it from §C if that happens, and the anchor table in §C.2 plus the structure in §C.3 are sufficient to do so.

**Why the script was written at Phase 1 rather than Phase 4.** Step ① of the build order is "prove the verifier RED against the un-annotated tree." That proof is only available **before** the annotations exist — once Phase 4 writes them, the un-annotated tree is gone and the RED can never be observed again except against a reconstructed fixture. Writing the verifier at Phase 4 would mean its firing controls were demonstrated against a fixture rather than against production state, which is the precise substitution `Production-Artifact Validation` exists to forbid. The v2.19.7 precedent is direct: the orphan check was built **first** because a forward-only check structurally cannot prove a deletion. `@dev` still owns Phase-4 refinement — adding anchors is expected; loosening or deleting one is a Phase-5 finding, not a fix.

**Build order (binding).** ① ✅ `scripts/verify-ledger-annotations.sh`, proven RED against the un-annotated tree (below) → ② annotations (rows 6–12) → ③ re-run to GREEN → ④ CI wiring (row 5) → ⑤ Scope A research + row 13 → ⑥ Scope E draft (row 14) → ⑦ `VERSION`.

### Controls demonstrated at Phase 1 (not asserted — run, with output)

| Control | Command | Result | Meaning |
|---|---|---|---|
| Verifier fires | `bash scripts/verify-ledger-annotations.sh` | **exit 1** — 13 PASS / 6 RED; REDs are `LA-04c`, `LA-05c`, `LA-08`, `LA-09`, `LA-10a`, `LA-10b` | Every RED is a Phase-4 deliverable. The RED set **is** the Phase-4 checklist; when it empties, Scope B/C are done. |
| `LA-05c` widened NC fires | inside the run above | RED — `Expected exactly 0 … got 1` in `.cowork-allowlist.json` | The **widened** control catches the real defect today. The Phase-0 narrow form would also have gone green after a half-repair; this one cannot. |
| Live probe executes | Section 2 | `LP-01 EXECUTED at 2026-08-09T11:55:35Z`, full JSON recorded | Pass condition is *executed + timestamped*, never *reproduces*. A 200 was returned and recorded; `require_code_owner_reviews: false` and `required_approving_review_count: 0` are **recorded facts, not assertions** (OT-7 step 2 still open). |
| `AC-B5-TIER` positive leg | projection of the **prose-only** edit | `e973f987…` — **identical to base** | The Phase-4 edit as planned does not move the projection. The Tier-B claim is demonstrated under the actual change, not argued. |
| `AC-B5-TIER` **firing** NC | projection of a fixture with `marketing/nexus-strategy.md` → `.mc` | `5fb8ed0b…` — **different** | A single character in one `blocked_files[].path` moves the sha256. The falsifier can fail. |
| `AC-B-APPEND` | `git diff --numstat` over the 7 protected files | `492 0` (`docs/spec.md`), `76 0` (`docs/architecture.md`), no other rows | **Zero deletions** across the protected set at Phase 1. |
| ShellCheck clean | `shellcheck scripts/verify-ledger-annotations.sh` | **exit 0**, 0 findings | First run reported 8 × `SC2295` (info) on the `${US}` field splitting. Fixed at Phase 1 rather than handed to @dev: this repo's bar is *ShellCheck 0 findings* (v2.19.7 precedent), and a tolerated info is how a real finding hides. Verifier behaviour re-confirmed byte-for-byte identical after the fix — same exit 1, same 13/6 split, same six IDs. |

**Expected `AC-B5-TIER` values, for @dev and @qa — do not recompute the base from memory.**
Base (`c8342d7`) and required head value: `e973f98739d46e3d42b8cbb5567872794d270276eff6f77f7ac547972f1ff44d`.
The NC fixture must produce something **other** than that; the observed value for the documented one-character fixture is `5fb8ed0b629df38f9de2077dc6cb2e2e2350dafc091c183587b1f76dbb442824`. If the head projection is anything but the first value, **Tier A snaps back and a GCS is owed before merge.**

**Pre-state capture (`AC-C3-CAPTURE`), executed at ① and recorded in the PR:**

```
git rev-parse HEAD                                       # the base for every numstat
gh release view v2.0.1 --json body -q .body | shasum -a 256
gh release view v1.0.0        # expect: not found
gh release view v1.1.1        # expect: not found
git ls-remote --tags origin v1.0.0    # expect: empty
git ls-remote --tags origin v1.1.1    # expect: empty
git show <base>:.cowork-allowlist.json | jq -S '<AC-B5-TIER projection>' | shasum -a 256
```

Baseline already captured at `c8342d7`: `v2.0.1` body sha256 `01ba4719c80b6fe911b091a7c05124b64eeece964e09c058ef8f9805daca546b` (empty body); both other tags absent locally and on origin. **Without this capture the Phase-5 NCs are unrunnable** — "identical before and after" has no *before*.

---

## §E — Anti-Pattern Detection

> *ISO 15288 — Technical: Design Definition (verification of the design itself).*

| # | Anti-pattern | Finding |
|---|---|---|
| 1 | God Class/Module | **CLEAR.** One script, one responsibility (anchors resolve), ~150 lines. |
| 2 | Circular Dependencies | **CLEAR.** The verifier reads docs; no doc reads the verifier. |
| 3 | Leaky Abstraction | **CLEAR.** `--repo-root` is the only seam and is not passed by the real call site. |
| 4 | Premature Optimization | **CLEAR.** |
| 5 | Over-Engineering | **FLAGGED, then argued down.** Twelve anchors in a bash script to verify eight documentation annotations is on the edge. Kept because the defect class is *rot over time*, not *error at write time* — the value is entirely in re-running it on future PRs, which is also why `AC-B-VERIFY-CI` is not optional. A verifier that runs once would be over-engineering; one that runs on every PR is the control. |
| 6 | Tight Coupling | **CLEAR.** |
| 7 | Missing Separation of Concerns | **CLEAR — and structurally enforced.** Section 1 (static, offline, reproducible) is separated from Section 2 (live probes, timestamp-recorded) precisely because merging them would give the probe section's non-reproducibility to the static section. |
| 8 | N+1 Query | **CLEAR.** One `gh api` call total. |
| 9 | Destructive Migration | **CLEAR, and it is the cycle's central constraint.** Zero deletions (`AC-B-APPEND` over 7 files), zero live Release writes, zero tag pushes (`AC-C3` over 3 tags), zero Council-side writes (`AC-E-S8`). |
| 10 | SoS Interface Discontinuity | **N/A** — single-project design; `parents: []`. |
| 11 | Cross-Project Tight Coupling | **FLAGGED, INFO.** `ot3-catalog-research-2026-08-02.md` is a Council-side absolute path baked into the spec (C-6). It is a genuine cross-repo coupling and it *will* break if the Council path moves. Accepted: it is a read-only research input consumed once at Phase 4, not a runtime dependency, and copying it into the target repo would import Council-side content this repo has no reason to carry. **Named, not hidden** — if Scope A ever recurs, copy the gate-time block in rather than re-citing the path. |

**One recurring defect, recorded because it now has three instances in one cycle:** an AC whose verification command was never run against the artifact it names (`CHANGELOG.md:1038` at 0.D; `AC-A3` and `AC-B5-2` at Phase 1). Two of the three were caught only by running the command. This is `docs/patterns.md`'s *authoritative-artifact-prescribes-defect* shape at WATCH 2/3 — @qa should evaluate promotion at Phase 8, on **cycle** count, not on these three sub-instances (the v2.19.7 precedent for declining to inflate a WATCH on sub-occurrences applies directly).

---

## §F — What I did not decide

> *ISO 15288 — Technical Management: Decision Management (boundaries).*

- **Branch protection / required status checks** — owner-held, `OT-7` step 2. `ledger-annotations` is deliberately not proposed as a required check.
- **Whether to file anything upstream** — owner-held under OT-3. Phase 4 drafts one file and files nothing.
- **The `requires_review` zero-reader claim** (@security S14) — carried as `CF-v2.19.8-A`. Fixing it is a structural edit and would flip the tier.
- **The two CI run-ID pairs** (Scope B item 6) — different identifier spaces; **not** re-resolved by me. @dev resolves them live at Phase 4 and pastes the output. Recorded as a stated limit rather than papered over.
