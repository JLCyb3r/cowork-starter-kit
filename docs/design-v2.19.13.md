# Design — v2.19.13 "Citation Repair + Registry-Row Integrity"

> *ISO 15288 — Technical Management: Project Planning Process.*

**Cycle:** v2.19.13 · **Phase:** 1 (Design) · **Mode:** full
**Classification:** SECURITY-SENSITIVE — Tier A · COMPLIANCE-SENSITIVE = NO
**Worktree:** `/Users/macbookpro/claude-cowork-config/.worktrees/v2.19.13-citation-repair`
**Branch:** `release/v2.19.13-citation-repair` · **Base:** `9f6ddc2e60e443297b3f1e9bbc7f9e70852b7922`

**Evidence base for every number in this document.** All measurements were re-run by @architect
during Phase 1 against the **worktree** at `9f6ddc2` (`git -C <wt> status --porcelain` → 0 lines),
never against `/Users/macbookpro/claude-cowork-config` (the `main` checkout, which is a live
parallel-session surface). Binary: `/usr/bin/grep` = **BSD grep (GNU compatible) 2.6.0-FreeBSD**,
invoked by absolute path because the bare `grep` in this harness is a ugrep shim that under-counts.
Shell: `zsh`, with `/bin/bash` cross-checked explicitly wherever shell semantics were load-bearing.

**The standing rule this cycle produced, applied to this document's own inputs:**

> A number inherited from a reviewer is not verified until the recipient re-runs it.

Every number in `phase1-binding-conditions-v2.19.13.md` was **re-run, not adopted** — including the
numbers @architect itself wrote in Round 1 and Round 2. Three inherited numbers did not survive
re-measurement; they are recorded in §B.2 with the commands that falsified them.

**Phase 1.1 — deliberation conditions applied (APPROVE WITH CONDITIONS, 0 blockers).** @security
returned 4 WARNING + 5 INFO and @dev 1 MEDIUM + 3 LOW; every condition was a sentence-level document
edit and **scope was untouched**. The same re-run discipline was applied to this round's conditions.
Two more inherited claims did not survive it, and both were corrected rather than implemented:

| claim | source | measured |
|---|---|---|
| *"(b) is non-discriminating because `## X` contains no shallower prefix"* | this spec, from C16 | **FALSE.** `grep -cF '# Placeholder authoring rules' CONTRIBUTING.md` → **1**. `## X` does contain `# X`. See §B.6. |
| *"`sort -u` locale merge — unprovable locally, no GNU binary"* | @security S5 | **FALSE.** GNU coreutils 9.11 is installed (`/opt/homebrew/bin/gsort`). Proved it in one command instead of deferring to CI. See §B.7. |

One further defect was found in this document's own inputs and is **not** on either reviewer's list —
the ADR-088 index-row/body numbering divergence, §B.8. It is the root cause of the `Decision (3)`
census, and it also decided @dev's FINDING 1 (§B.9).

**Running total: 6 of 20 Phase-1 conditions and 2 of 13 Phase-1.1 conditions falsified by re-run**,
plus 2 defects found in @architect's own prior output. The rule is holding because it is being turned
on its own author, not only on reviewers.

---

## Table of contents

- §A — Phase 1 Design Header (mandatory records)
- §B — Binding-conditions disposition + defects found IN the conditions file
  (§B.6–§B.9 added at Phase 1.1: two falsified deliberation claims, the ADR-088 numbering root cause,
  and the ruling on @dev FINDING 1)
- §C — Technical design
- §D — File-by-File Implementation Plan + `scope_allow_delta`
- §E — B1 verification
- **Classification Re-Run** (mandatory gate record)
- §F — Residuals carried forward

---

---

## §A — Phase 1 Design Header (mandatory records)

> *ISO 15288 — Technical Management: Decision Management Process.*

### A.0 Worktree discipline

**Worktree discipline: ENFORCED (SECURITY-SENSITIVE / Tier A).**
First action executed before any read or write:
`git -C /Users/macbookpro/claude-cowork-config/.worktrees/v2.19.13-citation-repair rev-parse HEAD`
→ `9f6ddc2e60e443297b3f1e9bbc7f9e70852b7922`, matching the pinned base exactly.
`COUNCIL_EXPECTED_BASE_SHA` was **unset** in this spawn context (fail-open per F6), so the pinned
base from the spawn prompt was used as the comparand instead. Worktree tree state at Phase 1 start:
clean (`status --porcelain` → 0 lines).

**All measurements in this cycle were taken inside the worktree, never against
`/Users/macbookpro/claude-cowork-config`.** That path is `main` and is a live parallel-session
surface; asserting numbers against it would violate the moving-corpus discipline. This also matters
mechanically: the worktree is nested *inside* the main checkout, so a naive recursive grep run from
`main` would traverse `.worktrees/` and double every count. Verified the worktree contains no nested
`.worktrees/` directory, so it is a clean measurement surface.

### A.1 Production validation

**Production validation: N/A — no Council-registered-project repo-artifact parsing in this design.**
This cycle contains no logic that parses `pipeline.md`, `roadmap.md`, `registry.json`, `retro.md` or
any Council guard-read file, so the cross-project loop does not apply.

**The equivalent obligation for this cycle — running candidate logic against the REAL artifacts
rather than against fixtures — was discharged, and it changed the design.** The candidate whole-line
matcher was executed read-only against **every** guard-form citation in the repository (15 files,
22 file/anchor pairs), not only the 4 tuples in scope. Two facts surfaced that appear in no spec, no
review and no condition, and both are load-bearing:

1. **`.github/workflows/quality.yml` — the guard's own source — carries the citation form**, with the
   extracted "anchor" being its own uninterpolated variable. Any self-integrity count over the guard
   form must include it and must not self-exclude by accident.
2. **`docs/internal/security/security-review-v2.19.11.md` carries three historical security-test
   payloads in the citation form**, whose anchors are shell command-substitution and quote-breakout
   strings. They are legitimate Class-B records that must not be edited. This makes
   **glob-and-resolve unsafe on the current tree** and is now the primary recorded reason for
   explicit tuple enumeration — a stronger reason than the fixture-RED-leg argument that had been
   carried, which re-measurement also showed to be weaker than stated (those fixtures are
   unbackticked and invisible to the extraction regex).

A fixture-only validation would have surfaced neither.

### A.2 Reuse Radar (4-source lookup)

| # | Source | Result |
|---|---|---|
| 1 | `docs/reuse-registry.md` (Council) | Present. Grepped for `citation\|anchor\|sanitiz\|matcher\|heading\|log-injection\|tripwire` → 4 hits, **all Council-internal registry-parsing prose, zero component candidates.** |
| 2 | `examples/scaffolds/INDEX.md` (Council) | **Not present** — scaffold index not yet materialized. Recorded and skipped, not silently dropped. |
| 3 | `docs/constituent-systems.md` + `Reusability:` ADR tags | Present. Target repo's own ADR-090 is the direct predecessor and is **EXTENDED**, not rebuilt. |
| 4 | `.claude/projects/ecosystem/sos-interfaces.json` | Present. 0 matches for `cowork\|citation\|anchor` — no existing interface contract covers this capability. |

**Reuse Scan**

