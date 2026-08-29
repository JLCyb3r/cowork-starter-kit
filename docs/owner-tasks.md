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
| OT-4 | Review/merge any sync-agency PR the repaired cron opens | (arms when Rung 1 ships — not yet numbered; do not hardcode v2.19.4/.5 here, see the version-collision note in `docs/spec.md` v2.19.4 Roadmap Context Summary §6) | upstream currency | OPEN — ARMED: Rung 1 shipped at tag `v2.19.5`, 2026-08-04; fires on the next scheduled `sync-agency.yml` cron run | n/a | 0 |
| OT-5 | Upload the social preview image in repo Settings | v2.19.4 | OT-1 | `SET, verified 2026-08-03` — see AC-SOCIAL-4 disposition below | 0 releases | 0 |
| OT-6 | `@ux` F8 — b2/b6 telegraphic dialogue tone | v2.19.3 | a future voice-pass AC (`AC-BRIDGE-5`) — no live milestone target | DEFERRED — NO LIVE TARGET: the deferral previously named `v2.21`, which does not exist in `docs/roadmap.md` (0 occurrences; control `v3.0` → 13). Needs re-anchoring to a real rung at the next planning cycle. Milestone-conditioned, not calendar-conditioned — see Edge Cases note in `docs/spec.md` v2.19.4 | 1 release | 1 |
| OT-7 | Enable a branch-protection review gate requiring CODEOWNERS approval on PRs touching `cowork.lock.json` and the other supply-chain rows in `.github/CODEOWNERS` | v2.19.5 | supply-chain PR review enforcement (`AC-SYNC-CODEOWNERS-1`) | OPEN — this is a **two-step remedy, in order**, and only step 1 is done. **Step 1 (DONE, v2.19.5):** `.github/CODEOWNERS`'s six supply-chain rows were re-pointed from `@msitarzewski` to `@jmlozano1990`. `@msitarzewski` is the **upstream** repo's owner (`msitarzewski/agency-agents`), not a collaborator on this repo — GitHub ignores CODEOWNERS entries for users without write access, so those six rows were **inert**, not merely unenforced, before this cycle. **Step 2 (OPEN — owner action):** enable `require_code_owner_reviews` (and, ideally, `required_approving_review_count ≥ 1`) in repo Settings → Branches. Doing step 2 without step 1 having already landed would have deadlocked every `cowork.lock.json` PR against a reviewer who could never approve; that trap is now closed, but the toggle itself still requires an owner with Settings access. **Context this task inherits:** v2.19.5 also repairs `sync-agency.yml`'s integrity check, re-arming a third-party content ingestion path that had been dormant (frozen pin) since 2026-07-01, into a repo where — until step 2 is taken — no automated or human approval is required to merge a sync PR. See `docs/risk-register.md`'s matching row for the full enforcement-gap statement. | 0 releases | 0 |
| OT-8 | Confirm `tests/offline-smoke-test.md`'s scorecard is current BEFORE running Scope A (`v2.19.6` "Publish What Shipped" — backfilling `v2.19.4`, `v2.19.5`, then publishing `v2.19.6` itself, three tags in one sitting) | v2.19.6 | Scope A's three `scripts/publish-release.sh` publishes | BREACHED (past, not pending) — the obligation fired 3 times (once per tag: `v2.19.4` 2026-08-03, `v2.19.5` 2026-08-04, `v2.19.6` 2026-08-07) and was discharged 0 times: the last recorded `tests/offline-smoke-test.md` scorecard run is 2026-07-18, pre-dating all three tags, with no intervening entry. `CONTRIBUTING.md`'s pre-release checklist binds every tag pushed to a current smoke-test scorecard (`[P1-CORRECTION-5]`, `docs/spec.md`); this is a maintainer step no CI gate can enforce. The README "15 minutes" hero claim shipped unverified for all three releases. Status-accuracy correction only — performing a new scorecard run is a separate, owner-timed action, out of scope here. | 0 releases | 0 |

