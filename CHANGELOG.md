# Changelog

All notable changes to this project are documented here. This project uses [Semantic Versioning](https://semver.org/).

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
