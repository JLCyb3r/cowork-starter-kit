# QA Report — v2.19.10 "Plain Language"

## Phase: 5 (Testing)
## Date: 2026-08-20
## Tree graded (2nd pass): `release/v2.19.10-plain-language` @ `2bac293` (pushed, local == remote,
## base `fd00dd2`). 1st pass graded `5814e43` and REJECTED on `AC-PL-3`; `c4df850` recorded that
## verdict; `2bac293` is @dev's single-line fix, graded here.
## CI: `2bac293` run `32366807486` — conclusion `success`, 0 failed (all jobs `success` or
## expected-`skipped`, independently re-checked job-by-job, not read off the summary line alone).
## Prior: `5814e43` run `32364566078` success; `b67a883` run `32364229736` failure — job-level
## breakdown showed exactly ONE failed job (`Version Consistency Check`), fixed at `5814e43`.

## Status: **APPROVED**

Scope: `AC-PL-1` … `AC-PL-8` only, per `docs/spec.md`'s explicit acceptance-set table and the Phase-1.3
withdrawal of the `AC-PL-13` "@qa verifies at Phase 5" line. `AC-PL-9` … `AC-PL-13` were not tested;
their absence is not a coverage gap (spec's own instruction, independently confirmed — no other
artifact in this tree still points @qa at the deferred ACs).

---

## 0. Re-verification pass (2nd pass, `c4df850` → `2bac293`)

**The 1st pass's §1–§11 below are preserved unmodified as the historical record of what was found and
how.** This section documents the re-verification of @dev's fix and the two dispositions the
orchestrator asked to be made explicit. Nothing in §1–§11 is retracted; §1b-i's FAIL is superseded by
§0a below, not deleted.

### 0a. `WIZARD.md:132` re-read — FAIL clears, no new FAIL introduced

`git diff c4df850..2bac293 --stat` → `WIZARD.md | 2 +-`, 1 file changed — confirms the fix is exactly
the single line claimed, nothing else in the tree moved. Diff:

```
- Confirm final bundle once: "Final bundle: [skills]. Continue?" Wait for user confirmation...
+ Confirm final bundle once: "Here's the final list: [skills]. Continue?" Wait for user confirmation...
```

Extracted the new quoted string (`Here's the final list: [skills]. Continue?`) to a scratch file and
ran the same 34-term jargon regex used throughout this report: **0 hits.**

- **Q1:** No jargon-list stem match → does not fail.
- **Q2:** No other technical term present (`skills` is plain English, not listed) → does not fail.
- **Q3:** Meaning preserved — confirms the same final skill list before proceeding, same register as
  the `:114` fix (`"Here's what I'd install…"`) it was written to match → does not fail.

**FAIL clears. PASS.**

**No new FAIL introduced, confirmed two ways:** (1) the diff stat above proves no other line changed;
(2) re-ran the full F4-block jargon scan (`:114-146`) post-fix — the one remaining `bundle` hit at the
same relative line is `sed -n '132p'` → `grep -oiE bundle | wc -l` = **1**, and it is the
meta-prose lead-in *"Confirm final bundle once:"*, not the quote (pre-fix that line carried 2 hits —
meta-prose + quote — independently confirmed via `git show c4df850:WIZARD.md | sed -n '132p' | grep -oiE
bundle` → 2 lines of output). The meta-prose occurrence is out of scope by the same rule applied
throughout §1b, unchanged, and was never part of the finding.

### 0b. Explicit disposition — `WIZARD.md:129` and `:128`

Both ruled **OUT of scope**, recorded here rather than left silent:

