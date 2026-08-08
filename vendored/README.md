# Vendored Upstream Content

This directory is the **local, offline copy** of all upstream content pinned in
`cowork.lock.json`. Nothing here is fetched at runtime — Cowork sessions need no
internet or GitHub access to use it (see WIZARD.md §Network & Offline Rule).

## agency-agents/

The reviewed library from
[msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) (MIT),
108 agent definition files across 10 category folders, materialized at the lock
file's `pinned_commit_sha`. (110 at the pinned commit upstream; 2 permanently
removed in v2.19.7 — see **Disclosure** below.)

Every file here:

- was fetched at the pinned commit and **SHA-256 verified** against the lock's
  `content_sha256` before being written (fail-closed)
- carries the **ADR-024 6-field attribution block** at the top
- is re-verified by CI on every pull request: the `vendored-integrity-check` job
  strips the attribution block and asserts the remaining bytes still hash to the
  lock value, so tampering with either the lock or the vendored copy fails CI

## Using this content

You can read, quote, and adapt these agent definitions offline — ask Claude to
"read `vendored/agency-agents/<category>/<file>.md`" or to adapt one for your
workspace. Installing them as first-class workspace skills through the wizard is
v2.7+ scope (see WIZARD.md F4 pool boundary); until then the wizard installs only
the curated `skills/` pool.

## Regenerating

Maintainers: after every `/sync-agency` lock bump, run from the repo root:

```bash
bash scripts/vendor-agency.sh
```

The script fetches each lock entry at the new pinned SHA, verifies hashes,
injects attribution, and round-trip-checks that CI will pass. A sync PR that
bumps the lock without refreshing this directory fails `vendored-integrity-check`.

<!-- DO-NOT-REGENERATE: hand-maintained section; sync-agency.yml regeneration must preserve below this marker -->

## Disclosure — vendored-tree read, v2.19.7

**This section is authored by Cowork Starter Kit, not upstream** — it describes
findings from a maintainer read of the vendored tree, not content from
`msitarzewski/agency-agents` itself, and it is never touched by `sync-agency.yml`'s
regeneration of the sections above this marker.

All 110 files pinned at the time of this read (`pinned_commit_sha` above) were read in
full for this cycle. Two were permanently removed (below); **4 findings (H-1, H-2, H-4,
H-5) remain disclosed** in the 108 files that ship today. Counted by flagged *location*
rather than by finding ID — H-2's 2 corrupted files counted separately, H-5's 7-file
fabricated-persona group counted as the single item it was found and filed as — that
same disclosure covers **5 flagged locations**. Both numbers are correct; they count
different things, and both are used below so neither reads as a typo of the other. None
of this is an attack; each finding is a sincere upstream
design choice or an inherited defect, consistent with how the rest of this corpus reads —
recorded here because a kit whose pitch is "unvetted third-party content is a real risk"
should not itself ship an unread third-party tree. Findings are disclosed rather than
silently patched (this kit does not edit vendored bytes — see **Regenerating** above),
and four upstream PRs have been filed against `msitarzewski/agency-agents` mapped to the
findings below (filing, not acceptance, is the deliverable — see `upstream-contribution/`).
MIT's AS-IS / no-warranty terms already govern this content regardless of this section.

### Removed (not disclosed as findings — deleted, not corrected)

