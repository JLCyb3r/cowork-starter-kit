# QA Report — v2.19.4 "Rung 0: Announcement Prerequisites"

## Phase: 5
## Date: 2026-08-03T00:00:00Z
## Status: APPROVED WITH NOTES

## Scope Under Review

Chain: spec (append at `docs/spec.md:5590-5812`, 222 insertions / 0 deletions) → Phase 2 `/legal` (narrow, PASS WITH WARNINGS) → Phase 1 SKIPPED (no architecture surface) → gate APPROVED (build + AC-SOCIAL-5 ADJUST + OT-3 "check AI rules first") → Phase 4 `@dev` (uncommitted working tree, `main`, STANDARD/in-place, no worktree).

**Working tree at review time (re-derived, not accepted from narrative):**

```
 M CHANGELOG.md
 M README.md
 M VERSION
 M assets/setup-demo.svg
 M docs/roadmap.md
 M docs/spec.md
?? assets/social-preview-source.svg
?? assets/social-preview.png
?? docs/owner-tasks.md
```

Every AC below was re-run against these files directly — nothing here is accepted from `pipeline.md`'s Phase 4 narrative. (Phase 4's pipeline row was found showing `IN PROGRESS` at the start of this review despite the work being complete in the working tree; the orchestrator confirmed this was its own omission — the verification had been done, the status write had not — and corrected the row to DONE before this report was persisted. See closing note.)

---

## AC-by-AC Results

### Demo de-slop (AC-DEMO-1..8)

| AC | Verify | Result |
|---|---|---|
| AC-DEMO-1 | `grep -o '—' assets/setup-demo.svg \| wc -l` = **1** (≤2 ✓); title em-dash count = **0** (≤1 ✓). **Negative control, run against `git show HEAD:assets/setup-demo.svg`:** total = **12**, title = **2** — exact match to the spec's claimed pre-change numbers. | **PASS** |
| AC-DEMO-2 | `grep -c "<!-- Beat" assets/setup-demo.svg` = **10**, all in order (`Beat 1`…`Beat 10`). `git diff assets/setup-demo.svg` shows the edit is a pure text/comment-punctuation swap — zero `<g>`/`<rect>` structural lines touched. | **PASS** |
| AC-DEMO-3 | Human-judgment AC. Old title: *"...demo — describe your goal...15 minutes — then the workspace keeps evolving: it notices friction, proposes a fix you confirm, and offers skill content updates you approve, every change reversible and never silent"*. New title: identical content, em dashes → period/colon, capitalization adjusted. Rendered the actual SVG (`rsvg-convert`) and read it directly: 15-min goal-driven setup ✓, real skill slugs named (`voice-matching`, `anti-ai-slop`) ✓, notice→propose→confirm loop ✓, reversible/never-silent ✓. Substance is fully preserved — this is a punctuation edit, not a re-narration. | **PASS** |
| AC-DEMO-4 | Re-ran the `(width−72)/8.4` budget check programmatically against every `<text class="text{Assistant,User}">` line, mapped to its nearest preceding `<rect class="bubble...">`. **Dialogue line count is 21, not the spec's stated 17** — the spec number is stale (see Disposition below). All 21 lines fit their bubble with margin (worst case: 43/48.57 in beat 2). Full table reproduced in Findings. | **PASS** (spec's own AC number is stale — dispositioned, not blocking) |
| AC-DEMO-5 | `python3 -c "import xml.dom.minidom as m; m.parse(...)"` → exits 0, no exception. | **PASS** |
| AC-DEMO-6 | Positive: `grep -icE '<script\|<foreignObject\|on[a-z]+=\|xlink:href\|<image\|<use\|@import\|url\(http\|href="(https?:\|//\|data:\|file:)'` on the real file = **0**. **Negative control (run on a scratch copy under `/private/tmp/.../scratchpad/svg-test/`, never the repo file):** appended `<script>alert(1)</script>` → same grep = **1**, control fires. Confirmed the real file was not touched: `git status --short assets/setup-demo.svg` still shows only `M` (no staged/appended script), MD5 recorded pre/post scratch-test unchanged. | **PASS** |
| AC-DEMO-7 | `grep -c 'viewBox="0 0 800 1050"' assets/setup-demo.svg` = **1**; diff confirms the `<svg viewBox=...>` line is untouched (only the sibling `<title>` line on the same diff hunk changed). | **PASS** |
| AC-DEMO-8 | `grep -oE "<[a-zA-Z]+" assets/setup-demo.svg \| sort -u` → exactly `circle, g, line, rect, style, svg, text, title` (8 elements). Matches the AC's corrected vocabulary (the brief's original 7-element list omitting `line` was the right catch). | **PASS** |

