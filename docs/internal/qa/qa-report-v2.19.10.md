# QA Report — v2.19.10 "Plain Language"

## Phase: 5 (Testing)
## Date: 2026-08-20
## Tree graded: `release/v2.19.10-plain-language` @ `5814e43` (pushed, local == remote, base `fd00dd2`)
## CI: HEAD run `32364566078` — conclusion `success`, 0 failed (all jobs `success` or expected-`skipped`).
## Commit `b67a883` run `32364229736` — conclusion `failure`; job-level breakdown shows exactly ONE
## failed job (`Version Consistency Check`), 3 expected `skipped` (path/flag-gated), all remaining
## ~30 jobs `success` — including `Registry sha256 Drift-Verify Check`. Fixed at `5814e43`
## (README badge). Nothing else was broken by that intermediate commit.

## Status: **REJECTED**

Scope: `AC-PL-1` … `AC-PL-8` only, per `docs/spec.md`'s explicit acceptance-set table and the Phase-1.3
withdrawal of the `AC-PL-13` "@qa verifies at Phase 5" line. `AC-PL-9` … `AC-PL-13` were not tested;
their absence is not a coverage gap (spec's own instruction, independently confirmed — no other
artifact in this tree still points @qa at the deferred ACs).

---

## 1. Render-layer instrument — 3-question read, every in-scope string

**Q1 (mechanical):** case-insensitive STEM match against the Cycle Jargon List, no inline definition in
the same sentence → YES fails. **Q2:** every other technical term inline-defined? NO fails. **Q3
(human judgment):** meaning preserved vs. pre-edit? NO fails. **FAIL = YES on Q1, OR NO on Q2, OR NO on
Q3.** All 34 Jargon-List terms scanned per string via one `grep -oiE` pass; every row below is a
command I ran against the live tree, not a restated claim.

### 1a. Registry descriptions (6 in-scope rows)

