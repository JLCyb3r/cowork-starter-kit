# Security Audit — v2.19.14 "The Parser and the Premise"

> **Provenance note (orchestrator).** Persisted by the orchestrator from `@security`'s returned
> text — `docs/internal/security/security-audit-v2.19.14.md` is not writable under `@security`'s
> scope rules (the allow-list cannot span the `internal/` path component). The agent did not
> attempt the write and did not route around the block. This was a **fresh** auditor instance,
> deliberately not the one that wrote the Phase-2 review.


## Phase: 6 (Code Audit)
## Date: 2026-08-29T11:15:00Z
## Repo: `jmlozano1990/Cowork-Starter-Kit` @ `release/v2.19.14-ci-parser-and-premise`, base `a546292`, uncommitted working tree
## Classification: SECURITY-SENSITIVE / Tier A — **independently confirmed** (merge-gate logic in `.github/workflows/`)
## Status: **PASS WITH WARNINGS** — 0 blocking, 7 warnings, 9 info

**Instrument declaration.** `/usr/bin/grep` by absolute path (BSD grep 2.6.0-FreeBSD); `-E` used for every alternation. Bare `grep` on this host is a ugrep shim. Shell probes under `/bin/bash` (3.2.57) **and** `/opt/homebrew/bin/bash` (5.3.15, closer to ubuntu-latest), each with `PATH=/usr/bin:/bin` pinned so the step body resolves BSD/POSIX tools deterministically. Locales `C` and `C.UTF-8` both exercised. All fixtures and mutated step bodies were built under `/private/tmp/.../scratchpad/mf3/`; **the repo was never mutated** — the one place a commit was needed (egress, §e) used a full `cp -R` copy outside the repo, deleted afterward. Every zero below carries a firing negative control.

---

## Findings Summary

| ID | Severity | Surface | Summary | BLOCKS MERGE |
|----|----------|---------|---------|--------------|
| A1 | WARNING | permissions | **No CI check is required to merge `main`.** MF-3 — and all 34 other jobs — are advisory. Pre-existing config, but it reframes "merge-enforcement gate". | **No** |
| A2 | WARNING | configuration | **Intra-token whitespace is deleted before the membership test.** `tools: [claude -code]` and 4 sibling forms ACCEPT. Prior passes tested mash-*out*, never mash-*in*. | **No** |
| A3 | WARNING | configuration | **The gate's success message counts a population it does not check.** `skills/x/y/SKILL.md` with `tools: [evil]` passes; message reads "2 skills checked". Pre-existing. | **No** |
| A4 | WARNING | schema | **ADR-098's stated rationale for scoping `set -f` is false.** Step-scoped `set -f` hard-fails; it never "passes vacuously". 3 sites, incl. the shipped comment. | **No** |
| A5 | WARNING | schema | **ADR-097 §Decision (5)'s own line citations do not resolve** in the file it ships in — moved 3 lines by insertions in the same commit. | **No** |
| A6 | WARNING | schema | **F-2 confirmed.** ADR-097 §Decision (3) mandates the retained-verbatim label on **both** re-derived rows; `:238` has none — the prior rationale is erased, not recorded. | **No** |
| A7 | WARNING | process | **Hand-written phase timestamps are local CEST labelled `Z`** — the record shows Phase 1 *after* Phase 3 and Phase 2 in the future. This is the audit trail of the owner's Tier A approval. | **No** |
| A8 | INFO | configuration | **F-3 confirmed — and I disagree with "out of cycle scope."** `CONTRIBUTING.md:226,239` are sites 6 and 7 of the same rename; `:239` is copy-pasteable and unguarded. | No |
| A9 | INFO | schema | **The falsified `.*` measurement ships; its falsification does not.** Wrong claim in `docs/architecture.md` (ships); correction in `tests/` (`export-ignore`d → 0 entries). | No |
| A10 | INFO | schema | **"control `v3.0` → 13" is a line count presented as an occurrence count** (true: 22). Ships in `owner-tasks.md`. Conclusion unaffected. | No |
| A11 | INFO | configuration | **Phase-2 S18 reproduces, inconsistently:** `[claude-code,]` ACCEPTs, `[claude-code, ]` REJECTs. One space decides. | No |
| A12 | INFO | configuration | **Phase-2 S7 reproduces:** the gate certifies files with no valid frontmatter. Bounded — cannot smuggle a disallowed token. | No |
| A13 | INFO | logging | **Internal-report content quoted verbatim into shipping docs.** No new disclosure (repo is public), but this is how the ADR-088 leak family began. | No |
| A14 | INFO | dependency | **The deferred `npm install -g` row is lower-risk than its name.** The script never runs npm — it is unpinned *advice*, not an unpinned install. Deferral still right. | No |
| A15 | INFO | process | **CHANGELOG.md / README.md untouched**, against this repo's own PR convention and its declared CHANGELOG↔tag↔Release invariant. | No |
| A16 | INFO | process | **(g) the phantom write is a tooling matter, with one audit consequence** — the single place record and bytes disagree (A6) has exactly the shape a dropped write leaves. | No |

---

## (a) Re-execution of the Tier A change against the shipped bytes

**Method — bytes, not narrative.** The step body was extracted mechanically from the working tree, not retyped:

```
/usr/bin/sed -n '1162,1242p' .github/workflows/quality.yml | /usr/bin/sed 's/^          //'
→ 81 lines, md5 254289e88b967f445e449ecbac3d9584, `bash -n` clean, 0 residual-indent lines
```

The pre-fix body was extracted the same way from `git show a546292:.github/workflows/quality.yml` (lines 1162–1201, 40 lines). Both were run by a `/bin/sh` runner that `cd`s into a sandbox and `exec "$BASH_BIN" -e "$STEP"` — reproducing GitHub's default `bash -e {0}`. 46 fixtures + 7 ADR-claim fixtures + 5 frontmatter-validity fixtures, byte-exact via Python.

### Result — 46-fixture matrix, shipped body

Identical ACCEPT set under **bash 3.2 / `LC_ALL=C`** and **bash 5.3 / `LC_ALL=C.UTF-8`**. No version or locale sensitivity.

**Firing negative control:** fixture `03 NEGCTRL-evil` (`tools: [evil]`) → `rc=1`, `::error::… contains invalid token 'evil'`. The check can go RED.

### The three defect classes — closed, each with a control proving it was real

I did not take the defects on trust. I ran the **pre-fix body** against the same fixtures in the same sandbox:

