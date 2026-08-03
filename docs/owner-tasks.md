# Owner Task Ledger

Tasks that only the project owner can act on — a repo Settings click, a live-render visual check, a hand-drafted PR to a third-party repo, a "does this still sound like me" judgment. These have historically disappeared into retro prose instead of living somewhere durable (see `docs/retro.md` v2.19.3 §9: `AC-DIST-2`/`AC-BRDTH-10` sat unresolved across 12 releases before this ledger existed). This file is that durable home.

**Schema (exactly 7 columns — deliberately no "was this checked recently" column):**

`ID | task | created (version) | what it blocks | status | age (releases) | deferral count`

A column tracking when a row was last touched was deliberately left out at design time. It was flagged, in the council verdict that shaped Rung 2's design, as a rubber-stamp generator — a column that gets updated on every pass without anyone re-evaluating the row it belongs to. Its absence here is a decision, not an oversight.

**Non-goal, stated plainly:** no CI job enforces this document's freshness this cycle (v2.19.4). The enforcing gate (`owner-task-expiry-check`) is **Rung 2 (v2.20)** scope, not this one's — and per the council's verdict, that gate's own design (rubber-stamp-proof expiry logic) still needs to survive its own check-that-cannot-fail proof before it ships, which is exactly why it is a separate, later cycle rather than something rushed in here. Until Rung 2 ships, rows in this ledger age only by manual retro review.

## Ledger

| ID | task | created (version) | what it blocks | status | age (releases) | deferral count |
|---|---|---|---|---|---|---|
| OT-1 | Post the public announcement (LinkedIn + Telegram, copy approved) | v2.19.3 | intake demand-gate clock; all organic discovery signal | **HELD BY OWNER 2026-08-03** — pending resolution of the upstream-repo integration question. Prior prerequisites are all closed (OT-2 `REGENERATED, verified 2026-08-03`; OT-5 `SET, verified 2026-08-03`) and the copy is approved, so this is **not** blocked on any remaining task — it is an owner decision to hold. Note this **reverses** the 2026-08-03 Decision Council's unanimous "publish now" recommendation, which found the approved copy makes no upstream and no dynamic-selection claim and is therefore not made untrue by the gap. The owner's call stands; the consequence is that the upstream-integration question is now **load-bearing on OT-1**, which it was not when the council ran. | 2 releases | 1 |
| OT-2 | De-slop `assets/setup-demo.svg` | v2.8.1 | OT-1 | `REGENERATED, see assets/setup-demo.svg, verified 2026-08-03` — owner: *"Demo is good to go,"* a fresh visual check on the v2.19.4 regenerated asset. Mechanical de-slop shipped *this cycle* (v2.19.4); the owner's prior check had **rejected** the pre-regeneration asset ("too many —"), and per the `AC-BRDTH-10` precedent (v2.19.3, `C-v2.19.3-1`) the regenerated asset re-inherited the same visual-check obligation rather than the prior rejection's fix counting as sign-off — which is why the shipped fix alone did not auto-close this row. **Closes an item carried since v2.8.1 — 12 releases.** | 12 releases | 1 |
| OT-3 | Catalog submissions (3 targets researched, 0 submitted) | v2.19.3 | discovery breadth | OPEN — drafts pending, rules verification in progress (see below) | 1 release | 0 |
| OT-4 | Review/merge any sync-agency PR the repaired cron opens | (arms when Rung 1 ships — not yet numbered; do not hardcode v2.19.4/.5 here, see the version-collision note in `docs/spec.md` v2.19.4 Roadmap Context Summary §6) | upstream currency | OPEN — dormant until Rung 1 ships | n/a | 0 |
| OT-5 | Upload the social preview image in repo Settings | v2.19.4 | OT-1 | `SET, verified 2026-08-03` — see AC-SOCIAL-4 disposition below | 0 releases | 0 |
| OT-6 | `@ux` F8 — b2/b6 telegraphic dialogue tone | v2.19.3 | v2.21's voice-pass AC (`AC-BRIDGE-5`) | DEFERRED-UNTIL-v2.21-Phase-0 (milestone-conditioned, not calendar-conditioned — see Edge Cases note in `docs/spec.md` v2.19.4) | 1 release | 1 |

