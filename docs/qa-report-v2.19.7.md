# QA Report — v2.19.7 "Finish the Storefront, Ship What We Read"

## Phase: 5 (Testing) — re-verification pass
## Date: 2026-08-08
## Repo: `/Users/macbookpro/claude-cowork-config` @ `bf2704f` (`release/v2.19.7-finish-the-storefront`), base `main` @ `fe25660`
## Prior pass: `b13ad42` (FAIL — 2 blockers: QA-3, QA-5; 3 non-blocking: QA-1, QA-2, QA-4)
## Status: PASS WITH WARNINGS — the one remaining item was fixed after this report was written (see §9)

---

## 1. Fix-pass diff reviewed

`git diff b13ad42..bf2704f --stat`:

```text
.github/workflows/quality.yml | 82 +++++++++++++++++++++++++++++++++++++++++++
CHANGELOG.md                  | 14 ++++++--
docs/architecture.md          | 25 ++++++++++++-
docs/design-v2.19.7.md        |  8 +++++
docs/risk-register.md         |  1 +
vendored/README.md            | 11 ++++--
6 files changed, 135 insertions(+), 6 deletions(-)
```

Per this project's governing standard — *a correction is not privileged; review the fix as hard as the original* (v2.19.6 retro: **3 of 12 defects were introduced by the fixes for earlier ones**) — every change below was independently re-derived, not read off the implementer's transcript.

---

## 2. QA-5 (prior BLOCKER) — RESOLVED, independently verified

**Claim under test:** one new step in `vendored-integrity-check` covering `AC-B5-1` (count == 108, both sides) and `AC-B5-4` (per-path presence/absence, 4 sub-checks × 2 paths); purely additive; actually running in CI.

**Method — fixture reproduction, not narrative trust:**

- Copied `cowork.lock.json`, `.cowork-allowlist.json` and `vendored/agency-agents/` to a scratch fixture and ran the step's logic verbatim: **GREEN** (`AC-B5-1 PASSED — lock=108 disk=108`, `AC-B5-4 PASSED`).
- Proved **all 6 legs independently RED** by mutating one leg at a time, reverting between tests:
  1. Lock count → 107 — **RED** (`LOCK_COUNT=107`)
  2. Disk count → 109 — **RED** (`DISK_COUNT=109`)
  3. Deleted file restored to disk — **RED** ("file present on disk")
  4. Deleted file's entry restored to lock — **RED** ("present in lock")
  5. `blocked_files` full-path entry removed — **RED** ("not in blocked_files")
  6. `blocked_patterns` basename entry removed — **RED** ("not covered by blocked_patterns")
- Confirmed the step sits inside `vendored-integrity-check`, which has **no job-level `if:`** (unlike the `pull_request`-only `vendored-removal-ledger`) — so it runs on `push` too.
- Confirmed it *actually executed* rather than merely existing in the file: `gh run view 31257755812` → step `Assert vendored count == 108 and the two v2.19.7 removals are complete (AC-B5-1, AC-B5-4)` → **success**.
- Confirmed "purely additive" rather than accepting the claim: `git diff b13ad42..bf2704f --numstat -- .github/workflows/quality.yml` → `82  0`, exactly 1 hunk, **zero** removed lines. The other 29 jobs are byte-identical.
- YAML re-validated.

**Verdict: PASS.**

---

## 3. QA-1 (prior non-blocking) — RESOLVED