| Class | Fixture | Pre-fix (`a546292`) | Shipped |
|---|---|---|---|
| **D-1 tokenizer collapse (N≥2)** | `tools: [claude-code, copilot]` | **REJECT** — `invalid token 'claude-codecopilot'` | **ACCEPT** ✓ |
| D-1 | `tools: [claude-code,copilot]` | **REJECT** — same fused token | **ACCEPT** ✓ |
| **D-2 `grep -qw` regex** | `tools: [claude.code]` | **ACCEPT** ✗ | **REJECT** ✓ |
| D-2 regex | `tools: [cursor*]` | **ACCEPT** ✗ | **REJECT** ✓ |
| **D-2 `-w` substring** | `tools: [code]` | **ACCEPT** ✗ | **REJECT** ✓ |
| D-2 substring | `tools: [claude]` | **ACCEPT** ✗ | **REJECT** ✓ |
| D-2 | `tools: [claude\-code]` | **ACCEPT** ✗ | **REJECT** ✓ |
| **D-3 pathname expansion** | `tools: [c?p?l?t]` + decoy file `copilot` in cwd | **ACCEPT** ✗ | **REJECT** ✓ |
| bracket injection | `tools: [[c]laude-code]` | **ACCEPT** ✗ | **REJECT** ✓ |
| multi-line flow | `tools: [claude-code,` / `  evil]` | **ACCEPT** ✗ | **REJECT** ✓ |
| **S17 duplicate key** | two `tools:` lines | **ACCEPT** ✗ | **REJECT** ✓ (`declared 2 times (duplicate key)`) |

**Ten inputs that the pre-fix gate accepted are now refused. Zero inputs that it refused are now accepted, except the two legitimate N≥2 lists — which is the point of `AC-PARSE-1`.**

### S17 and S19 — present, and proven load-bearing by counterfactual

Per the repo's own discipline, I `sed`-mutated **copies** of the step body outside the repo rather than editing anything:

| Mutation | What it removes | Effect |
|---|---|---|
| **M1** `*" $token "*)` → `*$token*)` | S19's quoting | `tools: [*]`, `[c?p?l?t]`, `[code]`, `[claude\-code]` all flip to **ACCEPT**. S19's quoting is the only thing holding those four. |
| **M2** `-ne 1` → `-gt 999999` | S17's duplicate-key count | `tools: [claude-]` + `tools: [code]` flips to **ACCEPT** — the mash lands on `claude-code` while a YAML parser reads `[code]`. S17 closes a real duplicate-key bypass. |
| **M3** `set -f` → no-op | D-3 protection | `tools: [c?p?l?t]` flips to **ACCEPT**. `set -f` is load-bearing. |
| **M4** `set -f` hoisted to step scope | the scoping | **Not a vacuous pass** — see A4. |

### Production corpus

Real `skills/` copied out of the repo (29 dirs), shipped step run against it under bash 5.3 / `C.UTF-8`:

```
MF-3 tools: vocabulary gate passed (      29 skills checked).
exit=0
```

**29/29 confirmed independently.** No fixtures, no mocks.

---

## (b) Attacking the `case` construction — what I found that prior passes did not

### A2 — WARNING: the membership test runs on a whitespace-stripped token, so the gate accepts values that are not in the vocabulary

```bash
token=$(printf '%s' "$raw" | tr -d '[:space:]')
```

`tr -d '[:space:]'` deletes whitespace **inside** an element, not just around it. Verified ACCEPT on the shipped body, both bash versions, both locales:

| Fixture | `tools:` value in the file | Token tested | Verdict |
|---|---|---|---|
| 18 | `[claude -code]` (U+0020) | `claude-code` | **ACCEPT** |
| 19 | `[claude<TAB>-code]` | `claude-code` | **ACCEPT** |
| 20 | `[claude<CR>-code]` | `claude-code` | **ACCEPT** |
| 21 | `[claude<VT>-code]` | `claude-code` | **ACCEPT** |
| 22 | `[claude<FF>-code]` | `claude-code` | **ACCEPT** |

The gate's guarantee is therefore **"every element, with all whitespace deleted, is one of four"** — not "every element is one of four". A YAML parser reads `claude -code`, a string not in the closed vocabulary, on a file CI certified.

Prior passes covered mash-**out** (`[claude-code copilot]` → `claude-codecopilot` → refused). Nobody tested mash-**in**, where the deletion lands *on* an allowed token. That asymmetry is the gap.

**Why it is WARNING and not CRITICAL:** `tools:` has no runtime consumer at v2.5 — `docs/spec.md:219` is explicit ("Wizard reads `tools:` as informational only at v2.5. Routing branch is v3.0 scope"). Nothing today reads the value the gate certified. But the gate exists precisely to keep the vocabulary closed *ahead of* v3.0 routing, and this is the same defect class the cycle was opened to close.

### Everything else I attacked, and what it did

| Vector | Result |
|---|---|
| Token containing literal `*` / `?` | **REJECT** — quoted expansion in the pattern is literal. M1 proves this is the quoting, not luck. |
| Token containing `]` | **REJECT** at the shape precheck (`[^][]*` excludes both brackets). |
| `IFS` manipulation | Not reachable. `case` takes a single WORD; `" $ALLOWED "` is not word-split. `IFS=$_oldifs` is an assignment RHS — no splitting, no globbing. Restore always runs (no `continue` escapes the outer loop after `set -f`). |
| Locale (`C` vs `C.UTF-8`) | Identical accept set. |
| NBSP / ZWSP inside token | **REJECT** — `tr` is byte-oriented; multibyte chars survive and break the match. |
| **NUL** inside token | **REJECT** — command substitution drops the NUL, the residue fails the shape precheck. |
| Embedded newline → multi-line `TOOLS_LINE` | Not reachable past the count check. `printf '%s\n' \| wc -l` counts correctly; command substitution strips trailing newlines so the off-by-one cannot occur. CR-only and CRLF files → **REJECT** (`^---$` never matches → fail-closed). BOM → **REJECT**. |
| Extremely long token (200 000 chars) | **REJECT**, no crash, no hang. |
| Command/parameter expansion of token content — oracle test | **No expansion.** `` `echo claude-code` `` and `$(echo claude-code)` would have become `claude-code` and ACCEPTed if expanded; both printed back literally and REJECTed. Same for `claude-code;echo hi` and `$ALLOWED`. Word splitting does not re-evaluate. |
| Case variance (`Claude-Code`) | **REJECT** — stricter, correct. |
| Nested `tools:` under another key + valid top-level | ACCEPT. The nested key is not `tools:`; nothing consumes it. Not a bypass. |
| `tools:` in the body after valid frontmatter | ACCEPT — correct; `awk`'s `c==1` window matches frontmatter semantics. |

### A3 — WARNING: the success message counts a population the loop does not check