## Tracked candidates (no action forced yet)

- **NAMING** — tracked, no action; see internal competitive analysis. `created: v2.19.4, blocks: nothing yet, status: OPEN (tracked, no action)`.
- **AGENCY-AGENTS PERSONA CONVERSION** — evaluate converting vetted `msitarzewski/agency-agents` vendored personas into pool skills. This is not new content exposure: all 110 files are already vendored (SHA-pinned in `cowork.lock.json`, pin `783f6a72`), already MIT-attributed (`THIRD-PARTY-NOTICES.md`), already kept current by `.github/workflows/sync-agency.yml`. 73 of 110 are non-engineering (marketing 30, design 8, sales 8, testing 8, project-management 6, support 6, academic 5, finance 5, product 5) and map directly onto this kit's existing presets — the open question is conversion effort and demand, not licensing or sourcing. Two real caveats: (a) personas are not 9-section SKILL.md files — conversion is genuine authoring work, not a copy; (b) pool entry runs through `PROMOTE.md`'s PR-gated maintainer ceremony with a fresh WS-EVAL re-grade at the boundary — nothing enters the pool by import. `created: v2.19.4, blocks: nothing yet, status: OPEN (tracked, no action)`. Also tracked in `docs/roadmap.md`'s `## Later (not yet versioned)` section.
- **GUILDSKILLS KIT-VS-SKILL FIT** — resolve whether this repo's 25-skill pool would register with GuildSkills (guildskills.com, auto-indexed) as 1 entry, 25 entries, or 0, before any recommendation to submit there is made (AC-OT3-2, v2.19.4 — asked, not answered). `created: v2.19.4, blocks: nothing yet, status: OPEN (tracked, no action)`.

## OT-5 disposition (AC-SOCIAL-4 / AC-SOCIAL-5)

Uploading `assets/social-preview.png` as the repo's GitHub social preview image is an **owner-only action** — GitHub exposes no API for this (`gh api` has no endpoint for `open_graph_image_url`; the only path is Settings → General → Social preview → Upload an image, in the web UI). No agent may mark this row `SET`, and no agent may script or automate the Settings UI to route around that boundary.

**Disposition: `SET, verified 2026-08-03`.**

Verification performed (owner-reported, not agent-executed — GitHub's Settings UI is the only upload path and remains outside any agent's reach): the repo page's `og:image` meta tag now resolves to `repository-images.githubusercontent.com/...` — GitHub's custom-uploaded-image CDN, not the `opengraph.githubassets.com` auto-generated fallback. The served image was downloaded and byte-compared against `assets/social-preview.png`: identical — 1280×640, 56,042 bytes, `cmp` clean. The live card is the authored asset, not a stale or regenerated substitute.

Noted for future cycles so the same bad check isn't re-run: the REST API's `open_graph_image_url` field reads empty regardless of upload state — it is simply never populated in REST responses on this repo, an unreliable probe rather than evidence of failure. The `og:image` meta tag is the correct ground truth.

The owner recorded one of the following once they acted on it:
- `SET, verified <date>` — uploaded and confirmed rendering on a real link-preview surface. **(this row's outcome — 2026-08-03)**
- `ASSET-READY — DEFERRED, owner has not yet uploaded it` — prior state, now superseded.
- `REJECTED, needs rework` — the card doesn't represent the kit well; asset needs another pass.

## OT-2 disposition (AC-DEMO-3 / owner visual check)

The mechanical de-slop (em-dash reduction, beat/geometry preservation) shipped this cycle and is independently verified — see `docs/spec.md` v2.19.4 Scope 1's ACs. The *substance* check (does the regenerated demo still read as the owner's own voice, once rendered) remains an owner-only, agent-impossible judgment call, per this repo's standing `AC-DIST-2`/`AC-BRDTH-10` precedent. No agent may flip this to `DONE`. Owner records `REGENERATED, see assets/setup-demo.svg, verified <date>` once they've viewed the live render, or `REJECTED — needs rework` if it still reads wrong.
