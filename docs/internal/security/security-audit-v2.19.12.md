# Security Audit — v2.19.12 "S4 report-egress retrofit"

## Phase: 6
## Date: 2026-08-23T16:05:00Z
## Status: PASS WITH WARNINGS
## Branch: `release/v2.19.12-s4-report-egress` @ `a3347d3`
## Classification: SECURITY-SENSITIVE — Tier A

**CRITICAL: 0 — BLOCKER: 0 — WARNING: 5 — INFO: 3**

This is an audit of the **shipped artifact**, not of the design. Every control below was
**extracted mechanically and executed**; nothing here rests on reading code and concluding.
Every green result is paired with a negative control that was observed to go red.

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | WARNING | 6 | configuration | Repo is PUBLIC; the 14 reports stay fully readable via web UI and `git clone`. The cycle removes them from release **archives** only. Stated nowhere in spec or design. |
| S2 | WARNING | 6 | configuration | Every already-published release still contains all 14 (verified: `v2.19.11` → 14). The change is forward-only. Stated nowhere. |
| S3 | WARNING | 6 | permissions | AC-7 permits additions in `docs/architecture.md`, which **ships publicly**. AC-8's claim "an individual filename trips it" is **FALSE** against the shipped control. Mechanism proven by differential run. |
| S4 | WARNING | 6 | configuration | AC-4 is structurally blind to a `.gitattributes` regression — proven `S4 PASS` while **83** internal files ship. Caught at release time by `release-archive-assert.sh`, but **not at PR time**. |
| S5 | WARNING | 6 | logging | The reduced-guarantee enumeration of "internal-analysis documents shipping at `docs/` root" omits `docs/assumptions.md`, `docs/owner-tasks.md`, `docs/next-steps.md` — same class as the named `risk-register.md`. Under-statement. |
| S6 | INFO | 6 | configuration | AC-4's "correct the step's error text" item only partially delivered; text still unconditionally asserts every match belongs under `docs/internal/{qa,security}/`. |
| S7 | INFO | 6 | dependency | The inline S4 `run:` body receives **zero** static analysis in CI (`quality.yml:132` scopes ShellCheck to `./scripts`). Run externally this audit: clean. |
| S8 | INFO | 6 | schema | No live credential patterns in any of the 83 internal documents. The exposure class is analytical disclosure, not secrets. |

## Environment and instrument declaration

- Inline `grep` in this session is a **ugrep shim** — a zsh function from the Claude Code shell
  snapshot (`snapshot-zsh-1787438881566-4nji8l.sh:46`) that re-execs `claude` with `ARGV0=ugrep`
  and `--ignore-files`, so it silently skips gitignored paths. **Every count in this report was
  taken with `/usr/bin/grep` invoked by absolute path** (BSD grep 2.6.0-FreeBSD, GNU compatible).
- `bash <script>.sh` gets BSD grep, not the shim. Guard bodies were executed under `bash`.
- **AC-4's GNU gap is closed** by its real CI run (`S4 PASS — 0 of 418`, `ubuntu-latest`),
  matching the local BSD count exactly. **AC-7's GNU gap remains open** — it has still never
  executed under GNU grep, by design (it is not a CI step).

---

## Task 1 — Audit of the shipped guard code

### 1a. Mechanical extraction

The job body was extracted from YAML with a parser, not by hand-copying:

```python
d = yaml.safe_load(open('.github/workflows/quality.yml'))
st = [s for s in d['jobs']['archive-leak-check']['steps'] if 'run' in s][0]
# shell: bash    env: LEAK_PATTERN, CANARY_PATHS, EXPECTED_CANARIES=3, MIN_ENTRIES=300
```

`shell: bash` is present as AC-4 requires — the zsh word-split defect that cost this cycle four
defect generations cannot recur.

### 1b. ShellCheck — the analysis CI does not perform

`quality.yml:132` pins `scandir: "./scripts"`. The inline body is therefore unanalysed in CI.
Run here (ShellCheck 0.11.0, `-s bash`):

```
rc=0        (no findings)
```

Reviewed by hand for the classes ShellCheck does not cover:
`set -euo pipefail` is present; both `grep -c` pipelines carry `|| true` (the ADR-089 defect class
— `grep -c` exits 1 on a zero count and would otherwise abort the step); `git archive | tar` runs
under `pipefail`, so an archive failure **fails closed**; `permissions: contents: read` cannot
write. No injection surface — no user-controlled data reaches a shell word.

### 1c. Execution at HEAD

