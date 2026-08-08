# Design — Cowork Starter Kit v2.19.7 "Finish the Storefront, Ship What We Read"

> **Held in hub state, lands in the repo at Phase 4.** `docs/design-*.md` matches no entry in `orchestrator-guard.sh`'s pre-gate allow-list, and this is consistent with actual practice rather than an obstruction: `docs/design-v2.19.6.md` landed in `b7ec836`, the v2.19.6 **feature PR**, post-gate. Authored by @architect at Phase 1 (2026-08-08); landed to `docs/design-v2.19.7.md` by @dev at Phase 4.
>
> Branch: `release/v2.19.7-finish-the-storefront` · Base: `main` @ `fe25660` · Classification: **SECURITY-SENSITIVE Tier A (GCS required)** + COMPLIANCE-SENSITIVE.

## §A Context

Baseline `main` @ `fe25660`, VERSION `2.19.6`, clean, 0 open PRs/issues. Two convergent gaps: a storefront that does not work (`/releases/latest` → `v2.19.4`, 0 assets; `Release Surface` red on 3 consecutive runs) and a vendored tree that had never been read (1 CRITICAL, 7 HIGH found by reading all 110 files).

Settled inputs, not re-opened: the owner's locked delete-2 / disclose-5 / upstream-4 decision; the `vendored/`-cannot-be-excluded premise; the proven `CF-v2.19.6-A` root cause.

## §B OQ-3 reconciled with F4

@architect's Phase 0.D objection to both posed options was that they verify an archive **rebuilt independently** of the one uploaded, and verify **after** publication. The pre-upload gate removed the rebuild on the prevention side but left CI asserting against a rebuild — the very thing objected to. **@security's F4(b) resolves that residue: don't rebuild, download the published asset.** The two findings solve different halves of one flaw.

```
scripts/release-archive-assert.sh   <- sole home of DROP_PATHS[] / KEEP_PATHS[]
    │
    ├── publish-release.sh          (a) PREVENTION — authoritative, fail-closed
    │     git archive $TARGET_SHA -> assert THOSE files -> upload THOSE files
    │     (no rebuild between assert and upload)
    │
    └── release-assets.yml          (b) DETECTION — post-hoc, push: tags retained
          gh release download -> assert the bytes GitHub actually serves
```

Three properties neither posed option had:

1. **The gate precedes publication.** Both posed options verified after assets were already public.
2. **The "byte-identical" assumption becomes a checked property rather than a silent premise.** A divergence between (a) and (b) is now a detected event.
3. **The manual-tag net survives.** `release-assets.yml:108` records the `push: tags` trigger as the deliberate catch for anyone tagging with a plain `git push`. Verification makes no write API call, so it cannot reintroduce the `403`.

## §C New control surfaces (3 scripts)

- **`scripts/release-archive-assert.sh`** — sole home of `DROP_PATHS[]` / `KEEP_PATHS[]`. Takes an archive path, exits non-zero on violation. Called by both sites. Single-sourcing is binding: two copies of a negative list drift, and **a drifted DROP list fails open**. Precedent stated in-repo at `verify-release-surface.sh:95-96`.
- **`scripts/verify-vendored-orphans.sh`** — the disk→lock direction. Called by `quality.yml`'s `vendored-integrity-check` on every PR, and by `publish-release.sh` before the archive is built.
- **`scripts/verify-lock-removals.sh`** — asserts `removed_paths ⊆ blocked_files_paths` across two lock revisions. Wired into `quality.yml` on `pull_request` (base..head).

## §D Sequencing — BINDING, and unmissable to @dev

**C1 is built FIRST and is the instrument that proves B5.** The forward-only check structurally cannot prove a deletion — verified on three independent lines (`quality.yml:1614`/`:1637`; `verify-lock-content-sha.sh:53`/`:77`; and no disk-side enumeration exists anywhere in the repo).

1. Build `verify-vendored-orphans.sh` + CI wiring.
2. **Prove it fires** — add an orphan fixture → RED; remove → GREEN.
3. *Only then* B1/B2 deletions + lock 110 → 108.
4. **Prove B5 with the instrument from (1)** — restore one deleted file → RED; re-delete → GREEN.
5. `blocked_files` (full-path) + `blocked_patterns` (basename) entries, each with its firing negative control.
6. `verify-lock-removals.sh`, exercised by this PR's own 2 removals.

**Do not reorder for scheduling convenience.**

## §E `PostOQClassificationReRun` — CONFIRMED

The file list was completed **first** (15 → **25 paths**), then the re-run executed against the complete list — otherwise it would have run against a list known to be wrong.

**Outcome: CONFIRMED — SECURITY-SENSITIVE, Tier A, GCS required.** Not ESCALATED (already at ceiling), not DOWNGRADED. Three of the ten additions are themselves new control surfaces that independently reach Tier A, so the completed list reinforces the classification rather than perturbing it. COMPLIANCE-SENSITIVE co-occurs.

Additions beyond the spec's 15: `VERSION`, `CHANGELOG.md`, `upstream-contribution/**`, `docs/spec.md`, `docs/design-v2.19.7.md`, the 3 new scripts, `templates/workspace-claude-md-template.md`, `CLAUDE.md`, `CONTRIBUTING.md`.

> **Correction (Phase 5, QA-4):** `docs/roadmap.md` is also modified this cycle (a version-number string only) and was omitted above — the list is 26 paths, not 25. See §K for the full note; classification outcome is unchanged (already at Tier-A ceiling on other grounds).

## §F OQ-2 — routed to the user gate