```bash
for skill_md in skills/*/SKILL.md; do …          # one level
SKILL_COUNT=$(find skills -name "SKILL.md" | wc -l)   # recursive
```

Demonstrated in the sandbox: `skills/t/SKILL.md` (valid) + `skills/x/y/SKILL.md` (`tools: [evil]`) →

```
MF-3 tools: vocabulary gate passed (       2 skills checked).
exit=0
```

The nested file is checked by **no** job: `skill-depth-check`'s POOL loop uses the same one-level glob (`:996`) and the same recursive `find` for its message (`:1021`); `registry-sha256-check` iterates registry slugs; `registry-cardinality-check` is a `>= 18` **minimum**, so an extra file cannot trip it; `Verify folder/SKILL.md format` is scoped to `examples/*/.claude/skills`, not `skills/`.

Today `find skills -name SKILL.md | wc -l` = 29 and `ls skills/*/SKILL.md | wc -l` = 29, so nothing is currently unchecked. Pre-existing — identical at `a546292`. This is a count reported as a boundary.

---

## (c) `scripts/install-pre-commit.sh`

**Exactly 5 sites, 5 added / 5 removed, nothing else.** Read the whole file (75 lines), not just the diff:

| Line | Kind | Change |
|---|---|---|
| 21, 24, 25 | comment | `.markdownlint.json` → `.jsonc` |
| **59** | **functional** | `CONFIG="${REPO_ROOT}/.markdownlint.jsonc"` |
| 71 | printed output | reworded ruleset line |

**Nothing unintended can execute.** No new command, no network call, no `eval`, no variable expansion added. The hook heredoc is quoted (`<<'HOOK'`), so `${REPO_ROOT}` is still resolved at hook-run time by `git rev-parse`, not baked in at install time — unchanged. `chmod +x`, `cp` backup, `set -euo pipefail` — all unchanged. The premise the fix corrects is real: `.markdownlint.jsonc` exists at the repo root and `.markdownlint.json` does not, so the pre-change hook always took the `else` branch and silently applied markdownlint defaults.

**A14 — the deferred `npm install -g markdownlint-cli` row: confirmed untouched, and lower-risk than its name.** The two occurrences are `:16` (a comment in the manual procedure) and `:41` (an error message printed when `command -v markdownlint` fails). **The script never invokes npm.** It is unpinned *advice*, not an unpinned install — no supply-chain execution happens inside this script under any input. The deferral still looks right to me, and I would go further: the row should be re-scoped from "pin the install" to "pin the version the *docs* tell a contributor to install", because that is all that is actually in this repo's control.

