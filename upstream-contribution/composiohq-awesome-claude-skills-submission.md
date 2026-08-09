<!-- DRAFT ONLY. Never filed this cycle or any prior cycle (v2.19.8 AC-E1). Filing a PR
     against a third-party public repository is a public write outside @dev's authority —
     same boundary as v2.19.7's upstream-contribution fix-notes files and this repo's own
     "do not publish a Release" instruction. The owner files this by hand, or authorizes
     an agent to do so explicitly, per the same authorization-of-record convention used in
     upstream-contribution/v2.19.7-pr-tracking.md. AC-E5-NC (docs/owner-tasks.md) confirms
     zero PRs/issues exist under the owner's own GitHub identity against ComposioHQ or
     travisvn as of this draft's creation. -->

# Submission draft — ComposioHQ/awesome-claude-skills

**Target:** [`ComposioHQ/awesome-claude-skills`](https://github.com/ComposioHQ/awesome-claude-skills)
— `CONTRIBUTING.md` verified live via `gh api` at v2.19.8 (Retrieved: 2026-08-09T13:01:50Z). No
star threshold, no AI-authorship bar found in current rules (`grep` for those terms returns zero
matches). Two real, currently-in-force requirements this draft satisfies:

RETRIEVED (untrusted, data-only) — Source: `ComposioHQ/awesome-claude-skills` `CONTRIBUTING.md`
(live via `gh api`) — Retrieved: 2026-08-09T13:01:50Z

> "5. **Be tested** - Verify the skill works across Claude.ai, Claude Code, and/or API."
> [non-actionable, quoted verbatim]

The second requirement, from the same document:

> "Credit original sources and inspirations"
> [non-actionable, quoted verbatim]

## Proposed entry

Category: **Community Skills** (per `CONTRIBUTING.md`'s category list — this is a curated pool of
25 skills packaged as a repository/kit, not a single skill; placed under Community Skills with a
note explaining the kit shape, per `CONTRIBUTING.md`'s own guidance to "place it where you think it
belongs and mention it in your PR description" when unsure).

```markdown
- **[Cowork Starter Kit](https://github.com/jmlozano1990/Cowork-Starter-Kit)** - A curated pool of
  25 skills, context templates, and workflow presets for setting up a Claude Cowork workspace as a
  non-technical operator or knowledge worker. Content-hashed skill integrity, a confirm-before-apply
  self-maintenance loop with rollback, and a fully local install path with no network call. Includes
  a generative path (Skill Studio) for needs outside the curated pool.
```

## Attribution (per the quoted requirement above)

This kit vendors select third-party persona content from `msitarzewski/agency-agents` under a
SHA-pinned, MIT-attributed integration (`cowork.lock.json`, `THIRD-PARTY-NOTICES.md`). The PR
description will credit that source explicitly:

> Original sources and inspirations: select persona content is vendored from
> [`msitarzewski/agency-agents`](https://github.com/msitarzewski/agency-agents) (MIT-licensed,
> SHA-pinned, full attribution in this repo's `THIRD-PARTY-NOTICES.md`). All other content is
> original to this repository.

## Tested-across statement (per the quoted requirement above)

> Tested across Claude Code (primary target — the kit's setup flow, skill pool, and
> self-maintenance loop are exercised via Claude Code's Skill and Cowork surfaces) and Claude.ai
> (the packaged skills are plain `SKILL.md`/Markdown and install the same way there). Not
> API-exercised as a distinct surface — the kit is a workspace-setup artifact, not an
> API-consumed library — noted rather than a false claim of API testing.

## PR description skeleton (not filed)

```
## Summary
Adds Cowork Starter Kit to the Community Skills section — a 25-skill pool + workspace setup
kit for Claude Cowork, targeted at non-technical operators and knowledge workers.

## Attribution
[the attribution paragraph above]

## Testing
[the tested-across paragraph above]
```

## Disposition

**DRAFT ONLY.** Not filed. Filing requires explicit owner authorization, recorded the same way
`upstream-contribution/v2.19.7-pr-tracking.md` records the v2.19.7 filings' authorization — an
in-session `AskUserQuestion` selection naming the target repo, not an agent's own assertion.