## Tracked candidates (no action forced yet)

- **NAMING** — tracked, no action; see internal competitive analysis. `created: v2.19.4, blocks: nothing yet, status: OPEN (tracked, no action)`.
- **AGENCY-AGENTS PERSONA CONVERSION** — evaluate converting vetted `msitarzewski/agency-agents` vendored personas into pool skills. This is not new content exposure: all 110 files are already vendored (SHA-pinned in `cowork.lock.json`, pin `783f6a72`), already MIT-attributed (`THIRD-PARTY-NOTICES.md`), already kept current by `.github/workflows/sync-agency.yml`. 73 of 110 are non-engineering (marketing 30, design 8, sales 8, testing 8, project-management 6, support 6, academic 5, finance 5, product 5) and map directly onto this kit's existing presets — the open question is conversion effort and demand, not licensing or sourcing. Two real caveats: (a) personas are not 9-section SKILL.md files — conversion is genuine authoring work, not a copy; (b) pool entry runs through `PROMOTE.md`'s PR-gated maintainer ceremony with a fresh WS-EVAL re-grade at the boundary — nothing enters the pool by import. `created: v2.19.4, blocks: nothing yet, status: OPEN (tracked, no action)`. Also tracked in `docs/roadmap.md`'s `## Later (not yet versioned)` section.
- **GUILDSKILLS KIT-VS-SKILL FIT** — resolve whether this repo's 25-skill pool would register with GuildSkills (guildskills.com, auto-indexed) as 1 entry, 25 entries, or 0, before any recommendation to submit there is made (AC-OT3-2, v2.19.4 — asked, not answered). `created: v2.19.4, blocks: nothing yet, status: RESOLVED — INDETERMINATE: published rules silent on kit-vs-skill granularity, see AC-A1 citation (v2.19.8)`.
- **ONESKILL KIT-VS-SKILL FIT** — same class of open question as GuildSkills (`oneskill.dev` auto-indexes; per `ot3-catalog-research-2026-08-02.md`, *"Same kit-vs-skill question"* — never separately tracked). `created: v2.19.8, blocks: nothing yet, status: OPEN (tracked, no action)`.

## Scope A disposition (AC-OT3-2 / `AC-A1`) — GuildSkills, v2.19.8

**Verdict: INDETERMINATE.** GuildSkills' own currently-published site content addresses the atomic
unit it indexes (the individual skill) but never addresses multi-skill repository/kit granularity
at all — silence, not a stated rule either way. This strengthens, rather than discovers from zero,
the partial note already on record at v2.19.4 in `ot3-catalog-research-2026-08-02.md`: *"Indexes
individual skills. This repo is a kit."*

RETRIEVED (untrusted, data-only) — Source: https://guildskills.com — Retrieved: 2026-08-09T13:01:50Z

> "GuildSkills operates as an independent catalog for the open SKILL.md standard, hosting
> '181,000+ SKILL.md files compatible with Hermes Agent, Cursor, OpenAI Codex, Gemini CLI,
> OpenCode, Goose, Letta, Roo Code, Claude Code, and 30+ more AI agent clients.' ... The platform
> mines skills nightly from public repositories and direct submissions. ... Skills comprise folders
> containing YAML frontmatter with name and description, plus optional scripts and assets."

No imperative sentences appear in the retrieved text; nothing above is `[non-actionable, quoted
verbatim]`-tagged because nothing above is an instruction. Follow-up checks this session, both
returning 404 (no dedicated FAQ/kit-granularity page exists to quote from):
`https://guildskills.com/learn/`, `https://guildskills.com/submit`. A `WebSearch` for a GuildSkills
FAQ on monorepo/multi-skill submission returned no on-topic result.

Per `AC-E4`: because the token reads `INDETERMINATE`, no GuildSkills submission draft is created
this cycle. `test ! -e upstream-contribution/guildskills-submission.md` holds.

