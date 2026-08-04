# Next steps — as of 2026-08-03

**What this is:** the ordered sequencing that came out of the 2026-08-03 Decision Council, written down so the next session doesn't have to re-derive it.

**What this is not:** a fourth ledger. `docs/roadmap.md` owns the version ladder, `docs/owner-tasks.md` owns owner-blocked items, and `docs/spec.md` owns per-cycle scope. This file points at those rows; it never restates their status. If they disagree with this file, they win and this file is stale.

---

## The sequencing

**Publish now. Rung 1 next. Persona conversion stays where it is.**

| # | Step | Owner | Canonical row | State |
|---|---|---|---|---|
| 1 | ~~Post the announcement to LinkedIn + Telegram~~ | **Owner** | `owner-tasks.md` OT-1 | **HELD 2026-08-03** — owner decision, pending the upstream-integration question below. No task blocks it; the copy is approved and its prerequisites are closed. |
| 2 | Ship Rung 1 (`v2.19.5`) | Pipeline | `spec.md` v2.19.4 §Roadmap Context | Not started — hard deadline, cron re-fires **2026-09-01** |
| 3 | Close the `v2.19.4` retro | Pipeline | pipeline Phase 8 | Closed 2026-08-03 via PR #98 |
| 4 | Catalog submissions | **Owner** (one browser check) | `owner-tasks.md` OT-3 | `ComposioHQ` clear; `travisvn` blocked by its own rules; `claudepluginhub` needs a human look |
| 5 | Re-run the sourcing scan on the vendored personas | Pipeline, **after** step 2 | `roadmap.md` "Later" | Not scheduled — a cheap read, not a build |

Step 1 does not wait on step 2. They are independent, and holding the announcement costs discovery time in a niche that already has three competing projects.

### Rung 1 scope (`v2.19.5`)

Three items, all small, all in the same blast radius:

1. **`sync-agency.yml` integrity redesign.** The check at `:221-227` compares the stored `content_sha256` against bytes fetched at the *new* upstream HEAD, so any legitimate upstream edit hard-fails as tampering. It has failed 2026-07-01 and 2026-08-01. This is the deadline item.
2. **`release-assets.yml` `body_path`.** Carry-forward `CF-v2.19.3-A`. This defect was reported closed at v2.19.2 without touching what produces it, and regenerated on the very next tag push — a repeat, not a new finding.
3. **Two false claims in `roadmap.md`** — see below.

---

## What we decided *not* to do, and why

**No persona→SKILL.md conversion bridge ahead of Rung 1.** The v2.10.0 cycle already ran a tiered adapt-vs-author scan against these exact 110 vendored files and found **0 of 110** conform to the 9-section template — 0 external adopt, authored from scratch instead, codified as **ADR-043** (`docs/retro.md:1037`). Conversion means authoring 110 skills from scratch, each through the `PROMOTE.md` PR-gated ceremony plus a fresh WS-EVAL re-grade. That is a program, not a rung. It stays where `roadmap.md` already put it: demand-gated, its own `/spec`, timing open.

**No deletion of the vendored corpus either.** Deleting it would remove the monthly CI burden and the reachability gap in one move — and it is the only irreversible option on the table. `roadmap.md` still carries persona conversion as a live candidate whose stated advantage is that the content is already vendored and license-cleared. Don't destroy the input while the decision is open.

**The 110 personas remain unreachable as installable skills**, and that is the current, understood state — not a defect to hot-fix. The registry references them zero times, `WIZARD.md:26` forbids fetching upstream during a live session (deliberate — it is what makes "no network call at setup" true), and `WIZARD.md:310` archives `vendored/` into `_setup-kit/` at handover. Nothing in the announcement copy claims otherwise.

---

## Two corrections queued for Rung 1

Both are in the persona row at `roadmap.md`. **Both closed in v2.19.5** — recorded here for the historical record; `roadmap.md` is the canonical current text.

- **"73 of 110 are non-engineering"** — the row's own parenthetical breakdown sums to **81**. Verified against `cowork.lock.json` `files[]`: 29 engineering, 81 non-engineering, 110 total. `roadmap.md:55` corrected in v2.19.5.
- **"kept current by `.github/workflows/sync-agency.yml`"** — untrue since 2026-07-01. The pin had not moved from `2026-05-07`; the workflow hard-failed twice (2026-07-01, 2026-08-01). v2.19.5 (ADR-075) fixes the root cause — the tamper check compared bytes fetched at the new upstream HEAD against the old pin's stored hash, so it failed on every legitimate edit — and the fix is verified end-to-end against the live 110-entry lock (`scripts/verify-lock-content-sha.sh cowork.lock.json` → `verified=110`) before this correction was made.

The first is a *check-that-cannot-fail* on the authoring side rather than the verify side: a number that reads as self-evidencing because its own proof sits beside it, where nobody ever performs the addition. It survived two cycles and was restated as verified fact before anyone summed the components. Candidate for a cheap doc lint — find an `N of M` adjacent to a parenthesized count list, assert the sum.

---

*Derived from a five-lens Decision Council run on 2026-08-03, unanimous against the queue jump. The verdict record lives in the hub repo's project state and is not public.*
