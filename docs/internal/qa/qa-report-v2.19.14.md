# QA Report — v2.19.14 "The Parser and the Premise"

## Phase: 5 (Testing)
## Date: 2026-08-29T10:41:27Z
## Status: PASS WITH NOTES — 0 blocking, 3 non-blocking findings

> **Provenance note (orchestrator).** Persisted by the orchestrator from `@qa`'s returned text.
> `docs/internal/qa/qa-report-v2.19.14.md` is **not writable by `@qa`** under current scope rules —
> verified twice: `orchestrator-guard.sh`'s `*/docs/qa-report*.md` is a suffix wildcard after the
> literal prefix `docs/qa-report` and cannot span the `internal/` path component, and `qa.md`'s own
> `scope_allow` regex `docs/qa-report\.md` does not match it either. `@qa` did not attempt the write
> and did not route around the block. Arranged before the phase opened, not discovered during it.

**Repo:** `/Users/macbookpro/claude-cowork-config`, branch `release/v2.19.14-ci-parser-and-premise`,
base/HEAD `a546292`. All cycle changes uncommitted in the working tree (7 modified, 2 untracked).

**Instrument declaration.** `/usr/bin/grep` by absolute path (bare `grep` on this host is a ugrep-family
shim). `-E` used wherever alternation appears. All shell reproductions ran under `/bin/bash`, never
`zsh`, per the D-3 shell-dependency finding. All adversarial/mutation testing ran on copies outside the
repo; the target repo was never mutated — confirmed by `git status --short` returning byte-identical
output to the session-start snapshot.

---

## Findings

| ID | Severity | Summary | Blocks Phase 6 |
|----|----------|---------|----------------|
| F-1 | INFO (self-corrected) | ADR-098's "Measured" table row for `tools: [.*]` is falsified — the real pre-fix verdict is REJECT, not `OK:.*` | **No** |
| F-2 | ISSUE (minor) | ADR-097 §Decision(3)'s "**both** re-derived rows carry the label" is not literally true — `:238` gets no verbatim label, and @dev's stated justification does not apply to `:238` | **No** |
| F-3 | ISSUE (minor, pre-existing, out of cycle scope) | `CONTRIBUTING.md:226,239` still reference `.markdownlint.json`, which does not exist in the repo — the same defect class as this cycle's Item 2, in an unaddressed location | **No** |

No blocking findings. The Tier A merge-gate change is independently verified against its own **real**
pre-fix and post-fix step bodies and the **real** 29-skill production corpus — not a replica, not a mock.

---

## (a) The parser fix, verified independently

**Method.** Pre-fix step body extracted via `git show a546292:.github/workflows/quality.yml`; post-fix
body read from the working tree. De-indented only, never rewritten. Each case ran by `cd`-ing into a
disposable fixture directory containing a real `skills/<name>/SKILL.md`, so the actual
`for skill_md in skills/*/SKILL.md` glob and the actual unquoted `for token in $TOKENS` loop fire.

| Case | Pre-fix | Post-fix |
|---|---|---|
| N=1 | pass | pass |
| N=2 `[claude-code, copilot]` | **REJECT** `invalid token 'claude-codecopilot'` | pass |
| N=3 | **REJECT** `'claude-codecopilotcursor'` | pass |
| `tools: []` | wrong message (multi-line misdiagnosis) | `declares no tools (empty array)` |
| multi-line form | wrong message `invalid token 'tools:'` (`CF-v2.5-A` residue) | correct MF-S1 message |
| duplicate `tools:` keys | **exit 0 — silently accepted** | `declared 2 times (duplicate key)`, exit 1 |
| `code` · `claude` · `claude.code` · `cursor*` · `c?p?l?t` (with a real `copilot` file) | **all exit 0 — five live bypasses** | all refused by name |
| `.*` | rejects (see F-1) | refused by name |
| `emacs` (control) | reject | reject |

**Production validation.** The post-fix step run against the repo's real `skills/` directory:
`MF-3 tools: vocabulary gate passed (29 skills checked)`, exit 0. The pre-fix step also passes 29/29 —
D-1/D-2/D-3 are latent-but-real, not yet triggered by shipped content.

**S19 regression fixture proven discriminating.** On a copy outside the repo, the `case` pattern's
quoting was deliberately removed (`case " $ALLOWED " in *" $token "*)` → `case $ALLOWED in *$token*)`)
and `tools: [*]` re-run: **silently ACCEPTS**, while control `emacs` still rejects. The fixture
therefore catches the exact plausible future edit it exists to catch.