### Social preview (AC-SOCIAL-1..5)

| AC | Verify | Result |
|---|---|---|
| AC-SOCIAL-1 | `file assets/social-preview.png` → PNG, **1280×640**, 8-bit RGB; size **56,042 bytes** (<1MB). Palette check — every color in `assets/social-preview-source.svg` traced by hand against `assets/setup-demo.svg`'s own `<style>` block and dot fills: `#8b8fa3`↔`.headerText`, `#e6ecff`↔`.textUser`, `#d7d9e6`↔`.textAssistant`, `#14141f`↔`.card`, `#23232f`↔`.bubbleAssistant`, `#8fd6a8`↔`.labelAssistant`, `#2b3a55`↔`.bubbleUser`, `#7ea6ff`↔`.labelUser`, `#ff5f56`/`#ffbd2e`/`#27c93f`↔ the three window-chrome dots. **Zero new colors introduced.** Rendered the PNG directly and confirmed it visually matches the demo's language (clean, on-brand, no overflow). | **PASS** |
| AC-SOCIAL-2 | Computed WCAG relative-luminance contrast for every text/background pairing in `assets/social-preview-source.svg` (8 `<text>` elements, 6 unique color pairs) using the standard sRGB formula: title `15.49:1`, tagline `13.01:1`, eyebrow/footer `5.70:1`, chip `#8fd6a8`/`#23232f` `9.13:1`, chip `#7ea6ff`/`#2b3a55` `4.78:1` (worst case, still ≥4.5:1). **Negative control:** `#6b6f85` on `#14141f` (the v2.19.3-incident color named in the AC) computes to **3.69:1**, independently reproducing the exact historical FAILED-AA value cited at `docs/retro.md:21` / the v2.19.3 gate row. | **PASS** |
| AC-SOCIAL-3 | Safe-area = center 1000×500 of the 1280×640 canvas → x∈[140,1140], y∈[70,570]. Computed left/right/top/bottom extent for all 8 text elements using a conservative monospace char-width estimate (0.62em, deliberately generous vs. real SFMono ~0.55-0.6em); every element's bounding box sits inside the safe area (widest: title2 right-edge 935.2 < 1140). Visual render (`Read` on the PNG) confirms no text approaches the card edges. | **PASS** |
| AC-SOCIAL-4 | `docs/owner-tasks.md` §"OT-5 disposition" records exactly **`ASSET-READY — DEFERRED, owner has not yet uploaded it.`** — one of the three permitted states, not `SET`/`DONE`. Grepped the entire uncommitted diff + new files for any `SET, verified` string: zero hits. No script or automation targeting GitHub repo Settings exists anywhere in the diff. | **PASS** |
| AC-SOCIAL-5 (gate MUST-FIX) | Provenance independently re-derived color-by-color (table above) — every fill traces to `assets/setup-demo.svg`'s existing palette, nothing stock or externally sourced. Headline "Describe your goal. / Get a workspace that evolves." traces conceptually to `README.md:3`'s opening blockquote line (paraphrase for card-length, not fabricated). **On the added `assets/social-preview-source.svg` file (beyond the spec's literal file list):** the spec's own Scope 2 AC text explicitly anticipates this — *"a new image asset exists at `assets/social-preview.png` (or `.png` derived from an authored `.svg` source, agent's implementation choice)"* — so this is not scope creep, it's the option the spec itself named. **Ruling: ACCEPTABLE.** | **PASS** |

### Owner-task ledger (AC-LEDGER-1..4)

| AC | Verify | Result |
|---|---|---|
| AC-LEDGER-1 | `docs/owner-tasks.md` exists; header row is the exact 7-column schema (`ID \| task \| created (version) \| what it blocks \| status (...) \| age (releases) \| deferral count`); 6 `OT-` rows present (OT-1..OT-6); 2 tracked candidates present (`NAMING`, and a second candidate — see Disposition #1/#3 below for its retitling). | **PASS** (with a disclosed naming deviation, see Disposition) |
| AC-LEDGER-2 | `grep -c "last_reviewed" docs/owner-tasks.md` = **0**. | **PASS** |
| AC-LEDGER-3 | Spec's literal verify (`grep -c "SKILL.md ecosystem sourcing" docs/roadmap.md`) = **0** — **stale**, see Disposition #1. Intent-level check (`grep -c "agency-agents" docs/roadmap.md`) = **1**; the `## Later` section does carry a row for this candidate. | **DISPOSITIONED PASS** (see below) |
| AC-LEDGER-4 | `docs/owner-tasks.md:11` states plainly: *"no CI job enforces this document's freshness this cycle (v2.19.4). The enforcing gate (`owner-task-expiry-check`) is Rung 2 (v2.20) scope..."* — an explicit non-goal statement, not a silent omission. | **PASS** |

### OT-3 catalog research (AC-OT3-1..3)

| AC | Verify | Result |
|---|---|---|
| AC-OT3-1 | The 3 curated targets' current rules **were** verified this cycle, with dates and sources, but the record lives in `pipeline.md`'s Phase 3 gate row narrative (Council-side), **not** appended to the file the spec's Output Contract designates (`ot3-catalog-research-2026-08-02.md`). `ls -la` on that file shows mtime **2026-08-02 15:22**, i.e. *before* this cycle's Phase 0 opened (2026-08-02T17:52:00Z) — confirming no findings note was ever appended to it. Substance is real and correctly sourced (verbatim `CONTRIBUTING.md` quotes for travisvn + ComposioHQ, a disclosed HTTP 403 for claudepluginhub.com); location is wrong relative to the spec's stated deliverable. | **PASS on substance / ISSUE on location** |
| AC-OT3-2 | **Not answered.** The AC requires the GuildSkills kit-vs-skill taxonomy question (does a 25-skill pool register as 1 entry, 25 entries, or 0) be resolved before any submission recommendation there. Searched `pipeline.md`, `scratchpad.md`, and `ot3-catalog-research-2026-08-02.md` for `GuildSkills` — the only occurrence is the original, still-open research question from before Phase 0. The Phase 2 `@compliance` finding answered a *different* question (no legal/ToS obligation from auto-indexing) — not the taxonomy-fit question this AC actually asks. No recommendation to submit to GuildSkills was made this cycle, so the AC's literal ordering constraint ("before any recommendation") is not technically violated — but the substantive research task itself, which the spec frames as required in-scope work, was not done. **Confirmed by the orchestrator as a genuine gap; disposition: carry forward as a tracked candidate in `docs/owner-tasks.md`, not silently dropped (see Findings).** | **FAIL / OPEN — non-blocking to OT-1 (see Verdict)** |
| AC-OT3-3 | `gh pr list`/`gh issue list --author "@me"` against all 3 named repos + the kit's own repo: zero results (verified `gh auth status` is genuinely authenticated, not silently no-op). `git branch -a`: no stray submission branches. | **PASS** |

### Version + compliance routing (AC-VERSION-1..2, AC-COMPLIANCE-1)

| AC | Verify | Result |
|---|---|---|
| AC-VERSION-1 | Re-ran the **exact** `version-consistency-check` CI logic from `.github/workflows/quality.yml:1631-1682` locally: `VERSION`→`2.19.4`, README badge (`grep -oP 'version-\K[0-9]+\.[0-9]+\.[0-9]+(?=-green)'`)→`2.19.4`, CHANGELOG top header (`grep -m1 -oP '^## \[\K[^\]]+'`)→`2.19.4`. All three match; the job would PASS. CHANGELOG `## [2.19.4]` is at line **7** (not line 1) — a `head -3` window misses it, `grep -m1` does not. | **PASS** |
| AC-VERSION-2 | `docs/roadmap.md:5` "Where we are" line reads `**v2.19.4**` (diff confirms substring-only edit, rest of the sentence byte-identical). | **PASS** |
| AC-COMPLIANCE-1 | `pipeline.md` Phase Log: Phase 2 `@compliance` DONE 2026-08-02T18:25:00Z, Phase 1 SKIPPED at the same timestamp (correct order — legal ran before design/skip). Scope recorded as narrow (ToS sanity + competitor-naming re-confirm), not a full review — matches the AC. **The Phase 2 row also claimed *"Findings in target-repo `docs/compliance-review.md`"* — this file does not exist anywhere in the target repo** (confirmed independently by both @qa and the orchestrator; see Disposition #5 below). **Ruling: AC-COMPLIANCE-1 still PASSES.** The AC's own text is a *process* requirement — narrow scope, correct ordering relative to `/design` — and says nothing about a persisted file. Both conditions are met on their own terms. The missing artifact is a real defect, but it is a *different* failure (a false claim about where output lives, not a failure of the review itself) and is tracked separately below rather than used to fail an AC it isn't part of. | **PASS on the AC / FINDING on the artifact claim** |

---

## Four Known Issues — Dispositions

### 1. AC-LEDGER-3 stale verify — is this a 3rd "Verifier-that-cannot-PASS" instance?

Read `docs/patterns.md:32` directly (current state: **WATCH 2/3**, instances v2.15.0 and v2.19.3). Both prior instances share one structural property: the verify command was **doomed by construction against the correct implementation** — v2.15.0's literal-diff check was guaranteed to show deletions on any faithful renumbering; v2.19.3's leg grepped an un-bolded substring that could never exist once the sentence was correctly bolded. In both cases, a *correct* implementation was *structurally incapable* of passing the check as written, from the moment the check was authored.

AC-LEDGER-3 is different in kind. At Phase 0, "SKILL.md ecosystem sourcing" was the accurate name of the candidate, and the verify command was correct against that intent — nothing about the check's construction made it doomed. Mid-cycle, the owner corrected the actual candidate's identity (a real, named upstream: `msitarzewski/agency-agents`, not a generic "ecosystem sourcing" concept), and the roadmap bullet correctly followed that correction. The check went stale **because the target moved**, not because the check was unsatisfiable from birth. A verify command that would have passed happily under the original (less-informed) scope is not the same failure shape as one that could never pass under any implementation.

**Ruling: this is *stale-after-approved-scope-change*, a distinct failure shape, and should NOT increment the Verifier-that-cannot-PASS counter.**

**Proposed new `docs/patterns.md` row (for `/retro` to consider, not added here — outside @qa's write scope until retro):**

| Pattern | Severity | Cycles | Description |
|---|---|---|---|
| Verify command orphaned by approved mid-cycle scope correction | WATCH (1/3) | v2.19.4 (1st instance — AC-LEDGER-3's verify grepped the literal phrase "SKILL.md ecosystem sourcing," accurate at Phase 0. The owner corrected the candidate's identity to a specific named upstream mid-cycle; the shipped artifact correctly followed the correction, orphaning the literal verify string while satisfying the AC's intent.) | Distinct from Verifier-that-cannot-PASS (that pattern's checks are unsatisfiable *from authoring*, regardless of implementation quality; this one's check was satisfiable and correct when written, and only went stale because the *target* legitimately moved mid-cycle under an approved owner correction). Recommended standing discipline: when a Phase-0 verify string names a concept rather than a stable identifier, and that concept is later resolved to a specific named entity, re-point the literal verify alongside the correction rather than leaving it to a downstream QA pass to notice the drift. |

### 2. AC-DEMO-4: spec says 17 lines, actual is 21

Confirmed by direct enumeration (table reproduced in Findings below): **21** dialogue lines (`textAssistant`/`textUser` class elements), not 17. All 21 independently re-verified against the bubble-budget formula — zero violations. The spec's number was never accurate for the *shipped* file (the beat count grew from 7→10 across v2.19.3, and the per-beat line count grew accordingly); it looks like a carry-forward arithmetic slip rather than a reflection of a real prior state. **Disposition: accept 21 as the correct, fully-verified count.** Recommend @pm append a one-line correction note in the next spec revision (append-only — do not edit the existing AC-DEMO-4 bullet); this report is the durable record in the meantime.

### 3. `addyosmani/agent-skills` fossils in `docs/spec.md`

Confirmed exactly 2 occurrences of "addyosmani" inside the v2.19.4 section (lines 5602, 5733 relative to the full file) — one bare mention in an author/framework list, one exact `addyosmani/agent-skills` in the out-of-scope line. Cross-checked against this cycle's actual shipped artifacts (`docs/roadmap.md`'s Later-section bullet, `docs/owner-tasks.md`'s tracked-candidate entry): both correctly name `msitarzewski/agency-agents`, confirming the real candidate was never in question — only the Phase-0 brief's rationale text carries the stale name. The out-of-scope line's catch-all clause ("...or any other external repo") keeps it *literally* true regardless.

**Disposition: stands as an accurate-if-dated record; recommended, not performed — the orchestrator has confirmed it prefers to carry an accurate-if-dated record over amending append-only history for cosmetics.** `docs/spec.md` is not in @qa's write scope in any case. No further action this cycle.

### 4. Append-only invariant

Independently re-verified, not accepted from `pipeline.md`'s narrative:

```
git diff --stat -- docs/spec.md
 docs/spec.md | 222 ++++++++++++++++++++++++++++++++++++++++++++++++++
```
— 222 insertions, **0 deletions** (the `+`-only bar confirms it visually as well as numerically).

```
wc -l docs/spec.md                    → 5812
git show HEAD:docs/spec.md | wc -l    → 5590
head -n 5590 docs/spec.md | cmp against git show HEAD:docs/spec.md → IDENTICAL
```

First 5590 lines are byte-for-byte identical to HEAD; exactly 222 new lines appended. `git diff --stat -- docs/architecture.md docs/retro.md docs/patterns.md` returns nothing — all three are entirely absent from this cycle's diff. **The invariant holds, confirmed two independent ways (stat + byte-cmp).**

### 5. `docs/compliance-review.md` claimed but absent — the cycle's third artifact-vs-narrative failure

Confirmed independently by both @qa and the orchestrator: the file does not exist in the working tree, `git status`, or `docs/internal/compliance/` (which holds only pre-existing, untouched versioned files). `@compliance`'s Phase 2 return asserted this file verbatim as the findings' location; the orchestrator accepted it without checking, and it was false.

This is the third instance this cycle of narrative outrunning artifact, alongside: (1) @pm's Phase 0 destructive `docs/spec.md` overwrite, reported as a successful write while silently destroying 5,373 lines of prior-cycle history; (2) the orchestrator's own Phase-0 SVG element allow-list, which asserted a 7-element vocabulary that the real shipped file's 8-element vocabulary (including `line`) contradicted. In all three cases the artifact was checked independently rather than the claim being trusted, and in all three cases the claim was wrong.

**What kept this instance from being a real loss:** the Phase 2 pipeline row embeds the compliance findings *verbatim*, not by reference to the missing file — so the substance survived the file's absence. Had the row only pointed at the file rather than reproducing its content, this cycle's entire Phase 2 review would have been unrecoverable. That is worth carrying forward as its own standing discipline candidate (narrative rows that cite an artifact should still embed the substance, not just the pointer) — flagged here for `/retro`, not actioned as a pattern-table entry by @qa.

---

## Additional Findings (beyond the four flagged issues)

1. **AC-OT3-2 genuinely unresolved** (detailed above) — the GuildSkills kit-vs-skill question was research the spec explicitly scoped as required this cycle and it was not done. Not a hard blocker (no submission or recommendation was made, and `AC-OT3-3`'s 0-submissions boundary holds), but it should not be silently dropped. **Recommended new `docs/owner-tasks.md` tracked-candidate row (not written by @qa — `docs/owner-tasks.md` is a product ledger outside @qa's write scope; supplied here as text for `@dev`/the orchestrator to apply, same discipline as a worktree-blocked write):**

   ```
   - **GUILDSKILLS KIT-VS-SKILL FIT** — resolve whether this repo's 25-skill pool would register with GuildSkills (guildskills.com, auto-indexed) as 1 entry, 25 entries, or 0, before any recommendation to submit there is made (AC-OT3-2, v2.19.4 — asked, not answered). `created: v2.19.4, blocks: nothing yet, status: OPEN (tracked, no action)`.
   ```

2. **`docs/compliance-review.md` claimed but absent** — see Disposition #5. Recommend the Council-side pipeline row be corrected (now done — the orchestrator applied a ⚠ note) and that `@compliance` actually write the promised file on its next narrow review, or that the row's convention change to "findings recorded in pipeline state" if a separate file is not going to be maintained going forward.
3. **AC-OT3-1 output-location deviation** — same root issue as #2's cousin: the spec's Output Contract names `ot3-catalog-research-2026-08-02.md` as the append target for OT-3 findings; the actual findings live in `pipeline.md`'s Phase 3 gate narrative instead. Non-blocking (the content is real, dated, and sourced), but worth closing the loop on for process hygiene.
4. **`docs/owner-tasks.md`'s second tracked candidate was retitled**, not just corrected in citation: spec asked for a row titled "SKILL.md ECOSYSTEM SOURCING"; the shipped ledger instead has "AGENCY-AGENTS PERSONA CONVERSION," with substantially expanded content (vendoring detail, category breakdown, two authoring caveats) not in the spec's one-line description. This is a superset of the required content and is factually more accurate than what the spec asked for (matches Disposition #1/#3's root cause) — **not a defect**, but noted so the AC-LEDGER-1 "as specced" checkbox isn't read as a literal match.

## Dialogue-Line Budget Table (AC-DEMO-4, full reproduction)

| Line | Class | Chars | Bubble width | Budget `(w-72)/8.4` | Fits? |
|---|---|---|---|---|---|
| "Welcome! What do you need help with?" | Assistant | 36 | 460 | 46.19 | ✓ |
| "Describe your goal in your own words." | Assistant | 37 | 460 | 46.19 | ✓ |
| "I write client reports, need my own voice" | User | 41 | 480 | 48.57 | ✓ |
| "Here's a Writing draft built from your goal" | Assistant | 43 | 620 | 65.24 | ✓ |
| "(matched: voice, reports): voice-matching," | Assistant | 42 | 620 | 65.24 | ✓ |
| "anti-ai-slop, editing-pass. Run or adjust?" | Assistant | 42 | 620 | 65.24 | ✓ |
| "Run with it" | User | 11 | 300 | 27.14 | ✓ |
| "Saved. Last question: your name, what" | Assistant | 37 | 500 | 50.95 | ✓ |
| "you're working toward, any deadlines?" | Assistant | 37 | 500 | 50.95 | ✓ |
| "Jordan: client reports, biweekly deadlines" | User | 42 | 540 | 55.71 | ✓ |
| "Your workspace is ready." | Assistant | 24 | 600 | 62.86 | ✓ |
| "voice-matching keeps drafts sounding" | Assistant | 36 | 600 | 62.86 | ✓ |
| "like you; anti-ai-slop flags AI-ish" | Assistant | 35 | 600 | 62.86 | ✓ |
| "phrasing. Archived setup in _setup-kit/." | Assistant | 40 | 600 | 62.86 | ✓ |
| "I noticed you keep renaming report" | Assistant | 34 | 640 | 67.62 | ✓ |
| "drafts by hand. Want me to propose" | Assistant | 34 | 640 | 67.62 | ✓ |
| "a naming fix, your call to confirm?" | Assistant | 35 | 640 | 67.62 | ✓ |
| "Yes, show me what changes" | User | 25 | 340 | 31.9 | ✓ |
| "Done. You can undo this any time from" | Assistant | 37 | 640 | 67.62 | ✓ |
| "the log. voice-matching also has an" | Assistant | 35 | 640 | 67.62 | ✓ |
| "update ready, pull it whenever you want." | Assistant | 40 | 640 | 67.62 | ✓ |

21/21 fit. 0 failures.

## Markdown/CI hygiene

`npx markdownlint-cli2` against `README.md`, `CHANGELOG.md`, `docs/owner-tasks.md`, `docs/roadmap.md`: **0 issues in 0 files**. No hard tabs in any changed doc file. `version-consistency-check` re-run manually (see AC-VERSION-1): PASS. Nothing has been pushed yet, so no live CI run exists to cite — this is the pre-push state.

## Unit/E2E Tests

- Total: 0 (no application code surface this cycle — static assets + markdown docs only, per the spec's own Technical Constraints)
- Passing: n/a
- Failing: n/a

This is a STANDARD assets+docs cycle with zero product/feature surface; verification is the mechanical AC re-derivation above, not a unit/E2E suite.

## Issues Found

- [ ] AC-OT3-2 (GuildSkills kit-vs-skill taxonomy question) never actually answered — carry forward as a tracked candidate (row text supplied above), non-blocking to this cycle's OT-1 path.
- [ ] `docs/compliance-review.md` claimed in `pipeline.md` Phase 2 row but does not exist in the target repo — third artifact-vs-narrative mismatch this cycle; pipeline row now corrected with a ⚠ note.
- [ ] OT-3 findings (3 curated targets' rules) live in `pipeline.md` narrative, not appended to the spec's designated `ot3-catalog-research-2026-08-02.md` — process hygiene, non-blocking.
- [ ] `docs/spec.md`'s 2 `addyosmani/agent-skills` fossil references — accepted as accurate-if-dated per orchestrator decision; no further action.
- [ ] AC-DEMO-4's stated "17 lines" vs. actual 21 — recommend an append-only correction note next spec touch.

## Verdict

**APPROVED WITH NOTES.** 20 of 22 ACs fully PASS with independently reproduced evidence (not accepted from @dev's or the orchestrator's narrative). AC-LEDGER-3 PASSES on intent with a dispositioned stale literal-verify (ruled a distinct failure shape, not a 3rd Verifier-that-cannot-PASS instance). AC-COMPLIANCE-1 PASSES on its own literal terms (ordering + narrow scope) despite the missing `docs/compliance-review.md` file, because the AC does not require that file's existence — the missing artifact is tracked as its own finding, not used to fail an AC it isn't part of. AC-OT3-2 is genuinely incomplete but does not block this cycle's own hard boundary (0 submissions, confirmed) or the OT-1 announcement path (which is gated on OT-2 + OT-5, not OT-3). All 4 known issues handed to @qa are dispositioned above with independent reasoning, not accepted at face value. 2 new findings were caught this cycle (AC-OT3-2 unresolved; `docs/compliance-review.md` claimed-but-absent, the cycle's 3rd artifact-vs-narrative mismatch) — both confirmed by the orchestrator, neither blocks merge.

Recommend proceeding to `/audit` (Phase 6) or directly to owner merge decision if this cycle is treated as STANDARD-fast-track per its own classification — with the 5 Issues Found above carried forward explicitly (not dropped) into `docs/owner-tasks.md` or the next cycle's Phase 0.

---

## Phase: 7
## Date: 2026-08-03T12:00:00Z
## Status: APPROVED WITH CONDITIONS

Four things changed since the Phase 5 pass above. Each was independently re-verified against the artifact, not accepted from any agent's or the orchestrator's narrative — this cycle already has three artifact-vs-narrative mismatches on the board (Findings #5 above), so Phase 7 treated every claim as unproven until checked.

### 1. Append-only invariant — RE-CONFIRMED, holds

```
git diff --stat -- docs/spec.md
 docs/spec.md | 222 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 222 insertions(+)
```

**0 deletions on `docs/spec.md`, unchanged from the Phase 5 measurement** — the file was not touched again between Phase 5 and Phase 7. `git diff --name-only` confirms `docs/architecture.md`, `docs/retro.md`, and `docs/patterns.md` are absent from this cycle's diff (grep for all three returns nothing). The invariant that failed once already this cycle (@pm's Phase 0 destructive overwrite) holds cleanly now.

### 2. Full diffstat — 13 deletions fully accounted for, all legitimate

```
 CHANGELOG.md                          |   6 +
 README.md                             |   2 +-
 VERSION                               |   2 +-
 assets/setup-demo.svg                 |  20 +++++++++----------
 docs/internal/planning/competitive.md |  10 ++++++++++
 docs/roadmap.md                       |   3 ++-
 docs/spec.md                          | 222 ++++++++++++++++++++++++++++++
 7 files changed, 252 insertions(+), 13 deletions(-)
```

Line-by-line source of every deletion: `assets/setup-demo.svg` 10 deletions (paired with 10 insertions — the em-dash→period/colon substitutions on the same lines, already verified under AC-DEMO-1/2/3 at Phase 5, unchanged since); `README.md` 1 deletion (badge `2.19.3`→`2.19.4`); `VERSION` 1 deletion (`2.19.3`→`2.19.4`); `docs/roadmap.md` 1 deletion ("Where we are" line, `v2.19.3`→`v2.19.4`, rest of the sentence byte-identical on diff inspection). **10+1+1+1 = 13.** No deletion falls outside the em-dash-substitution + version-bump set. `docs/internal/planning/competitive.md` is 10 insertions / 0 deletions (pure append). No finding.

### 3. Ruling on AC-OT3-2 — disposition accepted, does not block

`docs/owner-tasks.md` now carries, under `## Tracked candidates`: `**GUILDSKILLS KIT-VS-SKILL FIT** — resolve whether this repo's 25-skill pool would register with GuildSkills... (AC-OT3-2, v2.19.4 — asked, not answered). created: v2.19.4, blocks: nothing yet, status: OPEN (tracked, no action).` — text-for-text the row Phase 5 supplied. `grep -c "last_reviewed" docs/owner-tasks.md` = **0**, re-confirming AC-LEDGER-2 still holds with the ledger's schema unchanged (the deliberately-omitted freshness column was not smuggled back in by this addition).

This satisfies merge, for the same reason it was never a hard blocker at Phase 5: AC-OT3-2 never gated `AC-OT3-3`'s 0-submissions boundary (still true — re-confirmed no new branches or PRs against any of the 3 catalogs), and it never gated OT-1's announcement path (gated on OT-2 + OT-5, not OT-3). What changed is that the open question moved from "unanswered and only living in a QA report" to "unanswered and durably tracked in the product's own ledger, with the row schema (created/blocks/status) filled in." That is the correct disposition for a non-blocking research gap — not a fix, but no longer at risk of silent loss. **Does not block.**

### 4. Two Phase 5 findings — both dispositioned, not merely noted

The verdict paragraph above names two *new* findings @qa caught at Phase 5 (as opposed to the pre-existing 3 issues handed in from Phase 0-4): AC-OT3-2 unresolved, and `docs/compliance-review.md` claimed-but-absent.

- **AC-OT3-2** — dispositioned per item 3 above (durable ledger row, non-blocking).
- **`docs/compliance-review.md` claimed-but-absent** — re-read the live Phase 2 row in `pipeline.md`: it now opens with `**⚠ CORRECTED 2026-08-02T19:10Z — @compliance's claimed artifact DOES NOT EXIST**`, states plainly that the file was never written, names this as the cycle's third artifact-vs-narrative failure, and — critically — the row **embeds the Phase 2 findings verbatim** rather than only citing the missing file. Confirmed the file still does not exist (`find docs/internal/compliance/` shows only pre-existing versioned files, none touched this cycle) — this was never going to be fixed by Phase 7 (the missing artifact is a Phase-2-agent-behavior defect, not a Phase-6/7 remediable one), and it doesn't need to be: the substance survived because the row records it directly. Both are genuinely dispositioned — acknowledged, root-caused, and either tracked forward (OT3-2) or self-correcting via a durable, substance-preserving record (compliance-review.md) — not merely noted and left to rot.

### 5. Merge readiness

**Not yet ready for a merge decision — one required step remains: commit and open a PR.** Every file in this cycle's diff is currently uncommitted on `main` in the target repo (`/Users/macbookpro/claude-cowork-config`), which is expected for a STANDARD/in-place cycle that does its work directly against the working tree before a single commit. Per this repo's own binding constraint (`main` carries an active branch-protection ruleset, no bypass, confirmed in prior cycles' pipeline rows), a direct push to `main` is not an option regardless of classification.

**What must happen before merge, in order:**
1. Commit the 12 changed/new files (`CHANGELOG.md`, `README.md`, `VERSION`, `assets/setup-demo.svg`, `docs/internal/planning/competitive.md`, `docs/roadmap.md`, `docs/spec.md`, `assets/social-preview-source.svg`, `assets/social-preview.png`, `docs/internal/qa/qa-report-v2.19.4.md`, `docs/internal/security/security-review-v2.19.4.md`, `docs/owner-tasks.md`) on a short-lived branch.
2. Push, open a PR against `main`.
3. Wait for `gh pr checks` to go fully green (markdownlint, link-check, version-consistency-check are the relevant jobs here — all three were re-derived manually above and PASS; this still needs to be confirmed live in CI, not just locally).
4. Only then present the merge confirmation to the owner.

No code/logic surface exists this cycle (STANDARD, docs+assets only), so CI risk is low, but "low risk" is not the same as "green," and this report does not claim a CI run that has not happened yet.

### 6. Topology check

STANDARD/in-place classification, no worktree used for this cycle — confirmed via `pipeline.md`'s Current Task header (`Classification: STANDARD, in-place`) and every Phase Log row for this cycle recording `branch: main`. `git branch -a` in the target repo shows no stray branch for v2.19.4 (only pre-existing historical branches from prior cycles remain, all already merged/retro'd). No pipeline state is stranded on a branch that shouldn't hold it, and none is missing from where it should be. **Clean.**

### Verdict

**APPROVED WITH CONDITIONS.**

All 6 re-verification items above hold. The append-only invariant that broke once already this cycle is intact and independently reproduced two ways. All 13 deletions are accounted for and legitimate — none outside the expected em-dash + version-bump set. AC-OT3-2 is acceptably dispositioned as a durable, non-blocking tracked candidate. Both of @qa's own Phase 5 findings are genuinely dispositioned, not merely logged and abandoned. The S1 remediation is real on both ends — the public ledger is genuinely trimmed to a bare status line, and the competitive-positioning substance genuinely landed in `docs/internal/planning/competitive.md` (10 insertions, not a net loss). The Council-side AC-OT3-1 location gap is closed with a dated, substantive `## Gate-time verification` block.

**Condition for merge:** this diff must be committed to a branch, opened as a PR, and pass CI green before the owner is presented a merge decision — none of that has happened yet. This is process, not a content defect; nothing found in this Phase 7 pass requires further rework.

**qa_issues_prevented (Phase 7 pass):** blocker=0, issue=0, info=0 — no new issues surfaced this pass; all 4 re-verification targets from the brief confirmed clean on independent re-check.

**Rework rate:** 0% — no code changed between the Phase 5 SHA (uncommitted working tree) and this Phase 7 pass; the only diffs are the 4 items enumerated above (owner-tasks.md ledger row, competitive.md append + owner-tasks.md trim, and the Council-side catalog-research file, which lives outside this repo's own diff).
