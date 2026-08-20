# Security Review — v2.19.10 "Plain Language: say it the way she'd say it"

## Phase: 2
## Date: 2026-08-20T04:15:00Z (re-verify) · 2026-08-20T02:55:00Z (initial)
## Status: PASS WITH WARNINGS — 0 CRITICAL, 0 BLOCKER (after amendment). Initial pass: FAIL — 0 CRITICAL, 2 BLOCKER.

> **Persistence note (why this file appears at Phase 4/6 rather than Phase 2).**
> At Phase 2 the only write path on offer was `docs/` root, which ships in every public release
> archive (`git archive`). @security declined to write the review at all rather than publish it to a
> shipping path — the same S4 defect this very review was filing. `docs/internal/security/` is
> `export-ignore`d and is the correct home; the review is persisted here verbatim from the
> Phase 2 / Phase 2.1 pipeline record. **No finding text has been changed, softened, or
> back-dated.**

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | CRITICAL (BLOCKER) | 2 | configuration | AC-PL-6's fault-injection fixtures self-destruct on this cycle's own mandated AC-PL-1 rewrite — both `sed`s anchored on `apply/verify/rollback machinery`, which occurs exactly once, inside the `self-apply` description cell the rewrite must change. |
| S2 | CRITICAL (BLOCKER) | 2 | configuration | The F-1 remedy (file-wide count equality) freezes only the refusal sentence's first clause; deleting the actual pool restriction leaves the count at 2 and the instrument GREEN. |
| S3 | WARNING | 2 | ui | AC-PL-3 and AC-PL-7 row 6 collide on `WIZARD.md:123`; @dev was never told which edit shape is compliant. |
| S4 | WARNING | 2 | logging | 14 internal QA/security reports ship in every public release archive (regression at v2.18.0; 48 predecessors were correctly internal). Pre-existing, not introduced by this cycle. |
| S5 | WARNING | 2 | configuration | §C.3's anchor-uniqueness claim named 1 exception; there are 2. |
| S6 | WARNING | 2 | configuration | AC-PL-7 row 2's "all protected strings unique in their file" is false; the real margin is 2 tokens, not 5. |
| S7 | WARNING | 2 | configuration | §C.6's "both legs fire independently" is false at instrument level — reflow-only damage does not move the count; the failure message advertises a detection the instrument lacks. |
| S8 | WARNING | 2 | configuration | F-6 verifies the forward-pointer's string but not that it is DATED, which AC-PL-4 requires. |
| S9 | WARNING | 2 | configuration | `grep -cF` counts LINES, used throughout as an occurrence test on a file of paragraph-length lines. Findings survive re-measurement; the method did not. |
| S10 | INFO | 2 | configuration | The CODEOWNERS AC-E3-2 deferral was silent. |
| S11 | INFO | 2 | configuration | The YAML pin `AC_PL_6_EXPECTED_HEX_ROWS` was unquoted (parses as a YAML integer; consumed only as a shell string). |
| S12 | INFO | 2 | configuration | `set -u` trap when the AC-PL-6 steps are run locally outside the job's `env:` block. |
| S13 | WARNING | 2 | configuration | Row 6 leg A degrades to the whole-file grep it was minted to replace: an empty `LINE` makes `sed -n "p"` behave as `cat`, so both halves match at the surviving `:27` copy — false GREEN on exactly the condition row 6 exists to catch. |
| S14 | WARNING | 2 | configuration | AC-PL-7(c) had no recorded pre-edit baseline for row 6 — and (c) is the only leg that sees weakening-by-addition, on the one line whose mandated edit shape IS addition. Baseline measured and bound: 0. |
| S15 | WARNING | 2 | permissions | The design's own recommended `APIs` appositive — *"(other programs your computer talks to over the internet)"* — narrows the Data-locality guarantee by definition. A third weakening species (alongside deletion and addition) that no instrument sees. |
| S16 | WARNING | 2 | logging | ADR-037's Consequences claim is falsified by the 14 leaked files, and its §Maturation Path option (c) proposes a CI assertion checking the wrong direction. Carry-forward; a `.github/workflows/` change, out of scope for this PATCH. |
| S17 | INFO | 2 | configuration | 19-item @dev pre-push checklist supersedes the earlier 12. |

---

### CRITICAL (BLOCKER — both resolved at the amendment `be92754`)

