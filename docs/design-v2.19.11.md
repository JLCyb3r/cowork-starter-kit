# Design — v2.19.11 "Pay the Tier-A debt"

**Date:** 2026-08-21T19:17:16Z
**Author:** @architect (opus), Phase 1
**Branch:** `release/v2.19.11-tier-a-debt`
**Base SHA (BASE, literal — every base-pinned control in this document uses it):**
`b7b844716aa3146f212907ee381a49256aa1fd13`
**Classification:** SECURITY-SENSITIVE — **Tier A** (worktree/branch + PR + @security Guard Change
Summary owed at Phase 6). **COMPLIANCE-SENSITIVE: NO** (tripwire re-measured in §F.4).
**Scope:** AC-1, AC-2, AC-3, AC-8, AC-8b/AC-9b, AC-9, AC-10, AC-11 — **8 ACs.**
**Out of scope, DEFERRED to v2.19.12 by owner decision (2026-08-21T12:20:00Z):** AC-4, AC-5, AC-6,
AC-7a, AC-7b — the entire S4 report-egress retrofit. **Not designed here. ADR-088 stays PROPOSED
and is not amended. `docs/architecture.md`'s ADR-037 index cell is not touched. No file is moved.**


---

## Phase 2 rework record — 2026-08-22T01:36:59Z

**Author:** @architect (opus), Phase 2 rework. **Trigger:** `docs/internal/security/security-review-v2.19.11.md`
— verdict **FAIL — 1 BLOCKER (S1)**. **Scope of this rework: three items, nothing else.**

| Finding | Severity | Disposition | Where |
|---|---|---|---|
| **S1** — AC-3's anchor guard fails OPEN when `CONTRIBUTING.md` is unreadable | BLOCKER | **FIXED** — §E.2 replaced with @security's corrected step, applied **verbatim** (`diff` against the review's block: identical) | §E.2, §E.3 |
| **S2** — the AC-3 success line prints literals, not measurements | WARNING | **FIXED by the same correction** — the line now prints measured `distinct=${N_DISTINCT} cites=${N_CITES} headings=${N_HEADS}`. The original §E.3 leg (0) is **retracted as evidence** | §E.2, §E.3 |
| **S3** — ADR-090's convention is repo-wide; its enforcement is one file wide | WARNING | **DEFERRED as `CF-v2.19.11-A`** (v2.19.12). The *gap* is recorded now, in an appended ADR-090 amendment record — only the *repair* moves | §E.5, `docs/architecture.md` |
| **S4** — AC-8's replacement row over-claims the deny-list's reach | WARNING | **FIXED** — row amended; all binding constraints re-verified (field 8, `NF`=9, zero `\|`, tokens, hex-count 30) with a RED leg proving the checks can fail | §F.1, §F.1.1 |
| **S5** — `pull-updates` malformed-row refusal | CARRIED | **Untouched** — owner decision at the Phase 3 gate, per the review's own disposition | §L |

**Untouched by this rework, deliberately:** AC-4/5/6/7a/7b (v2.19.12); the Tier-A classification
(settled); A15 (deferred); **ADR-088 — still `PROPOSED (deferred)`, not amended, index cell not
touched**; no file moved; no report added to `docs/` root.

**Append-only discipline held:** `git diff --numstat` → `docs/architecture.md` **118 / 0**,
`docs/spec.md` **untouched**. `docs/design-v2.19.11.md` is this cycle's own new file and is edited
in place, as permitted.

**On @security's corrected code:** applied as given. It was syntax-checked (`bash -n` on the
YAML-parsed run body: clean; `yaml.safe_load` → exactly 1 step, 31-line `run`) and **not altered**.
No disagreement to report.
---

## Phase 1 design header

> *ISO 15288 — Technical Management: Decision Management.*