| Component | Registry hit | OSS candidate | Scaffold | Decision | Basis |
|---|---|---|---|---|---|
| Anchor-resolution matcher (inline shell) | none (grep pasted above) | n/a — `grep`/`awk` are already present, zero-dependency constraint forbids adding any | n/a | **EXTEND** | Extends ADR-090's existing inline guard. The zero-dependency / no-network constraint on this workflow forbids adding a dependency at all. |
| `ANCHOR_SAFE` sanitizer | none | n/a — same constraint | n/a | **BUILD** | No hit; ~6 lines of `tr`; adding a dependency is forbidden by the workflow's own constraint. Core to the security posture. |
| Citation-site tripwire | none | n/a | n/a | **REUSE (pattern)** | Reuses the in-repo `PARSER_COPIES` / `AC_PL_6_EXPECTED_HEX_ROWS` pinned-count shape verbatim. |
| W1 pipe-injection legs | none | n/a | n/a | **REUSE (pattern)** | Reuses the existing `pipe-sa`/`pipe-pg` runtime `awk` generator and `check_row()` shared function. **No new committed files** — these fixtures are generated into `mktemp -d` at CI time. |
| NC-5 + S15 control fixtures | none | n/a | n/a | **BUILD** | Two small committed files under `tests/`. Must be files, not shell one-liners — see §C.3. |

**Buy-vs-Build: 5 components scanned — REUSE 2 / ADOPT 0 / EXTEND 1 / BUILD 2**

No ADOPT rows, therefore: no dep-scan flag owed, no L1/L1b license gate owed, no `ATTRIBUTIONS.md`
row owed, no AC-D1.9 prompt-injection screen owed.

### A.3 EARS check

All 9 ACs (B0, S14, W1, CF-A, S5a, S5b, S11, S15, CF-B) were re-checked. **8 are Ubiquitous**
(falsifiable by absence); **AC-S5b is correctly Unwanted-behaviour**, being the one AC with a genuine
external runtime trigger rather than "the fix itself".

**EARS check: 0 HIGH-severity findings — no OQs generated.**

Two MEDIUM advisory findings from Round 2 were **resolved in this pass rather than carried**, because
both were testability defects rather than syntax defects: AC-S14 item 5 and AC-CF-A item 5 each placed
a non-behavioral obligation (a documentation carry-forward; a PR-authoring instruction) under a
behavioral Ubiquitous subject — a CI step cannot state a carry-forward. Both moved to Technical
Constraints. **EARS syntax 9/9 PASS; EARS testability 9/9 PASS** (was 6/8 at Round 2).

### A.4 SoS classification + UAF viewpoints

**N/A — single-project design.** The design touches exactly one registered project
(`claude-cowork-config`). The Council-side guard bundle is a *prerequisite to work around*, not a
constituent of this design, and no cross-project interface is created or modified.

| UAF viewpoint | Record |
|---|---|
| Operational | N/A — single-project design |
| Resources | N/A — single-project design |
| Services | N/A — single-project design |
| Personnel | N/A — single-project design |

One cross-repo note, recorded because it was mis-transferred once already: the Council's own
`docs/pipeline-policy.md §PostOQClassificationReRun` places `.github/workflows/` at **Tier B** in the
Council's *own* self-improvement governance. That rationale cites `security-sensitive-guard.yml`,
which **does not exist in this target repo**. It does not transfer, and it does not change this
cycle's verdict.

### A.5 Reliability analysis

**Reliability Analysis: N/A per NEVER-APPLY (no external API provider in any request path, no
failover or fallback mechanism, and no SLA or availability claim anywhere in the spec).**

### A.6 Heuristics check (Rechtin)

| Heuristic | Signal produced this cycle |
|---|---|
| *"In partitioning, choose the elements so that they are as independent as possible."* | **Fired.** S14 and S15 are NOT independent — same step, shared `$ANCHOR`, and S14 *creates* S15's population. Recorded as a binding Interference Constraint (combined edit). S14 × W1 **is** independent (different jobs) and is explicitly the safe pair. CF-A was wrongly folded into the combined set by the Round-2 draft; struck. |
| *"The choice between two architectures may well depend on which set of drawbacks can be handled better."* | **Fired, decisively.** Three matcher forms fail in three different directions — reddens-correct (noisy), greens-broken (silent), returns-0-on-correct (silent). Whole-line equality has none of the three. When one option's drawback is *silent* failure it is not a symmetric trade. |
| *"Build in and maintain options as long as possible."* | **Fired.** Recorded as ADR-092 §Maturation Path option (b) — a generated enumeration would dissolve the census gap — rather than forcing the choice now inside a 13th consecutive patch cycle. |
| *"A model is not reality."* | **Fired, and it is the cycle's core lesson.** Every defect generation came from reasoning about a command instead of running it. Discharged by re-running all 20 conditions; 4 were falsified. |
| *"Don't assume that the original statement of the problem is necessarily the best."* | **Not applicable — rationale:** scope was reviewed across 2 deliberation rounds and 6 reviews with **zero** scope defects found. Re-opening it at Phase 1 would be churn against a stable finding, and is an owner decision, not a Phase-1 one. |
| *"Simplify. Simplify. Simplify."* | **Fired as a constraint on the remedy.** Two proposed additions were kept (tripwire ~4 lines, `, rule 2` assertion ~3 lines) and the full census was **not** built, on cycle-size grounds. The tripwire's population was *scoped down* rather than the tripwire dropped. |

### A.7 Maturation Path self-grep (ADR-092)

Baseline before ADR-092 was appended, then after — worktree, `/usr/bin/grep` 2.6.0-FreeBSD:

```
**Future-state options:**         60 -> 61
**Concrete revisit triggers:**    60 -> 61
**Risk knowingly accepted:**      60 -> 61
```

Each header increased by **exactly 1**, confirming the section was COPIED from the template slot and
not paraphrased. Gate PASSES.

---

## §B — Binding-conditions disposition, and 4 defects found IN the conditions file

> *ISO 15288 — Technical: Stakeholder Needs and Requirements Definition Process.*

The full row-by-row disposition of all 20 conditions lives in the **Condition Ledger** appended to
`docs/spec.md` (that is the artifact @qa ticks). This section records only the four that **failed
re-measurement**, because each would have shipped a defect if implemented faithfully — which is this
project's binding failure mode, now in its 14th generation.

**Sixteen conditions reproduced exactly and are applied as written.** C1, C3, C7, C10, C12 and C17
were independently re-run and matched to the digit.

### B.1 — C13's pin of 16 REDs on this cycle's own correct tree

**Measured:** repo-wide guard-visible population = **15 files** (enumerated in §C.2). This cycle
adds **at least three more**, guaranteed:

| addition | why it must carry the guard form |
|---|---|
| `tests/fixtures/citation/nc5-prefix-truncated.md` | the guard must extract an anchor from it, or the control cannot run |
| `tests/fixtures/citation/s15-injection-control.md` | same |
| `templates/skill-template/SKILL.md` | CF-A backtick-wraps it; that is the point of the repair |

Post-cycle the repo-wide count is therefore **18 at minimum**. A pin of 16 fails on a **fully
correct** v2.19.13 tree — by 2, before this cycle's own internal reports are even written.

**A correction to my own first draft of this finding, recorded because the discipline applies to me
too.** I initially wrote that `docs/design-v2.19.13.md` would be a fourth addition, "because it must
quote the canonical anchor to specify the repair". **I then measured it: it does not.** This document
uses the generic form and bare anchor text, and never the full backticked `CONTRIBUTING.md` citation,
so it did not enter the population. The claim was an inference presented as a measurement — the exact
defect shape of generation 13 — and it is struck.

The per-cycle churn argument survives, but on **better** evidence than the one I first reached for:
every cycle emits a new `qa-report-v<N>.md`, `security-review-v<N>.md` and usually a
`security-audit-v<N>.md` under `docs/internal/`, and **five of those recurring per-cycle reports
already carry the guard form** (v2.19.10 and v2.19.11 vintages). For a citation-repair cycle they
near-certainly will again. That is a measured recurrence, not a projection about authoring style.