**A8 — F-3 belongs in this cycle.** `CONTRIBUTING.md:226` and `:239` are sites **6 and 7** of the same rename. `:239` is worse than `:226`: it is a copy-pasteable manual hook with **no `if [ -f ]` guard** (unlike the script's `:61`), passing `--config "${REPO_ROOT}/.markdownlint.json"` unconditionally under `set -euo pipefail`. A contributor who follows the documented alternative gets a hook pointed at a file that does not exist. It is 2 lines, docs-only, in an `export-ignore`d file (cannot touch the release archive), and not a Tier A surface. Deferring it to its own row costs more ceremony than the fix, and leaves the repo internally contradictory: the script now says `.jsonc`, CONTRIBUTING says `.json`.

Separately, **Phase-2's S12 survives the fix as predicted**: `install-pre-commit.sh:4` and `:54` still claim "the same markdownlint ruleset as the CI `markdown-lint` step". After this change the *config file* matches; the *file set* is governed by `.markdownlintignore` (`docs/`, `vendored/agency-agents/`) versus CI's action `globs` (`!docs/**`, `!vendored/agency-agents/**`) — which do appear to line up, but by two different mechanisms.

---

## (d) Doc corrections — do any of them overstate?

### The two the brief named: **no.**

**ADR-096 does not read as though v3.0's second-entry-point obligation is discharged.** §Decision (1) is unambiguous: *"It remains binding that v3.0 must demonstrate the Loop 1 behavioral controls firing through the SECOND entry point (`self-upgrade`), in re-runnable, `RAN`-stamped form. Nothing in this ADR discharges, weakens, defers, or narrows that obligation."* §Decision (4) then **refuses to adjudicate** the discharge and names the exact tension (control (b) says `self-upgrade`; Scenario 4 drove `self-apply`). The `docs/roadmap.md:44` correction carries the same posture: *"must still be demonstrated firing through the second entry point"* and *"a reduction in work, not in obligation."*

Every citation reproduces:

| Claim | Re-derived |
|---|---|
| `qa-report-v2.19.0.md:46/55/70` | All three present, text matches quoted form |
| control (b) has no `RAN`; 13 `RAN` in the file | `grep -c 'RAN '` → **13**; control (b) at `:97-108` confirmed unstamped, and its own text does say *"@qa should invoke `self-upgrade`"* |
| `SECGATE-B1` in zero files under `tests/` | **0.** Firing control: bare `SECGATE` → **2** |

**`CF-v2.5-F` does not read as though a security obligation was met.** It reads *"CLOSED — CONDITION NEVER FIRED"* and *"The condition never occurred: no escalation was ever owed, and none was missed."* That is the accurate framing, and the underlying facts re-derive exactly:

```
gh api repos/msitarzewski/agency-agents/pulls/521
→ created_at 2026-05-09T15:31:53Z, merged true, merged_at 2026-06-04T00:27:27Z
```

2026-05-09 + 60 days = 2026-07-08 (the stated trigger); merged 26 days into the window, 34 days before the trigger. Every number in the row is right.

I also re-ran the three `docs/owner-tasks.md` status corrections, **which the brief did not enumerate** — OT-4, OT-6, OT-8 all changed status in place, and `owner-tasks.md` **ships in the release archive**:

| Claim | Re-derived |
|---|---|
| OT-4: "Rung 1 shipped at tag `v2.19.5`, 2026-08-04" | tag `v2.19.5` → **2026-08-04** ✓ |
| OT-6: `v2.21` → 0 in `docs/roadmap.md` | **0** ✓ |
| OT-8: tags 2026-08-03 / -08-04 / -08-07 | `v2.19.4`/`v2.19.5`/`v2.19.6` ✓ exactly |
| OT-8: last scorecard 2026-07-18, pre-dating all three | `tests/offline-smoke-test.md:49` → **Run date: 2026-07-18** ✓ |

### Four places where the record **does** overstate or misstate

**A4 — the `set -f` rationale is false.** Three sites claim a step-scoped `set -f` would make MF-3 *"pass vacuously"*:

- `.github/workflows/quality.yml:1171` — *"would make this whole check pass vacuously on every run (BINDING: a check that cannot fail is not a check)"*
- `docs/architecture.md:121` (ADR-098 index row)
- `docs/architecture.md:16653-16654` (ADR-098 body)

Re-executed with `set -f` hoisted to step scope (mutation M4):

```
with errexit (what CI runs):  awk: can't open file skills/*/SKILL.md → rc=2
without errexit:              ::error::skills/*/SKILL.md missing tools: … → exit 1
```

**It fails loudly in both shells. It never passes.** The design decision is correct — the enclosing `for` glob is evaluated before the loop body, so hoisting `set -f` breaks it — but the reason given is wrong, and it invokes this repo's BINDING *check-that-cannot-fail* principle on a false premise. A future maintainer who tests the claim and finds it false has a standing invitation to "fix" the scoping.

**A5 — ADR-097 §Decision (5)'s own citations do not resolve in the file it ships in.** It says *"`docs/architecture.md:15422` and `:15557` are superseded by this ADR, never edited."* Verified:

```
git show a546292:docs/architecture.md | sed -n '15422p;15557p'
  → "which was **51 days** past due at this cycle's base — computed, not estimated. …"
  → "  and an escalation date pass by 51 days unnoticed. …"

sed -n '15422p;15557p' <working tree>
  → "sweep of `scripts/`, `.github/`, `skills/` and `templates/` for any of the six returns **zero** hits —"
  → "  planning cycles, and a reader who trusts it without following its per-row citations can act on a stale"
```

The three index rows inserted at `:118` **in this same commit** moved the claims to `:15425` / `:15560`. The citation was wrong the moment it was written. `docs/spec.md:11340-11341` carries the same stale numbers (mitigated there by quoting the text alongside). `carry-forwards.md:223`/`:238` are stable and correct.

**A6 — F-2 confirmed and re-derived.** ADR-097 §Decision (3): *"**Both re-derived rows carry the superseded text under that same label.**"* Shipped bytes: `:223` carries *"Original status text, retained verbatim: …"*; `:238` carries **no label and no verbatim text** — the superseded rationale (*"which is 51 days overdue — the same upstream PR"*) is paraphrased away. That is erasure where the governing ADR mandated retention, and it inverts the exact property ADR-093 valued ("adds a record rather than erasing one"). Cheapest correct fix is to add the label to `:238`, not to soften Decision (3) to match the bytes.

**A7 — the phase timestamps are local time labelled `Z`.** ADR-096 and ADR-097 both read: *"ACCEPTED (v2.19.14 Phase 3, 2026-08-29T10:01:15Z — was PROPOSED at Phase 1, 2026-08-29T11:34:00Z)"* — Phase 1 is **93 minutes after** Phase 3. `docs/internal/security/security-review-v2.19.14.md` is dated `2026-08-29T13:20:00Z`. My wall clock at audit start was `2026-08-29T10:46:01Z` and `11:06:09Z` mid-audit — so the Phase 2 review is stamped **~2 hours in the future**.

The pattern is coherent: CEST (UTC+2) hand-written and suffixed `Z`. `13:20` → `11:20Z`; `11:34` → `09:34Z`. The machine-generated stamps (`09:05:19Z`, `10:01:15Z`, seconds precision) are genuine UTC. **This matters more than a cosmetic date bug:** the Tier A ceremony's evidence that these ADRs crossed the owner gate as PROPOSED and were flipped at the gate *is* this timestamp pair, and as shipped it says the opposite.

**A9 — the falsified `.*` measurement ships; its falsification does not.** `docs/architecture.md:121` lists `.*` among tokens that *"all ACCEPT"* pre-fix, and `:16716` records `tools: [.*] | OK:.* | BAD:.*`. Independently re-run against the pre-fix body: `.*` **REJECTS** — the unquoted `for` glob-expands it against `.`/`..`, and `grep -qw '.'` then fails. The cycle **already caught this**, at `tests/mf3-tools-vocabulary-gate-firing-controls.md:295-317`, and the note is accurate. But `docs/architecture.md` is in the 419-entry release archive and `tests/` is `export-ignore`d to **0** entries — so the release ships the wrong measurement with no pointer to the correction. 4 of the 5 ACCEPT exemplars in that row (`code`, `claude`, `claude.code`, `cursor*`) reproduce; the `emacs` and Cyrillic `сursor` REJECT claims also reproduce.

**A10 — a line count presented as an occurrence count.** OT-6 (shipping) and ADR-098 both state *"control `v3.0` → 13"*. `grep -c` counts **lines containing**; true occurrences are **22** (`grep -o … | wc -l`). The conclusion (`v2.21` → 0) is unaffected — 0 is 0 in either unit — but this is the ambiguous-unit pattern recurring inside the cycle whose subject is measurement discipline.

---

## (e) Append-only and egress — re-derived, not accepted

### Append-only, by byte-prefix MD5 (`md5(base) == md5(head[0:len(base)])`)

| File | base bytes | head bytes | Verdict |
|---|---|---|---|
| `docs/spec.md` | 1 222 488 | 1 261 578 | **APPEND-ONLY** (`9eb2194b` == `9eb2194b`) |
| `docs/architecture.md` | 1 676 168 | 1 736 348 | modified in place |
| `.github/workflows/quality.yml` | 165 122 | 167 781 | modified in place |
| `docs/internal/carry-forwards.md` | 36 936 | 38 127 | modified in place |
| `docs/owner-tasks.md` | 16 344 | 16 894 | modified in place |
| `docs/roadmap.md` | 27 850 | 28 265 | modified in place |
| `scripts/install-pre-commit.sh` | 2 586 | 2 629 | modified in place |

**Phase 5's "append-only field-by-field" is the correct framing, and whole-file byte-prefix is not.** I enumerated every in-place removal (`git diff -U0`, `^-[^-]`) — there are exactly **8**, all accounted for:

- `architecture.md:116` — ADR-093 index row. **Only the Status cell changed**; the summary text is byte-identical. This satisfies ADR-097 §Decision (6) exactly.
- `architecture.md:118` — ADR-095 index row, replaced by itself + 3 new rows (ADR-096/097/098).
- `carry-forwards.md:223`, `:238` — the two re-derived rows.
- `owner-tasks.md:20`, `:22`, `:24` — OT-4 / OT-6 / OT-8 status corrections.
- `roadmap.md:44` — the `AC-UPGRADE-4-LEGA` predicate.
- `install-pre-commit.sh` — the 5 rename sites.

`docs/architecture.md` also gains 742 appended lines at `:16108`. Net `747 / 2` added/removed.

### Egress — re-derived on a copy, since the changes are uncommitted

`cp -R` of the whole repo to scratch, `git add -A && git commit` **in the copy**, then `git archive`:

```
total archive entries:  419
docs/internal entries:    0
tests/ entries:           0
.github/ entries:         0
scripts/install-pre-commit.sh: 0
docs/ entries (any):     27

CONTROL — the three new reports must be absent:
  grep -E 'security-review-v2.19.14|qa-report-v2.19.14|mf3-tools-vocabulary' → exit 1 (ABSENT)
FIRING CONTROL — a file that should ship:
  skills/action-items/SKILL.md → 1 (PRESENT)
```

Base archive is also **419** entries — the three new files add zero shipping entries. **`docs/internal/` → 0 and the three new reports absent, both confirmed independently, with a control proving the grep can go non-zero.**

**A13 (INFO).** The 27 shipping `docs/` entries include `architecture.md`, `owner-tasks.md`, `roadmap.md`, `risk-register.md` — so ADR-096/097/098 and the OT corrections are all user-visible in the release ZIP. ADR-096/097 quote `docs/internal/qa/qa-report-v2.19.0.md` verbatim and cite `docs/internal/security/security-audit-v2.5.md:40,58,282` by path and line, *inside* a shipping document. Nothing disclosed is sensitive, and the repo is public anyway (`gh repo view` → `PUBLIC`), so this is not a leak. It is the mechanism by which the ADR-088 leak family started, worth naming once.

I also verified the scope note in `tests/mf3-…`: no `.dev-scratch-mf3/` or any fixture residue exists at the repo root, and `git status` shows exactly 7 modified + 3 untracked files — no stray adversarial `SKILL.md` anywhere.

### The AC-CF25F-1 replacement control — re-run, and proven non-vacuous

| Assertion (on `carry-forwards.md`) | Base `a546292` | Required | HEAD | |
|---|---|---|---|---|
| `2026-06-04` ≥ 1 | **0** | ≥1 | **2** | PASS |
| `OVERDUE` = 0 | **1** | 0 | **0** | PASS |
| `never been performed` = 0 | **1** | 0 | **0** | PASS |
| `ADR-097` ≥ 1 | **0** | ≥1 | **2** | PASS |

**All four go the wrong way at base.** Every one is a firing control; none is vacuous. This is a genuine improvement over the `5 → 0` grep it replaced.

**One consistency note.** `AC-CF25F-1`'s literal text (`docs/spec.md:11373`) says *"No site may retain language implying an unconditional, breached, or overdue obligation"* across **5** sites. Three of the five (`architecture.md:116` summary — frozen; `:15425`, `:15560` — superseded-never-edited) still carry it in ADR-093's own voice. The cycle resolved this by ADR fiat (ADR-097 Decisions (5)/(6)) rather than by amending the AC. Substantively defensible — a reader can reach the correction — but the AC and the bytes now disagree, and nobody wrote that down.

---

## (f) The two open non-blocking findings

**F-2 → my A6. Does not block; I would fix it in this PR.** It is one row's label. But ADR-097's whole thesis is that a register may not repair a claim without a source ruling, and here the source ruling says "both rows" while the bytes deliver one. Leaving it means `:238`'s superseded rationale is erased rather than recorded. Two options, and only one is right: add the retained-verbatim label to `:238`, or amend §Decision (3). Amending the decision to match the implementation is the weaker move and sets the wrong precedent for a Tier A record.

**F-3 → my A8. Does not block; it belongs in this cycle, not its own row.** Phase 5 called it "pre-existing, out of cycle scope". It is pre-existing — but the cycle's own scope is *"repoint the sites that name `.markdownlint.json`"*, and CONTRIBUTING holds two of them. Fixing 5 of 7 is a partial rename that leaves the repo self-contradictory, and `:239` is the copy-pasteable one. Cost: 2 lines, docs-only, `export-ignore`d file, non-Tier-A. A separate row costs more ceremony than the fix.

---

## (g) The phantom write

**Security implication for what merges: none. Audit implication: one, and it is worth stating.**

The vanished artifact was the Phase-2 review *text*, which the orchestrator then persisted from the agent's return value. The bytes that merge are the bytes I read and executed. I did not accept any change on narrative: the gate was re-run from the extracted step body against 58 fixtures and the real 29-skill corpus; the doc corrections were each re-derived against primary sources (GitHub API for PR #521, `git tag` for the three release dates, `grep` for the two occurrence counts, the cited report lines read directly); append-only and egress were recomputed from scratch.

The consequence worth naming: **the one place where the record and the bytes disagree — A6, the missing `:238` label — has exactly the shape a silently-dropped write leaves.** I judge it more likely an authoring omission, because the rest of the same row landed and a dropped write would have taken the whole row. But it is the honest place to look, and it is why "verify the artifact, not the agent's narrative" is not a slogan in this cycle. This repo's own history supports the concern independently: PR #118 dropped 2 of 4 files (see `git log`, commit `53b63d4`-adjacent, PR #120's title).

