# QA Report — v2.19.12 "S4 report-egress retrofit"

## Phase: 5
## Date: 2026-08-23T15:30:00Z
## Status: PASS
## Verdict: **APPROVED**

Branch `release/v2.19.12-s4-report-egress` @ `66403f3` (pushed, CI green — see §6). BASE
(pinned) `b43fa523f995736af70c483930935aed62b6a42b`. Real CI run `32647681336` = **success**,
35 jobs, 3 `skipped` (conditional, unrelated to this cycle), 0 failures. The new `S4 — Archive
Leak Gate` job ran for real on `ubuntu-latest` and printed `S4 PASS — 0 of 418 archive entries
match …` — this closes the AC-4 GNU-grep gap named in `docs/design-v2.19.12.md` §I item 1.
**AC-7's CI gap is NOT closed** — it is deliberately not a CI step this cycle (§D.6, §I item 2);
I ran it locally, pre-merge, as assigned.

**Environment.** Inline `grep` in this interactive shell is the **ugrep 7.8.4 zsh shim**
(`type -a grep` → shell function first, `/usr/bin/grep` second). Inside `bash <script>.sh` or
`bash -c`, `grep` resolves to `/usr/bin/grep` (BSD) — verified both ways this session. **Every
load-bearing count below used `/usr/bin/grep`, by absolute path, or the real script's own
internal `grep` calls when run via `bash script.sh`** (which is BSD on this host, not the GNU
grep `ubuntu-latest` runs — that gap is closed only for AC-4, via the real CI run above, per
§I item 1; AC-7 remains BSD-only, unmeasured under GNU, per §I item 2).

**Method note on denominators.** Every check below states `POPULATION(invariant)` vs.
`POPULATION(proxy)` where the design doc defines one, and every control that can be tested with
one input on each side of its symmetric difference was tested that way — not just the clean
case. A green result on the clean case alone is not reported as passing; see Task 1.

---

## Task 1 — AC-7 control: extracted, executed, both halves of the symmetric difference