**This is the same failure class C7 deleted the residue pin for**, six conditions later in the same
document — C7's own words: *"a pin that fails on a correct tree is the same failure class this cycle
exists to fix."* The conditions file deletes one unstable pin and mandates another.

**Resolution:** the tripwire's *purpose* is preserved exactly and its *denominator* is corrected.
Population scoped to exclude `docs/` and `tests/`; pin = **6** post-CF-A (measured 5 today). See
§C.2 for why this does not weaken the control.

### B.2 — C9's "at least 4 deferred" is wrong; the measured count is 3

A full census was run over all 23 repo-wide `Decision (3)` occurrences, with **C9's own stated
inclusion test** applied to each. Total mis-pointer loci = **6**; in scope = **3**; deferred = **3**.
Six minus three is three, which is also forced by C9's own two other figures ("census is at least 6",
"3 loci in").

The hedge is legitimate about *future* files. It is not legitimate as a lower bound on the current
tree, where the set is finite, enumerable, and was enumerated.

### B.3 — C15's and C20's remedies each break the control they repair

**C15** mandates a visible ellipsis-prefixed truncation marker inside a pipeline that C15 itself
identifies as locale-dependent. Pinned to `LC_ALL=C` — the only deterministic choice — that pipeline
**strips multibyte**, so the marker is damaged by the very step it is meant to annotate. Measured:
the ellipsis is deleted, leaving a bare `[truncated]`.
**A marker that can be silently damaged cannot signal silent damage.** ASCII-only mandated, and the
operation order (strip, collapse, truncate, mark) fixed so the marker is applied last.

**C20** mandates a colon-free marker so the GREEN leg cannot be satisfied by colon-stripping alone.
Correct in purpose — but a colon-free marker **survives sanitization by construction**. Measured, the
sanitized output still contains `INJECTED-MARKER-7f3a`. So the inherited single assertion ("marker
absent from stdout") could **never** go GREEN on a correct implementation. Applying C20 to that
assertion shape converts a weak control into a permanently failing one.
**Rebuilt as two legs** — see §C.3.

### B.4 — C4's tie-breaker, on a ships-agnostic rule, mandates rewriting history

*"Where an occurrence's role is genuinely ambiguous, it is Class A"* is correct and adopted. But B0's
role rule is explicitly file- and ships-agnostic, and this repository is full of **append-only
historical records** that quote citations ambiguously — `CHANGELOG.md`'s release note for the
`self-apply` behaviour is the clearest live example, and it is export-ignored, so ships-status offers
no exemption either.

Read literally: tie-breaker plus ships-agnostic rule equals a standing obligation to **edit**
`CHANGELOG.md`, `docs/retro.md`, and every historical security audit — which this repository's own
append-only discipline forbids.

**Resolution:** the tie-breaker keeps its fail-safe direction, and B0 item 1 gains the discharge rule
it always implied: **Class A is an obligation, not an edit method.** Inside an append-only record the
obligation is discharged by a superseding cross-reference appended below, or by a recorded deferral —
never in place. This is the mechanism B0 items 3 and 4 already use; the tie-breaker simply had to say
so before it could be safely general.

### B.5 — C1 stands, with one clarification that does not weaken it

C1 is **non-waivable and is applied unchanged.** Its central claim was reproduced independently: on a
truncated anchor, the prefix form returns 1 (guard passes — false green) and the whole-line form
returns 0 (guard fails — correct).

One clarification, recorded so a later reader does not over-read the evidence: C1's two *illustrative*
live instances — `.github/CODEOWNERS` and `.github/workflows/release-assets.yml` — are genuine broken
Class-A pointers, but **neither is in the guard-visible backticked form** (measured: guard-form count
is 0 for each), so neither could ever reach the matcher under *either* implementation. They
demonstrate that prefix-shaped broken pointers exist in the wild; they are **not** demonstrations of a
false-green inside the guard. **C1 does not depend on them** — the reachable in-scope case (a
half-done CF-A repair) was reproduced directly and is sufficient alone.

### B.6 — Phase 1.1: the C16 rationale note was arguing from a false premise

@security S4 challenged one sentence in §GNU/BSD: *"(b) is non-discriminating for matching mode …
because `### X` contains `## X` while `## X` contains no shallower prefix."* Re-measured rather than
adopted, and the challenge holds — `## X` **does** contain `# X`:

```
/usr/bin/grep -cF  '# Placeholder authoring rules' CONTRIBUTING.md   -> 1     (matches the h2 line)
/usr/bin/grep -cxF '# Placeholder authoring rules' CONTRIBUTING.md   -> 0
/usr/bin/awk '{i=index($0,"# Placeholder authoring rules"); if(i>0) print NR": index="i}' \
             CONTRIBUTING.md                                          -> 114: index=2
```

The consequence is larger than the reviewer stated, and in the opposite direction. The guard sums
across h1–h6, so on the **h2** anchor bare `-F` returns `N_HEADS=2` where whole-line returns `1`.
**(b) therefore does discriminate the unanchored matchers** — it was being *undersold*, not oversold.
What (b) truly cannot discriminate is `index($0,s)==1`, and the reason is the `index=2` above: the
false match starts at offset 2, so a prefix-anchored test rejects it. That divergence surfaces only on
suffix **deletion**, which is (h)'s job and (h)'s alone.

Corrected in `docs/spec.md` §GNU/BSD. **C16's mandate is untouched** — 8 proof items, checklist reads
"All 8". Only the rationale was wrong, and a wrong rationale attached to a correct mandate is the
worse of the two failures: it teaches @dev and @qa a false rule they will apply somewhere else.

### B.7 — Phase 1.1: "unprovable locally" was itself unverified, and the locale merge is real

@security S5 flagged `sort -u` as the one member of the extraction pipeline whose locale-dependence
*satisfies* an assertion rather than breaking it, and filed it as unprovable locally for want of a GNU
binary. The finding is right; the caveat is not. Checked before accepting it:

```
/opt/homebrew/bin/gsort --version   -> sort (GNU coreutils) 9.11
/opt/homebrew/bin/gtr   --version   -> tr   (GNU coreutils) 9.11
ls /opt/homebrew/bin/ggrep /opt/homebrew/bin/gawk /opt/homebrew/bin/gsed  -> all absent
```

**GNU coreutils is installed.** The blanket "no GNU tooling on the authoring host" claim — carried in
§F and in `docs/spec.md` §Assumptions — is too broad, and it happens to be wrong about exactly the two
binaries this cycle's locale hazards live in. With `gsort` the merge took one command:

```
printf 'Placeholder authoring rules\nPlaceholder authoring\302\255 rules\n' \
  | LC_ALL=en_US.UTF-8 gsort -u | grep -c .    -> 1    MERGED (false green)
printf 'Placeholder authoring rules\nPlaceholder authoring\302\255 rules\n' \
  | LC_ALL=C          gsort -u | grep -c .    -> 2    correct
```

Two byte-distinct anchors, differing by a single **U+00AD SOFT HYPHEN**, collate equal and are merged
— so `N_DISTINCT` reads 1 and the `expected 1 distinct cited anchor` assertion **passes on a file
citing two different headings**. The character is invisible in rendered text, which is why a human
reviewer would not catch what the guard just waved through. `LC_ALL=C sort -u` pinned in AC-S14
item 2.

`gtr` also reproduced the sanitizer's locale split (`LC_ALL=C` deletes `§`, `en_US.UTF-8` preserves
it) and Defect 3(a)'s eaten ellipsis marker, both identical to the BSD results — so proof items (f)
and (g) are now **partially closed locally**, with glibc-versus-macOS collation tables as the residual
rather than "no binary exists". Items (a), (b), (c), (d), (e) and (h) still need CI: no GNU `grep`,
`awk` or `sed`.