**`:129` — `- **"Done" with no changes:** Accepted — install the proposed bundle as-is.`**
The quotes wrap `"Done"` only — a case-label matching what the *user* said, not a string *Claude*
speaks or displays (contrast with `:121`'s `**Done / keep all:** confirm to proceed.`, which sits
inside the enclosing `"Here's what I'd install…"` quote spanning `:114-121` and was already graded
in-scope/PASS as part of §1b string #1). The rest of the line (`Accepted — install the proposed bundle
as-is`) is Claude-facing behavioral instruction under the `**Edge cases:**` header (`:127`), structurally
parallel to `:128`/`:130`'s edge-case bullets, none of which are inside a quote or after `Display as:`/
`say:`/`respond:`. **OUT, by AC-PL-3's own textual scope rule and by the `CONTRIBUTING.md §
Runtime-string register` definition ("every spoken or quoted string").** Not a close call: even graded
IN, `"Done"` is a single common word with 0 jargon-list hits — it would trivially PASS either way, so
the ruling has no live consequence for this cycle's Status, only for the record.

**`:128` — `- **Empty bundle:** Minimum 1 skill. If user drops all suggestions, offer the Personal
Assistant bundle as a fallback.`**
No quotes anywhere on this line — `**Empty bundle:**` is a bolded case-label, not a quoted string, and
the rest is Claude-facing instruction. **OUT, same reasoning as `:129`, more clearly so** since there
is no quoted fragment to even debate. Confirmed via re-read of `:126-130` as one block (`**Edge
cases:**` header at `:126`, three bullets at `:127-129`) — this is the same section, same structural
class, as `:128` and `:129` both sit under it.

**Remaining `bundle`/`pool` occurrences named in the coordinator's message (`:110`, `:112`, `:125`,
`:134`) were already covered in §1b's original scan and disposed there as meta-prose/heading — not
re-litigated here since nothing about them changed.

### 0c. @dev's reported adjacent-check numbers — independently re-derived, not accepted on report

Every number below was re-run by me against the live `2bac293` tree, not read off @dev's commit
message:

| Check | @dev reported | Independently re-derived | Match |
|---|---|---|---|
| AC-PL-7 row 5: `never silently performs` | 1 | `grep -oF … WIZARD.md \| wc -l` → **1** | Y |
| AC-PL-7 row 5: `reversibly` | 1 | → **1** | Y |
| AC-PL-7 row 5: `never on its own` | 1 | → **1** | Y |
| AC-PL-7 row 6 Leg A half 1 (`:123`, scoped) | 1 | `sed -n '123p'` then `grep -oF … \| wc -l` → **1** | Y |
| AC-PL-7 row 6 Leg A half 2 (`:123`, scoped) | 1 | → **1** | Y |
| AC-PL-7 row 6 Leg B (file-wide) | 2 | → **2** | Y |
| AC-PL-7 row 6 anchor uniqueness | 1 | `grep -n 'No URL paste, no external source' WIZARD.md \| wc -l` → **1**, still at `:123` | Y |
| AC-PL-7(c) deny-list on `:123` | 0 | scoped `grep -oiE` of the 9-pattern deny-list → **0** | Y |
| AC-PL-7(c) deny-list on `:339` | 0 | scoped, same regex → **0** | Y |
| Numeral `25` at `:119` | verbatim | `sed -n '119p'` → *"…25 skills available…"* — verbatim | Y |
| TIER-1 (`scripts/`) | empty | `git diff --name-only fd00dd2..2bac293 -- scripts/` → **empty** | Y |
| TIER-2 (`cowork.lock.json`/`.cowork-allowlist.json`) | empty | → **empty** | Y |
| TIER-3 (`.github/CODEOWNERS`) | empty | → **empty** | Y |
| AC-PL-6 registry row count (unaffected, sanity re-check) | — | **30** (unchanged) | — |

**All 14 numbers held under independent re-derivation. No sixth cannot-fail instrument found in this
fix pass** — every check I re-ran used my own command against the live tree, not @dev's stated output,
and every one landed where claimed.

### 0d. Orchestrator's correction, confirmed

`docs/patterns.md:55` ("Claim scope wider than its verifying instrument") is at **WATCH 1/3**, `:56`
("Ambiguous-unit numeric claim") is at **WATCH 2/3** — matches §11 below, no further action needed here.

### 0e. Revised verdict

7/8 ACs were already clean at the 1st pass. `AC-PL-3` now clears on independent re-read, with no new
defect introduced and two previously-silent scope questions (`:128`, `:129`) now explicitly
dispositioned rather than left implicit. CI green at `2bac293` (job-by-job, not summary-only).

**Status flips to APPROVED.** §1's Findings Summary and Verdict (bottom of this report) are updated
accordingly; the original §1-§11 narrative above is left intact as the record of the 1st-pass finding
and its remedy.

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
| 6 | **`"Final bundle: [skills]. Continue?"`** | `:132` | **Y (1st pass)** | — | — | **FAIL at 1st pass, see §1b-i — FIXED, re-read PASS at §0a (now `"Here's the final list: [skills]. Continue?"`)** |
| 7 | Fast-track offer (*"Basics saved. 1) Keep going…2) Start now…"*) | `:145` | N | N | Y | **PASS** |
| — | Numeral `25` (*"25 skills available"*) | `:119` | N/A | N/A | Y | **PASS** — survives verbatim; the only instrument for this is this row (no CI job checks it). |

**1st pass: 6/7 spoken strings PASS, 1/7 FAILS — see §1b-i. 2nd pass (post-fix): 7/7 PASS — see §0a.**

#### 1b-i. BLOCKER at 1st pass (FIXED — see §0a) — `WIZARD.md:132`, `"Final bundle: [skills]. Continue?"` fails Q1

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
| 1 | `WIZARD.md:132` `"Final bundle: [skills]. Continue?"` failed Q1 — `bundle` unrewritten, no inline definition | **BLOCKER (1st pass)** | **FIXED at `2bac293`, re-read PASS — see §0a** |
| 2 | `context/.kit-migrations/` glossed only as "folder" in `self-apply`/`self-archive` rows | INFO | Not blocking |
| 3 | Group A negative-control claim ("current description and its truncation MUST fail Q1") holds for full descriptions and for `anti-ai-slop`'s truncation, but not for `prompt-gate`'s truncation | INFO | Precision correction only, does not affect post-edit PASS |
| 4 | Assignment brief's `docs/patterns.md:55` WATCH-count citation (2/3) does not match the live file (1/3) | INFO | Corrected in §11; orchestrator confirmed at §0d |
| 5 | `WIZARD.md:129` (`"Done"` case-label) and `:128` (`Empty bundle:` label) — AC-PL-3 scope disposition | N/A | **Ruled OUT of scope — explicit disposition at §0b** |

## Verdict

**APPROVED (2nd pass, tree `2bac293`).** All 8 in-scope acceptance criteria (`AC-PL-1` … `AC-PL-8`)
verify clean against fresh, independently-built fixtures and diffs. The 1st pass's single BLOCKER
(`AC-PL-3` failing on `WIZARD.md:132`) was fixed by a single-line, surgical edit (`git diff c4df850..
2bac293 --stat` confirms exactly 1 file / 1 line changed) and independently re-read clean at §0a — no
new FAIL introduced. The two scope questions the orchestrator flagged (`WIZARD.md:129`, `:128`) are now
explicit recorded dispositions (both OUT of scope, §0b) rather than silent omissions. @dev's 14 reported
adjacent-check numbers were independently re-derived, not accepted on report, and all 14 held (§0c). CI
green at `2bac293`, job-by-job (§0/header). No sixth cannot-fail instrument found in either pass.

**Recommendation: proceed to Phase 6 (`/audit`).**

---
---

# Phase 7 — Final Approval (composition read over the full range)

## Date: 2026-08-20
## Range verified: `fd00dd2..81e96d0` (whole cycle, all 18 commits: @architect's, @dev's, @qa's, @security's)
## Status: **APPROVED FOR MERGE (pending a PR being opened — see §7.6)**

Phase 5 above verified `AC-PL-1`…`AC-PL-8` at `2bac293`. Phase 6 (this file's Phase-6 sibling,
`docs/internal/security/security-audit-v2.19.10.md`) verified two more slices: `09bbced` and the delta
`09bbced..eaadeb6`. Three more commits landed after that (`3fd8a15` re-audit, `eaadeb6` remediation,
`81e96d0` final remediation) — **nobody had verified the composition as a unit.** This section does
that: every command below was re-run fresh against `81e96d0`, from a scratch directory, never against
the prior passes' record.

### 7.1 All 8 in-scope ACs, re-verified simultaneously at HEAD (`81e96d0`)

| AC | Instrument re-run at HEAD | Result |
|---|---|---|
| AC-PL-1 | Jargon scan (34-term list) on all 6 rows' `description` cells, extracted fresh via `awk -F'\|'` | `self-apply`/`self-archive`: 1 hit each, `context/.kit-migrations/` — same PASS-with-note as Phase 5's §1c, unaffected by the B1 wording change. `self-upgrade`/`pull-updates`/`prompt-gate`/`anti-ai-slop`: 0 hits. **HOLDS.** |
| AC-PL-2 | `sed -n '339p' WIZARD.md \| grep -oE '`[^`]+`'` → 11 backtick items; `grep -cF 'installed skills: [list]'` → 1 | 11 + 1 = 12, matching the `§D.2` pin exactly, post-B2 edit. **HOLDS.** |
| AC-PL-3 | `sed -n '132p'` (still *"Here's the final list…"*), row-6 anchor/leg checks below | Unaffected by rounds 2/3 — confirmed byte-identical since `2bac293`. **HOLDS.** |
| AC-PL-4 | `grep -c "Runtime-string register" CONTRIBUTING.md` → 1; scoped 4-line window in `spec.md:826` → 1, dated | **HOLDS.** (File-wide count in `spec.md` is 3, expected drift, already documented — did not restate it as the AC result.) |
| AC-PL-5 | `working-rules.md` Data locality clause, deny-list + both negative guarantees + all 6 categories | Unaffected since Phase 4 (`git diff --stat 5814e43..81e96d0 -- examples/` empty). **HOLDS.** |
| AC-PL-6 | `awk` valid-hex count → 30; `PARSER_COPIES` fragment count → 2; `\|\| true` present (B4) | **HOLDS.** |
| AC-PL-7 | Row 5: `never silently performs`/`reversibly`/`never on its own` each = 1 on `:339` post-B2; deny-list on `:339` = 0. Row 6: anchor unique at `:123`, leg A both halves present, leg B = 2, deny-list = 0. Row 1: 6/6 categories, 2/2 guarantees, deny-list 0. | **HOLDS — including row 5, the row the final round's own edit (B2) touched.** |
| AC-PL-8 | `ls examples/*/context/working-rules.md \| wc -l` = 7 (glob); 8-file explicit form used throughout | **HOLDS**, unchanged. |

**No regression found.** The three post-`09bbced` rounds (re-audit, two remediation commits) touched
`WIZARD.md`, `curated-skills-registry.md`, `CONTRIBUTING.md`, `PROMOTE.md`, `quality.yml`,
`skills/self-apply/SKILL.md`, and 3 canonicalization fixtures — every touched surface was re-verified
above and none moved an AC from GREEN to RED.

### 7.2 Third read — the rewritten safety-bearing descriptions, checked against the skills themselves

Not against @security's finding text, and not against @dev's commit message — against the actual
`SKILL.md` behavior. `git diff --name-only fd00dd2..81e96d0 -- skills/` shows exactly one file touched
(`skills/self-apply/SKILL.md`, the A1 anchor fix, body prose only — frontmatter and all cited security
mechanics byte-identical); `self-archive`, `self-upgrade`, `pull-updates` `SKILL.md` are untouched all
cycle, so reading them now is reading true ground truth, not a moving target.

- **B1 (`self-apply`/`self-archive` — "can never be changed or moved by this or any other skill").**
  Read `skills/self-archive/SKILL.md:16`: *"never itself apply-writable or move-eligible."* Read its
  namespace floor (§"The move-eligibility gate"): *"every `.claude/skills/**` file"* is move-denied —
  this covers `self-apply` on the move channel. Read `skills/self-apply/SKILL.md`'s own deny-list
  (§"The write-channel allow-list"): explicitly names `self-apply`, `self-archive`, `self-upgrade` as
  apply-denied — this covers `self-archive` on the apply channel. **Both registry claims are TRUE,
  verified against the mechanism, not the finding.**
- **B2 (`pull-updates` / `WIZARD.md:339` — "against the copies included with this kit on your own
  computer when you ask, and never on its own").** Read `skills/pull-updates/SKILL.md` §"No in-session
  network, ever": *"it never fetches anything over the network during a live session"*; §Triggers:
  *"**Never** a periodic or unsolicited inline suggestion — this flow only runs when explicitly asked
  (OQ4)."* The shipped sentence is accurate on both axes it asserts (locality, non-autonomy). **TRUE.**
- **Independently re-hashed:** `shasum -a 256 skills/self-apply/SKILL.md` →
  `0c77ab20779c79288eb35f3e1059955b566b3460456034b85dc87959a955e9f4`, byte-identical to the registry
  cell at `curated-skills-registry.md:31`. Not re-read off @dev's or @security's report — computed fresh.
- **B5's citation checked against its target:** `docs/design-v2.19.10.md`'s corrected attribution cites
  `qa-report-v2.19.10.md:272-278`; those lines are this file's own §2 row-6 anchor-existence guard
  narrative (typo'd-anchor simulation, fail-closed guard, `LINE=123` clean pass). The citation is
  accurate.

**No fourth defect found in this round's own fix.** The pattern this cycle repeatedly demonstrated —
the corrective action becoming the next defect — did not recur at `81e96d0`.

### 7.3 Deferred ACs — still deferred

- `git diff --stat -M fd00dd2..81e96d0 -- docs/` → 6 files changed, **0 renames**.
- `ls docs/ | grep -c 'qa-report\|security-review\|security-audit'` → **14**, unchanged from Phase 2.
- `grep -rln DEFERRED-TO-RETROFIT-CYCLE docs/` → 4 files (`architecture.md`, `design-v2.19.10.md`,
  `security-audit-v2.19.10.md`, `spec.md`) — marker present and greppable.
- `grep -c 'archive-leak\|AC-PL-9…13' .github/workflows/quality.yml` → **0** — no archive-leak gate was
  built. **Clean separation confirmed at HEAD, not just at the commit the prior passes read.**

### 7.4 Artifact placement — re-derived, with a correction to my own first pass

`git -C <repo> archive HEAD` into a scratch tarball, `tar -tf -`:

- `grep -c '^docs/internal/'` → **0**.
- **My first attempt at the report-path check used `grep -c 'v2\.19\.10'` and returned 1** —
  `docs/design-v2.19.10.md`, a design doc that legitimately ships at `docs/` root by this repo's own
  convention (every `design-vX.md` does). That is not a report leak; scoping the grep to the actual
  report-filename shapes (`qa-report`/`security-review`/`security-audit`) returns **0**, correctly.
  Recorded here rather than silently corrected, because shipping a claim one field wider than its own
  instrument is exactly the defect class this whole cycle is about, and it is worth catching in my own
  read, not just everyone else's.
- **Negative control on the corrected instrument:** the same report-path pattern without the version
  pin (`qa-report.*v2\.19\|security-review.*v2\.19\|security-audit.*v2\.19`) → **11** — the grep can
  return non-zero, confirming the **0** above means genuinely absent.
- This report and both `docs/internal/security/` reports are the only artifacts this cycle wrote; all
  three are confirmed absent from the archive.

### 7.5 CI — job by job at the actual merge candidate, `81e96d0`

Run `32374571984`: **31 success, 0 failure, 3 skipped** (the same three `pull_request`-gated jobs).
Read job-by-job via `gh run view --json jobs`, not off the summary conclusion.

### 7.6 What remains before an actual merge

**No PR exists yet for `release/v2.19.10-plain-language`** (`gh pr list --head ... --state all` → empty).
Per CLAUDE.md's pre-merge gate, `gh pr checks <PR>` must run fully green before a merge confirmation is
presented, and three CI jobs (`lock-content-sha-cross-check`, `/sync-agency Dry-Run`,
`Vendored Removal Ledger`) are `pull_request`-gated and have never executed against this exact tree.
**This is an orchestrator/process step, not a defect in the work** — consistent with @security's A16.
The QA verdict below approves the shipped bytes at `81e96d0`; opening the PR and re-confirming those
three jobs land green is the remaining mechanical step before the merge itself.

### Verdict

**APPROVED FOR MERGE.** All 8 in-scope ACs hold simultaneously at `81e96d0`, re-verified fresh rather
than composed from three prior partial reads. The rewritten safety-bearing descriptions (B1, B2) are
independently confirmed TRUE against the skills' own mechanics, not against any agent's account of
them. Deferred ACs remain cleanly unimplemented. Both internal reports and this one are confirmed
absent from the public archive, with a corrected (not merely trusted) negative control. CI is green,
job-by-job, at the actual candidate commit. The only remaining step is opening the PR itself.
