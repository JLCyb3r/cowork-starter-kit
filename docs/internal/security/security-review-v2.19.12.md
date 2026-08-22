# Security Review — v2.19.12 "S4 report-egress retrofit"

## Phase: 2
## Date: 2026-08-23T00:00:00Z
## Status: PASS WITH CONDITIONS — 0 CRITICAL, 2 BLOCKER

**Branch:** `release/v2.19.12-s4-report-egress` @ `83f317c`
**BASE:** `b43fa523f995736af70c483930935aed62b6a42b`
**Classification:** SECURITY-SENSITIVE — Tier A. **CONFIRMED.** COMPLIANCE-SENSITIVE = **NO. CONFIRMED.**
**Reviewer:** @security (opus), independent execution. Nothing below is accepted on @architect's transcripts.

> **Grep flavour behind every count in this document.** Probed with `type -a grep`:
> `grep` is a zsh function from `/Users/macbookpro/.claude/shell-snapshots/snapshot-zsh-1787438881566-4nji8l.sh`
> (a **ugrep** shim invoking `-G --ignore-files --hidden -I --exclude-dir=.git …`), then `/usr/bin/grep`
> = **BSD grep 2.6.0-FreeBSD**. **Every load-bearing count below was taken with `/usr/bin/grep`, by
> absolute path.** GNU grep — the flavour CI runs — remains unmeasured; see F-I1, which measures the
> shim/BSD gap for the first time and finds it **real and opposite in direction**.

