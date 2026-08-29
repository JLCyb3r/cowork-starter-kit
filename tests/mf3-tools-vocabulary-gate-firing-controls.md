# MF-3 `tools:` Vocabulary Gate — Firing Controls (v2.19.14, `AC-PARSE-1`..`4` — required before merge)

Validates ADR-098's parser/authorization rewrite of `.github/workflows/quality.yml`'s
`MF-3 — skills/*/SKILL.md tools: vocabulary gate` step, per this repo's own binding
*check-that-cannot-fail* discipline (a check that cannot fail is not a check). This is
the load-bearing deliverable of the v2.19.14 cycle's Item 1/2 (folded S17/S19) — the
**test**, not the fix, is what proves the three defects (D-1 tokenizer collapse, D-2
`grep -qw` regex/substring bypass, D-3 unquoted pathname-expansion bypass) are actually
closed, and stays discriminating enough to catch a future regression of either.

Every RED result below was reproduced against the **actual pre-fix step body**,
extracted live this session via `git show HEAD:.github/workflows/quality.yml`
(base `a546292`) — not hand-recalled. Every GREEN/RED result against the fixed
parser was reproduced against the **actual post-fix step body**, extracted live
this session directly out of the edited `.github/workflows/quality.yml` (lines
1162-1241) via the `Read` tool and re-assembled byte-for-byte (de-indented only) —
not a hand-written replica of the design. All invocations ran under **`/bin/bash`**
(GNU bash 3.2.57, this host's `/bin/bash`), never `zsh` — `zsh` does not reproduce
the D-3 pathname-expansion vector, and CI (`quality.yml`, no `shell:`/`defaults:`,
`runs-on: ubuntu-latest`) runs `bash -e`. Fixtures are real `skills/*/SKILL.md`
files under a real, disposable `skills/` directory (not the repository's own), so
the actual `awk` frontmatter extraction and the actual `for skill_md in
skills/*/SKILL.md` glob both fire for real, not simulated.

## Invocation record

- **Model:** Claude Sonnet 5 (model ID `claude-sonnet-5`), Anthropic — operating as
  `@dev` within The-Council pipeline, Phase 4 implementation of cycle v2.19.14.
- **Date:** 2026-08-29
- **Trigger:** Real invocations performed during this cycle's Phase 4
  implementation, not narrated or paraphrased after the fact.

### Method

The pre-fix and post-fix step bodies were each extracted into a standalone
executable script (de-indented only, no logic changed), and run with `cd` into a
fixture directory containing a real `skills/` tree, so `for skill_md in
skills/*/SKILL.md` glob-expands against real files exactly as it does in CI. The
D-3 glob-bypass fixtures additionally place a file literally named `copilot` at
the fixture root (the step's CWD in CI is the repo checkout root), matching the
ADR's own scenario rather than an empty directory. All fixture files and scripts
were constructed outside `tests/`, `skills/`, and every other tracked path — see
Scope note.

---

## A. `AC-PARSE-1` — N=1, N=2, N=3 tokenization

**Fixtures:** `skill-n1` (`tools: [claude-code]`), `skill-n2` (`tools:
[claude-code, copilot]`), `skill-n3` (`tools: [claude-code, copilot, cursor]`).

### RED — pre-fix (git HEAD, `a546292`), all three together

```
$ cd fixture-root && bash mf3-pre-fix-from-git-head.sh
::error::skills/skill-n2/SKILL.md tools: contains invalid token 'claude-codecopilot' (allowed: claude-code copilot cursor windsurf)
::error::skills/skill-n3/SKILL.md tools: contains invalid token 'claude-codecopilotcursor' (allowed: claude-code copilot cursor windsurf)
::error::MF-3 vocabulary gate failed on: skills/skill-n2/SKILL.md skills/skill-n3/SKILL.md
exit=1
```

`skill-n1` (N=1) does **not** appear in the failure list — the collapse only
fires at N≥2, confirming the briefed defect precisely (D-1: `s/,/ /g` then
`tr -d ' '` deletes the separator space it just inserted, concatenating
adjacent tokens).

- [x] **RAN 2026-08-29.** Confirmed RED — a valid 2-item and a valid 3-item list
      are both refused by the real pre-fix code, exact output above.

### GREEN — post-fix (this cycle's edit to `quality.yml`), same three fixtures

```
$ cd fixture-root && bash mf3-extracted-from-yaml.sh
MF-3 tools: vocabulary gate passed (       3 skills checked).
exit=0
```

- [x] **RAN 2026-08-29.** Confirmed GREEN — N=1, N=2 and N=3 all tokenize and
      validate correctly. This is **not** a fix that special-cases N=2: N=3 is a
      separate fixture in the same run and passes independently, satisfying the
      spec's explicit requirement that both be demonstrated, not one inferred
      from the other.

### Spacing variant (`tools: [ claude-code ,copilot ]`) — post-fix only

```
$ bash candidate_mf3.sh 'tools: [ claude-code ,copilot ]'
RESULT=OK: claude-code ,copilot
exit=0
```

- [x] **RAN 2026-08-29.** Confirmed GREEN — irregular spacing around commas and
      brackets does not defeat tokenization (`tr -d '[:space:]'` on each split
      token).

---

## B. `AC-PARSE-2` — multi-line YAML form still rejected, with the correct message

**Fixture:** `skill-multiline` — frontmatter reads:

```yaml
tools:
  - claude-code
```

(the `awk` frontmatter scanner captures the bare line `tools:` for this shape,
identically to the real repo's own scanner.)

### RED (wrong message) — pre-fix

```
::error::skills/skill-multiline/SKILL.md tools: contains invalid token 'tools:' (allowed: claude-code copilot cursor windsurf)
```

This is `CF-v2.5-A`'s residue: the multi-line form is refused, but with the
generic `invalid token 'tools:'` fallthrough, not the MF-S1 message the skill
authors are supposed to see.

- [x] **RAN 2026-08-29.** Confirmed — real pre-fix output above, part of the same
      combined run recorded under §D below (`fixture-edge`).

### GREEN (correct message) — post-fix

```
::error::skills/skill-multiline/SKILL.md tools: present but unparsed (multi-line form not supported at v2.5)
```

- [x] **RAN 2026-08-29.** Confirmed — the post-fix parser emits the MF-S1 string
      specifically, and does **not** emit an `invalid token` line naming
      `tools:` as the offending token. Two states that both occur in this
      codebase for different inputs are correctly distinguished — this is not a
      tautological check (see `docs/spec.md` AC-PARSE-2's own note).

---

## C. Edge case — `tools: []` (empty array) gets its own message

**Fixture:** `skill-empty` — `tools: []`.

### Pre-fix — misdiagnosed as the multi-line form

```
::error::skills/skill-empty/SKILL.md tools: present but unparsed (multi-line form not supported at v2.5)
```

- [x] **RAN 2026-08-29.** Confirmed — pre-fix, an empty array and the
      unsupported multi-line form are indistinguishable (both collapse `TOKENS`
      to empty).

### Post-fix — its own, accurate message (ADR-098 §Decision (5))

```
::error::skills/skill-empty/SKILL.md tools: declares no tools (empty array)
```

- [x] **RAN 2026-08-29.** Confirmed — `tools: []` is now refused (empty tool
      lists are still invalid — a skill must declare at least one tool) but with
      a message that is true, not MF-S1's actively-false "multi-line form not
      supported" for a case that plainly is not multi-line.

---

## D. `S17` — duplicate `tools:` keys

**Fixture:** `skill-dup` — frontmatter declares `tools:` **twice**:

```yaml
tools: [claude-code]
tools: [copilot]
```

### RED (silent accept) — pre-fix, isolated

```
$ cd fixture-dup-only && bash mf3-pre-fix-from-git-head.sh
MF-3 tools: vocabulary gate passed (       1 skills checked).
exit=0
```

**This is the defect S17 names, demonstrated, not inferred.** The `awk` scanner
captures both `tools:` lines (both match `^tools:` inside the frontmatter
block); `sed` processes each line independently, producing `claude-code` on one
line and `copilot` on the other; `tr -d ' '` and the unquoted `for token in
$TOKENS` word-split on the embedded newline (bash's default `IFS` includes
`\n`), so each line's token is checked **individually** and both happen to be
individually valid — the row **silently accepts a file the shape precheck was
supposed to have already rejected as malformed.**

- [x] **RAN 2026-08-29.** Confirmed RED-that-should-have-been-red-but-passed —
      exit 0, no error, real pre-fix code, isolated fixture (only `skill-dup`
      present, so no other fixture's failure could mask this).

### GREEN (correctly refused) — post-fix, combined run with `skill-empty` and `skill-multiline`

```
$ cd fixture-edge && bash mf3-extracted-from-yaml.sh
::error::skills/skill-dup/SKILL.md tools: frontmatter field declared 2 times (duplicate key)
::error::skills/skill-empty/SKILL.md tools: declares no tools (empty array)
::error::skills/skill-multiline/SKILL.md tools: present but unparsed (multi-line form not supported at v2.5)
::error::MF-3 vocabulary gate failed on: skills/skill-dup/SKILL.md skills/skill-empty/SKILL.md skills/skill-multiline/SKILL.md
exit=1
```

- [x] **RAN 2026-08-29.** Confirmed RED with the correct, specific
      diagnostic — `TOOLS_LINE_COUNT` (via `wc -l` on the awk-captured lines) is
      asserted `-eq 1` before any shape-checking runs, so a duplicated key can no
      longer smuggle two individually-valid lines past the gate. §B and §C's
      results reproduce identically inside this same combined run, proving the
      three fixes compose correctly in one pass, not just in isolation.

---

## E. Six bypass strings (D-2 regex/substring, D-3 pathname expansion)

Each token was verified BOTH as a standalone `case`-membership probe (below)
AND as a real `tools:` fixture routed through the full extracted step. Every
`ACCEPT` claimed pre-fix is a real exit-0 pass with the malicious token
un-flagged; every `reject` claimed post-fix is a real exit-1 with that exact
token named in the error line.

**D-2 fixtures (`code`, `claude`, `claude.code`, `cursor*`) and one D-3 fixture
(`c?p?l?t`, run in a directory containing a real file named `copilot`) — 5
fixtures, one combined pre-fix run:**

```
$ cd fixture-bypass1 && bash mf3-pre-fix-from-git-head.sh
::error::skills/skill-dotstar/SKILL.md tools: contains invalid token '.' (allowed: claude-code copilot cursor windsurf)
::error::skills/skill-dotstar/SKILL.md tools: contains invalid token '..' (allowed: claude-code copilot cursor windsurf)
::error::MF-3 vocabulary gate failed on: skills/skill-dotstar/SKILL.md skills/skill-dotstar/SKILL.md
exit=1
```

`skill-code` (`code`), `skill-claude` (`claude`), `skill-claudedotcode`
(`claude.code`), and `skill-cursorstar` (`cursor*`) do **not** appear in the
failure list — all four **silently ACCEPT**, confirmed live, reproducing
ADR-098's D-2 table exactly. `skill-dotstar` (`.*`) is the one entry that does
**not** reproduce ADR-098's claimed `.* -> ACCEPT` row — see the falsification
note at the end of this section.

- [x] **RAN 2026-08-29.** Confirmed — 4 of 5 named bypass tokens are silently
      accepted by the real pre-fix code, live.

**The glob bypass (`c?p?l?t`), isolated, with a real file named `copilot`
present at the fixture root:**

```
$ cd fixture-glob-only && bash mf3-pre-fix-from-git-head.sh
MF-3 tools: vocabulary gate passed (       1 skills checked).
exit=0
```

- [x] **RAN 2026-08-29.** Confirmed RED-that-passed — `c?p?l?t` is silently
      accepted, exit 0, because the unquoted `for token in $TOKENS` performs
      pathname expansion and a file matching that glob exists in the CWD (D-3).
      Isolated (only this one fixture present) so the accept is unambiguous.

### Post-fix — all 6 tokens correctly refused

```
$ cd fixture-bypass1 && bash mf3-extracted-from-yaml.sh
::error::skills/skill-claude/SKILL.md tools: contains invalid token 'claude' (allowed: claude-code copilot cursor windsurf)
::error::skills/skill-claudedotcode/SKILL.md tools: contains invalid token 'claude.code' (allowed: claude-code copilot cursor windsurf)
::error::skills/skill-code/SKILL.md tools: contains invalid token 'code' (allowed: claude-code copilot cursor windsurf)
::error::skills/skill-cursorstar/SKILL.md tools: contains invalid token 'cursor*' (allowed: claude-code copilot cursor windsurf)
::error::skills/skill-dotstar/SKILL.md tools: contains invalid token '.*' (allowed: claude-code copilot cursor windsurf)
::error::MF-3 vocabulary gate failed on: skills/skill-claude/SKILL.md skills/skill-claudedotcode/SKILL.md skills/skill-code/SKILL.md skills/skill-cursorstar/SKILL.md skills/skill-dotstar/SKILL.md
exit=1
```

```
$ cd fixture-glob-only && bash mf3-extracted-from-yaml.sh
::error::skills/skill-glob/SKILL.md tools: contains invalid token 'c?p?l?t' (allowed: claude-code copilot cursor windsurf)
::error::MF-3 vocabulary gate failed on: skills/skill-glob/SKILL.md
exit=1
```

- [x] **RAN 2026-08-29.** Confirmed — all 6 tokens are refused post-fix,
      **by their literal text**, including the glob token in the presence of the
      real `copilot` file (the `set -f` scoped to the token loop prevents the
      shell from ever resolving `c?p?l?t` to a filename before the `case`
      membership test sees it).

### Negative control — `emacs` must still be rejected post-fix

```
$ cd fixture-negctrl && bash mf3-extracted-from-yaml.sh
::error::skills/skill-emacs/SKILL.md tools: contains invalid token 'emacs' (allowed: claude-code copilot cursor windsurf)
exit=1
```

- [x] **RAN 2026-08-29.** Confirmed — the fix does not become "reject
      everything"; a genuinely invalid tool is still, correctly, refused.

### Falsification note — ADR-098's D-2/§Decision table row for `.*`

ADR-098's Context (D-2) and §Decision "Measured, current vs candidate" table
both claim the **pre-fix** parser **ACCEPTS** `tools: [.*]`. Reproduced live,
end-to-end (not as an isolated `grep -qw` probe), this is **false**: in
**every** real directory — including this test's fixture directories and the
real CI checkout root — the shell's own `.` and `..` entries always exist, and
bash's unquoted `for token in $TOKENS` glob-expands the literal token `.*`
against them (`.*` is a leading-dot pattern, so it matches dot-entries by
POSIX/bash pathname-expansion rules, verified directly: `for f in .*; do echo
$f; done` → `.` then `..`). Both resulting pseudo-tokens are then individually
tested and **both are correctly rejected** — so the real pre-fix behavior for
`tools: [.*]` is **BAD** (refused), not `OK:.*` as the ADR's own measured table
states. This does not change the vulnerability finding (D-2's `grep -qw`
substring/regex bypass is real and independently demonstrated by `code`,
`claude`, `claude.code`, `cursor*` above) or the candidate's correctness (the
post-fix parser also correctly rejects `.*`, for the right reason this time —
literal `case` membership, not an accident of two colliding shell bugs). ADR-098's
own isolated `grep -qw "$token"` probe (feeding the literal string directly,
bypassing the surrounding `for`-loop's own pathname expansion) is accurate as a
description of the `-w` vulnerability in isolation; its "current" column in the
combined pipeline table is the part that does not reproduce.

---

## F. `S19` — permanent regression fixture: `tools: [*]`

**Fixture:** `skill-star` — `tools: [*]`.

```
$ cd fixture-bypass2 && bash mf3-extracted-from-yaml.sh
::error::skills/skill-bracket/SKILL.md tools: present but unparsed (multi-line form not supported at v2.5)
::error::skills/skill-dcomma/SKILL.md tools: empty list element
::error::skills/skill-star/SKILL.md tools: contains invalid token '*' (allowed: claude-code copilot cursor windsurf)
exit=1
```

- [x] **RAN 2026-08-29.** Confirmed — `*`, run inside a directory that also
      contains real files (this is the same fixture set as §G below, not an
      empty directory), is refused by the `case " $ALLOWED " in *" $token "*)`
      membership test. **This is exactly the fixture S19 requires be kept
      permanently in the test set:** the `case` pattern's safety rests entirely
      on `" $token "` being double-quoted — `set -f` disables pathname
      expansion, which is a *different* shell mechanism from `case` pattern
      matching, and has **no effect** on whether an unquoted `case $token in`
      would let `*` re-glob as a case pattern (matching any string) instead of
      being tested as a literal. If a future edit ever drops the quotes around
      `$token` or `$ALLOWED` in the `case` statement, this fixture goes from
      `contains invalid token '*'` to a silent accept, and CI catches it. This
      fixture MUST remain in this file across future edits to MF-3 — do not
      remove it as "redundant" with the other bypass fixtures; it is the one
      that specifically exercises the quoting property, not the regex/glob
      properties §E exercises.

---

## G. Bonus adversarial coverage carried from Phase 2 (bracket-injection, double comma)

Both fixtures ran in the same batch as §F above (`fixture-bypass2`), output
shown there.

- **`skill-bracket`** — `tools: [[c]laude-code]`. The anchored shape precheck
  (`^tools:[[:space:]]*\[[^][]*\][[:space:]]*$`) requires the bracket interior
  to contain no nested `[` or `]`; this input's outer `[` is immediately
  followed by an inner `[`, so the whole-line match fails and the fixture
  correctly routes to the MF-S1 message, **not** into the tokenizer.
  - [x] **RAN 2026-08-29.** Confirmed — `tools: present but unparsed
        (multi-line form not supported at v2.5)`, not a tokenizer crash or a
        partial-match accept.
- **`skill-dcomma`** — `tools: [claude-code,,copilot]`. `IFS=','` splitting
  produces an empty middle field, which the empty-element guard inside the
  token loop catches explicitly.
  - [x] **RAN 2026-08-29.** Confirmed — `tools: empty list element`, a specific
        diagnostic rather than a silent drop of the malformed entry.

---

## H. Production validation — all 29 real skills, real shipped code

```
$ cd /Users/macbookpro/claude-cowork-config && bash .dev-scratch-mf3/mf3-extracted-from-yaml.sh
MF-3 tools: vocabulary gate passed (      29 skills checked).
exit=0
```

- [x] **RAN 2026-08-29.** Confirmed GREEN — every currently-shipping skill
      (`/usr/bin/grep -h "^tools:" skills/*/SKILL.md | sort | uniq -c` → `29
      tools: [claude-code]`) still passes the rewritten gate, run against the
      real `skills/` directory in this repository, using the exact step body
      now committed in `.github/workflows/quality.yml`.

---

## Disposition

`AC-PARSE-1`, `AC-PARSE-2`, and the folded `S17`/`S19` controls are all
demonstrated RED-then-GREEN with real, dated invocations. `AC-PARSE-3`/`-4`
(ADR-098 §Consequences — the two authorization bypasses D-2/D-3 that widening
the tokenizer would otherwise have made reachable) are demonstrated closed in
§E, and `AC-PARSE-4`'s own "inadmissible under `zsh`" clause is satisfied by
this file's blanket `/bin/bash` invocation discipline stated at the top.

**Residuals, named explicitly (not closed by this file):**

- **§E's falsification note is a documentation correction to ADR-098, not a
  code defect.** No follow-up fix is owed; the candidate's behavior for `.*` is
  correct (rejected) regardless of which historical reason the ADR gives for
  the pre-fix state.
- **Model drift.** A future model editing this step may reintroduce an
  unquoted `case` or a step-scoped `set -f` without re-running this file by
  hand; §F's `tools: [*]` fixture and this file's continued presence in CI-run
  documentation review are the only guard against that, per ADR-098's own
  §Maturation Path option (c) (a live meta-control in CI), which is explicitly
  **deferred**, not shipped, this cycle.

## Scope note

All fixture directories and extracted scripts used to produce the RED/GREEN
results above were constructed under `.dev-scratch-mf3/` at the repository
root — never inside `tests/`, `skills/`, or any other tracked path — and are
deleted before this cycle's changes are handed off, so no scratch fixture or
adversarial `SKILL.md` ships. `@qa` should re-run this file's invocations at
Phase 5 as part of formal test coverage, per this repo's standing convention
(`tests/pull-updates-firing-controls.md`, `tests/self-upgrade-firing-controls.md`).