So: **purely a tooling-reliability matter for the merge**, on the condition that byte-level verification is done — which it now has been.

---

## (h) What the prior phases missed

### A1 — WARNING: no CI check is required to merge `main`

This cycle's premise is *"this modifies a merge-enforcement gate."* Read-only probes of the live repo:

```
gh api repos/:owner/:repo/rulesets                                → []
gh api repos/jmlozano1990/Cowork-Starter-Kit/rules/branches/main  → []
gh api repos/:owner/:repo/branches/main/protection/required_status_checks
   → 404 {"message":"Required status checks not enabled"}
gh api repos/:owner/:repo/branches/main/protection
   → required_pull_request_reviews present, required_approving_review_count: 0
     enforce_admins: true, allow_force_pushes: false, allow_deletions: false
     (no required_status_checks key at all)
```

**Firing negative control** — the same endpoint against a public repo known to have rules:

```
gh api repos/cli/cli/rules/branches/trunk
   → [{"type":"copilot_code_review", … "ruleset_source":"cli/cli", …}]
```

The probe can return non-empty. The `[]` for Cowork-Starter-Kit is a real zero, and GitHub states the absence positively ("Required status checks not enabled") rather than merely returning nothing.

**What this means in plain terms:** a PR can be merged into `main` with the Quality Checks workflow red, and with zero approving reviews. MF-3 — and the other 34 jobs — produce a visible red X; nothing stops the merge. The workflow is `on: [push, pull_request]` with no path filters and the job carries no `if:`, so the gate does **run** on every PR; it simply does not **block**. And because `pull_request` executes the workflow file from the PR head, a PR that edits `quality.yml` runs its own edited version.

