<!-- Fix contribution prepared by cowork-starter-kit for msitarzewski/agency-agents.
     Maps to this repo's v2.19.7 disclosure finding H-4 (see vendored/README.md
     §Disclosure). Filing, not acceptance, is the deliverable — see docs/spec.md
     v2.19.7 AC-B4-1. Prepared by @dev; actual PR filing against the upstream repo
     is an orchestrator/owner action outside this file's own scope. -->

# Suggested fix — `product/product-behavioral-nudge-engine.md`

## Finding

Line 76 branches application behavior on an inferred, sensitive personal
attribute with no described consent or disclosure flow:

```typescript
if (userProfile.tendencies.includes('ADHD') || userProfile.status === 'Overwhelmed') {
```

Lines 115-116 name explicit engagement-design goals using variable-ratio
reinforcement mechanics:

```
- Building variable-reward engagement loops.
- Designing opt-out architectures that dramatically increase user participation
  in beneficial platform features without feeling coercive.
```

Under GDPR Art. 9, health status — including inferred mental-health-adjacent
conditions such as ADHD — is special category data, subject to stricter
processing conditions than ordinary personal data. This file's own persona
already infers and stores this kind of tag (`userProfile.tendencies`) with no
attached consent model. Separately, this same corpus already shows elsewhere
that it treats `health_information` as sensitive: `support/support-legal-
compliance-checker.md:125-131` classifies it under `sensitive_data`,
`legal_basis: explicit_consent`, `special_protection: true` — this file doesn't
yet apply that same standard to itself.

## Suggested fix

Two independent, additive changes — neither requires removing the persona's
adaptive-coaching feature, only naming what it is doing and gating it:

1. **Name the classification explicitly and gate it on consent**, rather than
   inferring and branching on it silently:

   ```typescript
   // userProfile.tendencies may include self-disclosed accessibility/attention
   // preferences (e.g. 'ADHD'). This is sensitive personal data under GDPR
   // Art. 9 in EU deployments — only set this field from an EXPLICIT,
   // opt-in user disclosure (never inferred from behavior), and honor
   // userProfile.consent.sensitiveTagsConsent before branching on it.
   if (userProfile.consent?.sensitiveTagsConsent &&
       (userProfile.tendencies.includes('ADHD') || userProfile.status === 'Overwhelmed')) {
   ```

2. **Reword the two engagement-design bullets** to describe the mechanism
   without the "without feeling coercive" framing, which reads as an explicit
   design goal to obscure the mechanic from the user it targets:

   ```
   - Building variable-reward engagement loops — disclose this pattern in any
     user-facing description of the assistant's behavior, since variable-ratio
     reinforcement is a well-documented engagement mechanic worth being
     transparent about.
   - Designing opt-out architectures that make the off-ramp genuinely easy to
     find and use — the measure of success is whether users who want to opt out
     can do so quickly, not how rarely they do.
   ```

None of this is reported as an attack — this is a sincere product-design choice
(an adaptive coaching assistant) that a small, named change makes safer to adapt
into other products without carrying its consent gap and its "invisible on
purpose" framing along with it.