**Worktree discipline: SKIPPED-BY-CONVENTION (in-place branch work).** `COUNCIL_EXPECTED_BASE_SHA`
was supplied and verified: `git -C /Users/macbookpro/claude-cowork-config merge-base --is-ancestor
b7b8447 HEAD` → **BASE-OK**; `git worktree list` → **1 entry** (this repo works in place on a
release branch, not in a detached worktree — the repo's own convention, unchanged from v2.19.10).

**Buy-vs-Build: N/A — no non-trivial new components this cycle.**

**Reuse Scan.** Every change in scope is a *repair of an existing surface* — no new module, no new
dependency, no new file under `scripts/`, no new workflow. The one genuinely new artifact is two
inline CI steps, and both are constrained by a standing repo rule (TIER-4: never under `scripts/`).

| Component | Registry hit (grep pasted) | OSS candidate (name+license+health) | Scaffold | Decision | Basis |
|---|---|---|---|---|---|
| AC-1 `evidence_tags()` failure path | Source 1: `docs/reuse-registry.md` not present in this repo — skipped | none sought | n/a | **REUSE (in-repo)** | Mirrors `evidence_body()`'s S-A3 pattern at `scripts/verify-release-surface.sh:135-169`, verbatim in shape. Not a build. |
| AC-3 anchor guard | Source 1 not present — skipped | none sought | Source 2: `examples/scaffolds/INDEX.md` not present — skipped | **BUILD (12 lines, inline)** | No hit; core differentiator — the guard must derive its expectation from the citing file, which no generic linter does. <100 LoC, no dependency. |
| AC-8b/AC-9b per-row gate | Source 1 not present — skipped | none sought | n/a | **EXTEND (in-repo)** | Extends the house fault-injection model already at `quality.yml:576` and `:619`; the `awk` expression is @security's, unmodified. |

Source 3 (CS catalog / `Reusability:` ADR tags) and Source 4 (`sos-interfaces.json`) live in
The-Council, which this cycle is instructed not to touch beyond reading the spec. Recorded as
**not consulted, by instruction** rather than as "no hits" — the honest form.

**EARS check: 0 HIGH-severity findings — no OQs generated.** The eight in-scope ACs were re-read
against EARS syntax at Phase 1. All eight carry an explicit trigger word (`WHEN`, `WHERE`, `THE …
SHALL`), a named file, and at least one executable control. Two advisory (non-HIGH) notes, both
recorded in §J because they change a control rather than a requirement: AC-1's mechanism clause
is internally contradictory (§J.1) and AC-10's control leg 1 contradicts AC-10's own prose (§J.2).

**SoS Classification:** N/A — single-project design. UAF viewpoints, each explicitly:
**Strategic** — N/A, single-project design. **Operational** — N/A, single-project design.
**Service** — N/A, single-project design. **Personnel** — N/A, single-project design.

**Reliability Analysis: N/A per NEVER-APPLY** (no multi-provider request path, no failover
mechanism, no SLA or availability claim anywhere in the eight in-scope ACs; the only external call
touched is a single `git ls-remote` whose *failure handling* is the subject, not its availability).

**Heuristics Check (Rechtin), consulted for ADR-089 and ADR-090:**

| Heuristic | Signal produced this cycle |
|---|---|
| *"In introducing technological and social change, how you do it is often more important than what you do."* | Applied. AC-2's rewrite is a find-and-replace; AC-3 is what makes it durable. The pair is one ADR (ADR-090), not two, because the convention is the deliverable. |
| *"Don't assume that the original statement of the problem is necessarily the best, or even the right one."* | **Fired twice.** The spec's Item 1 statement ("misleading MISSING-TAG") was already amended to "silent crash" at Phase 0; Phase 1 found a second restatement was needed (§J.1). |
| *"The first line of defense against complexity is simplicity of design."* | Applied to AC-8b: **one step, one copy** of the parser, instead of the two-step split that produced defect A4 in v2.19.10 and now costs a permanent `PARSER_COPIES` pin (§G.5). |
| *"A model is not reality."* | Applied. Every instrument in this document was run against the **actual** repository files, and where a post-edit state was needed, against a **materialised** post-edit copy — never reasoned about. Four defects were found that way (§J). |
| *"Regarding trade-offs: … if you can't tell the difference, it doesn't matter."* | Not applicable — no trade-off in this cycle turned on an unmeasurable difference. Recorded per the even-when-empty rule. |
| *"Build in and maintain options as long as possible in the design … "* | Not applicable in the usual sense (this is a repair cycle), but its inverse fired: **ADR-088 is deliberately left PROPOSED** so v2.19.12 keeps the option, rather than being closed out here. |

**Production validation: N/A — no repo-artifact parsing in this design** in the Council sense (no
`pipeline.md` / `registry.json` / `roadmap.md` parser is introduced, and no other registered
project is in scope). The equivalent discipline *was* applied within this repo and is the reason
this design is trustworthy: **every** instrument below was executed against the real
`CONTRIBUTING.md`, `scripts/canonicalize-scan.sh`, `curated-skills-registry.md`, `CHANGELOG.md`,
`WIZARD.md`, `.github/workflows/quality.yml` and `docs/retro.md` at `b7b8447`, and against a
**materialised** copy carrying this cycle's own pending edits. Not one control in this document is
fixture-only. Per-instrument transcripts are inline in §G.

**B1 verification: DEFERRED to the orchestrator.** `scripts/guards/scope-allow-verify.sh` and
`.claude/agents/dev.md` live in `/Users/macbookpro/The-Council`, which this cycle is instructed not
to touch beyond reading the spec (a parallel session is active there). The `scope_allow_delta:`
block is supplied in §K for the orchestrator to verify before Phase 4.

**§Maturation Path self-grep (Workflow step 5.5 — GATE before Phase 1 DONE).** Baseline at
`b7b8447` = **56 / 56 / 56**; +2 new ADRs (089, 090), each carrying the verbatim block → **58 /
58 / 58**. Output pasted in §M.

---

## §A. What this cycle is, in one paragraph

Four carry-forwards from v2.19.10 are paid off, and one erratum is filed. A release-surface script
that dies silently on a network failure is made to say why and fail closed (AC-1). Five stale
line-number citations are re-anchored to a heading, and a CI step is added that derives the
expected anchor *from the citing file* so the new form cannot rot the way the old one did (AC-2 +
AC-3). Two user-facing registry descriptions that say the wrong thing are corrected, and a standing
CI gate is added so the correction cannot silently shift a supply-chain hash cell (AC-8, AC-9,
AC-8b/AC-9b). One CHANGELOG bullet that credits the wrong skill with a safety phrase is corrected
(AC-10). One retro carry-forward that a later investigation falsified is superseded by an appended
correction record (AC-11). **Nothing is moved, nothing is deleted, no ADR status is flipped.**

---

## §B. Sequencing — this is load-bearing, not housekeeping

> *ISO 15288 — Technical Process: Implementation.*

Four commits, in this order. The ordering is not stylistic: **two of these steps are RED against
the tree that precedes them**, and landing them out of order red-lines CI on arrival.

| # | Commit | Contents | Why here |
|---|---|---|---|
| 1 | `fix(release-surface): evidence_tags fails loudly instead of aborting silently (AC-1)` | `scripts/verify-release-surface.sh` | Independent of everything else. Touches `scripts/` — this alone is what makes the cycle Tier A. |
| 2 | `fix(citations): de-pin the 5 CONTRIBUTING.md:129 citations + CI anchor guard (AC-2, AC-3)` | `scripts/canonicalize-scan.sh` **and** `.github/workflows/quality.yml` **in the same commit** | **MANDATORY co-landing.** AC-3's step is RED against the pre-AC-2 tree — verified, transcript in §G.3.4. Landing AC-3 first, or alone, red-lines CI. |
| 3 | `fix(registry): correct self-apply and prompt-gate descriptions + standing per-row gate (AC-8, AC-9, AC-8b/AC-9b)` | `curated-skills-registry.md` **and** `.github/workflows/quality.yml` | The gate is GREEN on both the pre- and post-edit registry (§G.5.4), so either order works — but co-landing keeps the gate and the rows it guards in one reviewable unit, and it is the *rows* that carry the risk. |
| 4 | `docs(changelog,retro): correct the never-on-its-own attribution + fetch-tags erratum (AC-10, AC-11)` | `CHANGELOG.md`, `docs/retro.md` | Documentation-only. Kept last so AC-11's base-pinned control (§G.8) has a clean, single-row diff against `BASE`. |

`docs/spec.md`, `docs/design-v2.19.11.md` and `docs/architecture.md` land in the Phase-1 commit
(this one), ahead of all four.

---

## §C. AC-1 — `evidence_tags()` fails loudly

> *ISO 15288 — Technical Process: Design Definition.*

### C.1 The defect, restated correctly

`scripts/verify-release-surface.sh:30` is `set -euo pipefail`. `:218` is
`TAGS_EVIDENCE="$(evidence_tags)"`, a top-level assignment. `:129` is
`git ls-remote --tags origin 2>/dev/null | awk '{print $2}'`. When `git ls-remote` fails, `pipefail`
makes the pipeline's status git's, the assignment at `:218` inherits it, and `set -e` aborts the
script **there** — before the `MISSING-TAG` loop at `:297` is ever reached. `grep -c 'trap '` is
**0** in both this script and `release-predicate.sh`, so nothing prints a cause. `2>/dev/null` has
already discarded git's own explanation. The observable is: **exit 128, zero output.**

Reproduced at Phase 1 against a scratch repo whose only remote is unresolvable:

```
$ bash pre.sh ; echo "SCRIPT_EXIT=$?"
SCRIPT_EXIT=128
```

No `::error::`. No `REACHED-AFTER-ASSIGNMENT`. Nothing.

### C.2 The exact code shape @dev is to write

Replace `scripts/verify-release-surface.sh:129` — the single line
`  git ls-remote --tags origin 2>/dev/null | awk '{print $2}'` — with the block below. Everything
above it in `evidence_tags()` (the `EVIDENCE_DIR` early return at `:121-124` and the
`command -v git` guard at `:125-128`) is **byte-unchanged**.

```bash
  # [AC-1, v2.19.11 - ADR-089] The old `2>/dev/null` discarded git own stderr, and under
  # `set -euo pipefail` the failed pipeline aborted the top-level assignment at :218 with
  # no diagnostic at all: bash exit code 128, no `::error::` line, and git own
  # "Could not resolve host" already thrown away. Mirrors evidence_body() S-A3 pattern
  # (:135-149): capture stderr in a mktemp file, read rc explicitly, surface the real
  # cause, and fail CLOSED with exit 2 (contract/tool error).
  #
  # LOAD-BEARING (ADR-089): `rc=$?` is reachable here ONLY because bash `inherit_errexit`
  # is OFF (the default; scripts/ and .github/ contain no `shopt` at all). This function
  # runs inside the `$( )` at :218, which does not inherit `set -e` while that option is
  # off; enabling it makes the assignment below abort the subshell before `rc=$?` runs,
  # silently restoring the exact opaque-128 defect this closes. DO NOT add
  # `shopt -s inherit_errexit` to this script without re-bracketing every `rc=$?` idiom
  # here and in evidence_body().
  #
  # NOT `2>&1` into the captured variable: git can exit 0 while writing to stderr
  # ("error: refs/tags/vX.Y.Z does not point to a valid object!"), and :286 tests the
  # captured evidence with `grep -qF "refs/tags/v${tok}"` against the whole line - a
  # merged stream turns a broken-ref diagnostic into a tag-exists GREEN. mktemp keeps the
  # two streams apart (S-A6: mktemp, never a fixed path).
  local ls_remote_stderr out rc
  ls_remote_stderr="$(mktemp)"
  out="$(git ls-remote --tags origin 2>"$ls_remote_stderr")"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "::error::release-surface: 'git ls-remote --tags origin' failed (exit ${rc}) —" >&2
    echo "  the origin tag set could not be read, so every MISSING-TAG finding below would" >&2
    echo "  be an artifact of this failure rather than a fact about the repository." >&2
    echo "  Failing closed. Raw git error:" >&2
    sed 's/^/    /' "$ls_remote_stderr" >&2
    rm -f "$ls_remote_stderr"
    exit 2
  fi
  rm -f "$ls_remote_stderr"
  printf '%s\n' "$out" | awk '{print $2}'
```

**Binding constraints on this edit, all adjudicated before Phase 1 and re-verified in it:**

1. **NO caller-side bracket at `:218`.** Do not add `set +e` / `RC=$?` / `set -e` around
   `TAGS_EVIDENCE="$(evidence_tags)"`. The `exit 2` inside the function terminates the `$( )`
   subshell, and `set -e` at the top level propagates it as exit **2**. Adding a bracket without
   rc=2 propagation yields exit 0 and a universal `MISSING-TAG` — it *manufactures* the defect the
   Phase-0 amendment falsified.
2. **`local ls_remote_stderr out rc` on its own line; assign on separate lines.**
   `local X="$(cmd)"` is FORBIDDEN — `local`'s own status masks the command's, and the demonstrated
   result is script exit **0** with an empty tag set.
3. **Never `2>/dev/null`.** And, per §J.1, never `2>&1` into the captured variable either.
4. Variable name is `ls_remote_stderr`, not `git_stderr` — `evidence_body()` already owns
   `gh_stderr`; the parallel naming makes the mirrored pattern legible.

### C.3 Negative controls — three legs, both directions, all RUN

**Leg 1 — the failure path, pre and post.** Scratch repo, `origin` = `https://example.invalid/nope.git`.
The post-fix leg was run against the **real patched script's actual function text**, extracted
from the patched file (lines 119-164) into a harness with `EVIDENCE_DIR=""`, not against a
paraphrase.

```
# PRE-FIX (the current line 129)
$ bash pre.sh ; echo "SCRIPT_EXIT=$?"
SCRIPT_EXIT=128

# POST-FIX (the block above, verbatim, extracted from the patched script)
$ bash harness.sh ; echo "SCRIPT_EXIT=$?"
::error::release-surface: 'git ls-remote --tags origin' failed (exit 128) —
  the origin tag set could not be read, so every MISSING-TAG finding below would
  be an artifact of this failure rather than a fact about the repository.
  Failing closed. Raw git error:
    fatal: unable to access 'https://example.invalid/nope.git/': Could not resolve host: example.invalid
SCRIPT_EXIT=2
```

`REACHED-AFTER-ASSIGNMENT` is absent in both. Exit is **2**, not 1 and not 128.

**Leg 1b — the `inherit_errexit` dependency, demonstrated rather than asserted.** The same
post-fix harness with one line prepended:

```
$ bash post-inherit.sh ; echo "SCRIPT_EXIT=$?"      # shopt -s inherit_errexit
SCRIPT_EXIT=128
```

The fix silently reverts to the pre-fix behaviour: no `::error::`, exit 128. This is why ADR-089
exists, and why the comment block above says what it says.

**Leg 2 — credential-leak assertion (an inspection, not a transform).** Both directions:

```
# GREEN direction — the real emitted block
$ grep -qE '://[^/[:space:]]*@' real-err.txt ; echo $?
1                                   # no userinfo present -> assertion GREEN

# RED direction — a fixture whose stderr is 'https://u:p@example.invalid/x.git/'
$ bash cred-red.sh ; echo "EXIT=$?"
CRED-LEAK ASSERT: RED (credential-shaped userinfo present) -- correct for this fixture
EXIT=1
```

**Do NOT add a `sed` redactor.** The assertion inspects; it must not mangle the diagnostic AC-1
exists to surface.

**Added at v2.19.13 Phase 4 (AC-CF-B item 2, purely additive — zero deletions).** The GREEN
direction above (no userinfo in the real emitted block) reflects **git's own URL-handling
behavior**, not code-level redaction performed by `verify-release-surface.sh`. Checked rather than
assumed: `scripts/verify-release-surface.sh` contains no `sed`/`awk`/regex step that strips or masks
credential-shaped text anywhere in its `evidence_tags()` or `evidence_body()` paths — the only `sed`
usage in the script is `sed 's/^/    /'`, an indentation prefix, unrelated to redaction. The fixture
`git ls-remote --tags` is run against in Leg 1/1b's harness (`https://example.invalid/nope.git`)
carries no embedded userinfo, so git's own diagnostic never contains any to begin with; the GREEN
result is an absence of input, not a removal performed on the way out. Do not read the GREEN leg as
evidence that this script sanitizes credentials — it does not, and the RED leg (`cred-red.sh`,
above) exists precisely because a fixture that DOES carry userinfo is not defended against by
anything in this script.

**Leg 3 — `EVIDENCE_DIR` mode byte-unchanged.** The real script and the real patched script, same
evidence directory, same floor, output hashed:

```
$ bash scripts/verify-release-surface.sh --evidence-dir /tmp/ac1lab/ev --floor 2.19.9 >baseline 2>&1 ; echo $?
1
$ shasum -a 256 baseline
4dce8d57ede0ba6aecd070db1bde2450f9dca077c6ba8c6c4bf671aa2ac12948

$ bash <patched>/verify-release-surface.sh --evidence-dir /tmp/ac1lab/ev --floor 2.19.9 >post 2>&1 ; echo $?
1
$ shasum -a 256 post
4dce8d57ede0ba6aecd070db1bde2450f9dca077c6ba8c6c4bf671aa2ac12948
```

**Byte-identical.** (Note for @qa: the patched copy must be run with `release-predicate.sh` and
`semver-compare.sh` beside it — this script resolves siblings via `SCRIPT_DIR`. Two false RED runs
during Phase 1 were caused by that, not by the patch.)

**Leg 4 (added at Phase 1, not in the spec) — happy-path non-regression against the real origin.**
Old form and new form, both against this repository's actual remote:

```
$ old form  -> 91 lines
$ new form  -> 91 lines
$ cmp old new
HAPPY-PATH BYTE-IDENTICAL
```

**Leg 5 — ShellCheck.** `shellcheck <patched>/verify-release-surface.sh` → **exit 0**, no findings.
(The repo's `shellcheck` job scans `./scripts`, so this is a real merge gate.)

### C.4 What executing this remedy breaks

| Remedy element | What it could break | Caught by |
|---|---|---|
| Adding a caller-side bracket at `:218` | exit 0 + universal `MISSING-TAG` — the defect Phase 0 falsified | Constraint 1 above; Leg 1 asserts exit **2**, which a bracket without rc-propagation cannot produce |
| `local X="$(cmd)"` | script exit 0 with an empty tag set | Constraint 2; Leg 1 |
| `2>&1` into the captured variable | **fail-OPEN**: a git stderr line naming a ref enters the evidence set and `:286`'s `grep -qF` matches it (§J.1) | Constraint 3; demonstrated in §J.1 |
| Restructuring the whole function around one `rc` flow | `EVIDENCE_DIR` early-return behaviour drifts | Leg 3, byte-hash |
| A later `shopt -s inherit_errexit` | silently restores the opaque-128 defect | Leg 1b; ADR-089; the in-file comment |

---

## §D. AC-2 — de-pin the 5 citations

> *ISO 15288 — Technical Process: Design Definition.*

### D.1 The exact edit

In `scripts/canonicalize-scan.sh`, at **`:10`, `:24`, `:40`, `:123`, `:187`**, replace the literal
string `CONTRIBUTING.md:129` with:

```
`CONTRIBUTING.md § Worked-example authoring rules (S1 security carry-forward)`
```

**The backticks are load-bearing, not cosmetic.** They terminate the anchor so AC-3's `` [^`]+ ``
extraction cannot run greedily to end-of-line. Without them AC-3 reports `N_DISTINCT=5` and
red-lines CI on a correctly-executed AC-2 (the 0.D R2 finding).

Mechanically, this is exactly:
`sed -i 's|CONTRIBUTING\.md:129|`CONTRIBUTING.md § Worked-example authoring rules (S1 security carry-forward)`|g' scripts/canonicalize-scan.sh`

`docs/patterns.md` and the 11 other Class-B files are **OUT** — they cite `:129` as a narrative
record of a past incident, and rewriting them would falsify the historical record.

### D.2 Two things this edit could have broken, both checked before prescribing it

1. **Backticks inside the embedded Python.** `:123` sits inside a heredoc. If that heredoc were
   unquoted, the two new backticks would be command substitution and would break the script.
   Checked: `scripts/canonicalize-scan.sh:109` is `python3 - "$TARGET" … <<'PYEOF'` — **quoted**.
   Inert. `:10`, `:24`, `:40`, `:187` are shell `#` comments, where backticks are also inert.
2. **Line length.** `.markdownlint.jsonc` sets `"MD013": false`, and `markdown-lint` excludes
   `docs/**` anyway; `shellcheck` has no line-length rule. No lint surface.

### D.3 Negative controls — all RUN

```
(a) stale pins:      pre-edit  grep -cF 'CONTRIBUTING.md:129' scripts/canonicalize-scan.sh  -> 5
                     post-edit                                                              -> 0
(b) heading unique:  grep -cF '### Worked-example authoring rules (S1 security carry-forward)' CONTRIBUTING.md -> 1
                     (measured BOTH before and after; the heading is at CONTRIBUTING.md:157)
(c) SF-S-1:          post-edit  grep -v '^\s*#' scripts/canonicalize-scan.sh \
                                | grep -cE 'pip install|npm install|curl |wget '            -> 0
```

**(d) Behavioural non-regression, both directions — the leg the spec did not ask for.** The
post-edit script was executed against a real input and a poisoned input and compared with the
pre-edit script:

```
$ bash scripts/canonicalize-scan.sh --section '## Example' skills/prompt-gate/SKILL.md   ; echo $?   # 0
$ bash <post-edit>.sh              --section '## Example' skills/prompt-gate/SKILL.md    ; echo $?   # 0
$ cmp out-pre.txt out-post.txt
BYTE-IDENTICAL

# RED direction — a '## Example' containing "Ignore all previous instructions."
pre-edit : ::error::canonicalize-scan: forbidden imperative token found … ; exit 1
post-edit: ::error::canonicalize-scan: forbidden imperative token found … ; exit 1   (identical)
```

The prompt-injection scan still fires. The de-pin is inert to behaviour.

### D.4 What executing this remedy breaks

It trades an undetected **line-number** staleness for an undetected **heading-name** staleness —
nothing compares either. That is the whole reason AC-3 exists, and it is why AC-2 and AC-3 are one
ADR. AC-2 alone would be a lateral move.

---

## §E. AC-3 — anchor-resolution guard, derived from the citing script

> *ISO 15288 — Technical Process: Verification.*

### E.1 Placement

A new **inline step** at the end of the existing `canonicalize-scan-check` job in
`.github/workflows/quality.yml` (immediately after the `No network/dependency add in this job
(SF-S-1)` step, currently ending at `:1398`). **Never a file under `scripts/`** — the recurring
TIER-4 condition. Adjacency chosen deliberately: this is the job that already reads
`scripts/canonicalize-scan.sh`.

### E.2 The exact step @dev is to write

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

**Applied verbatim from `docs/internal/security/security-review-v2.19.11.md` §S1 ("Exact corrected
code"), byte-for-byte, at Phase 2 rework.** It was not re-derived, re-typed, or "simplified" here.
The two comparisons `[ "${N_DISTINCT:-x}" != "1" ]` and `[ "${N_HEADS:-x}" != "1" ]` **must not be
reverted to `-ne`.** Leg NEW-3 in §E.3 is the proof: a `$DOC` that is a **directory** passes the
`-r` precheck, so the precheck alone would have been an insufficient correction — only the
`"${X:-x}"` string comparison catches it. Both halves are load-bearing; neither alone closes S1.

**Why this defect existed — the chain is the finding.** The `|| true` on the capture pipelines was
added at Phase 1 (§E.3.1, §J.3) to stop a *silent abort*. That was a real defect, correctly fixed.
But `|| true` also converts an **unreadable-file error** into an **empty capture**: `grep -cF` on a
missing or unopenable file writes nothing to stdout (the `0` it prints on a zero-match is only
printed once the file opens) and exits **2**; `|| true` swallows that; `[ "" -ne 1 ]` is then not
*false* but an **error** — bash prints `[: : integer expected` and the test returns **2**; an `if`
treats any non-zero condition as FALSE; `set -e` is **exempt inside an `if` condition**; and control
falls through to the `PASSED` line and `exit 0`. Fail-**open**, on the single guard standing between
a rotted citation and a green merge. `CONTRIBUTING.md` is `export-ignore`d, so this is not a corner
case: any consumer running the guard against a `git archive` tree gets an unconditional green.

**This is the third defect in AC-3's remedy chain, and each fix introduced the next.**

1. The 0.D R2 snippet **hardcoded** the anchor — a citation with a dropped qualifier would pass
   every check. Remedy: derive the anchor from the citing file (ADR-090 §Decision (2)).
2. Derivation under `set -euo pipefail` **aborted the step silently** against the pre-edit tree —
   exit 1, no `::error::` at all (§E.3.1). Remedy: `|| true` on the pipelines (§Decision (4)).
3. `|| true` opened the **empty-capture fail-open** S1 documents. Remedy: the `-r` precheck **plus**
   the string comparison above.

Every one of the three was found by **running** the guard against a tree it had not yet been run
against — the hardcoded form by typo-ing a citation, the silent abort by using the *pre*-edit tree,
the fail-open by removing `$DOC` entirely. **None of the three was found by reading the code**, and
each reading-based review declared the prior fix complete. That is the transferable lesson, and it
is why ADR-090 §Decision (4) is written as a standing rule about assignment pipelines rather than as
a note about one line.

**The correction also closes S2 — and S2 is why S1 was invisible in this document's own §E.3
evidence.** The superseded success line printed `distinct=1 … headings=1` as **hardcoded literals**;
the corrected line prints the **measured** `distinct=${N_DISTINCT} cites=${N_CITES}
headings=${N_HEADS}`. That is not cosmetic. §E.3's original leg (0) transcript read
`anchor guard PASSED — … distinct=1 cites=5 headings=1`, which is **byte-identical to the output of
the fail-open path**. A materialised post-edit tree built with `git archive` — the natural way to
build one — contains no `CONTRIBUTING.md` at all, so that leg (0) GREEN **cannot be distinguished
after the fact from the S1 fail-open.** The original leg (0) is therefore **retracted as evidence,
not merely superseded**: a success message that cannot tell success from a specific failure is
evidence of neither. Under the corrected line the same run would have printed `headings=` with an
empty value, and the defect would have been visible the first time it ever ran.

**The anchor is never hardcoded in the workflow.** It is derived from the citing script, which is
the only form that can catch a citation the author typo'd — the hardcoded form let AC-2 (0 stale
pins) and the heading-uniqueness check both stay GREEN while one citation resolved to nothing.

**`${1:-…}` / `${2:-…}` under `set -u`:** safe by construction, and the zero-argument form (what
GitHub Actions actually runs) was executed, not assumed — see E.3 leg (0).

### E.3 Negative controls — nine legs, every one RUN against the CORRECTED step

The guard was extracted **from the parsed YAML** (`yaml.safe_load` → `steps[N]['run']` → file →
`bash`), so what was tested is the shipped text, not a transcription of it.

**Provenance of this transcript.** The six original legs plus the three new ones were re-run against
**fresh fixtures**, independently of both @architect's Phase-1 run and @security's Phase-2 run, and
the results below are that independent re-run. They are cited, not re-derived here. The three `NEW-`
legs are the S1 regression legs; each returned **EXIT=0 (fail-open)** against the superseded §E.2
step and returns **EXIT=1** against the corrected one.

```
(0)  clean, zero-arg, post-AC-2 tree, CONTRIBUTING.md present:
     anchor guard PASSED — distinct=1 cites=5 headings=1                         EXIT=0
(i)   heading renamed        -> resolves to 0 headings, expected 1                EXIT=1
(ii)  heading duplicated     -> resolves to 2 headings, expected 1                EXIT=1
(iii) one citation typo'd    -> expected 1 distinct anchor, found 2               EXIT=1
(iv)  one citation deleted   -> expected 5 citations, found 4                     EXIT=1
(v)   PRE-AC-2 tree          -> expected 1 distinct anchor, found 0               EXIT=1
NEW-1 DOC missing            -> '<doc>' is missing or unreadable                  EXIT=1  (was 0)
NEW-2 DOC chmod 000          -> '<doc>' is missing or unreadable                  EXIT=1  (was 0)
NEW-3 DOC is a directory     -> resolves to <non-numeric> headings, expected 1    EXIT=1  (was 0)
```

**Leg (0)'s `distinct=1 … headings=1` is now a measurement, not a literal** — that is the whole of
the S2 fix, and it is what makes leg (0) admissible evidence at all. See the retraction note in
§E.2: the *superseded* step's leg (0) transcript was byte-identical to the fail-open output and
proved nothing in either direction.

**NEW-3 is the leg that decides the shape of the fix.** A directory satisfies `-r`, so it reaches
the comparisons with an empty capture. If the correction had been the `-r` precheck alone, NEW-3
would still be `EXIT=0`. The `"${X:-x}"` string comparison is therefore not defensive
belt-and-braces — it is the half that closes the route the precheck cannot see. Do not simplify it
away on the grounds that "the precheck already handles it."

**ShellCheck: exit 0 on the corrected step.** `bash -n` on the YAML-parsed run body: clean; the
block round-trips through `yaml.safe_load` as exactly one step with a 31-line `run` body.

### E.3.1 The defect leg (v) found — inside the R2-corrected snippet

The 0.D R2 snippet had `|| true` on `N_DISTINCT`, `N_CITES` and `N_HEADS`, **but not on the
`ANCHOR` assignment itself**. Against any tree where the backticked citation form is absent
(pre-edit, or total drift), `grep -oE` exits 1, `pipefail` propagates it, and under `set -euo
pipefail` the assignment **aborts the step with exit 1 and zero output**:

```
$ bash guard.sh <pre-edit script> CONTRIBUTING.md ; echo "EXIT=$?"
EXIT=1                       # <- no ::error:: line at all
```

That is **the AC-1 defect class, reproduced inside AC-3's own guard**, and it is the same
`grep -cF`-exits-1-on-zero-matches shape @security already fixed once in this very workflow
(`quality.yml`'s `PARSER_COPIES` B4 note). It was found by running the guard in the direction that
should make it RED, against the *pre*-edit tree — which the R2 verification, run only against a
simulated *post*-edit tree, could not see.

**Fix, folded into the step above:** `… | sort -u || true)`. Post-fix, leg (v) emits the named
diagnostic. Both directions re-run; all six legs pass.

### E.4 What executing this remedy breaks

| Remedy element | What it breaks | Caught by |
|---|---|---|
| Landing AC-3 before or without AC-2 | CI red on arrival, undiagnosably before the `\|\| true` fix | leg (v); §B commit 2 makes co-landing mandatory |
| Un-delimited citation form | `N_DISTINCT=5` on a correct AC-2 | AC-2's backticks; leg (0) |
| Hardcoding the anchor in the workflow | a typo'd citation passes every other check | leg (iii) |
| Pinning `EXPECTED_CITES` | a future cycle that legitimately adds a 6th citation red-lines | **accepted and intended** — a 6th citation *is* a change to the citation surface. Bump `EXPECTED_CITES` in the same edit. Recorded in ADR-090 §Maturation Path. |

---

### E.5 S3 — the convention is repo-wide, the guard is one file wide. DECISION: defer, with an ID.

@security S3 (WARNING, non-blocking) found a citation of the same `CONTRIBUTING.md` heading at
`skills/self-apply/SKILL.md:45`, in a variant form that resolves to **zero** headings, in a file that
ships into every user workspace — while AC-3's guard reads `scripts/canonicalize-scan.sh` only.

**Re-verified at Phase 2 rework, and the finding is larger than S3 states.** The non-conforming form
appears in **nine** files, and **two** of them ship:

```
$ grep -rlF 'CONTRIBUTING.md § Worked-example authoring rules, rule 2' .
skills/self-apply/SKILL.md    PROMOTE.md    CHANGELOG.md
tests/fixtures/canonicalization/f2-1-nfkc-fullwidth.md   (+ f2-2, f2-3)
docs/retro.md   docs/internal/security/security-audit-v2.19.10.md
docs/internal/security/security-review-v2.19.11.md

$ git archive HEAD | tar -tf - | grep -E '^(PROMOTE\.md|skills/self-apply/SKILL\.md|CONTRIBUTING\.md)$'
PROMOTE.md
skills/self-apply/SKILL.md            # CONTRIBUTING.md absent — export-ignore'd

$ grep -cF '### Worked-example authoring rules, rule 2' CONTRIBUTING.md               -> 0
$ grep -cF '### Worked-example authoring rules (S1 security carry-forward)' CONTRIBUTING.md -> 1
```

`PROMOTE.md:34` is a **second shipping Class-A site S3 did not name.** Under ADR-088 §Decision (3)'s
differential-execution rule the other seven sites are **Class B** — fixture headers and historical
records — and are **frozen**.

#### Decision: **(b) — defer to v2.19.12 as `CF-v2.19.11-A`.**

`CF-v2.19.11-A` — *normalize the two shipping Class-A `§`-form citations
(`skills/self-apply/SKILL.md:45`, `PROMOTE.md:34`) to the conforming anchor, and widen AC-3's guard
from a single `SCRIPT`/`DOC` pair to a derived multi-file inventory.*

**Reason, in the order the reasons actually bind:**

1. **Option (a) as scoped would have shipped the same partial coverage it exists to fix.** S3's
   remedy names one file. Repairing only that one leaves `PROMOTE.md:34` broken and shipping, and
   the ADR would still be claiming more than the guard does — the exact defect being corrected.
2. **The real repair is a design change, not a widening.** AC-3's guard is one `SCRIPT`/`DOC` pair
   with a pinned `EXPECTED_CITES=5`. Covering three citing files with two different anchor strings
   requires replacing the pair and the pin with a **derived inventory** — that is ADR-090
   §Maturation Path **option (a)**, an explicitly deferred future-state, not a patch. Prescribing it
   at Phase 2 rework would mean shipping a new guard shape with no negative controls run against it,
   in the same document where §E.2 just recorded three consecutive defects all caused by exactly
   that.
3. **VERIFIED cost — a third gated row.** The brief's claim was checked rather than relied on:
   ```
   $ shasum -a 256 skills/self-apply/SKILL.md
     0c77ab20779c79288eb35f3e1059955b566b3460456034b85dc87959a955e9f4
   $ awk -F'|' '$0 ~ /^\| self-apply \|/ {gsub(/ /,"",$8); print $8}' curated-skills-registry.md
     0c77ab20779c79288eb35f3e1059955b566b3460456034b85dc87959a955e9f4
   $ grep -n 'registry-sha256-check' .github/workflows/quality.yml   -> 556 (job), 755-762 (assert)
   ```
   The registry cell **is** the file's hash and CI enforces the match, so editing
   `skills/self-apply/SKILL.md` **forces a `curated-skills-registry.md` field-8 bump** — a third
   gated row in a cycle whose highest-risk item is already *"we are editing gated rows"*, landing
   after a BLOCKER, with no fresh @security pass over the new gated-row edit. **Claim confirmed.**
4. **Deferral costs nothing that is not already lost.** Both citations are broken **today** and have
   been since v2.19.10. Deferring changes neither. The cycle still ships five anchored citations and
   the repo's first CI check that a citation resolves — strictly better than the status quo in every
   direction.

**What deferral does NOT license.** ADR-090 may not go on describing this as a remaining *line-pin*
awaiting migration. It is a **non-conforming variant of ADR-090's own form, already resolving to
zero, in two shipping files, at the moment of minting.** That correction is **not** deferred: it is
appended to `docs/architecture.md` as *"Amendment record — ADR-090 §Maturation Path and
§Consequences"* in this same rework, per the append-only house convention. The gap is recorded in
the ADR now; only the repair moves to v2.19.12.

**Handoff to @qa (Phase 5):** verify the amendment record exists and that ADR-090's coverage claim
is not asserted anywhere beyond one file-pair. **Handoff to v2.19.12:** `CF-v2.19.11-A`, above.

### E.6 Erratum — v2.19.13 superseding note on the `§Decision (3)` citation above (AC-CF-B item 3)

**This file has shipped (v2.19.11) and is closed** — per the append-only discipline `docs/
architecture.md`'s B0 amendment states explicitly (§1's live/closed boundary), a closed design
document is corrected only by an appended record, never in place. This note is that appended
record; §E.5's sentence above, *"Under ADR-088 §Decision (3)'s differential-execution rule the
other seven sites are Class B ... and are frozen,"* is left **byte-unchanged**.

**The correction:** `§Decision (3)` in that sentence denotes ADR-088's **body** Decision (2) — the
Class A/B reference-freeze ruling — not the archive-leak gate that is ADR-088's body Decision (3).
This is not a typo unique to this file: ADR-088's own **index row** (`docs/architecture.md`, the
ADR-088 summary line) numbers the reference-class ruling `(3)`, and this sentence is a faithful
reading of that index row. The two numbering schemes diverge; ADR-088's amendment record appended
at v2.19.13 Phase 4 (`docs/architecture.md`, *"Amendment record — ADR-088 §Decision (2)/(3): ...
"*) rules the **body** numbering authoritative and records the divergence in full — see that
amendment for the complete ruling, the root-cause table, and the full census (6 mis-pointer loci
total; this file's §E.5 sentence is one of the 3 in scope, corrected this same way).

**Mechanism, stated so a later auditor does not "consolidate" this with H.1/H.2 above:** this is an
**appended superseding note**, never a direct edit — unlike H.1 (a false transcript with no
date-indexed truth-value to protect) and the Leg-2 addition above (purely additive, zero deletions),
this locus would have overwritten a reading that was **defensible when written**, against ADR-088's
own index row. `docs/architecture.md`'s B0 amendment §3 rules on exactly this conflict (its own
§MECHANISM RULING, four grounds) and this note applies that ruling locally, so a reader standing at
§E.5's sentence finds the correction without having to already know to look in `docs/
architecture.md`.

---

## §F. AC-8 / AC-9 — the two registry description rewrites

> *ISO 15288 — Technical Process: Design Definition.*

### F.1 AC-8 — `self-apply`, `curated-skills-registry.md:31`

**What is wrong today.** The description says *"requires **you** to propose a change, check it, and
be able to reverse it **before it takes effect**."* Two errors: the **actor is inverted** (the skill
proposes; the user confirms), and the **rollback is mis-timed** (reversal is available *after* the
change takes effect, not before). It also enumerates only 3 of the 5 real deny-list members
(`skills/self-apply/SKILL.md:52` names five).

**The replacement row, verbatim** (field 2, fields 4-8 and the trailing `|` are byte-unchanged;
only field 3 is rewritten):

```
| self-apply | One of three required safety skills. It records every change you approve, in order, using a consistent format so entries stay easy to track. It proposes each change and shows you exactly what would happen; nothing is written until you say yes, and after a change has been made you can still undo it from the copy saved beforehand. The change log itself, `context/memory-of-use.md`, sits on a fixed, protected list that this approve-and-apply flow always skips, and so do the saved-copies folder `context/.apply-backups/`, the upgrade-history folder `context/.kit-migrations/`, the install record `cowork.install.json`, and every file whose name starts with `self-`, including this skill's own file. Nothing you approve here can rewrite any of them. That list guards this flow, not the whole kit: when a required safety skill is missing from your workspace, the updater still installs it, as its own clearly labelled step, from bytes checked against the published checksum for that skill. | builtin | 2026-07-22 | 1 | mandatory-infrastructure | 0c77ab20779c79288eb35f3e1059955b566b3460456034b85dc87959a955e9f4 |
```

Checks against the AC's binding constraints:

- **Zero literal `|` in the description.** Confirmed by the field-8 control below.
- **Leading `| self-apply |` shape preserved**, field-8 position preserved, `NF` = **9**.
- **Token `` `self-` `` preserved** — present, backticked, in *"every file whose name starts with
  `self-`"*.
- **Token `context/.kit-migrations/` preserved** — present.
- **Enumeration completed, not reduced** (@security S7): all **five** deny-list members are now
  named — the ledger, `context/.apply-backups/`, `context/.kit-migrations/`,
  `cowork.install.json`, and the `self-` prefix set. The prior text named three. This is strictly
  additive; ADR-085's "may never weaken a stated guarantee" is satisfied in the safe direction.
- **Ambiguity resolved, not narrowed.** The old *"This file can never be changed or moved"* could
  read as the ledger or as the skill's own file. The new text names **both** explicitly, so no
  reading is dropped.
- **Actor and timing, the semantic half:** *"It proposes each change and shows you exactly what
  would happen; nothing is written until you say yes"* (skill proposes → user confirms → **then**
  it takes effect) and *"after a change has been made you can still undo it from the copy saved
  beforehand"* (reversal **after**).
- **Accuracy of the deny-list claim (@security S4, amended at Phase 2 rework).** The row no longer
  says the protected set *"can never be changed or moved by this or any other skill"*. See §F.1.1.


#### F.1.1 S4 — the deny-list's reach, corrected (Phase 2 rework)

**The finding.** @security S4: the pre-rework replacement text asserted that the deny-listed set —
including *"every file whose name starts with `self-`"* — *"can never be changed or moved **by this
or any other skill**."* That is **false as written**, and it is false in the dangerous direction: it
promises protection a real channel does not honour.

**Verified at source, not inherited from the review.**

- `skills/self-apply/SKILL.md:50` — the deny-list, and it governs *"the write-channel allow-list"*
  of the apply flow.
- `skills/self-apply/SKILL.md:59` (MF-1c, LOAD-BEARING) — *"This `self-*` deny governs the runtime
  memory-of-use APPLY channel described on this page ONLY. It does **not** govern … the trusted
  installer/pull-backfill ceremony `pull-updates` uses to install a missing `self-*` safety skill
  into a gateless workspace (AC-PULL-7, ADR-073) … a different channel entirely, never reached by
  this deny-list's evaluation in the first place."*
- `skills/pull-updates/SKILL.md:90` — that channel, concretely: *"this workspace is missing
  `self-upgrade` … `pull-updates` backfills it as its own labeled step: bytes copied from
  `skills/self-upgrade/SKILL.md`, byte-verified against the registry's `sha256` for that slug,
  installed."*

So a `self-`-prefixed file **is** written by a skill, through a channel the deny-list deliberately
does not cover — because you cannot gate installing the gate on the gate you are installing.

**This is inherited, not introduced.** The *current* registry row already claims *"This file can
never be changed or moved by this or any other skill."* The pre-rework rewrite carried the claim
forward and **sharpened** it (`including this skill's own file`), which is why it is corrected here
rather than deferred: AC-8's whole purpose is that this row describes the skill accurately, and a
rewrite that re-asserts a falsehood more precisely fails its own AC.

**The correction, stated as a boundary rather than a promise.** The amended text scopes the
guarantee to the flow the deny-list actually governs (*"a fixed, protected list that this
approve-and-apply flow always skips … Nothing you approve here can rewrite any of them"*), and then
names the exception in plain language instead of hiding it (*"That list guards this flow, not the
whole kit: when a required safety skill is missing from your workspace, the updater still installs
it, as its own clearly labelled step, from bytes checked against the published checksum for that
skill"*). Both halves of MF-1c survive the translation: the deny-list is absolute **within its
channel**, and the installer is a **separate, byte-verified, labelled** channel.

**ADR-085 direction check.** The amendment *narrows* a stated guarantee, which is the direction
ADR-085 scrutinises. It is admissible because the narrowed statement is the **true** one and the
wider statement was never honoured by the code — ADR-085 protects guarantees the system actually
provides, not claims it does not. The user-visible protection is unchanged; only the description
stops over-claiming. Nothing in the deny-list itself is edited by this cycle.

**All five deny-list members remain named** (@security S7): the ledger, `context/.apply-backups/`,
`context/.kit-migrations/`, `cowork.install.json`, and the `self-` prefix set. The S7 enumeration
gain is preserved by the amendment, not traded away for the accuracy gain.

**Re-verified after amendment, against a simulated post-edit registry** (row 31 replaced, nothing
else touched):

```
field 8, self-apply  : 0c77ab20779c79288eb35f3e1059955b566b3460456034b85dc87959a955e9f4   (unchanged)
NF, row 31           : 9
literal '|' in field 3 : 0
AC-PL-6 hex-row count : 30   (pin is 30 — unchanged, no pin bump owed)
field 8, prompt-gate : 16b8ef1036d5d7320a7a166b5ea907d365a703b28f5858592bdccc810f1db2c3   NF=9  (untouched)

token `self-` (backticked)      : 1
token context/.kit-migrations/  : 1
token context/memory-of-use.md  : 1
token context/.apply-backups/   : 1
token cowork.install.json       : 1
'by this or any other skill'    : 0   <- the over-claim is gone
```

**RED leg — the checks above can fail.** One literal `|` injected into the amended field 3:

```
field8=mandatory-infrastructure     (field 7's content, shifted right)
NF=10
hexrows=29                          -> AC-PL-6 RED
```

A GREEN that a fault injection cannot turn RED is not evidence; this one turns RED.
### F.2 AC-9 — `prompt-gate`, `curated-skills-registry.md:83`

Replace `a few` with `up to 3`, restoring the bound `skills/prompt-gate/SKILL.md:3` and `:73` both
state. Nothing else in the row changes.

```
| prompt-gate | Asks up to 3 clarifying questions before answering, using your files for context. Improves how well it understands a vague prompt, and skips itself automatically for simple requests or when your message starts with `*`. | builtin | 2026-05-10 | 1 | study,research,writing,project-management,creative,business-admin,personal-assistant | 16b8ef1036d5d7320a7a166b5ea907d365a703b28f5858592bdccc810f1db2c3 |
```

### F.3 Negative controls — all RUN against the **edited** registry

```
field 8, self-apply : 0c77ab20779c79288eb35f3e1059955b566b3460456034b85dc87959a955e9f4   (unchanged)
field 8, prompt-gate: 16b8ef1036d5d7320a7a166b5ea907d365a703b28f5858592bdccc810f1db2c3   (unchanged)
NF, row 31 / row 83 : 9 / 9
AC-PL-6 hex-row count: 30   (pin is 30 — unchanged, so no pin bump is owed)
grep -c 'a few'      : 1 -> 0
grep -c 'up to 3'    : 0 -> 1
grep -c 'context/.kit-migrations/' : present
grep -c 'self-`'     : present
```

Command for the field-8 legs, exactly as the AC states it (and it is proven able to fail — the
pipe-containing variant returns `mandatory-infrastructure`, field 7's content, shifted):

```
awk -F'|' '$0 ~ /^\| self-apply \|/ {gsub(/ /,"",$8); print $8}' curated-skills-registry.md
```

**The sha256 cells do not change and must not be touched.** They hash
`skills/<slug>/SKILL.md`, not the registry row. Neither SKILL.md is edited by this cycle.

### F.4 COMPLIANCE tripwire — re-measured, CLEAR

- (a) `examples/personal-assistant/context/working-rules.md` — **not in this cycle's file list at
  all.** `git diff --numstat -- <that path>` must emit **no row**; @dev asserts this at Phase 4.
- (b) The AC-10 edit's blast radius must exclude `CHANGELOG.md:42-44`. **Measured at Phase 1**
  against the materialised post-edit CHANGELOG: the hunk is `@@ -33,9 +33,9 @@` → lines **33-41**.
  `:42-44` is outside it. **CLEAR.** COMPLIANCE-SENSITIVE stays **NO**; `/legal` is not owed.

### F.5 Semantic-half judge (unchanged, restated so @qa inherits it)

Executor **@qa, Phase 5**; artifact `docs/internal/qa/qa-report-v2.19.11.md §N`. One row per
rewritten string, recording pre- and post- text and an explicit YES/NO on (a) does the new text
place the user's confirmation **before** the change takes effect, (b) does it place reversal
**after**. The structural controls in F.3 do not cover this and must not be presented as if they do.

---

## §G. AC-8b / AC-9b — standing per-row structural gate

> *ISO 15288 — Technical Process: Verification.*

### G.1 Why the zero-`|` constraint alone is the wrong control

It is a prohibition on human typing, discharged by a one-shot check at Phase 4; nothing standing
survives the merge. And the existing `quality.yml:587` self-test does not merely misbehave on a
shifted row — with `REAL_HASH="mandatory-infrastructure"` its `-z` guard does not fire, `sed`
writes the deadbeef into the *shifted* field 8, `FOUND_MISMATCH=1`, and the step prints
**"Fault-injection test PASSED"**. An unearned green, inside the instrument built to prevent
unearned greens.

### G.2 Placement and shape — one step, one copy

A new **inline step** inside the existing `registry-sha256-check` job in
`.github/workflows/quality.yml`, immediately after the `AC-PL-6 — registry row-structure integrity`
step (currently ending at `:721`) and before the `Verify curated-skills-registry.md sha256 …` step.
**Never under `scripts/`** — TIER-4.

**Design decision, and it is the important one: the fault-injection self-test and the real
assertion live in ONE step, sharing ONE `check_row()` definition.** The existing AC-PL-6
arrangement splits them across two steps; because GitHub Actions steps do not share shell state,
that split forced the parser to be written out twice, which is exactly defect **A4** from
v2.19.10 and is why `quality.yml:703-715` now carries a permanent `PARSER_COPIES -ne 2`
self-integrity pin. **One step, one copy owes no such pin** — and, strictly stronger, the
self-test exercises the *same* code path the real assertion runs, which AC-PL-6's split
structurally cannot.

**Assertion first, self-test second** — also deliberate, and also found by running it. With the
self-test first (the house order), a registry that is *already* damaged produces
`AC-8b SELF-TEST FAILED - a benign whitespace reflow … was reported as damage (false positive)`,
which blames the check for the registry's fault. Verified:

```
$ bash gate.sh <pipe-damaged registry>
::error::AC-8b SELF-TEST FAILED - a benign whitespace reflow of the row pipes was reported as damage (false positive).
EXIT=1                                   # <- RED, but the wrong diagnosis
```

Reordered, the same input reports the true cause. The logic holds: the self-test exists to make a
**GREEN** trustworthy; a **RED** needs no self-test, because a RED is not an unearned green.

### G.3 The exact step @dev is to write

```yaml
      - name: AC-8b/AC-9b — per-row structural integrity of the gated registry rows (v2.19.11, ADR-090 companion)
        run: |
          set -euo pipefail
          REG="${1:-curated-skills-registry.md}"
          GATED_SLUGS="self-apply prompt-gate"
          check_row() {
            awk -F'|' -v row="$2" 'BEGIN{seen=0;ok=0} {n=$2; gsub(/ /,"",n); if(n==row){seen++; s=$8; gsub(/ /,"",s); if(NF==9 && s ~ /^[0-9a-f]{64}$/) ok++}} END{exit (seen==1 && ok==1)?0:1}' "$1"
          }
          for slug in $GATED_SLUGS; do
            if ! check_row "$REG" "$slug"; then
              echo "::error::AC-8b/AC-9b FAILED - ${slug} does not appear as exactly one row with exactly 9 pipe-delimited fields and a 64-char lowercase-hex value in field 8. A description rewrite most likely introduced a | character, shifting every later field right so field 8 is no longer the sha256 cell. Repair the ROW; do NOT widen NF and do NOT relax the hex shape. If this cycle intentionally changed the registry column count, that is a structural change to a gated row and belongs in its own reviewed cycle."
              exit 1
            fi
            echo "AC-8b/AC-9b: ${slug} OK - exactly 1 row, 9 fields, valid hex in field 8."
          done
          FIX="$(mktemp -d)"
          trap 'rm -rf "$FIX"' EXIT
          sed 's/^| self-apply |/|self-apply|/' "$REG" > "$FIX/reflow.md"
          awk -F'|' 'BEGIN{OFS="|"} $2==" self-apply " {$3=$3 "| "} 1' "$REG" > "$FIX/pipe-sa.md"
          awk -F'|' 'BEGIN{OFS="|"} $2==" prompt-gate " {$3=$3 "| "} 1' "$REG" > "$FIX/pipe-pg.md"
          grep -v '^| self-apply |' "$REG" > "$FIX/deleted.md"
          for f in reflow pipe-sa pipe-pg deleted; do
            if cmp -s "$REG" "$FIX/$f.md"; then
              echo "::error::AC-8b FIXTURE SETUP FAILED - the ${f} fixture was a no-op; its field-2 anchor no longer exists in the registry. Repair the FIXTURE anchor. Do NOT relax the assertions below."
              exit 1
            fi
          done
          fail=0
          if ! check_row "$FIX/reflow.md" self-apply; then echo "::error::AC-8b SELF-TEST FAILED - a benign whitespace reflow of the row pipes was reported as damage (false positive)."; fail=1; fi
          if check_row "$FIX/pipe-sa.md" self-apply; then echo "::error::AC-8b SELF-TEST FAILED - a pipe injected into self-apply description was NOT detected."; fail=1; fi
          if check_row "$FIX/pipe-pg.md" prompt-gate; then echo "::error::AC-9b SELF-TEST FAILED - a pipe injected into prompt-gate description was NOT detected."; fail=1; fi
          if check_row "$FIX/deleted.md" self-apply; then echo "::error::AC-8b SELF-TEST FAILED - a deleted self-apply row was NOT detected; the check is vacuous."; fail=1; fi
          if [ "$fail" -ne 0 ]; then exit 1; fi
          echo "AC-8b/AC-9b self-test PASSED - reflow GREEN, both pipe injections RED, row deletion RED."
          echo "AC-8b/AC-9b PASSED - gated slugs verified: ${GATED_SLUGS}."
```

**The `awk` expression is @security's, unmodified.** It has now been verified through the four
legs @security specified, the fifth the 0.D R2 round added, a sixth added here, and — the
difference from R2 — against **this cycle's actual rewritten rows** rather than a simulation.
It pins **no hash value**: shape only.

**Fixture-anchor independence (ADR-087) is satisfied:** every fixture is anchored on **field 2**
(`| self-apply |`, `" self-apply "`, `" prompt-gate "`), which AC-8 and AC-9 leave byte-unchanged.
No fixture quotes any description content this cycle rewrites. The `cmp -s` validity guard is the
house pattern, carried over from `quality.yml:657-664`.

### G.4 Negative controls — six legs, all RUN, from the YAML-parsed text

Extracted via `yaml.safe_load` → `jobs['registry-sha256-check']['steps'][4]['run']` → file → `bash`.

```
1. clean tree (pre-edit registry, zero-arg, repo root):
   AC-8b/AC-9b: self-apply OK …  / prompt-gate OK …
   AC-8b/AC-9b self-test PASSED - reflow GREEN, both pipe injections RED, row deletion RED.
   AC-8b/AC-9b PASSED …                                                          EXIT=0

2. this cycle's ACTUAL pipe-free rewrite (materialised post-edit registry):      EXIT=0  GREEN

3. benign whitespace reflow  (sed 's/^| self-apply |/|self-apply|/'):            GREEN   (no false positive)

4. pipe-injected, self-apply:                                                    RED
   ::error::AC-8b/AC-9b FAILED - self-apply does not appear as exactly one row …

5. self-apply row deleted entirely:                                              RED     (not vacuous)
   ::error::AC-8b/AC-9b FAILED - self-apply does not appear as exactly one row …

6. NEW — the check itself broken (END{exit 0}), run on a GOOD registry:
   AC-8b/AC-9b: self-apply OK …          <- the assertion still passes …
   ::error::AC-8b SELF-TEST FAILED - a pipe injected into self-apply description was NOT detected.
   ::error::AC-9b SELF-TEST FAILED - a pipe injected into prompt-gate description was NOT detected.
   ::error::AC-8b SELF-TEST FAILED - a deleted self-apply row was NOT detected; the check is vacuous.
                                                                                 EXIT=1
```

Leg 6 is the one that matters and the one AC-PL-6's split arrangement cannot produce: **an
unearned GREEN is converted into a RED by the step's own self-test, because the self-test runs the
same `check_row()` the assertion ran.**

### G.5 Self-integrity constraint — measured, not assumed

`quality.yml:703-715` asserts the AC-PL-6 row-structure parser's core expression appears **exactly
2** times in `.github/workflows/quality.yml`, with an explicit *"do not relax to 'at least 2'"*.

```
$ grep -cF -f pin-frag.txt .github/workflows/quality.yml                      -> 2   (today)
$ grep -cF -f pin-frag.txt <the AC-8b step text alone>                        -> 0
$ grep -cF -f pin-frag.txt <quality.yml + AC-8b step + AC-3 step, simulated>  -> 2   (unchanged)
```

Neither new step perturbs the pin. `AC_PL_6_EXPECTED_HEX_ROWS` also stays at **30** (§F.3) — no
bump is owed, and none must be made.

### G.6 YAML validity — parsed, not eyeballed

The full simulated `quality.yml` (both new steps spliced at their real insertion points) parses:

```
$ python3 -c "import yaml; d=yaml.safe_load(open('sim2.yml')); …"
YAML OK, jobs= 34
registry-sha256-check steps = 6   (AC-8b lands 4th, before the sha256 verify step)
canonicalize-scan-check steps = 6 (AC-3 lands last, after SF-S-1)
```

### G.7 Known and intended consequence

A future cycle that legitimately adds a registry column will red-line this step. **That is
correct** — a column change *is* a structural change to a gated row — and it must not be patched
by widening `NF`. Recorded in ADR-090 §Maturation Path.

---

## §H. AC-10 — the `never on its own` misattribution

> *ISO 15288 — Technical Process: Design Definition.*

### H.1 The defect

`CHANGELOG.md:35-38` credits `self-archive` with **three** safety phrases, one of which
(`never on its own`) belongs to `pull-updates` per `WIZARD.md:339`. Editing `:37` alone leaves
`:36` saying *"all three of `self-archive`'s safety phrases"* above a list of two — an internal
contradiction. Both must move in one edit.

### H.2 The exact replacement (lines 36-38; line 35 is byte-unchanged)

```
- **The wizard's setup-complete closing message rewritten** — every technical term inline-defined,
  including inside parentheticals, with every listed file and skill still named and both of
  `self-archive`'s safety phrases (`never silently performs`, `reversibly`) preserved verbatim,
  along with `pull-updates`'s own `never on its own`.
```

`WIZARD.md` is **not** touched. `grep -cF 'never on its own' WIZARD.md` stays **1**.

### H.3 The control — CORRECTED at Phase 1, and the correction is the point

The spec's AC-10 control has three counting legs, of which the first is
`printf '%s\n' "$BULLET" | grep -c 'never on its own'  #  1 -> 0`.

**That leg contradicts AC-10's own prose.** AC-10 says the phrase shall be *"attribut[ed] … to
`pull-updates`"* — which requires the phrase to still be **in** the bullet. `grep -c` counts
matching *lines* within the extracted bullet, so any surviving occurrence anywhere in the bullet
keeps the count at 1. A `1 -> 0` requirement can only be satisfied by **deleting** the phrase, and
a fix that deletes it satisfies every leg of the spec's control while destroying the record AC-10
exists to correct. See §J.2.

**Corrected control** — flatten the bullet, then assert on the parenthetical, not on the file:

```bash
set -uo pipefail
CH="${1:-CHANGELOG.md}"; WZ="${2:-WIZARD.md}"; FAIL=0
BULLET="$(awk '/^- \*\*The wizard.s setup-complete closing message rewritten/,/^- \*\*The F4 bundle/' "$CH")"
LINES="$(printf '%s\n' "$BULLET" | grep -c . || true)"
if [ "$LINES" -lt 3 ]; then
  echo "::error::AC-10 control BROKEN - bullet extraction returned ${LINES} lines; the awk range no longer matches."
  exit 1
fi
FLAT="$(printf '%s\n' "$BULLET" | tr '\n' ' ')"
N_ALLTHREE="$(printf '%s' "$FLAT" | grep -cF 'all three' || true)"          # want 0
N_PULL="$(printf '%s' "$FLAT" | grep -cF 'pull-updates' || true)"           # want >=1
N_PHRASE="$(printf '%s' "$FLAT" | grep -cF 'never on its own' || true)"     # want >=1  (PRESERVED, not deleted)
PAREN="$(printf '%s' "$FLAT" | sed -n 's/.*safety phrases (\([^)]*\)).*/\1/p')"
N_WZ="$(grep -cF 'never on its own' "$WZ" || true)"                         # want 1
[ "$N_ALLTHREE" -eq 0 ] || FAIL=1
[ "$N_PULL"     -ge 1 ] || FAIL=1
[ "$N_PHRASE"   -ge 1 ] || FAIL=1
[ -n "$PAREN" ]         || FAIL=1
printf '%s' "$PAREN" | grep -qF 'never silently performs' || FAIL=1
printf '%s' "$PAREN" | grep -qF 'reversibly'              || FAIL=1
printf '%s' "$PAREN" | grep -qF 'never on its own'        && FAIL=1        # the misattribution itself
[ "$N_WZ" -eq 1 ]       || FAIL=1
[ "$FAIL" -eq 0 ] || { echo "AC-10: RED"; exit 1; }
echo "AC-10: GREEN"
```

The vacuity guard is mandatory and is leg 1: an `awk` range that stops matching returns empty and
every `grep -c` below it returns 0 — indistinguishable from a clean pass. Both range endpoints were
re-measured at `b7b8447`: each matches **exactly once**.

### H.4 Negative controls — GREEN plus four RED directions, all RUN

```
GREEN — materialised corrected bullet:
  leg1 bullet_lines=5   leg2 all_three=0   leg3 pull_updates=1   leg4 phrase_preserved=1
  leg5 self_archive_parenthetical=[`never silently performs`, `reversibly`]
  leg6 wizard_copy=1                                                    AC-10: GREEN   EXIT=0

RED-a — the pre-edit tree (the defect itself):
  leg2 all_three=1   leg3 pull_updates=0
  leg5 self_archive_parenthetical=[`never silently performs`, `reversibly`, `never on its own`]
                                                                        AC-10: RED     EXIT=1

RED-b — numeral fixed, `pull-updates` named, phrase LEFT inside self-archive's parenthetical
        (passes every leg of the SPEC's control):
  leg2 all_three=0   leg3 pull_updates=1   leg4 phrase_preserved=1
  leg5 self_archive_parenthetical=[… `never on its own` see also `pull-updates`]
                                                                        AC-10: RED     EXIT=1

RED-c — phrase DELETED outright (what the SPEC's leg `1 -> 0` would have required):
  leg2 all_three=0   leg3 pull_updates=1   leg4 phrase_preserved=0
                                                                        AC-10: RED     EXIT=1

RED-d — awk range endpoint renamed (vacuity):
  LINES=886 (the range runs UNTERMINATED to EOF, not 0 lines — the END anchor no longer
  matches, so awk never closes the range; the `< 3` vacuity guard does NOT fire on 886)
  N_ALLTHREE=2 (an incidental double-match of "all three" elsewhere in CHANGELOG.md, reached
  only because the range now runs unterminated) -> FAIL=1                AC-10: RED   EXIT=1
```

**CORRECTED at v2.19.13 Phase 4 (AC-CF-B item 1) — the transcript above previously read**
*"`::error::AC-10 control BROKEN - bullet extraction returned 0 lines; the awk range no longer
matches.`"*, **claiming the vacuity guard fires on this fixture. It does not.** Re-run against the
real file at this file's own cited base, both the END-anchor-renamed and the START-anchor-renamed
`awk` variants: renaming the END anchor does not make the range match nothing — it makes the range
match **everything from the START anchor to EOF** — because `awk` range matching stays "inside"
the range once opened until its end pattern is found, and an end pattern that never matches never
closes it. Re-measured at `BASE` (`b7b844716aa3146f212907ee381a49256aa1fd13`, the same SHA §I.3
pins) with `/usr/bin/awk` (BSD awk 20200816) and `/usr/bin/wc -l`/`/usr/bin/grep`: the range's own
extent — START line through true EOF, inclusive, blank lines included — is **1242 raw lines**.
That is not the number leg 1 tests, though, and this is a definitional gap, not a transcription
error: the control's `LINES` variable (H.3's script, `:1044`) pipes the range through `grep -c .`
first, which drops the range's 356 blank lines, leaving **`LINES=886`** — the figure the RED-d
block above already states correctly, because it is describing the variable, not the range. `886`
is not `< 3` either, so **leg 1's vacuity guard passes through undetected**, and the RED this
fixture actually produces comes from **leg 2** — the unterminated
range now sweeps in a second, unrelated `"all three"` occurrence later in `CHANGELOG.md`, so
`N_ALLTHREE` reads `2` instead of `0` and the ordinary `[ "$N_ALLTHREE" -eq 0 ] || FAIL=1` assertion
fires. The RENAMED-START variant is the one that actually exercises the vacuity guard as originally
described: with the START anchor renamed, the range never opens, `BULLET` is empty, `LINES=0`, and
leg 1 correctly fires `AC-10 control BROKEN` at `EXIT=1`. Both variants were re-run this session
against the real file; both are RED, but by two different mechanisms, and only one of them is the
vacuity guard.

RED-b and RED-c are the two the spec's control could not distinguish from a correct fix.

### H.5 Where the control lives

**Phase 4/5 only — this is NOT a new CI step.** AC-10 corrects a historical CHANGELOG entry; there
is no ongoing invariant to guard, and adding a third inline step to `quality.yml` for a one-shot
prose fix would be over-engineering. @dev runs it before commit; @qa re-runs it at Phase 5. The
runnable form is above; @qa should re-derive it from this document rather than trusting a summary.

---

## §I. AC-11 — the `fetch-tags` erratum

> *ISO 15288 — Technical Process: Design Definition.*

### I.1 The correction to be recorded

`docs/retro.md` v2.19.10 §Carry-forwards records `release-surface.yml`'s missing `fetch-tags:` as
*"a real but LATENT defect, unconfirmed in CI."* It is **inert**, not latent: `verify-release-surface.sh:193-196`
forces `LOCAL_TAG_ACTIVE=0` whenever `CI` is set, and `evidence_tags()` queries the **remote**, so
no CI code path consults `actions/checkout`'s fetch settings at all. The local reproduction is
*explained* by this, not contradicted — locally `CI` is unset.

### I.2 Placement — append, never rewrite

The originals at `:124` and `:150` are **NOT** rewritten. A new `### Erratum — v2.19.11 …`
subsection is **inserted** at the end of the v2.19.10 entry, after the final carry-forward bullet
at `:152` and before the `---` at `:154`. Insertion produces additions only; zero deletions.

### I.3 The control — base-pinned, three legs

`BASE` is the literal SHA `main` pointed to when this branch was created:
**`b7b844716aa3146f212907ee381a49256aa1fd13`**, recorded here per the AC and independently
re-derivable by @qa at Phase 5. It is **NOT** `git merge-base origin/main HEAD`, which fails at
`actions/checkout`'s default fetch-depth where `origin/main` may not exist — reintroducing AC-1's
own silent-abort class.

```bash
git diff --numstat b7b844716aa3146f212907ee381a49256aa1fd13..HEAD -- docs/retro.md
# MUST emit exactly ONE row; second field (deletions) == 0; first field (additions) > 0.
```

**An empty result is a FAIL, not a pass.** The bare form `git diff docs/retro.md` is **forbidden as
evidence** — it compares working tree against index and emits zero rows once @dev commits, and
"second field == 0" is vacuously true of an empty set.

**Range scoping (@security S9):** scope the endpoint to the **implementation** commits. This
cycle's own Phase-8 retro will later append to `docs/retro.md`; state the endpoint explicitly
rather than relying on the topology (historically `#111` followed `#110`, but that is a habit, not
a guarantee).

### I.4 All three legs RUN

```
(1) vacuity / empty-set direction, at the current pre-edit HEAD:
    $ git diff --numstat b7b8447..HEAD -- docs/retro.md
    (no output)   rows=0        -> the control MUST treat this as FAIL

(2) append-only GREEN shape, on real history (a prior append-only retro commit):
    $ git diff --numstat 7c8ac12 fd00dd2 -- docs/retro.md
    124     0       docs/retro.md          -> exactly one row, deletions 0

(3) proven able to fail, on real history (a commit that DID delete retro lines):
    $ git diff --numstat b3eb849~1 b3eb849 -- docs/retro.md
    21      16      docs/retro.md          -> second field non-zero -> RED
```

Leg 3 uses an actual historical commit rather than a synthesised one, so no scratch commit is
created on this branch.

---

## §J. What this Phase found that the spec got wrong

> *ISO 15288 — Technical Management: Quality Assurance.*

Four findings. Three change a prescribed remedy; one changes a control's direction. Every one was
found by **running** the prescribed thing, in the direction that should make it RED, against a tree
carrying this cycle's own pending edits.

### J.1 AC-1's two mechanism clauses contradict each other, and the literal one is fail-OPEN

AC-1 says both *"mirror `evidence_body()`'s S-A3 pattern at `:135-149`"* and *"Capture stderr with
`2>&1` **into** the captured variable."* These are different designs. `evidence_body()` captures
stderr in a **`mktemp` file** (`:158-160`) precisely so it does not contaminate the captured
stdout, and its comment cites S-A6 (*"Uses `mktemp`, not a fixed path"*).

The literal `2>&1` form is not merely less tidy — **it is a fail-open vector.** `git ls-remote` can
exit **0** while writing to stderr. `verify-release-surface.sh:286` tests the captured evidence
with `grep -qF "refs/tags/v${tok}"` **against the whole line**, not against a field. Demonstrated
with a shim that prints git's own real message shape to stderr and exits 0:

```
shim stderr: error: refs/tags/v9.9.9 does not point to a valid object!
shim stdout: aaaa<TAB>refs/tags/v2.19.9

mktemp form: ORIGIN_HAS_TAG=0 (correct - MISSING-TAG)
2>&1  form:  ORIGIN_HAS_TAG=1 (FALSE GREEN)
```

A broken-ref diagnostic becomes a tag-exists GREEN on a **Tier-A release-surface gate**. A milder
version is visible even without a ref-shaped message:

```
mktemp form  -> refs/tags/v2.19.9 , refs/tags/v2.19.10
2>&1  form   -> redirecting , refs/tags/v2.19.9 , refs/tags/v2.19.10
```

**Resolution:** the *"mirror `evidence_body()`'s S-A3 pattern"* clause wins; the `2>&1` clause is
read as what it was plainly for — **"never `2>/dev/null`, never discard git's stderr"** — which the
prescribed block satisfies in full. This is recorded in ADR-089 §Decision (3) so no future reader
re-derives `2>&1` from the AC text.

### J.2 AC-10's control leg 1 contradicts AC-10's own requirement

`grep -c 'never on its own'  # 1 -> 0` can only be satisfied by deleting the phrase from the
bullet, while the AC requires it be *attributed to `pull-updates`* — i.e. kept. A fix that deletes
it passes all three of the spec's legs (RED-c in §H.4 would have been GREEN under the spec's
control) and destroys the record. **Corrected in §H.3:** the phrase must be **preserved**
(`>=1`) and must be **absent from `self-archive`'s parenthetical** — the assertion is about
attribution, which is where the defect lives, not about a file-level count.

### J.3 AC-3's R2-corrected snippet aborts silently on total drift

Detailed in §E.3.1. The `ANCHOR` assignment lacks `|| true`; against any tree without the
backticked citation form — including **the pre-AC-2 tree, which is what CI sees if AC-3 lands
first** — `grep -oE` exits 1 under `pipefail` and the step dies with exit 1 and **zero output**.
That is the AC-1 defect class inside AC-3's own guard, and the same `grep`-exits-1-on-zero shape
@security already fixed once in this workflow. **Fixed** by `… | sort -u || true)`, re-verified in
both directions. It also establishes the mandatory co-landing of AC-2 and AC-3 (§B, commit 2).

### J.4 The spec's AC-8b/AC-9b step shape inherits AC-PL-6's dual-copy hazard

Not a defect in @security's `awk` — that expression is correct and is used unmodified. The AC as
written says "an inline step", which read literally alongside the house pattern (fault-injection
step + assertion step) reproduces the **two-copy** arrangement whose drift is defect A4 and whose
only mitigation today is a hand-maintained `PARSER_COPIES` pin. §G.2 collapses it to **one step,
one copy**, which owes no pin and yields a strictly stronger self-test (leg 6, §G.4). The
assertion-before-self-test ordering was likewise found by running it, not by reading it.

### J.5 One thing the spec got right that is worth restating

The spec's `PARSER_COPIES == 2` claim and its `NF == 9` claim were both re-measured at `b7b8447`
and both hold (**2**, and **9 / 9**). `AC_PL_6_EXPECTED_HEX_ROWS` is **30** before and after this
cycle's rewrites. No pin bump is owed anywhere in this cycle.

---

## §K. `scope_allow_delta:`

```yaml
scope_allow_delta:
  scope: standard
  add:
    - "scripts/verify-release-surface.sh"
    - "scripts/canonicalize-scan.sh"
    - ".github/workflows/quality.yml"
    - "curated-skills-registry.md"
    - "CHANGELOG.md"
    - "docs/retro.md"
  remove: []
  note: >
    Six files, all pre-existing; no file is created, moved or deleted by Phase 4.
    B1 cross-reference against .claude/agents/dev.md scope_allow.standard could not be
    run from this repository — @architect was instructed not to touch /Users/macbookpro/The-Council
    beyond reading the spec (a parallel session is pinned to `self` there). The orchestrator
    must run scripts/guards/scope-allow-verify.sh against this document before Phase 4.
```

---

## §L. Classification Re-Run (post-OQ, against the FINAL file list)

> *ISO 15288 — Technical Management: Risk Management.*

Final file list: the six files in §K plus this design document, `docs/spec.md` and
`docs/architecture.md` (Phase-1 commit).

**Result: CONFIRMED — SECURITY-SENSITIVE, Tier A.** Two files under `scripts/` and one under
`.github/workflows/` are modified; TIER-1 (*"any file under `scripts/` added or modified"*) fires
on `scripts/verify-release-surface.sh` alone, and the `.github/workflows/` change is independently
Tier-B-or-higher. No downgrade is available and none is sought. The classification is unchanged
from the owner's pre-cycle decision; the re-run is recorded because the record is mandatory even
when the result is unchanged.

**Guard Change Summary owed at Phase 6** must cover, at minimum: (1) the release-surface script
now hard-stops with exit 2 and a printed cause instead of dying silently — a *behaviour* change on
a release gate; (2) two new always-on CI steps that can block a merge; (3) the S5 known-open
problem below.

**S5 carried forward, named and unfixed, for the Phase-3 gate.** `skills/pull-updates/SKILL.md:30`
specifies refusal for a malformed *manifest* but has **no equivalent clause for a malformed
registry row**; on a shifted row the runtime prose-gate may refuse, may miscount, or may skip
verification. **Undefined is not fail-closed.** Pre-existing, not introduced here, and deliberately
not fixed: `pull-updates` is itself a hash-gated row, so editing its `SKILL.md` would force a
**third** gated-row sha256 bump inside a cycle whose highest-risk item is already "we are editing
gated rows." @security recommends shipping with it named. Owner decides at Phase 3.

---

## §M. Anti-pattern scan (11-point, before finalising)

| # | Anti-pattern | Finding |
|---|---|---|
| 1 | God class/module | None. Largest new artifact is a 26-line CI step. |
| 2 | Circular dependencies | None. |
| 3 | Leaky abstraction | **One, accepted and documented:** `evidence_tags()`'s correctness depends on `inherit_errexit` being off — a shell-global leaking into a function's contract. Not removable without a caller-side bracket, which §C.4 shows is worse. Recorded in ADR-089 and in an in-file comment. |
| 4 | Premature optimization | None. |
| 5 | Over-engineering | **Actively avoided twice:** AC-10 gets no CI step (§H.5); AC-8b gets one step rather than two (§G.2). |
| 6 | Tight coupling | AC-3 couples the workflow to `scripts/canonicalize-scan.sh`'s citation text — **intended**; deriving the expectation from the citing file is the whole mechanism. |
| 7 | Missing separation of concerns | None. |
| 8 | N+1 query | N/A. |
| 9 | Destructive migration | **None — and this is the cycle's defining constraint.** No `git mv`, no deletion, no ADR status flip. ADR-088 remains PROPOSED. |
| 10 | SoS interface discontinuity | N/A — single project. |
| 11 | Cross-project tight coupling | None. The Council-side items (`token-logger.sh` pin-blindness; the un-minted "validate instruments against the post-implementation tree" rule) stay in their own `/self-improve` cycle. |

---

## §N. §Maturation Path self-grep — GATE output

Run after authoring ADR-089 and ADR-090, before Phase 1 is marked DONE:

```
$ for h in 'Future-state options:' 'Concrete revisit triggers:' 'Risk knowingly accepted:'; do
    printf '%s → %s\n' "$h" "$(grep -cF "**${h}**" docs/architecture.md)"
  done
Future-state options: → 58
Concrete revisit triggers: → 58
Risk knowingly accepted: → 58
```

Baseline at `b7b8447` was **56 / 56 / 56**; +1 per new ADR × 2 ADRs = **58 / 58 / 58**. Each header
was **copied verbatim** from ADR-035's block (`docs/architecture.md:8853-8856`), not retyped.

**Re-run after the Phase 2 rework: still 58 / 58 / 58.** The rework appends an *amendment record* to
ADR-090 (§E.5, `docs/architecture.md`), not a new ADR, so it mints no fourth §Maturation Path block
and the gate is unperturbed. The amendment's revisit triggers (e) and (f) are appended to ADR-090's
existing list by reference rather than by duplicating the `**Concrete revisit triggers:**` header —
duplicating it would have inflated the count to 59 and falsified this gate.

---

## §O. Handoff — what @dev must not do

1. **Do not implement AC-4, AC-5, AC-6, AC-7a or AC-7b.** They are v2.19.12's.
2. **Do not move any file.** Not one of the 14 reports, not anything else.
3. **Do not flip ADR-088**, do not amend it, do not touch ADR-037's index cell.
4. **Do not add a caller-side bracket at `verify-release-surface.sh:218`.**
5. **Do not add a `sed` redactor** to AC-1's error path.
6. **Do not rewrite the AC-8b `awk` expression.**
7. **Do not bump `AC_PL_6_EXPECTED_HEX_ROWS`** (still 30) or relax `PARSER_COPIES` (still 2).
8. **Do not touch `skills/self-apply/SKILL.md` or `skills/prompt-gate/SKILL.md`** — their sha256
   cells are pinned in the registry and editing either forces a hash bump this cycle does not want.
9. **Do not rewrite `docs/retro.md:124` or `:150`.** Append only.
10. **Do not land AC-3 without AC-2 in the same commit.**
11. **Do not "simplify" §E.2's `[ "${X:-x}" != "1" ]` comparisons back to `-ne`,** and do not drop
    the `-r` precheck loop. Both halves close S1 and **neither alone is sufficient** — leg NEW-3
    (`$DOC` is a directory) passes `-r` and is caught only by the string comparison. §E.2 is
    @security's verbatim text; land it byte-for-byte.
12. **Do not normalize the `§`-form citations in `skills/self-apply/SKILL.md:45` or `PROMOTE.md:34`,
    and do not widen AC-3's `SCRIPT`/`DOC` pair.** Deferred to v2.19.12 as `CF-v2.19.11-A` (§E.5).
    Item 8 above is the mechanical reason the first of those is out of scope.
13. **Do not restore the AC-8 row's *"can never be changed or moved by this or any other skill"*
    phrasing.** It is false — `pull-updates`' trusted-installer backfill (ADR-073 / MF-1c) is
    exactly such a channel. See §F.1.1; the amended row in §F.1 is the one to land.