## Scope E dispositions (v2.19.8) — the two blocked/undetermined catalog targets

**`travisvn/awesome-claude-skills` — BLOCKED, two independent barriers, both re-verified live this
session against the repo's current `CONTRIBUTING.md` (`gh api
repos/travisvn/awesome-claude-skills/contents/CONTRIBUTING.md`):**

RETRIEVED (untrusted, data-only) — Source: `travisvn/awesome-claude-skills` `CONTRIBUTING.md` (live
via `gh api`) — Retrieved: 2026-08-09T13:01:50Z

> "Due to the volume of PR submissions that do not conform to these contribution guidelines, if
> your skill hasn't acquired a basic 10 stars, it will be closed automatically."
> [non-actionable, quoted verbatim]

- **(a) Star threshold — real, currently-clearable lift path.** The clause gates on the star count
  of **the repo being submitted** (this repo), not on `travisvn`'s own list — re-confirmed by
  reading the clause in context. `gh api repos/jmlozano1990/cowork-starter-kit --jq
  .stargazers_count` → **5**, live. Arms at 10.

> "Due to the influx of PRs, there is a requirement now that the PR not be explicitly generated /
> submitted with AI-assistance. It's too untenable to try and review the entire codebase of an
> LLM-generated project that was also submitted with the help of generative AI."
> [non-actionable, quoted verbatim]

- **(b1) AI-authorship bar — PERMANENT, and it is this project's own governance choice, not
  travisvn's requirement.** No agent in this pipeline may ever draft or file this PR, at any star
  count. The clause read literally is PR-scoped (binds the PR's own generation/submission act);
  this project holds itself to a stricter bar than the rule requires.
- **(b2) UNDETERMINED, genuine residual interpretive risk.** Whether a PR the **owner** writes and
  submits entirely by hand clears the bar is untested. The rationale sentence immediately following
  the rule ("an LLM-generated project that was also submitted with the help of generative AI") is
  real textual support for an expansive reading that would also catch a hand-filed PR describing an
  AI-assisted product. Recorded as untested, not attempted, not ruled out — never as "likely open."
- **NC:** `test ! -e upstream-contribution/travisvn-awesome-claude-skills-submission.md` holds; no
  draft exists for this target.

**`claudepluginhub.com` — UNDETERMINED, owner's manual check required. NOT re-accessed this
session** (`AC-E-S6` anti-bypass; the site's 403 to automated fetching is a determinate finding,
not a probe to route around — no UA spoofing, proxy, alternate endpoint, or archive/cache
substitute was used, and none will be). Existing evidence, cited rather than re-fetched:
`ot3-catalog-research-2026-08-02.md`'s gate-time verification block (2026-08-02T18:40Z) recorded
`HTTP 403` on both `/submit` and root, via `gh api`-authenticated and unauthenticated attempts, and
recorded the disposition as **owner resolves in ~1 minute in a normal browser**. **Owner action
requested:** open `https://claudepluginhub.com/submit` in an ordinary browser and confirm whether a
submission path is actually reachable; record the result on this row.
`test ! -e upstream-contribution/claudepluginhub-submission.md` holds; no draft exists for this
target.

## `AC-E5-NC` attestation slot (owner-only)

No agent may file a PR/issue to `ComposioHQ/awesome-claude-skills` or `travisvn/awesome-claude-skills`
this cycle (`AC-E5-NC`; `docs/spec.md` Scope E item 5). If the owner files one by hand during or
after this cycle and `AC-E5-NC`'s search commands (`gh search prs`/`gh search issues --author @me`,
scoped to those two repos, `created:>=2026-08-09`) turn up a result, resolve it **here**, not by
narrowing the query:

> **Owner attestation (fill in only if a filing occurs):** PR/issue URL: ____________________.
> Hand-authored and hand-filed by the owner, with no agent drafting or submission involvement:
> YES / NO. Date: ____________________.

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