| # | Row | Q1 | Q2 | Q3 | Verdict | Note |
|---|---|---|---|---|---|---|
| 1 | `self-apply` (`:31`) | N | N* | Y | **PASS*** | Jargon scan: 0 hits except `context/.kit-migrations/` (Jargon-List term #34), glossed only as "the folder" — see §1c. Judged sufficient (Q2 borderline, not a fail) — flagged, not blocking. |
| 2 | `self-archive` (`:32`) | N | N* | Y | **PASS*** | Same `context/.kit-migrations/` note as row 1. |
| 3 | `self-upgrade` (`:33`) | N | N | Y | **PASS** | 0 jargon hits. `dormant`/`ready` plain language, meaning preserved. |
| 4 | `pull-updates` (`:41`) | N | N | Y | **PASS** | 0 jargon hits. "byte-for-byte" reads as plain comparison language, not a listed term. |
| 5 | `prompt-gate` (`:83`, Group A) | N | N | Y | **PASS** | 0 jargon hits (full text). Negative control: pre-edit full description fails Q1 (`auto-skips`, `bypass`, undefined) — confirmed. See §1b for the truncated-fallback caveat. |
| 6 | `anti-ai-slop` (`:122`, Group A) | N | N | Y | **PASS** | 0 jargon hits (full text). Negative control: pre-edit fails Q1 (`AI-tell`, `opt-in`, `denylist`, undefined) — confirmed. See §1b. |

**Group A ≤12-word truncated-fallback form (ADR-030 Role-Generation Rule, `WIZARD.md:394`) — required
by AC-PL-1 Group A:**

- `prompt-gate` post-edit, first 12 words (`awk`-extracted, word-bounded): *"Asks a few clarifying
  questions before answering, using your files for context."* — clean sentence boundary, 0 jargon
  hits, meaning preserved. **PASS.**
- `anti-ai-slop` post-edit, first 12 words: *"Smooths out text that reads like it was written by AI —"*
  — 0 jargon hits (`AI` alone is not a stem match for the listed term `AI-tell`). Truncation lands on a
  dangling em-dash, which is a cosmetic artifact of the 12-word cut, not a meaning change. **PASS,
  INFO-level readability note.**

**Group A negative-control precision (see §1b below for the full derivation):** the pre-edit **full**
description fails Q1 for both rows, as required. The pre-edit **truncated** form fails Q1 for
`anti-ai-slop` (`AI-tell` falls within the first 12 words) but **does not** fail Q1 for `prompt-gate`
(`auto-skips`/`bypass` fall after word 12) — narrower than the spec's blanket claim that "the CURRENT
description and its truncation MUST fail Q1." This does not affect AC-PL-1's post-edit requirement
(both post-edit truncations are independently confirmed clean above); it is a precision correction to a
negative-control claim, recorded per the binding "do not state a claim wider than its instrument" rule.

**Group A token-overlap constraint (Technical Constraints, matching-behaviour preservation):** both rows
retain ≥1 non-stopword token shared with their `name` AND their pre-edit description —
`prompt-gate` → `prompt`, `questions`, `context`; `anti-ai-slop` → `AI`, `hedging`, `voice`. Confirmed
by direct text comparison of the diff hunks. **Satisfied.**

### 1b. F4 bundle menu — spoken/quoted strings only (`WIZARD.md:114-146`)

Scope per AC-PL-3: text inside quotes, or following `Display as:`/`say:`/`respond:`. Full block
(`:114-146`) scanned with the 34-term jargon regex; every hit individually triaged in-scope vs.
meta-prose:

| # | String | Location | Q1 | Q2 | Q3 | Verdict |
|---|---|---|---|---|---|---|
| 1 | Opening + 5 bullet options (*"Here's what I'd install…Done / keep all: confirm to proceed."*) | `:114-121` | N | N | Y | **PASS** |
| 2 | Pool-exhaustion refusal (*"That's not something we have available — the closest match is [X]. Want that instead?"*) | `:123` | N | N | Y | **PASS.** Negative control: pre-edit *"That's not in the current pool…"* fails Q1 on `pool` — confirmed. |
| 3 | External-source refusal (*"Installing skills from external sources isn't supported yet — the wizard installs only from the local, vetted pool (already reviewed and included with this kit)."*) | `:123` | N | N | Y | **PASS.** `pool` now inline-defined in the same sentence. Doubles as AC-PL-7 row 6 — see §2. |
| 4 | Role-generation display (*"Installed skills will help you with: […]"*) | `:125` | N | N | Y | **PASS** |
| 5 | *"Want more options?"* | `:132` (edge case) | N | N | Y | **PASS** |
| 6 | **`"Final bundle: [skills]. Continue?"`** | `:132` | **Y** | — | — | **FAIL — see §1b-i, BLOCKER** |
| 7 | Fast-track offer (*"Basics saved. 1) Keep going…2) Start now…"*) | `:145` | N | N | Y | **PASS** |
| — | Numeral `25` (*"25 skills available"*) | `:119` | N/A | N/A | Y | **PASS** — survives verbatim; the only instrument for this is this row (no CI job checks it). |

**6/7 spoken strings PASS. 1/7 FAILS — see §1b-i.**

#### 1b-i. BLOCKER — `WIZARD.md:132`, `"Final bundle: [skills]. Continue?"` fails Q1

`bundle` is Jargon-List term #19. This exact quoted string is unchanged by this cycle's diff
(`git diff fd00dd2..HEAD -- WIZARD.md | grep -n "Final bundle"` → 0 hits). Re-derived the full pre-edit
F4-block scope for `bundle`/`pool` from a fresh extraction (`sed -n '114,146p' WIZARD.md`, jargon-regex
scan, every hit individually classified in-quote vs. meta-prose):

- Pre-edit in-quote (spoken) `bundle` occurrences: exactly **2** — `"Your bundle: [final skill
  list]."` (`:114`, now rewritten to *"Here's what I'd install…"*) and `"Final bundle: [skills].
  Continue?"` (`:132`, **unchanged**). This reproduces the spec's own "2 in-scope occurrences" claim
  exactly.
- Every other `bundle`/`pool` hit in the block (`:112`, `:116`, `:123` meta-prose lead-in, `:125`,
  `:128`, `:129`, `:134`, `:142` checkpoint-stub template field) is Claude-facing meta-prose or written
  file-template content, not a spoken/quoted string — correctly out of AC-PL-3's scope, per
  `CONTRIBUTING.md § Runtime-string register`'s own definition ("every spoken or quoted string").

Only 1 of the 2 pre-edit in-scope occurrences was rewritten. `WIZARD.md:132`'s quoted confirmation still
reads jargon with no inline definition — **Q1 = YES, FAIL** under this cycle's own binding instrument.
This is not an instrument defect (unlike the design doc's F-1/F-6/F-7/F-8 findings) — it is an
incomplete edit against a real, in-scope AC-PL-3 requirement.

**Remedy (do not redesign):** rewrite the quoted string at `WIZARD.md:132` to drop or inline-define
`bundle`, mirroring the fix already applied at `:114` — e.g. `"Here's the final list: [skills].
Continue?"`. No other file or AC is implicated by this fix.

### 1c. Registry Group A/B jargon-gloss judgment call — `context/.kit-migrations/`

`self-apply` and `self-archive` both retain `context/.kit-migrations/` (Jargon-List term #34), glossed
only as *"the `context/.kit-migrations/` folder."* This names the type (a folder) but not its purpose.
Judged **PASS** — "folder" functions as a minimal type-gloss and the surrounding sentence already
states the operative guarantee (protection), which is what a non-technical reader needs — but recorded
explicitly rather than silently passed, since it is the one Jargon-List term in this cycle's edits that
gets the thinnest gloss of any in-scope string. Not a blocking finding.

### 1d. Closing message (`WIZARD.md:339`)

Full-line jargon scan: 1 hit — `reversibly`, inline-defined in the same clause (*"…and does so
reversibly, meaning any move it makes can always be undone)"*). Pre-edit jargon (`ledger`,
`apply/verify/rollback`, `engine`, `kit versions`) removed entirely, not just redefined. **PASS.**
AC-PL-2 item-diff and negative-guarantee checks in §3.

---

## 2. AC-PL-7 — safety-semantics preservation, all 6 rows

| Row | Clause | (a) enumeration | (b) neg. guarantee | (c) deny-list (pre→post) | Verdict |
|---|---|---|---|---|---|
| 1 | Data locality (`examples/personal-assistant/…`) | 6/6 tokens present | 2/2 present | 0→0 | **GREEN** |
| 2 | File access, 8 files | untouched by this diff (see below) | — | — | **GREEN (by construction)** |
| 3 | Spend awareness (`examples/personal-assistant/…`) | — | *"unless I ask explicitly"* present | — | **GREEN (byte-unchanged)** |
| 4 | Academic integrity (`examples/study/…`) | — | *"must be mine"* present | — | **GREEN (byte-unchanged)** |
| 5 | WIZARD.md Closing | 11/11 pinned items + `[list]` | 3/3 (`never silently performs`, `reversibly`, `never on its own`) | — | **GREEN** |
| 6 | WIZARD.md F4 pool boundary (`:123`) | — | Leg A both halves present; Leg B 2→2 | 0→0 | **GREEN** |

**Row 1 detail — AC-PL-5's `APIs` finding, resolved correctly, not weakened:**
`git diff fd00dd2..HEAD -- examples/personal-assistant/context/working-rules.md` shows exactly one line
changed. Extracted pre/post clause to files and ran the deny-list regex
(`unless|except|if (you|it|needed)|when (necessary|needed)|as long as|provided that|at your
discretion|without (asking|checking)|or go ahead`, case-insensitive) against both: **0 → 0**. All 6
enumerated categories (`financial amounts`, `calendar event details`, `contact information`, `health
information`, `physical addresses`, `authentication credentials`) and both negative guarantees
(`Never send`, `decline and offer a local alternative`) individually confirmed present post-edit via
`grep -oF … | wc -l` (each = 1). The shipped resolution — *"(other programs or services outside this
computer)"* — is the **safe, broad shape**, not the narrower *"…over the internet"* variant flagged as a
risk (S15): it excludes nothing that was previously in scope, since anything "outside this computer" is
still covered regardless of transport (internet, LAN, local IPC to another device). **No weakening.**

**Row 2 detail — untouched, confirmed by diff, not by trust:** `git diff fd00dd2..HEAD -- examples/
templates/ | grep -c '^diff --git'` → **1** (only `personal-assistant/context/working-rules.md`, and
only its Data locality line — confirmed above). All 8 `## File access` sections, including the
template's structural-exception two sentences (*"the folders I have explicitly given you access to"*,
*"Do not read files outside my project folder without asking"*, both confirmed present verbatim), are
byte-unchanged this cycle. No fresh damage possible to verify against; the design doc's Phase-1 margin
finding (only 2 of `personal-assistant`'s 5 tokens are load-bearing, due to extra prose occurrences of
`Tasks/`/`People/`/`Calendar/` elsewhere in that file) still holds and is recorded for future cycles
that touch `§ Daily briefing` or `§ Follow-ups` in that file.

