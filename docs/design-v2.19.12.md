# Design — v2.19.12 "S4 report-egress retrofit"

**Phase 1 (Design) · @architect (opus) · 2026-08-23**
**Branch:** `release/v2.19.12-s4-report-egress`
**BASE (pinned, literal 40-char SHA):** `b43fa523f995736af70c483930935aed62b6a42b`
**Classification:** SECURITY-SENSITIVE — **Tier A** (worktree branch + PR + @security Guard Change Summary REQUIRED). COMPLIANCE-SENSITIVE = **NO**.

> *ISO 15288 — Architecture Definition Process.*

---

## §A. Phase-1 header record

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
diff line count: 3925      <- BYTE-IDENTICAL to the clean run
REMOVED-LINE VIOLATIONS (a): 18    <- unchanged
VERDICT: exit 1 (VIOLATION)        <- same 35, the real one absent
```

**The violation never enters the stream.** Non-empty.

**Both halves non-empty. This is textbook denominator drift** — the shape R3 named and R4 was convened to eliminate. It survived R4 because R4 tested the *inventory guard* and the *header filter*, and the partition — where the population lives — was never run.

**Negative control (so this is not a check that cannot fail):** a removal seeded in `docs/design-v2.19.10.md`, a non-excluded frozen surface, **was** caught (`MINUS docs/design-v2.19.10.md 1`). The detection logic is sound. The **population** is wrong.

### E.3 — Repaired AC-7, verified in both directions

Two changes. Both were executed before being written down.

1. **Derive the rename exclusion from rename detection, not from pathspecs.** Use `git diff --find-renames=100%` over the **whole repo, with no `:(exclude)`**. A byte-unchanged rename then emits `rename from` / `rename to` and **no content lines at all**, so the 14 pairs drop out mechanically — while `docs/internal/**` stays *inside* the population, closing half B. Diff size falls 3925 → **119 lines**.
2. **Permit additions by a derived rule, not a filename list.** Additions are permitted in (i) the four append-only surfaces, (ii) any file **created by this cycle** — detected mechanically as `--- /dev/null`, so no filename is hardcoded and none can drift — and (iii) `scripts/verify-ledger-annotations.sh`. Removals are permitted **only** in `scripts/verify-ledger-annotations.sh`.

**Executed — correct cycle:**
```
(a) REMOVED violations: 0
(b) ADDED violations: 0
permitted: removals 3, additions 18
VERDICT: exit 0 CLEAN
```

**Executed — both seeded violations present:**
```
(a) REMOVED violations: 2
    MINUS SRCX/docs/design-v2.19.10.md               1
    MINUS SRCX/docs/internal/qa/qa-report-v2.19.10.md 1
(b) ADDED violations: 0
VERDICT: exit 1 VIOLATION
```

**Strictly stronger in both directions:** false violations 35 → 0, and the half-B violation the AC was structurally blind to is now **caught**.

**🔴 The `scripts/verify-ledger-annotations.sh` carve-out is safe ONLY because AC-5 asserts that file's content positionally.** The carve-out is a hole; AC-5's two greps (`==3` new-path, `==0` old-path) are what fill it. **If AC-5 is ever dropped or weakened, this carve-out becomes a silent blind spot on the one file the whole cycle's script-side correctness rests on.** State this in the AC text — it is the same "no leg may be dropped" conjunction that AC-6 carries, and it is the neighbouring-remedy interlock this cycle's method exists to surface.

**Inventory guard: unchanged and retained.** `N=14 B=0` verified passing (`grep -c ''` / `grep -c '^[[:space:]]*$'`). The R3/R4 work on it stands; it was never the defect.

**Exit semantics: unchanged.** clean → **0** (the safety property), violation → **1**, broken inventory → **3** (diagnosis). AC-4's vacuity guard keeps `exit 1`: it has no fail-open, because its clean path is already 0. Consistency question, not a safety one — as R3 stated correctly.

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
- `docs/architecture.md` — ADR-088 amendment, ADR-091, index rows, AC-8 forwarding note (**append**; the index-cell edits in §G.3 are the sole in-place changes and name none of the 14).
- `docs/spec.md`, `CHANGELOG.md` — **append only**.

```yaml
scope_allow_delta:
  add:
    - "docs/design-v2.19.12.md"
    - "docs/internal/qa/qa-report-v2\\.(18\\.0|19\\.0|19\\.6|19\\.7|19\\.9)\\.md"
    - "docs/internal/security/security-(audit|review)-v2\\.(18\\.0|19\\.0|19\\.5|19\\.6|19\\.7|19\\.9)\\.md"
  remove: []
```

---

## §G. ADR obligations

> *ISO 15288 — Information Management Process.*

**G.1 — ADR-088 amendment** (appended record, §C.3): 3-arm canary replacing §Decision (5)'s single-family form; numeric claim restated as a **delta (−14 archive entries)**, never a hardcoded absolute; **one** reconciliation clause naming **ADR-090's amendment §3 as operative** (ADR-090's convention is aspirational outside its single guarded pair; ADR-088 §Decision (2)'s Class A/B ruling is the in-force reference-freeze rule); the two scope boundaries.

**G.2 — ADR-091 (new).** *The reference-freeze control derives its population by rename-pairing, not pathspec exclusion.* Mints the §E.3 repair, carries the §Maturation Path section, and records the interlock that the `verify-ledger-annotations.sh` carve-out depends on AC-5.

**G.3 — index-cell edits (DONE at Phase 1, this branch).** Both are executed; they are the **only two
in-place line changes** in `docs/architecture.md` this cycle (`git diff --numstat` → `196	2`), and
**neither removed line names any of the 14** (verified: `0` matches).
- ADR-088 row: `PROPOSED (deferred …)` → `ACCEPTED (v2.19.12 — was PROPOSED (deferred) at v2.19.10 Phase 1.3 …, cf. ADR-028)`, plus an `AMENDED by …` pointer to the new amendment record.
- ADR-037 row: the clause *"the retrofit that closes them has not yet shipped"* — **false at merge** — replaced with the shipped form naming v2.19.12.
- ADR-091 row added after ADR-090.

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

**Not guaranteed** (unchanged from the FINAL AC SET, restated so no reader infers more): internal reports at paths outside `^docs/<stem>-` are invisible to AC-4 by design — **`docs/project-audit-v2.6.1.md` ships today and stays shipping**; the ~56 dangling citations are *acknowledged* by AC-8's note, not repaired; **an AC-7 match is a candidate, not a proven violation** — it flags `.bak` filenames, vendored copies, and URLs naming a file in a *different repository*; a human confirms.

**Do NOT widen `LEAK_PATTERN`.** Measured: a 4-stem match returns **15**, breaking AC-6's `R100 == 14` and AC-4's own "14 paths" prose simultaneously.

**Do NOT leave redirect stubs at `docs/` root** — they match `LEAK_PATTERN` and make AC-6's delta 13.

**Carry-forwards:** `CF-v2.19.12-A` (`.github/CODEOWNERS` `docs/security/` row is inert — the move does **not** bring the reports under owner routing); `CF-v2.19.12-B` (re-scope `CF-v2.19.11-A` from a post-merge measurement); `CF-v2.19.12-D` (**new** — `docs/project-audit-v2.6.1.md` knowingly out of scope); `CF-v2.19.12-E` (**new** — record the dangling-citation count *measured at merge*, never inherited).

---

## §I. NOT-RUN — explicit

Assume the next round mines this list first; that is what has happened every time.

1. **GNU grep on `ubuntu-latest` — still unmeasured by anyone, now five rounds running.** Every count here is BSD (`/usr/bin/grep`). Rank first for the first real CI run.
2. **The repaired AC-7 control has never run in real CI**, only against a local simulated tree. `git archive "$BASE"` needs BASE's object: **exactly one** of 34 `actions/checkout` jobs sets `fetch-depth: 0`. AC-7 stays pre-merge-local **or** its host job declares it.
3. **A modified movee** (content edited during the move) was not run against the repaired AC-7. Expected: it breaks `--find-renames=100%` pairing, so its content lines enter the diff and AC-7 fires — *double* coverage with AC-6. **Expected, not measured.**
4. `diff.renameLimit` exhaustion and **case-only renames** against AC-6 — untested; first thing to attack if AC-6 is doubted. Note the repaired AC-7 now shares AC-6's dependence on rename detection, so a renameLimit failure degrades **both** controls together. **This is a new coupling introduced by §E.3 and is the single most likely place the next defect lives.**
5. The repo's own `tests/` suite against a post-move tree — `tests/fixtures/release-surface/` has two files citing movesets.
6. LP-01's `Branch not protected` 404 path against the real API.
7. AC-4 inside a real Actions runner.
8. `CF-v2.19.11-A` / ADR-090 overlap (S12) — not investigated; unchanged from Phase 0.
