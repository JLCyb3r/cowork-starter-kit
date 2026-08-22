# Security Review — v2.19.11 "Pay the Tier-A debt"

## Phase: 2
## Date: 2026-08-21T19:53:57Z
## Status: FAIL — 1 BLOCKER, 0 CRITICAL

**Reviewer:** @security (opus)
**Branch:** `release/v2.19.11-tier-a-debt`
**Base SHA verified:** `b7b844716aa3146f212907ee381a49256aa1fd13` — `git merge-base --is-ancestor` → **BASE-OK** against HEAD `2e090a1`.
**Classification:** SECURITY-SENSITIVE — Tier A (settled, not re-derived). Guard Change Summary owed at Phase 6.
**Scope reviewed:** AC-1, AC-2, AC-3, AC-8, AC-8b/AC-9b, AC-9, AC-10, AC-11 (8 ACs).
**Out of scope, not reviewed:** AC-4, AC-5, AC-6, AC-7a, AC-7b (deferred to v2.19.12).

**Method note.** Every finding below was produced by *executing* the design's prescribed code — extracted
from `docs/design-v2.19.11.md` mechanically (Python fence-extraction for the shell blocks; `yaml.safe_load`
of a simulated `quality.yml` for the two CI steps, so what ran is what GitHub Actions would parse) — against
a **materialised post-edit tree** carrying all six of this cycle's pending file edits. Nothing in the
Findings table is an inspection-only hypothesis. Items I could not execute are labelled **NOT RUN**.

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | CRITICAL | 2 | configuration | **BLOCKER.** AC-3's anchor guard reports `PASSED` and exits 0 when `CONTRIBUTING.md` is unreadable — the one condition under which its assertion is unsatisfiable. Two reachable routes demonstrated. |
| S2 | WARNING | 2 | logging | AC-3's success line prints `distinct=1 … headings=1` as hardcoded literals, never the measured values, so the S1 fail-open transcript is byte-indistinguishable from a true pass — including in the design's own §E.3 leg (0) evidence. |
| S3 | WARNING | 2 | configuration | ADR-090 mints a repo-wide citation convention; AC-3 enforces it over one file. The uncovered sixth citation (`skills/self-apply/SKILL.md:45`) ships into every user workspace, is in a non-conforming variant form, and resolves to **0** headings today. |
| S4 | WARNING | 2 | permissions | AC-8's replacement row asserts the deny-listed set "can never be changed or moved by this or any other skill", distributed across the `self-` prefix set. `pull-updates`' trusted-installer backfill (ADR-073 / MF-1c) is exactly such a channel. Pre-existing over-claim; the rewrite carries it forward and sharpens it. |
| S5 | WARNING | 2 | permissions | **Carried, deliberately unfixed by design (§L).** `skills/pull-updates/SKILL.md` has a refusal clause for a malformed *manifest* (`:30`) but none for a malformed *registry row*, which `:49`/`:74`/`:83` require it to read a `sha256` out of. Owner decision at Phase 3. |
| S6 | INFO | 2 | logging | AC-8b's `FIX="$(mktemp -d)"` aborts the step under `set -e` with no diagnostic if `mktemp -d` fails — fail-closed but undiagnosable, the same A09 class AC-1 exists to close. |
| S7 | INFO | 2 | ui | A carriage return inside a cited anchor reaches the runner's stdout carrying arbitrary text after it (`::add-mask::` demonstrated locally). Whether GitHub Actions' command parser treats CR as a line boundary is **NOT RUN**. |
| S8 | INFO | 2 | dependency | ShellCheck returns **exit 0** on the defective AC-3 step. No static tool available in this repo would have caught S1; only executing the guard against a tree missing its input did. |
| S9 | INFO | 2 | configuration | AC-1's bare `mktemp` ignores `TMPDIR` on macOS (BSD) and honours it on GNU/CI. Not a defect — the path is unpredictable and the behaviour matches `evidence_body()`'s existing S-A6 pattern. Recorded so a future reader does not mistake it for one. |
| S10 | INFO | 2 | configuration | AC-10 ships no standing CI control (§H.5, deliberate). A future rot of the corrected CHANGELOG bullet is uncaught. Accepted — it is a historical record, not a live invariant. |

**BLOCKER count: 1 (S1). CRITICAL count: 1 (S1, same finding).** S1 blocks the Phase 3 gate.

---

## Scope-Allow Re-Walk (B2, ADR-127) — independent audit

Walked `docs/design-v2.19.11.md` §K `scope_allow_delta.add[]` against the design's §B file-by-file
sequencing. Six files, all pre-existing, none created/moved/deleted:

| Plan file | In `scope_allow_delta.add[]` | Verdict |
|---|---|---|
| `scripts/verify-release-surface.sh` | yes | PASS |
| `scripts/canonicalize-scan.sh` | yes | PASS |
| `.github/workflows/quality.yml` | yes | PASS |
| `curated-skills-registry.md` | yes | PASS |
| `CHANGELOG.md` | yes | PASS |
| `docs/retro.md` | yes | PASS |

**Scope-Allow Re-Walk: PASS (6/6 files verified).**

**Honest limitation, named:** the cross-reference against `.claude/agents/dev.md` `scope_allow.standard`
could **not** be run — that file lives in `/Users/macbookpro/The-Council`, which this cycle is instructed
not to touch beyond reading the spec (a parallel session is pinned to `self` there). This re-walk verifies
the delta is *complete and correct against the plan*; it does **not** verify the delta is *sufficient
against dev.md's regexes*. The orchestrator must run `scripts/guards/scope-allow-verify.sh` before Phase 4,
exactly as §K states. **NOT RUN: the dev.md regex leg.**

---

## Deferred-scope integrity — verified, all clean

The owner split this cycle at the Item 3 seam. Every guard on that split holds:

```
$ git diff --name-status b7b8447..HEAD
M       docs/architecture.md
A       docs/design-v2.19.11.md
M       docs/spec.md

$ git diff --find-renames=100% --name-status b7b8447..HEAD | grep '^R'
NO RENAMES

$ sed -n '111p' docs/architecture.md | tail -c 120
… | **PROPOSED (deferred at v2.19.10 Phase 1.3 — was ACCEPTED at Phase 1.2; number reserved
  for the S4 retrofit cycle, cf. ADR-028)** |

$ git diff b7b8447..HEAD -- docs/architecture.md | grep -E '^[-+]\| ADR-0(37|88)'
(no output — ADR-037 and ADR-088 index rows UNTOUCHED)

$ git diff --numstat b7b8447..HEAD -- docs/architecture.md
304     0       docs/architecture.md            # append-only, zero deletions

$ ls docs/ | grep -cE '^(qa-report|security-audit|security-review)-'
14                                               # unchanged — no 15th added at docs/ root
```

- **ADR-088: still PROPOSED.** Not amended, not flipped.
- **No file moved.** Zero renames at `--find-renames=100%`.
- **No `docs/` root report added.** This review is written to `docs/internal/security/`, which is
  `export-ignore`d in `.gitattributes` and therefore does not ship in the release archive.
- `docs/architecture.md` is append-only (304 additions, 0 deletions).
- §Maturation Path gate: `Future-state options:` / `Concrete revisit triggers:` / `Risk knowingly
  accepted:` → **58 / 58 / 58**, matching the design's §N claim.

---

## CRITICAL / BLOCKER

### S1 — AC-3's anchor guard fails OPEN when `CONTRIBUTING.md` is unreadable

- [ ] **BLOCKER. Must be corrected in `docs/design-v2.19.11.md` §E.2 before the Phase 3 gate opens.**

**The mechanism.** In the step as designed:

```bash
N_HEADS="$(grep -cF "### ${ANCHOR}" "$DOC" || true)"
if [ "$N_HEADS" -ne 1 ]; then echo "::error::anchor guard — …"; exit 1; fi
```

When `$DOC` is unreadable, `grep -cF` writes **nothing** to stdout (the `0` it prints on a zero-match is
only printed when the file *opens*), errors to stderr, and exits **2**. `|| true` captures the empty
string. `[ "" -ne 1 ]` is not false — it is an **error**: bash prints `[: : integer expected` and the test
returns **2**. A non-zero `if` condition is treated as FALSE, so the error branch is skipped, `set -e` does
not fire (a failing command in an `if` condition is exempt), and control falls through to the final
`echo "anchor guard PASSED …"` and **exit 0**.

The guard's entire stated purpose — *"it resolves to exactly one heading in `CONTRIBUTING.md`"* — is
**vacuously satisfied when `CONTRIBUTING.md` does not exist.**

**Route 1 — the document is renamed or deleted.** This is not hypothetical: it is precisely the citation-rot
scenario ADR-090 exists to close, and `docs/retro.md:138` records that a `CONTRIBUTING.md` edit inside a
*single cycle* moved the cited anchor's line number twice.

```
$ mv CONTRIBUTING.md CONTRIBUTING-renamed.md
$ bash ac3-run.sh          # the YAML-parsed step text, zero-arg, as Actions runs it
grep: CONTRIBUTING.md: No such file or directory
ac3-run.sh: line 11: [: : integer expected
anchor guard PASSED — anchor='Worked-example authoring rules (S1 security carry-forward)' distinct=1 cites=5 headings=1
EXIT=0        <-- CI GREEN
```

**Route 2 — `$DOC` resolves to a directory.** Survives an `-r` test, so a readability precheck alone does
not close it:

```
$ bash ac3-run.sh scripts/canonicalize-scan.sh docs
grep: docs: Is a directory
ac3-run.sh: line 11: [: : integer expected
anchor guard PASSED — … headings=1
EXIT=0
```

**Why this is BLOCKER and not WARNING.** (a) It is a brand-new always-on CI gate on a Tier-A surface;
(b) the failure direction is *open*, and the guard is the only thing standing between a rotted citation and
a green merge; (c) it is the **same defect class** — an unguarded/mis-guarded capture producing a
non-diagnosable outcome — that AC-1 exists to close, that `quality.yml:703-715`'s B4 note already fixed once
in this same workflow, and that §J.3 found and fixed *inside this very guard's previous draft*; and (d)
`CONTRIBUTING.md` is `export-ignore`d, so the file is genuinely absent from any `git archive` tree — a
future consumer running this guard against an archive gets an unconditional green.

**Sequencing note.** S1 does **not** change §B's mandatory co-landing of AC-2 and AC-3 (commit 2). That
constraint is independently correct and verified below (leg v). Fixing S1 does not make AC-3 safe to land
alone.

#### Exact corrected code (replaces `docs/design-v2.19.11.md` §E.2 verbatim)

