# Owner Task Ledger

Tasks that only the project owner can act on — a repo Settings click, a live-render visual check, a hand-drafted PR to a third-party repo, a "does this still sound like me" judgment. These have historically disappeared into retro prose instead of living somewhere durable (see `docs/retro.md` v2.19.3 §9: `AC-DIST-2`/`AC-BRDTH-10` sat unresolved across 12 releases before this ledger existed). This file is that durable home.

**Schema (exactly 7 columns — deliberately no "was this checked recently" column):**

`ID | task | created (version) | what it blocks | status | age (releases) | deferral count`

A column tracking when a row was last touched was deliberately left out at design time. It was flagged, in the council verdict that shaped Rung 2's design, as a rubber-stamp generator — a column that gets updated on every pass without anyone re-evaluating the row it belongs to. Its absence here is a decision, not an oversight.

**Non-goal, stated plainly:** no CI job enforces this document's freshness this cycle (v2.19.4). The enforcing gate (`owner-task-expiry-check`) is **Rung 2 (v2.20)** scope, not this one's — and per the council's verdict, that gate's own design (rubber-stamp-proof expiry logic) still needs to survive its own check-that-cannot-fail proof before it ships, which is exactly why it is a separate, later cycle rather than something rushed in here. Until Rung 2 ships, rows in this ledger age only by manual retro review.

## Ledger

| ID | task | created (version) | what it blocks | status | age (releases) | deferral count |
|---|---|---|---|---|---|---|
| OT-1 | Post the public announcement (LinkedIn + Telegram, copy approved) | v2.19.3 | intake demand-gate clock; all organic discovery signal | OPEN — blocked by OT-2 + OT-5 | 1 release | 0 |
| OT-2 | De-slop `assets/setup-demo.svg` | v2.8.1 | OT-1 | mechanical de-slop done *this cycle* (v2.19.4); **owner visual disposition still pending** — see `docs/spec.md` v2.19.4 Scope 1's AC (no agent may write DONE) | 12 releases | 1 |
| OT-3 | Catalog submissions (3 targets researched, 0 submitted) | v2.19.3 | discovery breadth | OPEN — drafts pending, rules verification in progress (see below) | 1 release | 0 |
| OT-4 | Review/merge any sync-agency PR the repaired cron opens | (arms when Rung 1 ships — not yet numbered; do not hardcode v2.19.4/.5 here, see the version-collision note in `docs/spec.md` v2.19.4 Roadmap Context Summary §6) | upstream currency | OPEN — dormant until Rung 1 ships | n/a | 0 |
| OT-5 | Upload the social preview image in repo Settings | v2.19.4 | OT-1 | asset created + owner-approved *this cycle*; **the Settings upload itself is still pending** — see AC-SOCIAL-4 disposition below | 0 releases | 0 |
| OT-6 | `@ux` F8 — b2/b6 telegraphic dialogue tone | v2.19.3 | v2.21's voice-pass AC (`AC-BRIDGE-5`) | DEFERRED-UNTIL-v2.21-Phase-0 (milestone-conditioned, not calendar-conditioned — see Edge Cases note in `docs/spec.md` v2.19.4) | 1 release | 1 |

## Tracked candidates (no action forced yet)

- **NAMING** — tracked, no action; see internal competitive analysis. `created: v2.19.4, blocks: nothing yet, status: OPEN (tracked, no action)`.
- **AGENCY-AGENTS PERSONA CONVERSION** — evaluate converting vetted `msitarzewski/agency-agents` vendored personas into pool skills. This is not new content exposure: all 110 files are already vendored (SHA-pinned in `cowork.lock.json`, pin `783f6a72`), already MIT-attributed (`THIRD-PARTY-NOTICES.md`), already kept current by `.github/workflows/sync-agency.yml`. 73 of 110 are non-engineering (marketing 30, design 8, sales 8, testing 8, project-management 6, support 6, academic 5, finance 5, product 5) and map directly onto this kit's existing presets — the open question is conversion effort and demand, not licensing or sourcing. Two real caveats: (a) personas are not 9-section SKILL.md files — conversion is genuine authoring work, not a copy; (b) pool entry runs through `PROMOTE.md`'s PR-gated maintainer ceremony with a fresh WS-EVAL re-grade at the boundary — nothing enters the pool by import. `created: v2.19.4, blocks: nothing yet, status: OPEN (tracked, no action)`. Also tracked in `docs/roadmap.md`'s `## Later (not yet versioned)` section.
- **GUILDSKILLS KIT-VS-SKILL FIT** — resolve whether this repo's 25-skill pool would register with GuildSkills (guildskills.com, auto-indexed) as 1 entry, 25 entries, or 0, before any recommendation to submit there is made (AC-OT3-2, v2.19.4 — asked, not answered). `created: v2.19.4, blocks: nothing yet, status: OPEN (tracked, no action)`.

## OT-5 disposition (AC-SOCIAL-4 / AC-SOCIAL-5)

Uploading `assets/social-preview.png` as the repo's GitHub social preview image is an **owner-only action** — GitHub exposes no API for this (`gh api` has no endpoint for `open_graph_image_url`; the only path is Settings → General → Social preview → Upload an image, in the web UI). No agent may mark this row `SET`, and no agent may script or automate the Settings UI to route around that boundary.

**Disposition: `ASSET-READY — DEFERRED, owner has not yet uploaded it.`**

The owner records one of the following once they act on it:
- `SET, verified <date>` — uploaded and confirmed rendering on a real link-preview surface.
- `ASSET-READY — DEFERRED, owner has not yet uploaded it` — current state.
- `REJECTED, needs rework` — the card doesn't represent the kit well; asset needs another pass.

## OT-2 disposition (AC-DEMO-3 / owner visual check)

The mechanical de-slop (em-dash reduction, beat/geometry preservation) shipped this cycle and is independently verified — see `docs/spec.md` v2.19.4 Scope 1's ACs. The *substance* check (does the regenerated demo still read as the owner's own voice, once rendered) remains an owner-only, agent-impossible judgment call, per this repo's standing `AC-DIST-2`/`AC-BRDTH-10` precedent. No agent may flip this to `DONE`. Owner records `REGENERATED, see assets/setup-demo.svg, verified <date>` once they've viewed the live render, or `REJECTED — needs rework` if it still reads wrong.