- [x] **S1 — AC-PL-6's fault-injection fixtures self-destruct on this cycle's own mandated edit.**
  Both fixtures were anchored on the literal `apply/verify/rollback machinery`, which occurs
  **exactly once** — inside `self-apply`'s `description` cell (`curated-skills-registry.md:31`), the
  very field AC-PL-1 must rewrite. `apply/verify/rollback` is Jargon-List term #7, so the rewrite is
  *required*, not optional. Post-rewrite both `sed`s no-op, the fixtures become `cmp`-identical to the
  clean tree, and step 1 fires `FAULT-INJECTION FAILED; exit 1`. §D.1 sequences `quality.yml` FIRST,
  so the job would be green on commit 1 and **permanently red on commit 2**, blaming the check when
  the fixture had merely evaporated. @architect's 30/29/29 record reproduced exactly on the clean
  tree — honest, but tree-dependent.
  **Remedy adopted:** content-independent `awk` fixture keyed on **field 2** (fires 29 on both the
  clean and the post-rewrite tree) plus a `cmp -s` fixture-validity guard, the repo's own house
  pattern (`quality.yml:573-576`).
  **Re-verified on @security's own retained fixtures, not on @architect's description:** the adopted
  fixture returns 29 RED on both trees; the superseded form is `cmp`-identical to the clean tree. The
  `cmp -s` guard passes positive **and** negative controls. The decoupling attack @security designed
  against the guard **does not exist**: the `awk` and `sed` anchors are determined by the same two
  pipe characters, so any mutation killing one kills the other — *stated as tested, not assumed*.

- [x] **S2 — the F-1 remedy is narrower than the guarantee it protects.**
  @architect's *diagnosis* was confirmed (the refusal string occurs twice, `WIZARD.md:27` and `:123`),
  but the count remedy freezes only the sentence's **first clause**. Measured:
  `sed '123s/ — the wizard installs only from the local, vetted pool\.//' WIZARD.md` →
  `grep -oF "Installing skills from external sources isn't supported yet" | wc -l` → **2** → GREEN.
  Deleting the positive statement of where skills may come from — the actual pool boundary — left the
  instrument green. **The repo had already solved this class and the design did not cite it:**
  `quality.yml:753-785` uses anchor-scoped paragraph extraction plus a fault-injection step proving
  the unscoped form passes, and that is the shape @architect chose for F-6 two pages earlier in the
  same document. Scoping for F-6 and bare counting for F-1 was the inconsistency.
  **Remedy adopted:** scope to the F4 line via the unique anchor `No URL paste, no external source`,
  then assert **both** halves inside that scope. Re-verified: the 4-row negative-control matrix
  reproduces **cell-for-cell**; anchor uniqueness re-confirmed **by occurrence**, per S9.

### WARNING

- [x] **S3** — AC-PL-3 and AC-PL-7 row 6 collide on `WIZARD.md:123` and @dev is never told.
  Appending after `…vetted pool` is **the only compliant shape** (count stays 2, GREEN); rewriting the
  opening into plainer English goes **RED on correct-looking work** — and a plain-language pass will
  reach for exactly that opening. Bound into §C.3 as an explicit warning box.
- [ ] **S4** — 14 internal QA/security reports ship in every public release archive.
  Orchestrator-verified: 14 at `docs/` root, **0** under `docs/internal/`. A regression at **v2.18.0**;
  48 predecessors went to `docs/internal/` and were correctly excluded. The repo is public and these
  documents enumerate unfixed gaps, inert controls, and zero-coverage areas. **Pre-existing.**
  In-cycle remedy (free): this cycle's reports go to `docs/internal/`. Retrofitting the 14 is a
  separate owner decision.
  **RE-ASSESSED at the amendment — HIGH STANDS, and the correction cut the other way.** @security
  withdrew "silent regression" (the orchestrator's relay of @architect's correction was right on that
  narrow point) — but then read ADR-037 itself rather than the citation to it.
  Orchestrator-verified independently: the phrase *"radical transparency"* appears **0 times** in
  ADR-037, and ADR-037 explicitly `git mv`'d **12 qa-reports into `docs/internal/qa/` and 16 security
  reviews into `docs/internal/security/`** — the exact file class. So `docs/design-v2.19.7.md:82`
  invoked a convention its cited ADR does not contain, to justify placement that ADR had already
  decided against. A finding rationalized on a misreading is not a resolved finding — it is an
  unreviewed one wearing a resolved label. Routing THIS cycle's reports to `docs/internal/` is not a
  new convention; it is **ADR-037 compliance**.
- [x] **S5** — §C.3's anchor-uniqueness claim named 1 exception; there are 2. Corrected table.
- [x] **S6** — AC-PL-7 row 2's "all unique in their file" is FALSIFIED but the row is **CONTAINED**.
  Re-measured by occurrence: `personal-assistant` `Calendar/`=2, `Tasks/`=3, `People/`=3,
  `Finances/`=1, `Documents/`=1; `writing` `Voice-and-Style/`=2. Compressing the clause to *"my
  folders"* still drives `Finances/` and `Documents/` to 0 → RED. **The instrument still works — but
  the margin is 2 tokens, not 5.**
