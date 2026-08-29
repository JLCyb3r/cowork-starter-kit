# Carry-Forwards — the single visible register

**Created:** 2026-08-28T12:39:25Z · **Cycle:** `plan-2026-08-27-v3-engine` · **Base:** `ff0c44c`, VERSION `2.19.13`
**Authority:** ADR-093. This register is a **derived, regenerable view — never a second authority.** Every row
cites the surface that owns it. **Where this register and its source surface disagree, the source wins and
this file is regenerated** — with one narrow exception recorded at §K. Do not close an item here; close it at
its source and re-derive.

> **PLACEMENT IS A SECURITY DECISION, NOT A FILING ONE — read before moving this file.**
> This register lives under `docs/internal/` deliberately (Phase 2 finding **S1**, CRITICAL). It aggregates
> rows sourced from the export-ignored report families, and an aggregate is not merely the sum of its
> sources: it distils scattered reports into one ranked list of what is still broken and unowned. The
> directory-prefix `export-ignore` on `docs/internal/` is the layer that demonstrably works —
> **re-verified this cycle by `git archive HEAD | tar -tf -`: 419 entries, 0 of them under
> `docs/internal/`, against 19 top-level `docs/*.md` files that do ship.**
>
> **Verify placement with `git archive`, never with `git check-attr`.** `check-attr` returns `unspecified`
> for a file covered by a *directory-prefix* rule and reads as though no control applies. It nearly
> produced a false all-clear this cycle.
>
> **What this placement does NOT do — stated so nobody over-reads it.** This repository is **PUBLIC**
> (`gh repo view` → `"visibility":"PUBLIC"`, checked this session). `export-ignore` withholds a file from
> the **release archive**; it does not withhold it from `git clone` or the GitHub web UI. Relocation
> therefore restores **parity with the 14 internal reports already handled this way** — it does not make
> this content secret, and no decision should rest on a belief that it does. Because relocation alone does
> not reduce the aggregation itself, §G additionally carries **origin-document pointers instead of
> reproduced finding detail** (see §G's own note).

---

## Population definition — read this before quoting any number from this file

Three good-faith counts of "open carry-forwards" have been produced for this project (`~34` inherited,
`30/33` at Phase 0, `43` by an independent sweep). They disagreed because **none of them stated what it was
counting.** This register states it first.

### What counts as an id

**Admitted:** a string matching `CF-v<major>.<minor>[.<patch>]-<suffix>` that is **used as the identifier of
a specific tracked work item** — some document assigns it a description or a disposition.

**Excluded, with the reason:**

| Excluded class | Example | Why |
|---|---|---|
| Metasyntactic placeholder | `CF-v2.5-N` (`docs/internal/qa/qa-report-v2.5.md:218`, a section heading) | The suffix is a variable, not a label |
| Illustration inside proposal text | `CF-v2.5-ARCH-1`, `CF-v2.5-SEC-1`, `CF-v2.5-H` (`docs/spec.md:10843-10844`) | Written to demonstrate a *proposed* naming shape; names no actual item |

**Known blind spot, stated rather than hidden.** An id written only in **elided** form — prefix omitted, as
`` `CF-v2.19.12-PERMITSHAPE`, `-AC7-CI` `` at `docs/spec.md:10534` — is **invisible to any `CF-`-anchored
sweep by construction**. One such id exists (`CF-v2.19.12-AC7-CI`). It is on this register because it was
found by *reading*, not by sweeping. No census can be trusted to have found others of its kind. ADR-094
§Decision (3)'s forward-only citation rule exists to stop new ones appearing.

**Ids are not items.** The census counts distinct *strings*; this register counts distinct *work items*.
Before this cycle those numbers differed by exactly 5, because five ids each named two unrelated items
(ADR-094). After the ARCH renumbering they no longer differ.

### The numbers this definition produces

| Measurement | Value | How measured |
|---|---|---|
| Distinct id strings, raw, at `ff0c44c` | **40** | `/usr/bin/grep -rohE` with the pattern above over `docs/`, `sort -u` |
| …minus the placeholder class | **39** | 40 − `CF-v2.5-N` |
| Distinct id strings, raw, working tree at Phase 0 close | **43** | same regex, same scope, **after** the Phase-0 document landed |
| …minus placeholder + illustrations | **39** | 43 − `CF-v2.5-N` − 3 illustrations |
| Distinct id strings, raw, after this cycle's Phase-1 edits | **49** | same regex; +5 `CF-v2.5-ARCH-*`, +1 `CF-v2.19.12-AC7-CI` now written in full for the first time |
| …minus placeholder + illustrations | **45** | the current real-id population |
| **Genuinely open work items, strict** | **42** | the table below. Re-derived by summing the ten lettered subsections independently: **8+6+3+2+5+2+6+5+2+3 = 42**, and cross-checked against the ten section headings' own declared counts, which sum to the same 42 |
| **Genuinely open work items, broad** | **45** | strict + 3 `docs/owner-tasks.md` "tracked candidates (no action forced yet)" |

### Reconciling 43 against 39 — both were right, and the stated hypothesis was wrong

The open discrepancy entering Phase 1 was an independent sweep returning **43** where Phase 0 reported **39**,
with the working hypothesis that *"the two regexes admit different things."*

**That hypothesis is false, and was falsified rather than argued away.** Running Phase 0's **own** regex
reproduces **43** in the working tree and **40** at `HEAD`. It is the same regex in both cases. The delta is
three strings — `CF-v2.5-ARCH-1`, `CF-v2.5-SEC-1`, `CF-v2.5-H` — **introduced by the Phase-0 document itself**,
as illustrations inside its own proposal table at `docs/spec.md:10843-10844`.

So the two numbers measured **the same population at different times**, and the distinction that reconciles
them is **mention versus use**, not regex scope. `39` is correct for the real-id population at both points.
Neither number was adopted over the other; both were re-run.

### Where this register's count departs from Phase 0's

Phase 0 reported **30 strict / 33 broad**. Re-running the count produced **38 / 41** at Phase 1. The
Phase-1 delta against Phase 0 was **8 items across three classes, all of them omissions rather than
disagreements** — every item Phase 0 *did* count was verified and retained. Later phases of this same cycle
opened 4 more: 2 at Phase 2 and 1 at Phase 5 (all §J), plus 1 at Phase 6 (`plan-v3-engine-REGISTER-AGGREGATION`,
in §A, since its home is `docs/risk-register.md`). **Current: 42 strict / 45 broad.**

| Missed class | Count | Why it was missed |
|---|---|---|
| The entire `CF-v2.5-ARCH-*` series (architecture side) | 5 | Phase 0 counted only the security/QA side of the collided id-space. The owner ruling then established that **4 of these 5 are live inputs to this very cycle**, 2 hard-verified still-unfixed at `ff0c44c` |
| `CF-v2.4-D`, `CF-v2.4-E` | 2 | The whole `CF-v2.4-*` family is absent from Phase 0's disposition table. Five of its seven members are genuinely closed; these two never were |
| `CF-v2.19.12-AC7-CI` | 1 | Written only in elided form — invisible to every sweep, including Phase 0's |

**Coincidence warning:** this register's **strict 42** and Phase 0's **broad 33** are different measurements,
and its strict 33-vs-broad-36 arithmetic is not the same arithmetic as Phase 0's 30-vs-33. Do not treat any
two of these numbers as confirming each other because they are close. That is the exact error that let "~34"
look plausible for three cycles.

---

## The register — 42 strict open items

Status vocabulary: **OPEN** (actionable, unowned) · **OPEN-DEFERRED** (actionable, explicitly deferred with a
named target) · **ACCEPTED** (risk knowingly carried, no work planned) · **ORPHANED** (no surface has
dispositioned it in 3+ cycles).

### A. `docs/risk-register.md` open rows (8)

| Id | What it is | Origin | Recorded at | Status | Disposition |
|---|---|---|---|---|---|
| `v2.20-CARRY-1` | The deterministic pattern-scan covers `## Example` sections only; structurally insufficient once v2.20 accepts untrusted community content | v2.18.0 Phase 6 | `docs/risk-register.md:7` | OPEN | Binding on v2.20's own `/spec`. Not a v3.0 dependency |
| `SF-2` | Class-2-before-Class-1 execution ordering when a self-integrity check and an engine-file write could both apply to the same target | v2.19.0 Phase 6 (`docs/internal/security/security-audit-v2.19.0.md:34,53`) | `docs/risk-register.md:8` | OPEN | **MATURES THIS CYCLE.** Accepted as INFO *only because* `self-upgrade` had no live target; v3.0 gives it one. Answered structurally by ADR-095 D6 — Class-2 checks run against the staging area before an atomic rename, which cannot interleave |
| `SF-3` | No standing re-check that an installed skill's on-disk bytes still match the registry `sha256` | v2.19.0 Phase 6 | `docs/risk-register.md:9` | OPEN | Named in ADR-095 §Maturation Path (b) as a hub-boundary item — a space card attestation would discharge it |
| `SF-4` | The migration-provenance log is tamper-*resistant* (append-only, deny-listed) but not tamper-*evident* (no hash-chaining) | v2.19.0 Phase 6 | `docs/risk-register.md:10` | OPEN | Named in ADR-095 §Maturation Path (c). First real consumer is the v3.x hub |
| `v2.19.5-CODEOWNERS-1` | No enforced review gate over PRs touching supply-chain files; branch protection requires 0 approvals and 0 checks | v2.19.5 Phase 2/3, owner-accepted at the gate | `docs/risk-register.md:11` | OPEN | Binding until `OT-7` step 2 lands. Needs owner-level repo Settings access no pipeline agent holds |
| `v2.19.9-SKILLSTUDIO-TARGET` | `skill-studio` step 8's `CLAUDE.md` write: benefit premise falsified (ADR-082), cost unchanged; retained on "no third target" | v2.19.9 Phase 1 (ADR-082/083) | `docs/risk-register.md:14` | OPEN | Closes on either a genuinely auto-applying instruction target, or a determinate answer on workspace-file read reliability |
| `CF-v2.19.13-DECISION3-RESIDUE` | 3 remaining `§Decision (3)` mis-pointer loci, all in `export-ignore`d append-only surface | v2.19.13 Phase 4 | `docs/risk-register.md:17` | OPEN | Named, not scheduled. This row *is* the reachability discharge. Retirement path: ADR-092 §Maturation Path (b) |
| `plan-v3-engine-REGISTER-AGGREGATION` | The carry-forward register aggregates open, unowned items sourced from the export-ignored report families; aggregation is a distinct exposure from its sources, and relocation plus pointer-substitution reduce it without eliminating it in a public clone | Phase 2, this cycle (`@security` S1, CRITICAL as raised; Phase 6 disposition residual WARNING) | `docs/risk-register.md` (row added this cycle) | OPEN — accepted, carried | **Owner: repository owner** — every closing condition needs a decision no pipeline agent can take. Closes only on (a) the repository becoming private, (b) `docs/internal/` ceasing to be tracked in git, or (c) removing the register's security/QA section outright. **Relocation and pointer-substitution do NOT close it** — those are the mitigations already applied and counted |

> **Repaired this cycle (ADR-093 §Decision (3)):** `AC-PUB-10` (`:12`) and `CF-v2.19.6-A` (`:15`) printed
> `**OPEN**` while being declared CLOSED at `:38-44` and `:60-68` of the same file. Their Status cells now read
> `CLOSED (v2.19.8)` with the original status text retained verbatim; the Description, Accepted-condition and
> Source cells are byte-identical to the pre-cycle state, verified field-by-field. **The restored property is
> an invariant, not a total: no row printing `**OPEN**` is contradicted by a `CLOSED` declaration elsewhere in
> the same file.** That invariant is what the repair restored, and it is what a future reader should re-derive
> — it survives any legitimate new row, which a pinned total does not. The count moved from 7 to 8 later in
> this same cycle when `plan-v3-engine-REGISTER-AGGREGATION` was added as a genuinely-new accepted risk; that
> is an increase, not a regression, and §A's heading tracks it.
>
> **A distinction worth keeping, because an earlier draft of this file got it wrong in both directions.** A
> *total asserted as a claim* — "the OPEN count is 7", restated in a second document — goes stale silently and
> still reads as authoritative; that is the failure this cycle corrected three times (`SECGATE-B1`, the HLD
> line count, ADR-093's own Consequences). **A per-section heading count is a different object: it is a
> checksum**, sitting directly above the rows it counts, so a disagreement between the two is *detectable by
> anyone who reads the section*. The two must be reconciled, never dropped. **This section is the proof:** its
> heading read `(7)` while `docs/risk-register.md` had 8 OPEN rows, and it was that visible disagreement
> between heading and source — not any narrative — that surfaced the missing census row at Phase 7.

### B. `docs/owner-tasks.md` Ledger — open rows (6)

| Id | What it is | Origin | Recorded at | Status | Disposition |
|---|---|---|---|---|---|
| `OT-1` | Post the public announcement (LinkedIn + Telegram, copy approved) | v2.19.3 | `docs/owner-tasks.md:17` | OPEN | Gates the v2.20 intake demand-clock and all organic discovery signal. **Age column understated** — reads "2 releases" against roughly 10 |
| `OT-3` | Catalog submissions — 3 targets researched, 0 submitted | v2.19.3 | `docs/owner-tasks.md:19` | OPEN | Drafts pending |
| `OT-4` | Review/merge any sync-agency PR the repaired cron opens | (unnumbered — "arms when Rung 1 ships") | `docs/owner-tasks.md:20` | OPEN | **STATUS TEXT IS STALE.** Reads "dormant until Rung 1 ships"; the sync-agency path was restored at **v2.19.5** and we are at v2.19.13. Whether the task is open is a separate question from whether its gating text is still true — it is not |
| `OT-6` | `@ux` F8 — b2/b6 telegraphic dialogue tone | v2.19.3 | `docs/owner-tasks.md:22` | OPEN-DEFERRED | Milestone-coupled to v2.21's voice-pass AC (`AC-BRIDGE-5`) |
| `OT-7` | Enable branch-protection review gate requiring CODEOWNERS approval on supply-chain files | v2.19.5 | `docs/owner-tasks.md:23` | OPEN | Step 1 (re-point rows to `@jmlozano1990`) done at v2.19.5; **step 2 open**. Blocks closing `v2.19.5-CODEOWNERS-1` |
| `OT-8` | Confirm the smoke-test scorecard is current **before running Scope A** (`v2.19.6` "Publish What Shipped") | v2.19.6 | `docs/owner-tasks.md:24` | OPEN | **STATUS TEXT IS STALE.** The gating event — Scope A's three publishes — shipped long ago; v2.19.7 through v2.19.13 have all since published. Age column reads "0 releases" against 7 |

### C. `CF-v2.19.13-*` family — open, not yet promoted to `docs/risk-register.md` (3)

| Id | What it is | Origin | Recorded at | Status | Disposition |
|---|---|---|---|---|---|
| `CF-v2.19.13-CITATION-CENSUS` | Full census of the citation form across all shipping files, deferred on patch-cycle-size grounds; corrected denominator is 4 | v2.19.13 | `docs/retro.md:292` | OPEN | Unowned |
| `CF-v2.19.13-MEMBERSHIP-NC` | `SELF_MEMBER` diagnostic has no committed negative control (no false-GREEN currently possible) | v2.19.13 | `docs/retro.md:293` | OPEN | Correctly scoped; unowned |
| `CF-v2.19.13-GITHUB-CLASSA` | Two live Class-A pointers (`.github/CODEOWNERS:8`, `.github/workflows/release-assets.yml:4`) remain broken | v2.19.13 | `docs/retro.md:294` | OPEN | Deferred by decision. **Tier A to fix** — touches `.github/` |

### D. Pre-existing residuals, unscheduled (2)

| Id | What it is | Origin | Recorded at | Status | Disposition |
|---|---|---|---|---|---|
| `S10` | `CONTRIBUTING.md:39`'s malformed self-citation is structurally invisible to the extraction regex by construction | v2.19.11 security audit | `docs/retro.md:298` | ACCEPTED | Not scheduled; maintainer surface only |
| `A15` | The registry-row-count pin is defeatable by a compensating add/remove pair | v2.19.13 | `docs/retro.md:299` | OPEN-DEFERRED | Survives into the next row-adding cycle. **v3.0 adds rows — this is the cycle it arms** |

### E. `CF-v2.19.12-*` family — real, never queued (5)

Recovered at v2.19.13 Phase 0, dispositioned in `docs/spec.md:10521-10537`, and **dropped again** — "Not in
queue" and "Later cycle" both name a disposition without naming a target. This is the family's **third** silent
drop.

| Id | What it is | Origin | Recorded at | Status | Disposition |
|---|---|---|---|---|---|
| `CF-v2.19.12-A` | — | v2.19.12 | `docs/spec.md:10537` | ORPHANED | "Not in queue — Real, not queued" |
| `CF-v2.19.12-D` | — | v2.19.12 | `docs/spec.md:10537` | ORPHANED | "Not in queue — Real, not queued" |
| `CF-v2.19.12-GATTR` | — | v2.19.12 | `docs/spec.md:10537` | ORPHANED | "Not in queue — Real, not queued" |
| `CF-v2.19.12-PERMITSHAPE` | — | v2.19.12 | `docs/spec.md:10534` | ORPHANED | "Later cycle — No executable host / would trip its own guard" |
| `CF-v2.19.12-AC7-CI` | **Never defined anywhere.** The id has exactly one occurrence in the corpus, and it is a deferral | v2.19.12 | `docs/spec.md:10534`, elided as `-AC7-CI` | ORPHANED | **Counted by no prior census** — see the blind-spot note above. It was deferred before it was ever written down. Its content must be reconstructed before it can be worked |

### F. Older singletons (2)

| Id | What it is | Origin | Recorded at | Status | Disposition |
|---|---|---|---|---|---|
| `CF-v2.19.8-A` | The `requires_review` zero-reader false-safety claim in `.cowork-allowlist.json`'s notes | v2.19.8 (@security S14) | `docs/design-v2.19.8.md:690` | OPEN | Deferred every cycle since v2.19.8 — fixing it is a structural edit that flips the cycle's tier |
| `CF-v2.19.5-A` | `files[].sha256` has zero readers (write-only data) | v2.19.5 | `docs/retro.md:2238` | ORPHANED | Never closed, never re-mentioned on any surface since the v2.19.5 retro |

### G. `CF-v2.5-*` security/QA series — orphaned since v2.6.0 (6)

**Last dispositioned `docs/internal/qa/qa-report-v2.6.0.md:270` (2026-05-11):** *"none applicable to v2.6.0
scope."* **No surface since names any of them.** A sweep of `scripts/`, `.github/`, `skills/` and `templates/`
for all six returns **zero** hits — nothing outside the paper trail shows any was ever addressed. Roughly 30
point releases. **This is the same dropped-ledger shape as §E, thirty releases older, and named in no brief.**

Cite these with their origin document (ADR-094 §Decision (3)) — the bare form is ambiguous for anything
written before 2026-08-28.

> **Why this section carries pointers instead of descriptions (S1 remedy, second layer).** Every row below
> names a **topic and a location**, not a finding's mechanism, its remediation status prose, or the reason it
> was accepted. That is deliberate. Six open, unowned security items reproduced in full, in one ranked list,
> is a materially different artifact from the same six scattered across an export-ignored report family —
> and this repository is public, so relocating the register out of the release archive (see the header note)
> reduces the archive exposure without reducing the aggregation. Applying ADR-094 §Decision (3)'s own
> forward-only rule — *cite an id with its origin document* — turns out to be the same move that fixes the
> aggregation: the pointer is what a maintainer needs, and the mechanism is what they should read at source.
>
> **The register's purpose survives this.** Openness, ownership and overdue status are what make an item
> visible, and all three are retained in full. What is removed is the standalone how-to.

All six originate at **v2.5 Phase 6** and are recorded in
**`docs/internal/security/security-audit-v2.5.md`** (`CF-v2.5-F` additionally at `:40,58,177,282`).

| Id | Topic (read the origin document for the finding itself) | Status | Disposition |
|---|---|---|---|
| `CF-v2.5-A` (security/QA) | Diagnostic-message precision on a tool-declaration parse path. Security property was preserved; the defect is user-visible text | ORPHANED | Unowned since v2.6.0 |
| `CF-v2.5-B` (security/QA) | Checkout-identity scoping on an opt-in local developer script | ORPHANED | Accepted at v2.5 as an opt-in trust model; never revisited |
| `CF-v2.5-D` (security/QA) | Account-hardening recommendation for outbound contribution | ORPHANED | Out-of-band; no owner assigned |
| `CF-v2.5-E` (security/QA) | Lint-sentinel hardening for a frontmatter-boundary parser | ORPHANED | Unowned since v2.6.0 |
| `CF-v2.5-F` (security/QA) | Upstream acknowledgement-window watch (60-day) | **CLOSED — CONDITION NEVER FIRED (v2.19.14)** | **Re-derived from ADR-097** (`docs/architecture.md`): the obligation was conditional — escalate to @pm only if PR #521 (`msitarzewski/agency-agents`) had no maintainer response by 2026-07-08 (`docs/internal/security/security-audit-v2.5.md:40,58,282`). PR #521 **merged 2026-06-04**, 34 days before the trigger and 26 days into the 60-day window. **The condition never occurred: no escalation was ever owed, and none was missed.** Original status text, retained verbatim: *"Stated escalation date 2026-07-08; **51 days past due** at this cycle's base (computed, not estimated)."* That arithmetic was correct and irrelevant — it measured days past a date without evaluating whether the date's condition had fired. The row's prior verdict (unaddressed status, no completion on record) is superseded by the above; it is not restated here as an assertion |
| `CF-v2.5-G` (security/QA) | Tool-vocabulary allow-list governance | ORPHANED | **Directly load-bearing on v3.0** — pairs with `CF-v2.5-ARCH-B`/`-ARCH-C` in §H. Should not ship v3.0 unaddressed |

### H. `CF-v2.5-ARCH-*` architecture series — live inputs to v3.0 (5)

**Renumbered this cycle from the bare `CF-v2.5-A`..`-E` form (ADR-094 §Decision (1)).** Counted by **no prior
census** — Phase 0 counted only the security/QA side of the collided id-space. The owner ruling then
established these are not history: 4 of 5 are live inputs to v3.0, and 2 were hard-verified still-unfixed at
`ff0c44c`.

| Id | What it is | Origin | Recorded at | Status | Disposition |
|---|---|---|---|---|---|
| `CF-v2.5-ARCH-A` | The backfill script is not shipped to users; a future cycle adding content outside `sync-agency.yml` must run its logic locally first | v2.5 Phase 1 | `docs/architecture.md` v2.5 carry-forwards section | OPEN | **Hard-verified at `ff0c44c`: `scripts/backfill-content-sha256.sh` is not on disk.** Still exactly the state described |
| `CF-v2.5-ARCH-B` | v3.0 `tools:` routing implementation — ADR-029 binds it declarative, never auto-translating | v2.5 Phase 1 | `docs/architecture.md` v2.5 carry-forwards section | OPEN | **v3.0 spec work.** Read ADR-029's forward-binding statement before designing it |
| `CF-v2.5-ARCH-C` | v3.0 multi-tool skill authoring — widening skills beyond `claude-code` needs explicit per-tool validation, methodology TBD in the v3.0 spec | v2.5 Phase 1 | `docs/architecture.md` v2.5 carry-forwards section | OPEN | **Hard-verified at `ff0c44c`: all shipped skills remain `tools: [claude-code]`.** Its stated resolution venue is this design arc |
| `CF-v2.5-ARCH-D` | F3 PR outcome evaluation — the v3.0 gate review reads the upstream PR's acknowledgement outcome | v2.5 Phase 1 | `docs/architecture.md` v2.5 carry-forwards section | OPEN | **v3.0 gate work — NOT discharged this cycle; only its rationale is corrected (ADR-097, `docs/architecture.md`).** Paired with `CF-v2.5-F` (security/QA) — that pairing's premise is now corrected: PR #521 merged **2026-06-04**, well inside its acknowledgement window, so there was no overdue escalation to pair against. Original status text, retained verbatim: *"v3.0 gate work. Paired with `CF-v2.5-F` (security/QA), which is 51 days overdue — the same upstream PR."* **Input recorded for the v3.0 gate's own evaluation, not performed here:** the contributed file survives upstream, renamed to `project-management/project-management-meeting-notes-specialist.md`, still present in `msitarzewski/agency-agents`. Whether a rename satisfies governance under ADR-030 is the gate's call |
| `CF-v2.5-ARCH-E` | `upstream-contribution/` directory governance as outbound contributions accumulate | v2.5 Phase 1 | `docs/architecture.md` v2.5 carry-forwards section | OPEN | Backlog; the only one of the five not a live v3.0 input |

### I. `CF-v2.4-*` family — counted by no prior census (2)

Five of this family's seven members are genuinely closed (`A`, `B`, `C`, `F`, `G` — verified at
`docs/spec.md:354-356` and `docs/internal/security/security-audit-v2.4.md:278`). **These two never were,** and
the family appears in no Phase-0 disposition table at all. They are the oldest open items in the project.

| Id | What it is | Origin | Recorded at | Status | Disposition |
|---|---|---|---|---|---|
| `CF-v2.4-D` | Selection-preset community PR contribution workflow — the secondary contribution model alongside skill PRs | v2.4 | `docs/spec.md:215,375`; `docs/retro.md:5306` | ORPHANED | Explicitly "re-deferred to v2.6+" at v2.5 and never picked up. **Overlaps v2.20 community intake** — fold it in there rather than reviving it standalone |
| `CF-v2.4-E` | LLM-based goal matching (judge goal-to-preset fit, beyond keyword match) | v2.4 | `docs/spec.md:216,377,1225`; `docs/retro.md:5307` | ORPHANED | Backlog with an activation condition — "keyword-match below 80% in field testing." **No field data has ever been gathered**, so the condition has never been evaluable. Gated on `OT-1` |

---

### J. Opened at Phase 2 and Phase 5 of this cycle (3)

The first two were raised by `@security` at Phase 2, the third by `@qa` at Phase 5, all against this design.
None is fixable inside a PURE-DOC cycle, and recording them here is the whole point of the register existing.

| Id | What it is | Origin | Recorded at | Status | Disposition |
|---|---|---|---|---|---|
| `CF-plan-v3-engine-EGRESS-PATTERN` | The release-archive egress gate's pattern requires a version suffix, so bare-named report files do not match it. **The pattern is only half the defect: all three of the gate's canaries are themselves versioned**, so its self-test exercises only the shape the pattern already matches and reports healthy while blind | Phase 2, this cycle (`@security` S4, confirmed by execution) | `docs/internal/security/security-review.md` S4 | OPEN | **Tier B — must NOT be fixed here.** The remedy edits `.github/workflows/`, which would re-classify this PURE-DOC cycle and pull a workflow change through a gate that never reviewed it. **Carry the canary with the pattern:** a pattern fix shipped without a *bare-named* fourth canary reproduces the check-that-cannot-fail and the next reviewer will read GREEN as evidence. Bare-named files are currently protected by the `docs/internal/` directory `export-ignore` **alone** — single-layer |
| `CF-plan-v3-engine-SECMEM-SCOPE` | `@security`'s own agent definition instructs it to maintain persistent memory under a path its own scope guard forbids it to write. It refused to tunnel around the guard and reported the conflict instead — the correct behaviour, and the reason this is a recorded finding rather than a silent guard bypass | Phase 2, this cycle (`@security`, self-reported) | `docs/internal/security/security-review.md` | OPEN — **NOT THIS REPOSITORY'S** | **Out of scope here; routing is the disposition.** The defect is in The-Council's own agent configuration, not in the Cowork kit — it belongs to the `self` slug and must be fixed there. It is recorded in this register **only so it is not lost at the cycle boundary**, which is the exact failure mode §E documents happening three times to one family. Close it here once the `self` slug has an owning cycle |
| `CF-plan-v3-engine-C1-AXIS3` | **ADR-095's C1 privilege-differential check carries TWO independent defects. They are orthogonal, and fixing either leaves the other live.** **Leg 1 — unextractable axis (`@qa`, Phase 5).** C1's three axes are (i) declared `tools:` frontmatter, (ii) deny-list membership, (iii) the write scope the seeded `CLAUDE.md` grants. Axis (iii) has **no mechanical-extraction procedure defined anywhere**, because `CLAUDE.md` in this kit is prose, not a schema. **Leg 2 — the failure criterion is fail-open on lost protections (`@security`, Phase 6).** C1 computes effective privilege as the **union** of the three axes and fails on **strict superset** (`docs/architecture.md` ADR-095 D1.3, C1). A superset test detects only monotone *increase* — but **deny-list membership is a protection, not a capability.** A child that *loses* deny-list membership yields a **smaller** union, so the test **passes** while the child is strictly less safe. Reachable exactly as ADR-061 exists to prevent: if the generated child emits its safety skill outside the `self-*` reserved prefix, or its `self-apply` prose omits the deny rule, that machinery becomes apply-writable in the child — invisibly to the leg's only security control. Same fail-open shape the ADR already guards one level up: D1.3's precondition covers a *skill* absent from the **parent**; nothing covers a *protection* absent from the **child** | Leg 1: Phase 5 (`@qa`). Leg 2: Phase 6 (`@security`) | `docs/internal/qa/qa-report.md`; `docs/internal/security/security-audit.md`; the check itself at `docs/architecture.md` ADR-095 D1.3 C1 | OPEN | **Owned by the v3.0 build cycle's Phase 1 — record it there before Phase 2, do not rediscover it.** **Leg 2's remedy is structural and is the one that must land first: split the terms. Capabilities tested for INCREASE, protections tested for DECREASE, fail on either.** A single union under a single superset test cannot express both directions, so no amount of axis-(iii) extraction precision fixes it. **Leg 1's remedy:** define a parseable write-scope schema that `CLAUDE.md` generation emits alongside the prose, making axis (iii) extractable. This is the same undefined-extraction shape C5 was renamed and re-specified to close, recurring one level down inside the check ADR-095 names as load-bearing — so C5's remedy is the precedent. **A previously-listed option — 'narrow C1 to axes (i) and (ii)' — is STRUCK, not deferred.** It was written before Leg 2 was known, and it is not merely weaker but *wrong*: axis (ii) IS the protection axis, so narrowing to (i)+(ii) retains the exact term whose loss the superset test cannot see. It would have read as a legitimate shortcut to a build cycle that had not seen Leg 2. **Also NOT acceptable:** leaving axis (iii) as prose interpreted at check time — *undefined is not fail-closed* (`v2.19.11-PULL-ROW-1`), and a fail-open axis inside a fail-closed check silently weakens the whole check |

> **Axis-by-axis extractability, measured rather than assumed — read this before designing the Leg 1 remedy.**
> An earlier draft of the row above stated that axes (i) and (ii) are "both backed by structured artifacts."
> **That is false for axis (ii), and a build cycle acting on it will hunt for a schema that does not exist.**
>
> - **Axis (i) — `tools:` — genuinely structured. Confirmed.** Across all 29 shipped skills there are exactly
>   **four** frontmatter keys repo-wide: `name`, `description`, `tools`, `trigger_examples`. Negative-controlled:
>   each key returns a count of **29**, so the extractor demonstrably read every file rather than silently
>   skipping some — a count of 29 keys over 29 files is only meaningful because no file is missing one.
> - **Axis (ii) — deny-list membership — NOT structured.** There is **no deny-list frontmatter key on any of
>   the 29 skills** (`grep` for `deny`/`denylist`/`deny_list`/`denied`/`blocked` as frontmatter keys returns
>   nothing). The authoritative deny-list is **body prose** at `skills/self-apply/SKILL.md:53`, under the
>   heading *"The write-channel allow-list — deny-first"* at `:51`.
> - **What rescues axis (ii) anyway:** per-skill membership reduces to the **`self-*` reserved-prefix glob**
>   (`skills/self-apply/SKILL.md:55`, "Reserved prefix (v2.19, MF-1a)"; `AC-APPLY-3`; ADR-061; ADR-071). So the
>   axis is *decidable from a slug* without parsing the prose — which is why the conclusion "axis (ii) is
>   checkable today" stands even though the stated ground did not.
>
> **The correction matters beyond pedantry, and it is why Leg 2 exists.** The very thing that makes axis (ii)
> checkable — a glob over a naming convention — is also what makes it *losable*: a child whose safety skill is
> emitted under a different name simply falls out of the glob. A protection that is decided by a naming
> convention is exactly the kind that a superset test cannot see disappear.

---

## §K — the one narrow exception to "the source wins"

ADR-093 §Decision (1) makes the source authoritative wherever it and this register disagree. Phase 2 finding
**S10** found the one case where that rule would propagate an error rather than correct one, and the exception
is deliberately mechanical so it cannot be stretched:

> **Where a source's citation names a path that does not resolve (`test -e` fails), this register keeps the
> resolving path.** The discrepancy is then a repair owed *at the source*, not a disagreement about substance.

**It covers location only.** Status, description and disposition are never in scope — for those the source
always wins, without exception.

**Currently dormant, and it should be kept that way.** `docs/risk-register.md` carried 5 citations to report
paths that have not existed since v2.19.12 while this register cited the same sources correctly; applied
literally, the authority rule would have overwritten the correct paths with the dead ones on every
regeneration. All 5 were repaired at the source this cycle, so the rule and the register now agree.

---

## Broad count — the 3 additional "tracked candidates" (45 total)

`docs/owner-tasks.md`'s own schema separates these from its actionable Ledger — they are open ideas, not
deferred obligations. Included here only to make the broad number reproducible.

| Id | What it is | Recorded at | Status |
|---|---|---|---|
| `NAMING` | Tracked, no action; see internal competitive analysis | `docs/owner-tasks.md:28` | OPEN (tracked, no action) |
| `AGENCY-AGENTS PERSONA CONVERSION` | Evaluate converting 73 vetted non-engineering vendored personas into pool skills | `docs/owner-tasks.md:29` | OPEN (tracked, no action). **Also listed in `docs/roadmap.md`'s `## Later` — same item, not double-counted** |
| `ONESKILL KIT-VS-SKILL FIT` | Same class of open question as GuildSkills | `docs/owner-tasks.md:31` | OPEN (tracked, no action) |

---

## Deliberately excluded, with reasons

| Excluded | Count | Why |
|---|---|---|
| `docs/patterns.md` rows | 58 (8 BINDING, 8 at WATCH 2/3) | A structurally different ledger. Patterns are *recurring failure shapes*, not deferred work items — nobody "closes" a pattern by shipping a fix. Merging the ledgers would conflate two closure semantics |
| Verified-closed `CF-` ids | — | `CF-v2.19-A/B`, `CF-v2.3.1-A`, `CF-v2.19.3-A`, `CF-v2.19.5-B/C/D/E/F`, `CF-v2.19.6-A`, `AC-PUB-10`, `CF-v2.19.11-A/B`, `CF-v2.19.12-B/C/E`, `CF-v2.4-A/B/C/F/G`, `v2.19.11-PULL-ROW-1`, `v2.19.7-LEDGER-FP` — each has an explicit closure no later surface contradicts |
| `v2.19.11-PULL-ROW-1`'s two residuals | 2 | Model drift and per-slug variance are **named but not tracked as their own items** in the row that closed. Held to `docs/risk-register.md`'s authoritative `CLOSED`; noted here so they are not lost, not counted as items |

---

## How to regenerate this register

1. Re-run the census: `/usr/bin/grep -rohE 'CF-v[0-9]+\.[0-9]+(\.[0-9]+)?-[A-Za-z0-9]+(-[A-Za-z0-9]+)*' docs/ | sort -u | wc -l`
   — **use `/usr/bin/grep` by absolute path.** The project's bare `grep` resolves to a `ugrep` shim that
   honours `.gitignore` and under-counts.
2. Subtract the excluded classes named above. State the population, always.
3. Read the source surfaces for status — `docs/risk-register.md`, `docs/owner-tasks.md`, `docs/retro.md`'s
   per-cycle sections, `docs/spec.md`'s "Out of Scope" tables, and the `docs/internal/` report families.
4. **The sweep will not find elided ids.** Read `docs/spec.md`'s deferral tables directly.
5. Where this file and a source disagree, **the source wins**. Regenerate; do not reconcile in place.
6. **Reconcile every section heading's declared count against the rows beneath it — the headings are a
   checksum, not decoration.** The strict total is derived by summing them, so a stale heading is not an
   unpinned count, it is a **wrong** one, and it silently corrupts the derivation. Two commands, and they
   must agree with each other and with step 7:

   ```
   # per-section actual row counts, and their sum
   awk '/^## The register/,/^## Broad count/' docs/internal/carry-forwards.md \
     | awk '/^### [A-Z]\./{sec=substr($2,1,1); next} /^\| `|^\| \*\*/{c[sec]++} \
            END{t=0; split("A B C D E F G H I J",k," "); \
                for(i=1;i<=10;i++){printf "%s=%d ", k[i], c[k[i]]; t+=c[k[i]]} \
                printf "| TOTAL=%d\n", t}'

   # the headings' own declared counts, summed
   grep -oE '^### [A-J]\..*\(([0-9]+)\)$' docs/internal/carry-forwards.md \
     | grep -oE '\([0-9]+\)$' | tr -d '()' | paste -sd+ - | bc
   ```

   **A disagreement between these two is a detected defect, not a formatting nit.** This is exactly how the
   Phase-7 census gap was found: §A's heading read `(7)` while `docs/risk-register.md` carried 8 rows
   printing `**OPEN**`, and the row for `plan-v3-engine-REGISTER-AGGREGATION` existed nowhere in any table.
7. **Cross-check §A against its source directly**, since §A is a mechanical census of one file rather than a
   judgement: `grep -c '\*\*OPEN\*\*' docs/risk-register.md` must equal §A's heading count and its row count.
   Enumerate the ids, do not just compare totals — **a count that matches by coincidence while the membership
   differs is the failure this step exists to catch**, and an extractor returning `0` rows is a vacuous pass,
   not a clean one. Verify the extractor found something before trusting that it found nothing wrong.