### B.8 — Phase 1.1: the `Decision (3)` census has a root cause, and it is ADR-088 itself

Not raised by either reviewer. Found while ruling on @dev's FINDING 1, by reading ADR-088 instead of
citing it. **ADR-088 numbers its own decisions two different ways:**

```
index row, docs/architecture.md:111 — "Three decisions:"
  (1) archive-leak gate   (2) git check-attr rejected   (3) references ruled by differential
                                                            execution — Class A/Class B  <-- HERE
body, "### Decision" — six decisions:
  (1) retrofit the 14 via git mv
  (2) repair only the references a machine resolves; freeze the rest              <-- AND HERE
  (3) mint the archive-leak gate   (4) git archive is the instrument
  (5) canary                       (6) design-v2.19.* asymmetry
```

Under the index row, `§Decision (3)` **is** the reference-class ruling. The six census loci are
therefore not typos — they are a faithful reading of a summary the repository still publishes.

This matters for B0 in two ways. First, correcting three citing sites while leaving the index row
unreconciled fixes the symptom and leaves the generator running: the next reader of the index row
mints mis-pointer number seven, and B0's census goes stale by construction. Second, it changes the
right *mechanism* — see §B.9. B0 item 3 now carries both a ruling that the **body** numbering is
authoritative (the same more-specific-artifact rule C6 applied to the push table) and an instruction
to record the divergence in the amendment. The amendment is an append to `docs/architecture.md`, so
this costs no new scope.

**Corrected at Phase 2.1 — the clause that used to close this paragraph was false.** It read: *"and
does not edit the index row, which is itself inside an append-only record."* **The ADR index table is
not an append-only record, and it never has been.** Measured counterexample, run this session:

```
git show 39e1df0 -- docs/architecture.md   # "hotfix: rename v1.4.0 -> v1.3.2" (#7)
  -| ADR-019 | ... (v1.4)   | ACCEPTED |      <- description cell rewritten in place
  +| ADR-019 | ... (v1.3.2) | ACCEPTED |
  -| ADR-015 (amendment v1.4)   | ... |       <- ID cell rewritten in place
  +| ADR-015 (amendment v1.3.2) | ... |
```

And, on this very row, a second and closer counterexample found the same way — at `9a9961f`
(v2.19.12) **ADR-088's own `Status` cell** was rewritten in place from
`**PROPOSED (deferred at v2.19.10 Phase 1.3 …)**` to `**ACCEPTED (v2.19.12 …). AMENDED by the ADR-088
amendment record appended at v2.19.12 Phase 1 (§Amendment record — ADR-088, below).**` — an in-place
`Status`-cell edit whose sole purpose was **making an appended amendment reachable from the index
row**, which is precisely the move this cycle now needs a second time.

**The reachability ground, not merely the permission.** Striking the false premise would only make
the edit *allowed*; what makes it *owed* is B0 item 1's rule — **a recorded deferral MUST be reachable
from the occurrence, and silence at the occurrence is not a discharge**. The index row is the
occurrence that mints the defect. Ruling the body authoritative in an appended amendment that the
index row does not point to leaves the generator running exactly as the first half of this paragraph
warns. So B0 gains item 6, and the index row's `Status` cell — **not** its three-decision summary
text, which stays frozen because it was defensible when written — carries the pointer.

**Why the distinction survives.** The ADR *bodies* remain append-only; a `Status` cell is metadata
about the record, not the record. That is why B0's `bodies` parenthetical is left byte-identical
rather than widened, and why §D P-row 11 now names the one in-place edit instead of saying
"Append-only" flatly.

### B.9 — Phase 1.1: ruling on @dev FINDING 1 — B0 item 3 wins, AC-CF-B item 3 is corrected

**The conflict is real.** B0 item 3: the in-scope `Decision (3)` mis-pointers get *"a superseding
cross-reference appended below the record, never an in-place edit."* AC-CF-B item 3: the same line,
`docs/design-v2.19.11.md`'s `Under ADR-088 §Decision (3)'s`, *"is corrected to `(2)`"* — the direct-edit
verb its two siblings carry. @dev was right that it inherited that verb when C9 folded it in at
Phase 1, and right to refuse to guess.

**Ruled: appended superseding note. Not a direct edit.** @dev's own preferred resolution — CF-B's
specific wording beats B0's general one, per this cycle's C6 precedent — is sound *in form*, but its
premise is that this locus differs from the other two in a way that matters. Measured, it differs in a
way that does not:

| locus | sits inside | closed record? |
|---|---|---|
| `docs/architecture.md` `\| Site \| Class (ADR-088 §Decision (3)) \| Ships? \|` | `## Amendment record — ADR-090` | yes |
| `docs/architecture.md` `§Decision (3) above: Class B references are frozen` | `## Amendment record — ADR-088` | yes |
| `docs/design-v2.19.11.md` `Under ADR-088 §Decision (3)'s` | `### E.5`, ordinary design-doc body | **yes** |

@dev is correct that the third is not inside an amendment block. But the property that selects the
mechanism is **closed-versus-live**, not amendment-block-versus-body, and on that axis all three
match. Four grounds, all measured:

1. **The file is in the class.** ADR-088's Class-B clause enumerates append-only historical records
   and names a **sibling design doc**, `docs/design-v2.19.8.md`, among them.
2. **It is closed.** `docs/design-v2.19.11.md` shipped two cycles ago.
3. **The specificity argument selects the wrong winner** for the reason above.
4. **Decisive, and only visible because of §B.8:** `(3)` was *defensible when written*, against
   ADR-088's index row. An in-place rewrite would destroy a reading the repository still publishes —
   precisely the harm ADR-088's own second ground for freezing names (*"a v2.18.0 retro entry … was
   true when written"*). An appended note preserves both numberings, which is what a reader standing
   at that line actually needs.

**Items 1 and 2 of AC-CF-B keep the direct verb, and that is not an inconsistency.** Item 2 is purely
additive (a clause is *gained*; zero deletions). Item 1 replaces a transcript that was **never true of
any tree**, so it has no date-indexed truth-value to protect and freezing it would only preserve an
invitation to re-derive from a false record. Item 3 is the only one that would overwrite a defensible
past reading. That distinction is now written into the AC so a later auditor does not "consolidate"
the three verbs.

---

## §C — Technical design

> *ISO 15288 — Technical: Architecture Definition Process.*

### C.1 The resolution primitive

The guard today runs a hardcoded-h3, fixed-string **substring** count against the doc — **two**
defects in one line: the heading level is pinned to h3, and the match is substring rather than
whole-line. Both are replaced by a level-agnostic whole-line loop over h1 through h6, summing
`grep -cxF` (or `awk '$0 == s'`) per level.

Three forbidden alternatives and their failure directions are recorded in ADR-092 §Decision (1).
The design consequence that matters for @dev: **`N_HEADS` must be asserted equal to 1, never
"at least 1"**, and the sum is taken across all six levels so a heading's *depth* is irrelevant while
its *text* must match exactly.

### C.2 The tripwire and its scoped population

Measured guard-visible population (files carrying the backticked form), worktree at `9f6ddc2`:

| scope | count | files |
|---|---|---|
| repo-wide | **15** | includes 10 under `docs/` |
| **excluding `docs/` and `tests/`** | **5** | `.github/workflows/quality.yml`, `CHANGELOG.md`, `PROMOTE.md`, `scripts/canonicalize-scan.sh`, `skills/self-apply/SKILL.md` |
| **pin, post-CF-A** | **6** | plus `templates/skill-template/SKILL.md`, which enters the population only once CF-A backtick-wraps it |