- [x] **S7** — *"both legs fire independently"* is false at instrument level. Reflowing pipe *spacing*
  does not change pipe *count*, so reflow-only reads 30 GREEN and the compound fixture's RED comes
  **entirely** from the pipe-injection leg. **Coverage is fine** (`wizard-consistency-check` catches
  reflow); the **claim** was the defect, inside a passage asserting it was not.
- [x] **S8** — F-6 verifies the pointer's string but not that it is DATED. Leg 2b added.
- [x] **S9** — every "unique in its file" claim used `grep -c` (LINES) as an occurrence test on a file
  of paragraph-length lines. Re-run with `grep -oF … | wc -l` they **all hold**, so the findings are
  sound and the method was not. Method standardized in §C.0.
- [ ] **S13** — **row 6 leg A can return GREEN on the exact condition it exists to catch.**
  `LINE=$(grep -n … | cut -d: -f1)` with a typo'd or removed anchor yields an **empty** `LINE`;
  `sed -n "p" WIZARD.md` is then `cat`, printing all **42,707 bytes**, so both halves match at the
  surviving `:27` copy. Not a BLOCKER *only* because row 6's own token goes RED independently — the
  material difference from S2, where leg B was GREEN with nothing else covering it. §C.7's block
  carries **no `set -euo pipefail`** (§C.6's does) and row 6 is hand-run, so the unguarded venue is
  the real one. **Remedy:** a fail-closed `[ -z "$LINE" ] && exit 1` guard before `sed`.
- [ ] **S14** — AC-PL-7(c) has **no recorded pre-edit baseline for row 6**, and (c) is the ONLY leg
  that sees weakening-by-addition, on the one line whose *mandated* edit shape **is** addition.
  Proven: appending `unless you paste a link you trust` leaves legs A and B GREEN and only (c) fires
  0→1. **Baseline measured and bound: 0.**
- [ ] **S15** — **a third weakening species that no instrument sees.** The design's own recommended
  `APIs` appositive — *"(other programs your computer talks to over the internet)"* — **narrows the
  guarantee by definition**: a local IPC bridge or an on-device agent no longer obviously falls under
  `Never send`. All six categories stay intact; the deny-list stays 0; (a), (b) and (c) are all GREEN.
  Systematic, not incidental: AC-PL-7's precedence rule tells @dev to *"inline-define the term"* as
  the standard remedy, in a cycle whose entire subject is adding inline definitions.
  **Safer wording supplied. Binding condition on the final wording:** the appositive must ATTACH to
  `APIs` (append, never replace); every row-1 token must leave count 1; the deny-list must leave 0.
- [ ] **S16** — ADR-037's Consequences claim *"a future contributor cannot ship a new internal
  artifact to users"* is falsified — 14 files did exactly that — and its own §Maturation Path option
  (c) proposes a CI assertion **checking the wrong direction** (that `docs/internal/**` is absent from
  the archive); these leaked by never being placed internal at all. The assertion that would close it
  is the inverse. **`.github/workflows/` change = Tier B, out of scope for this PATCH. Carry-forward;
  do NOT bundle.**

### INFO

- **S10** — the CODEOWNERS AC-E3-2 deferral was silent. Recorded in §H.
- **S11** — quote the YAML pin. Unquoted it parses as a YAML integer; harmless today, but quoting
  removes the question rather than leaving a reader to re-derive the answer.
- **S12** — both AC-PL-6 steps run under `set -u` and read a job-level `env:` value; a local run
  outside the job aborts on the unbound variable.
- **S17** — 19-item @dev pre-push checklist supersedes the earlier 12.
- **@security's own near-miss, recorded because the negative control is what stopped it.**
  `git check-attr export-ignore` reports `unspecified` for `docs/internal/` files, and @security
  nearly filed a false CRITICAL on that basis. `git archive` proved the directory pattern works.
- **On the un-minted general rule ("simulate the post-edit tree for every mandated edit") —
  @security AGREES with @architect and sharpened the reason:** the rule is *unbounded in cost and has
  no scoping predicate* (a 30-file cycle ⇒ 30 simulated trees); minting an unreviewed general policy
  inside an amendment would reproduce this cycle's signature failure at the policy layer. Declining it
  is *"the consistent act, not the timid one."* Correct home: The-Council's `docs/pipeline-policy.md`
  — a Tier-A surface needing its own `/self-improve` cycle plus a Guard Change Summary.
- **@architect's own supporting figure corrected:** the "4 of 5 instruments were caught by simulation"
  attribution was not independently re-derived; some (S7, F-1) were caught by ordinary damage
  fixtures. *The lesson holds at 2–3 of 5; it does not need 4 to be true.*

---

### Classification — re-derived independently, NOT accepted from @architect

**Tier B CONFIRMED at `be92754`. Guard Change Summary NOT owed.**

All four snapback conditions clear with commands — and @security added **the negative control the
conditions themselves lacked**: `git diff -- <path>` returns 0 for a path that does not exist, so all
three paths were confirmed to exist first. **The zeros mean *not modified*, not *not present*.**

- **TIER-2 checked non-vacuously.** The real risk is whether the edits *force* a lock change: no scope
  path appears in `cowork.lock.json` / `.cowork-allowlist.json` (`grep -c '"path"'` → 108, as the
  proof the grep works on that file).
- **TIER-3 clears more strongly than stated.** CODEOWNERS *already* covers `quality.yml` and
  `curated-skills-registry.md`, so no addition is needed and the condition cannot trigger.
- **ADR-087 touches no Tier-A surface.**

### `/legal` ruling — NOT owed

Re-derived independently: all 8 row-1 protected tokens occur **exactly once each**; the deny-list
count on the Data locality line = **0**; and the designed `APIs` fix is an appositive that adds words
and removes none. The `/legal` tripwire is **the enumerated category set**, and narrowing a
*destination definition* is not a category change.

**`/legal` becomes owed if** the final wording REPLACES rather than appends, **or** any row-1 token
leaves count 1, **or** the deny-list leaves 0.

---

### OWASP Top 10 Assessment (Phase 2)

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | WATCH | No auth surface in this kit. `self-*` deny-list is the nearest analogue; untouched by this cycle's scope. |
| A02 Cryptographic Failures | N/A | No cryptography in scope. `sha256` cells are integrity, covered under A08. |
| A03 Injection | PASS | No new parser consumes external input. The AC-PL-6 `awk` parses this repository's own registry only. |
| A04 Insecure Design | **FAIL → WARN** | S1+S2 were the **4th and 5th** instruments this cycle that cannot report the condition they exist to report. After the amendment: WARN, on S13/S14/S15 — all one-line remedies, none able to return GREEN once the checklist lands. |
| A05 Security Misconfiguration | WATCH → WARN | S4/S16 — `.gitattributes` archive-hygiene convention is sound but its Consequences claim is falsified and its proposed CI closure checks the wrong direction. |
| A06 Vulnerable Components | PASS | No dependency change. Action SHAs pinned. |
| A07 Auth Failures | N/A | No authentication surface. |
| A08 Data Integrity Failures | PASS | `registry-sha256-check` fail-closed; AC-PL-6 adds row-structure integrity ahead of it. |
| A09 Logging & Monitoring | **FAIL → WARN** | Zero CI coverage of all 8 `working-rules.md`; S7's failure message overclaims a detection the instrument lacks. |
| A10 SSRF | N/A | No outbound request surface. Pool boundary forbids URL fetch by policy. |

### LLM Threat Assessment (Phase 2)

| Category | Status | Notes |
|----------|--------|-------|
| LLM01 Prompt Injection | PASS | No new untrusted-input path. `WIZARD.md` spoken strings are authored content. Ledger `Note` re-scan (ADR-055) unchanged. |
| LLM02 Insecure Output Handling | PASS | Registry `description` cells for Group B have zero render paths; Group A reaches role-generation as declarative text only. |
| LLM06 Sensitive Information Disclosure | **WARN** | S4 — 14 internal reports in the public archive enumerate this kit's own unfixed gaps and inert controls. |

---

### Summary

Two BLOCKERs, both **inside the corrections to earlier defects** rather than in the Phase-0 ACs — the
cycle's signature failure reproducing one level up. Both were fixed at `be92754` and re-proven on
@security's **own retained fixtures**, not on @architect's description.

**The hunted pattern was still present, one level shallower, after the amendment: 3 new HIGH
(S13/S14/S15), all defects INSIDE the fix for S2.** None is a BLOCKER, because in each case an
independent leg still fires. All three carry one-line remedies bound as Phase-4 conditions.

S15 is the one that generalizes: it is a **third weakening species** — narrowing-by-definition —
alongside deletion and addition, and **no instrument in this cycle can see it.** It is the reason
Phase 6 must include a human read of the shipped sentences, not only a re-run of the greps.

Phase 3 gate MAY OPEN.