> **Method.** A disposable clone at the branch tip (`git clone --no-hardlinks`); the live repo was never
> mutated. Every assertion carries `POPULATION(invariant)` / `POPULATION(proxy)` and one input in each
> half of the symmetric difference. Negative controls run before any green was trusted — the first
> AC-7 run in this session returned CLEAN with `moveset.list` **never created** (`PATTERNS LOADED: 0`),
> a check that could not fail; it was discarded and re-run with `PATTERNS LOADED: 14` printed.

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | CRITICAL | 2 | configuration | **BLOCKER.** AC-7's repaired form has no executable artifact and no designated executor. `awk` appears **0×** in `docs/design-v2.19.12.md`; §D assigns AC-7 no implementation home; the spec's bash block stops exactly at the partition — the locus of four defect generations. Every future runner re-derives it from prose. |
| S2 | CRITICAL | 2 | configuration | **BLOCKER.** The `--- /dev/null` rule permits additions in **any** file created this cycle, including public ones. Executed: a new `docs/report-index.md` republishing all 14 old paths is `(ok+)` under AC-7, `S4 PASS — 0 of 419` under AC-4, and leaves AC-6's delta at exactly 14. All three controls green. |
| S3 | WARNING | 2 | schema | ADR-088 flipped to ACCEPTED and ADR-037's index row rewritten to past tense at **Phase 1**, before the Phase 3 gate; the compensating control binds @qa at **Phase 5**, after it. The descope-at-gate event that created ADR-088's own deferral record is still ahead of this cycle. |
| S4 | WARNING | 2 | logging | REDUCED GUARANTEE **under-states** the dangling-citation count: stated `~56/7`, measured at this branch base on the real shipping tree **66 lines / 8 files**. The 10-line delta is the cycle's own `docs/design-v2.19.12.md`. |
| S5 | WARNING | 2 | logging | REDUCED GUARANTEE names `docs/project-audit-v2.6.1.md` as *the* out-of-scope internal artifact. The shipping set is larger: **7** `docs/design-v*.md` after this cycle (6 at BASE) plus `docs/risk-register.md`. This cycle's own design doc ships a NOT-RUN list enumerating 8 untested areas of the release-hygiene controls. |
| S6 | WARNING | 2 | configuration | Deletion-side attribution degrades to `/dev/null`. Executed on a modified-movee tree: `MINUS /dev/null 5`. Detection sound; diagnosis lost. `^-` lines must be attributed from `--- SRCX/`, not `+++ DSTX/`. |
| S7 | WARNING | 2 | configuration | The spec's `3925 → 119` diff-size figures are from a **synthetic** tree, not this branch. Measured here: old form **4664 / 36**, repaired form **858 / 0**. A verifier reproducing the spec's numbers gets a mismatch — the spurious-BROKEN trigger AC-4 itself warns about. |
| S8 | INFO | 2 | dependency | Shim/BSD flavour gap measured for the first time, and it is **opposite**: `grep -F -f` with a blank pattern line → **1** under BSD, **0** under the ugrep shim. GNU remains unmeasurable here (no `ggrep`, no Homebrew grep, no docker/podman/colima/nix — probed). |
| S9 | INFO | 2 | configuration | Three NOT-RUN items closed by execution this session (modified movee; `diff.renameLimit` vs AC-7; the cycle's own Phase-2 report vs AC-7). All three pass. |
| S10 | INFO | 2 | dependency | No dependency manifest in this repo (`npm audit` N/A). No secrets in the branch diff. |

**Scope-Allow Re-Walk: N/A** — `scope_allow_delta` targets an external registered project governed by its own pre-commit hook, not a Council-side `scope_allow` block. The `add[]` list in §D.4 was read and covers the 14 destination paths and `docs/design-v2.19.12.md`; it does **not** cover this report's path — see S1's remedy note.

---

## Task 1 — Independent ruling on @architect's AC-7 repair

**RULING: the repair is sound in the two directions it was tested, and I reproduced both from scratch.
It is defective in a third direction it was not tested in. Two BLOCKERs, both with one-line remedies.**

### 1.1 What I reproduced (re-implemented, not inherited)

I wrote my own stateful partition (`awk`, `index()` matching, `--- ` / `+++ ` header tracking) and built
a full correct-cycle end state on top of the **real branch tip** — not a synthetic tree: 14 `git mv` in
one commit, AC-5's complete edit (three `AFILE` repoints + the false LA-03a annotation corrected),
a `CHANGELOG.md` append, a `quality.yml` append.

```
$ git -C sim show --format= --name-status --find-renames=100% <r3>  | awk '{print $1}' | sort | uniq -c
  14 R100                       <- AC-6 single-commit leg: R100=14, A/D/M=0

$ /usr/bin/grep -c ... ; git diff --numstat -- scripts/verify-ledger-annotations.sh
3	3	scripts/verify-ledger-annotations.sh      <- AC-5 numstat, independently 3/3
positional new (MUST be 3): 3
positional old (MUST be 0): 0

$ AC-7, half A (correct cycle)
PATTERNS LOADED: 14
REMOVED-LINE VIOLATIONS (a): 0
ADDED-LINE VIOLATIONS (b): 0
permitted: removals 3, additions 18
   (ok+) CHANGELOG.md                                             1
   (ok+) docs/design-v2.19.12.md                                 14
   (ok+) scripts/verify-ledger-annotations.sh                     3
   (ok-) scripts/verify-ledger-annotations.sh                     3
VERDICT: exit 0 CLEAN
```

`permitted: removals 3, additions 18` matches @architect's reported figure exactly, derived independently.

```
$ AC-7, half B (genuine removal seeded inside docs/internal/qa/qa-report-v2.19.10.md:399,
                plus an addition seeded in the public docs/how-it-works.md)
REMOVED-LINE VIOLATIONS (a): 1
   MINUS docs/internal/qa/qa-report-v2.19.10.md                   1
ADDED-LINE VIOLATIONS (b): 1
   PLUS  docs/how-it-works.md                                     1
VERDICT: exit 1 VIOLATION
```

**The half-B blind spot is genuinely closed.** `docs/internal/**` is back inside the population, and the
removal the pathspec form was structurally unable to see is caught. Confirmed, not accepted.

**D1's diagnosis reproduces**, with tree-specific magnitudes (see S7):

| Form | diff lines | movee-naming ± lines on a **correct** cycle |
|---|---|---|
| old (`:(exclude)` pathspecs) | **4664** | **36** |
| repaired (`--find-renames=100%`, no exclude) | **858** | **0** |

### 1.2 BLOCKER S1 — the repair exists only as prose

`/usr/bin/grep -c awk docs/design-v2.19.12.md` → **0**. §D (File-by-File Implementation Plan) lists
D.1 moves, D.2 the ledger script, D.3 `quality.yml` (AC-4 only), D.4 new/appended files. **AC-7 appears
in none of them.** The spec's AC-7 bash block ends at:

```bash
git diff --find-renames=100% --src-prefix=SRCX/ --dst-prefix=DSTX/ "$BASE".."<branch-tip>"
```

— and then hands the partition to four English bullets. The partition is precisely where D4 was found,
where the population lives, and where four generations of defects have landed. A control whose
executable half is prose will be re-derived by every runner. I re-derived it and reproduced the numbers,
which is evidence the prose is *good* — it is not evidence that the next person's re-derivation will be.

> `POPULATION(invariant)` = the exact program @architect executed and measured 35 → 0 with.
> `POPULATION(proxy)` = whatever a reader reconstructs from §E.3's two bullets.
> The symmetric difference is unbounded, because the proxy is not a program.

**Remedy (cheap, no new surface):** paste the exact executed partition script **verbatim** into
`docs/design-v2.19.12.md` §E.3 as a fenced block, and name its executor and phase in the AC text
("@qa runs this at Phase 5, pre-merge, locally"). If a `scripts/` home is preferred, the cycle is
already Tier A and already touches `scripts/` — but the verbatim block is sufficient and adds nothing
to the release surface.

### 1.3 BLOCKER S2 — the case where `--- /dev/null` is wrong, constructed and executed

> `POPULATION(invariant)` = additions permitted in the four append-only surfaces (AC-7(b) as stated).
> `POPULATION(proxy)` = four append-only surfaces **∪ `scripts/verify-ledger-annotations.sh` ∪ every
> file created by this cycle**, regardless of where it lives or whether it ships.

The proxy's exception set is strictly larger than the invariant's, and the extra region is not empty
of dangerous inputs. I built one that a well-meaning @dev would plausibly write:

`docs/report-index.md` — a new, **public**, shipping document created this cycle, listing all 14
pre-move paths under the heading *"The following internal reports were relocated in v2.19.12"*.
It is the natural thing to write instead of AC-8's note. Executed against all three controls:

```
AC-7 :  (ok+) docs/report-index.md   14          <- PERMITTED. Silent.
AC-4 :  TOTAL: 419  |  AC-4 LEAK MATCHES: 0      <- "S4 PASS - 0 of 419". Blind: report-index does
                                                     not match ^docs/(qa-report|security-audit|security-review)-
        tar -tf | grep -n 'report-index'  ->  40:docs/report-index.md   <- and it ships.
AC-6 :  PRE=432  POST=418  DELTA=14  leak@R3=0   <- PASSES. The file lands outside the r3 commit,
                                                     so the delta control never sees it.
```

**All three controls return green on a tree that publicly republishes the complete index of the 14
internal reports the cycle just withdrew.** The reports themselves do not ship — the cycle's headline
guarantee holds — but AC-7's *stated* invariant (b) is violated, silently, by its own proxy.

This is not hypothetical drift: the same widening quietly blesses (i) a new file under `tests/fixtures/`
citing old paths, which would break the repo's own suite (NOT-RUN #5), and (ii) any new `scripts/` or
`.github/` file referencing a moved report at its old path. **It is also the mechanism that made *this
very report* pass AC-7** — see §1.5. The widening is easy to miss precisely because its common case is
benign.

**Sub-case where defence-in-depth does hold, stated so the remedy is not over-scoped:** a movee
*re-created at its old path* is also `--- /dev/null` and also permitted by AC-7 — but AC-4 catches it
(it matches `LEAK_PATTERN`) and AC-6's `R100` drops below 14. **AC-4 is load-bearing for that sub-case
and must not be weakened while S2 is open.**

**Remedy (cheap, no population change, no new machinery):** the control MUST **print the permitted-
additions bucket by filename** — my implementation already does, and it is what made S2 visible — and
the AC text MUST state: *any file in that bucket other than the four append-only surfaces,
`scripts/verify-ledger-annotations.sh`, and paths under `docs/internal/` is a **reviewer STOP**, not a
pass.* That converts a silent permission into a loud one and matches AC-7's existing posture
("a match is a candidate, not a violation") in the inverse direction. It costs one line of AC text and
one line of output.

### 1.4 S6 — deletion-side attribution degrades to `/dev/null`

Executed (modified-movee tree, NOT-RUN #3):

```
REMOVED (a): 5
   MINUS /dev/null                                                5
VERDICT: exit 1 VIOLATION
```

For a whole-file deletion git emits `--- SRCX/<path>` and `+++ /dev/null`. A partition that takes `cur`
from the `+++` header — which is what design §E's method paragraph describes ("tracking `+++ DSTX/`
headers") — attributes every deletion-side violation to `/dev/null`. **Detection is sound; the exit code
is correct; only the diagnosis is lost.** But a reviewer meeting `MINUS /dev/null 5` in a cycle with a
35-false-violations history will most plausibly conclude the control broke again — the exact spurious-
BROKEN trigger AC-4 calls out as having cost this cycle four generations.

The **spec** already says "tracking `--- SRCX/` and `+++ DSTX/` headers so each line keeps its file" and
is therefore correct; the **design's** method paragraph names only `+++`. **Remedy:** state explicitly
that `^-` lines take attribution from the preceding `--- SRCX/` header and `^+` lines from `+++ DSTX/`,
in whichever artifact S1's verbatim script lands.

### 1.5 Testing the remedy against its neighbours, and against my own output

- **AC-5 ↔ AC-7 (the generation-7 shape):** the ledger carve-out is real and is filled only by AC-5's
  two positional greps. I confirmed both halves independently (`3` new-path, `0` old-path, numstat `3 3`).
  @architect's "no leg may be dropped" interlock is correct and is now recorded in ADR-091 §Decision (4).
- **AC-6 ↔ AC-7 (the new coupling @architect names as most likely to fail next):** tested. Under
  `git -c diff.renameLimit=1`, the repaired AC-7 diff is **858 lines with 14 `rename from` markers —
  byte-identical to the default run.** AC-7 is renameLimit-immune for the same reason AC-6 is:
  `--find-renames=100%` pairs by exact content hash, not by the O(n²) inexact search the limit bounds.
  **NOT-RUN #4's AC-7 half is now closed;** the case-only-rename half is not (see NOT-RUN below).
- **This cycle's own mandated output vs its own control** — the collision that has fired three times
  in this lineage. Executed with a proxy of this report committed at
  `docs/internal/security/security-review-v2.19.12.md`:
  `(ok+) docs/internal/security/security-review-v2.19.12.md 3` — permitted, and
  `tar -tf … | grep -c 'security-review-v2.19.12'` → **0**, it does not ship. **No collision.**
  This is the first cycle in the lineage where the cycle's own output clears its own controls on
  first execution. It is also, as noted in §1.3, an instance of the S2 widening working benignly.

---

## Task 2 — Classification and the ADR sequencing risk

### 2.1 Classification: CONFIRMED, both axes

**SECURITY-SENSITIVE Tier A — CONFIRMED.** The Phase-4 file list contains `scripts/verify-ledger-
annotations.sh` (TIER-1: any file under `scripts/`) and `.github/workflows/quality.yml`. Either alone
suffices. Independently verified rather than inherited: the branch as committed touches only
`docs/architecture.md`, `docs/design-v2.19.12.md`, `docs/spec.md` (`git diff --name-status`), so
**Tier A is owed by the Phase-4 plan, not yet by the branch** — the ceremony is correctly pre-declared.

**COMPLIANCE-SENSITIVE = NO — CONFIRMED.** No dependency manifest exists in this repo
(`package.json` / `requirements.txt` / `go.mod` / `Cargo.toml` all absent), so no licence surface moves;
no third-party ToS is engaged; no personal data is added. The move is if anything compliance-**positive**:
it withdraws documents containing contributor handles from every public release archive. Secrets scan
of the branch diff: 0 true positives (one false positive on the string "16-token").

### 2.2 The ADR-088 flip: **the compensating control is NOT adequate. Move the flip to Phase 4.**

The branch as committed carries, in `docs/architecture.md:58` — **a file that ships in the public
release archive** — this past-tense factual claim:

> *"the retrofit that closes them **shipped in v2.19.12** (14 reports moved into
> `docs/internal/{qa,security}/`, archive leak matches 0)"*

Fourteen reports are, at `83f317c`, still at `docs/` root. `git ls-files` confirms all 14.

@architect's own deferral record, at `docs/architecture.md:14232`, states the governing principle
verbatim: **"An ADR that diagnoses a falsified status claim must not ship carrying one."** The branch
now carries exactly that, in the same document, authored by the same agent, at Phase 1.

**Why the Phase-5 compensating control does not cover it — enumerate the reachable states:**

| State | Phase 5 conjunction fires? | Outcome |
|---|---|---|
| Phase 4 lands all 14 | yes | flip becomes true. Fine. |
| Phase 4 lands 12 of 14 | yes (`R100 ≠ 14`) | caught. Fine. |
| **Owner descopes the retrofit at the Phase 3 gate** | **no — Phase 5 never runs** | **no control at all** |

The third row is not speculative. **It is what happened to this cycle's direct ancestor.** ADR-088 was
minted ACCEPTED at v2.19.10 Phase 1.2 and the owner moved the retrofit out **at the Phase 3 gate**;
the entire deferral record at `:14222` exists because of that event, and the correction cost a
downgrade to `PROPOSED (deferred)`. **That gate has not yet happened for v2.19.12.** @architect has
placed the mitigation downstream of the risk it mitigates.

The doc commits are also independently harvestable — a later cycle taking "just the ADR work" from this
branch inherits the false claim with no control anywhere in its path.

**Ruling: move it, and be specific about where.** "Phase 4" is right, and the precise requirement is
that the ADR-088 status flip **and** the ADR-037 index-row past-tense edit land in a Phase-4 commit that
is a **descendant of the r3 move commit**, so the branch is never in a state where the claim can be
harvested without the move. Cost is near zero: these are the only two in-place line changes in
`docs/architecture.md` this cycle, and I verified independently — via the AC-7 run over
`BASE..83f317c`, which returned `REMOVED-LINE VIOLATIONS (a): 0` — that **neither removed line names any
of the 14**, so relocating them cannot trip AC-7(a).

Keep the Phase-5 conjunction check regardless. It is a good check. It is simply not sufficient alone.

**Related sequencing asymmetry, noted:** the *claim* (the flip) landed at Phase 1; its *mitigation*
(AC-8's forwarding note) is deferred to Phase 4 — `/usr/bin/grep -n 'qa-report,security-audit,security-review'
docs/architecture.md` → no match on the branch. Claim early, mitigation late is the wrong order.

---

## Task 3 — Is the REDUCED GUARANTEE honest and complete?

Verdict: **accurate in every claim it makes, but incomplete in two places, both under-statements.**

### 3.1 `docs/project-audit-v2.6.1.md` — claim CONFIRMED, exactly as written

```
$ /usr/bin/grep -nE '^docs/(qa-report|security-audit|security-review|project-audit)-' base.entries
38:docs/project-audit-v2.6.1.md          <- 15 with 4 stems
39:docs/qa-report-v2.18.0.md             <- 14 with 3 stems
… (13 more)
```

It ships at BASE, it ships at the end state, and AC-4 is blind to it. The "do NOT widen — 4 stems
returns 15, breaking `R100 == 14` and AC-4's own prose simultaneously" reasoning **reproduces exactly**.
The non-guarantee is honest and the refusal to widen is correct.

### 3.2 S5 — but it is not the only one, and the list implies it is

`.gitattributes` export-ignores `docs/internal/`, `spec.md`, `retro.md`, `patterns.md`. Everything else
under `docs/` ships. The full set of internal-analysis documents at `docs/` root in the release archive:

| Artifact | Count at BASE | After this cycle |
|---|---|---|
| `docs/project-audit-v2.6.1.md` | 1 | 1 |
| `docs/design-v*.md` | 6 | **7** |
| `docs/risk-register.md` | 1 | 1 |

**This cycle's own `docs/design-v2.19.12.md` ships**, and it contains §I — a NOT-RUN list enumerating
**8 untested areas of the release-hygiene controls** — plus §H naming precisely what `LEAK_PATTERN` is
blind to and instructing that it not be widened. The cycle withdraws 14 QA/security reports from the
public archive while adding, to that same archive, a document that maps where the withdrawal controls
are weak.

I am **not** recommending this be fixed here. ADR-037 made design docs public deliberately, and widening
anything in this cycle is already ruled out on measured grounds. **The finding is that the non-guarantee
list must say it.** An under-stated non-guarantee is the failure mode; naming one file when the class has
nine members is an under-statement. Add the class to the list and to the GCS, and carry it forward.

### 3.3 S4 — the dangling-citation count is under-stated by the cycle's own artifact

Measured by me on the **actual post-move shipping tree** (`git archive` of the correct-cycle end state,
extracted, `/usr/bin/grep -rc -F -f <the 14 exact docs/-prefixed names>`):

| File | dangling citation lines |
|---|---|
| `docs/design-v2.19.10.md` | 25 |
| **`docs/design-v2.19.12.md`** | **10** |
| `scripts/verify-release-surface.sh` | 6 |
| `scripts/publish-release.sh` | 6 |
| `docs/architecture.md` | 6 |
| `docs/risk-register.md` | 5 |
| `docs/design-v2.19.8.md` | 5 |
| `scripts/release-predicate.sh` | 3 |
| **TOTAL** | **66 lines across 8 shipping files** |

Occurrence count is also **66** (`grep -rho | grep -c ''`) — one citation per line, no double-counting.

**Subtract this cycle's own `docs/design-v2.19.12.md` and you get exactly `56` across `7` — R4's figure.**
That is the arithmetic: the stated number was measured on a tree that did not yet contain the cycle's own
design document. **This is the identical correction @architect already made once in §B** ("the archive
absolute is 432 → 418, not 431 → 417, because this cycle owes its own shipping design doc") — applied to
the archive count and **not** applied to the citation count.

The spec's framing is defensible — it deletes the pin and says *"the carry-forward records the count
measured at merge, not a figure inherited from a fold-in."* But the FINAL AC SET's REDUCED GUARANTEE and
the design's §H both say "**the ~56** dangling citations", present tense, as the shipped truth. At this
branch base the shipped truth is **66/8**. Correct it in both, and in the GCS.

**Confirmed and retained:** `/usr/bin/grep -rnE '\]\([^)]*docs/(qa-report|security-audit|security-review)-v[0-9]'`
over the shipping tree → **zero markdown links.** `link-check` stays green; no user-clickable link breaks.
That claim is exactly right.

### 3.4 Are the citations acknowledged and not repaired? YES — and that is correct

AC-7(a) forbids removals repo-wide; the four append-only surfaces permit only additions. The cycle's own
rules therefore **mandate** leaving 66 citations broken, and AC-8 supplies one appended note in a
shipping file (`docs/architecture.md` ships — confirmed present in the archive listing). The forwarding
note is not yet on the branch; it is Phase-4 work per §D.4. **Not a defect at Phase 2** — noted only
because it is the mitigation half of the flip whose claim half already landed (§2.2).

### 3.5 Are the spec's numbers measured at this branch base?

Mostly yes, and @architect states the flavour and the base explicitly, which is the right discipline.
Two exceptions, both traced:

- **S4** — the `~56/7` citation figure is inherited from R4's pre-design-doc tree. Above.
- **S7** — `3925 → 119` diff sizes are from @architect's synthetic tree. At this branch base the same
  two forms measure **4664 → 858** (movee-naming lines **36 → 0**). The *direction and mechanism*
  reproduce completely; the *magnitudes* do not, and are not reproducible by anyone verifying against
  the branch. Label them "synthetic tree" or replace them with the branch-base pair.

Verified-and-correct, so the reader can tell what was checked: `431` archive entries at BASE
(`/usr/bin/grep -c ''` → 431); `418` at end state; delta `432 − 418 = 14`; `R100 = 14`, `A/D/M = 0`;
`3 3` numstat; positional greps `3` / `0`; the three `**Maturation Path**` header counts at the branch
tip → **60 / 60 / 60**, equal, matching the claimed `58 → 60` (+2 each) — @architect's paraphrase check
holds; `docs/internal/**` → **0** archive entries.

---

## OWASP Top 10 Assessment

| Category | Status | Notes |
|---|---|---|
| A01 Broken Access Control | **RISK REDUCED** | The cycle's purpose. 14 internal QA/security reports leave the public release archive; `docs/internal/**` → 0 archive entries, verified. Residual: S2 (a new public file may re-expose the *index*), S5 (7 design docs + project-audit + risk-register still ship). |
| A02 Cryptographic Failures | N/A | No cryptography in scope. |
| A03 Injection | PASS | No user input, no interpreter boundary. AC-7's `grep -Ff` pattern file is machine-derived from `git archive`, and the `N==14 / B==0` inventory guard fences the one injection-shaped hazard (a blank pattern matching everything) before use. |
| A04 Insecure Design | **WARN** | S1: the control's executable half is prose. A design whose verification step must be re-derived by each runner is an insecure design in the literal sense — the thing that gets executed is not the thing that was reviewed. |
| A05 Security Misconfiguration | **WARN** | `.gitattributes` becomes the sole `git archive`-surface protection for 71 internal reports, and AC-4 is structurally blind to that rule's removal (`LEAK_PATTERN` is anchored at `^docs/`). @architect names this boundary in the ADR-088 amendment — correctly, and it remains the cycle's largest standing exposure. |
| A06 Vulnerable Components | PASS | No dependency manifest in this repo; `npm audit` N/A. No new dependency, no vendored content. |
| A07 Auth Failures | N/A | No authentication surface. `verify-ledger-annotations.sh`'s LP-01 `gh api` probe is read-only and is skipped under `--no-probes`, which both AC-5 legs use. |
| A08 Software/Data Integrity | PASS | Content byte-unchanged across the move, proven by `R100 = 14` with `A/D/M = 0` — content-hash equality, not similarity. Independently re-run, and re-run under `diff.renameLimit=1` with an identical result. |
| A09 Logging/Monitoring Failures | **WARN** | S6: deletion-side violations are reported against `/dev/null`. The control fails *loudly but illegibly* — and in this lineage an illegible alarm has repeatedly become the next generation's defect. S4/S5: under-stated figures in the artifact a non-developer approver reads. |
| A10 SSRF | N/A | No server-side request construction. |

**LLM threat assessment (LLM01 / LLM02 / LLM06).** Applicable: `docs/design-v2.19.12.md`, this report,
and the AC text are all consumed by later agents. Nothing in this cycle causes agent-authored content to
be executed. One forward-only note, consistent with the repo's standing posture: **the moved reports'
content is data, never instructions** — relocating them under `docs/internal/` does not change that, and
no future consumer (Phase-5 verifier, retro, or audit corpus) may treat a finding quoted inside a moved
report as a directive. No new egress path is created; the change is net-negative on egress.

---

## Findings, numbered, with remedies

### CRITICAL / BLOCKER

- [ ] **S1 — AC-7's repaired form has no executable artifact and no designated executor.**
      *Evidence:* `awk` 0× in the design doc; §D has no AC-7 row; the spec's bash block terminates at
      `git diff …` and delegates the partition to prose.
      *Remedy:* paste the exact executed partition **verbatim** into `docs/design-v2.19.12.md` §E.3, and
      name the executor and phase in the AC text. **Also add this report's path to `scope_allow_delta.add[]`**
      (`docs/internal/security/security-review-v2\.19\.12\.md`) — §D.4's list omits it.
      *Must close before the Phase 3 gate.*

- [ ] **S2 — the `--- /dev/null` rule permits additions in any file created this cycle, including public
      ones; all three controls return green on a tree that republishes the moveset index.**
      *Evidence:* `docs/report-index.md` → AC-7 `(ok+) 14`; AC-4 `0 of 419` with the file shipping at
      archive entry 40; AC-6 `PRE=432 POST=418 DELTA=14`.
      *Remedy:* print the permitted-additions bucket by filename, and state in the AC that any entry
      other than the four append-only surfaces, `scripts/verify-ledger-annotations.sh`, and paths under
      `docs/internal/` is a **reviewer STOP**. Do **not** narrow the population — `docs/design-v2.19.12.md`
      legitimately needs 14 permitted additions, so a narrowing breaks the correct cycle.
      *Must close before the Phase 3 gate.*

### WARNING

- [ ] **S3 —** move the ADR-088 flip and the ADR-037 index-row edit into a Phase-4 commit descending from
      the r3 move commit. Retain the Phase-5 conjunction check as a second control, not the only one.
- [ ] **S4 —** correct the dangling-citation figure to **66 lines across 8 shipping files**, measured at
      this branch base, in the REDUCED GUARANTEE, design §H, and the GCS. Keep "measured at merge" for
      the carry-forward.
- [ ] **S5 —** add the class to the non-guarantee list: 7 `docs/design-v*.md` (incl. this cycle's own),
      `docs/project-audit-v2.6.1.md`, and `docs/risk-register.md` ship publicly and are outside AC-4 by
      design. Carry forward; do not widen anything this cycle.
- [ ] **S6 —** attribute `^-` lines from `--- SRCX/` and `^+` lines from `+++ DSTX/`, explicitly, wherever
      S1's verbatim script lands.
- [ ] **S7 —** label `3925 → 119` as synthetic-tree, or replace with the branch-base pair `4664 → 858`
      (`36 → 0` movee-naming lines).

### INFO

- **S8 —** flavour gap measured: blank-pattern `grep -F -f` → **1 (BSD, fails open)** vs **0 (ugrep shim)**.
  Inventory-guard patterns agree across both (`grep -c ''` → 3/3; `grep -c '^[[:space:]]*$'` → 1/1).
  Anyone who validated the F2 hazard with an *inline* `grep` in this harness would have concluded there
  was no hazard. GNU unmeasurable here — `command -v ggrep gnugrep docker podman colima nix` → empty,
  `/opt/homebrew/opt/grep/libexec/gnubin/grep` absent. The claim in the spec is accurate.
- **S9 —** NOT-RUN items closed by execution: modified movee (AC-6 `R100=13, A=1, D=1`; AC-7 exit 1 —
  double coverage confirmed); `diff.renameLimit=1` vs AC-7 (858 lines, 14 rename markers, byte-identical);
  the cycle's own Phase-2 report vs AC-7 (`(ok+) 3`, and 0 archive entries).
- **S10 —** no dependency manifest (`npm audit` N/A); no secrets in the branch diff.

---

## NOT-RUN — honest list

1. **GNU grep on `ubuntu-latest`.** Still unmeasured, now six rounds. I confirmed by probe that it is
   unmeasurable *on this host* rather than merely un-attempted. Rank first for the first real CI run.
2. **AC-7 in a real Actions runner**, including `$BASE` object availability. Exactly one of 34
   `actions/checkout` jobs sets `fetch-depth: 0`. Unchanged from @architect's list.
3. **Case-only renames vs AC-6/AC-7.** Not run, and not runnable here for a stated reason: this host's
   filesystem is case-insensitive, so the collision cannot be materialised in a working tree. It would
   need `git update-index` plumbing or a case-sensitive volume. **The renameLimit half of NOT-RUN #4 is
   now closed; this half is not.**
4. **The repo's own `tests/` suite against a post-move tree.** `tests/fixtures/release-surface/` cites
   movesets and sits inside a frozen surface. Unchanged.
5. **LP-01's `Branch not protected` 404 path** against the real API. Unchanged.
6. **AC-4's full YAML inside a runner**, including `shell: bash` word-splitting. I verified the logic by
   reading; I did not execute the composed step in an Actions context.
7. **`CF-v2.19.11-A` / ADR-090 overlap (S12).** Not investigated. Unchanged from Phase 0.
8. **Whether S2's remedy is sufficient in practice** — it converts a silent permission into a printed
   line a human must read. I cannot test whether a human will read it. That is the same limitation the
   AC-7 "candidate, not violation" clause already carries.

---

## Summary

The repair is **good work and it holds where it was tested** — I rebuilt it from scratch on the real
branch tip and reproduced `35 → 0` and both seeded catches without borrowing a number. The half-B blind
spot is genuinely closed. AC-5, AC-6, and AC-4 all verify independently. The coupling @architect
nominated as the most likely next failure — `diff.renameLimit` — I attacked and could not break, in
either control.

The two blockers are both of this cycle's signature shape, and neither is expensive. **S1** is the
remedy existing only as prose, in a lineage where every generation of defect has been born in the gap
between what was reviewed and what was run. **S2** is the ninth remedy-borne defect: a rule written to
eliminate hardcoded filenames ("no filename is hardcoded and none can drift") replaced a bounded
exception set with an unbounded one, and the input that exploits it is a document a helpful implementer
would plausibly write. Both close with a fenced code block and one line of AC text respectively.

**S3** is the one I would insist on regardless of the others: a public shipping document currently
asserts, in the past tense, that a move which has not happened did happen — and the compensating control
sits downstream of the exact gate event that produced this ADR's own deferral record.

**S4 and S5 matter because a non-developer approves this on the summary alone.** Every number in that
summary must be measured at this branch base. Two were not, and both err in the direction that makes the
cycle look tidier than it is.

**PASS WITH CONDITIONS.** S1 and S2 close by Phase-1 amendment before the Phase 3 gate. S3–S7 are
binding Phase-4 acceptance conditions.