- **Branch (a):** add the job as a required status check + `AC-C2-1` — makes "refuses to merge" true, but requires an **owner-side GitHub Settings change no agent can make** (`required_status_checks` verified empty) and permanently changes the repo's merge ergonomics on a solo repo.
- **Branch (b):** correct `architecture.md` to describe what is actually true — flagged-for-mandatory-human-review, matching the CODEOWNERS gate already on supply-chain files. Zero owner action; leaves the stronger claim unmade.

**No recommendation ranked** — the cost falls on the owner, and (a) is not reversible by an agent.

## §G Anti-pattern scan (11-point)

Two dispositioned. **Leaky Abstraction — avoided:** the DROP/KEEP list sits behind one script interface rather than duplicated across caller and CI. **Missing Separation of Concerns — avoided:** orphan detection is its own script rather than bolted into `vendored-integrity-check`'s loop, so `publish-release.sh` can call it without importing CI concerns.

No God Module, no circular dependencies, no N+1, no premature optimisation, no over-engineering. **One Destructive Migration (B1/B2 deletions)** — explicitly backed by `AC-B5-7`'s removal ledger, which is the required explicit backup plan: a removal not declared in `blocked_files` fails closed.

## §H F6 CODEOWNERS deferral — recorded, not silent

`vendor-agency.sh` and `canonicalize-scan.sh` are deferred this cycle. Recorded here so the deferral is explicit rather than an omission. Added instead: `semver-compare.sh` and `release-assets.yml` (both edited this cycle) plus the 3 new control scripts.

## §I F9 — public-ZIP surface acknowledged

The DROP list is a *negative* list; only `docs/spec.md`, `docs/retro.md`, `docs/patterns.md`, `docs/internal/` are excluded. So `qa-report-*.md`, `security-audit-*.md`, `security-review-*.md` and `risk-register.md` — all at `docs/` root — ship in the public ZIP, and **this design doc will too** when it lands at Phase 4, exactly as `docs/design-v2.19.6.md` did in `b7ec836`. Conscious choice under ADR-037's radical-transparency convention, not an oversight.

## §J Implementation notes (@dev, added at Phase 4 landing)

Recorded here rather than only in the PR description, since this file is the durable design record.

- **AC-A1-0 / precondition placement:** the version+tag-commit precondition is implemented as two guard blocks inside `publish-release.sh` — one before the idempotent-skip/repair decision (covers all three branches uniformly for the tag-commit-equality half) and the existing create-path-only VERSION-at-HEAD check is retained as-is (it already only guards the create branch, which is correct — repair/idempotent-skip do not create a new tag, so there is no "requested version" to compare against a differing `TARGET_SHA`'s `VERSION`; what changes is that the destination-write itself, not just the tag-creation, is now gated on `$TARGET_SHA`'s own committed `VERSION` matching the requested one on every branch).
- **Backfill caveat mechanism (A2):** implemented as an opt-in `PUBLISH_BACKFILL_CAVEAT=1` environment variable read by `publish-release.sh`, which prepends a fixed caveat block (naming both B1/B2 removed paths and pointing to `vendored/README.md`'s B3 disclosure section) to `NOTES_FILE` before either the create or repair branch runs — never applied via a later `gh release edit`. Never set for the v2.19.7 publish itself; the orchestrator sets it only for the two backfill publishes (v2.19.5, v2.19.6), which remain orchestrator-run per the task's publish boundary.
- **B4 (upstream PRs):** `upstream-contribution/` gains one patch-plus-cover-note bundle per finding (H-1, H-2, H-4, H-5), ready for the owner/orchestrator to open as PRs against `msitarzewski/agency-agents` — filing them is an external-repo public write outside `@dev`'s authority (same boundary as the "do not publish" instruction for this repo's own Releases) and is left to the orchestrator with explicit owner sign-off.
- **AC-D1-1 heading-level deviation (recorded, per Phase-5 QA-2 finding).** The spec's literal text asks for a `### Full changelog` (h3) section; the implementation in `publish-release.sh` (the "1a. Append a 'Full changelog' link section" step) emits `## Full changelog` (h2) instead. This is a deliberate deviation, not a miss: `templates/public-artifact/release-body.md:25` — the pre-existing, unchanged template that governs every *hand-curated* release body in this repo — already uses `## Full changelog` (h2). Matching that established convention, so a script-generated body and a hand-curated body share one heading-level rule, was judged more valuable than literal conformance to the AC's heading level, which is not otherwise load-bearing (`body_names_version()` matches on the dotted/anchor version string, not on any heading text or level). Firing negative control (added at Phase 4, re-runnable by @qa): extract the `## [2.19.7]` CHANGELOG section, run it through the same anchor-derivation pipeline `publish-release.sh` uses, and assert `grep -c '^## Full changelog$'` returns exactly 1 and `grep -c '^### Full changelog$'` returns 0 against the generated notes file — proving the emitted heading level is what this note claims, not merely asserting the substring "changelog" appears somewhere (which the pre-fix body already satisfied via its own CHANGELOG excerpt, and would not have distinguished h2 from h3).

## §K Phase-5 QA findings folded in (this file, per QA-2/QA-4)

- **QA-4 classification-list correction:** `docs/roadmap.md` is modified this cycle (the "Where we are" version bump, `v2.19.4` → `v2.19.7`) but was omitted from §E's file list. §E's count and file list should be read as 26 paths, not 25 — `docs/roadmap.md` added. Low-risk content-only change (a version-number string), does not itself change the Tier-A/GCS classification (already at ceiling on other grounds per §E).
- **QA-4 non-finding, confirmed:** the "docs/ADR-INDEX.md" reference in this file's own earlier drafting was to the **in-file `## ADR Index` table at `docs/architecture.md:11`** (this repo's actual convention, per `CONTRIBUTING.md`), not a separate missing file — `docs/ADR-INDEX.md` does not exist in this repo and none was expected. @qa confirmed this is not a defect; recorded here only so the record is unambiguous for a future reader.