```
$ bash s4.sh        # extracted body, at a3347d3
S4 PASS — 0 of 418 archive entries match ^docs/(qa-report|security-audit|security-review)-.
rc=0
```

418 — reproducing CI exactly.

### 1d. Negative controls — the gate observed going red

| Control | Result |
|---|---|
| Pre-move tree (`BASE` `b43fa52`) | `rc=1`, **14** paths enumerated by name |
| Single-arm pattern typo, canaries intact | `rc=1`, `S4 gate BROKEN — LEAK_PATTERN does not match canary 'docs/security-audit-v9.9.9.md'` then `2 of 3` — **the broken arm names itself** |
| `MIN_ENTRIES=99999` (vacuity) | `rc=1`, `archive listed 418 entries, expected >= 99999` |

**My first canary control was invalid and I discarded it.** A `sed 's|security-audit|security-XXXXt|'`
mutated the pattern *and* the canary together, so they still matched and the run returned
`S4 PASS` — a check that could not fail. Re-run mutating only `LEAK_PATTERN`, it fires correctly.
Recording this because the harness gives no signal that a negative control was a no-op.

### 1e. AC-5 — the ledger script edit

All four legs executed at HEAD: **3** / **0** / `3	3` / `rc 0`
(`PASS — 19 of 19 static anchors resolved`).

The "still owed" stale-annotation repair **was** delivered, and its replacement claim is **true**:
LA-03a previously asserted `docs/retro.md` matches `S-A3` *0 times*; it now says *1 time*. Measured:
`S-A3` 1, `S-A9` 1, `S-A10` 1.

Negative control — LA-03 paths reverted to pre-move in a disposable clone:

```
rc=1
LA-03a FAILED — cannot read 'docs/security-audit-v2.19.6.md' (the anchor names a file that is not there).
LA-03b FAILED — ...   LA-03c FAILED — ...
FAILED — 3 of 19 STATIC ANCHORS did not resolve
```

**The AC-5 ↔ AC-7 conjunction is intact.** AC-7 carves `verify-ledger-annotations.sh` out of both
halves; AC-5's positional greps are what fill that hole, and they are live.

---

## Task 2 — Attacking the shipped AC-7 control

@qa proved both halves of the symmetric difference red. The third direction is the **permitted set
itself**, which @qa correctly flagged as having no machine assertion on its own shape.

> `POPULATION(invariant)` = files that may legitimately gain a line naming one of the 14.
> `POPULATION(proxy)` = whatever strings happen to sit in `PERMIT_ADD` at run time.

### S3 — `docs/architecture.md` is permitted **and** ships publicly

Of the 9 `PERMIT_ADD` entries, **3 are in the public release archive**:

```
docs/architecture.md
docs/design-v2.19.12.md
scripts/verify-ledger-annotations.sh
```

Attack: append to `docs/architecture.md` a section naming **all 14** pre-move paths individually —
the same shape as the `docs/report-index.md` input that made S2 a Phase-2 BLOCKER, relocated into a
permanently-permitted, publicly-shipping file. Result, on a disposable clone at `a3347d3`:

```
ADDED-LINE VIOLATIONS (b): 0
   (ok+) docs/architecture.md                                   5
VERDICT: exit 0 CLEAN
```

Negative control, **same run**, identical payload in a non-permitted public file:

```
   PLUS  docs/faq-extra.md                                      1
VERDICT: exit 1 VIOLATION
```

One run, one payload, two files: the control discriminates purely on filename membership.

**This falsifies a claim the spec makes.** AC-8 states, parenthetically,
*"control-tested: the glob and the prose form pass AC-7; an individual filename trips it."*
It does not trip. Mechanism proven by re-running the identical attack tree with
`docs/architecture.md` removed from `PERMIT_ADD`:

```
   PLUS  docs/architecture.md                                   5
   PLUS  docs/faq-extra.md                                      1
VERDICT: exit 1 VIOLATION
```

So AC-8's control-test **was true** under the Phase-1 `--- /dev/null` form (where
`architecture.md`, not being cycle-created, was unpermitted) and **was falsified by the Phase-2.1
S2 remedy** that replaced it. This is precisely the failure mode this spec's own
§Measurement discipline names: *"Test each remedy against its neighbouring remedies' output, not
only against the defect it was written to fix."* The S2 fix is correct and strictly better than
what it replaced; it silently invalidated a neighbouring AC's stated property.

### Ruling — acceptable, or does it need closing?

