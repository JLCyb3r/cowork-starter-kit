# Design — v2.19.12 "S4 report-egress retrofit"

**Phase 1 (Design) · @architect (opus) · 2026-08-23**
**Branch:** `release/v2.19.12-s4-report-egress`
**BASE (pinned, literal 40-char SHA):** `b43fa523f995736af70c483930935aed62b6a42b`
**Classification:** SECURITY-SENSITIVE — **Tier A** (worktree branch + PR + @security Guard Change Summary REQUIRED). COMPLIANCE-SENSITIVE = **NO**.

> *ISO 15288 — Architecture Definition Process.*

---

## §A. Phase-1 header record

> **PHASE 2.1 REWORK RECORD — 2026-08-23, @architect (opus), branch `release/v2.19.12-s4-report-egress`.**
> Eight bounded items from `docs/internal/security/security-review-v2.19.12.md`. **The AC set was not
> reopened.** Closed here: **S1** (§E.3 now carries the verbatim executed control; §D.6 names executor
> and phase), **S2** (§E.3 Decision 3 + §E.4 — the `--- /dev/null` rule is replaced by a finite set
> derived from `BASE` + `CYCLE_VERSION`; @security's `docs/report-index.md` construction is an
> executed RED case), **S3** (§D.5 — the ADR-088 flip and the ADR-037 past-tense edit are **reverted
> on this branch** and become Phase-4 work descending from the r3 move commit), **S4** (§H item 2 —
> the citation figure is *unpinned*, not corrected to `66/8`; the orchestrator overruled @security
> here), **S5** (§H item 1 — the non-guarantee names the class), **S6** (§E.3 change 2 — `^-`
> attribution from `--- SRCX/`), **S7** (§E.5 — diff-size magnitudes removed, three measurers
> tabulated), **S11** (§D.4 — `scope_allow_delta` enumerated, phantoms removed, the Phase-2 report's
> own path added). Every claim below that changed carries the command that produced it.

**Worktree discipline:** ENFORCED (SECURITY-SENSITIVE). First action was `git -C /Users/macbookpro/claude-cowork-config rev-parse HEAD` → `b43fa523f995736af70c483930935aed62b6a42b`, matching the orchestrator-supplied base. No drift.

**Grep flavour behind every load-bearing count in this document.** Probed with `type -a grep` (never `bash -c 'type grep'`, which cannot see a zsh function):

```
grep is a shell function from /Users/macbookpro/.claude/shell-snapshots/snapshot-zsh-1787438881566-4nji8l.sh
grep is /usr/bin/grep
```

`grep --version` inline → **ugrep 7.8.4**. **Every count in this document was taken with `/usr/bin/grep` (BSD grep), invoked by absolute path**, and every count is labelled as such. GNU grep on `ubuntu-latest` — the flavour CI actually runs — remains unmeasured by anyone across five rounds; see §I.

**Reuse Radar.** `docs/reuse-registry.md` — not present in this repo (Council-side artifact, ships v0.32.2): skipped. `examples/scaffolds/INDEX.md` — not present: skipped. CS catalog / `Reusability:` tags — `claude-cowork-config` is not a Domain / Confidante / Pillar OS / Motif constituent; no SoS umbrella applies. `sos-interfaces.json` — not applicable to this repo.
**Buy-vs-Build: N/A — no non-trivial new components this cycle.** This is a retrofit: files move, one script field is repointed, one CI step is added inline. No new dependency, no new module, no vendored content.

**EARS check.** Applied to the HIGH-severity ACs (AC-4 through AC-8). All four carry executable assertions with pinned literals and named exit codes; none is vague in the EARS sense ("the system shall be robust"). **EARS check: 0 HIGH-severity findings — no OQs generated.** The defects found this phase are *denominator* defects, not *vagueness* defects — the ACs say exactly what they mean, and what they mean is measurably wrong. EARS does not detect that class; symmetric-difference execution does.

**SoS Classification:** N/A — single-project design.
**UAF viewpoints:** Strategic — N/A, single-project design. Operational — N/A, single-project design. Service — N/A, single-project design. Resource — N/A, single-project design.

**Reliability Analysis: N/A per NEVER-APPLY** (no external API provider in a request path, no failover mechanism, no SLA or availability claim in scope).