**Extraction, mechanical, not retyped.** Bash fences in `docs/design-v2.19.12.md`:
`grep -n '^```bash$'` → lines 299, 518. Script body extracted with
`sed -n '300,367p' docs/design-v2.19.12.md` (closing fence independently located at line 368 via
`awk 'NR>=299 && NR<=370 && /^```$/{print NR}'` → 368). Byte-compared head/tail against the
source range — identical. This is the same script reproduced verbatim in `docs/spec.md`
(AC-7's bash block, confirmed identical on sight).

**Clean run, real branch, `BASE..HEAD`:**

```
$ bash ac7.sh . HEAD
PATTERNS LOADED: 14
REMOVED-LINE VIOLATIONS (a): 0
ADDED-LINE VIOLATIONS (b): 0
permitted: removals 3, additions 51
   (ok-) scripts/verify-ledger-annotations.sh                   3
   (ok+) docs/internal/security/security-review-v2.19.12.md     1
   (ok+) docs/design-v2.19.12.md                               45
   (ok+) scripts/verify-ledger-annotations.sh                   3
   (ok+) docs/spec.md                                           2
VERDICT: exit 0 CLEAN
EXIT: 0
```

**Not a check that cannot fail:** `PATTERNS LOADED: 14` (not 0 — the moveset file is populated).
The `permitted:` bucket was reviewed **by name**, not by count, per the AC's own instruction —
the count (51) is a live, moving number (the design doc's own contribution grew from 14→31→45
across three sessions; recorded here as a tree-state sample, not an expected value). No
unexpected filename appears in the bucket. `docs/architecture.md` contributes 0 additions
matching a movee name — consistent with AC-8's forwarding note using the family-glob form, never
an individual filename (§AC-8 below).

**Half A is not enough — both halves of the symmetric difference, seeded and run, in a
disposable clone (`git clone --no-hardlinks`; the live repo was never touched):**

- **Removal-half seed:** `docs/design-v2.19.10.md:1736` (a frozen, non-permitted prior-cycle
  design doc) contained the line `` 1. `docs/qa-report-v2.18.0.md` `` — an existing citation of
  a movee, outside the four append-only surfaces and outside the permitted set. Deleted it
  (`sed -i '' '1736d'`).
- **Addition-half seed:** appended `See docs/security-review-v2.18.0.md for details.` to
  `docs/how-it-works.md` — a public, non-permitted file — naming a movee by individual filename.
- Both seeded in one commit (`8f95172`) on top of the real branch tip.

```
$ bash ac7.sh <clone> HEAD
PATTERNS LOADED: 14
REMOVED-LINE VIOLATIONS (a): 1
   MINUS docs/design-v2.19.10.md                                1
ADDED-LINE VIOLATIONS (b): 1
   PLUS  docs/how-it-works.md                                   1
permitted: removals 3, additions 51
VERDICT: exit 1 VIOLATION
EXIT: 1
```

**Both halves went RED**, independently of the design doc's own transcripts (my own seeds, my
own clone, not a re-run of theirs). Clone deleted after use (`rm -rf`).

**Negative controls, independently re-derived (not copied from the design doc's numbers):**

1. **Inventory leg.** Widened the moveset regex with a 4th stem, `project-audit` (matching
   `docs/design-v2.19.12.md` §E.4's own construction — my first attempt used `design-v` and
   produced a syntactically different, non-matching pattern; corrected and re-run):
   ```
   ::error::AC-7 control BROKEN - moveset yields 15 lines; expected 14.
   EXIT: 3
   ```
2. **Permitted-set leg.** Dropped `docs/design-v${CYCLE_VERSION}.md` from `PERMIT_ADD` and
   re-ran against the real, correct, clean branch tip:
   ```
   ADDED-LINE VIOLATIONS (b): 45
      PLUS  docs/design-v2.19.12.md                               45
   VERDICT: exit 1 VIOLATION
   EXIT: 1
   ```

All three exit codes (0 clean / 1 violation / 3 broken-inventory) observed from four distinct
inputs, all run by me this session. **Verdict: AC-7's control is sound on the real branch, in
both directions, with working negative controls. This closes §D.6 / §I item 2's CI gap only for
the local, pre-merge leg it was scoped to — it is still not a CI step, by design.**

---

## Task 2 — ADR-088 conjunction (@architect's compensating control)

**Population:** `POPULATION(invariant)` = "ADR-088 reads ACCEPTED only if the retrofit has
actually shipped." `POPULATION(proxy)` = "the ADR-088 index cell string" (which is what a reader
actually sees).

```
$ /usr/bin/grep -n "ADR-088" docs/architecture.md | grep -i "status\|PROPOSED\|ACCEPTED"
111:| ADR-088 | ... | **ACCEPTED (v2.19.12 — was PROPOSED (deferred) at v2.19.10 Phase 1.3, and
ACCEPTED at Phase 1.2; number reserved and carried forward, cf. ADR-028). AMENDED by the
ADR-088 amendment record appended at v2.19.12 Phase 1 …**
```

```
$ git archive HEAD | tar -tf - | wc -l
418
$ git archive HEAD | tar -tf - | /usr/bin/grep -cE '^docs/(qa-report|security-audit|security-review)-'
0    (exit 1 — /usr/bin/grep -c exits 1 on a zero count; documented hazard, AC-5 §Phase-1
      correction 2, confirmed live here too)
```

**Conjunction holds: ACCEPTED (true) AND leak==0 (true).** Per §D.5 / §G's binding rule ("if
@qa cannot run the conjunction, the flip is reverted rather than trusted"), the flip is
**trusted, not reverted** — I ran it and both legs are true.

**Ancestry check (§I item 8 — "no automated control asserts the ancestry; @qa must check by
hand"):**

```
$ git log --oneline d51dd51..HEAD -- docs/architecture.md
a218dfa dev: R4 — ADR-088 flip to ACCEPTED, ADR-037 index-row correction, AC-8 forwarding note
$ git merge-base --is-ancestor d51dd51 a218dfa; echo $?
0
```

The flip commit (`a218dfa`, R4) **is** a descendant of the r3 move commit (`d51dd51`), as §D.5
requires. Confirmed by hand, not inferred.

**ADR-037 index row:** line 58 reads `"ADR-088, which supplies the remedy, shipped the retrofit
in v2.19.12 — the corrections stand, and the 14 internal QA/security reports the amendment
record identified are moved behind docs/internal/{qa,security}/"` — no longer "has not yet
shipped." (That exact phrase still appears once in the file, at `docs/architecture.md:14751`,
but as **narrative past-tense description of what the row used to say**, inside the ADR-088
amendment's own §4 explaining the correction — not the live index row. Read in context to avoid
a false positive here.)

---

## Task 3 — Per-AC verification against real shipped artifacts

| AC | Method | Result |
|----|--------|--------|
| AC-4 | Job extracted from `.github/workflows/quality.yml` via `yaml.safe_load` (Python), not read/paraphrased. `runs-on: ubuntu-latest`, step `shell: bash` confirmed present. Extracted the step's `run:` block verbatim and executed it locally with the job's own `env:` (`LEAK_PATTERN`, `CANARY_PATHS`, `EXPECTED_CANARIES=3`, `MIN_ENTRIES=300`) — **and** confirmed the real CI run (`32647681336`, `ubuntu-latest`, real GNU grep) printed the identical pass line. | `S4 PASS — 0 of 418 archive entries match ^docs/(qa-report\|security-audit\|security-review)-.` exit 0, both locally (BSD) and in real CI (GNU). |
| AC-5 | All four legs run for real: two positional `/usr/bin/grep -cE` counts (via Python `re` for the literal `${US}` delimiter, since it's a literal 4-character string in the source, not a control character — confirmed by inspecting raw bytes first, corrected an initial mistake where I searched for the actual 0x1F byte and got a false 0), `git diff --numstat`, and the script itself. | new-path 3, old-path 0, numstat `3␉3`, `bash scripts/verify-ledger-annotations.sh --no-probes` → `PASS — 19 of 19 static anchors resolved; 0 live-probe failures`, exit 0. LA-03a/b/c specifically confirmed `PASS` against the new `docs/internal/security/security-audit-v2.19.6.md` location. |
| AC-6 | `git show --format= --name-status --find-renames=100% d51dd51` (the `v2.19.12-r3` tag commit, confirmed `git rev-parse v2.19.12-r3` == `d51dd51ba08...`). | 14 × `R100`, 0 × A/D/M. Matches §D.1's list exactly, both source and destination paths checked by eye. |
| AC-7 | See Task 1. | 0/0/exit 0 on the real branch; both halves RED when seeded; both negative controls fire. |
| AC-8 | `/usr/bin/grep -n "qa-report,security-audit,security-review" docs/architecture.md` → line 14785. | Reads `` docs/{qa-report,security-audit,security-review}-v*.md `` — **the family-glob form**, confirmed, not an individual filename. (Consistent with the AC-7 clean run showing 0 additions attributed to `docs/architecture.md` — a family-glob doesn't match any single movee's literal name.) |

**Honesty on RAN vs INFERRED:** every row above is **RAN**, not inferred from prose. The one
place I initially got a wrong number (AC-5's `${US}` delimiter, and the AC-7 inventory-widening
stem) is stated above rather than silently corrected out of the record — both were caught by
re-checking against raw file bytes / the design doc's own construction before I trusted the
result.

---

## Task 4 — Whole-cycle regression sweep, `7084f4e..HEAD`

`7084f4e` confirmed an ancestor of `HEAD` (`git merge-base --is-ancestor`, exit 0) and a
descendant of pinned `BASE` (`git merge-base --is-ancestor BASE 7084f4e`, exit 0) — it sits
inside Phase-1/2.1 authoring, before the R1–R5 implementation commits.

```
$ git diff --find-renames=100% 7084f4e..HEAD -- docs/architecture.md docs/retro.md docs/spec.md CHANGELOG.md > diff.txt
$ /usr/bin/grep -c '^-[^-]' diff.txt
13
```

All 13 removed lines checked (Python, both units — the exact `docs/`-prefixed 14 names, and the
bare-filename form, since **bare is the unit AC-7 actually matches**, per the task brief's own
warning that a prior reviewer tested only the prefixed form):

```
bare hits: 0   prefixed hits: 0   (13 removed lines checked)
```

All 13 are ADR-088/ADR-037 status-cell prose (the PROPOSED→ACCEPTED flip and its narrative,
S3's revert-then-reapply) — none names a movee, in either unit.

**No file added at `docs/` root matching the 3 report stems:**

```
$ git diff --name-status --find-renames=100% 7084f4e..HEAD
M	.github/workflows/quality.yml
M	CHANGELOG.md
M	README.md
M	VERSION
M	docs/architecture.md
M	docs/design-v2.19.12.md
R100 × 14 (the moveset, source→destination, all 14 verified by eye against §D.1)
M	scripts/verify-ledger-annotations.sh
$ grep -E '^A\s+docs/(qa-report|security-audit|security-review)-' <above>
(no match, exit 1)
```

**The 14 moves are the only renames:** exactly 14 `R100` lines, every other line `M`, zero `A`
or `D` lines. Confirmed.

---

## Task 5 — Carry-forward completeness (nothing exists only in chat)

1. **`.gitattributes` single-line exposure.** `find docs/internal -type f | wc -l` → **82** files
   currently protected by the single `docs/internal/ export-ignore` line (`.gitattributes:28`).
   AC-4 is structurally blind to that line's removal (`LEAK_PATTERN` is `^docs/`-anchored and
   never inspects `.gitattributes`). **This has an explicit, durable home — not chat-only:**
   named as a Concrete Revisit Trigger in **both** shipped, `ACCEPTED` ADRs on this branch —
   ADR-088 amendment (`docs/architecture.md:14802`, *"`.gitattributes` is edited by any cycle
   (boundary (a) is live)"*) **and** ADR-091 (`docs/architecture.md:14944`, *"any edit to
   `.gitattributes`' `docs/internal/ export-ignore` line, which is what makes the three internal
   permitted paths safe"*). No cycle is currently scoped to close it — it is recorded as a
   revisit trigger, not a numbered CF, which is the correct home per this project's own
   `maturation-path-in-adr` convention for "risk knowingly accepted, no cycle owns the fix yet."
   I did not mint a new CF for it; the two ADR triggers already are the durable record the task
   asked me to confirm exists.
2. **`CF-v2.19.12-E`** (the citation count). Confirmed recorded in `docs/design-v2.19.12.md:726`
   and `docs/spec.md:9058`, both stating *"measured at merge"* — never a pinned figure. I did
   **not** add an eighth measurement to any shipped doc. For my own diagnostic use only (not
   written into any shipped artifact): a family-glob, `docs/`-prefixed count on the **current
   working tree at HEAD** (a different tree-state than "at merge", stated so it is not
   mistaken for the CF's own number) returns a different value again than the six already in
   circulation — consistent with the design doc's own point that this quantity moves every time
   `docs/design-v2.19.12.md` or `docs/architecture.md` is edited. Not pinning it here either.
3. **AC-7-in-CI gap.** Durably recorded in `docs/design-v2.19.12.md` §D.6 / §I item 2 and
   restated in `docs/spec.md`'s AC-7 "Executor and phase (binding)" clause — both shipped on the
   branch, not chat-only. Confirmed still true: `archive-leak-check` (AC-4) is the only S4-family
   job in `.github/workflows/quality.yml`; no job invokes the AC-7 partition script.

---

## Version / release-hygiene spot checks

```
$ cat VERSION → 2.19.12
$ grep "version-2.19.12" README.md → 1 hit (badge)
$ grep "^## \[2.19.12\]" CHANGELOG.md → 1 hit
```

Version triple consistent.

---

## §6 — CI

```
$ gh run list --branch release/v2.19.12-s4-report-egress --limit 5
… all 5 most recent runs: completed / success …
$ gh run view 32647681336 --json jobs -q '.jobs | length' → 35
$ gh run view 32647681336 --json jobs -q '.jobs[] | select(.conclusion != "success")'
3 jobs, all conclusion=skipped (lock-content-sha-cross-check, /sync-agency Dry-Run,
Vendored Removal Ledger — conditional jobs, not failures)
```

35 jobs total, 32 success + 3 skipped, 0 failed.

---

## RAN vs NOT-RUN (honest split)

**RAN, this session, by me:**
- AC-7 control: extracted mechanically, run on real branch tip, both halves of symmetric
  difference seeded and run in a disposable clone, both negative controls re-derived and run.
- AC-4: job extracted via `yaml.safe_load`, executed locally; real CI log fetched and grepped.
- AC-5: all four legs.
- AC-6: `git show --find-renames=100%` on the real tagged commit.
- AC-8: grep against the shipped forwarding note.
- ADR-088/ADR-037 conjunction, including the ancestry check.
- Whole-cycle regression sweep (7084f4e..HEAD), both units.
- `.gitattributes` file count (82), version triple, CI job count/conclusions.
- Maturation Path completeness for ADR-088 amendment and ADR-091 (3/3 headers each, non-empty;
  independently re-counted 60/60/60 across the whole file for the three header strings).

**NOT-RUN (inherited from the design doc's own NOT-RUN list, unchanged by me, and correctly so
— out of scope for Phase 5):**
- GNU grep for AC-7 specifically (AC-4's GNU gap is closed via real CI; AC-7 is deliberately not
  a CI step, so it has no GNU leg to close this cycle).
- Case-only renames (not runnable on this host's case-insensitive filesystem).
- The repo's own `tests/` suite against the post-move tree.
- LP-01's live-probe branch-protection path (`--no-probes` was used, as specified).

**Something I believe is still imperfect about the command that shows it:** the AC-7 script's
`permitted:` bucket count is reported as a raw integer with no upper bound — a reviewer scanning
only the `REMOVED`/`ADDED` violation counts (0/0) could still miss a newly-added permitted
filename that shouldn't be there, if they don't read the by-name list every time. The control
documents this ("diagnostics, not the control") and I did read it by name each run, but the
script itself does not fail if the permitted set silently grows in a future edit to include an
unintended path — that would require a person to notice a new line in the `(ok+)` list. This is
the same class of risk the design doc names for `.gitattributes`: a human-read diagnostic is
weaker than a machine assertion, and no machine assertion exists for the shape of the permitted
bucket itself.

---

## Verdict

**APPROVED.**

- AC-4 through AC-8: all verified against real shipped artifacts, not paraphrases (Task 3 table).
- AC-7's control: extracted verbatim, clean on the real branch, both directions of its
  symmetric difference produce the correct result when seeded, both negative controls fire,
  reviewed by name (Task 1).
- ADR-088/ADR-037 conjunction holds, and its sequencing precondition (flip commit descends from
  the move commit) is confirmed by hand, not assumed (Task 2).
- Whole-cycle regression sweep clean in both units across the four append-only surfaces; no
  root-level report additions; exactly 14 renames (Task 4).
- All three named carry-forward risks have a durable, shipped home — none exists only in chat
  (Task 5).
- CI green: 35 jobs, 32 success + 3 conditional-skip, 0 failures. AC-4's GNU-grep gap closed by
  the real run. AC-7's CI gap remains open by design, and is compensated by this report.

No BLOCKER or unresolved finding from this Phase 5 pass. The one open item (the permitted-bucket
shape has no machine assertion) is recorded above as an observation for a future cycle, not a
gate on this one — it was already known and accepted at Phase 2.1 (ADR-091 §Risk knowingly
accepted).