`docs/risk-register.md` gains row `v2.19.7-LEDGER-FP`: states the cause (the bare-basename `nexus-strategy.md` repair reads as a *removal* to `verify-lock-removals.sh`'s literal path-string diff), states explicitly why no protection is lost (both the repaired full-path `blocked_files` entry and the unchanged `blocked_patterns` entry cover the file), and is cross-linked from a new `CHANGELOG.md` "Known, accepted CI signal on this PR" callout — discoverable by someone reading the PR cold rather than buried.

ADR-080 §Maturation Path gained a REPAIRED-classification future option and revisit trigger (e) — *"the second time a `blocked_files` path repair trips `AC-B5-8`"* — correctly filed under the existing three binding headers.

**Deliberately not built as control logic.** Adding a blocking dimension to a control introduced in this same cycle raises the odds the control itself is wrong — the same reasoning @security used to decline S11.

**Verdict: PASS.**

---

## 4. QA-2 (prior non-blocking) — RESOLVED

`docs/design-v2.19.7.md` §J records the `AC-D1-1` h3→h2 heading-level deviation and its rationale (matches `templates/public-artifact/release-body.md`'s existing h2 convention). The firing negative control was **independently re-run** against the real `CHANGELOG.md` `[2.19.7]` section rather than taken on trust: h2 count = 1, h3 count = 0. Matches exactly.

**Verdict: PASS.**

---

## 5. QA-4 (prior non-blocking) — RESOLVED

`docs/design-v2.19.7.md` §E corrected to 26 paths with `docs/roadmap.md` named. §K's ADR-INDEX clarification (an in-file `## ADR Index` table at `architecture.md:11`, not a missing file) matches the independent Phase-5 conclusion.

**Verdict: PASS.**

---

## 6. QA-3 (prior BLOCKER) — missing-finding theory REFUTED

The original blocker theory was that a 6th HIGH finding had gone undisclosed. **Refuted by evidence.**

The audit contains exactly 6 finding IDs: `C-1, H-1, H-2, H-3, H-4, H-5`. `C-1` (B1) and `H-3` (B2) are the two deletions, leaving **4 IDs**. Counted by flagged *location* rather than finding ID — H-2's two files counted separately, H-5's seven-file group counted as the single item it was filed as — those same 4 IDs cover **5 locations**. Both numbers are correct; they count different things.

`vendored/README.md`'s reworded text now states the unit explicitly and reads unambiguously to an outside reader. **No evidence of a genuinely missing finding.**

---

## 7. Lint / CI / portability

- `shellcheck scripts/*.sh` → **0 findings**.
- `.github/workflows/quality.yml` parses valid.
- CI on `bf2704f`: **29/29 applicable jobs green**. `vendored-removal-ledger`, `lock-content-sha-cross-check` and `/sync-agency Dry-Run` correctly `skipped` (PR-only triggers, no PR open at the time).
- Bash 3.2 portability confirmed on all three new scripts — no `mapfile`/`readarray`/`declare -A`.

---

## 8. Phase-4 boundary — holds

```text
git tag --list | grep -E "v2\.19\.[567]"              -> (none)
git ls-remote --tags origin | grep -E "v2\.19\.[567]"  -> (none)
gh release list --limit 5                              -> latest still v2.19.4
grep -c "not yet filed" upstream-contribution/v2.19.7-pr-tracking.md -> 4
```

No tags created, no Releases published, no upstream PRs filed, no live `gh` writes. Publishing is post-merge and owner-approved, matching the v2.19.6 precedent.

---

## 9. The one finding this pass produced — since FIXED

**The fix pass introduced a new defect exactly where the v2.19.6 pattern predicts one** — a partial edit that corrected one occurrence and missed its neighbour two paragraphs up.

`CHANGELOG.md`'s `[2.19.7]` entry contradicted itself: line 24-25 (untouched) read *"1 CRITICAL and 7 HIGH findings"*, while line 35-37 (edited) read *"4 remaining HIGH findings (across 5 flagged files)"*. Seven minus one deletion implies six, not four. `docs/spec.md:6723` carried the same stale tally.

**Root cause:** "7 HIGH" is the audit coverage table's per-**file** tally; every other claim in this cycle counts **finding IDs**. The two units were never reconciled, and the audit's own file-level tally does not reconcile against its findings text either.

**Fix applied (orchestrator, post-report):** both surfaces now state the count by finding ID — `CHANGELOG.md` reads *"1 CRITICAL and 5 HIGH findings (`C-1`, `H-1` through `H-5`)"*, making the arithmetic self-consistent (5 HIGH − 1 deleted = 4 remaining), and `docs/spec.md:6723` names both units explicitly and says which one downstream claims use.

This mattered because `CHANGELOG.md` is **not** in `DROP_PATHS` — it ships in the public release ZIP. A public document making an internally-contradicting numeric claim is precisely the defect class this cycle exists to eliminate.

---

## Issues Found

| ID | Status |
|---|---|
| QA-5 | ✅ RESOLVED — fixture RED/GREEN ×6, live CI execution confirmed, purely-additive diff verified |
| QA-1 | ✅ RESOLVED — documented and cross-linked; control logic deliberately not built |
| QA-2 | ✅ RESOLVED — deviation recorded with an independently re-run firing control |
| QA-4 | ✅ RESOLVED — classification list corrected to 26 paths |
| QA-3 | ✅ REFUTED — no missing finding; wording units now explicit |
| CHANGELOG count contradiction | ✅ FIXED post-report (§9) |

## Verdict

**PASS WITH WARNINGS.** All five prior findings are resolved with independent verification rather than narrative trust. The single new finding was narrow, mechanical, and has been fixed; no further dev pass or design change is required.