**Row 6 detail — Leg A/Leg B/(c), independently rebuilt, not re-run from CI:**
- Leg A (anchor `grep -n 'No URL paste, no external source' WIZARD.md` → unique, line 123). Both halves
  confirmed present on that line via `grep -oF` scoped to `sed -n '123p'` output: *"Installing skills
  from external sources isn't supported yet"* and *"the wizard installs only from the local, vetted
  pool"*.
- **Anchor-existence guard, built and proven, not assumed:** simulated a typo'd anchor
  (`grep -n 'No URL paste, no external sorce'` → empty `LINE`) and ran the unguarded equivalent,
  `sed -n "p" WIZARD.md | wc -l` → **422** (whole file, not 1 line). This is the exact defect described
  in the assignment: an ungated empty `LINE` degrades leg A into a presence-anywhere check, which would
  silently pass even if the real F4 copy at `:123` were deleted (line 27's Network & Offline Rule copy
  would still match). My check includes a fail-closed guard (`[ -z "$LINE" ]` → abort) before ever
  calling `sed -n "${LINE}p"`; the real anchor (`LINE=123`, non-empty) passes it cleanly.
- Leg B: `grep -oF "Installing skills from external sources isn't supported yet" WIZARD.md | wc -l` →
  **2** post-edit, matching the pre-edit baseline of 2 (line 27 unchanged, line 123 the rewritten F4
  copy).