**Heuristics check (Rechtin), for the ADRs minted below:**
- *"In architecting a new program, all the serious mistakes are made in the first day."* — Signal: **fired.** The AC set's population choice (`:(exclude)docs/internal/...`) was made once and inherited through four review rounds without re-examination. §E.
- *"Do the hard part first."* — Signal: **fired.** The one piece nobody had executed (AC-7's partition) was executed first, before any document was written. It failed.
- *"A model is not reality."* — Signal: **fired.** Four rounds of RED/GREEN/BROKEN modelled the control's behaviour inside the control's own frame. Running it against a real simulated tree contradicted the model.
- *"Relationships among the elements are what give systems their added value."* — Signal: **fired.** The AC-5 ↔ AC-7 interaction (AC-5's mandated edit is an AC-7 violation) is invisible when each AC is reviewed alone. §E.2.
- *"The first line of defense against complexity is simplicity of design."* — Signal: **partially counter-indicated.** The R4 simplification pass deleted the pathspec enumeration, and with it the `scripts/verify-ledger-annotations.sh` exclusion that made the set coherent. Simplification removed a load-bearing element. Recorded, not reversed — the repair below is simpler *and* correct.

**Production-artifact validation: N/A — no repo-artifact parsing in this design.** This cycle's logic parses `git diff` and `git archive` output, not pipeline.md / roadmap.md / registry.json / retro.md. The equivalent discipline *was* applied in the stronger available form: every control was executed against a **full simulated end-state tree built from a real clone of this repository at BASE**, not against fixtures. See §E.

**B1 verification: SKIPPED** — `scope-allow-verify.sh` is a Council-side guard; this design targets an external registered project, where @dev's scope is governed by the target repo's own pre-commit hook. The `scope_allow_delta` block is recorded in §D.4 regardless.

**Classification Re-Run (post-OQ, per `docs/pipeline-policy.md` §PostOQClassificationReRun):** **CONFIRMED — SECURITY-SENSITIVE Tier A, no change.** The final file list (§D) still contains `scripts/verify-ledger-annotations.sh` (TIER-1: any file under `scripts/` modified) and `.github/workflows/quality.yml`. Either alone is sufficient. The AC-7 repair in §E adds no new file to the list — it changes the *content* of a control that was already in scope.

---

## §B. Measurements re-derived at BASE

Every figure below was measured this session at `b43fa523f995736af70c483930935aed62b6a42b`. **Nothing is inherited.** Where a figure contradicts one carried forward from Phase 0, the contradiction is stated.

| Quantity | Measured @ BASE | Command | Note |
|---|---|---|---|
| Moveset size | **14** | `git archive <BASE> \| tar -tf - \| /usr/bin/grep -E '^docs/(qa-report\|security-audit\|security-review)-'` | enumerated, not counted |
| Archive entries @ BASE | **431** | same, piped to `/usr/bin/grep -c ''` | matches the Phase-0 correction |
| Archive entries @ simulated end state | **418** | `git archive <sim> \| tar -tf - \| /usr/bin/grep -c ''` | 431 − 14 + 1 (`docs/design-v2.19.12.md`) |
| Leak matches @ simulated end state | **0** | `... \| /usr/bin/grep -cE '^docs/(qa-report\|security-audit\|security-review)-'` | AC-4 GREEN holds |
| LA-03 records naming a movee | **3** (`:134`, `:135`, `:136`) | `/usr/bin/grep -nE 'docs/(qa-report\|security-audit\|security-review)-' scripts/verify-ledger-annotations.sh` | the *only* three in that file |
| `docs/retro.md` matches `S-A3` / `S-A9` / `S-A10` | **1 / 1 / 1** | `/usr/bin/grep -c '<id>' docs/retro.md` | F4 confirmed — LA-03a's annotation is false |
| Movee self-citations, **exact** `docs/`-prefixed | **13 lines** | `git grep -c -E '<14 exact names>' <BASE> -- <5 movees>` | reproduces Phase 0's 13 |
| Movee self-citations, **bare-name** | **15 lines** | AC-7 partition, §E | **+2 vs exact** — bare citations lacking the `docs/` prefix |

**Correction 1 — AC-4's GREEN literal is `0 of 418`, not `0 of 417`.** The FINAL AC SET quotes `S4 PASS — 0 of 417` from R2's simulation, which predates this cycle's own `docs/design-v2.19.12.md`. Measured end state is **418**. **Nothing breaks:** AC-4's YAML interpolates `${COUNT}` and pins no absolute — this is precisely why ADR-088's amendment restates the claim as a *delta*. Only prose citing 417 is wrong.

**Correction 2 — the bare-name metric is 15 lines inside the movees, not 13.** Phase 0 measured 13 with a `docs/`-prefixed pattern. AC-7's control matches **bare filenames** (`sed 's#^docs/##'`), and finds **15**. The 2-line delta is citations written without the `docs/` prefix. This is the same mechanism as S2 — measured here at the movee level for the first time. It changes no acceptance threshold; it is recorded so no reviewer "reconciles" 15 down to 13.

---

## §C. The four items Phase 1 owed

> *ISO 15288 — Decision Management Process.*

### C.1 — AC-5's `numstat` expectation, re-derived

**The Phase-0 instruction is wrong. The expectation is still `3	3`.**

The instruction reads: *"This changes the numstat expectation — Phase 1 MUST re-derive it; it is no longer `3 3`."* Re-derived by execution on a real clone: the annotation is **field 5 of the same physical line** as the `AFILE` (field 2). Correcting the annotation modifies a line the repath was already modifying. Three modified lines = 3 added + 3 deleted.

```
$ git diff --numstat -- scripts/verify-ledger-annotations.sh
3	3	scripts/verify-ledger-annotations.sh
```

The edit measured was the complete AC-5 edit: all three `AFILE` values repointed to `docs/internal/security/security-audit-v2.19.6.md` **and** LA-03a's false *"not docs/retro.md, where it occurs 0 times"* annotation replaced.

**The number is `3	3`, but the number alone is not the requirement.** `3	3` is true only while each record occupies one physical line. An implementer who reflows a record across two lines produces a different numstat with identical semantics. **The AC must therefore state the invariant, not only the literal:** *exactly the three LA-03 records change, each remains one physical line, and no other line in the file changes.* The positional greps (below) carry the evidence; `numstat` is corroboration.

**AC-5's positional assertions, executed on the repaired post-move tree:**

```
$ /usr/bin/grep -cE 'LA-03[abc]\$\{US\}docs/internal/security/security-audit-v2\.19\.6\.md\$\{US\}' scripts/verify-ledger-annotations.sh
3
$ /usr/bin/grep -cE 'LA-03[abc]\$\{US\}docs/security-audit-v2\.19\.6\.md\$\{US\}' scripts/verify-ledger-annotations.sh
0
$ bash scripts/verify-ledger-annotations.sh --no-probes    # rc=0
verify-ledger-annotations: PASS — 19 of 19 static anchors resolved; 0 live-probe failures
```

**🔴 Implementation hazard found while executing this: `/usr/bin/grep -c` exits 1 when the count is 0.** The "MUST be 0" leg therefore **aborts any step running under `set -euo pipefail`** — the exact ADR-089 defect class that ADR-090 §Decision (4) exists to name. **Every AC-5 assertion pipeline MUST carry `|| true`.** This is not theoretical: it was observed live this session (`Exit code 1` accompanying the correct output `0`).

### C.2 — `BASE` pinned

**`BASE=b43fa523f995736af70c483930935aed62b6a42b`** — the literal 40-char SHA of `b43fa52`, verified as the branch tip at Phase 1 start. Every AC referencing `BASE` uses this literal. No abbreviation is permitted in any shipped control: an abbreviated SHA is ambiguity waiting for the object count to grow.

### C.3 — ADR-088 amendment

Authored and appended to `docs/architecture.md` as **"Amendment record — ADR-088 (appended v2.19.12 Phase 1)"**, per the house convention that ADRs are amended by appended record and never rewritten in place. It carries all five owed elements: the 3-arm canary; the delta-not-absolute restatement; the single reconciliation clause naming ADR-090's amendment §3 as operative; the ADR-037 index-row correction; and the two scope boundaries (`docs/internal/ export-ignore` as sole archive protection for 71 reports, and `LEAK_PATTERN`'s `^docs/` anchor leaving `docs/project-audit-v2.6.1.md` shipping). See §G.

### C.4 — AC-7's partition logic, executed

**Executed. It does not hold.** Full findings in §E — this is the substantive result of Phase 1.

---

## §E. 🔴 AC-7 FAILS ON A CORRECT CYCLE — four defects, measured

> *ISO 15288 — Verification Process.*

**Method.** A disposable clone of this repository at BASE (`git clone --no-hardlinks`; the live repo was never mutated, per the read-only-on-shared-resources rule). Into it: the 14 `git mv` operations, AC-5's complete edit, AC-8's family-glob forwarding note appended to `docs/architecture.md`, a `CHANGELOG.md` append, and a `docs/design-v2.19.12.md` enumerating the moveset. One commit. **This is a correct, fully compliant cycle — the tree AC-7 is supposed to bless.**

Because the AC's own pipeline discards file attribution (defect **D4**), the partition was reimplemented statefully, tracking `+++ DSTX/` headers.

**Result on a correct cycle:**

```
INVENTORY: N=14 B=0                          <- inventory guard PASSES
REMOVED-LINE VIOLATIONS (a): 18
   MINUS docs/qa-report-v2.19.6.md        5
   MINUS docs/security-audit-v2.19.6.md   5
   MINUS scripts/verify-ledger-annotations.sh  3
   MINUS docs/security-audit-v2.19.9.md   2
   MINUS docs/security-review-v2.19.5.md  2
   MINUS docs/qa-report-v2.19.0.md        1
ADDED-LINE VIOLATIONS (b) outside the four append-only surfaces: 17
   PLUS docs/design-v2.19.12.md           14
   PLUS scripts/verify-ledger-annotations.sh   3
VERDICT: exit 1 (VIOLATION)
```

**35 violations, every one of them the cycle's own mandated work.** The "mandated corrective action is the next defect vector" lineage reaches **5/5**.

### D1 — the rename-pair exclusion achieves the opposite of its stated intent

AC-7 says *"excluding the 14 rename pairs"* and implements it as `:(exclude)docs/internal/qa` `:(exclude)docs/internal/security`. Those pathspecs exclude the **destination** paths. Git can then no longer pair source to destination, so **each of the 14 movees renders as a whole-file deletion** and every content line becomes a `-` line. The exclusion does not hide the rename pairs; it *guarantees* their deletion half is visible while hiding the addition half. 15 of the 18 removed-line violations are movee self-citations.

> `POPULATION(invariant)` = every file in the repo, minus the 14 rename pairs.
> `POPULATION(proxy)` = every file outside `docs/internal/qa` and `docs/internal/security`, **with the 14 movees present as deletions**.

The two differ in **both** directions — which is why both halves of the symmetric difference are non-empty (below).

### D2 — `scripts/verify-ledger-annotations.sh` trips both halves, on AC-5's mandated edit

3 removed lines and 3 added lines. **AC-5 requires exactly this edit.** The superseded AC-7a explicitly excluded this file — *"Class A, which AC-7a already explicitly excludes because AC-5 changes it."* The R4 simplification deleted the 9-pathspec enumeration and, with it, that exclusion. The two ACs now contradict each other by construction. This is the AC-5 ↔ AC-7 interaction that no single-AC review can see.

### D3 — `docs/design-v2.19.12.md` trips half (b), 14 times

This file is a **new shipping artifact this cycle** — the AC set itself relies on it (the archive end state is 432 → 418 *because* of it). It is not one of the four append-only surfaces, so every line naming a movee is an addition violation. Any design document that enumerates its own moveset trips the control.

### D4 — the partition is not computable from `$OUT` as the AC constructs it

The AC pipes through `grep -vE '^(--- SRCX/|\+\+\+ DSTX/)'`, **discarding file attribution**, and then rules that *"any `^+` line outside the four append-only surfaces is a violation."* That predicate needs the filename the header just removed. Executed literally, `$OUT` is 37 undifferentiated lines:

```
+- Moved 14 internal reports behind docs/internal/. Example: docs/security-audit-v2.19.6.md is
-13. `docs/security-review-v2.19.5.md`
+- docs/qa-report-v2.18.0.md -> internal
+- docs/qa-report-v2.19.0.md -> internal
```

Line 1 is a **permitted** CHANGELOG addition; lines 3–4 are **violations**. They are indistinguishable in this stream. (37 = 19 + 17 + 1, cross-checking the stateful count exactly.)

### E.2 — Symmetric difference, both halves executed

**Half A — satisfies the invariant, violates the proxy:** the correct cycle above. **35 false violations.** Non-empty.

**Half B — violates the invariant, satisfies the proxy:** a genuine citation removal seeded inside `docs/internal/qa/qa-report-v2.19.10.md:399`, which names `docs/qa-report-v2.19.9.md`. This is exactly what AC-7(a) forbids *"anywhere in the repo."*

```
$ (with the violation committed)
diff line count: UNCHANGED, byte-identical to the clean run
REMOVED-LINE VIOLATIONS (a): 18    <- unchanged
VERDICT: exit 1 (VIOLATION)        <- the same 35, the real one absent
```

**The violation never enters the stream.** Non-empty. The *invariance* is the finding; the absolute
line count is not, and is deliberately not pinned here — see §E.5.

**Both halves non-empty. This is textbook denominator drift** — the shape R3 named and R4 was convened to eliminate. It survived R4 because R4 tested the *inventory guard* and the *header filter*, and the partition — where the population lives — was never run.

**Negative control (so this is not a check that cannot fail):** a removal seeded in `docs/design-v2.19.10.md`, a non-excluded frozen surface, **was** caught (`MINUS docs/design-v2.19.10.md 1`). The detection logic is sound. The **population** is wrong.

### E.3 — Repaired AC-7 — THE EXECUTABLE ARTIFACT (Phase-2 rework, closes S1 / S2 / S6)

> **Why this section changed.** Phase 2 found (**S1, BLOCKER**) that the repair existed only as
> prose: `/usr/bin/grep -c awk docs/design-v2.19.12.md` returned **0**, §D assigned AC-7 no
> implementation home, and the spec's bash block stopped exactly at the partition — the locus of
> four defect generations. @security re-derived a working partition from those bullets and
> reproduced the numbers, which is evidence the prose was *good*; it is not evidence that the next
> reader's re-derivation will be. **The block below is not a description of what was executed. It is
> what was executed, byte-for-byte**, and every figure in §E.3 and §E.4 is its stdout.

**Executor and phase (binding).** **`@qa` runs this at Phase 5, pre-merge, locally**, over
`BASE..<branch tip>`, and pastes the stdout — including the `permitted:` bucket — into
`docs/internal/qa/qa-report-v2.19.12.md`. **@dev SHOULD run it before the Phase-4 commit**; a
violation found at Phase 5 costs a rework round. It is deliberately **not** a CI step this cycle:
`git archive "$BASE"` needs BASE's object and exactly one of 34 `actions/checkout` jobs sets
`fetch-depth: 0` (§I item 2). Exit codes: **0** clean, **1** violation, **3** control broken.

**Three changes from the AC as written. All three were executed before being written down.**

**1. Derive the rename exclusion from rename DETECTION, never from pathspecs (defect D1).**
`git diff --find-renames=100%` over the whole repository, **no `:(exclude)`**. A byte-unchanged
rename emits `rename from` / `rename to` and **no content lines at all**, so the 14 pairs drop out
mechanically — while `docs/internal/**` stays *inside* the population, closing half B. Excluding a
rename's destination does not hide the pair; it **prevents the pairing**, guaranteeing the deletion
half is visible while the addition half is hidden.

**2. Preserve attribution, and take it from the correct side (defect D4; Phase-2 finding S6).**
The AC's pipeline filtered the headers out and then ruled on "which file the line is in" — not a
computable predicate. Track headers statefully, and **attribute `^-` lines from the preceding
`--- SRCX/` header and `^+` lines from `+++ DSTX/`.** The design's earlier method paragraph named
only `+++`; on a modified movee git renders the pair as a whole-file delete plus a whole-file add,
so the deletion half carries `+++ /dev/null` and every deletion-side violation is reported against
`/dev/null`. Detection and exit code stay correct; the **diagnosis** is lost — and in this lineage
an illegible alarm has repeatedly become the next generation's defect. Measured, same tree, same
diff, only the attribution rule differing:

```
attribution from '+++' only (superseded)   ->    MINUS /dev/null                     1
attribution from '--- SRCX/' (shipped)     ->    MINUS docs/qa-report-v2.19.6.md     1
```

The `SRCX/` / `DSTX/` prefixes are load-bearing for this and are not cosmetic: a **content** line
whose text begins `++ ` renders as `+++ ` and would otherwise be parsed as a header.

**3. Permit additions from a FINITE DERIVED SET, never from `--- /dev/null` (Phase-2 finding S2,
BLOCKER — this is a correction of Phase 1's own repair).** Phase 1 permitted additions in "any file
created by this cycle", detected as `--- /dev/null`, on the reasoning that **no filename is
hardcoded and none can drift**. @security constructed the input that breaks it: a new, public,
shipping `docs/report-index.md` republishing all 14 pre-move paths passes AC-7, AC-4 and AC-6
simultaneously. A rule written to eliminate a hardcoded filename list had replaced a **bounded**
exception set with an **unbounded** one. The permitted set is instead derived from the two literals
this control already pins — `BASE` and `CYCLE_VERSION` — and is finite:

| Permitted for ADDITIONS | Why |
|---|---|
| `CHANGELOG.md`, `docs/architecture.md`, `docs/retro.md`, `docs/spec.md` | the four append-only surfaces, already named by the AC |
| `scripts/verify-ledger-annotations.sh` | AC-5 mandates the edit (defect D2) |
| `docs/design-v${CYCLE_VERSION}.md` | this cycle's own shipping design doc; legitimately needs 14 (defect D3) |
| `docs/internal/qa/qa-report-v${CYCLE_VERSION}.md` | the Phase-5 QA report |
| `docs/internal/security/security-review-v${CYCLE_VERSION}.md` | the Phase-2 security review (already on this branch) |
| `docs/internal/security/security-audit-v${CYCLE_VERSION}.md` | the Phase-6 audit |

Permitted for REMOVALS: `scripts/verify-ledger-annotations.sh` **only**.

**The drift objection is answered by failing CLOSED, not by widening.** If a cycle artifact is named
off-pattern, its additions are *violations*, printed by name — loud, not silent. That is the
opposite of `--- /dev/null`, which fails **open** and silently. Negative control run: dropping
`docs/design-v${CYCLE_VERSION}.md` from the permitted set turns the **correct** cycle red with
`PLUS docs/design-v2.19.12.md 14`, so the permitted-set leg demonstrably can fail (§E.4).

**Rejected alternatives, named so they are not re-proposed.** (i) @security's remedy — print the
bucket and declare an unexpected entry a *reviewer STOP* — was rejected as the primary control
because it converts a silent permission into **a printed line a human must read**, which @security
itself listed as untestable on its own NOT-RUN list. **The printing is retained regardless** (it is
what made S2 visible, and it costs one line of output). (ii) A `docs/internal/**` **prefix** was
rejected in favour of the three exact `CYCLE_VERSION`-derived paths: the prefix would permit
additions anywhere under the move's own destination, and `docs/internal/` is protected from the
release archive by exactly one `.gitattributes` line that AC-4 is structurally blind to (ADR-088
amendment §5(a)). Measured cost of the narrower choice: on a modified movee the prefix form catches
only the removal half, the exact form catches **both** halves (§E.4, case B6).

**🔴 The `scripts/verify-ledger-annotations.sh` carve-out is safe ONLY because AC-5 asserts that
file's content positionally.** The carve-out is a hole; AC-5's two greps (`==3` new-path, `==0`
old-path) are what fill it. **If AC-5 is ever dropped or weakened, this carve-out becomes a silent
blind spot on the one file the whole cycle's script-side correctness rests on.** No leg may be
dropped — the same conjunction AC-6 carries.

**Inventory guard: unchanged and retained.** `N=14 B=0`. It was never the defect. Its `exit 3` leg
is demonstrated firing in §E.4.

#### The control, verbatim

```bash
#!/usr/bin/env bash
# AC-7 reference-freeze control - v2.19.12
# Usage: ac7.sh <repo> <tip-rev>
set -uo pipefail
REPO="${1:-.}"; TIP="${2:-HEAD}"
BASE="b43fa523f995736af70c483930935aed62b6a42b"
CYCLE_VERSION="2.19.12"
WORK="$(mktemp -d)"
MOVESET="$WORK/moveset.list"
git -C "$REPO" archive "$BASE" > "$WORK/base.tar"
tar -tf "$WORK/base.tar" | /usr/bin/grep -E '^docs/(qa-report|security-audit|security-review)-' | sed 's#^docs/##' > "$MOVESET"
N="$(/usr/bin/grep -c '' "$MOVESET" || true)"
B="$(/usr/bin/grep -c '^[[:space:]]*$' "$MOVESET" || true)"
if [ "$N" -ne 14 ]; then
  echo "::error::AC-7 control BROKEN - moveset yields ${N} lines; expected 14."
  exit 3
fi
if [ "$B" -ne 0 ]; then
  echo "::error::AC-7 control BROKEN - moveset has ${B} blank/whitespace lines; expected 0."
  exit 3
fi
echo "PATTERNS LOADED: $N"
PERMIT_ADD="CHANGELOG.md docs/architecture.md docs/retro.md docs/spec.md scripts/verify-ledger-annotations.sh docs/design-v${CYCLE_VERSION}.md docs/internal/qa/qa-report-v${CYCLE_VERSION}.md docs/internal/security/security-review-v${CYCLE_VERSION}.md docs/internal/security/security-audit-v${CYCLE_VERSION}.md"
PERMIT_DEL="scripts/verify-ledger-annotations.sh"
git -C "$REPO" diff --find-renames=100% --src-prefix=SRCX/ --dst-prefix=DSTX/ "$BASE".."$TIP" > "$WORK/diff.txt"
awk -v movesetfile="$MOVESET" -v permit_add="$PERMIT_ADD" -v permit_del="$PERMIT_DEL" '
BEGIN{
  n=0
  while((getline ln < movesetfile) > 0) if(ln!="") M[++n]=ln
  na=split(permit_add,PA," "); for(i=1;i<=na;i++) if(PA[i]!="") OKADD[PA[i]]=1
  nd=split(permit_del,PD," "); for(i=1;i<=nd;i++) if(PD[i]!="") OKDEL[PD[i]]=1
  src="?"; dst="?"; newfile=0
}
/^--- SRCX\//         { src=substr($0,10); newfile=0; next }
/^--- \/dev\/null/    { src="/dev/null";   newfile=1; next }
/^\+\+\+ DSTX\//      { dst=substr($0,10);            next }
/^\+\+\+ \/dev\/null/ { dst="/dev/null";              next }
/^[-+]/{
  hit=0
  for(i=1;i<=n;i++) if(index($0,M[i])>0){hit=1;break}
  if(!hit) next
  if(substr($0,1,1)=="-"){
    if(src in OKDEL) OKD[src]++; else VD[src]++
  } else {
    ok = (dst in OKADD)
    if(ok) OKA[dst]++; else VA[dst]++
  }
}
END{
  va=0; vd=0
  for(f in VD) vd+=VD[f]
  for(f in VA) va+=VA[f]
  printf "REMOVED-LINE VIOLATIONS (a): %d\n", vd
  for(f in VD) printf "   MINUS %-52s %3d\n", f, VD[f]
  printf "ADDED-LINE VIOLATIONS (b): %d\n", va
  for(f in VA) printf "   PLUS  %-52s %3d\n", f, VA[f]
  ta=0; td=0
  for(f in OKA) ta+=OKA[f]
  for(f in OKD) td+=OKD[f]
  printf "permitted: removals %d, additions %d\n", td, ta
  for(f in OKD) printf "   (ok-) %-52s %3d\n", f, OKD[f]
  for(f in OKA) printf "   (ok+) %-52s %3d\n", f, OKA[f]
  if(va+vd>0){ print "VERDICT: exit 1 VIOLATION"; exit 1 }
  print "VERDICT: exit 0 CLEAN"
}' "$WORK/diff.txt"
RC=$?
rm -rf "$WORK"
exit $RC
```

### E.4 — The test matrix that decided S2, executed

**Method.** One disposable clone (`git clone --no-hardlinks`; the live repo was never mutated), built
on the **real branch tip `84cf3b3`** — not a synthetic tree: the 14 `git mv` in one commit tagged
`v2.19.12-r3`, then AC-5's complete edit, AC-8's forwarding note, AC-4's step and a `CHANGELOG.md`
append in a descendant commit `v2.19.12-r4`. Every seeded case branches from `v2.19.12-r4`, so the
A/B differs in exactly one variable.

**The S2 decision, isolated to one variable.** Same tree, same script, only the permitted-additions
rule differing:

| Tree | `--- /dev/null` rule (Phase-1 form) | derived-set rule (shipped) |
|---|---|---|
| **Half A** — correct cycle | exit 0 CLEAN, `(a) 0 / (b) 0` | **exit 0 CLEAN, `(a) 0 / (b) 0`** |
| **B1** — @security's `docs/report-index.md` | **exit 0 CLEAN**, `(ok+) docs/report-index.md 14` — GENERATION 9 reproduced | **exit 1 VIOLATION**, `PLUS docs/report-index.md 14` |
| **B4** — new `tests/fixtures/` file citing 2 pre-move paths | exit 0 CLEAN | **exit 1 VIOLATION**, `PLUS tests/fixtures/release-surface/seeded-fixture.txt 2` |

The mechanical option therefore works, and **no human is in the loop**. @security's printed-warning
remedy is not needed as the control; the printing is kept as diagnostics.

**Half A — satisfies the invariant, must not be flagged (`v2.19.12-r4`):**

```
PATTERNS LOADED: 14
REMOVED-LINE VIOLATIONS (a): 0
ADDED-LINE VIOLATIONS (b): 0
permitted: removals 3, additions 20
   (ok-) scripts/verify-ledger-annotations.sh                   3
   (ok+) CHANGELOG.md                                           2
   (ok+) docs/internal/security/security-review-v2.19.12.md     1
   (ok+) docs/design-v2.19.12.md                               14
   (ok+) scripts/verify-ledger-annotations.sh                   3
VERDICT: exit 0 CLEAN
```

**The orchestrator's constraint holds: `docs/design-v2.19.12.md`'s legitimate additions do not
trip.** The population was not narrowed far enough to break the correct cycle.

**🔴 Read the `permitted:` counts as a tree-state sample, never as an expected value — including the
ones printed above.** They are a function of the very documents this rework is editing. The
transcript above was taken on branch tip `84cf3b3`, where `docs/design-v2.19.12.md` contributed
**14**. Re-run after this rework's edits (tip `7497e77` + `r3` + `r4`) the same correct cycle
returns:

```
REMOVED-LINE VIOLATIONS (a): 0
ADDED-LINE VIOLATIONS (b): 0
permitted: removals 3, additions 39
   (ok-) scripts/verify-ledger-annotations.sh                   3
   (ok+) CHANGELOG.md                                           2
   (ok+) docs/internal/security/security-review-v2.19.12.md     1
   (ok+) docs/design-v2.19.12.md                               31      <- was 14
   (ok+) scripts/verify-ledger-annotations.sh                   3
   (ok+) docs/spec.md                                           2
VERDICT: exit 0 CLEAN
```

and `B1` re-run on the same tip is still `ADDED-LINE VIOLATIONS (b): 14 / PLUS docs/report-index.md
14 / exit 1`. **`docs/design-v2.19.12.md` moved 14 → 31 because §E.3 now carries the verbatim script
and §D.4 now enumerates the moveset.** Writing "31" down here would change it again — this is a
fixed point that does not exist, and it is the same trap as S4 and S7 one level in.

**The acceptance criterion is therefore the invariant, not any count:** on a correct cycle
`(a) == 0` and `(b) == 0` and `exit == 0`; the `permitted:` bucket is diagnostics, and its contents
are reviewed by *name* — an unexpected filename in it is the signal, not an unexpected number.

**The live branch, as it stands after this rework, is CLEAN under the shipped control:**
`BASE..HEAD` → `PATTERNS LOADED: 14 / (a) 0 / (b) 0 / exit 0`, with `removals 0` — confirming §D.5's
revert made `docs/architecture.md` purely append-only.

**Half B — violates the invariant, must be flagged. Four constructions, all non-empty:**

```
B1  new public docs/report-index.md republishing all 14 pre-move paths
    ADDED-LINE VIOLATIONS (b): 14
       PLUS  docs/report-index.md                                  14      exit 1

B2  citation REMOVAL seeded inside docs/internal/qa/qa-report-v2.19.10.md:399
    REMOVED-LINE VIOLATIONS (a): 1
       MINUS docs/internal/qa/qa-report-v2.19.10.md                 1      exit 1

B4  new tests/fixtures/release-surface/seeded-fixture.txt citing 2 pre-move paths
    ADDED-LINE VIOLATIONS (b): 2
       PLUS  tests/fixtures/release-surface/seeded-fixture.txt      2      exit 1

B6  a movee modified during the move (breaks R100 pairing; NOT-RUN #3 closed)
    REMOVED-LINE VIOLATIONS (a): 5
       MINUS docs/qa-report-v2.19.6.md                              5      <- S6: real path, not /dev/null
    ADDED-LINE VIOLATIONS (b): 5
       PLUS  docs/internal/qa/qa-report-v2.19.6.md                  5      exit 1
```

**B2 is the half the superseded pathspec form was structurally blind to.** It is caught.
**B6 gives double coverage with AC-6** and is the case that justifies exact derived paths over a
`docs/internal/**` prefix: under a prefix rule the `PLUS` half would be permitted.

**Negative controls — so none of this is a check that cannot fail:**

```
permitted-set leg   drop docs/design-v${CYCLE_VERSION}.md from PERMIT_ADD, run against the CORRECT cycle
                    -> ADDED-LINE VIOLATIONS (b): 14 / PLUS docs/design-v2.19.12.md 14 / exit 1

inventory leg       widen the moveset regex to a 4th stem (project-audit) -> N=15
                    -> ::error::AC-7 control BROKEN - moveset yields 15 lines; expected 14.  exit 3
```

All three exit codes (0 / 1 / 3) were observed, each from a distinct input.

**Neighbouring-remedy checks (the generation-7 shape).**

- **S3 x AC-7.** Moving the ADR-088 flip and the ADR-037 index-row edit to Phase 4 (§D.5) means two
  lines that are currently unchanged will be *removed* in a Phase-4 commit, and removals are
  permitted only in `verify-ledger-annotations.sh`. Verified that neither line names a movee, in
  **both** units — `docs/`-prefixed **and** the bare-filename unit AC-7 actually matches:
  `/usr/bin/grep -c -F -f <14 docs/-prefixed names>` -> **0**;
  `/usr/bin/grep -c -F -f <14 bare names>` -> **0**. Relocating them cannot trip AC-7(a).
- **S1 x S4.** Pasting this script and enumerating the moveset in §D.4 both *add* movee-naming lines
  to `docs/design-v2.19.12.md`. That is permitted by AC-7 — and it is also the direct demonstration
  that any pinned dangling-citation figure is stale the moment the design doc is edited. See §H.
- **S11 x AC-7.** §D.4's enumerated `scope_allow_delta` lists destination paths, which are not
  movee names; the design doc is permitted for additions regardless.
- **AC-5 x AC-7.** The ledger carve-out is filled only by AC-5's two positional greps. Both legs
  re-confirmed on the post-move clone: `3` new-path, `0` old-path, numstat `3	3`.

### E.5 — Diff-size magnitudes are NOT pinned (closes S7, on the S4 ruling)

The Phase-1 draft pinned `3925 -> 119` diff lines. Phase 2 measured the same two forms at the branch
base and got **`4664 -> 858`** (`36 -> 0` movee-naming lines) and asked for the figures to be
labelled synthetic or replaced. **Replacing them would have been wrong.** Phase 2.1 measured the
same two forms a third time, on a correct-cycle tree built from the real branch tip:

| Measurer | superseded `:(exclude)` form | repaired `--find-renames=100%` form | tree-state |
|---|---|---|---|
| Phase 1 (@architect) | 3925 | 119 | synthetic clone, moveset-enumerating design doc only |
| Phase 2 (@security) | 4664 | 858 | branch tip `83f317c` + its own end-state build |
| Phase 2.1 (@architect) | **4683** | **1388** | branch tip `84cf3b3` + `v2.19.12-r4` |

And the *"movee-naming lines"* sub-quantity, measured on the Phase-2.1 tree, is **27 -> 15** — not
`36 -> 0`, because "movee-naming line" and "violating line" are **different quantities**: 15 of the
repaired form's lines name a movee and are *permitted*.

**Three competent measurers, three tree-states, and at least two different units for one English
phrase.** That is the `Ambiguous-unit numeric claim` pattern — BINDING since v2.19.11 — firing for
the fourth time in this cycle. **The magnitudes are therefore removed rather than replaced.** What
reproduces in all three measurements, and is the actual claim, is the **direction and the
mechanism**: the pathspec form inflates the diff by rendering all 14 movees as whole-file deletions;
the rename-paired form does not. Anyone who wants a number runs:

```bash
git diff --find-renames=100% "$BASE".."<tip>" | wc -l
git diff "$BASE".."<tip>" -- . ':(exclude)docs/internal/qa' ':(exclude)docs/internal/security' | wc -l
```

and states the tree-state it was run on.

---

## §D. File-by-File Implementation Plan (Phase 4, @dev)

> *ISO 15288 — Implementation Process.*

**Do NOT implement before the Phase 3 gate.**

### D.1 — the 14 moves (`git mv` only; content byte-unchanged)

5 → `docs/internal/qa/`: `qa-report-v2.18.0.md`, `qa-report-v2.19.0.md`, `qa-report-v2.19.6.md`, `qa-report-v2.19.7.md`, `qa-report-v2.19.9.md`
9 → `docs/internal/security/`: `security-audit-v2.18.0.md`, `security-audit-v2.19.0.md`, `security-audit-v2.19.6.md`, `security-audit-v2.19.7.md`, `security-audit-v2.19.9.md`, `security-review-v2.18.0.md`, `security-review-v2.19.0.md`, `security-review-v2.19.5.md`, `security-review-v2.19.6.md`

All 14 in **one commit**, tagged `v2.19.12-r3`. No content edit inside any movee — a repoint breaks R100 and fails AC-6.

### D.2 — `scripts/verify-ledger-annotations.sh` (AC-5)

Lines 134–136 only. Repoint the three `AFILE` values to `docs/internal/security/security-audit-v2.19.6.md`, and correct LA-03a's false annotation. Each record stays **one physical line**. Expected `git diff --numstat` → `3	3`.

### D.3 — `.github/workflows/quality.yml` (AC-4)

Add the S4 step exactly as composed in the R1 fold-in, **plus `shell: bash`** (`for c in $CANARY_PATHS` does not word-split under zsh). Also correct the error text: it currently instructs moving *any* match into `docs/internal/`, which for a legitimately public document removes it from every release.

### D.4 — new/appended files

- `docs/design-v2.19.12.md` — this document (new).
- `docs/architecture.md` — ADR-088 amendment, ADR-091, ADR-091 index row, AC-8 forwarding note (**append only at Phase 1**). The two in-place index-cell edits are **Phase-4 work** — see §D.5.
- `docs/internal/security/security-review-v2.19.12.md` — the Phase-2 security review (new, already on the branch).
- `docs/internal/qa/qa-report-v2.19.12.md` — the Phase-5 QA report, carrying the §E.3 control's stdout.
- `docs/spec.md`, `CHANGELOG.md` — **append only**.

**`scope_allow_delta` — enumerated, not cross-producted (closes Phase-2 finding S11).** The previous
block used `security-(audit|review)-v2\.(18\.0|19\.0|19\.5|19\.6|19\.7|19\.9)\.md`, a
**cross-product granting 12 destination paths where only 9 exist** — the three phantom grants were
`security-audit-v2.19.5.md`, `security-review-v2.19.7.md`, `security-review-v2.19.9.md` — while
**omitting** the Phase-2 report's own path. A write-scope grant must enumerate the moveset, and the
moveset is already derived mechanically elsewhere in this design. Over-broad in one direction and
short in the other is now corrected in both.

```yaml
scope_allow_delta:
  add:
    - "docs/design-v2.19.12.md"
    - "docs/internal/qa/qa-report-v2.18.0.md"
    - "docs/internal/qa/qa-report-v2.19.0.md"
    - "docs/internal/qa/qa-report-v2.19.6.md"
    - "docs/internal/qa/qa-report-v2.19.7.md"
    - "docs/internal/qa/qa-report-v2.19.9.md"
    - "docs/internal/qa/qa-report-v2.19.12.md"
    - "docs/internal/security/security-audit-v2.18.0.md"
    - "docs/internal/security/security-audit-v2.19.0.md"
    - "docs/internal/security/security-audit-v2.19.6.md"
    - "docs/internal/security/security-audit-v2.19.7.md"
    - "docs/internal/security/security-audit-v2.19.9.md"
    - "docs/internal/security/security-review-v2.18.0.md"
    - "docs/internal/security/security-review-v2.19.0.md"
    - "docs/internal/security/security-review-v2.19.5.md"
    - "docs/internal/security/security-review-v2.19.6.md"
    - "docs/internal/security/security-review-v2.19.12.md"
  remove: []
```

**Count check, executed against the branch, not asserted:** the 14 destination paths above are the
`git mv` targets of the 14 sources enumerated in §D.1 — same list, same order, `docs/` replaced by
`docs/internal/{qa,security}/`. The two extra entries are this cycle's own reports
(`security-review-v2.19.12.md`, already committed on this branch; `qa-report-v2.19.12.md`, owed at
Phase 5). Total **17**. No regex alternation appears in the block, so no path can be granted that is
not written out.

### D.5 — Phase-4 only: the ADR-088 status flip and the ADR-037 index-row correction (closes S3)

**These two in-place line edits were made at Phase 1 and have been REVERTED on this branch.** They
are Phase-4 work and **MUST land in a commit that is a descendant of the `v2.19.12-r3` move
commit.**

| # | File | Edit |
|---|---|---|
| 1 | `docs/architecture.md` ADR-088 index row | status cell `PROPOSED (deferred at v2.19.10 Phase 1.3 …)` → `ACCEPTED (v2.19.12 — was PROPOSED (deferred) at v2.19.10 Phase 1.3, and ACCEPTED at Phase 1.2; number reserved and carried forward, cf. ADR-028)`, plus an `AMENDED by …` pointer to the v2.19.12 amendment record |
| 2 | `docs/architecture.md` ADR-037 index row | the clause *"the retrofit that closes them has not yet shipped"* → the shipped form naming v2.19.12 |
| 3 | `docs/architecture.md` ADR-088 amendment record, §Status and §4 | replace the "NOT FLIPPED BY THIS RECORD" placeholder with the flip record |

**Why.** @security (S3) enumerated the reachable states of the Phase-1 flip and found the
compensating control sits downstream of the risk it mitigates:

| State | Phase-5 conjunction fires? | Outcome |
|---|---|---|
| Phase 4 lands all 14 | yes | flip becomes true |
| Phase 4 lands 12 of 14 | yes (`R100 != 14`) | caught |
| **owner descopes the retrofit at the Phase 3 gate** | **no — Phase 5 never runs** | **no control at all** |

The third row is **what happened to this cycle's ancestor**: ADR-088 was minted ACCEPTED at v2.19.10
Phase 1.2 and the owner moved the retrofit out at the Phase 3 gate — the deferral record exists
because of that event, and that gate has not yet happened for v2.19.12. `docs/architecture.md`
**ships**, so between Phase 1 and Phase 3 the branch was publishing, in the past tense, that a move
which has not happened did happen — violating this design's own governing rule, *"An ADR that
diagnoses a falsified status claim must not ship carrying one."*

**The Phase-5 conjunction check is RETAINED as a second control.** @qa MUST verify: the ADR-088
index cell reads ACCEPTED **and** `git archive HEAD | tar -tf - | grep -cE '^docs/(qa-report|security-audit|security-review)-'`
returns 0. If @qa cannot run the conjunction, the flip is reverted rather than trusted.

**Confirmed safe against AC-7, in both units** — the two lines a Phase-4 commit will *remove* name
none of the 14: `/usr/bin/grep -c -F -f <14 docs/-prefixed names>` → **0**, and
`/usr/bin/grep -c -F -f <14 bare names>` → **0** (the bare unit is what AC-7 actually matches).
Relocating them cannot trip AC-7(a).

### D.6 — AC-7 execution (closes S1)

AC-7 has an implementation home and an owner. **@qa, Phase 5, pre-merge, locally**, runs the
verbatim control in §E.3 over `BASE..<branch tip>` and pastes its stdout — including the
`permitted:` bucket — into `docs/internal/qa/qa-report-v2.19.12.md`. @dev SHOULD run the same
script before the Phase-4 commit. Not a CI step this cycle (§I item 2).

---

## §G. ADR obligations

> *ISO 15288 — Information Management Process.*

**G.1 — ADR-088 amendment** (appended record, §C.3): 3-arm canary replacing §Decision (5)'s single-family form; numeric claim restated as a **delta (−14 archive entries)**, never a hardcoded absolute; **one** reconciliation clause naming **ADR-090's amendment §3 as operative** (ADR-090's convention is aspirational outside its single guarded pair; ADR-088 §Decision (2)'s Class A/B ruling is the in-force reference-freeze rule); the two scope boundaries.

**G.2 — ADR-091 (new).** *The reference-freeze control derives its population by rename-pairing, not pathspec exclusion.* Mints the §E.3 repair, carries the §Maturation Path section, and records the interlock that the `verify-ledger-annotations.sh` carve-out depends on AC-5.

**G.3 — index-cell edits: REVERTED at Phase 2.1, relocated to Phase 4 (S3).** `docs/architecture.md`
is now **purely append-only** against `main` on this branch — verified:
`git diff main -- docs/architecture.md | /usr/bin/grep -c '^-[^-]'` → **0**. The two edits and their
rationale are specified in §D.5.

**Maturation-Path self-grep (Workflow step 5.5), measured BASE → working tree:**
`**Future-state options:**` 58 → **60** · `**Concrete revisit triggers:**` 58 → **60** · `**Risk knowingly accepted:**` 58 → **60**.
All three increased by exactly **+2**, matching the two §Maturation Path sections authored (the ADR-088 amendment record and ADR-091). Equal deltas across all three headers is the evidence that none was paraphrased.

**🔴 Sequencing risk accepted, with a compensating check.** The flip is recorded at Phase 1 while the
14 files have not yet moved, so **this branch is transiently self-contradictory until §D.1 lands**.
That is tolerable only because the branch is unmerged and merge requires Phase 7. The compensating
control is mandatory and is written into the amendment record itself: **Phase 5 (@qa) MUST verify the
conjunction** — ADR-088 reads ACCEPTED **and** the archive returns 0 leak matches. If §D.1 is dropped
or descoped and the flip survives, `main` ships the exact falsified-status error ADR-088 exists to
correct. **If @qa cannot run that conjunction, the flip must be reverted rather than trusted.**

**🔴 The flip is only honest if the move lands in the same branch.** ADR-088 §Decision (1) asserts the 14 *are* retrofitted. **Phase 5 (@qa) MUST verify the conjunction:** ADR-088 reads ACCEPTED **and** `git archive HEAD | tar -tf -` returns 0 leak matches. If the move is dropped and the flip survives, `main` carries exactly the falsified-status error ADR-088 was written to correct in ADR-037.

---

## §H. Risks, boundaries, carry-forwards

**Not guaranteed** (restated so no reader infers more):

1. **Internal documents at paths outside `^docs/<stem>-` are invisible to AC-4 by design, and the
   class has more than one member (closes S5).** The Phase-1 draft named only
   `docs/project-audit-v2.6.1.md`, which reads as if it were the sole exception. `.gitattributes`
   export-ignores `docs/internal/`, `spec.md`, `retro.md` and `patterns.md`; **everything else under
   `docs/` ships.** The internal-analysis documents that ship at `docs/` root are:
   **every `docs/design-v*.md`** (this cycle adds its own), **`docs/project-audit-v2.6.1.md`**, and
   **`docs/risk-register.md`**. Membership is enumerable at merge with
   `git archive HEAD | tar -tf - | /usr/bin/grep -E '^docs/(design-v|project-audit-|risk-register)'`;
   **no count is pinned here**, for the reason in item 2.
   This cycle's own `docs/design-v2.19.12.md` ships and contains §I — a NOT-RUN list enumerating the
   untested areas of the release-hygiene controls — plus §H naming exactly what `LEAK_PATTERN` is
   blind to. **The cycle withdraws 14 QA/security reports from the public archive while adding, to
   that same archive, a document that maps where the withdrawal controls are weak.** That is not
   fixed here — ADR-037 made design docs public deliberately, and widening anything this cycle is
   ruled out on measured grounds (below) — but it is now *stated*, which is the whole obligation of
   a non-guarantee. Carried as `CF-v2.19.12-D`.

2. **The dangling citations are acknowledged by AC-8's note, not repaired — and their number is
   deliberately NOT pinned (closes S4).** Phase 2 was right that `~56/7` under-states the shipping
   tree, and right about the mechanism: it is the same correction already made once in §B for the
   archive absolute (`432 -> 418`, "because this cycle owes its own shipping design doc") and not
   applied to the citation count. **But writing `66/8` into the spec would re-pin the figure the
   simplification pass deliberately removed.** Measured this session, one quantity, four answers:

   | Unit | Tree-state | Value |
   |---|---|---|
   | lines / files, `docs/`-prefixed | shipping archive of the correct-cycle end state | **66 / 8** |
   | occurrences | same | **66** |
   | lines / files | **working tree** at the same commit (includes export-ignored files) | **128 / 21** |
   | lines / files, `docs/`-prefixed | shipping archive **before** this cycle's design doc existed | **56 / 7** |

   Add the figures already in circulation — `59/8`, `60/8`, and the orchestrator's independently
   measured `70` — and one English phrase, *"the dangling citations"*, has carried **six** values
   across three units and three tree-states. `docs/design-v2.19.12.md` is itself one of the largest
   contributors, and **this Phase-2.1 rework changed its contribution again** by pasting the §E.3
   control and enumerating the moveset in §D.4. Any number written here is stale before it is read.

   **Therefore: no citation count is pinned in this design, in the spec, or in the Guard Change
   Summary.** The quantity, stated once and unpinned: *lines naming one of the 14 pre-move
   `docs/`-prefixed paths, counted in the release archive of the merge commit.* It is recorded by
   `CF-v2.19.12-E` **measured at merge**, which is what the FINAL AC SET already said.

3. **An AC-7 match is a candidate, not a proven violation** — it flags `.bak` filenames, vendored
   copies, and URLs naming a file in a *different repository*; a human confirms.

**Do NOT widen `LEAK_PATTERN`.** Measured: a 4-stem match returns **15**, breaking AC-6's `R100 == 14` and AC-4's own "14 paths" prose simultaneously.

**Do NOT leave redirect stubs at `docs/` root** — they match `LEAK_PATTERN` and make AC-6's delta 13.

**Carry-forwards:** `CF-v2.19.12-A` (`.github/CODEOWNERS` `docs/security/` row is inert — the move does **not** bring the reports under owner routing); `CF-v2.19.12-B` (re-scope `CF-v2.19.11-A` from a post-merge measurement); `CF-v2.19.12-D` (**new** — `docs/project-audit-v2.6.1.md` knowingly out of scope); `CF-v2.19.12-E` (**new** — record the dangling-citation count *measured at merge*, never inherited).

---

## §I. NOT-RUN — explicit

Assume the next round mines this list first; that is what has happened every time. **Updated at
Phase 2.1 — three Phase-1 items were closed by execution, one by @security and two here, and three
new ones are added by this rework.**

1. **GNU grep on `ubuntu-latest` — still unmeasured by anyone, now six rounds running.** Every count
   in this document is BSD (`/usr/bin/grep`, absolute path; inline `grep` in this harness is a
   **ugrep 7.8.4** zsh shim). @security confirmed by probe that GNU is **unmeasurable on this host**
   (`command -v ggrep gnugrep docker podman colima nix` → empty; no Homebrew gnubin), which is a
   stronger statement than "not attempted" but is not a measurement. **Rank first for the first real
   CI run.** @security also measured the shim/BSD gap for the first time and found it **real and
   opposite in direction**: `grep -F -f` with a blank pattern line returns **1** under BSD (fails
   open) and **0** under the shim.
2. **The §E.3 control has never run in real CI**, only locally against simulated end-state trees
   built from real clones. `git archive "$BASE"` needs BASE's object and exactly one of 34
   `actions/checkout` jobs sets `fetch-depth: 0`. **This is why §D.6 assigns it to @qa at Phase 5,
   locally, rather than to CI.** If a later cycle promotes it to CI, the host job must declare
   `fetch-depth: 0`.
3. **Case-only renames against AC-6 and AC-7** — not run, **and not runnable on this host**: the
   filesystem is case-insensitive, so the collision cannot be materialised in a working tree. It
   needs `git update-index` plumbing or a case-sensitive volume. The repaired AC-7 shares AC-6's
   dependence on rename detection, so this case degrades **both** together.
   *(The `diff.renameLimit` half of this item is CLOSED — @security ran the repaired control under
   `git -c diff.renameLimit=1` and got a byte-identical diff with all 14 rename markers, because
   `--find-renames=100%` pairs by content hash, not by the bounded inexact search.)*
4. **The repo's own `tests/` suite against a post-move tree.** `tests/fixtures/release-surface/`
   contains files citing movesets and sits inside a frozen surface. Unchanged, and now sharper: §E.4
   case **B4** shows a *new* file under `tests/fixtures/` citing pre-move paths is correctly RED, but
   the behaviour of the **existing** fixtures after the move is still unmeasured.
5. **AC-4's composed YAML inside a real Actions runner**, including `shell: bash` word-splitting of
   `CANARY_PATHS`. Verified by reading only, by two agents. Unchanged.
6. **LP-01's `Branch not protected` 404 path** against the real API. Unchanged.
7. **`CF-v2.19.11-A` / ADR-090 overlap (S12).** Not investigated. Unchanged from Phase 0.
8. **NEW — the Phase-4 flip commit has not been executed.** §D.5 requires the ADR-088 status flip and
   the ADR-037 index-row correction to land in a commit **descending from `v2.19.12-r3`**. What was
   verified is only that the two lines they *remove* name none of the 14, in both units. **That the
   commit is actually ordered after r3 is checkable only at Phase 4/5**, and no automated control
   asserts the ancestry — @qa must check `git merge-base --is-ancestor <r3> <flip-commit>` by hand.
9. **NEW — the derived permitted set is not asserted against the cycle's real artifact names.** The
   control permits `docs/internal/qa/qa-report-v2.19.12.md` and
   `docs/internal/security/security-audit-v2.19.12.md`, neither of which exists yet. If @qa or
   @security name their report differently, the correct cycle goes RED — **loud, not silent**, and
   fixable in one line, but it will look like a control failure to someone who has not read this
   note. The Phase-2 report's real path was confirmed to match (`(ok+) 1`).
10. **NEW — `.gitattributes` is not asserted by anything in this cycle.** Decision (3)'s three
    internal permitted paths are safe only because `docs/internal/ export-ignore` keeps them out of
    the archive, and **AC-4 is structurally blind to that line's removal** (ADR-088 amendment §5(a)).
    Adding an assertion would be a new control and is out of this rework's scope; it is the largest
    standing exposure and is named in ADR-091's revisit triggers.