```yaml
      - name: Citation anchor resolves to exactly one heading (AC-3, v2.19.11 — ADR-090)
        run: |
          set -euo pipefail
          SCRIPT="${1:-scripts/canonicalize-scan.sh}"
          DOC="${2:-CONTRIBUTING.md}"
          EXPECTED_CITES=5
          # [S1, @security Phase 2] BOTH halves below are load-bearing and neither alone is
          # sufficient. `grep -cF` on an unreadable file writes NOTHING to stdout (the "0" it
          # prints on a zero-match is only printed once the file opens) and exits 2; `|| true`
          # then captures the EMPTY STRING. `[ "" -ne 1 ]` is not false, it is an ERROR — the
          # test returns 2, an `if` treats non-zero as FALSE, `set -e` is exempt inside an `if`
          # condition, and the step falls through to the PASSED line and exit 0. Demonstrated
          # against a renamed CONTRIBUTING.md and against a $DOC that is a directory.
          #   Half 1 — the -r precheck: gives the DIAGNOSABLE error for the common case.
          #   Half 2 — the "${X:-x}" string comparison: closes every remaining route to an
          #            empty capture (a directory passes -r; so does a mid-run permission
          #            change). Do NOT drop it and keep only the precheck.
          # Do NOT "simplify" these back to `-ne`. A count from `grep -c` never has a leading
          # zero, so string equality is exact here.
          for f in "$SCRIPT" "$DOC"; do
            if [ ! -r "$f" ]; then
              echo "::error::anchor guard — '${f}' is missing or unreadable, so the citation cannot be resolved at all. This is the citation-rot case the guard exists to catch; it must never report PASSED."
              exit 1
            fi
          done
          ANCHOR="$(grep -oE "\`CONTRIBUTING\\.md § [^\`]+\`" "$SCRIPT" | sed "s/^\`CONTRIBUTING\\.md § //; s/\`\$//" | sort -u || true)"
          N_DISTINCT="$(printf "%s\\n" "$ANCHOR" | grep -c . || true)"
          if [ "${N_DISTINCT:-x}" != "1" ]; then echo "::error::anchor guard — expected 1 distinct cited anchor, found ${N_DISTINCT:-<non-numeric>}."; exit 1; fi
          N_CITES="$(grep -cF "\`CONTRIBUTING.md § ${ANCHOR}\`" "$SCRIPT" || true)"
          if [ "${N_CITES:-x}" != "$EXPECTED_CITES" ]; then echo "::error::anchor guard — expected ${EXPECTED_CITES} citations, found ${N_CITES:-<non-numeric>}."; exit 1; fi
          N_HEADS="$(grep -cF "### ${ANCHOR}" "$DOC" || true)"
          if [ "${N_HEADS:-x}" != "1" ]; then echo "::error::anchor guard — '${ANCHOR}' resolves to ${N_HEADS:-<non-numeric>} headings, expected 1."; exit 1; fi
          echo "anchor guard PASSED — anchor='${ANCHOR}' distinct=${N_DISTINCT} cites=${N_CITES} headings=${N_HEADS}"
```

