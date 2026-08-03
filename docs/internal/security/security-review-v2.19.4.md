# Security Review — v2.19.4 "Rung 0: Announcement Prerequisites" (claude-cowork-config)

**Phase:** 6 · **Date:** 2026-08-03T11:29:01Z · **Status:** PASS WITH WARNINGS · **Reviewer:** @security

> **Deliverable-path note.** @security's write scope does not cover this target repo, so this report was returned as text and persisted by @dev at the orchestrator's direction. This is a blocked-write-honestly-reported case, not a phantom-artifact case — the distinction that matters in this cycle, where a prior phase claimed a file that was never written.

## Findings Summary

| ID | Severity | Surface | Description |
|----|----------|---------|-------------|
| S1 | WARNING | configuration | `docs/owner-tasks.md`'s NAMING tracked-candidate publishes competitive-positioning reasoning (branding collision across 4+ GitHub projects, explicit rationale for not renaming) at the public top level of `docs/`, while this repo's own convention (`docs/internal/planning/competitive.md`) treats that exact class of content as internal-only |
| S2 | INFO | configuration | Content Exclusion Policy analogy does not transfer: the policy governs Council-side pipeline-state sync, not already-public target-repo docs; a sync-exclusion row would not reduce this file's actual exposure |
| S3 | INFO | none | "Setup works fully offline" / no network call at setup — spot-checked against `WIZARD.md:25-27` and confirmed accurate |
| S4 | INFO | file-upload | `assets/social-preview-source.svg` re-confirmed inert (0 dangerous constructs, 6-element vocabulary), no local paths/hostnames/usernames |
| S5 | INFO | dependency | No hardcoded secrets or credentials in diff or new files; no dependency manifest exists in this repo |
| S6 | INFO | file-upload | `assets/social-preview.png` chunk list re-confirmed clean (no `tEXt`/`iTXt`/`zTXt`/`eXIf`) |

**CRITICAL:** none.

## WARNING

**S1 — NAMING candidate content placement.** `docs/owner-tasks.md` stated, in the public repo, that "Cowork starter" is contested vocabulary across 4+ GitHub projects, and gave the business rationale for not renaming (burns the URL, docs, and existing stars for cosmetic gain). This is competitive/branding analysis, not process-transparency content.

**Recommendation (accepted, applied at Phase 6):** keep `docs/owner-tasks.md` at the public top level of `docs/` **as-is**, with one exception — trim the NAMING entry to a bare status line and fold its substance into `docs/internal/planning/competitive.md`, which already exists for this class of content.

Reasoning, checked against this repo's own precedent rather than a general rule:

1. `docs/internal/**` has a narrow, consistent existing purpose here: audit artifacts (`qa-report-*`, `security-review-*`, `compliance-review-*`) **and** `docs/internal/planning/competitive.md` + `personas.md`. That second pair is the tell — this repo already treats competitive-landscape analysis as internal-only, even though its engineering process (`spec.md`, `retro.md`, `patterns.md`, `risk-register.md`) is radically public.
2. `owner-tasks.md`'s dominant content (5 of 6 OT rows) is process transparency, not strategy — the same shape `docs/retro.md` already carried publicly for `AC-DIST-2`/`AC-BRDTH-10` across 12 releases. Moving the whole file to `internal/` would be *inconsistent* with that precedent and would defeat the ledger's stated purpose (visitors can see what is owner-blocked, part of this project's public-trust story per `TRUST.md`).
3. The NAMING row is the outlier because of its **content**, not its file.
4. `.gitignore` is the wrong tool entirely — nothing here is a credential, a bypass, or a copyable technical capability, and hiding it would contradict the file's own reason for existing.

## Row-by-row disclosure assessment

| Row | Judged harm | Reasoning |
|---|---|---|
| OT-1 (unlaunched announcement) | None material | "We haven't announced yet" is not competitively exploitable; no rival can preempt a LinkedIn post |
| OT-2 (SVG de-slop) | None | Production-quality housekeeping |
| OT-3 (3 catalogs researched, 0 submitted) | Negligible | Open community directories anyone would independently discover; public `docs/spec.md` already names all three by URL |
| OT-4 (dormant until Rung 1) | None new | "Upstream sync currently broken" is already disclosed more explicitly in the announcement copy's own honesty-constraints table |
| OT-5 (owner uploads PNG) | None | Mechanical, API-less fact already in `docs/spec.md` |
| OT-6 (UX tone deferred to v2.21) | None | Internal quality scheduling |
| **NAMING** | **The one real finding** | Competitive-positioning judgment, not engineering-process transparency — see S1 |
| AGENCY-AGENTS PERSONA CONVERSION | None new | Same content is already being added to public `docs/roadmap.md` `## Later` in this same diff |
| GUILDSKILLS KIT-VS-SKILL FIT | None | An open research question about a registry's taxonomy; operational, not strategic |

**Baseline note:** public `docs/spec.md` already states bluntly that a direct web search returns no result, with 0 external issues and 14 visitors in 14 days — a franker admission of weak traction than anything in `owner-tasks.md`.

## Content Exclusion Policy question — premise corrected

**Recommendation: NO row, and the premise needs correcting.** That policy governs The-Council's `/sync` and `mcp-guard.sh`, which push **Council-side pipeline-state files** to JIRA/Confluence. `docs/owner-tasks.md` is a **target-repo product doc already committed to a public GitHub repository**. Adding it would not reduce exposure — it is as public as it will ever get the moment the PR merges. The correct lever is placement (S1), not sync exclusion. This project has no JIRA/Confluence integration enabled (confirmed via `registry.json`). Solving the wrong layer.

## Secondary checks

**S4 — `assets/social-preview-source.svg`.** As a *source* file it had never been through the demo SVG's S5/S6 gauntlet; the full demo-grade check was run against it directly rather than assuming parity. `grep -icE '<!DOCTYPE|<!ENTITY|SYSTEM|PUBLIC|javascript:|data:|<script|<foreignObject|on[a-z]+=|xlink:href|<image|<use|@import|url\(http'` = 0. Element vocabulary exactly `{circle, rect, style, svg, text, title}` — a subset of the demo's verified 8. Only string literal is the intended public repo URL.

**S3 — announcement claim vs. reality.** "No network call at setup" **holds**: `WIZARD.md:25` ("Everything installs locally… No wizard step requires the internet") and `:26-27` (explicit never-fetch instruction, and a requirement to say so plainly if a fetch is attempted). The other two claims were out of this cycle's changed surface and were not re-derived.

**S6 — path/credential/hostname leakage: none.** Checked every diffed and new file for `macbookpro`, `/Users/`, `/home/`, `localhost`, private-IP patterns, and credential shapes (`api[_-]?key`, `secret`, `token`, `password`, `BEGIN (RSA|OPENSSH|PRIVATE)`, `AKIA`, `ghp_`, `sk-`). Zero hits beyond the intended public `github.com/jmlozano1990/Cowork-Starter-Kit` string. The only `${GITHUB_TOKEN}` references are pre-existing CHANGELOG prose describing correct GitHub Actions usage, far from the new v2.19.4 section.

## OWASP assessment

| Category | Status | Notes |
|---|---|---|
| A01 Broken Access Control | N/A | No application code or auth surface |
| A02 Cryptographic Failures | N/A | No crypto surface |
| A03 Injection | PASS | Both SVGs independently re-confirmed inert; PNG has no injectable metadata |
| A04 Insecure Design | WARNING (S1) | Content-placement decision, not a technical design flaw |
| A05 Security Misconfiguration | N/A | No workflow, settings, or guard surface touched |
| A06 Vulnerable Components | N/A | No dependency manifest exists |
| A07 Identification/Auth Failures | N/A | No auth surface |
| A08 Data Integrity Failures | PASS | No externally-sourced assets; social card traces color-for-color to the existing demo palette |
| A09 Logging Failures | N/A | No logging surface |
| A10 SSRF | N/A | No server-side request surface; no remote refs in either asset |
| LLM01 Prompt Injection | PASS | Documentation, not an auto-loaded instruction surface; WIZARD's goal-text-as-DATA posture unchanged |
| LLM06 Sensitive Info Disclosure | WARNING (S1) | The live disclosure question this audit existed to answer |

## Note on the AC vocabulary itself

This audit found a defect class the four prior verification catches did not: not a false write claim, but an **unexamined disclosure-shape finding**. Every literal AC in `docs/spec.md` (AC-LEDGER-1..4) is satisfied by the content as shipped — the ACs check schema and presence, never whether a tracked-candidate row's *content* belongs at that visibility tier.

**Recommendation for a future `/spec`:** carry an AC requiring that any tracked-candidate row whose content overlaps `docs/internal/planning/competitive.md`'s scope holds a pointer, not the full reasoning, in the public ledger.

## Verdict

**PASS WITH WARNINGS.** No CRITICAL, no blocker. One WARNING (S1) with a concrete, non-blocking remedy. Five INFO items, all confirmatory. Secondary checks clean.