**Why scoping does not weaken the control.** The tripwire's job is to detect a *new live pointer*
appearing. `docs/` occurrences are Class-B quotations inside historical records, and a new one is
authored every cycle by design; `tests/` fixtures are deliberately broken controls. Neither can host
a live Class-A pointer without violating a rule already stated elsewhere. The remaining surface —
workflows, scripts, skills, templates, ceremony files — is exactly where one would appear.

**Three implementation constraints:** the guard's own source file is inside the counted set and must
not be self-excluded by accident; the tripwire **counts files only** — it must never extract, resolve,
or re-expand a discovered anchor (§C.4); and the `docs/`/`tests/` exclusion is written as a **rooted
path prefix**, never as a bare `--exclude-dir=docs`. The two forms agree today only by accident —
measured, there are **zero** nested directories named `docs` or `tests` below the root — so a later
`examples/*/docs/` would widen the blind spot with the pin still reading 6.

**Self-drop-out, and why a named assertion is required (@security S1).** The first constraint above
guards the *exclusion filter*. It does not guard **the guard's own file ceasing to match the
pattern**, which is a different event with identical arithmetic. `quality.yml` carries the guard form
on **exactly one line** — the `N_CITES=` line — and only because both backticks sit on it. AC-S14
item 4b sends @dev into that same step with the `PARSER_FRAG1`/`PARSER_FRAG2` split idiom; applied to
the citation literal it breaks that line, the count reads **5** against a pin of **6**, and CI reds on
a **correct** implementation. The cheapest-looking fix is lowering the pin — which permanently removes
the guard's own source from surveillance. AC-S14 item 5 therefore asserts membership **by name**, with
its own diagnostic, so the failure names its cause instead of presenting as an off-by-one.

This is the third time in this cycle that a proposed control's failure mode is *"reds a correct
tree, and the obvious repair silently shrinks the guarded population"* — after C13's repo-wide pin and
C7's residue pin. It is worth naming as the recurring shape rather than the third coincidence.

### C.3 The sanitizer and its two-legged control

Order is binding: **strip, collapse, truncate at 80, then mark.**

```
ANCHOR_SAFE="$(printf '%s' "$ANCHOR" | tr -d '%:' | LC_ALL=C tr -cd '[:print:]')"
```

`printf '%s'` never `printf "$ANCHOR"` — the value is contributor-controlled and may contain `%`, and
passing it as a *format string* is the identical bug class to the Round-1 fixture defect. `LC_ALL=C`
is pinned because the collapse is otherwise locale-dependent (measured: `C` deletes the section sign,
UTF-8 preserves it). The lossy marker is **ASCII-only** and applied last.

**The control has two legs and both are required:**

| Leg | Assertion | What it proves |
|---|---|---|
| **A** | stdout MUST NOT contain `%0A`, and MUST NOT contain `::error::INJECTED-MARKER-7f3a` | the injection shape is neutralized |
| **B** | stdout MUST contain `INJECTED-MARKER-7f3a` | the anchor was **sanitized, not dropped** — the substantive decision of AC-S15 |

Leg B is what makes a "just delete the variable" implementation fail. Without it, the cheapest way to
pass Leg A is to destroy the only diagnostic a human gets when the guard fires.

The payload lives in a **committed fixture file**, never a shell one-liner: measured, the naive
`printf` form errors out in zsh and silently eats the percent in bash (`%0A` consumed as the
hex-float conversion, yielding `0X0P+0`), so the control would exercise a payload with no percent
sign in it — the one property it exists to test.

### C.4 Never glob-and-resolve

`docs/internal/security/security-review-v2.19.11.md` records historical security-test payloads **in
the guard-visible citation form**, whose anchors are shell interpolation, command-substitution and
quote-breakout strings. They are legitimate Class-B records and must not be edited.

**The count is FIVE, not three — corrected at Phase 2.1 by extracting them instead of recalling
them.** `` /usr/bin/grep -noE '`CONTRIBUTING\.md § [^`]+`' `` over that file returns **six**
occurrences, five hazardous and one benign:

| line | extracted anchor | hazard |
|---|---|---|
| `:193` | `${ANCHOR}\` | **shell parameter expansion**, inside a quoted `$( )` — previously uncounted |
| `:252` | `Worked-example authoring rules, rule 2` | none — an ordinary citation |
| `:504` | `${ANCHOR}\` | **shell parameter expansion**, inside a quoted `$( )` — previously uncounted |
| `:512` | `$(touch /tmp/AC3_PWNED)` | command substitution |
| `:516` | `x"; touch /tmp/AC3_PWNED2; echo "` | quote breakout + command chaining |
| `:520` | `$(id)` | command substitution |

The earlier "three" counted only the `$( )` and breakout payloads at `:512`, `:516`, `:520`. It
**missed `:193` and `:504`**, which are recorded quotations of the guard's *own source line*
(`N_CITES="$(grep -cF "\`CONTRIBUTING.md § ${ANCHOR}\`" "$SCRIPT" || true)"`). Those two are the more
insidious members of the class: they do not look like attack payloads, they look like documentation —
yet re-expanding one in a shell context expands `${ANCHOR}` and re-enters `$( )` exactly as the
overtly hostile three do. **A rule derived from the three would have been sized to payloads that
announce themselves.**

Consequences: the tuple list is **enumerated, never globbed**; the tripwire **counts only**; and any
tooling that must handle a discovered anchor passes it as a **quoted argument to a fixed-string
matcher** — never into a regex, never back through a shell.

This supersedes the previously-carried rationale for enumeration (that a glob would redden the
`f2-*` canonicalization fixtures). Re-measurement shows those fixtures carry the broken citation
**unbackticked**, so the extraction regex cannot see them at all. A glob's actual damage would be
sweeping `docs/`, where `docs/architecture.md` alone carries 2 distinct anchors and would fail the
distinct-anchor assertion.

### C.5 W1 fixtures are generated, not committed

Re-measured: the existing pipe-injection fixtures are written into a `mktemp -d` directory at CI
runtime by inline `awk` generators, then compared with `cmp -s` against the real registry by a no-op
setup guard (`for f in reflow pipe-sa pipe-pg deleted`). **W1 therefore adds no committed fixture
files** — 3 generator lines, 3 self-test legs, and 3 new entries in the setup-guard list, all inline.
This is what keeps W1 compliant with the "stay INLINE, never `scripts/`" constraint.

### C.6 Phase-4 execution discipline — hold commits, push by P-row (@dev FINDING 2)

**This is an instruction to @dev, not background.** It cuts directly against ordinary habit (commit,
push, watch CI), and following the habit reds CI on correct work.

**Rule: within a push group, commit locally and DO NOT PUSH until every commit in that P-row is
ready.** `docs/spec.md` §Push sequence defines the groups P0–P4; the push tip is what CI evaluates, so
intermediate commit-level reds are structurally invisible and acceptable, while **no push-level red
is acceptable.**

**Why it is load-bearing rather than tidy.** `registry-sha256-check` recomputes each hash against
**every row on every run** — it is not incremental and has no notion of "this commit didn't touch that
skill". So a byte change to `skills/self-apply/SKILL.md` pushed *without* its paired field-8 bump in
the same push produces a genuine, correct RED against a change that is itself correct and merely
half-landed. Two of this cycle's rows are exposed:

| push | byte change | paired cell | consequence if pushed apart |
|---|---|---|---|
| **P1** | CF-A edits `skills/self-apply/SKILL.md` | `self-apply` field 8 | hash drift RED |
| **P3** | S5a edits `skills/pull-updates/SKILL.md` | `pull-updates` field 8 | hash drift RED |