**Acceptable to merge; the spec sentence must be corrected; the shape assertion is a cheap follow-up.**

Reasoning, in the order that decides it:

1. **The shipped artifact complies.** The AC-8 note as written uses the family-glob form and names
   no individual file (verified at `docs/architecture.md:14785`). Nothing is exploited today.
2. **The payload this hole permits is filenames, not contents** — and per S1 below, the contents are
   already public anyway. The marginal disclosure is close to zero.
3. **But a false control claim is load-bearing on future cycles.** A later editor who reads
   "an individual filename trips it" will rely on a property that does not exist. That is the
   defect, and it is documentation-class, not code-class.

**Concrete closure (in the cycle's own idiom, ~4 lines):** assert `PERMIT_ADD`'s shape the same way
the S4 gate asserts its canaries — pin the element count and fail `exit 3` (BROKEN, not VIOLATION)
on drift:

```bash
PERMIT_ADD_COUNT="$(printf '%s\n' $PERMIT_ADD | /usr/bin/grep -c . || true)"
if [ "$PERMIT_ADD_COUNT" -ne 9 ]; then
  echo "::error::AC-7 control BROKEN - PERMIT_ADD has ${PERMIT_ADD_COUNT} entries; expected 9."
  exit 3
fi
```

This turns "a human reads the `permitted:` bucket" into a machine assertion, closing the diagnostics-
only gap @qa identified, without re-litigating the S2 decision — which was correct and which I
independently confirm is strictly stronger than the `--- /dev/null` rule it replaced.

---

## Task 3 — The `.gitattributes` exposure: severity and disposition

### The premise required testing, and it is FALSE

The brief states the `docs/internal/ export-ignore` line is *"the sole archive protection"*. It is not.
`scripts/release-archive-assert.sh` carries `docs/internal/` in its `DROP_PATHS` negative-assertion
array (`:87`) and is invoked in **two** places:

| Invocation | When | Effect |
|---|---|---|
| `scripts/publish-release.sh:324,328` | **pre-upload**, against the exact bytes about to be attached | `ERROR: refusing to publish` — **prevention** |
| `.github/workflows/release-assets.yml:105-106` | on `push: tags`, against the **downloaded published asset** | detection of divergence |

### Both halves executed

Disposable clone at `a3347d3`, `docs/internal/ export-ignore` deleted, committed:

```
archive entries: 431 → 507        docs/internal/ files now shipping: 83   (of which 74 are QA/security reports)
```

**AC-4 against that tree — structurally blind, exactly as the brief predicted:**

```
S4 PASS — 0 of 507 archive entries match ^docs/(qa-report|security-audit|security-review)-.
rc=0
```

`LEAK_PATTERN` is anchored `^docs/<stem>-`, so `docs/internal/qa/qa-report-v2.19.6.md` cannot match.
Note the gate reports a **larger** archive as PASS — the vacuity guard is a floor and offers no help here.

**`release-archive-assert.sh` against the same archive — RED:**

```
FAIL: DROP-list path present in leak.zip: docs/internal/
release-archive-assert: FAILED ...
rc=1
```

**Positive control** (so the RED is not an always-red script) — clean `HEAD` archive, same command:

```
release-archive-assert: PASS — clean.zip (prefix 'cowork-starter-kit-2.19.12/', DROP=14, KEEP=17).
rc=0
```

### Ruling: **WARNING. Not a merge blocker. Not its own cycle. A scoped follow-up with a binding AC.**

- **Not a blocker**, because the failure mode is *prevented at the point of publication* by a control
  that is proven to fire, with a hard refusal, before any byte reaches the public.
- **Not its own cycle.** @architect's argument would be right if `.gitattributes` were genuinely
  unguarded; the measurement above shows it is not. What remains is a **detection-timing** gap, not
  an exposure gap.
- **The real, narrow gap:** `release-archive-assert.sh` never runs on a PR. A `.gitattributes`
  regression merges green and surfaces only when someone next cuts a release — late, and blocking at
  the worst moment.
- **Concrete disposition — 3 lines in the job that already exists**, reusing the `$ENTRIES` listing
  the S4 step has already computed, closing exactly the blindness demonstrated above:

```bash
INTERNAL="$(printf '%s\n' "$ENTRIES" | grep -c '^docs/internal/' || true)"
if [ "$INTERNAL" -ne 0 ]; then
  echo "::error::S4 — ${INTERNAL} docs/internal/ entries in the archive; docs/internal/ export-ignore is missing from .gitattributes."
  exit 1
fi
```

Measured on both trees: `0` at `HEAD`, `89` on the removed-line tree. Carry as
`CF-v2.19.12-GATTR` with that AC text, on the next cycle — **not** a Tier-A cycle of its own.

The observation that `.gitattributes` is itself export-ignored (so users cannot inspect it) is
**true and unchanged by this cycle**; it is a transparency limitation, not a control weakness.

---

## Task 5 — Regression check on what the cycle promised

The reduced-guarantee list is **accurate in what it says and under-stated in what it omits** — which
is the failure mode named in the brief.

**Accurate and verified:** the spec's own enumeration command returns exactly the 9 files it names
(`docs/design-v2.19.{6,7,8,9,10,11,12}.md`, `docs/project-audit-v2.6.1.md`, `docs/risk-register.md`),
and `docs/design-v2.19.12.md` does ship carrying its own NOT-RUN list, as disclosed.

**Under-stated, three ways:**

**S1 — the repository is PUBLIC.** `gh repo view --json visibility` → `{"isPrivate":false,"visibility":"PUBLIC"}`.
`.gitattributes` affects `git archive` **only** — its own header says so: *"not `git clone` or working
tree."* All 83 files under `docs/internal/`, including all 14 moved reports and every prior security
audit, are readable right now at github.com and by anyone who clones, and remain so after this merge.
Neither `docs/spec.md` nor `docs/design-v2.19.12.md` states this anywhere. A reader of the cycle's
one-line thesis — *"14 internal QA and security reports ship inside every public release archive.
Move them behind `docs/internal/`"* — would reasonably conclude the reports are no longer public.
They are. **This is the single most important sentence missing from the cycle's artifacts.**

**S2 — the change is forward-only.** Verified: `git archive v2.19.11 | tar -tf - | grep -cE '^docs/(qa-report|security-audit|security-review)-'` → **14**. Every already-published release archive still
contains them. Nothing in the cycle claims otherwise, but nothing states it either.

**S5 — the "internal-analysis documents" enumeration is a closed claim with an open population.**
The spec says these *are* the internal-analysis documents shipping at `docs/` root. Also shipping,
same class, unnamed:

| File | Why it is the same class |
|---|---|
| `docs/assumptions.md` | Assumption register with per-item confidence and **blast radius if wrong** — a sibling artifact of the named `docs/risk-register.md` |
| `docs/owner-tasks.md` | Internal owner ledger; cites retro internals and deferral counts |
| `docs/next-steps.md` | Internal sequencing written out of a Decision Council |

`POPULATION(invariant)` = internal-analysis documents shipping at `docs/` root.
`POPULATION(proxy)` = `docs/` root files matching 3 hardcoded stems. Half B is non-empty by 3.
This is the same S5 defect the Phase-2.1 rework was commissioned to fix (*"the class has more than
one member, and naming only one under-stated it"*) — corrected one level down, still present one
level up. **Fix:** state the class by its rule, not by enumeration, or extend the list by the 3.

**No regression found** in any guarantee the cycle actually makes. The 14 left the archive and stayed
byte-identical; nothing else moved; the ledger resolves; no file lost a citation outside the
permitted set.

### Independent confirmation of "byte-unchanged" (a different instrument than AC-6)

AC-6 proves byte-identity through **rename detection**, and the spec records that coupling as
untested against case-only renames. I verified the same invariant with an instrument that does not
use rename detection at all — direct blob-hash set comparison:

```
of the 14 BASE blobs, byte-identical twins under docs/internal at HEAD:  14
BASE blobs with NO byte-identical twin at HEAD:                           0     (empty)
```

Negative control (one synthetic hash injected) prints exactly the injected line, so the empty result
is meaningful. **The byte-unchanged guarantee holds independently of rename detection.**

### Other confirmations

- Reports remaining at `docs/` root: **0**. Version triple: `VERSION` 2.19.12, README 2.19.12,
  `CHANGELOG.md:22` `## [2.19.12] - 2026-08-23`.
- Deletions audited (not just additions): exactly 7 removed lines branch-wide — README 1, VERSION 1,
  `verify-ledger-annotations.sh` 3 (the AC-5 repath), `docs/architecture.md` 2. The 2 in
  `architecture.md` are precisely the mandated ADR-088 status flip and the ADR-037 index-row
  past-tense correction, and they land in `a218dfa`, which
  `git merge-base --is-ancestor d51dd51 a218dfa` confirms **descends from the r3 move commit** —
  the S3 sequencing binding is satisfied.
- AC-8 note complies: family-glob form, no individual filename, pins no count.
- No live credential patterns (`gh[pousr]_`, `AKIA`, PEM private keys, `xox[baprs]-`, `sk-`) in any
  of the 83 internal documents. The sensitivity here is analytical — unfixed findings and attack
  reasoning — not secrets. This is consistent with the Content Exclusion Policy rationale.

---

## OWASP Top 10 Assessment

| Category | Status | Notes |
|---|---|---|
| A01 Broken Access Control | N/A | No runtime authz surface; this is a build-artifact cycle |
| A02 Cryptographic Failures | PASS | No crypto introduced; no secrets in scope (S8) |
| A03 Injection | PASS | No user-controlled data reaches a shell word in the S4 body; all interpolations are job-level `env` |
| A04 Insecure Design | **WARNING** | S3 — a control property asserted in the spec (AC-8) does not hold against the shipped control |
| A05 Security Misconfiguration | **WARNING** | S4 — PR-time blindness to a `.gitattributes` regression; mitigated at publication |
| A06 Vulnerable Components | PASS | No dependencies added. All 3 Actions SHA-pinned (`checkout@11bd719`, `shellcheck@00cae50`, `markdownlint@05f3221`) |
| A07 Auth Failures | N/A | No auth surface |
| A08 Data Integrity Failures | PASS | `git archive` on a tree object — working-tree state cannot leak in; blob-hash comparison confirms integrity of all 14 |
| A09 Logging & Monitoring | **WARNING** | S5 — stated non-guarantees under-state the population; S1/S2 omissions are disclosure-integrity issues |
| A10 SSRF | N/A | No outbound request introduced. `permissions: contents: read` |

**LLM threat assessment (LLM01/02/06):** the moved documents are data consumed by humans and by
`verify-ledger-annotations.sh` as *paths*, never as instructions. No agent-readable surface in this
cycle interprets report content as directives. No prompt-injection vector introduced.

---

## NOT-RUN — honest list

1. **AC-7 under GNU grep.** Never executed by anyone, in any round, in any environment. It is not a
   CI step by design (`git archive "$BASE"` needs BASE's object; 1 of 34 checkout jobs sets
   `fetch-depth: 0`). My runs were BSD `/usr/bin/grep`. **Ranked first** for any future CI adoption.
2. **Case-only renames** against AC-6 / AC-7's shared rename-detection coupling. Not runnable on this
   case-insensitive host. Unchanged from Phase 2; my blob-hash check reduces but does not eliminate
   the exposure, because it compares content, not path casing.
3. **`diff.renameLimit` exhaustion** — Phase 2 tested `renameLimit=1` and could not break it; I did
   not re-test, and did not test the inexact-rename path.
4. **Enumeration of every published release tag.** I verified `v2.19.11` contains 14; I did not walk
   all ~30 tags. The S2 claim is stated only for the tag I measured.
5. **`release-archive-assert.sh` end-to-end through `publish-release.sh`.** I executed the assert
   directly against built archives (both directions). I did **not** run `publish-release.sh` itself —
   it performs irreversible public writes, and the no-destructive-test-on-live-resource rule applies.
   The `refusing to publish` path is therefore read, not executed.
6. **The proposed remedies in S3 and S4 are untested as shipped code.** I verified the *measurements*
   they rest on (`PERMIT_ADD` count 9; `docs/internal/` 0 at HEAD / 89 on the regression tree). The
   snippets themselves have not been run inside their target files.
7. **markdownlint over `docs/`.** Excluded by `!docs/**` and `.markdownlintignore`. Nothing in this
   cycle's document set — including this report — is lint-verified. Green CI is not evidence about
   these files.

---

## Verdict

**PASS WITH WARNINGS — 0 CRITICAL, 0 BLOCKER.**

The cycle does what it says: the 14 reports left the release archive, byte-unchanged, nothing else
moved, the ledger resolves, no file outside the permitted set gained or lost a citation, and the gate
that prevents recurrence is real, canary-protected, vacuity-guarded, and observed going red in three
independent ways. Both Phase-2 BLOCKERs are genuinely closed, and the S2 mechanical remedy is
stronger than the printed-warning remedy I originally proposed.

The five WARNINGs are **honesty and timing** defects, not exposure defects: what the cycle achieved is
narrower than what its own documents imply, and one guard's blind spot is covered later than it should
be. None of them is made worse by merging, and one of them (S1) is made *better* by merging.