**Fairness rule honoured.** No pure-mock evidence anywhere in this AC's coverage. `@dev`'s own
`tests/mf3-tools-vocabulary-gate-firing-controls.md` uses the identical extraction method and its
RAN-stamped outputs reproduce byte-for-byte against an independent re-run.

---

## (b) Verdict on the `tools: [.*]` falsification — @dev is correct

Reproduced in a fresh fixture directory: the unquoted `for token in $TOKENS` loop glob-expands the
literal `.*` against the shell's own `.` and `..` entries — present in **every** directory — and both
pseudo-tokens are individually rejected. Real pre-fix end-to-end verdict: **REJECT**.

The isolated probe that produced the ADR's claim was also reproduced: with `token='.*'` assigned
directly, `grep -qw` receives the literal two-character BRE `.*`, which matches the whole `ALLOWED`
line → ACCEPT. **True of `grep -qw` in isolation; false of the pipeline**, because the token never
reaches `grep -qw` as `.*` in the real script.

**The D-2 vulnerability is untouched.** It is independently demonstrated by five other tokens, all
reproduced as live exit-0 silent accepts pre-fix. The vulnerability class is real; one of its six
advertised example strings is not a working instance of it. The candidate's correctness is unchanged —
post-fix, `.*` is rejected for the right reason (literal `case` membership).

**Disposition — INFO, non-blocking.** A documentation-accuracy defect in an ACCEPTED Tier A record,
not a code defect and not a security regression. Per the repo's append-only convention the remedy is a
note, not an edit. `tests/mf3-tools-vocabulary-gate-firing-controls.md` §E already carries this exact
falsification — @dev disclosed it in real time rather than adopting the ADR's table.

---

## (c) Verdict on the ADR-097 / ADR-098 retention conflict — right for `:223`, incompletely justified for `:238`

**`:223` — correct call.** Full verbatim retention would have reproduced `OVERDUE` and
`never been performed`, which ADR-098 §Decision(7)'s control requires reach 0. Retaining only the
"51 days" fragment quoted, and paraphrasing the rest, was the only choice compatible with the shipped
gate-approved control — and it matches ADR-097's own supporting paragraph, which names only that phrase
as surviving. **The apparent conflict largely dissolves on close reading: ADR-097's summary sentence
overstates what its own supporting paragraph specifies.**

**`:238` — right result, wrong clause cited.** `:238`'s original text contained neither the capitalised
`OVERDUE` nor `never been performed` (`grep -c 'OVERDUE'` → 0 on it, case-sensitive). **Nothing in the
control would have failed had `:238` kept its phrase verbatim under the same label.** @dev's stated
rationale therefore does not apply to `:238`, and ADR-097 §Decision(3) plainly says "**Both** re-derived
rows carry the superseded text under that same label" — only one does.

Not blocking: no information a future reader needs is lost — the `CF-v2.5-F` / `CF-v2.5-ARCH-D` pairing
is preserved in the new prose, and ADR-097 §Decision(4) gives `:238` a narrower row-specific instruction
that is a **more defensible ground** for the lighter treatment than the one @dev cited. Right result
reached by citing the wrong clause of a two-clause ADR.

**Recommendation (F-2, non-blocking):** at the next touch, either add the retained-verbatim label to
`:238`, or amend ADR-097 so §Decision(4) explicitly supersedes §Decision(3)'s "both rows" language —
so the record stops asserting something the shipped row does not do. That is this cycle's own failure
pattern recurring at much lower stakes.

---

## (d) The four-assertion `CF-v2.5-F` control

| Assertion | Pre (`a546292`) | Post | Required |
|---|---|---|---|
| `2026-06-04` | 0 | 2 | 0 → ≥1 ✅ |
| `OVERDUE` | 1 | 0 | 1 → 0 ✅ |
| `never been performed` | 1 | 0 | 1 → 0 ✅ |
| `ADR-097` | 0 | 2 | 0 → ≥1 ✅ |

**Discrimination proven by construction**, on a copy outside the repo. A cosmetic-only edit deleting
just the two "51 days" phrases leaves `**ORPHANED — OVERDUE**` and `has never been performed` standing:

```
2026-06-04           -> 0   (required >=1)
OVERDUE              -> 1   (required 0)   <- RED
never been performed -> 1   (required 0)   <- RED
ADR-097              -> 0   (required >=1)
```

The control fails a cosmetic fix on all four assertions. Proven directly, not by trusting ADR-098's
claim about it.

