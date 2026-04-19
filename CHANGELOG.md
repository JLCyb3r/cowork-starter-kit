# Changelog

All notable changes to this project are documented here. This project uses [Semantic Versioning](https://semver.org/).

---

## [1.3.2] — 2026-04-19

> **Note:** This release was initially tagged as v1.4.0 (2026-04-19) but was renamed to v1.3.2 to align with the v1.3.x preset-rollout versioning lane. Content is identical to the original v1.4.0 release.

**Personal Assistant Preset (7th preset) + Security Posture.** Adds a new goal preset for daily personal life management, introducing the first sensitive-personal-data surface in cowork-starter-kit history and the ADR-019 Data-Locality Rule pattern.

**Added:**

- 7th preset `presets/personal-assistant/` — full scaffold: README, folder-structure (Calendar/, Finances/, Tasks/, People/, Documents/), writing-profile, connector-checklist, context/ (5 files), project-instructions-starter.txt, cowork-profile-starter.md, skills-as-prompts.md
- 3 stub skills for Personal Assistant preset:
  - `presets/personal-assistant/.claude/skills/daily-briefing/SKILL.md` — 16-line stub; morning briefing from local Calendar/, Tasks/, People/ folders
  - `presets/personal-assistant/.claude/skills/follow-up-tracker/SKILL.md` — 16-line stub; logs commitments owed and pending from conversations and inbox
  - `presets/personal-assistant/.claude/skills/spend-awareness/SKILL.md` — 16-line stub; paste-based transaction summarizer; descriptive only (no investment advice, budgeting recommendations, or savings plans)
- ADR-019 "Instruction-Surface Security Posture" — 4-element contract for data-category constraints (exact heading, grep phrase, placement, setup-surface reinforcement); explicit scope limitation: NOT appropriate as sole control for regulated data (HIPAA PHI, PCI, GDPR Art. 9); bold callout block added to architecture.md per S7
- ADR-015 v1.3.2 amendment — Trigger 1 direct-invocation exempt from proactive-mapping requirement with global-instructions.md; codifies v1.3.1 Phase 6 implicit behavior
- Data Locality Rule in `presets/personal-assistant/global-instructions.md` — 6 sensitive-data categories (financial amounts, calendar events, contact details, health information, physical addresses, authentication credentials); decline-and-redirect rule; pasted-content-as-data rule; placed BEFORE proactive trigger rules per ADR-019
- New persona: Life Admin Juggler (v1.3.2 PRD)
- `presets/personal-assistant/connector-checklist.md` — finance paste-only prohibition with explicit naming of prohibited connectors (Plaid, Yodlee, bank APIs)
- S4 note in ADR-019 Consequences: redaction escape-valve scoped to PA preset in v1.3.2; community preset authors must revisit before broadening

**Changed:**

- `WIZARD.md` Q1 — Personal Assistant added as 7th goal option; Q3 — preset-specific question added for Personal Assistant; fallback message updated "6 options" → "7 options"
- `CLAUDE.md` — `personal-assistant` alias added to preset enumeration (350 words maintained via compensating trim of "sample" in Step 6 phrasing — non-semantic trim)
- `curated-skills-registry.md` — Personal Assistant section added; 3 new rows (daily-briefing, follow-up-tracker, spend-awareness); total 19 → 22 entries
- `README.md` — version badge 1.3.1 → 1.3.2; preset table updated to 7 presets; "Six goal presets" → "Seven goal presets"; Next up teaser updated
- `docs/security-review.md` — v1.3.2 Phase 2 security review appended (0 CRITICAL / 3 WARNING / 6 INFO; classification SECURITY-SENSITIVE; data-locality verdict ACCEPT WITH REFINEMENT; all 6 @architect open issues resolved)

**Security:**

- First SECURITY-SENSITIVE cycle since v1.2; first sensitive-personal-data surface in cowork-starter-kit history
- 9 MUST-FIX carry-forwards from Phase 2 absorbed: S1 (data-category extension), S2 (pasted-content-as-data rule), S3 (CLAUDE.md word-count preserved), S4 (ADR-019 S4 note), S5 (spend-awareness anti-pattern line), S6 (finance connector prohibition), S7 (ADR-019 scope bold callout), S8 (WIZARD.md "7 options"), Issue 5 (IP boundary grep — 0 hits confirmed)

---

## [1.3.1.1] — 2026-04-18

**Documentation patch.** No functional changes.

**Changed:**
- README.md version badge corrected 1.2.0 → 1.3.1 (stale since v1.3.0 release)
- README.md "Next up" teaser updated from shipped v1.3.0 to upcoming v1.3.2 Writing preset depth
- templates/skill-template/SKILL.md CONTRIBUTOR NOTICE block — removed stale "(arriving in v1.3.0 B2 commit)" future-tense reference; placeholder authoring rules are now live

---

## [1.3.1] — 2026-04-18

**Research Preset Depth + Carry-Forward Hygiene** — rewrites all 3 Research preset skills to the full 9-section ADR-015 template, expands skill-depth CI enforcement to include the Research preset, and resolves all 3 Phase 2 v1.3.1 security carry-forwards.

**Added:**

- 3 Research preset skills rewritten to full depth:
  - `presets/research/.claude/skills/literature-review/SKILL.md` — thematic matrix + gap analysis framework; theme/source count header; 7 quality criteria; 7 anti-patterns; four-tier writing-profile rule (cells terse, count-line neutral, synthesis adapts, gaps adapt); BibTeX-aware extension
  - `presets/research/.claude/skills/source-analysis/SKILL.md` — 7-field evaluation card (source type, authority, methodology, evidence quality, limitations, bias, bottom line); citation recommendation as Bottom line; two-tier writing-profile rule (fields 1–6 terse, Bottom line adapts)
  - `presets/research/.claude/skills/research-synthesis/SKILL.md` — Research preset variant (ADR-018); always peer-review-rigor; 7-column matrix (claim, method, evidence, limitations, authority, recency, citation-network); four synthesis sections (Agreements, Disagreements, Gaps, Synthesis); four-tier writing-profile rule; intentionally distinct from Study variant
- `presets/research/skills-as-prompts.md` — regenerated from the 3 new Research SKILL.md files; replaces v1.0 stubs with full 9-section prose content for each skill; preserves ADR-003 dual-path fallback usability

**Changed:**

- `presets/research/global-instructions.md` — trigger rules expanded to cover all 4 modes per Research skill (literature-review: academic survey + thesis chapter; source-analysis: citation vetting + claim-specific evaluation; research-synthesis: peer-review prep + systematic review + meta-analysis framing)
- `curated-skills-registry.md` — Research preset descriptions updated to match v1.3.1 SKILL.md frontmatter; new `research-synthesis` Research entry added (ADR-018 dual-file; 19 total rows); vetting dates updated to 2026-04-18
- `.github/workflows/quality.yml` — `skill-depth-check` job: `ENFORCED_PRESETS` expanded from `"study"` to `"study research"`
- `CONTRIBUTING.md` — v1.3.1: B10 input-session template section added (full 6-Q schema, defaults+clarify pattern for skills 2+); After Phase 7 push-and-PR checklist added; PR reviewer checklist item 19 added (cross-preset slug-divergence check per ADR-018)
- `CLAUDE.md` — trimmed to 350 words (carry-forward from v1.2 audit A3; target met)

**Security (Phase 2 carry-forwards resolved):**

- S1 (MUST-FIX): CONTRIBUTING.md B10 section documents 3 worked-example authoring rules (real sources only; forbidden imperative token scan; user-written expected output); all 3 Research SKILL.md `## Example` sections cite real peer-reviewed sources (Miller 1956, Baddeley 2000, Cowan 2001) with no imperative tokens outside code fences
- S2 (SHOULD-FIX): CONTRIBUTING.md PR reviewer checklist item 19 added for cross-preset slug-divergence verification (ADR-018 enforcement by review, not CI)
- S3 (MUST-FIX): `presets/research/global-instructions.md` updated so all 4 trigger modes per Research skill map to "offer automatically when" firing conditions; `## Triggers` sections in B1/B2/B3 are a subset-or-extend of the updated global rules

---

## [1.3.0] — 2026-04-18

**Preset Skills Depth — Study Preset Pilot** — rewrites all 3 Study preset skills to the full 9-section ADR-015 template, adds skill-depth CI enforcement, and resolves all 4 Phase 2 v1.3 security carry-forwards.

**Added:**

- 9-section skill template (ADR-015): `## When to use`, `## Triggers`, `## Instructions`, `## Output format`, `## Quality criteria`, `## Anti-patterns`, `## Example`, `## Writing-profile integration`, `## Example prompts` — enforced via CI for the Study preset pilot
- `skill-depth-check` CI job (ADR-016): validates each Study preset skill has all 9 required section headings and meets the 60-line floor; path allowlist prevents false positives on non-skill files
- 3 Study preset skills rewritten to full depth:
  - `presets/study/.claude/skills/flashcard-generation/SKILL.md` — Anki-ready output with human-readable + TSV blocks, 6 quality criteria, 6 anti-patterns, writing-profile integration, spaced-repetition atomicity rules
  - `presets/study/.claude/skills/note-taking/SKILL.md` — 4-framework auto-selection (Cornell / Outline / Zettelkasten / Lightweight), 11-step instructions, 7 quality criteria, 7 anti-patterns, 3-tier writing-profile rule
  - `presets/study/.claude/skills/research-synthesis/SKILL.md` — source-count mode auto-selection (1/2/≥3), full matrix + synthesis output, BibTeX-aware extension, 7 quality criteria, 7 anti-patterns
- Retro-template carry-forward workflow (B8): `docs/retro.md` v1.3.0 section added with carry-forward surfacing process
- README "Next up" teaser (B9): `## Next up` section added describing v1.4 Research preset pilot
- CONTRIBUTING.md v1.3: checklist items 12–17 added (skill-depth-check CI requirements); placeholder-authoring rules: 5 rules stating when placeholder content is acceptable (no undeclared gaps, examples must be real)
- `.gitignore` guard: patterns added for `.claude/projects/` and `skill-inputs/` directories to prevent accidental commit of local pipeline state and user skill-input files (S4 carry-forward)

**Changed:**

- `curated-skills-registry.md`: Study preset descriptions updated to match v1.3.0 SKILL.md frontmatter (`description:` field) for all 3 entries; vetting dates updated to 2026-04-18
- `presets/study/skills-as-prompts.md`: regenerated from the three v1.3.0 SKILL.md files; replaces 16-line v1.2 stubs with full 9-section prose content for each skill; preserves ADR-003 dual-path fallback usability as a single pasteable prompt
- `.github/workflows/quality.yml` `registry-url-check` job: tightened URL validation to require `https://github.com/` prefix for non-builtin entries (was any HTTPS URL)

**Security (Phase 2 carry-forwards resolved):**

- S1: CI advisory notice added — `skill-depth-check` job comments warn when a skill file is near the CI floor; CONTRIBUTING.md v1.3 documents the fail-open rationale
- S2: CONTRIBUTING.md v1.3 item 16 added: SHA-pin all GitHub Action versions before publishing community skills
- S3: Inline negative test added to `skill-depth-check` CI job: verifies the check correctly rejects a synthetic 59-line stub
- S4: `.gitignore` guard added for `skill-inputs/` and `.claude/projects/` — prevents local user input files from being committed to the public repo

---

## [1.2.0] - 2026-04-17

**Dynamic Workspace Architect** — the wizard now discovers your goal before proposing a workspace, adds a universal writing profile step for all presets, and ships a curated skills registry for goal-matched skill discovery.

**All 6 presets updated.**

**New files:**

- `curated-skills-registry.md` — Tier 1 curated skills registry at repo root; 18 vetted entries (3 per preset); Tier 2 community section with opt-in instructions; community PR process for additions
- `templates/writing-profile-template.md` — canonical writing profile template with 5 sections; used by contributors for new presets; CI-enforced
- `presets/*/context/writing-profile.md` (6 new files) — goal-appropriate writing profile defaults for each preset; not blank; user fills in personal details

**Updated files (all presets):**

- `project-instructions-starter.txt` (6 files) — rewritten with dynamic wizard flow: open-ended goal discovery, suggestion branch for uncertain users, preset detection + accelerator offer, novel-goal handling, writing profile step (3–4 questions), fast-track pause; ≤400 words each
- `global-instructions.md` (6 files) — added writing profile trigger rule: reference `writing-profile.md` when generating content ≥100 words

**Infrastructure:**

- `CLAUDE.md` — rewritten with full dynamic wizard (same as starter files); replaces v1.1.1 preset-selector content; Layer 1a universal entry point per ADR-010
- `CONTRIBUTING.md` — PR checklist updated to v1.2 (11 items); added CLAUDE.md high-impact guidance, registry entry requirements, SHA-pinning guidance, writing-profile.md requirements
- `.github/workflows/quality.yml` — 3 new CI jobs: `claude-md-word-count-check` (≤400 words), `writing-profile-template-check` (template + required sections), `registry-url-check` (HTTPS-only source_url)
- `VERSION` — bumped to 1.2.0

---

## [1.1.1] - 2026-04-16

**Zero-paste setup** — adds `CLAUDE.md` at repo root so Cowork auto-runs the onboarding wizard when you open the project. No copy-paste required.

**New files:**

- `CLAUDE.md` — project instructions auto-loaded by Cowork; contains preset-agnostic onboarding state machine and safety rule

**Updated files:**

- `README.md` — Quick Start simplified to 3 steps (download, open, talk)
- `SETUP-CHECKLIST.md` — paste step demoted to optional; wizard starts automatically
- `.github/workflows/quality.yml` — new CI job: `claude-md-safety-rule-check`
- `VERSION` — bumped to 1.1.1

---

## [1.1.0] - 2026-04-16

**Wizard Architecture Redesign** — fixes the v1.0 root cause failure where Cowork's intent classifier intercepted WIZARD.md before it could be read.

**All 6 presets updated.**

**New files (all presets):**

- `project-instructions-starter.txt` — paste into Project Settings > Custom Instructions BEFORE any conversation; contains state machine check + abbreviated onboarding interview + ongoing behavior rules; primary trigger path
- `.claude/skills/<skill-name>/SKILL.md` — all skills converted from flat `.md` to `folder/SKILL.md` format with YAML frontmatter for auto-discovery as `/slash-commands`

**Updated files (all presets):**

- `global-instructions.md` — rewritten from passive skill list to proactive trigger rules format; explicit trigger conditions and offer phrases for each skill
- `context/about-me.md` — added `Upcoming deadlines:` field for session-start deadline surfacing

**Infrastructure:**

- `.claude/skills/setup-wizard/SKILL.md` — root-level /setup-wizard skill for explicit fallback invocation; includes reset confirmation guard
- `WIZARD.md` — marked documentation-only with top note; no longer a runtime path
- `SETUP-CHECKLIST.md` — Step 3 is now paste `project-instructions-starter.txt` (before any conversation)
- `README.md` — updated flow diagram and Quick Start with new architecture
- `CONTRIBUTING.md` — PR checklist updated to v1.1 (7 items including starter file, word count, safety rule in starter, skill format)
- `templates/preset-template/` — added `project-instructions-starter.txt` template and `example-skill/SKILL.md`
- `docs/OUTPUT-STRUCTURE.md` — updated to show `project-instructions-starter.txt` as primary output artifact
- `.github/workflows/quality.yml` — 3 new CI jobs: `starter-file-check`, `starter-safety-rule-check`, `skill-format-check`
- `VERSION` — bumped to 1.1.0

---

## [1.0.0] - 2026-04-15

Initial release.

**Presets included:**

- Study — research, note-taking, flashcard generation
- Research — literature review, source analysis, synthesis
- Writing — voice matching, editing, outlining
- Project Management — status updates, meeting notes, risk assessment
- Creative — ideation, creative briefs, feedback synthesis
- Business/Admin — email drafting, report summary, action items

**Infrastructure:**

- WIZARD.md — Cowork-as-wizard primary delivery
- SETUP-CHECKLIST.md — manual fallback path
- scripts/setup-folders.sh — bash folder creation (macOS)
- scripts/setup-folders.ps1 — PowerShell folder creation (Windows)
- templates/preset-template/ — contributor scaffold
- templates/global-instructions-base.md — safety rule source of truth
- .github/workflows/quality.yml — CI: markdown lint, link check, shellcheck, safety-rule enforcement