This is pre-existing configuration, not introduced or worsened by this change, and it is why the human owner is the actual boundary here. But it belongs in the Guard Change Summary, because the honest answer to "can this stop a bad change reaching `main`?" is "only if you look at the red X."

### Other items

- **A11 (INFO).** Phase-2 S18 reproduces in the shipped bytes and is *inconsistent*: `tools: [claude-code,]` → **ACCEPT**; `tools: [claude-code, ]` → **REJECT** ("empty list element"). Identical to YAML, opposite verdicts, decided by one space (with `IFS=','`, a trailing delimiter yields no null field; a trailing space does). Gate-approved as INFO at Phase 3, so shipping it is consistent — but the boundary is arbitrary and undocumented.
- **A12 (INFO).** Phase-2 S7 reproduces: a file with **unterminated** frontmatter (`---` at line 1, never closed) and a file with a `# heading` *before* `---` both **ACCEPT**. The gate's model is "text between the 1st and 2nd `---` lines anywhere in the file", not "YAML frontmatter at byte 0". Bounded: when real frontmatter exists, the gate's window always contains it, so a disallowed token cannot be smuggled — I tried the decoy-block construction and it rejects. The fail-open is on *frontmatter validity*, not on *vocabulary*.
- **A15 (INFO).** `CHANGELOG.md` and `README.md` are untouched. Repo convention (`d7c1f1c` v2.19.13 #116, `9a9961f` v2.19.12 #114, `9005dc8` v2.19.11 #112) puts the version's CHANGELOG entry in the version's own PR. README badge reads `version-2.19.13`. CHANGELOG.md's own header declares a CHANGELOG↔tag↔GitHub-Release invariant with three named exceptions. If this is the v2.19.14 release PR, that invariant needs an entry.
- **Clean.** Secret scan across the full diff (`api[_-]?key|secret|token|passwd|password|BEGIN … PRIVATE KEY|ghp_|github_pat_|AKIA…`) returns only the word "token" in its vocabulary sense — no credentials, no keys, no PII.
- **Blast radius confirmed minimal.** All 7 `quality.yml` diff hunks fall within lines **1165–1235** — entirely inside the MF-3 step. The file's 6 `permissions:` blocks (`:223, 1941, 2384, 2406, 2530, 2591`) are all outside it and unchanged; `skill-depth-check` declares none and inherits the workflow default, also unchanged. `release-assets.yml`, `release-surface.yml`, `sync-agency.yml` are byte-identical. YAML parses: 35 jobs, `skill-depth-check` has 9 steps, MF-3 is step 5.

---

## OWASP Top 10 Assessment

| Category | Status | Notes |
|---|---|---|
| A01 Broken Access Control | **PASS** | The change replaces a regex/glob authorization test with fixed-string membership. 10 previously-accepted bypass inputs now refused; M1/M2/M3 counterfactuals prove each new control load-bearing. Residual A2 (whitespace normalization) does not admit a *disallowed* value into a *consumer* — there is no consumer at v2.5. |
| A02 Cryptographic Failures | N/A | No cryptographic surface. Registry `sha256` machinery untouched. |
| A03 Injection | **PASS** | Expansion-oracle fixtures (`` `echo claude-code` ``, `$(echo claude-code)`, `;echo hi`, `$ALLOWED`) all echo back literally and reject — no command, parameter, or arithmetic expansion of untrusted content. Shape precheck bounds the character set; `case` pattern is quote-protected (M1 proves it). GitHub workflow-command injection via `::error::` is not reachable — a token cannot contain a newline (`tr` strips it). |
| A04 Insecure Design | **PASS WITH WARNINGS** | A3: the gate's subject set (`skills/*/`) is narrower than its reported set (`find skills`) — a count used as a boundary. A12: frontmatter validity is inferred, not parsed. Both pre-existing, both bounded. |
| A05 Security Misconfiguration | **WARNING** | **A1** — no required status checks, 0 required approving reviews on `main`. Every CI gate in this repo is advisory. Pre-existing. |
| A06 Vulnerable/Outdated Components | **PASS** | No dependency added or changed. `npm install -g markdownlint-cli` is comment + error-message text only; the script never executes npm (A14). Action pins are SHA-pinned and untouched. |
| A07 Identification/Auth Failures | N/A | No authentication surface. |
| A08 Software & Data Integrity | **PASS WITH WARNINGS** | Egress re-derived (419 entries, `docs/internal/` → 0, three new reports absent, firing control passes). Append-only re-derived field-by-field with all 8 in-place removals enumerated. A5/A6/A7 are record-integrity defects in the Tier A audit trail, not artifact-integrity defects. |
| A09 Logging & Monitoring | **PASS WITH WARNINGS** | The gate's success line reports a count larger than the population it checked (A3). Error messages are accurate and specific — the shipped body distinguishes missing / duplicate-key / unparseable / empty-array / empty-element / invalid-token, where the pre-fix body collapsed several into one misleading message. |
| A10 SSRF | N/A | No outbound request surface. |

**LLM threat assessment (LLM01/02/06).** `SKILL.md` files are executed as AI context, so the `tools:` field is model-visible. LLM01 (prompt injection): the gate reads only the `tools:` frontmatter line and never emits its content into a model context — the only echo is a GitHub Actions annotation, whitespace-stripped and newline-free. LLM02 (insecure output handling): the token is interpolated into `echo "::error::…"` only; no downstream consumer parses it. LLM06 (sensitive disclosure): A13 — internal QA/security report content is quoted into shipping documents; content assessed non-sensitive, repo public.

---

## What my re-run falsified, by author

| Claim | Author | Status after re-run |
|---|---|---|
| A step-scoped `set -f` would make MF-3 *"pass vacuously"* | `@architect` (ADR-098), carried into the shipped comment | **FALSE.** Hard-fails: `rc=2` with errexit, `exit 1` without. Never passes. |
| Pre-fix parser ACCEPTs `tools: [.*]` | `@architect` (ADR-098 `:121`, `:16716`) | **FALSE** — independently confirmed; already self-caught in `tests/`, but the correction lives only in a non-shipping file. |
| ADR-097 §Decision (3): *"Both re-derived rows carry the superseded text under that same label"* | `@architect` | **FALSE in the bytes** — `:238` has no label. (Matches @qa's F-2.) |
| `docs/architecture.md:15422` / `:15557` locate the two "51 days" claims | `@architect` (ADR-097 §D5), `@pm` (`spec.md:11340-41`) | **FALSE at HEAD** — moved to `:15425`/`:15560` by this same commit. |
| ADR-096/097 PROPOSED at Phase 1 `11:34:00Z`, ACCEPTED at Phase 3 `10:01:15Z` | `@architect` | **Chronologically impossible.** Phase 1 post-dates Phase 3 by 93 min; local CEST labelled `Z`. |
| Phase 2 security review dated `2026-08-29T13:20:00Z` | prior `@security` | **~2h in the future** vs. wall clock `10:46:01Z` / `11:06:09Z`. |
| Phase 2 S18: `tools: [claude-code,]` accepted | prior `@security` | **Still true** in shipped bytes — and inconsistent with `[claude-code, ]`, which rejects. |
| Phase 2 S7: `awk` frontmatter scan "fails open" | prior `@security` | **True, and I can name the shape** — unterminated frontmatter and heading-before-`---` both ACCEPT. Bounded: no token smuggling. |
| Phase 2 S12: *"same ruleset as CI"* survives the fix | prior `@security` | **Confirmed** — `install-pre-commit.sh:4`/`:54` unchanged. |
| Phase 2 S19: `case` safety rests solely on `" $token "` quoting | prior `@security` | **Confirmed and strengthened** — M1 shows removing the quotes flips 4 inputs to ACCEPT. |
| Phase 5: append-only, byte-offset + MD5 | `@qa` | **Confirmed as *field-by-field*.** Whole-file byte-prefix holds only for `docs/spec.md`; all 8 in-place removals independently enumerated and accounted for. |
| Phase 5: egress via `git archive`, 419 entries, `docs/internal/` → 0 | `@qa` | **Confirmed independently**, and extended: base is also 419, so the three new files add zero shipping entries. |
| Phase 5: 29/29 production skills pass | `@qa` | **Confirmed** — real `skills/`, real extracted step body, bash 5.3, `exit=0`. |
| Orchestrator brief: doc corrections are ADR flips + `roadmap.md:44` + `carry-forwards.md:223/:238` | orchestrator | **Incomplete** — three further in-place status corrections in `docs/owner-tasks.md` (OT-4/6/8), in a file that **ships**. All three re-derive correctly. |
| Brief: *"the unpinned `npm install -g markdownlint-cli`"* | orchestrator / Phase 2 | **Overstated as a risk** — the script never runs npm. Untouched, as claimed; but it is unpinned *advice*, not an unpinned install. |

---

## Guard Change Summary — v2.19.14

⚠️ **MERGE WITH CONDITIONS — the gate itself is correct and strictly stricter (10 bypasses closed, 0 opened, proven by re-running both versions); 4 text-only corrections should land in this PR first, none of which touch the gate**

| Fact | Status |
|---|---|
| Permissions / scope | ✅ 0 changed — all 7 workflow edits fall inside lines 1165–1235 (the MF-3 step); all 6 `permissions:` blocks and the other 34 jobs byte-identical; 2 other workflow files untouched |
| CI | ⚠️ Cannot report — no GitHub Actions run observed. Locally: workflow YAML parses (35 jobs), and the real MF-3 step passes on the real 29 skills, `exit=0` |
| Can it block you? | ⚠️ **No — and that is the surprise.** No CI check is required to merge `main` (`required_status_checks` → 404 "not enabled"; rulesets → `[]`; 0 required approvals). The gate goes red; nothing stops the merge |
| Known problems shipping unfixed | ⚠️ 16 filed, 7 WARNING — none can let a disallowed tool value through to anything that reads it, because nothing reads it yet (v2.5 = informational only) |
| Forward-only caveats | ⚠️ 2 — the whitespace gap (A2) only bites when v3.0 starts routing on `tools:`; the nested-skill gap (A3) only bites if someone adds `skills/<a>/<b>/SKILL.md` |
| What we could not prove | ⚠️ 3 — see the closing line |

**What you're approving:** a CI check that decides which AI tools a skill may declare. It used to answer that question with pattern-matching, which let five wrong answers through; it now compares against the four approved names exactly, and it stopped rejecting the legitimate two-name lists it was supposed to allow.

**What you're accepting:**
1. **The check still can't stop a merge on its own** — no CI job in this repo is a required check. *(Certain. Medium harm — this is the one worth your attention, and it is not caused by this change.)*
2. **A tool name with a space hidden inside it is still accepted** (`claude -code` counts as `claude-code`). Harmless today because nothing reads the field; it becomes real when v3.0 starts routing on it. *(Likely to be hit eventually. Low harm now, Medium at v3.0.)*
3. **Four written records disagree with the code or with themselves** — including the timestamps that are supposed to prove these decisions crossed your approval gate. *(Certain — I verified all four. Low harm, but it is your own audit trail.)*
4. **A skill filed one folder deeper than expected is checked by nothing, while the "N skills checked" message counts it.** No such file exists today. *(Unlikely. Low harm.)*

---

### What changed

A CI check that validates one line of each skill file — the line naming which AI tools that skill works with — was rewritten. It previously used pattern-matching that treated the untrusted name as a search expression, so five different wrong names slipped through as if approved, and it also mangled any list of two or more names into one nonsense word and rejected it. It now compares each name letter-for-letter against the four approved ones. Separately, a helper script that installs a local formatting check on a contributor's machine was pointed at the settings file that actually exists (it had been pointed at a filename that was never there, so the check silently did nothing).

### What could break

1. **The check cannot block a merge, so a bad change reaching `main` still depends on someone seeing the red X.** I probed the live repository three different ways: no required status checks, no branch rulesets, zero required approving reviews. A control probe against a public repository that *does* have rules returned results, so this is a real zero and not a broken measurement. *(Certain. Medium harm — pre-existing, not caused by this change, and it is the single most important thing to know about a "merge gate".)*
2. **A tool name containing a space, tab or carriage return in the middle is accepted as if it were an approved name.** I confirmed five variants pass. Nothing reads this field today, so nothing acts on it. It matters at v3.0, when the setup wizard is meant to start routing on it. *(Likely eventually. Low harm today, Medium at v3.0.)*
3. **Four written records are wrong in ways I verified by re-running them.** The reason given in the code comment for a safety decision is false (I ran the alternative — it fails loudly rather than passing silently, as claimed). Two line-number citations point at the wrong lines because this same change shifted them. One rule says "both rows get a label" and only one row got it. And the timestamps say a decision was proposed 93 minutes *after* it was approved — they are local time written as if they were UTC. *(Certain. Low harm individually; together they weaken the paper trail of your own approval.)*
4. **A skill file placed one folder deeper than the expected layout is validated by no check at all, while the check's own "N skills checked" message counts it.** I demonstrated this: a nested file declaring a forbidden tool passed, and the message said 2 checked when 1 was. No such file exists today, and this behaved identically before the change. *(Unlikely. Low harm.)*
5. **Contributors following the written instructions rather than running the script still get the broken filename.** `CONTRIBUTING.md` holds two more copies of the same wrong path, one of them a block people copy and paste. *(Likely for any new contributor. Low harm — it wastes their time and may teach them to skip the check.)*

### What's protected

Everything the check used to do, it still does — and more. I ran both the old and new versions of the check side by side, in the shell CI actually uses, against 58 hand-built files:

- **Ten inputs the old check waved through are now refused**, including a name that resolves to an approved one via wildcard matching, a name that is merely a fragment of an approved one, and a name that resolves by matching a file sitting in the repository.
- **Zero inputs that used to be refused are now allowed**, apart from the legitimate two-name lists that were the whole point of the change.
- **All 29 real skills pass**, run against the real files with the real code, not a copy.
- Each of the three new safety mechanisms was verified to be *doing the work*: I made a modified copy of the check outside the repository with each mechanism disabled in turn, and each time a specific attack came back. They are not decorative.
- The two internal reports written this cycle, and the new test file, **do not ship** in the public release package — confirmed by building the package from a copy of the repository with those files committed, and by a control confirming a file that *should* ship does.

The load-bearing control here is **your own eyes on the red X**, because no CI check in this repository is a required check. That is worth saying plainly: the code is now correct, but the enforcement is you.

### What to verify after merge

- **On the next pull request, the "Skill Depth Check" job's log ends with `MF-3 tools: vocabulary gate passed (29 skills checked)`.** If that line is absent, or the number is not 29, something moved.
- **When a skill is next added or edited, `docs/architecture.md` gains an ADR row whose "PROPOSED at Phase 1" timestamp is *earlier* than its "ACCEPTED at Phase 3" timestamp.** If Phase 1 is still later, the timestamp habit did not get fixed and the approval trail stays unreliable.
- **`docs/internal/carry-forwards.md` line 238 contains the words "Original status text, retained verbatim".** Its absence is the alarm — it means the rule and the file still disagree.
- **`CONTRIBUTING.md` contains no occurrence of `.markdownlint.json` without the trailing `c`.** If it still does, contributors are still being handed the broken instructions.

### Conditions before merge (all text-only; none touches the check's logic)

1. **Fix the three phase timestamps** in ADR-096/097's status lines and the Phase-2 review header (local CEST written as `Z`). *This is your approval record.*
2. **Correct the reason in the code comment and ADR-098** — a step-scoped `set -f` fails loudly, it does not pass silently.
3. **Add the retained-verbatim label to `carry-forwards.md:238`**, as ADR-097 §Decision (3) requires.
4. **Repoint the two `.markdownlint.json` references in `CONTRIBUTING.md`** — sites 6 and 7 of the same rename.

Optionally also: correct the two off-by-three line citations in ADR-097 §Decision (5), and add a one-line note beside ADR-098's `.*` table row so the shipping document carries the correction that currently lives only in the non-shipping test file.

**What we could not prove:** three things. **(1)** That GitHub Actions passes — no CI run was observed; I verified the workflow YAML parses and the extracted step passes locally on the real 29 skills under bash 5.3, which is close to but not identical to `ubuntu-latest`. **(2)** Whether `markdownlint-cli` errors or silently falls back when handed a `--config` path that does not exist — the tool is not installed on this machine, so I cannot say whether `CONTRIBUTING.md`'s manual hook would block every commit or merely do nothing. **(3)** Whether the mechanism behind the Phase-2 write that reported success and left nothing has recurred in this cycle — I verified every claimed change is present in the bytes, which is the only defence available, but I cannot prove no *unclaimed* change was lost.

---

## Recommendation

**MERGE — after the four text-only corrections above.**

The Tier A change is correct. I re-executed both versions of the gate against 58 adversarial fixtures and the real 29-skill corpus; the three briefed defect classes are closed, S17 and S19 are present and each proven load-bearing by a disabling counterfactual, and I could not construct an input that admits a disallowed vocabulary token. The one new gap I did find (A2, intra-token whitespace) has no reachable consumer at v2.5 and is a WARNING, not a blocker.

Nothing here blocks. The four conditions are documentation defects in files this PR already modifies, they cost minutes, and one of them — the timestamps — is the record of the owner's own Tier A approval, which is exactly the artifact a Tier A ceremony exists to produce.

---

## Files

- Audited: `/Users/macbookpro/claude-cowork-config/.github/workflows/quality.yml` (MF-3 step, lines 1160–1241)
- Audited: `/Users/macbookpro/claude-cowork-config/scripts/install-pre-commit.sh`
- Audited: `/Users/macbookpro/claude-cowork-config/docs/architecture.md` (ADR-096 `:16109`, ADR-097 `:16317`, ADR-098 `:16524`; index rows `:116`, `:118`–`:121`)
- Audited: `/Users/macbookpro/claude-cowork-config/docs/roadmap.md:44`, `/Users/macbookpro/claude-cowork-config/docs/owner-tasks.md:20,22,24`, `/Users/macbookpro/claude-cowork-config/docs/internal/carry-forwards.md:223,238`
- Read: `/Users/macbookpro/claude-cowork-config/docs/internal/security/security-review-v2.19.14.md`, `/Users/macbookpro/claude-cowork-config/docs/internal/qa/qa-report-v2.19.14.md`, `/Users/macbookpro/claude-cowork-config/tests/mf3-tools-vocabulary-gate-firing-controls.md`
- Harness (outside the repo, reproducible): `/private/tmp/claude-501/-Users-macbookpro-The-Council/9e7c0e0a-9334-41ec-8833-b9e1fd389476/scratchpad/mf3/` — `mf3-step.sh` (extracted shipped body, md5 `254289e88b967f445e449ecbac3d9584`), `mf3-step-OLD.sh` (extracted base body), `mut-M1..M4-*.sh` (counterfactuals), `fixtures/` `fixtures2/` `fixtures3/` (58 fixtures), `gen*.py`, `drive*.sh`, `check.sh`, `runner.sh`, `runner-noe.sh`, `appendonly.sh`, `egress.sh`, `prod.sh`, `nested.sh`, `coverage.sh`

**Delegation:** haiku=0 sonnet=0 opus=1 missed=~6 (the secret scan, the SKILL.md enumeration, the tag/date lookups, the occurrence counts, and the `.gitattributes` read were all mechanical and belonged on `[haiku]`; I kept them because each fed directly into a judgment I was forming and the round-trip cost exceeded the saving — but that is a rationalisation, not a defence).agentId: ad30451ae2b9860ab (use SendMessage with to: 'ad30451ae2b9860ab', summary: '<5-10 word recap>' to continue this agent)
<usage>subagent_tokens: 259497
tool_uses: 158
duration_ms: 2016601</usage>