Commit-level pairing is optional; **push-level pairing is mandatory** (`docs/spec.md` §sha256 plan).
Regenerate via `scripts/registry-hash.sh <slug>` — never by hand, and never by copying the hash out of
CI error text, which is how a wrong-but-consistent value gets laminated in.

**One consequence worth expecting so it is not misread as a new defect:** inside
`registry-sha256-check`, W1's step runs *before* the sha256 drift step, so a W1 fixture error during
P2/P3 aborts the job before the hash diagnostic ever runs. Fix W1 first, re-push, then read the hash
result. A green W1 is a precondition for the hash diagnostic being meaningful, not merely for it being
green.

### C.7 Anti-pattern scan

| # | Anti-pattern | Finding |
|---|---|---|
| 1 | God class/module | **Present, accepted.** The anchor-guard step grows to ~4 responsibilities (extract, resolve, self-integrity, tripwire). Splitting it would break the Interference Constraint, which is the higher-value invariant. Retirement path: ADR-092 §Maturation Path option (a). |
| 2 | Circular dependencies | None. S14 and W1 are in different jobs with no shared shell state. |
| 3 | Leaky abstraction | None introduced. |
| 4 | Premature optimization | None. |
| 5 | Over-engineering | **Actively resisted.** The full census was declined; the tripwire was scoped down rather than dropped. |
| 6 | Tight coupling | **Present by necessity and named:** S14 creates S15's population. Recorded as the Interference Constraint. |
| 7 | Missing separation of concerns | None. |
| 8 | N+1 query | N/A — no data layer in this repository. |
| 9 | Destructive migration | **None, explicitly.** No registry row added or removed (30 = 30); ADR bodies appended, never edited in place; append-only records discharged by cross-reference. |
| 10 | SoS interface discontinuity | N/A — single-project. |
| 11 | Cross-project tight coupling | None. |

---

## §D. File-by-File Implementation Plan

> *ISO 15288 — Technical: Design Definition Process.*

| # | File | Change | Owner-AC |
|---|---|---|---|
| 1 | `.github/workflows/quality.yml` | Rebuild the anchor-guard step: 4-tuple enumeration, per-tuple distinct/citation counts, whole-line level-agnostic matching, both self-integrity assertions, scoped tripwire (pin 6), `, rule 2` assertion, `ANCHOR_SAFE` sanitizer, sink handling. Widen `GATED_SLUGS` to 5 with 3 generator lines, 3 legs and 3 setup-guard entries. Add in-workflow proof items (a) through (h). **INLINE only.** | AC-S14, AC-S15, AC-W1 |
| 2 | `skills/self-apply/SKILL.md` | Correct the citation anchor; relocate `, rule 2` outside the backticks. | AC-CF-A |
| 3 | `PROMOTE.md` | Correct the citation anchor; relocate `, rule 2` outside the backticks. | AC-CF-A |
| 4 | `templates/skill-template/SKILL.md` | Backtick-wrap the citation, add the space after the section sign, move the trailing period outside. | AC-CF-A |
| 5 | `curated-skills-registry.md` | Bump `self-apply` and `pull-updates` sha256 cells; rewrite `self-archive` and `self-upgrade` description cells. No row added or removed. | AC-CF-A, AC-S5b, AC-S11 |
| 6 | `skills/pull-updates/SKILL.md` | Add the malformed-registry-row refusal clause. | AC-S5a |
| 7 | `tests/pull-updates-firing-controls.md` | NEW. Record the real invocation: model, version, date, verbatim refusal output. | AC-S5b |
| 8 | `tests/fixtures/citation/nc5-prefix-truncated.md` | NEW. Prefix-truncation negative control fixture. | AC-S14 (NC-5) |
| 9 | `tests/fixtures/citation/s15-injection-control.md` | NEW. Injection-control payload, as a file so no shell `printf` can eat it. | AC-S15 |
| 10 | `docs/risk-register.md` | Flip `v2.19.11-PULL-ROW-1` to CLOSED, naming model drift and per-slug variance as residuals. Only on AC-S5b's recorded invocation. | AC-S5b |
| 11 | `docs/architecture.md` | Append the B0 amendment record (role axis, tie-breaker, discharge rule, mechanism naming, 3 superseding cross-references, historical-example note). **Append-only WITH EXACTLY ONE IN-PLACE EDIT, named here so this row does not contradict the AC it carries: ADR-088's index-row `Status` cell gains a pointer to the new amendment (AC-B0 item 6), in the same form that cell already carries from `9a9961f`. That is the only byte outside the appended block that changes. ADR bodies and the index row's three-decision summary text are NOT edited.** | AC-B0 |
| 12 | `docs/design-v2.19.11.md` | Three corrections: RED-d transcript, Leg-2 credential-leak clause, `Decision (3)` mis-pointer. | AC-CF-B |
| 13 | `CHANGELOG.md` | Release notes for v2.19.13. | release hygiene |
| 14 | `VERSION` | `2.19.12` to `2.19.13`. | release hygiene |
| 15 | `README.md` | Version badge `2.19.12` to `2.19.13`. | release hygiene |

**Already landed at Phase 1 by @architect (not @dev's work):** `docs/spec.md` (finalized spec +
Condition Ledger), `docs/architecture.md` (ADR-092 body + index row), `docs/design-v2.19.13.md`
(this document). `docs/architecture.md` appears in both lists because Phase 1 appended the ADR and
Phase 4 appends the B0 amendment — two separate appends to an append-only file, no conflict.

**Files explicitly NOT written:** anything under `scripts/` (ADR-090 forbids it and it escalates
ceremony), and any new row in `curated-skills-registry.md`.

```yaml
scope_allow_delta:
  add:
    - .github/workflows/quality.yml
    - skills/self-apply/SKILL.md
    - skills/pull-updates/SKILL.md
    - templates/skill-template/SKILL.md
    - tests/pull-updates-firing-controls.md
    - tests/fixtures/citation/nc5-prefix-truncated.md
    - tests/fixtures/citation/s15-injection-control.md
    - docs/risk-register.md
    - docs/architecture.md
    - docs/design-v2.19.11.md
    - docs/spec.md
    - PROMOTE.md
    - CHANGELOG.md
    - README.md
    - VERSION
    - curated-skills-registry.md
  remove: []
```

**This block is a no-op for scope enforcement on this cycle — and the reason recorded here through
Phase 2 was the wrong one.** It read: *"`claude-cowork-config` is an external registered project;
`.claude/agents/dev.md`'s `scope_allow` governs Council-side writes and is not in this cycle's
scope."* That is a claim about *jurisdiction*, and it is not what the guard does. **Corrected at
Phase 2.1 by reading the guard instead of citing it** — `scripts/guards/scope-check.sh:708-712`,
verbatim this session:

```
708  # --- External project: allow all writes within the project root ---
709  if [ -n "$ACTIVE_PROJECT_PATH" ] && [[ "$FILE" == "$ACTIVE_PROJECT_PATH/"* ]]; then
710    # External project mode: dev and devops can write freely within the project
711    # (project's own guards handle finer-grained restrictions)
712    exit 0
713  fi
714  # --- Check scope_allow.standard[] patterns ---
```

**The derivation:** `:709` returns `exit 0` at `:712` — **before** the `scope_allow.standard[]` loop
at `:714` is ever entered. `dev.md`'s patterns are therefore not *out of jurisdiction*; they are
**never reached**. Every path in the block above lies under the project root, so the carve-out fires
on all 15 and the block cannot bind anything. That is why it is a no-op.

**The precondition, stated because the carve-out is conditional and the condition is not free.**
`:709` fires only while `ACTIVE_PROJECT_PATH` resolves to this project's root. Two independent
resolvers can supply it: the session-pin/registry path (`:396`), or the ADR-207 file-location-derived
fallback (`:412`), which by its own guard `[ -z "$ACTIVE_OVERRIDE" ]` is **skipped whenever a session
pin is set**. Measured this session, the guard's own stderr:

```
scope-check: ACTIVE override (source=pin value=claude-cowork-config registry=self agent=architect)
```

So the pin is currently carrying it and the registry's `active_project` is `self` — the file-derived
fallback is inert right now *because* the pin is set. Both resolvers point here, so writes land; but
a pin re-aimed at another slug would take `ACTIVE_PROJECT_PATH` with it, `:709` would stop firing,
and these 15 paths would fall through to `:714`. **A Phase-4 write refused with a scope error is this
precondition breaking — it is not a signal that the file plan is wrong.**

**BINDING: do NOT widen The-Council's `.claude/agents/dev.md` to "fix" such a refusal.** The patterns
at `:714` are matched with `echo "$REL_FILE" | grep -qE "$PATTERN"` — **unanchored substring
regexes** (`dev.md` today carries bare `'scripts/'`, `'package\.json'`, `'tsconfig'`). Adding this
cycle's plan files there would not scope a permission to this project; it would grant it
**repo-wide**. **Four** of the 15 entries name files that exist in The-Council itself — measured this
session, not assumed: `docs/architecture.md`, `docs/spec.md`, `README.md`, `CHANGELOG.md` present;
`VERSION` and `docs/risk-register.md` **absent** (a first draft of this paragraph said "six" and
named those two; the count was corrected by running `ls` against the hub). So the "fix" hands @dev
write access to the hub's own architecture record, its live spec and its release notes in order to
satisfy an external project's file plan. **The hazard does not depend on that count** — an unanchored
pattern also grants every path those files *would* occupy later; the four are simply the ones already
sitting there today. That is a privilege escalation wearing the costume of a
scope correction. The correct remedy is always to restore the pin, never to widen the allow-list.

The block is recorded because ADR-115 requires its presence (omission is a parse error), and every
entry carries a non-wildcard prefix — `.github/`, `skills/`, `templates/`, `tests/`, `docs/`, or a
named root file. No entry is a bare wildcard.

---

## §E — B1 verification

> *ISO 15288 — Technical Management: Decision Management Process.*

### B1 verification (ADR-127 / C29)

**B1 verification: PASS @ 2026-08-27T06:21:00Z** — `scripts/guards/scope-allow-verify.sh` exit **0**.

```
VERIFY-RESULT: PASS — all 14 plan file(s) covered (72 scope_allow patterns + 16 delta entries)
```

Per-file: `.github/workflows/quality.yml`, `tests/**` (3 files), `docs/architecture.md`,
`docs/design-v2.19.11.md`, `CHANGELOG.md`, `README.md` resolved COVERED-BY-REGEX; the remaining 6
resolved COVERED-BY-DELTA.

**One tokenizer note, recorded rather than left as a silent gap:** the verifier extracted **14** of
the §D table's **15** rows. `VERSION` is not extracted, because it carries neither a path separator
nor a dot-extension and so does not match the tokenizer's file-shaped pattern. It **is** present in
`scope_allow_delta.add[]`. This is a verifier tokenizer limitation, not a coverage gap, and it does
not affect the PASS — but a reader comparing "15 rows" against "14 covered" would otherwise be
looking at an unexplained discrepancy.

---

## Classification Re-Run

*Mandatory per `docs/pipeline-policy.md` §PostOQClassificationReRun — required even when the answer is CONFIRMED. Fail closed if absent.*

**Result: CONFIRMED — SECURITY-SENSITIVE, Tier A. COMPLIANCE-SENSITIVE = NO.**

Re-evaluated against the **final** §D file list after all condition resolution, not against the
Phase-0 list.

**Rationale.** The final file list still contains `.github/workflows/quality.yml` — a CI guard
surface — plus `curated-skills-registry.md` sha256 cells and `skills/pull-updates/SKILL.md`'s safety
prose, each of which independently carries Tier A on the standing basis used at v2.19.12. Condition
resolution **added** files (two committed control fixtures under `tests/`, and
`docs/design-v2.19.11.md` gained a third correction) but removed none, and no addition is of a lower
ceremony class. Classification therefore cannot move downward, and nothing in the final list
introduces external content, third-party code, license obligations, or personal data, so
COMPLIANCE-SENSITIVE remains NO.

**No upward flip.** Tier A is already the highest ceremony tier in this repository, so Phase 2 cannot
be skipped and no orchestrator halt is triggered.

**Ceremony owed:** worktree branch (active) + PR + **one @security Guard Change Summary at Phase 2**
(owed then, not at Phase 0.D). Squash-merge only, after owner approval on the GCS. Never
fast-forward.

