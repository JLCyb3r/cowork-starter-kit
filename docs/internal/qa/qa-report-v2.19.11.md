# QA Report — v2.19.11 "Pay the Tier-A debt"

## Phase: 5
## Date: 2026-08-22T02:26:49Z
## Status: PASS
## Verdict: **APPROVED**

Branch `release/v2.19.11-tier-a-debt` @ `edd5b82925aed309dc5fc99169f54026a4d61643`. Cycle base
`b7b844716aa3146f212907ee381a49256aa1fd13`, Phase-4 diff base `cdb40e4`. Real CI run
`32545547627` = **success** (confirmed via `gh run view`, job-by-job, log-grepped for this
cycle's own new instruments — see §5). 8 ACs in scope: AC-1, AC-2, AC-3, AC-8, AC-8b/AC-9b, AC-9,
AC-10, AC-11. Out of scope, not tested: AC-4/5/6/7a/7b, S5, A15, `CF-v2.19.11-A`. ADR-088
confirmed still PROPOSED (§4).

Everything below was **run**, against the real shipped files or fixtures derived from them by
`sed`/`awk` on a field-2/heading anchor — never a hand-written paraphrase of the real artifact,
per this project's standing rule that @qa rejects pure-mock controls on security-critical ACs.
Commands and their actual output are inlined. Anything not executed is labeled **NOT RUN**.

---

## 1. Per-AC verification (commands run, actual output)

### AC-1 — `evidence_tags()` fails loudly

Shipped function at `scripts/verify-release-surface.sh:119-164` matches
`docs/design-v2.19.11.md` §C.2 byte-for-byte (diffed by eye against the design's code block —
identical).

**Failure-path leg, run against the real function, correctly nested inside `$( )`** (this matters
— see below):

```
$ bash /tmp/ac1-harness2.sh   # sources the real evidence_tags(), calls TAGS_EVIDENCE="$(evidence_tags)"
                               # exactly as :218 does, against a scratch repo with an
                               # unresolvable origin (https://example.invalid/nope.git)
::error::release-surface: 'git ls-remote --tags origin' failed (exit 128) —
  the origin tag set could not be read, so every MISSING-TAG finding below would
  be an artifact of this failure rather than a fact about the repository.
  Failing closed. Raw git error:
    fatal: unable to access 'https://example.invalid/nope.git/': Could not resolve host: example.invalid
SCRIPT_EXIT=2
```

`::error::` present, exit **2**, `REACHED-AFTER-ASSIGNMENT` absent. Matches design §C.3 leg 1
exactly.

**Verification note (not a defect, worth recording):** my first harness attempt called
`evidence_tags` directly at top level instead of through `TAGS_EVIDENCE="$(evidence_tags)"`, and
got `SCRIPT_EXIT=128` with `rc=$?` never reached — i.e. the *pre-fix* behavior. This is exactly
the `inherit_errexit`/subshell mechanism ADR-089 documents: a command-substitution subshell does
not inherit `-e` unless `inherit_errexit` is on, so `rc=$?` is only reachable when the function
runs inside `$( )`, as it does at the real call site `:218`. Confirms the design's own claim that
this is load-bearing, by nearly reproducing the defect myself through an unfaithful harness.

**Credential-leak assertion — real git does not exercise it.** Tested two real-git failure modes
(unresolvable host; and a resolvable host with bad Basic-auth credentials in the URL against
`github.com`) — in both cases real git's own `fatal:`/`remote:` text **omits** the userinfo
(`git ls-remote` / the transport layer strips it before printing). The assertion
(`grep -qE '://[^/[:space:]]*@'`) is therefore, honestly, **only ever exercised by the design's
synthetic fixture** (`docs/design-v2.19.11.md` §C.3 leg 2), never by a real git failure mode I
could produce. The design labels this correctly as a fixture-only proof ("Proven able to fail
with a fixture") — it does not claim real-git reproduction. Recorded as INFO, not a finding: the
assertion is still a legitimate defense-in-depth inspection, just not one with a real-git positive
case I could find.

**Leg 3 (`EVIDENCE_DIR` byte-identical) and Leg 4 (happy-path byte-identical):** **NOT independently
re-run** — re-running these requires the sibling scripts (`release-predicate.sh`,
`semver-compare.sh`) plus a live `gh`-authenticated happy path, exactly the setup the design's own
note warns produces false REDs if done carelessly. Instead verified via real CI: the
`Release Predicate + Standing Gate Check (v2.19.6)` job (which runs `verify-release-surface.sh`
end-to-end against `tests/fixtures/release-surface/`, including an
`AC-PUB-12 — negative control (untagged in-flight version -> exit 1, MISSING-TAG)` step) — **PASS**
in real CI run `32545547627`. Labeled **NOT RUN locally**, confirmed via CI.

**Leg 5 — ShellCheck:** confirmed via real CI job `ShellCheck` — **success**.

**Verdict: AC-1 GREEN**, confirmed on the real function, real call-site semantics, real CI.

---

### AC-2 — de-pin the 5 citations

```
$ grep -cF 'CONTRIBUTING.md:129' scripts/canonicalize-scan.sh
0
$ grep -cF '`CONTRIBUTING.md § Worked-example authoring rules (S1 security carry-forward)`' scripts/canonicalize-scan.sh
5
$ grep -cF '### Worked-example authoring rules (S1 security carry-forward)' CONTRIBUTING.md
1
$ grep -v '^\s*#' scripts/canonicalize-scan.sh | grep -cE 'pip install|npm install|curl |wget '
0
```

All three legs GREEN, run against the real files.

---

### AC-3 — anchor-resolution guard, derived from the citing script

Extracted the real shipped step (`.github/workflows/quality.yml:1436-1468`) into a standalone
script and ran it directly, byte-identical to the design's §E.2 block.

```
$ cd /Users/macbookpro/claude-cowork-config && bash /tmp/ac3-guard.sh scripts/canonicalize-scan.sh CONTRIBUTING.md
anchor guard PASSED — anchor='Worked-example authoring rules (S1 security carry-forward)' distinct=1 cites=5 headings=1
EXIT=0
```

Leg (0), GREEN, **measured** values (not the retracted hardcoded-literal form §E.2 warns about) —
confirmed the S2 fix (measured output, not literal) is actually shipped.

```
$ bash /tmp/ac3-guard.sh scripts/canonicalize-scan.sh /tmp/CONTRIBUTING-renamed.md   # leg (i): heading renamed
::error::anchor guard — 'Worked-example authoring rules (S1 security carry-forward)' resolves to 0 headings, expected 1.
EXIT=1

$ bash /tmp/ac3-guard.sh scripts/canonicalize-scan.sh /tmp/ac3-dir-doc               # leg NEW-3: $DOC is a directory
grep: /tmp/ac3-dir-doc: Is a directory
::error::anchor guard — 'Worked-example authoring rules (S1 security carry-forward)' resolves to <non-numeric> headings, expected 1.
EXIT=1

$ bash /tmp/ac3-guard.sh /tmp/pre-ac2-canonicalize-scan.sh CONTRIBUTING.md            # leg (v): pre-AC-2 tree
::error::anchor guard — expected 1 distinct cited anchor, found 0.
EXIT=1
```

Four of the nine legs independently re-run (0, i, NEW-3, v) — chosen because NEW-3 is the leg the
design itself calls "the leg that decides the shape of the fix" (the `-r` precheck alone would
have missed it) and (v) is the sequencing-critical leg (proves AC-2+AC-3 must land together). All
four fire for the reason stated, not by accident. Legs (ii), (iii), (iv), NEW-1, NEW-2 **NOT
independently re-run** by me — trusted on the strength of: byte-identical shipped step text, the
documented three-round adversarial rework history (0.D R2 → Phase 1 → Phase 2/S1), and
confirmation the whole `canonicalize-scan-check` job passed in real CI.

Real CI confirmation — `Canonicalize + Forbidden-Token Scan Check (v2.18.0 F2/F3, ADR-068)` job,
log line: `anchor guard PASSED — anchor='Worked-example authoring rules (S1 security carry-forward)'
distinct=1 cites=5 headings=1`, run `32545547627`, **success**.

**Verdict: AC-3 GREEN**, structurally re-verified on the shipped step against real/derived
fixtures and against real CI.

---

### AC-8 / AC-9 — registry description rewrites

Shipped rows, `curated-skills-registry.md:31` (self-apply) and `:83` (prompt-gate), confirmed
byte-identical to design §F.1/§F.2.

```
$ awk -F'|' '$0 ~ /^\| self-apply \|/ {gsub(/ /,"",$8); print $8}' curated-skills-registry.md
0c77ab20779c79288eb35f3e1059955b566b3460456034b85dc87959a955e9f4
$ awk -F'|' '$0 ~ /^\| prompt-gate \|/ {gsub(/ /,"",$8); print $8}' curated-skills-registry.md
16b8ef1036d5d7320a7a166b5ea907d365a703b28f5858592bdccc810f1db2c3
$ shasum -a 256 skills/self-apply/SKILL.md
0c77ab20779c79288eb35f3e1059955b566b3460456034b85dc87959a955e9f4  skills/self-apply/SKILL.md
$ shasum -a 256 skills/prompt-gate/SKILL.md
16b8ef1036d5d7320a7a166b5ea907d365a703b28f5858592bdccc810f1db2c3  skills/prompt-gate/SKILL.md
$ awk -F'|' '$0 ~ /^\| self-apply \|/ {print NF}' curated-skills-registry.md   # 9
$ awk -F'|' '$0 ~ /^\| prompt-gate \|/ {print NF}' curated-skills-registry.md  # 9
```

Both field-8 controls match the spec's pinned expected values exactly, **and** independently
cross-checked against a live `shasum` of the actual `SKILL.md` files (not just trusting the
registry's own claim) — confirms neither `SKILL.md` was touched this cycle and the sha256 cells
are real hashes of real files, not placeholders.

```
$ grep -c 'a few' curated-skills-registry.md      # 0  (was 1, confirmed via git show cdb40e4)
$ grep -c 'up to 3' curated-skills-registry.md    # 1
$ sed -n '3p;73p' skills/prompt-gate/SKILL.md
description: … asking up to 3 grounded clarifying questions …
- Cap at 3 questions — one `AskUserQuestion` with up to 3 items is preferred over 3 separate questions.
```

AC-9's requirement ("restate the numeric bound the skill itself carries") independently confirmed:
`skills/prompt-gate/SKILL.md:3` and `:73` both say the same bound the registry now states.

Self-apply deny-list enumeration cross-checked at source (`skills/self-apply/SKILL.md:53`, the
real write-channel deny-list): `context/memory-of-use.md`, `context/.apply-backups/`,
`context/.kit-migrations/`, the `self-*` reserved prefix set, `cowork.install.json` — **all five**
named in the new row text. Enumeration is complete, not reduced.

**Verdict: AC-8/AC-9 GREEN**, structurally.

**Semantic-half judge — see §2 below, this is the explicit deliverable.**

---

### AC-8b / AC-9b — standing per-row structural gate

Extracted the real shipped step (`.github/workflows/quality.yml:723-757`) verbatim into a
standalone script and ran it **against the real `curated-skills-registry.md`** — not a
hand-written mock. The step's own fixtures are themselves derived from the real file via
`sed`/`awk` on the field-2 anchor, so even the injection legs exercise real content.

```
$ bash /tmp/ac8b-body.sh curated-skills-registry.md
AC-8b/AC-9b: self-apply OK - exactly 1 row, 9 fields, valid hex in field 8.
AC-8b/AC-9b: prompt-gate OK - exactly 1 row, 9 fields, valid hex in field 8.
AC-8b/AC-9b self-test PASSED - reflow GREEN, both pipe injections RED, row deletion RED.
AC-8b/AC-9b PASSED - gated slugs verified: self-apply prompt-gate.
EXIT=0
```

**Leg 6 — the check itself broken, run on the real (good) registry** (the leg AC-PL-6's two-step
split structurally cannot produce, per the design's own claim — independently verified):

```
$ sed 's/END{exit (seen==1 \&\& ok==1)?0:1}/END{exit 0}/' /tmp/ac8b-body.sh > /tmp/ac8b-broken.sh
$ bash /tmp/ac8b-broken.sh curated-skills-registry.md
AC-8b/AC-9b: self-apply OK - exactly 1 row, 9 fields, valid hex in field 8.
AC-8b/AC-9b: prompt-gate OK - exactly 1 row, 9 fields, valid hex in field 8.
::error::AC-8b SELF-TEST FAILED - a pipe injected into self-apply description was NOT detected.
::error::AC-9b SELF-TEST FAILED - a pipe injected into prompt-gate description was NOT detected.
::error::AC-8b SELF-TEST FAILED - a deleted self-apply row was NOT detected; the check is vacuous.
EXIT=1
```

Confirmed: a sabotaged `check_row()` still produces the "assertion passed" lines for both slugs,
but the self-test (running against the same real registry) catches it and fails the step. This is
the poisoned-backfill defense's self-integrity property, demonstrated on the real artifact, not a
synthetic one.

**Self-integrity pin (`PARSER_COPIES`), measured directly rather than trusted:**

```
$ grep -cF 's=$8; gsub(/ /,"",s); if (s ~ /^[0-9a-f]{64}$/) c++} END{print c+0}' .github/workflows/quality.yml
2
$ awk -F'|' '{s=$8; gsub(/ /,"",s); if (s ~ /^[0-9a-f]{64}$/) c++} END{print c+0}' curated-skills-registry.md
30
```

`PARSER_COPIES` = 2 (unperturbed — the AC-8b `check_row()` expression text differs from AC-PL-6's
pinned fragment, so it correctly doesn't double-count) and `AC_PL_6_EXPECTED_HEX_ROWS` = 30,
matching the pin exactly. No bump owed, confirmed by direct count, not by reading the design's
claim.

**Real CI confirmation**, run `32545547627`, job `Registry sha256 Drift-Verify Check (v2.18.0 F5,
ADR-069, MF-S-1)`:

```
AC-8b/AC-9b: self-apply OK - exactly 1 row, 9 fields, valid hex in field 8.
AC-8b/AC-9b: prompt-gate OK - exactly 1 row, 9 fields, valid hex in field 8.
AC-8b/AC-9b self-test PASSED - reflow GREEN, both pipe injections RED, row deletion RED.
AC-8b/AC-9b PASSED - gated slugs verified: self-apply prompt-gate.
```

This is on the real merge-candidate commit's real registry file, in the real CI environment — the
strongest evidence available. Not a mocked control.

**Verdict: AC-8b/AC-9b GREEN**, and it satisfies this project's "no pure-mock controls on
security-critical ACs" rule — every leg above ran against the real registry, either directly or
via a fixture mechanically derived from it.

---

### AC-10 — `never on its own` misattribution

Shipped `CHANGELOG.md:35-38` matches design §H.2 byte-for-byte; `WIZARD.md` confirmed
byte-unchanged:

```
$ git diff --stat b7b8447..HEAD -- WIZARD.md
(no output — zero diff)
```

**Corrected control (§H.3), re-derived from the design doc and run against the real tree:**

```
LINES=5 N_ALLTHREE=0 N_PULL=1 N_PHRASE=1 N_WZ=1
PAREN=[`never silently performs`, `reversibly`]
AC-10: GREEN
```

All eight assertions in the corrected control pass on the real `CHANGELOG.md`/`WIZARD.md`: the
numeral fix landed (`all three` → 0 occurrences in the bullet), the phrase is preserved
(`>=1`, not deleted), it's attributed to `pull-updates` (present), and it's **absent** from
`self-archive`'s own parenthetical (which now correctly lists only its own two phrases).
`WIZARD.md`'s own count stays exactly 1.

**Defect confirmed in the design doc's own §H.4 RED-d transcript — this is the item @dev
already flagged; I independently reproduced it rather than trusting the report.** The design
claims renaming the `awk` range's **end** anchor reproduces the vacuity guard
(`bullet extraction returned 0 lines`). It does not:

```
$ sed 's/^- \*\*The F4 bundle-customization/- **RENAMED-END-anchor bundle-customization/' CHANGELOG.md > /tmp/changelog-end-renamed.md
$ awk '/^- \*\*The wizard.s setup-complete closing message rewritten/,/^- \*\*The F4 bundle/' /tmp/changelog-end-renamed.md | wc -l
1242
$ awk '/^- \*\*The wizard.s setup-complete closing message rewritten/,/^- \*\*The F4 bundle/' /tmp/changelog-end-renamed.md | tr '\n' ' ' | grep -oF 'all three' | wc -l
2
```

Renaming the END anchor leaves the `awk` range unterminated — it runs to EOF (1242 lines, not 0),
and the control's leg 1 vacuity guard (`LINES -lt 3`) never fires. The eventual RED verdict is
real, but it comes from `N_ALLTHREE` picking up two **unrelated** "all three" occurrences
elsewhere in the file (`CHANGELOG.md:110` and `:256`, confirmed by `grep -n`) — not from the
vacuity guard the transcript credits. By contrast, renaming the **START** anchor does reproduce
the documented 0-line transcript exactly:

```
$ sed 's/^- \*\*The wizard.s setup-complete closing message rewritten/- **RENAMED-START-anchor closing message rewritten/' CHANGELOG.md > /tmp/changelog-start-renamed.md
$ awk '/^- \*\*The wizard.s setup-complete closing message rewritten/,/^- \*\*The F4 bundle/' /tmp/changelog-start-renamed.md | wc -l
0
```

**Severity: INFO, not a blocker.** AC-10 "ships no CI step" (spec, explicit) — this transcript is
a Phase-4/5 documentation artifact, not a live guard. The real, shipped fix is verified GREEN
above by every other leg, including the ones that matter operationally (numeral fixed, phrase
re-attributed, `self-archive`'s parenthetical no longer over-claims, `WIZARD.md` untouched). The
defect is confined to which of two hypothetical fixture directions the design doc's own
RED-d row correctly describes — it does not change AC-10's verdict. Recommend a one-line
correction to `docs/design-v2.19.11.md` §H.4 in a future doc-only pass: either split RED-d into
"start-anchor renamed → vacuity (0 lines)" and a separately-labeled leg for "end-anchor renamed →
runs to EOF, caught incidentally by `N_ALLTHREE`", or scope RED-d explicitly to the start anchor.

**Verdict: AC-10 GREEN** on the real artifact; one INFO-level documentation defect in the design's
own negative-control transcript, confirmed independently, not blocking.

---

### AC-11 — `fetch-tags` erratum, base-pinned

```
$ git diff --numstat b7b844716aa3146f212907ee381a49256aa1fd13..HEAD -- docs/retro.md
13   0   docs/retro.md
```

Exactly one row, 0 deletions, 13 additions — matches the AC's requirement exactly (an empty
result would be a FAIL, per the AC's own text; this is not empty). Diff content confirmed: an
`### Erratum — v2.19.11` section **appended** after the existing carry-forward table (not a
rewrite of `:124`/`:150`, confirmed unaffected by the insertion's line range). ADR-088 was not
touched by this correction (see §4).

**Verdict: AC-11 GREEN.**

---

## 2. AC-8 semantic-half judge (the explicit deliverable, design §F.5)

One row per rewritten string. YES/NO on (a) confirmation placed **before** the change takes
effect, (b) reversal placed **after**. Source-verified against `skills/self-apply/SKILL.md:87-114`
(the actual apply/rollback flow) and `skills/prompt-gate/SKILL.md:3` (the actual numeric bound) —
not judged from the registry text alone.

| Row | Pre-text (v2.19.10, `cdb40e4`) | Post-text (shipped, `edd5b82`) | (a) confirm BEFORE effect | (b) reversal AFTER effect |
|---|---|---|---|---|
| **self-apply** `curated-skills-registry.md:31` | "…**requires you** to propose a change, check it, and be able to reverse it **before it takes effect**." | "It proposes each change and shows you exactly what would happen; nothing is written until you say yes, and after a change has been made you can still undo it from the copy saved beforehand." | **YES** — "nothing is written until you say yes" is source-accurate: `SKILL.md:126` — turn-two apply render shows the exact diff, "followed by a plain yes/no ask; on yes, the write confirmation"; `SKILL.md:87` — "A write follows only the ACTUAL CURRENT turn's yes… The write itself happens immediately after that fresh confirmation." The old text inverted the actor (**you** propose) — the skill proposes, the user confirms; the new text correctly assigns "it proposes… shows you" to the skill and "you say yes" to the user. | **YES** — "after a change has been made you can still undo it from the copy saved beforehand" is source-accurate: `SKILL.md:108-112` — "Before the write happens, the target's exact current bytes are saved to `context/.apply-backups/…`" (copy saved **beforehand**), and rollback fires "only ever follows a verifier FAIL" — i.e. after the write. The old text's "reverse it before it takes effect" was the mis-timing this AC exists to fix; the new text moves reversal to strictly after. |
| **prompt-gate** `curated-skills-registry.md:83` | "Asks **a few** clarifying questions…" | "Asks **up to 3** clarifying questions…" | N/A — this row is a numeric-bound correction (AC-9), not a confirm/reversal-timing edit; the (a)/(b) axes don't apply. Judged instead on factual accuracy: **YES**, matches `skills/prompt-gate/SKILL.md:3` ("asking up to 3 grounded clarifying questions") and `:73` ("Cap at 3 questions") — both cited sources independently confirmed to say the same bound. | N/A (same reason). |

**Enumeration-completeness cross-check (self-apply row, part of the same semantic pass):** all
five real deny-list members from `skills/self-apply/SKILL.md:53` are named in the new text
(`context/memory-of-use.md`, `context/.apply-backups/`, `context/.kit-migrations/`,
`cowork.install.json`, the `self-` prefix set) — up from three in the old text. Strictly additive,
matches ADR-085's "may never weaken a stated guarantee" in the safe direction.

**Over-claim correction (Phase-2 rework, S4) verified at source, not inherited from the security
review:** the old text (and the pre-rework replacement) said the deny-listed set "can never be
changed or moved by this or any other skill." I independently read
`skills/self-apply/SKILL.md:59` (MF-1c) and `skills/pull-updates/SKILL.md:90` — confirmed a
`self-*` file **is** written by the installer/backfill channel (`pull-updates`), a different,
byte-verified channel the deny-list deliberately does not cover. The shipped row's amended text —
"Nothing you approve here can rewrite any of them… That list guards this flow, not the whole kit"
— is the accurate, narrower claim. `grep -c 'by this or any other skill' curated-skills-registry.md`
→ **0**, confirmed the over-claim is gone.

**Verdict: AC-8's semantic requirement is satisfied.** Both the actor-inversion and the
rollback-mis-timing defects are corrected, source-verified, not merely structurally passed.

---

## 3. Whole-diff regression check

```
$ git diff --numstat b7b844716aa3146f212907ee381a49256aa1fd13..HEAD
70    0     .github/workflows/quality.yml
3     3     CHANGELOG.md
2     2     curated-skills-registry.md
422   0     docs/architecture.md
1323  0     docs/design-v2.19.11.md
671   0     docs/internal/security/security-review-v2.19.11.md
13    0     docs/retro.md
1     0     docs/risk-register.md
336   0     docs/spec.md
5     5     scripts/canonicalize-scan.sh
35    1     scripts/verify-release-surface.sh
```

11 files. Every one is accounted for:

- **6 files carry the ACs' actual code/content changes**, and their insertion/deletion counts
  match the ACs exactly: `quality.yml` (+70/-0, two new inline steps, AC-3 + AC-8b/AC-9b),
  `CHANGELOG.md` (+3/-3, the 3-line H.2 replacement, AC-10), `curated-skills-registry.md` (+2/-2,
  two rows replaced in place, AC-8/AC-9), `scripts/canonicalize-scan.sh` (+5/-5, 5 citation
  replacements, AC-2), `scripts/verify-release-surface.sh` (+35/-1, one line replaced with the new
  block, AC-1), `docs/retro.md` (+13/-0, the appended erratum, AC-11).
- **5 files are process artifacts the spec explicitly requires or permits**, all pure-addition
  (0 deletions, confirming append-only discipline): `docs/architecture.md` (+422, ADR-089 +
  ADR-090, both required by the spec's "2 new ADRs owed"), `docs/design-v2.19.11.md` (+1323, this
  cycle's own design doc), `docs/internal/security/security-review-v2.19.11.md` (+671, the Phase-2
  security review), `docs/spec.md` (+336, this cycle's finalized spec), `docs/risk-register.md`
  (+1, the S5-out-of-scope acceptance row `v2.19.11-PULL-ROW-1`, correctly recorded as an accepted
  risk rather than a fix — matches the spec's own "ship with it named-and-unfixed" decision).

**Zero deletions in any append-only file** (`docs/architecture.md`, `docs/retro.md`,
`docs/spec.md` are all `+N/-0`) — confirmed by `git diff … | grep '^-'` returning only the file
header for `docs/architecture.md`.

No file outside the 8-AC scope was touched. No `CF-v2.19.11-A`/S5/A15 remedy code appeared (only
the S5 risk-register acceptance row, which is documentation of the deferral, not a fix).

---

## 4. ADR-088 status check

```
$ grep -n "ADR-088" docs/architecture.md | head -2
58: … | ACCEPTED — **AMENDED …** Note: **ADR-088, which supplies the remedy, is PROPOSED (deferred) as of Phase 1.3** …
111: … | **PROPOSED (deferred at v2.19.10 Phase 1.3 — was ACCEPTED at Phase 1.2 …)** |
```

Confirmed **PROPOSED**, unflipped, exactly as the spec requires ("ADR-088 stays PROPOSED. It is
not flipped and not amended by this cycle."). Both new ADRs this cycle (ADR-089, ADR-090) ship
**ACCEPTED** with all three required `§Maturation Path` sub-headers present verbatim
(**Future-state options:**, **Concrete revisit triggers:**, **Risk knowingly accepted:**) —
confirmed by direct grep/read of `docs/architecture.md:14381-14399` (ADR-089) and
`:14522-14545` (ADR-090).

---

## 5. What I ran (summary)

- Extracted and directly executed, against real repo files or real-derived fixtures: AC-1's
  `evidence_tags()` (2 harnesses — one deliberately wrong, corrected), AC-3's shipped CI step (4 of
  9 legs), AC-8b/AC-9b's shipped CI step (clean run + leg 6 self-integrity break), AC-10's
  corrected control (GREEN + both anchor-rename directions).
- Direct `grep`/`awk`/`shasum` verification of AC-2's three legs, AC-8/AC-9's field-8 + NF +
  enumeration + numeric-bound legs, AC-11's base-pinned diff, the `PARSER_COPIES`/`AC_PL_6_
  EXPECTED_HEX_ROWS` self-integrity pins.
- `gh run view 32545547627` — confirmed real CI success on the exact HEAD SHA, then
  `gh run view --log`, grepped for this cycle's own new instrument output lines
  (`anchor guard PASSED`, `AC-8b/AC-9b PASSED`, `AC-8b/AC-9b self-test PASSED`) — confirmed they
  fired for real in the real pipeline, not just in my local re-derivation.
- `git diff --numstat`/`--stat` for the whole-cycle regression sweep and the AC-11 base-pinned
  control.
- Read `skills/self-apply/SKILL.md`, `skills/pull-updates/SKILL.md`, `skills/prompt-gate/SKILL.md`
  at source for the semantic judge and the S4 over-claim correction — not inherited from the
  design doc or security review's characterization of them.

**NOT RUN:** AC-1 leg 3 (`EVIDENCE_DIR` byte-hash) and leg 4 (happy-path byte-diff) locally —
confirmed instead via the real CI job that exercises the same script end-to-end
(`Release Predicate + Standing Gate Check`, PASS). AC-3 legs (ii), (iii), (iv), NEW-1, NEW-2 —
not independently re-run; relied on shipped-step-text identity + real CI PASS + the 4 legs I did
run including the most failure-prone one (NEW-3, directory).

---

## 6. Findings

| Severity | AC | What | Evidence |
|---|---|---|---|
| INFO | AC-10 | `docs/design-v2.19.11.md` §H.4's RED-d transcript is wrong about *why* the leg goes RED when the `awk` range's END anchor is renamed. It claims the vacuity guard fires (0 lines); actually the range runs unterminated to EOF (1242 lines) and the RED comes from `N_ALLTHREE` incidentally matching two unrelated "all three" occurrences elsewhere in `CHANGELOG.md` (`:110`, `:256`). Renaming the START anchor, not the END anchor, is what reproduces the documented 0-line transcript. Does not affect AC-10's shipped verdict — AC-10 ships no CI step, and every operationally-relevant leg of the control passes GREEN on the real tree. Already surfaced during Phase 4 (per the orchestrator's briefing) and independently reproduced here with exact repro commands (§1, AC-10). | `awk … /tmp/changelog-end-renamed.md \| wc -l` → 1242 (not 0); `grep -n "all three" CHANGELOG.md` → lines 110, 256 exist outside the intended bullet |
| INFO | AC-1 | The credential-leak assertion's RED direction is only ever exercised by the design's synthetic fixture, never by a real git failure mode. Tested unresolvable-host and bad-Basic-auth-against-github.com; both real-git failure texts omit userinfo already. Not a defect — the design labels the fixture as synthetic honestly, and the assertion is legitimate defense-in-depth even without a real-git positive case. | Direct test against `git ls-remote` with `https://u:p@example.invalid/...` and `https://baduser:badpass@github.com/...` — neither leaked credentials in stderr |

**No BLOCKER, no CRITICAL, no WARNING findings.** Both findings above are INFO-severity,
non-blocking, and do not change any AC's verdict.

---

## Unit Tests / E2E Tests

This repo has no `npm test`/`pytest`-style suite; its test harness is the CI workflow
(`.github/workflows/quality.yml`, 33 jobs) plus `tests/fixtures/`. All jobs relevant to this
cycle's 6 code-touching files ran and passed in real CI (run `32545547627`, HEAD `edd5b82`):
ShellCheck, Canonicalize + Forbidden-Token Scan Check, Registry sha256 Drift-Verify Check,
Release Predicate + Standing Gate Check, Registry Cardinality Check, Wizard Consistency Check,
Self-Apply Deny-List Completeness Check, Version Consistency Check — all **success**. 3 jobs
`skipped` (`/sync-agency Dry-Run`, `Vendored Removal Ledger`, `lock-content-sha-cross-check`) —
unrelated to this cycle's file list (no vendored/lock-file changes), consistent with their
documented trigger conditions.

## Rework rate

Not computed — this is a Phase 5 report on a single implementation pass; no rework cycle occurred
before this Phase 5 (Phase 4 → Phase 5 is the first pass, per the operating context's single
Phase-4 diff base `cdb40e4`).

## Verdict

**APPROVED.** All 8 in-scope ACs verified GREEN against real artifacts and/or real CI, not
paraphrased transcripts. Two INFO-severity findings recorded, neither blocking. ADR-088 confirmed
unflipped. No unauthorized files touched. Ready for Phase 6.