---

## (e) The doc corrections

- **`docs/roadmap.md:44`** — the falsified predicate is replaced; the conclusion survives verbatim in
  substance (*"must still be demonstrated firing through the second entry point (`self-upgrade`)"*).
- **OT-4** — worded against the condition, not a date. Tag date verified: `v2.19.5` → 2026-08-04.
- **OT-6** — `v2.21` → **0** in `docs/roadmap.md`; control `v3.0` → **13**. Matches.
- **OT-8** — recorded as a past breach. All three tag dates verified (`v2.19.4` 2026-08-03,
  `v2.19.5` 2026-08-04, `v2.19.6` 2026-08-07); `tests/offline-smoke-test.md` carries exactly one
  scorecard entry (2026-07-18), confirming "no intervening entry."
- **Three ADRs** flipped `PROPOSED ⚠ NOT IN FORCE` → `ACCEPTED` at both section-header and index-row.

---

## (f) Append-only discipline — proven, not eyeballed

```
$ git diff -U0 docs/architecture.md | grep -E '^@@'
@@ -116 +116 @@            <- ADR-093 index row
@@ -118 +118,4 @@          <- ADR-095 index row + 3 new index rows
@@ -16104,0 +16108,742 @@  <- pure append at EOF
```
Arithmetic closes exactly: 1+1+0 = 2 deletions, 1+4+742 = 747 insertions, matching `--stat`. **No other
hunks exist.**

Field-by-field, via byte-offset divergence + MD5 of the common prefix:

| Row | `cmp` differs at | MD5 of common prefix, pre vs post |
|---|---|---|
| ADR-093 `:116` | char 1407 — the start of the Status cell | `b9ddbe2d…` = `b9ddbe2d…` ✅ |
| ADR-095 `:118` | char 3163 | `ac746232…` = `ac746232…` ✅ |

**Only the Status cell of each index row changed; every other field and every ADR body is
byte-identical to the base commit.**

---

## (g) Scope — clean

`tests/self-upgrade-firing-controls.md` is **absent from the changed-file list**, so no new `RAN` stamp
could have been added. `docs/internal/carry-forwards.md` is exactly `2 insertions / 2 deletions` — the
`:223` and `:238` rows only. `docs/risk-register.md` untouched. No repo-settings files. No npm version
pin added (`scripts/install-pre-commit.sh` is a 5-site repoint only), matching ADR-098 §Maturation
Path (iii)'s deferral.

---

## (h) Egress — clean

`git archive HEAD | tar -t` → **419** entries; `docs/internal/` → **0** (negative control holds).

| File | Ships? |
|---|---|
| `docs/architecture.md` · `docs/roadmap.md` · `docs/owner-tasks.md` | **Yes** |
| `docs/spec.md` · `docs/internal/carry-forwards.md` · `.github/workflows/quality.yml` · `scripts/install-pre-commit.sh` | No |

All results re-derived from `.gitattributes` directly rather than trusting prior claims.

---

## What Phases 0-4 got wrong, re-run this session

- **ADR-098's "Measured" table, `tools: [.*]` CURRENT column** — falsified (§b). Already self-disclosed
  by @dev; the independent reproduction confirms @dev's note exactly and finds no further error in it.
- **Nothing else.** Every other number re-run independently reproduced exactly as claimed by its author
  (@architect, @pm, @security, @dev, orchestrator): the eight four-assertion counts, the `v2.21`/`v3.0`
  roadmap counts, three git tag dates, the smoke-test scorecard date and uniqueness, the 419-entry
  archive total, the 5-site repoint count, and the row-scoped `dormant` counts (0 on OT-4's row, 1
  unchanged on OT-7's). F-2 and F-3 are gaps nobody had checked, not falsifications of claims made.

---

## Verdict

**PASS WITH NOTES.** All three named defects (D-1 tokenizer collapse, D-2 `grep -qw` regex/substring
bypass, D-3 unquoted pathname-expansion bypass) are reproduced live pre-fix and confirmed closed
post-fix, including the S17 duplicate-key and S19 case-quoting hardenings folded in at the gate. The one
falsification found in Phase 0-4's own work is self-corrected and does not touch the shipped fix's
correctness. The four-assertion control is proven discriminating by construction. Append-only discipline
is proven field-by-field. Scope and egress clean.

**Recommend: proceed to Phase 6 (`/audit`).**

Delegation: haiku=0 sonnet=1 opus=0 missed=0.