The `|| true` on the `ANCHOR` assignment (§J.3's fix) is **retained unchanged** — it is correct, and leg (v)
below re-proves it.

#### My correction, checked in both directions — all eight legs RUN

Per the standing rule that a reviewer's correction is not privileged, the corrected step was run against
the same materialised post-edit tree, on every original leg plus the two new ones:

```
(0)  GREEN, zero-arg, post-AC-2 tree, CONTRIBUTING.md present:
     anchor guard PASSED — anchor='Worked-example authoring rules (S1 security carry-forward)' distinct=1 cites=5 headings=1
     EXIT=0
(i)   heading renamed        -> "…resolves to 0 headings, expected 1."             EXIT=1
(ii)  heading duplicated     -> "…resolves to 2 headings, expected 1."             EXIT=1
(iii) one citation typo'd    -> "expected 1 distinct cited anchor, found 2."       EXIT=1
(iv)  one citation deleted   -> "expected 5 citations, found 4."                   EXIT=1
(v)   PRE-AC-2 tree          -> "expected 1 distinct cited anchor, found 0."       EXIT=1
NEW-1 DOC renamed            -> "'CONTRIBUTING.md' is missing or unreadable, …"    EXIT=1   (was EXIT=0)
NEW-2 DOC chmod 000          -> "'CONTRIBUTING.md' is missing or unreadable, …"    EXIT=1   (was EXIT=0)
NEW-3 DOC is a directory     -> "…resolves to <non-numeric> headings, expected 1." EXIT=1   (was EXIT=0)
```

Leg NEW-3 is the one that proves the `-r` precheck alone would have been an insufficient correction — the
second half of the fix is load-bearing. **ShellCheck: exit 0 on the corrected step.**

---

## WARNING

### S2 — the AC-3 success line prints literals, not measurements

- [ ] The shipped line is `echo "anchor guard PASSED — anchor='${ANCHOR}' distinct=1 cites=${N_CITES} headings=1"`.
      `distinct=1` and `headings=1` are **hardcoded**. In the normal path they are guaranteed by the checks
      above; in the S1 fail-open path the `headings` check never executes, and the line asserts `headings=1`
      about a file that does not exist.

**Consequence for this cycle's own evidence.** The design's §E.3 leg (0) transcript reads
`anchor guard PASSED — … distinct=1 cites=5 headings=1`. That is **byte-identical** to the fail-open output
I captured. If @architect's materialised post-edit tree was built with `git archive` — which is the natural
way to build one, and which is what I did — then `CONTRIBUTING.md` was absent from it (it is `export-ignore`d;
`git archive HEAD | tar -tf - | grep -c '^CONTRIBUTING.md$'` → **0**), and that leg (0) GREEN *was* the
fail-open. **I cannot determine which it was** — that is the point of the finding. A success message that
cannot distinguish success from a specific failure is not evidence. **NOT RUN: reconstructing @architect's
tree.** Closed by the corrected code in S1, which prints `${N_DISTINCT}` and `${N_HEADS}`.

### S3 — ADR-090's convention is repo-wide; its enforcement is one file wide

- [ ] AC-3's guard reads `scripts/canonicalize-scan.sh` only. A **sixth** citation to the same
      `CONTRIBUTING.md` section exists at `skills/self-apply/SKILL.md:45`, in a *variant* form the new
      convention does not define:

```
citation form:  `CONTRIBUTING.md § Worked-example authoring rules, rule 2`
$ grep -cF '### Worked-example authoring rules, rule 2' CONTRIBUTING.md          -> 0
$ grep -cF '### Worked-example authoring rules (S1 security carry-forward)' …    -> 1
$ git archive HEAD | tar -tf - | grep -c '^skills/self-apply/SKILL.md$'          -> 1   (ships to users)
```

Under ADR-090 decision (1)'s own rule, this citation resolves to **zero** headings, and it is in the one
file of the two that ships into every user workspace. It is **pre-existing** (landed v2.19.10) and outside
AC-2's scope, so this is not a defect the cycle introduces — but ADR-090 asserts a repo-wide convention while
shipping enforcement that covers the lower-blast-radius file and not the higher one. Two honest dispositions,
either acceptable: (a) narrow ADR-090's §Decision (3) to say the guard is scoped to `canonicalize-scan.sh`
this cycle and name the SKILL.md citation as the next rung in §Maturation Path; or (b) extend
`$SCRIPT` to a two-file list in a follow-up. **Do not silently leave the ADR claiming more than the guard
does.** Not blocking — the guard is strictly better than what exists today.

### S4 — AC-8's replacement row over-claims the deny-list's reach

- [ ] The replacement text (design §F.1) reads: *"The change log itself, `context/memory-of-use.md`, can
      never be changed or moved **by this or any other skill** … and so are … every file whose name starts
      with `self-`, including this skill's own file."*

`skills/pull-updates/SKILL.md:90` describes exactly such a channel: *"this workspace is missing
`self-upgrade` … `pull-updates` backfills it as its own labeled step: bytes copied from
`skills/self-upgrade/SKILL.md`, byte-verified against the registry's `sha256` for that slug, installed."*
`skills/self-apply/SKILL.md`'s own MF-1c is explicit that this is *"a different channel entirely, never
reached by this deny-list's evaluation in the first place."*

So "by this or any other skill", distributed over the `self-` prefix set, is **false as written**. The
direction of the error is over-claiming protection, which does not weaken a stated guarantee in ADR-085's
sense — but in a user-facing description of a *safety* skill, telling a user that something can never be
written when a real channel writes it is the more dangerous direction of the two.

**This is inherited, not introduced.** The current row already says *"This file can never be changed or moved
by this or any other skill … Starting in v2.19, files whose names start with `self-` are protected the same
way."* The rewrite carries the claim forward and sharpens it (`including this skill's own file`).

**Disposition: route to @qa's Phase-5 semantic-half judge** (design §F.5, `qa-report-v2.19.11.md §N`) as an
explicit row, rather than blocking. Correcting it needs prose AC-8 does not scope, and AC-8's own binding
constraints (zero `|`, field-8 position, token preservation) are all independently satisfied — verified below.
If @qa's judge finds the accuracy defect material, it belongs in v2.19.12 alongside the S4 retrofit, not here.

### S5 — CARRIED, deliberately unfixed: `pull-updates` has no malformed-registry-row refusal

- [ ] **Not to be fixed this cycle.** Recorded in design §L; a risk-register row is added by this review.
      See "The S5 paragraph for the Phase 3 gate" below for the owner-facing statement.

The mechanism, stated precisely against the actual file:

- `skills/pull-updates/SKILL.md:30` — REFUSE clause exists, and it is scoped to a malformed
  **`cowork.install.json` manifest**: *"If it is unparseable, truncated, or schema-invalid … REFUSE to offer
  or apply any update."*
- `:49` / `:74` / `:83` — the poisoned-backfill defense requires each backfilled safety skill's bytes to be
  *"byte-verified against that slug's `curated-skills-registry.md` `sha256` entry BEFORE going live."*
- There is **no** clause anywhere covering a malformed registry **row**. On a pipe-shifted row, "that slug's
  `sha256` entry" is not well-defined — field 8 holds `mandatory-infrastructure`, not a hash. The prose says a
  mismatch is refused, which *might* fail closed; it might also cause the verification to be skipped as
  unavailable. **Undefined is not fail-closed**, and that is the whole finding.

---

## INFO

- **S6 — AC-8b's `mktemp -d` failure is undiagnosable.** `FIX="$(mktemp -d)"` sits at the top level of the
  `run:` block under `set -euo pipefail`; on failure the step aborts with a bare non-zero exit and no
  `::error::`. **Fail-closed** (RED), so not a security hole — but it is the same A09 class AC-1 exists to
  close, in a step landing in the same cycle. `rm -rf ""` (the trap firing with an empty `FIX`) was verified
  a safe no-op. One line closes it if wanted:
  `FIX="$(mktemp -d)" || { echo "::error::AC-8b — could not create a scratch directory for the self-test fixtures; the self-test could not run, so this step's GREEN would be unearned."; exit 1; }`

- **S7 — CR-bearing anchor reaches runner stdout.** A citation containing a carriage return is extracted
  intact and echoed:
  `::error::anchor guard — 'A^M::add-mask::SECRET' resolves to 0 headings, expected 1.`
  Whether GitHub Actions' workflow-command parser treats `\r` as a line boundary is **NOT RUN** — I have no
  way to execute against the real runner from here, so this is a **hypothesis**, not a demonstrated
  exploit. Reachability requires write access to `scripts/canonicalize-scan.sh`, i.e. a merged PR, so the
  practical severity is low. Cheap hardening if ever wanted: `ANCHOR="$(… | tr -d '\r')"`.

- **S8 — no static tool catches S1.** `shellcheck -s bash` on the *defective* AC-3 step returns **exit 0**;
  likewise on the AC-8b step. This is worth recording in the Phase-8 retro: the recurring remedy for this
  defect class cannot be "add linting." Only executing the guard against a tree missing its input found it —
  the same technique §J.3 used, applied one input further out.

- **S9 — `mktemp` and `TMPDIR`.** BSD `mktemp` (macOS) with no template ignores `TMPDIR` and uses the
  per-user `0700` temp directory; GNU `mktemp` (ubuntu, i.e. CI) honours it. Verified. Neither is a fixed
  path, so S-A6 is satisfied on both, and the behaviour is identical to `evidence_body()`'s existing call.
  Recorded so it is not re-litigated.

- **S10 — AC-10 carries no standing control**, by deliberate design (§H.5). Correct call: it corrects a
  historical CHANGELOG entry, and a third inline step for a one-shot prose fix would be over-engineering.
  The consequence — a future rot of that bullet is uncaught — is accepted here explicitly.

---

## What I verified and found CORRECT

These were attacked and held. Recording them so Phase 4/5 does not re-derive them, and so the Guard Change
Summary can cite measurements rather than claims.

### AC-1 — `evidence_tags()` (all legs RUN, including two the design did not run)

| Leg | Result |
|---|---|
| Pre-fix failure path | `SCRIPT_EXIT=128`, no output, `REACHED-AFTER-ASSIGNMENT` absent — reproduced |
| Post-fix failure path (real patched function text, extracted from the patched file) | `::error::` with git's own `Could not resolve host`, **`SCRIPT_EXIT=2`** — not 1, not 128 |
| **Temp-file leak on the `exit 2` path** | **No leak.** Instrumented `TMPDIR`, counted before/after: 0 → 0. `rm -f` runs on both the failure and success paths |
| **`mktemp` failure while `git` FAILS** | fail-CLOSED, `SCRIPT_EXIT=2` |
| **`mktemp` failure while `git` SUCCEEDS** | fail-CLOSED, `SCRIPT_EXIT=2`. The empty-filename redirect makes the command fail, so `rc≠0`. **No fail-open route through `mktemp`** |
| Symlink race / predictable path | `mktemp` (not a fixed path) — S-A6 satisfied, identical to `evidence_body()` |
| Happy path, real remote with tags | byte-identical to the old form |
| **Empty tag set (git exits 0, zero tags) — NOT tested by the design** | **byte-identical.** My hypothesised `printf '%s\n' ""` extra-blank-line divergence is neutralised because `$( )` strips trailing newlines. The untested direction is clean |
| `--evidence-dir` mode, real script vs real patched script | **byte-identical**, `sha256 713c888f…`, exit 0 both |
| Credential-leak assertion, **live** against a real `https://u:p@…` remote | **GREEN** — git anonymises the userinfo in its own stderr (`https://example.invalid/x.git/`); `grep -qE '://[^/[:space:]]*@'` → rc 1 |
| Credential assertion proven able to fail | fixture with literal `u:p@` → rc 0 → RED |
| ShellCheck on the fully patched script | **exit 0**, no findings |

**§J.1's `2>&1` fail-open — independently reproduced, not taken on report.** With a shim printing git's real
message shape to stderr and exiting 0:

```
2>&1  form -> ORIGIN_HAS_TAG=1     (FALSE GREEN)
mktemp form -> ORIGIN_HAS_TAG=0    (correct — MISSING-TAG)
```

The orchestrator's R2 adjudication of `2>&1` capture was fail-open on a Tier-A release gate, and the design's
`mktemp` resolution is the correct one. **AC-1 is sound as designed.**

### AC-8b / AC-9b — the poisoned-backfill anchor (my own BLOCKER S2 from 0.D)

**The `awk` claim is TRUE byte-for-byte.** Programmatically compared the program text between the single
quotes in the spec against the design's `check_row()`:

```
SPEC awk program == DESIGN awk program ?  True
len: 156 / 156
```

Only `-v row=` (`$slug` → `$2`) and the filename (`curated-skills-registry.md` → `"$1"`) are parameterised,
which is exactly what wrapping it in a function requires. **Nothing was altered.**

**The collapse to one step did not weaken anything.** Eight directions RUN against the YAML-parsed step text:

| Direction | Result |
|---|---|
| Pre-edit registry (clean tree) | GREEN, exit 0 |
| **This cycle's actual post-edit registry** | GREEN, exit 0 |
| Internal benign whitespace reflow fixture | GREEN (no false positive) — reported in the self-test line |
| Pipe injected into `self-apply` description | **RED**, exit 1 |
| Pipe injected into `prompt-gate` description | **RED**, exit 1 |
| `self-apply` row deleted entirely | **RED**, exit 1 (not vacuous) |
| **NEW — duplicate `self-apply` row** | **RED** (`seen==1` holds) |
| **NEW — uppercase hex in field 8** | **RED** (`^[0-9a-f]{64}$` holds) |
| **NEW — registry file missing** | **RED**, exit 1 — **fail-CLOSED** |
| **Leg 6 — `check_row()` sabotaged to `END{exit 0}`, run on a GOOD registry** | assertion passes, then **three `SELF-TEST FAILED` errors, exit 1** — the unearned GREEN is converted to RED |

Leg 6 is the property AC-PL-6's split arrangement structurally cannot produce, and it reproduces exactly as
the design claims. **The single-step collapse is strictly stronger, and it fails closed.**

Note the contrast with S1, since it is the whole lesson of this cycle: **AC-8b fails closed on a missing
input; AC-3 fails open on a missing input.** Two new guards, same cycle, opposite behaviour — because AC-8b
uses `if ! check_row …; then` (a boolean) and AC-3 uses `if [ "$X" -ne N ]` on a possibly-empty capture. The
defect is the idiom, not the `|| true`. The same empty-capture bug exists in AC-10's control
(`[ "$N_WZ" -eq 1 ] || FAIL=1`) and there it fails **closed**, verified — because that idiom treats the
test's error status as failure.

**Both pins verified unchanged, run and not asserted:**

```
$ grep -cF -f pin-frag.txt .github/workflows/quality.yml      -> 2   (today)
$ grep -cF -f pin-frag.txt <AC-8b step alone>                 -> 0
$ grep -cF -f pin-frag.txt <AC-3 step alone>                  -> 0
$ grep -cF -f pin-frag.txt <SIMULATED post-edit quality.yml>  -> 2   (unchanged)

# and the REAL AC-PL-6 step executed against the simulated post-edit tree:
$ AC_PL_6_EXPECTED_HEX_ROWS=30 bash acpl6-run.sh
AC-PL-6 PASSED — 30 rows carry a valid sha256 cell in field 8 (pin: 30).   EXIT=0
```

`PARSER_COPIES` stays **2**; `AC_PL_6_EXPECTED_HEX_ROWS` stays **30**. **No pin bump is owed and none must
be made.** The full simulated `quality.yml` parses: `yaml.safe_load` → 34 jobs,
`registry-sha256-check` 6 steps, `canonicalize-scan-check` 6 steps.

### AC-8 / AC-9 — S7 token preservation, re-checked against the ACTUAL replacement text

Run against the materialised post-edit registry, not against the AC prose:

```
field 8, self-apply : 0c77ab20779c79288eb35f3e1059955b566b3460456034b85dc87959a955e9f4   (UNCHANGED)
field 8, prompt-gate: 16b8ef1036d5d7320a7a166b5ea907d365a703b28f5858592bdccc810f1db2c3   (UNCHANGED)
NF self-apply / prompt-gate : 9 / 9
literal '|' in self-apply description (field 3) : 0
grep -cF 'a few'   : 0        grep -cF 'up to 3' : 1
`self-` (backticked)            : present
context/.kit-migrations/        : present
context/.apply-backups/         : present   <- ADDED
cowork.install.json             : present   <- ADDED
context/memory-of-use.md        : present
```

**S7 satisfied.** Both required tokens preserved. **The two added deny-list members are correct**: cross-read
against the real list at `skills/self-apply/SKILL.md` § *"The write-channel allow-list — deny-first"*, the
five members are the ledger, `context/.apply-backups/`, `context/.kit-migrations/`, the `self-` prefix set,
and `cowork.install.json`. The enumeration goes 3 → 5 with **nothing dropped** — strictly additive, the safe
direction under ADR-085. (The separate accuracy question about the *scope* of the protection claim is S4.)

### AC-10 — the corrected control, and RED-b / RED-c

The design's §H.3 corrected control was extracted and run in five directions:

```
GREEN — materialised corrected bullet                                        AC-10: GREEN  EXIT=0
RED-a — pre-edit tree (the defect itself)                                    AC-10: RED    EXIT=1
RED-b — numeral fixed, pull-updates named, phrase LEFT in the parenthetical  AC-10: RED    EXIT=1
RED-c — phrase DELETED outright                                              AC-10: RED    EXIT=1
RED-d — awk range endpoint renamed (vacuity)   "::error::AC-10 control BROKEN …"  EXIT=1
plus: WIZARD.md missing -> RED (fail-closed);  CHANGELOG missing -> "control BROKEN" (fail-closed)
```

**§J.2 is correct and consequential.** RED-b and RED-c are the two the spec's original `1 -> 0` leg could
not distinguish from a correct fix — and RED-c (deleting the phrase) would have passed all three of the
spec's legs while destroying the record AC-10 exists to correct. @architect's correction is verified, and its
own missing-file behaviour is fail-closed.

### AC-11 — all three legs reproduced on real history

```
(1) $ git diff --numstat b7b8447..HEAD -- docs/retro.md      -> rows=0   (must be treated as FAIL)
(2) $ git diff --numstat 7c8ac12 fd00dd2 -- docs/retro.md    -> 124  0   docs/retro.md
(3) $ git diff --numstat b3eb849~1 b3eb849 -- docs/retro.md  ->  21 16   docs/retro.md   (RED)
```

Exactly as documented. The base-pinned form is correct and the bare `git diff <path>` form is correctly
forbidden as evidence.

### AC-2 — inertness

`scripts/canonicalize-scan.sh:109` is `python3 - … <<'PYEOF'` — **quoted heredoc**, so the two new backticks
at `:123` are inert; `:10`, `:24`, `:40`, `:187` are shell `#` comments where backticks are also inert.
Post-edit: `grep -cF 'CONTRIBUTING.md:129'` → **0**; the target heading is unique at `CONTRIBUTING.md:157`
(**1**, measured before and after). SF-S-1 verified below.

---

## Instruction-laundering check on the new CI steps (A03 / LLM01)

**Question:** can a malicious or malformed `scripts/canonicalize-scan.sh` comment inject shell through
`$ANCHOR`?

**Answer: NO — demonstrated, not reasoned.** The three interpolation sites are the *only* places `$ANCHOR`
is used, and all three are double-quoted parameter expansions. There is no `eval`, no `sh -c`, no unquoted
expansion, and no re-parse anywhere in the step:

```bash
N_CITES="$(grep -cF "\`CONTRIBUTING.md § ${ANCHOR}\`" "$SCRIPT" || true)"   # -F: fixed string, not regex
N_HEADS="$(grep -cF "### ${ANCHOR}" "$DOC" || true)"                        # -F: fixed string, not regex
echo "::error::anchor guard — '${ANCHOR}' resolves to ${N_HEADS} headings, expected 1."
```

Three payloads planted five times each in a fixture script, then run through the YAML-parsed step:

```
payload `CONTRIBUTING.md § $(touch /tmp/AC3_PWNED)`
  -> ::error::anchor guard — '$(touch /tmp/AC3_PWNED)' resolves to 0 headings, expected 1.   EXIT=1
  -> /tmp/AC3_PWNED exists? NO

payload `CONTRIBUTING.md § x"; touch /tmp/AC3_PWNED2; echo "`      (quote-break attempt)
  -> ::error::anchor guard — 'x"; touch /tmp/AC3_PWNED2; echo "' resolves to 0 headings…    EXIT=1
  -> /tmp/AC3_PWNED2 exists? NO

payload `CONTRIBUTING.md § $(id)`
  -> ::error::anchor guard — '$(id)' resolves to 0 headings, expected 1.                     EXIT=1
```

Every payload is echoed back as inert text. Two structural properties make this robust rather than
accidental: (1) the extraction regex is `` `CONTRIBUTING\.md § [^`]+` ``, so an anchor **cannot contain a
backtick** — the classic command-substitution character is excluded by construction; (2) `grep` is
line-oriented and `sort -u` emits whole lines, so `$ANCHOR` can never contain a newline, and the
`N_DISTINCT != 1` gate rejects any multi-element result before `$ANCHOR` is echoed. Combined, a workflow
command can never be placed at the start of a runner-stdout line via this path. The one residual is the
carriage-return case (S7), which is **NOT RUN** against the real runner and is a hypothesis.

**AC-8b carries no equivalent surface**: it interpolates only `"$REG"` and the loop variable `$slug`, and
`$slug` comes from the workflow-literal `GATED_SLUGS="self-apply prompt-gate"`, never from repo content.

---

## COMPLIANCE tripwire — verdict for the merge gate

**COMPLIANCE-SENSITIVE: NO. `/legal` is NOT owed. Tripwire CLEAR on both legs, verified independently.**

**Leg (b) — the AC-10 hunk must exclude `CHANGELOG.md:42-44`.** I materialised the design's §H.2 replacement
against the real `CHANGELOG.md` and measured the actual hunk rather than accepting the reported range. First,
the byte-equality precondition (if line 35 were not byte-identical the hunk could shift):

```
CHANGELOG.md:35  "- **The wizard's setup-complete closing message rewritten** — every technical term inline-defined,"
design line 1    "- **The wizard's setup-complete closing message rewritten** — every technical term inline-defined,"
LINE 35 BYTE-UNCHANGED? True        (4 lines replace 4 lines; 1277 -> 1277)
```

Then the measured hunk:

```
$ git diff --no-index -- CHANGELOG.md <materialised>/CHANGELOG.md
@@ -33,9 +33,9 @@ scoped to SEO/positioning copy only.
```

**`@@ -33,9 +33,9 @@` → lines 33–41.** `CHANGELOG.md:42-44` — the bullet carrying *"All six protected data
categories and both negative guarantees survive unchanged"* — is **outside the hunk**, by one line. @architect's
reported range is **CONFIRMED**, independently measured, not taken on report.

**Leg (a) — no diff line touches `examples/personal-assistant/context/working-rules.md`.** That path appears
nowhere in the design's §K `scope_allow_delta.add[]` (six files, enumerated above), nowhere in §B's four
commits, and the branch's current diff against `BASE` touches only `docs/architecture.md`,
`docs/design-v2.19.11.md` and `docs/spec.md`. **CLEAR.** @dev remains bound at Phase 4 to assert
`git diff --numstat -- examples/personal-assistant/context/working-rules.md` emits **no row** — this is a
design-time verdict, and the Phase-4 assertion is the one that binds the built artifact.

**Margin note for @dev, since leg (b) clears by exactly one line:** any edit that adds or removes a line
anywhere in `CHANGELOG.md` above line 42 shifts this hunk. Do not fold any other CHANGELOG change into
commit 4 without re-measuring the hunk range.

---

## The S5 paragraph for the Phase 3 gate

*(Written to be actionable by a non-developer, per the remit. This is what the owner is accepting.)*

> **What you are accepting.** One of the safety skills, `pull-updates`, is the thing that installs or repairs
> the other safety skills in a user's workspace. Before it does, it is required to check the new copy against
> a fingerprint recorded in one specific column of `curated-skills-registry.md`. The skill has a clear written
> rule for what to do if the *install record* is damaged — it refuses and says so. It has **no written rule at
> all** for what to do if the *registry row* is damaged, which is what happens if a stray `|` character gets
> into a description and pushes every column one place to the right. In that state the fingerprint column
> holds a word instead of a fingerprint. The skill might refuse; it might compare against the wrong thing; it
> might decide there is nothing to check and install anyway. Nobody has written down which, and "nobody wrote
> it down" is not the same as "it fails safely." **What makes this acceptable to defer:** this cycle adds a
> standing CI check (AC-8b/AC-9b) that makes exactly this damage impossible to merge into the repository the
> registry ships from — I ran it in ten directions and it went red on every form of the damage, including one
> where I sabotaged the check itself and its own self-test caught that too. **That CI check is load-bearing.**
> With it in place, the only way to reach the undefined state is for someone to hand-edit their own copy of the
> registry inside their own workspace. Without it, the gap would be reachable through an ordinary merge. **What
> you are NOT accepting:** any weakening of anything that exists today — this is a pre-existing gap in wording,
> not something this cycle creates. **The cost of fixing it here instead:** `pull-updates` is itself one of the
> fingerprinted rows, so editing its file forces a *third* fingerprint change inside a cycle whose single
> biggest risk is already "we are editing fingerprinted rows." I recommend shipping with it named and fixing it
> in a cycle that is not also editing the rows.

A risk-register row has been added recording this (`v2.19.11-PULL-ROW-1`).

---

## OWASP Top 10 Assessment

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | **PARTIAL** | No auth surface. The nearest analogue is the `self-apply` write-channel deny-list, whose *description* over-claims its reach (S4). The deny-list itself is untouched by this cycle. |
| A02 Cryptographic Failures | **PASS** | No crypto introduced. Both `sha256` cells byte-unchanged (verified). AC-8b pins hash *shape* (`^[0-9a-f]{64}$`), never a hash *value* — correct: pinning values would force a bump on every legitimate SKILL.md edit. |
| A03 Injection | **PASS** | `$ANCHOR` interpolation attacked with three payloads × 5 occurrences; no shell injection, no command substitution, no quote-break. Backtick excluded by the extraction regex; newline excluded by grep's line orientation. `grep -F` throughout. Residual: S7 (CR), **NOT RUN** against the real runner. |
| A04 Insecure Design | **FAIL** | **S1.** A new always-on CI gate whose assertion is vacuously satisfied by the absence of the thing it asserts about. Corrected code supplied and verified in 8 directions. |
| A05 Security Misconfiguration | **PASS** | `.gitattributes` unchanged. This review is written under `docs/internal/security/` (`export-ignore`d) and adds no 15th report to `docs/` root — count verified still **14**. YAML validity of the simulated post-edit workflow confirmed by `yaml.safe_load` (34 jobs). |
| A06 Vulnerable/Outdated Components | **PASS** | Zero dependencies added. SF-S-1 verified against the post-edit script: `grep -v '^\s*#' \| grep -cE 'pip install\|npm install\|curl \|wget '` → **0**. No `npm audit` surface — this repo has no package manifest. |
| A07 Identification & Auth Failures | **N/A** | No identity or session surface in scope. |
| A08 Software & Data Integrity Failures | **STRENGTHENED** | The headline category. AC-8b/AC-9b converts a one-shot human prohibition into a standing per-row structural gate over the two supply-chain rows `pull-updates` byte-verifies against — verified RED in 6 damage directions, GREEN on both the benign reflow and this cycle's real rewrite, and **leg 6** converts a sabotaged checker's unearned green into red. AC-1 closes a fail-open on the release-surface gate (a broken-ref diagnostic could be read as tag-exists — reproduced). Residual: S5, runtime side, deferred with a named control. |
| A09 Security Logging & Monitoring Failures | **MIXED** | AC-1 is a clear improvement: a silent `exit 128` becomes a named `::error::` carrying git's own words, with no credential leak on any transport tested. Against that: **S2** (a success line that prints literals instead of measurements, making a failure indistinguishable from a pass in this cycle's own evidence) and **S6** (an undiagnosable abort path in AC-8b). |
| A10 SSRF | **N/A** | The one external call, `git ls-remote --tags origin`, targets only the configured remote; `assert_gh_destination_repo` at `:116` is unchanged and still runs ahead of `evidence_tags()` in non-evidence mode. |

### LLM threat assessment

| Category | Status | Notes |
|---|---|---|
| LLM01 Prompt Injection | **PASS** | AC-2's de-pin is inert to `canonicalize-scan.sh`'s forbidden-imperative scan (quoted heredoc verified; the design's both-direction behavioural leg holds). The AC-8/AC-9 replacement rows are declarative user-facing prose containing no imperative that a runtime reader could act on. The AC-3 guard treats repo content strictly as data — proven above. |
| LLM02 Insecure Output Handling | **PASS** | AC-1's `::error::` emits git's raw stderr under a `sed 's/^/    /'` indent only. The credential assertion is an **inspection**, never a redaction transform — correct, and the design's prohibition on adding a `sed` redactor should be preserved. Verified GREEN live against a real `u:p@` remote and proven able to fail on a fixture. |
| LLM06 Sensitive Information Disclosure | **PASS** | git anonymises userinfo in its own stderr on the transport tested; no token, path outside the workspace, or credential appears in any emitted diagnostic. `mktemp` files are removed on every path (verified 0 → 0 with an instrumented `TMPDIR`). |

---

## For the Phase 6 Guard Change Summary — flagged now

Items I already know must appear, so Phase 6 does not rediscover them:

1. **A behaviour change on a release gate.** `verify-release-surface.sh` now hard-stops with **exit 2** and a
   printed cause where it previously died at exit 128 with no output. Louder and stricter — a run that used to
   die confusingly now dies clearly, and a run that used to *silently* produce nothing now refuses.
2. **Two new always-on CI steps that can block a merge**, both inline in `quality.yml`, both proven able to go
   red on the damage they exist to catch and proven able to go green on benign change.
3. **S5 ships named and unfixed**, with the AC-8b/AC-9b CI gate as the load-bearing independent control. The
   Phase-3 paragraph above is the honest form.
4. **`EXPECTED_CITES=5` and the `NF==9` shape are intentional future red-liners** — a legitimate 6th citation
   or a legitimate new registry column will red-line CI, and must be fixed by bumping the constant in the same
   edit, never by relaxing the check.
5. **Forward-only caveat:** S1's corrected guard, if the correction is applied, has no way to prove itself in
   CI until a future cycle actually renames or moves `CONTRIBUTING.md`. Its value is entirely in the direction
   nothing has yet travelled.
6. **What could not be proven:** whether @architect's §E.3 leg (0) GREEN was a true pass or the S1 fail-open
   (S2) — the transcripts are byte-identical, and the tree that produced it no longer exists.

---

## Summary

The design is a careful, high-quality document. Its four §J findings are all real and all correctly fixed;
I re-ran the load-bearing ones rather than accepting them, and every one held — including the `2>&1`
fail-open, which I reproduced independently and which confirms the orchestrator's R2 adjudication of AC-1 was
wrong and the design's `mktemp` resolution is right. @architect's two most consequential claims — that the
AC-8b `awk` was not altered, and that the AC-10 hunk excludes `CHANGELOG.md:42-44` — are both **TRUE**,
verified byte-for-byte and by measured diff respectively. AC-1, AC-8b/AC-9b, AC-10's corrected control and
AC-11's base-pinned control are all sound and all fail closed.

One item is not sound. **AC-3's guard reports `PASSED` in exactly the situation that makes its assertion
impossible to satisfy**, and it prints a success line whose `headings=1` is a hardcoded literal rather than a
measurement — which means the design's own evidence that the guard passes cannot be distinguished from the
guard failing open. This is the twelfth-and-thirteenth instance of this cycle's signature failure mode: the
defect is inside the remedy, and specifically inside the *third* revision of this one guard (spec → R2 fix →
§J.3 fix → still open). It was found the same way §J.3's was — by running the guard against a tree missing
its input — one input further out than the previous round looked.

**Verdict: FAIL. 1 BLOCKER (S1), 0 additional CRITICAL, 4 WARNING, 5 INFO.** The remedy is small and fully
specified: replace `docs/design-v2.19.11.md` §E.2 with the corrected step above, which I have run through all
six original legs plus three new ones. Once §E.2 is amended, this review's verdict converts to **PASS WITH
WARNINGS** and the Phase 3 gate may open with S3, S4 and S5 carried to the owner as named, accepted items.