- **`marketing/marketing-carousel-growth-engine.md`** — branches on an autonomous,
  zero-confirmation posture ("Zero Confirmation: Run the entire pipeline without asking
  for user approval", "Notify Only at End") that publishes generated content directly to
  public TikTok/Instagram accounts via a third-party API, with no approval step between
  generation and that irreversible public write.
- **`project-management/project-manager-senior.md`** — carries leaked third-party
  workspace content unsuitable for redistribution.

Neither is filed upstream — the owner's decision here was deletion, not correction
(`docs/spec.md` v2.19.7 §Settled inputs).

### Disclosed findings (4 findings across 5 flagged files, in the 108 that ship)

**H-1 — a substring deny-list gates a Python `eval()` call.**
`vendored/agency-agents/engineering/engineering-ai-data-remediation-engineer.md:175-180`
builds a `forbidden = ['import', 'exec', 'eval', 'os.', 'subprocess']` list (`:177`) and rejects
any AI-generated transformation string containing one of those substrings before passing
the survivor to `eval()` at `:198`. Substring deny-lists ahead of `eval()` are a
well-documented bypassable pattern in the Python security literature — string
concatenation, alternate name resolution (`__import__`, `getattr(__builtins__, ...)`),
and non-ASCII lookalike identifiers are standard bypass classes a fixed substring list
does not close. Filed upstream.

**H-2 — corrupted headings from a mangled emoji encoding, 28 headings across 2 files.**
`vendored/agency-agents/engineering/engineering-mobile-app-builder.md` and
`vendored/agency-agents/marketing/marketing-app-store-optimizer.md` each carry 14
level-2 (`##`) headings whose leading emoji renders as garbage bytes instead of an emoji
character — e.g. `## =­ Your Communication Style` (verified:
`grep -cP '^## (?![A-Za-z0-9])' <file>` — level-2 headings whose first character after
"## " is NOT alphanumeric — returns 14 for each file; both files share byte-identical
corrupted sequences at the same heading positions, consistent with a shared upstream
encoding round-trip rather than two independent incidents). No content is lost — every
heading's TEXT survives intact after the corrupted lead-in bytes — but the corruption is
visible to anyone reading the file directly. Filed upstream (one PR covering both files,
per the granularity `docs/spec.md` AC-B4-1 allows).

**H-4 — a persona instructing itself to infer a mental-health-adjacent status and apply
variable-reward engagement design.**
`vendored/agency-agents/product/product-behavioral-nudge-engine.md:76` branches
application behavior on `userProfile.tendencies.includes('ADHD')` — an inferred,
sensitive personal-attribute classification with no described consent or disclosure
flow attached to it in the file. The same file's `:115-116` names "variable-reward
engagement loops" and "opt-out architectures that dramatically increase user
participation … without feeling coercive" as explicit design goals — variable-ratio
reinforcement schedules are a well-documented pattern in behavioral-design literature
for engagement mechanics that trade user control for measured participation lift. Under
**GDPR Art. 9**, health status (including inferred mental-health-adjacent conditions
such as ADHD) is **special category data**, subject to stricter processing conditions
than ordinary personal data — worth naming specifically here rather than only as "dark
patterns" in the abstract, because it is the concrete legal category a developer adapting
this persona actually needs to see. Notably, this same vendored corpus already
demonstrates elsewhere that it knows this distinction matters:
`vendored/agency-agents/support/support-legal-compliance-checker.md:125-131` classifies
`health_information` under `sensitive_data`, `legal_basis: explicit_consent`, and
`special_protection: true` — an internal inconsistency between what one file in the
corpus models as sensitive and what another file does, rather than a uniform oversight.
Filed upstream.

**No live GDPR obligation attaches to this kit** for H-4 — this repository ships inert
reference Markdown with no processing, no server, no telemetry, and no account (see
`TRUST.md`), and these personas are not yet installable as live skills (see **Using this
content** above). Controllership, if any, attaches to a downstream adopter who deploys
this persona's logic against real user data — a downstream adopter doing so at scale
would likely warrant its own DPIA; that is a note for that adopter, not an obligation
triggered by this disclosure.

**H-5 — 7 finance/legal files open with a fabricated named persona and a fabricated
professional track record, with no advice disclaimer.**
`finance/finance-tax-strategist.md:49`, `finance/finance-financial-analyst.md:49`,
`finance/finance-investment-researcher.md:49`, `finance/finance-bookkeeper-controller.md:49`,
`finance/finance-fpa-analyst.md:49`, `support/support-finance-tracker.md:47`, and
`support/support-legal-compliance-checker.md:47` (all under
`vendored/agency-agents/`) each open with a sentence in the shape "You are **[Name]**, a
veteran/seasoned [role] with N+ years of experience …", naming specific fabricated
credentials (e.g. "Big Four accounting firms", "navigated IRS audits", "designed
tax-efficient entity structures across 30+ jurisdictions"). None of the 7 files contains
any advice-disclaimer or not-legal/financial-advice language. MIT's AS-IS / no-warranty
terms already govern this content, but a persona bio is not the same signal as a license
footer to a reader who encounters the file directly (see **Placement** below). Filed
upstream (one PR, since the pattern is identical across all 7 files).

### Placement note (H-5)

A disclosure here is necessary as the disclosure-of-record but not sufficient as what a
live Cowork session actually sees: `WIZARD.md` moves this whole `vendored/` directory
(including this README) into `_setup-kit/` at handover, and the real encounter path for
this content is a direct offline read by path (`WIZARD.md` §Using this content, above) —
a session reading `finance/finance-tax-strategist.md` directly never has this file in
context. A one-line advice-disclaimer for the finance/legal vendored subset therefore
also lives in `templates/workspace-claude-md-template.md` (and/or root `CLAUDE.md`),
inside the existing 400-word cap this repo already enforces on those files (ADR-011).