- (c) deny-list on `:123`, the mandated additive-edit line: **0 pre-edit → 0 post-edit**, confirmed via
  `sed -n '123p'` on both `fd00dd2` and HEAD, same regex as row 1. The added parenthetical *"(already
  reviewed and included with this kit)"* is a genuine inline definition of `pool`, not an exception
  clause.

---

## 3. AC-PL-2 — closing message item-diff (against the Phase-1 pin, `docs/design-v2.19.10.md §D.2`)

`sed -n '339p' WIZARD.md | grep -oE '`[^`]+`'` produces exactly the 11 pinned backticked items, in the
pinned order, zero diff against the Phase-1 list. `grep -cF 'installed skills: [list]' WIZARD.md` → 1
(the 12th, un-backticked item). **PASS, 0 dropped items.**

---

## 4. AC-PL-6 — registry row-structure integrity, CI gate audit

Live tree: `awk -F'|' '{s=$8; gsub(/ /,"",s); if (s ~ /^[0-9a-f]{64}$/) c++} END{print c+0}'
curated-skills-registry.md` → **30**, matching the pin (`AC_PL_6_EXPECTED_HEX_ROWS: "30"`,
`.github/workflows/quality.yml:571`). Implemented entirely inside `registry-sha256-check`
(`quality.yml:556-696`) — no `scripts/` file added (TIER-4 clear, `git diff --name-only fd00dd2..HEAD --
scripts/` → empty).

**Fresh, independently-built fixtures (not CI's own, copied to a scratch dir outside the repo):**

| Fixture | Method | Count | Verdict |
|---|---|---|---|
| Clean | copy of live registry | 30 | GREEN — matches pin |
| Pipe injection (real anchor, `self-apply`) | `awk` positional injection on field 2 | 29 | RED — correct |
| Broken-anchor pipe injection (typo, extra space) | same `awk`, anchor `"  self-apply "` | n/a — `cmp -s` identical to clean | **No-op correctly caught** — this is the canary the CI job's own `cmp -s` fixture-validity guard exists for; proved it fires |
| Different-row injection (`prompt-gate`, not `self-apply`) | same method, different anchor | 29 | RED — confirms the technique generalizes, not a `self-apply`-specific artifact |
| Compound (pipe + reflow) | `sed` reflow on top of pipe fixture | 29 | RED — correct |
| Reflow-only (no pipe injection) | `sed` reflow alone | 30 | GREEN — **honesty check confirmed**: reflow alone does not move the count; the RED above comes entirely from the pipe-injection leg, matching the design doc's own "HONEST SCOPE" claim |

**CI's own `REAL_HASH` extraction canary, independently pressure-tested:** ran the exact awk pattern
(`$0 ~ /^\| self-apply \|/`) against the live registry — non-empty, correct 64-hex value extracted. Ran
a deliberately typo'd pattern (`self-appply`) — **empty output**, confirming the script's own
`if [ -z "$REAL_HASH" ]; then exit 1; fi` guard would fire rather than silently degrading into a false
pass. Canary sound.

**No sixth cannot-fail instrument found in AC-PL-6's implementation** — every leg I pressure-tested
(fault-injection self-test's `REAL_HASH` guard, the `cmp -s` fixture-validity guard, the count assertion
itself) went RED/aborted on the condition it exists to catch, under a fresh fixture I built myself.

---

## 5. AC-PL-4 — no-jargon rule, discoverable home

- `grep -c "Runtime-string register" CONTRIBUTING.md` → **1** (post-edit; pre-edit 0, per Phase-1
  record).
- `sed -n '824,827p' docs/spec.md`: line 824 = the v2.5.3 row, byte-unchanged (confirmed via
  `git diff fd00dd2..HEAD -- docs/spec.md` — the row appears only as unmodified context, never in a
  `+`/`-` hunk). Line 826 = the forward-pointer, on its own line, within the 4-line window:
  `grep -cF 'CONTRIBUTING.md § Runtime-string register'` scoped to that window → 1. Dated:
  `grep -cE '[0-9]{4}-[0-9]{2}-[0-9]{2}'` over the same 4-line window → 1 (`added 2026-08-20`).
- **Scope note:** the unscoped file-wide count of the same string is **3**, not 1 — this is expected
  drift the design doc already flagged (F-6, twice-superseded); the scoped 4-line-window check is the
  corrected, authoritative instrument and is what's reported here. Restating the file-wide "3" as if it
  were the AC-PL-4 result would itself be a claim wider than its instrument.

**PASS.**

---

## 6. Registry structural checks (schema/NF, unrelated to sha256 field)

`awk -F'|' 'NF==9 {c++} END{print c}' curated-skills-registry.md` → 50 (includes the 2-column schema
legend rows, as documented — this is why AC-PL-6 does not use `NF!=9` as its instrument). `grep -c
'^|' curated-skills-registry.md` → 59 total pipe-bearing lines. No `|` character introduced into any of
the 6 rewritten description cells — confirmed by the AC-PL-6 valid-hex-row count staying at exactly 30
(a stray pipe would shift field 8 for that row and drop the count to 29, as demonstrated in §4's
fixtures).

---

## 7. AC-PL-8 — template parity, coverage gap re-confirmed

`ls examples/*/context/working-rules.md | wc -l` → **7** (glob alone misses the template). The 8-file
form (`examples/*/… templates/preset-template/…`, explicit) was the one actually used for the §1c /
§2-row-2 full-8-file jargon sweep above. `grep -rn "working-rules" .github/workflows/` → **0** — no CI
job covers any of the 8 files; AC-PL-8 plus this Phase-5 read remain the only instrument for this
surface, reconfirmed.

**Full 8-file jargon audit (AC-PL-5), independently re-run:** concatenated all 8 `working-rules.md`
files and scanned with the same 34-term regex used throughout this report. **Exactly 1 hit: `APIs`, in
the personal-assistant Data locality clause** — already resolved (§2, row 1). No other jargon-list term
appears anywhere across the 8 files. This reproduces the spec's stated Phase-1 audit result
(`[CONFIRMED at Phase 1]` — exactly 1 pre-existing violation) as a fresh, independent re-derivation
rather than accepting the design doc's number on trust.

---

## 8. Scope-withdrawal integrity check (`AC-PL-9` … `AC-PL-13`)

`git diff --name-only fd00dd2..HEAD` matches exactly `docs/design-v2.19.10.md §D.1`'s rows 1–9
(implementation) plus rows 15–16 (append-only spec/architecture records) — nothing from the withdrawn
rows 12–14. `docs/spec.md`'s own withdrawal notice (*"The `AC-PL-13` line reading…is withdrawn by this
notice. @qa verifies nothing from that section"*) is the only place a Phase-5 obligation for the
deferred ACs was ever recorded, and it has already retracted itself. No other artifact in this tree
still instructs @qa to verify `AC-PL-9`…`AC-PL-13`. **Clean.**

---

## 9. Historical-verify-command discipline

Did not re-run the `AC-CI-*` / `AC-COMP-2` verify commands recorded at `docs/architecture.md:9673`,
`:9757-9760` (§F EXEMPT, append-only record of a closed cycle) — per the assignment's explicit caution
and the v2.19.9 precedent of lost time.

---

## 10. Public-artifact placement (this report)

`git archive HEAD | tar -tf - | grep '^docs/'` confirms the pre-existing 14-file leak (`docs/qa-report-
v2.18.0.md` … `v2.19.9.md`, `docs/security-{audit,review}-*`) — pre-existing per S4, not caused by this
cycle, not retrofitted here (owner-scoped, out of this cycle per spec). `docs/internal/` yields 0 hits
in the same archive listing. This report is written to `docs/internal/qa/qa-report-v2.19.10.md`, not
`docs/` root, per the binding §D.1 instruction. Shape follows `docs/qa-report-v2.19.9.md` (the most
recent QA report on this tree; no `docs/internal/qa/qa-report-v2.19.9.md` exists — v2.19.9 predates the
`docs/internal/` convention for QA reports).

---

## 11. Correction to the assignment brief itself

The assignment brief states *"`docs/patterns.md:55` (ambiguous-unit numeric claim) is at WATCH 2/3"* and
separately *"`docs/patterns.md:55` is at WATCH 2/3 for this cycle"* [claim-scope-wider row]. Independent
re-derivation (`grep -n` against the live file):

- `docs/patterns.md:55` — **"Claim scope wider than its verifying instrument"** — is at **WATCH 1/3**,
  not 2/3.
- `docs/patterns.md:56` — **"Ambiguous-unit numeric claim"** — is at **WATCH 2/3**, matching the brief's
  other reference.

Recorded per the binding "re-derive, never restate" rule. Not itself an AC-PL finding, and not something
I am promoting a row for at Phase 5 (that is Phase 8 territory) — flagged so the discrepancy is on the
record rather than silently carried forward.

---

## Findings summary

| # | Finding | Severity | Status |
|---|---|---|---|
| 1 | `WIZARD.md:132` `"Final bundle: [skills]. Continue?"` fails Q1 — `bundle` unrewritten, no inline definition | **BLOCKER** | Open — remedy in §1b-i |
| 2 | `context/.kit-migrations/` glossed only as "folder" in `self-apply`/`self-archive` rows | INFO | Not blocking |
| 3 | Group A negative-control claim ("current description and its truncation MUST fail Q1") holds for full descriptions and for `anti-ai-slop`'s truncation, but not for `prompt-gate`'s truncation | INFO | Precision correction only, does not affect post-edit PASS |
| 4 | Assignment brief's `docs/patterns.md:55` WATCH-count citation (2/3) does not match the live file (1/3) | INFO | Corrected in §11 |

## Verdict

**REJECTED.** 7 of 8 acceptance criteria (`AC-PL-1`, `AC-PL-2`, `AC-PL-4`, `AC-PL-5`, `AC-PL-6`,
`AC-PL-7`, `AC-PL-8`) verify clean against fresh, independently-built fixtures and diffs. `AC-PL-3`
fails on one of its own two in-scope spoken strings (`WIZARD.md:132`). This is a small, precisely
located, one-line fix — not a design defect and not grounds to revisit any other AC. **Remedy:** rewrite
the quoted string at `WIZARD.md:132` to drop or inline-define `bundle`, in the same register as the
fix already shipped at `WIZARD.md:114`. Re-run this report's §1b table (row 6 only) after the fix; no
other section of this report requires re-verification.