**Standing-rule question deliberately left open** (it is an owner decision, not a reviewer's or an
architect's): whether this target repo should carry its own standing classification table, so that a
future cycle touching only `quality.yml` does not re-litigate Tier A/B from first principles. The
Council's own policy does not transfer here — its rationale cites a workflow file that does not exist
in this repo. Recorded, not decided.

---

## §F — Residuals carried forward

> *ISO 15288 — Technical Management: Risk Management Process.*

| id | Residual | Severity | Disposition |
|---|---|---|---|
| `CF-v2.19.13-CITATION-CENSUS` | Guarded population is smaller than the obligated population; nothing reconciles them. **Corrected — this figure previously read 3, and predated this cycle's own design doc joining the population it counts.** `git archive HEAD` + `` /usr/bin/grep -rlE '`CONTRIBUTING\.md § [^`]+`' `` over `docs/*.md`, minus the `.gitattributes` export-ignore set (`docs/internal/`, `docs/spec.md`, `docs/retro.md`, `docs/patterns.md`): **4** shipping files carry guard-form citations outside the 4-tuple — `docs/architecture.md`, `docs/design-v2.19.10.md`, `docs/design-v2.19.11.md`, `docs/design-v2.19.13.md` (this file, via `:562`'s quotation of the guard's own source line). **Not re-quoted as a bare fact, per the `CONTRIBUTING.md`-hardcoding row's own precedent below: this is the repo-wide, docs/-scoped figure, not the tripwire's stable scoped one (`TRIPWIRE_PIN=6`, excludes `docs/`/`tests/`), and it grows by construction — any cycle whose own `design-vX.Y.Z.md` quotes the guard's citation form as documentation joins the population the moment it's authored, exactly as this file did. Re-run the measurement for the live count rather than trusting this digit next cycle.** | MEDIUM | Named, not scheduled. Retirement path = ADR-092 §Maturation Path option (b). |
| `CF-v2.19.13-GITHUB-CLASSA` | `.github/CODEOWNERS` and `.github/workflows/release-assets.yml` carry **broken Class-A pointers today**. Both unbackticked (invisible to the guard by construction); one anchor does not exist on any single line. Both export-ignored. | MEDIUM | **Deferred by decision, named not silent.** Repairing them requires backtick-wrapping first, and one requires un-wrapping a two-line comment. |
| `CF-v2.19.13-DECISION3-RESIDUE` | 3 remaining `Decision (3)` mis-pointer loci (`security-audit-v2.19.11.md` x2, `docs/retro.md` x1). | LOW | Deferred **with a stated inclusion test** so the next auditor can re-derive the set. All export-ignored, all in append-only records. |
| `S10` | `CONTRIBUTING.md`'s malformed self-citation — no space after the section sign, invisible to the extraction regex by construction. | LOW | Named carry-forward, not scheduled. Maintainer surface (S13). |
| `A15` | Registry-row-count pin is defeatable by a compensating pair. | LOW | Stays deferred. No row added this cycle (30 = 30, re-confirmed). |
| `CF-v2.19.13-MEMBERSHIP-NC` | **The tripwire's named-membership assertion (AC-S14 item 5) has no committed negative control.** Its *count* leg fails arithmetically in both directions, but the **distinct diagnostic** — *"the anchor guard's own source file has dropped out of the counted population"* — is never itself exercised, because the only faithful trigger is editing the real guard's citation line. @qa (Phase 2.D) proposed a self-test against a **mocked file list**. | LOW | **Named residual — deliberately NOT this cycle, and the discriminator is stated so the deferral can be audited.** Unlike proof item (c), which admitted a **false GREEN** and was therefore fixed this cycle, this gap admits **no false GREEN at all**: on self-drop-out the count still reads 5 against a pin of 6 and CI still goes RED. What is unproven is only the *quality of the message*, not the firing. Deferring it is an ergonomics debt, not an assurance gap — which is precisely the line that made (c) mandatory and makes this optional. Two further grounds: fixturing it requires **parameterizing the membership predicate to accept an injected file list**, which is ADR-092 §Maturation Path option (a) applied to a second call site — work this cycle explicitly defers; and the injected list would exercise the predicate but **not** the `grep -rl` population-generation that feeds it in production, so the control would be partial even once built. **Revisit trigger:** the first time a self-drop-out actually occurs and is misdiagnosed as an off-by-one, or whenever option (a) is taken up — at which point the predicate is already a function and the control costs one leg. |
| GNU/BSD | **Corrected at Phase 1.1 — the earlier blanket claim was wrong.** No GNU `grep`, `awk` or `sed` and no container runtime on the authoring host, so matching-mode and extraction-regex results are BSD-only. **But GNU coreutils 9.11 IS present** (`gsort`, `gtr`), covering both binaries the locale hazards live in. | **MEDIUM** until CI (was HIGH) | Items (a)(b)(c)(d)(e)(h) still closed only by `ubuntu-latest` on this cycle's own PR, stated as **untested**. Items (f) and (g) **partially closed locally** under GNU coreutils (§B.7); residual there is glibc-versus-macOS collation tables, not absence of a binary. |
| Lint surface on `tests/**.md` | The 3 new fixture/record files land inside markdownlint's `**/*.md` glob and lychee's `--offline "**/*.md"`; `tests/` is excluded from neither. | LOW | Named in `docs/spec.md` Technical Constraints §Lint surface, with the active rule set measured (`MD041` is **disabled**; `MD047`/`MD009`/`MD012`/`MD010` are not). Repo's own pre-push CI-pitfall class. |
| `CONTRIBUTING.md` hardcoding | ADR-092 pins one target document where ADR-090's citation form is generic. Measured latent. **Re-run at Phase 2.1, and the restatement had to be done twice — the first attempt reproduced the defect it was correcting.** (i) The row previously read *"all 33 guard-visible"*, which conflated two populations: openings and *closed* openings are not the same set. (ii) The corrected figure — 33 openings / 32 guard-visible — was **itself already stale when written**, because writing it added two more occurrences to `docs/`. **Repo-wide, this number counts the sentence that reports it.** Measured series, `git grep` at **pinned revisions only**: **29 / 29** at `9f6ddc2` (cycle base) → **33 / 32** at `dd8eab2` (Phase 1.1 close — the figure the 2.D condition carried, correct at that commit and stale by the next one). A third data point proved the mechanism in both directions: this row's first draft *added* two occurrences (→ 35 / 34) and its second draft *removed* one again (→ 34 / 33), purely by changing how the row quotes the pattern. **No current repo-wide value is quoted here, deliberately: quoting it changes it.** Re-run the command against a named revision if you need the figure. **The load-bearing figure is therefore the SCOPED one, and it is stable: excluding `docs/` and `tests/`, the count is 9 openings / 9 guard-visible — identical at `9f6ddc2` and at Phase 2.1, unmoved by four commits of documentation.** That is the population the tripwire pins, and this is ADR-092 §Decision (3) demonstrated on itself: *a pin whose population includes artifacts the cycle itself creates is not a control, it is a scheduled false alarm.* The repo-wide figure is a description, never a pin. All occurrences target `CONTRIBUTING.md`; **zero** target anything else — that claim is population-independent and is the one the hardcoding risk actually rests on. The only unclosed opening is `docs/spec.md:9837` (closing backtick wraps to the next line — invisible to line-based extraction by construction, and inside `docs/` regardless). **This row deliberately does not reproduce the literal opening form**, quoting only the escaped regex `` `CONTRIBUTING\.md § [^`]+` `` which does not match it — otherwise the row would increment its own counts a third time. **Do not match this row on the bare digits "32/33"**: `docs/spec.md:7346` carries an unrelated **v2.19.8 job-count** pair (*"`quality.yml` currently has **32** jobs … This job makes **33**"*), which is **Class B**, **true when written**, **correctly frozen**, and must not be "reconciled" with this row. Two different 32→33 pairs, two different populations, one of them historical. | LOW (latent) | Named under ADR-092 §Risk knowingly accepted, with a revisit trigger on the first non-`CONTRIBUTING.md` target. Goes live in triplicate — guard, tripwire and census blind at the same instant — so it is stated as a re-runnable measurement, not an assurance. |
| `%0A` decoding | GitHub Actions' handling of percent-encoded newlines at error/stdout sinks remains **UNRUN by anyone**. | INFO | Explicitly **not** load-bearing for AC-S15's correctness, and less so after sanitization. Not promoted to fact. |
| Model drift + per-slug variance | AC-S5b is a one-time invocation, 1 slug of 3. | MEDIUM | Both named in the risk-register CLOSED text. The sha256 gate makes the *text* durable, not a future model's behaviour. |
| Anchor-guard step responsibility count | The step now carries ~4 responsibilities. | LOW | Accepted; splitting would break the Interference Constraint. Retirement path = ADR-092 option (a). |

---

## Closing note

The cycle's own standing rule — *a number inherited from a reviewer is not verified until the
recipient re-runs it* — was applied to the conditions file that mandated it. **Four of twenty
conditions were falsified by that re-run**, and each would have shipped a defect if implemented
faithfully: a pin that REDs on a correct tree, a deferred-count that is arithmetically impossible
against its own two neighbouring figures, a truncation marker eaten by its own pipeline, and a
tie-breaker that mandates rewriting history. Three of the four are the *same* failure class the
condition immediately above them was written to prevent.

That is the 14th generation of this project's named failure mode, and it was found in the document
whose purpose was to end it. The corrective is not more prose — it is ADR-092 §Maturation Path
option (a): make the primitive a single shared function so there is one place to be right, instead of
a new place to be wrong in every remedy.

**Phase 1.1 addendum.** The deliberation round produced **zero blockers** and thirteen sentence-level
conditions, and the same rule was turned on them: **two did not survive re-measurement** (§B.6, §B.7),
and one defect neither reviewer raised was found by reading a cited ADR instead of citing it (§B.8 —
ADR-088 numbers its own decisions two different ways, which is the root cause of the entire
`Decision (3)` census and which decided @dev's FINDING 1 in §B.9). A third self-inflicted instance was
caught *while writing the fix for* @security S6: the first draft of ADR-092's risk paragraph
illustrated the `CONTRIBUTING.md` hardcoding with a specimen citation naming another file, which made
that paragraph's own *"zero target any other file"* measurement false by its own hand. Re-running the
count found it at 1; the illustration was rewritten as prose and the count returned to 0.

The pattern across all three is one thing: **a claim about the repository, written from inference and
never re-run against it.** It does not matter whether the author is a reviewer, a prior phase, or the
same agent forty minutes earlier. The only control that has caught any of them is running the command.
