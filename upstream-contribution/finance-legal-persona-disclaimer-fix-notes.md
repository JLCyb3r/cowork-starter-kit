<!-- Fix contribution prepared by cowork-starter-kit for msitarzewski/agency-agents.
     Maps to this repo's v2.19.7 disclosure finding H-5 (see vendored/README.md
     §Disclosure). Filing, not acceptance, is the deliverable — see docs/spec.md
     v2.19.7 AC-B4-1. Prepared by @dev; actual PR filing against the upstream repo
     is an orchestrator/owner action outside this file's own scope. -->

# Suggested fix — 7 finance/legal files, no advice disclaimer

## Finding

Seven files each open with a sentence in the shape "You are **[Name]**, a
veteran/seasoned [role] with N+ years of experience …", naming specific
fabricated credentials, and none of the seven contains any advice-disclaimer or
not-legal/financial-advice language:

- `finance/finance-tax-strategist.md:49` — "You are **Cassandra**, a veteran Tax
  Strategist with 15+ years of experience across Big Four accounting firms …
  navigated IRS audits, and designed tax-efficient entity structures across 30+
  jurisdictions."
- `finance/finance-financial-analyst.md:49` — "You are **Morgan**, a seasoned
  Financial Analyst with 12+ years of experience …"
- `finance/finance-investment-researcher.md:49` — "You are **Quinn**, a veteran
  Investment Researcher with 14+ years …"
- `finance/finance-bookkeeper-controller.md:49` — "You are **Dana**, a
  meticulous Controller with 13+ years of experience …"
- `finance/finance-fpa-analyst.md:49` — "You are **Riley**, a sharp FP&A
  Analyst with 11+ years of experience …"
- `support/support-finance-tracker.md:47` — "You are **Finance Tracker**, an
  expert financial analyst and controller …"
- `support/support-legal-compliance-checker.md:47` — "You are **Legal
  Compliance Checker**, an expert legal and compliance specialist …"

MIT's AS-IS / no-warranty terms already govern this content, but a persona bio
naming specific fabricated professional history is a different signal to a
reader than a license footer — a user handed "Cassandra … navigated IRS audits"
may reasonably read this as domain authority, not as a role-play framing device.

## Suggested fix

Add one sentence, in the same position in each of the 7 files (immediately
after the persona-identity paragraph, before "You think in …" / "Your
superpower is …" style follow-on text), consistent in wording across all 7:

```
**This is a role-play persona, not a licensed professional.** Verify any
finance, tax, accounting, or legal guidance independently — including with a
licensed professional where the decision has real financial or legal stakes —
before acting on it.
```

This is a single-sentence, low-friction addition that does not change any
file's functional behavior, and keeps the fabricated-persona framing (which is
this corpus's established house style across every category, not unique to
these 7 files) while closing the specific gap of zero advice-disclaimer text
in the subset where a reader is most likely to act on the output.

None of this is reported as an attack — every one of these 7 files reads as a
sincere, consistently-styled persona-driven agent design, applied here to a
domain (finance/legal) where the missing disclaimer matters more than it would
elsewhere in the corpus.
