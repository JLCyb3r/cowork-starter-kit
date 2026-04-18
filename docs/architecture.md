# Architecture — Claude Cowork Config

## Overview

Claude Cowork Config is a static template repository that provides a goal-driven onboarding wizard for non-technical Claude Cowork users. This document records all architectural decisions as numbered ADRs. The architecture defines the repo structure, delivery mechanism, skill file strategy, versioning model, and CI/CD approach.

**Stack:** No application runtime. Markdown + optional bash scripts. Delivered as a public GitHub repo (ZIP-downloadable).

---

## ADR Index

| ADR | Title | Status |
|-----|-------|--------|
| ADR-001 | Wizard Delivery Mechanism | SUPERSEDED by ADR-006 |
| ADR-002 | Preset Versioning Strategy | ACCEPTED |
| ADR-003 | Skill File Delivery and A2 Assumption Mitigation | SUPERSEDED by ADR-007 |
| ADR-004 | Repository Structure and File Naming Conventions | ACCEPTED (updated v1.2) |
| ADR-005 | CI/CD Strategy | ACCEPTED |
| ADR-006 | Wizard Delivery Mechanism v1.1 — Three-Layer Trigger Architecture | ACCEPTED (extended by ADR-010) |
| ADR-007 | Skill File Format v1.1 — folder/SKILL.md with YAML Frontmatter | ACCEPTED |
| ADR-008 | CI Expansion v1.1 — Starter File and Skill Format Enforcement | ACCEPTED |
| ADR-009 | Wizard UX Format Standard | ACCEPTED (extended by v1.2) |
| ADR-010 | CLAUDE.md as Universal Dynamic Wizard Entry Point (v1.2) | ACCEPTED |
| ADR-011 | Dynamic Wizard State Machine and Word Budget Architecture | ACCEPTED |
| ADR-012 | Skill Discovery Hybrid Architecture — Tier 1/Tier 2 Model | ACCEPTED |
| ADR-013 | Writing Profile Architecture — Universal Artifact for All Workspaces | ACCEPTED |
| ADR-014 | CI Expansion v1.2 — Writing Profile Template Enforcement | ACCEPTED |
| ADR-015 | Canonical 9-Section Skill Template (v1.3.0) | ACCEPTED |
| ADR-016 | `skill-depth-check` CI with Path Allowlist (v1.3.0) | ACCEPTED |
| ADR-017 | Per-Skill User-Input Schema for User-in-the-Loop Authoring (v1.3.0) | ACCEPTED |
| ADR-015 (amendment v1.3.1) | Stress-test re-validation on Research preset shapes; 130-line ceiling for Research-preset skills | ACCEPTED |
| ADR-016 (amendment v1.3.1) | `ENFORCED_PRESETS="study research"`; word-split-loop verification | ACCEPTED |
| ADR-018 | Preset isolation for skill-slug collisions (research-synthesis dual-file disposition) | ACCEPTED |

---

## ADR-001: Wizard Delivery Mechanism

**Date:** 2026-04-14
**Status:** SUPERSEDED by ADR-006 (2026-04-15)

*Retained for historical record. The Cowork-as-wizard primary path (WIZARD.md as runtime entry point) failed in real-world testing on 2026-04-15. See ADR-006 for the replacement architecture.*

**Context:** The wizard (F1 + F2) must guide a non-technical user from "just installed Cowork" to "personalized workspace" in under 15 minutes with zero code required. The delivery must work cross-platform (macOS primary, Windows secondary) and from a ZIP download (no git required).

### Options Considered

**Option A — Pure Markdown Guide (User Reads and Applies Manually)**
- User reads a structured `WIZARD.md` file, answers questions on paper/mentally, then manually selects and copies files from the appropriate preset folder.
- Pros: Maximum compatibility, zero friction, no runtime.
- Cons: No interactivity. User must do all the mapping themselves. Higher cognitive load. Does not feel like a "wizard" — feels like reading documentation. Violates the AC "wizard presents 6 goal cards" (there is no presentation, just text). High drop-off risk for beginners.

**Option B — Bash Interactive Script (`wizard.sh`)**
- Terminal-based interactive script that asks questions via `read -p`, maps answers to a preset, and copies/generates output files to a target directory.
- Pros: Genuine interactivity. Can generate personalized files (profile, global instructions). macOS-native. Scriptable.
- Cons: Requires opening a terminal — violates zero-code for users who fear the terminal. Needs a PowerShell equivalent for Windows (doubles maintenance). ZIP download may lose execute permissions (`chmod +x` required on macOS — another terminal step).

**Option C — Python CLI**
- Python script that runs the wizard via `python wizard.py`.
- Pros: Cross-platform (Python is pre-installed on macOS and available on Windows). Can be sophisticated (fuzzy matching, rich output).
- Cons: "Open terminal, run python" is intimidating for non-technical users. Python version issues on Windows. Dependency management risk. Overkill for what is fundamentally a branching questionnaire.

**Option D — Cowork-as-Wizard (Conversational) + Bash Fallback + Manual Checklist** (RECOMMENDED at time of writing)
- The PRIMARY path uses Claude Cowork itself as the wizard runtime. The user opens the repo folder in Cowork and says "Help me set up" or "Run the setup wizard." A `WIZARD.md` instruction file in the repo root tells Cowork exactly how to conduct the interview.
- A SECONDARY path provides `scripts/setup-folders.sh` (bash).
- A TERTIARY path provides `SETUP-CHECKLIST.md`.

### Decision (v1.0)

**Option D — Cowork-as-Wizard with layered fallbacks.**

### Failure (2026-04-15)

Real-world test: user opened repo in Cowork and said "set up my workspace." Cowork's native intent classifier intercepted the phrase, ran its own built-in setup skill, asked one generic question, and installed a generic productivity plugin. `WIZARD.md` was never read. Root cause: Cowork's intent classifier runs before any project files are read. Passive markdown cannot override intent routing at the system level. See ADR-006.

### Consequences (archived)

- `WIZARD.md` at repo root retained for documentation and contributor reference only — NOT a runtime entry point in v1.1+.

---

## ADR-002: Preset Versioning Strategy

**Date:** 2026-04-14
**Status:** ACCEPTED
**Context:** The repo ships 6 presets at launch. Community contributors will add more. The question is whether to version each preset independently or version the entire repo as a single unit.

### Options Considered

**Option A — Monorepo Single Semver** (RECOMMENDED)
- One `version` field in the repo root (e.g., in `VERSION` file or repo tags). All presets share the version. A change to any preset bumps the repo version.
- Pros: Simple. One version to communicate. GitHub releases are straightforward. Contributors submit PRs against the repo, not individual packages. Users download one ZIP at one version.
- Cons: A typo fix in one preset bumps the version for all presets. No way to express "only the Research preset changed."

**Option B — Per-Preset Semver**
- Each preset folder contains a `VERSION` file or version field in a metadata file. Presets can be updated independently.
- Pros: Granular. Users can track which presets changed. Enables independent release cadence.
- Cons: Overkill for a content repo at v1. Complicates the contribution model (contributors must understand per-preset versioning). ZIP download includes all presets regardless — independent versions have no delivery benefit. GitHub Releases doesn't natively support multi-package repos without tooling.

### Decision

**Option A — Monorepo Single Semver.**

Rationale:
1. This is a content repo, not a package ecosystem. The presets are not independently consumable — they share the wizard, the output format spec, and the safety rules.
2. At v1 with 6 presets, per-preset versioning is premature complexity. If the community grows to 20+ presets, this can be revisited.
3. Version is tracked via git tags (`v1.0.0`, `v1.1.0`) and a `VERSION` file at repo root. GitHub Releases map 1:1 to tags.
4. CHANGELOG.md notes which presets were affected in each release.

### Consequences

- `VERSION` file at repo root contains the current semver string.
- Git tags follow `vX.Y.Z` format.
- CHANGELOG.md uses per-release sections noting affected presets.
- CONTRIBUTING.md instructs contributors to not manage versions — maintainers handle versioning at release time.

---

## ADR-003: Skill File Delivery and A2 Assumption Mitigation

**Date:** 2026-04-14
**Status:** SUPERSEDED by ADR-007 (2026-04-15)

*Retained for historical record. The dual-path delivery decision (flat `.md` + `skills-as-prompts.md` fallback) was superseded after validating that flat `.md` files do not auto-discover as slash commands in Cowork. See ADR-007 for the replacement.*

**Context:** The spec's F5 (Skill/Context File Starter Kit) delivers SKILL.md files stored in `.claude/skills/`. Assumption A2 states this loading behavior is UNTESTED for Cowork — it is only confirmed for Claude Code.

### Decision (v1.0)

**Dual-Path Delivery:** Ship SKILL.md files as primary; include `skills-as-prompts.md` as fallback. Include a validation protocol for A2 before Phase 4.

### Finding (2026-04-15)

User validated A2 in a real Cowork session: flat `.md` files in `.claude/skills/` are readable as prompts but do NOT auto-discover as `/slash-commands`. Running `/skill-creator` on a flat file produces the correct `folder/SKILL.md` format with YAML frontmatter, and the resulting skill auto-discovers as `/skill-name`. The flat format is confirmed broken for the auto-discovery use case. See ADR-007.

### Consequences (archived)

- `skills-as-prompts.md` retained in all 6 presets as copy-paste fallback (last-resort path unchanged).

> **Post-Phase-1 Update (2026-04-15):** A2 assumption resolved via research. Cowork does not auto-discover `.claude/skills/` from filesystem (Claude Code only). Delivery mechanism updated: `.claude/skills/` content is packaged as a ZIP for manual upload via Settings > Customize > Skills. Skill-creator (built-in Cowork meta-skill) is now the primary skill delivery path — the wizard guides users to build personalized skills live during the setup session. Pre-built skill files in preset folders serve as ZIP upload source and reference content.

---

## ADR-004: Repository Structure and File Naming Conventions

**Date:** 2026-04-14
**Status:** ACCEPTED (updated v1.1: new files added to structure — see below)
**Context:** The repo must be navigable by non-technical users downloading a ZIP. File names must be self-explanatory. The structure must support 6 presets at launch and scale to community-contributed presets.

### Decision

```
claude-cowork-config/
|
|-- README.md                          # Product landing page + quick start
|-- WIZARD.md                          # Documentation + script source only (NOT runtime path in v1.1+)
|-- SETUP-CHECKLIST.md                 # Fully manual setup alternative (tertiary path)
|-- CONTRIBUTING.md                    # How to add a new preset
|-- CHANGELOG.md                       # Release history (which presets changed)
|-- LICENSE                            # MIT
|-- VERSION                            # Single semver string (e.g., "1.1.0")
|-- .gitignore
|
|-- .claude/
|   |-- skills/
|       |-- setup-wizard/
|           |-- SKILL.md               # /setup-wizard explicit invocation skill (ships with all downloads)
|
|-- presets/
|   |-- study/
|   |   |-- README.md                  # Preset overview: who it's for, what it configures
|   |   |-- project-instructions-starter.txt  # PRIMARY: paste into Custom Instructions before any conversation
|   |   |-- global-instructions.md     # Full proactive trigger rules (session behavior)
|   |   |-- folder-structure.md        # Documented folder tree for this goal type
|   |   |-- connector-checklist.md     # Recommended connectors with decision helpers
|   |   |-- skills-as-prompts.md       # Last-resort fallback: all skill content as copy-paste snippets
|   |   |-- context/
|   |   |   |-- about-me.md            # User fills in (template with prompts)
|   |   |   |-- working-rules.md       # Pre-filled safe defaults
|   |   |   |-- output-format.md       # Pre-filled per preset
|   |   |-- .claude/
|   |       |-- skills/
|   |           |-- flashcard-generation/
|   |           |   |-- SKILL.md       # name: flashcard-generation, description: ...
|   |           |-- note-taking/
|   |           |   |-- SKILL.md
|   |           |-- research-synthesis/
|   |               |-- SKILL.md
|   |
|   |-- research/   (same structure as study/)
|   |-- writing/    (same structure as study/)
|   |-- project-management/  (same structure as study/)
|   |-- creative/   (same structure as study/)
|   |-- business-admin/  (same structure as study/)
|
|-- scripts/
|   |-- setup-folders.sh               # Bash folder creation (secondary path, macOS)
|   |-- setup-folders.ps1              # PowerShell folder creation (secondary path, Windows)
|
|-- templates/
|   |-- preset-template/               # Blank preset template for contributors
|   |   |-- README.md
|   |   |-- project-instructions-starter.txt  # Template starter file
|   |   |-- global-instructions.md
|   |   |-- folder-structure.md
|   |   |-- connector-checklist.md
|   |   |-- skills-as-prompts.md
|   |   |-- context/
|   |   |   |-- about-me.md
|   |   |   |-- working-rules.md
|   |   |   |-- output-format.md
|   |   |-- .claude/
|   |       |-- skills/
|   |           |-- example-skill/
|   |               |-- SKILL.md       # Template skill with YAML frontmatter
|   |
|   |-- global-instructions-base.md    # Shared safety rules (always included)
|
|-- docs/
|   |-- spec.md                        # Product spec (Phase 0 output)
|   |-- assumptions.md                 # Assumptions register
|   |-- competitive.md                 # Competitive analysis
|   |-- personas.md                    # User personas
|   |-- architecture.md                # This file (ADRs)
|   |-- OUTPUT-STRUCTURE.md            # Documents what the wizard produces
```

### File Naming Conventions

1. **All user-facing files:** lowercase with hyphens, `.md` extension. No spaces, no underscores in file names.
2. **Preset folder names:** lowercase, hyphenated slugs matching the preset name (`study`, `research`, `writing`, `project-management`, `creative`, `business-admin`).
3. **Skill directories:** lowercase, hyphenated, descriptive names (e.g., `research-synthesis/`, `meeting-notes/`). Each skill is a folder containing `SKILL.md`.
4. **Root-level files:** UPPERCASE for standard open-source files (README.md, CONTRIBUTING.md, CHANGELOG.md, LICENSE, VERSION, WIZARD.md, SETUP-CHECKLIST.md). This follows GitHub conventions and ensures visibility.
5. **Context files:** lowercase, hyphenated. Always three files per preset: `about-me.md`, `working-rules.md`, `output-format.md`.
6. **No binary files.** Every file in the repo is plain text (markdown or shell script). No images, PDFs, or compiled artifacts. ASCII diagrams only.
7. **`project-instructions-starter.txt`:** `.txt` extension (not `.md`) because the user pastes its content into Cowork Project Settings > Custom Instructions field — it is not a markdown document, it is plain text.

### Output Package Spec

When the wizard completes, the user's workspace should contain:

```
<user-workspace>/
|-- cowork-profile.md                  # Generated: user's answers + selected preset
|-- project-instructions-starter.txt   # Source: copied from preset (user already pasted before wizard)
|-- .claude/
|   |-- skills/
|       |-- <skill-name>/
|           |-- SKILL.md               # folder/SKILL.md format (auto-discovers as /skill-name)
|-- context/
|   |-- about-me.md
|   |-- working-rules.md
|   |-- output-format.md
|-- <goal-folders>/
|-- connector-checklist.md
|-- SETUP-CHECKLIST.md
```

### Consequences

- Flat, predictable structure — no deeply nested directories beyond the skill folder convention.
- `templates/` directory enables community contributions via CONTRIBUTING.md.
- `templates/global-instructions-base.md` is the single source of truth for the safety rule.
- `.claude/skills/` directories inside presets contain dotfile paths — the `.gitignore` must not exclude them.
- Root-level `.claude/skills/setup-wizard/SKILL.md` ships with every download for universal `/setup-wizard` access.

---

## ADR-005: CI/CD Strategy

**Date:** 2026-04-14
**Status:** ACCEPTED (extended by ADR-008 in v1.1)
**Context:** The repo needs automated quality checks to catch broken links, malformed markdown, and shell script issues. CI runs on GitHub Actions, not the user's machine, so this does not violate the zero-dependency constraint.

### Options Considered

**Option A — No CI**
- Rely on manual review for markdown quality.
- Pros: Zero setup.
- Cons: Broken links and formatting errors will ship. Community contributions are harder to validate.

**Option B — Markdown Lint Only**
- `markdownlint-cli2` via GitHub Actions on push/PR.
- Pros: Catches formatting issues. Low complexity.
- Cons: Doesn't catch broken links — the most common content repo failure mode.

**Option C — Markdown Lint + Link Check + ShellCheck** (RECOMMENDED)
- Three checks in a single GitHub Actions workflow:
  1. `markdownlint-cli2` — validates markdown formatting.
  2. `lychee` — validates all relative and external links.
  3. `shellcheck` — validates bash scripts in `scripts/` (if present).

### Decision

**Option C — Markdown Lint + Link Check + ShellCheck.**

Rationale:
1. Broken relative links are the #1 quality issue in content repos with cross-referenced files.
2. ShellCheck costs nothing to add and catches common bash issues.
3. External link checking runs as a separate job with `continue-on-error: true`.

### Workflow Structure

```yaml
# .github/workflows/quality.yml
name: Quality Checks
on: [push, pull_request]
jobs:
  markdown-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: DavidAnson/markdownlint-cli2-action@v19
        with:
          globs: '**/*.md'

  link-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: lycheeverse/lychee-action@v2
        with:
          args: --no-progress '**/*.md'
          fail: true

  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ludeeus/action-shellcheck@2.0.0
        with:
          scandir: './scripts'
```

*Note: v1.1 adds three additional jobs. See ADR-008.*

### Consequences

- `.github/workflows/quality.yml` is included in the repo.
- `.markdownlint.jsonc` configuration file at repo root.
- PRs are blocked on markdown lint and internal link check failures.
- External link failures are reported but do not block PRs.
- ShellCheck runs on all `.sh` files in `scripts/`.

---

## ADR-006: Wizard Delivery Mechanism v1.1 — Three-Layer Trigger Architecture

**Date:** 2026-04-15
**Status:** ACCEPTED
**Supersedes:** ADR-001

### Context

**Root cause failure (2026-04-15):** ADR-001 chose Cowork-as-wizard with `WIZARD.md` as the primary runtime path. This failed in the first real-world test. When the user said "set up my workspace," Cowork's native intent classifier intercepted the phrase before reading any project files, ran its own built-in setup skill, asked one generic question, and installed a generic productivity plugin. `WIZARD.md` was never read.

**Why WIZARD.md cannot be a reliable runtime path:** Cowork's intent classifier processes user messages before inspecting project files. A file that describes wizard behavior has no effect until Cowork decides to read it — and the classifier intercepts "set up"-type phrases before that decision is made. No amount of instruction text in WIZARD.md can override this routing.

**What does work:** Custom instructions (Project Settings > Custom Instructions) are injected as system context before Cowork's intent classifier runs. Content in this field cannot be intercepted — it is already in the model context before the first user message is evaluated.

**Word limit constraint (Assumption A1):** Cowork's custom instructions field accepts approximately 400 words without truncation. A ≤300 word target provides a safety margin. The full 11-step wizard script cannot fit in this field. The bootstrap content must be concise.

### Options Considered

**Option A — project-instructions-starter.txt as bootstrap (RECOMMENDED)**
- A short file (~200–300 words) the user pastes into Project Settings > Custom Instructions before any conversation. Contains: (1) a state machine check (does `cowork-profile.md` exist with real content?), (2) a pointer to run the onboarding interview if not, (3) Phase 2 ongoing behavior rules.
- Pros: Custom instructions are system context — cannot be intercepted by the intent classifier. State machine is evaluated on every session start with no user action required. Stays within the word limit.
- Cons: User must paste the file before starting. If they forget, the wizard does not auto-fire. Mitigation: SETUP-CHECKLIST.md Step 1 is now "paste starter file."

**Option B — Override WIZARD.md with stronger invocation text**
- Add "IMPORTANT: Before responding to anything else, read and follow WIZARD.md" to a project README or instructions file.
- Pros: No new file type.
- Cons: Root cause analysis established this cannot work. Cowork's intent classifier runs before project file inspection. Override text in a project file is logically equivalent to WIZARD.md itself — it would also be ignored. This option is ruled out.

**Option C — /setup-wizard skill only (no starter file)**
- Rely entirely on the user explicitly invoking `/setup-wizard`.
- Pros: Guaranteed path — direct skill invocation bypasses the intent classifier.
- Cons: Requires user awareness. Non-technical users may not know to type the command. Does not auto-fire on first session. Appropriate as a fallback, not a primary path.

### Decision

**Three-layer trigger architecture:**

**Layer 1 — Primary: `project-instructions-starter.txt`**
Each preset ships a `project-instructions-starter.txt` file (≤300 words). The user pastes it into Project Settings > Custom Instructions before starting any conversation. Contains a state machine: if `cowork-profile.md` does not exist or contains the placeholder `[Your name]`, auto-run the onboarding interview. If it exists with real content, greet by name and skip onboarding.

This is the primary surface because custom instructions are system context — injected before intent classification, not subject to interception.

**Layer 2 — Explicit fallback: `/setup-wizard` skill**
A proper Cowork skill at `.claude/skills/setup-wizard/SKILL.md` (repo root, ships with every download). Contains YAML frontmatter (`name: setup-wizard`, `description:` present). Self-contained interview script. Explicit `/setup-wizard` invocation routes directly to the skill — Cowork's intent classifier cannot intercept a direct skill call. Used when: starter file was not pasted, user wants to redo setup.

Reset guard: before rerunning the interview, the skill prompts "This will reset your profile and re-run onboarding. Your past sessions are unaffected. Confirm? (Yes / No)."

**Layer 3 — Documentation only: WIZARD.md**
Kept for repo-browser context and contributor reference. Contains the detailed per-preset question scripts (source of truth for interview content) and a top note: "Users: start with `/setup-wizard` or paste `project-instructions-starter.txt`. This file is the script source, not the entry point." WIZARD.md is NOT a runtime path in v1.1+.

### Consequences

- `presets/<name>/project-instructions-starter.txt` exists for all 6 presets at launch.
- Each starter file is ≤300 words to stay within Cowork's custom instructions field limit.
- Each starter file contains Phase 1 (onboarding state machine + interview trigger) and Phase 2 (session-start rules, proactive skill triggers summary, safety rule).
- `.claude/skills/setup-wizard/SKILL.md` ships at repo root with valid YAML frontmatter.
- `SETUP-CHECKLIST.md` Step 1 is: paste `project-instructions-starter.txt` into Project Settings > Custom Instructions — before any conversation.
- `WIZARD.md` receives a documentation-only header note; all "primary path" claims are removed.
- The state machine check (`cowork-profile.md` existence) is evaluated by Cowork on every session start via the custom instructions block.

---

## ADR-007: Skill File Format v1.1 — folder/SKILL.md with YAML Frontmatter

**Date:** 2026-04-15
**Status:** ACCEPTED
**Supersedes:** ADR-003

### Context

**Finding from ADR-003 validation:** User tested A2 (whether Cowork auto-discovers `.claude/skills/` files) in a live Cowork session. Flat `.md` files (e.g., `flashcard-generation.md`) are readable as prompts but do NOT auto-discover as `/slash-commands` in Cowork. This is a Claude Code-only behavior.

**What does work:** Running `/skill-creator` on flat content produces the correct `folder/SKILL.md` format with YAML frontmatter (`name:`, `description:` fields). The resulting skill auto-discovers as `/flashcard-generation`, `/note-taking`, etc. The required format is:

```
.claude/skills/<skill-name>/SKILL.md
```

Where `SKILL.md` contains:
```yaml
---
name: skill-name
description: One-sentence description of what this skill does.
---
[Skill body: instructions + example, ≤250 words]
```

### Options Considered

**Option A — Retain flat .md files, update SETUP-CHECKLIST to instruct /skill-creator**
- Keep `flashcard-generation.md` etc. in the repo; wizard tells users to run `/skill-creator` on each.
- Pros: No file restructuring.
- Cons: Users start from broken flat files and must know to fix them. CI cannot validate skill format. Flat files in the repo set the wrong expectation for community contributors.

**Option B — Ship folder/SKILL.md format directly** (RECOMMENDED)
- Convert all preset skill files to the correct format. Ship pre-built skills that already work. Wizard's `/skill-creator` validation step confirms/improves rather than bootstraps from scratch.
- Pros: Skills auto-discover immediately after upload. Community contributors see the correct format as the canonical example. CI can enforce the format. Better first-run experience.
- Cons: File restructuring required for all 6 presets.

### Decision

**Option B — folder/SKILL.md format for all preset skills.**

Rationale:
1. Auto-discovery on first use is the product promise. Shipping pre-built broken files violates that promise.
2. The `folder/SKILL.md` format is the Cowork canonical format — it should be the source of truth in the repo.
3. CI enforcement (skill-format-check job, see ADR-008) is only possible if the repo itself uses the correct format.
4. `/skill-creator` validation during onboarding becomes a confirm/improve step rather than a repair step.

### Skill Activation Flow During Onboarding

When a user says "Yes" to a skill in the wizard:
1. `project-instructions-starter.txt` instructs Cowork: "Run `/skill-creator` to validate the skill is properly installed."
2. Fallback (if `/skill-creator` is unavailable or deprecated): confirm the skill file exists at `.claude/skills/<skill-name>/SKILL.md`.
3. This fallback must be present in all 6 onboarding scripts. The `/skill-creator` dependency is explicitly logged as UNTESTED in `docs/assumptions.md`.

### Consequences

- All flat `.md` skill files in `presets/*/.claude/skills/` are deleted and replaced with `<skill-name>/SKILL.md` folders.
- Each `SKILL.md` contains: `name:` (slug), `description:` (one sentence), skill body (instructions + examples, ≤250 words).
- `templates/preset-template/.claude/skills/example-skill/SKILL.md` uses this format; the flat `example-skill.md` is removed.
- `skills-as-prompts.md` is RETAINED in all 6 presets as the copy-paste last-resort fallback (unchanged from v1.0).
- SETUP-CHECKLIST.md includes a step-by-step ZIP upload walkthrough for skills (Settings > Customize > Skills > '+', with folder structure requirement).
- CONTRIBUTING.md PR checklist requires all skills in `folder/SKILL.md` format (no flat `.md` files).

---

## ADR-008: CI Expansion v1.1 — Starter File and Skill Format Enforcement

**Date:** 2026-04-15
**Status:** ACCEPTED

### Context

v1.1 introduces two new file types that are required in every preset:
1. `project-instructions-starter.txt` — if absent, the primary trigger path does not exist.
2. `folder/SKILL.md` skill format — if flat `.md` files slip through, skills do not auto-discover.

Community contributions can easily omit these files or use the wrong format without automated enforcement. The v1.0 CI (ADR-005) catches markdown lint and broken links, but has no awareness of these new file surfaces. Three new CI jobs are needed.

### Decision

Add three jobs to `.github/workflows/quality.yml`:

**Job 1 — `starter-file-check`**
Verifies `presets/*/project-instructions-starter.txt` exists for all 6 presets. Blocks PR if absent. This ensures no preset ships without the primary trigger path.

**Job 2 — `starter-safety-rule-check`**
Greps all 6 starter files for the canonical safety rule text ("Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder"). Blocks PR if absent. Parallel to the existing `global-instructions.md` safety-rule check, extended to cover the new starter file surface.

**Job 3 — `skill-format-check`**
Verifies all files under `presets/*/.claude/skills/` follow the `folder/SKILL.md` convention. Specifically: fails if any `.md` file exists directly at the skills directory root (i.e., `presets/*/.claude/skills/*.md` matches — flat file detected). This prevents regression to the v1.0 flat file format.

### Rationale

1. Every new required file surface must have CI enforcement. Manual review cannot reliably catch missing files across 6 presets in community PRs.
2. The safety rule is a non-negotiable product requirement. Extending the safety-rule grep to cover starter files closes a gap — the v1.0 CI only checked `global-instructions.md`.
3. Skill format enforcement prevents the known v1.0 failure mode (flat files that look correct but do not auto-discover) from reappearing in community presets.

### Consequences

- `.github/workflows/quality.yml` gains three new jobs.
- All three jobs block PRs on failure (no `continue-on-error`).
- The starter-safety-rule-check job runs against both `global-instructions.md` AND `project-instructions-starter.txt` for all 6 presets.
- CI now enforces: (1) markdown format, (2) link integrity, (3) shell script safety, (4) safety rule in global-instructions, (5) starter file existence, (6) safety rule in starter files, (7) skill format convention.

---

## ADR-009: Wizard UX Format Standard

**Date:** 2026-04-15
**Status:** ACCEPTED

### Context

The v1.0 wizard used lettered options (A/B/C), a `→ Type a number.` CTA, and a 4-option skill presentation format. The @ux review (Phase 0b) identified specific UX failure points: inconsistent option formats create cognitive overhead; the step counter revealing the full interview length before fast-track causes drop-off; skill presentation with 4 options is too wide for quick scanning. These are not aesthetic preferences — they affect completion rate for the North Star metric.

This ADR establishes the canonical UX format for all presets and all future community contributions.

### Decision

The following format rules are mandatory for all preset wizard questions:

**1. Numbered options universally**
All options use numbered format (1, 2, 3...). No lettered options (A, B, C). The sole exception is "S) Suggest" which is kept as a letter to visually distinguish it from numbered choices. This convention applies to single-select, multi-select, and skill presentation steps.

Rationale: Lettered options conflict with the skill presentation format (which also uses numbers); numbered options are consistent and require no mental mode-switching.

**2. `**Your answer:**` CTA on its own line**
Every question ends with the CTA `**Your answer:**` on its own line. Replaces `→ Type a number.` This is bolder, clearer, and more inviting for non-technical users.

**3. Step counter hides denominator until after fast-track**
Progress display shows "Step N" (not "Step N of 11") until the user passes the fast-track decision point (Step 5). After the user explicitly chooses to continue past fast-track, the denominator is revealed. Rationale: showing "Step 3 of 11" before the user commits to the full interview increases drop-off risk.

**4. Fast-track at Step 5 for all presets**
After Step 5, all 6 presets pause with: "Your basic workspace is ready. 1) Yes, continue — deeper customization  2) Get started now — run `/setup-wizard` later." This addresses the documented tension between Alex persona's tolerance (2–3 questions) and the full 11-step interview.

**5. Skill presentation: 3 options**
Skill offer format: `1. Yes — activate  2. No — skip it  3. Show me more`. Not 4 options. The "Show me a full example" option from the plan is collapsed into "Show me more." Rationale: 4 options creates unnecessary hesitation; "Show me more" covers both discovery needs.

**6. Personalized skill example, no description block**
Each skill step shows a concrete personalized example (using the user's actual subject/role from earlier steps) instead of a generic description block. The example alone conveys value; a description block adds length without insight.

**7. AskUserQuestion heuristic nudge with numbered-list fallback**
Every `project-instructions-starter.txt` must include: "For each wizard question, use AskUserQuestion to present the options as clickable buttons if available. If not available, use the numbered list format below." This is a best-effort heuristic — no AC may require button rendering. Numbered list format is the guaranteed delivery target; buttons are a stretch enhancement.

**8. "S) Suggest" on knowledge-gap questions only**
The "S) Suggest" escape hatch appears only on questions where there is an objectively better answer based on context (study method, output format, tools, skill selection). It does NOT appear on personal preference questions (name, creative constraints, tone preferences).

**9. Free-text tolerance**
If the user answers with words instead of a number, the wizard matches intent, states the interpretation in one sentence, and proceeds. Does not re-ask. Example: "Got it — I'm treating that as [X]. Moving on."

**10. "You choose" response format**
When user says "you choose" / "suggest" / "not sure": one concrete recommendation + one-sentence reason, then "Sound right?" Does not re-list options.

**11. "Show me more" latency acknowledgment**
When user selects option 3 on a skill step, wizard immediately says "Generating an example — just a moment..." before producing the longer content.

**12. Time estimate at fast-track**
Fast-track pause uses "a few more minutes" not an exact number.

### Applicability

These rules are the canonical UX standard for:
- All 6 v1.1 presets
- WIZARD.md question scripts
- Future community-contributed presets (enforced via CONTRIBUTING.md PR checklist)
- Any future preset template updates

### Consequences

- All 6 presets' `project-instructions-starter.txt` and WIZARD.md question scripts are written to this spec.
- CONTRIBUTING.md PR checklist gains a UX format compliance check item.
- The spec format rules in this ADR supersede any conflicting question format guidance in the plan document.
- Numbered list is always designed as primary; AskUserQuestion buttons are designed as a bonus layer only.

---

## Anti-Pattern Scan

For a static template repository, most architect anti-patterns are inapplicable. Brief assessment:

| # | Anti-Pattern | Applies? | Notes |
|---|-------------|----------|-------|
| 1 | Over-engineering schema | No | No database. No schema. |
| 2 | Missing RLS policies | No | No database. No row-level security needed. |
| 3 | God table | No | No tables. |
| 4 | Premature optimization | No | No runtime performance concerns. Checked: preset versioning kept simple (ADR-002). |
| 5 | Missing indexes | No | No database. |
| 6 | Stringly-typed data | Watched | File naming conventions (ADR-004) serve as the "type system." Preset folder names are canonical identifiers — CI enforces consistency. Skill folder names must match their `name:` frontmatter value. |
| 7 | Circular dependencies | Watched | `WIZARD.md` references presets which reference `templates/global-instructions-base.md`. Dependency is one-directional (wizard -> presets -> templates). No cycles. |
| 8 | Missing audit trail | Partially | CHANGELOG.md + git history serve as the audit trail. VERSION file is the versioning mechanism. |
| 9 | Undocumented assumptions | Addressed | A1 (word limit) and `/skill-creator` stability are the critical v1.1 assumptions. Both are logged in `docs/assumptions.md` with fallback paths. |

No anti-patterns detected. The architecture is appropriately simple for a static content repository.

---

## Safety Architecture

The safety rule ("Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder") is enforced at four layers:

1. **Template layer:** `templates/global-instructions-base.md` contains the canonical safety rule text. This file is the single source of truth.
2. **Preset layer:** Every preset's `global-instructions.md` must include the base template content. The CONTRIBUTING.md guide makes this a hard requirement for new presets.
3. **Starter file layer (NEW in v1.1):** Every `project-instructions-starter.txt` must contain the safety rule verbatim in the Phase 2 ongoing behavior block. This is the primary runtime surface — having the safety rule here means it is active from the first session.
4. **CI layer:** Two CI jobs enforce the safety rule — the existing `safety-rule-check` (global-instructions.md) and the new `starter-safety-rule-check` (project-instructions-starter.txt). PRs are blocked if either check fails.

v1.1 strengthens the safety architecture by extending enforcement to the primary runtime surface. The v1.0 layer (wizard layer referencing WIZARD.md) is deprecated since WIZARD.md is no longer a runtime path.

v1.2 adds a fifth layer: the writing profile trigger rule in `global-instructions.md` for all 6 presets reinforces voice-consistency behavior whenever Cowork produces written output.

---

## ADR-010: CLAUDE.md as Universal Dynamic Wizard Entry Point (v1.2)

**Date:** 2026-04-17
**Status:** ACCEPTED
**Extends:** ADR-006 (Three-Layer Trigger Architecture — layers 2 and 3 unchanged)

### Context

**v1.1 trigger architecture:** The primary trigger path is `project-instructions-starter.txt` (pasted by the user into Project Settings > Custom Instructions before any conversation). CLAUDE.md at the repo root was introduced in v1.1.1 as an additional surface: when a user opens the repo folder as a Cowork Project, CLAUDE.md is auto-loaded as system context — without the user needing to paste anything. This is confirmed working behavior (plan validation, 2026-04-17).

**v1.2 driver:** The dynamic wizard is more complex than the v1.1 preset-selector. It now has: open-ended goal discovery, a suggestion branch for uncertain users, preset detection + accelerator offer, novel-goal handling, writing profile step, and skill discovery. All of this must be reachable for users who open the repo folder in Cowork without any prior configuration step — including users who have never used Cowork before and don't know to paste a starter file.

**The tension:** The spec requires per-preset `project-instructions-starter.txt` files to contain the full dynamic wizard flow (F1 AC, F3 AC). The plan establishes CLAUDE.md as the universal entry point. These are not mutually exclusive — they serve different user segments. The architecture must define which is primary and how they relate.

### Options Considered

**Option A — CLAUDE.md primary, starter files preset-specific summary only**
- CLAUDE.md contains the full dynamic wizard flow (up to word budget). Starter files contain a shorter preset-specific setup block that assumes CLAUDE.md has already run. Users who forgot to set up CLAUDE.md-based project still get a functional but simpler path.
- Pros: CLAUDE.md does the heavy lifting automatically. Starter files remain short (within v1.1's ≤300 word budget). No duplication of dynamic wizard logic.
- Cons: Users who use only a starter file (downloaded ZIP, new Cowork project, not using the repo folder) get a less dynamic experience. The two surfaces diverge architecturally.

**Option B — Both surfaces contain the full dynamic wizard (RECOMMENDED)**
- CLAUDE.md at repo root contains the full dynamic wizard (≤350 words — same budget as starter files). Per-preset `project-instructions-starter.txt` files also contain the full dynamic wizard. Both surfaces are functionally equivalent. The user gets the dynamic wizard regardless of which path they take.
- Pros: No degraded path. A user who downloads the ZIP, creates a Cowork project, and pastes any starter file gets the same dynamic wizard as a user who opens the repo folder directly. Consistent behavior = easier testing, easier documentation, easier community contributions.
- Cons: Duplication of wizard logic across 7 files (1 CLAUDE.md + 6 starter files). Any change to the wizard must propagate to all 7 files. Mitigated by: WIZARD.md as the authoritative script source; CI enforcement of required sections.

**Option C — CLAUDE.md only, deprecate per-preset starter files**
- Remove per-preset `project-instructions-starter.txt` files. CLAUDE.md is the single wizard surface. Presets are accessed entirely through the dynamic wizard (preset detection path).
- Pros: Single source of truth. No synchronization problem.
- Cons: Breaks the use case where a user wants a preset-specific setup without using the repo folder. Removes the ability to distribute individual presets. Violates F1/F3 ACs which require starter files for all 6 presets.

### Decision

**Option B — Both surfaces contain the full dynamic wizard.**

Rationale:
1. The spec's F1 AC explicitly requires `project-instructions-starter.txt` to exist for all 6 presets AND contain the dynamic wizard flow. Option C is ruled out by spec.
2. The duplication problem (Option B con) is manageable: WIZARD.md remains the authoritative script source. Starter files and CLAUDE.md are runtime projections of the same script. CONTRIBUTING.md PR checklist enforces both surfaces are updated together.
3. Consistent behavior across paths reduces QA burden. One smoke-test procedure covers both entry points.
4. Option A creates a two-tier user experience where a ZIP-download user gets a lesser wizard. For a product targeting non-technical users who may not know how to open a folder in Cowork, this is a critical failure mode.

### Layer Architecture Update (v1.2)

The three-layer architecture from ADR-006 remains intact. Layer 1 now has two parallel surfaces:

**Layer 1a — Auto-load: `CLAUDE.md` at repo root**
Cowork auto-loads `CLAUDE.md` as system context when the user opens the repo folder as a Cowork Project. No user action required. Contains the full dynamic wizard (≤350 words). This is the zero-friction path for users who open the repo directly.

**Layer 1b — Manual paste: `project-instructions-starter.txt` (per preset)**
User pastes content into Project Settings > Custom Instructions before any conversation. Contains the full dynamic wizard (≤350 words). Functionally identical to Layer 1a. This is the path for users who create a fresh Cowork project and want a preset-flavored starting point.

**Layer 2 — Explicit fallback: `/setup-wizard` skill (unchanged from v1.1)**
Direct `/setup-wizard` invocation routes to the skill. Used when neither Layer 1 path was configured, or when user wants to redo setup.

**Layer 3 — Documentation only: `WIZARD.md` (unchanged from v1.1)**
Contains the authoritative interview script for all presets. Not a runtime path.

### Content Relationship

Both Layer 1a and Layer 1b files contain:
1. State machine check (cowork-profile.md existence test)
2. Open-ended goal discovery opener
3. Suggestion branch logic (response to uncertainty)
4. Preset detection + accelerator offer
5. Writing profile step (3–4 questions)
6. Pointer to /setup-wizard for full interview continuation
7. Safety rule verbatim
8. AskUserQuestion nudge

CLAUDE.md is universal (no preset-specific interview content — that lives in WIZARD.md and is invoked via /setup-wizard).
Per-preset starter files add preset-specific context hints (e.g., "This is the Study starter — I'll suggest study-specific tools") but the wizard flow is otherwise identical.

### Consequences

- `CLAUDE.md` at repo root is updated to the dynamic wizard format (≤350 words). It replaces the current v1.1.1 preset-selector content.
- All 6 `presets/*/project-instructions-starter.txt` files are updated with the dynamic wizard flow (≤350 words each).
- Both surfaces must contain the safety rule verbatim. Existing CI jobs `claude-md-safety-rule-check` and `starter-safety-rule-check` enforce this.
- WIZARD.md remains the authoritative script source. Layer 1 surfaces are concise bootstrap; WIZARD.md contains the full per-preset interview scripts.
- The word budget for both surfaces is ≤350 words (increased from ≤300 in v1.1). This was validated as the right budget for dynamic branching in the spec (F3). A1 assumption (Cowork field limit) remains UNTESTED at 350 words — fallback to split architecture applies if actual limit is proven <300 words.

---

## ADR-011: Dynamic Wizard State Machine and Word Budget Architecture

**Date:** 2026-04-17
**Status:** ACCEPTED

### Context

The v1.2 dynamic wizard adds three new behaviors that must fit within the 350-word budget for CLAUDE.md and each starter file:

1. **Open-ended goal discovery** (replaces preset menu): First question is "What would you like to use this workspace for?" — free text, not numbered menu.
2. **Suggestion branch**: If the user responds with uncertainty ("not sure", "maybe", "something like"), the wizard must offer 3 concrete direction options before proceeding.
3. **Preset detection**: If the user's goal matches one of the 6 presets, the wizard offers the preset as a scaffold before proceeding with the customization interview.
4. **Novel goal handling**: If the goal matches no preset, the wizard acknowledges this and proposes a custom build.
5. **Writing profile step**: Universal 3–4 question step for all goals (not just Writing preset).

Fitting all of this, plus the state machine check, safety rule, and AskUserQuestion nudge, into 350 words requires explicit word budget allocation.

### Word Budget Analysis

The v1.1 starter file (≤300 words) contains:
- State machine check + onboarding trigger: ~60 words
- Preset menu + interview dispatch: ~100 words
- Ongoing behavior summary: ~80 words
- Safety rule: ~15 words
- AskUserQuestion nudge: ~20 words
- Total: ~275 words

The v1.2 additions requiring budget:
- Suggestion branch logic: ~40 words
- Preset detection + accelerator offer phrasing: ~30 words
- Novel goal handling: ~20 words
- Writing profile step (3–4 questions): ~60 words
- Total additions: ~150 words

The preset-specific interview steps are REMOVED from the starter file (they move to WIZARD.md, invoked via /setup-wizard). This recovers ~80 words. Net budget change: +70 words. 300 + 70 = 370 words — slightly over the 350 target.

### Options Considered

**Option A — Compress interview dispatch, keep all branches inline**
Compress the interview dispatch to a pointer ("For the full interview, I'll use the preset scripts — starting now…") rather than embedding step content. Move all per-preset interview steps to WIZARD.md. Inline the suggestion branch and preset detection but not the step-by-step interview.
- Pros: Fits in 350 words. Starter file is a bootstrap + branch controller, not an interview runner.
- Cons: Requires /setup-wizard or WIZARD.md content to be accessible during the first session. This works because /setup-wizard skill is universally available.

**Option B — Increase word budget to 400 words**
Accept that dynamic wizard content requires 400 words and raise the budget.
- Pros: All content inline. No indirection.
- Cons: Assumption A1 (field limit) is untested at 400 words. The A1 validation path calls for testing at 300, 350, and 400 — but until tested, 400 words is a risk. The 350 target exists specifically to maintain a safety margin below the ~400-word estimated limit. Raising to 400 eliminates the margin.

**Option C — Split architecture (state machine + pointer only, full script in WIZARD.md)** (FALLBACK)
Keep CLAUDE.md and starter files at ≤150 words (state machine check + pointer only). Full wizard script (goal discovery, suggestion branch, preset detection, writing profile, interview) lives in WIZARD.md and is invoked by pointer reference.
- Pros: Fits any field limit, even very short ones.
- Cons: Requires CLAUDE.md to reference WIZARD.md — but ADR-001's root cause failure showed that project files may not be accessible in all contexts. Pointer approach reintroduces the v1.0 failure risk. Only valid as an escalation fallback when A1 validates limit <300 words.

### Decision

**Option A — Compressed inline bootstrap (≤350 words) with full interview in WIZARD.md.**

Rationale:
1. 350 words is the validated target (spec F3, assumption A1 safety margin). Option B eliminates the safety margin without new evidence.
2. Option A is architecturally cleaner: the starter file is a state controller, not an interview runner. The interview content belongs in WIZARD.md (the authoritative source per ADR-006 Layer 3).
3. /setup-wizard skill is universally available (confirmed in v1.1) — the pointer-to-skill pattern is proven. The v1.0 failure was pointer-to-passive-file (WIZARD.md not always read); pointer-to-skill-invocation is different and reliable.
4. Option C is preserved as the escalation path if A1 validation fails.

### State Machine Design

The CLAUDE.md / starter file state machine follows this logic, encoded in ≤350 words:

```
PHASE 1 — SESSION START CHECK
  IF cowork-profile.md absent OR contains "[Your name]":
    → Run onboarding (go to PHASE 2)
  ELSE:
    → Greet by name, surface deadlines <7 days, ask what to work on today

PHASE 2 — GOAL DISCOVERY
  Ask: "What would you like to use this workspace for?"
  
  IF response is uncertain ("not sure", "maybe", "I think", "something like"):
    → SUGGESTION BRANCH: offer 3 directions
      1. [Study / Learning] — e.g., exam prep, reading comprehension, research
      2. [Work / Projects] — e.g., project tracking, reports, stakeholder updates
      3. [Writing / Creating] — e.g., articles, content, storytelling
      Say: "Which fits closest? Or describe your actual goal and I'll match it."
  
  IF response matches a preset (study, research, writing, PM, creative, business-admin):
    → PRESET ACCELERATOR: "That sounds like [Preset]. I have a great starting point —
       want me to customize it for you?  1) Yes — use [Preset] as a starting point  
       2) No — build from scratch"
    IF yes: load preset scaffold, proceed to PHASE 3
    IF no: proceed to PHASE 3 with novel flow
  
  IF response is a novel goal (no preset match):
    → "Interesting — I'll build a workspace for [goal] from scratch."
    → Proceed to PHASE 3 with novel flow

PHASE 3 — PROFILE + WRITING PROFILE (3–4 questions each)
  → Name, role/context
  → Writing tone, audience, preferences, optional sample
  → Fast-track offer: "Basic workspace ready. 1) Continue  2) Get started now"

PHASE 4 — FULL INTERVIEW (via /setup-wizard or WIZARD.md)
  → Workspace design, skills, folder structure
```

### Consequences

- CLAUDE.md and starter files contain the state machine + PHASE 2 branch logic + PHASE 3 questions inline (fits ≤350 words).
- PHASE 4 content (workspace design, skills, folder structure) is in WIZARD.md and accessible via `/setup-wizard` invocation.
- The suggestion branch uses the exact 3 directions shown above — not dynamically generated, because dynamic generation would require prose instructions that exceed the word budget.
- Preset detection uses keyword matching: if the user's goal contains "study", "exam", "course", "research", "literature", "writing", "article", "blog", "project", "PM", "creative", "design", "business", "admin", "email" — map to the closest preset and offer it.
- Novel goals receive an explicit acknowledgment and proceed to /setup-wizard for the custom build flow.
- Fallback escalation: if A1 validation proves Cowork field limit is <300 words, revert to Option C (state machine only, pointer to /setup-wizard).

---

## ADR-012: Skill Discovery Hybrid Architecture — Tier 1/Tier 2 Model

**Date:** 2026-04-17
**Status:** ACCEPTED

### Context

v1.1 shipped 3 static skills per preset (18 total). They are correct-format, curated, and safe. v1.2 must evolve skill discovery to: (1) dynamically recommend skills based on detected goal, (2) surface community skills with safety vetting, and (3) support novel goals that have no pre-bundled skills.

**Security constraint (non-negotiable, confirmed by D3):** Repello AI and Snyk ToxicSkills research (2026) confirms 13.4% critical security issue rate in community skills, 36% prompt injection rate. A default-open community skill discovery mode is unacceptable. The architecture must enforce curated-first with opt-in for broader discovery.

**Static file constraint:** No runtime network calls are permitted during wizard execution. The repo is a static markdown collection. Any skill discovery that requires a live API call to GitHub, skills.sh, or any external registry must be deferred to explicit user opt-in with documented manual steps — the wizard itself cannot execute HTTP requests.

### Options Considered

**Option A — Curated only (expand registry, no Tier 2)**
Ship only curated skills with an expanded registry. No community skill discovery at all.
- Pros: Zero security surface from unvetted skills. Simple to reason about.
- Cons: Novel goals get no skill recommendations (E4 edge case). Power users are blocked from the broader ecosystem. Community contribution path is limited to preset PRs (high-friction). D2 assumption shows the broader skill ecosystem exists and is valuable.

**Option B — Live GitHub scan (no curation layer)**
Wizard searches GitHub live at wizard runtime for matching skills.
- Pros: Always fresh. Can find skills for any goal.
- Cons: Requires network calls during wizard execution — impossible in static markdown context. Security research confirms this approach exposes users to 13.4% critical risk without vetting. Not feasible for this stack.

**Option C — Hybrid: curated registry (Tier 1) + opt-in community scan (Tier 2)** (RECOMMENDED)
Two-tier model: Tier 1 is a static curated registry shipped in the repo. Tier 2 is an explicit opt-in where the wizard instructs the user to search specified GitHub repos and presents a keyword-scan vetting procedure.
- Pros: Default path is fully safe (curated). Power users can access broader ecosystem with informed consent. No live network calls in the wizard path. Community can contribute to the registry via PRs (lower friction than full preset PRs).
- Cons: Registry requires manual maintenance. Tier 2 "scan" is LLM-assisted review, not automated sandbox execution — it is a best-effort safety check, not a guarantee.

### Decision

**Option C — Hybrid Tier 1/Tier 2 model.**

### Tier 1 Architecture — Curated Skills Registry

**File:** `curated-skills-registry.md` at repo root

**Schema per entry:**
```
| name | description | source_url | vetting_date | tier | goal_tags |
```

- `name`: slug matching the `name:` frontmatter of the SKILL.md (e.g., `flashcard-generation`)
- `description`: one sentence — what this skill does for the user
- `source_url`: canonical URL (GitHub repo URL for community skills; `builtin` for Anthropic official)
- `vetting_date`: ISO 8601 date of last manual vetting review (e.g., `2026-04-17`)
- `tier`: `1` (curated/official) or `2` (community)
- `goal_tags`: comma-separated list of preset slugs this skill is appropriate for (e.g., `study,research`)

**Tier 1 population at v1.2 launch:**
- Minimum 18 entries (≥3 per preset category, as required by F5 AC)
- Sources: Anthropic official pre-built skills (pptx, xlsx, docx, pdf processing), existing 18 preset skills migrated from preset folders, EAIconsulting/cowork-skills-library candidates
- All entries manually vetted by repo maintainer before merge

**Wizard skill recommendation flow (Tier 1):**
1. Wizard detects goal (Step 2 output)
2. Filters `curated-skills-registry.md` by `goal_tags` matching the detected goal
3. Presents top 3–5 matching skills with name, description, and a personalized example
4. User selects (Yes / No / Show me more)
5. On "Yes": wizard instructs installation via `/skill-creator` (primary) or ZIP upload (fallback)
6. `/skill-creator` fallback: confirm file exists at `.claude/skills/<name>/SKILL.md`

**Novel goal skill flow:**
If no Tier 1 entries match the user's goal tags (E4 edge case), wizard states: "I don't have verified skills for [goal] yet. You can build custom skills via `/skill-creator`." Setup completes without skill installation.

### Tier 2 Architecture — Community Opt-In Discovery

**Activation:** Explicit opt-in only. Wizard presents: "Want me to search for more skills? These aren't verified by us — review before installing. 1) Yes, show me more  2) No, stick with verified skills"

**Search sources (hardcoded list in WIZARD.md):**
- `anthropics/skills` (Anthropic official, auto-trusted)
- `travisvn/awesome-claude-skills`
- `VoltAgent/awesome-agent-skills`
- `EAIconsulting/cowork-skills-library`

**Vetting procedure (LLM-assisted, manual):**
The wizard instructs the user to navigate to the skill's SKILL.md and paste the body into the chat. The wizard then:
1. Scans for flagged keywords: `exec`, `subprocess`, `curl`, `wget`, `$HOME`, `$PATH`, `rm`, `delete`, `os.system`, `eval`
2. If any keyword found: surface as WARNING with the line containing the keyword. Require user to type "I understand" before proceeding.
3. Checks source repo indicators: stars >50 OR from recognized organization (Anthropic, EAIconsulting), last commit within 12 months. Surface as INFO if below threshold.
4. User must confirm each Tier 2 skill individually before install instructions are provided.

**Important limitation (to be stated in wizard):** The keyword scan is a heuristic performed by reviewing SKILL.md text. It is NOT sandbox execution. A skill that passes the scan may still have unexpected behavior. Users should review the full SKILL.md before installing.

### Skill Presentation Format (both tiers)

For each recommended skill:
```
[Skill name] — [one-line description]
"For your [detected goal]: [personalized example using earlier answers]"
Source: [Tier 1 Curated / Tier 2 Community — [source repo]]
1. Yes — install  2. No — skip  3. Show me more
```

The personalized example is generated by the wizard using the user's stated goal and any role/context gathered in the profile step. It is not a template — it is constructed at wizard runtime from the interview answers.

### Repository Structure Addition (v1.2)

```
claude-cowork-config/
|-- curated-skills-registry.md     # NEW: Tier 1 curated skills registry
```

The registry lives at repo root (not inside a preset folder) because it serves all goals, including novel goals that don't map to any preset.

### Consequences

- `curated-skills-registry.md` is a new required repo artifact. CI does not validate its content beyond its existence (markdown lint covers format). Manual vetting is the quality gate.
- Tier 2 discovery requires no code changes — it is wizard conversation instructions in WIZARD.md, not a CI-enforced surface.
- Existing 18 preset skills (18 SKILL.md files in preset folders) are NOT migrated into the registry — they remain as preset-bundled skills for users who download and use individual presets. The registry provides goal-matching for the dynamic wizard path.
- Community PR process for registry additions: documented in CONTRIBUTING.md with the required schema fields. PRs must include vetting evidence (date tested, source repo health indicators). Automated vetting pipeline deferred to v1.3.
- The `/skill-creator` fallback path (confirm file exists at `.claude/skills/<name>/SKILL.md`) is carried forward unchanged from v1.1.

---

## ADR-013: Writing Profile Architecture — Universal Artifact for All Workspaces

**Date:** 2026-04-17
**Status:** ACCEPTED

### Context

v1.1 shipped `context/` directories with `about-me.md`, `working-rules.md`, and `output-format.md` per preset. None of these addressed writing voice. v1.2 adds `writing-profile.md` as a universal fourth context file, generated for every completed setup regardless of preset.

**User need:** Every Cowork user produces text. Study users write lab reports. Career Manager users write cover letters. Research users write literature reviews. A voice calibration that makes Cowork outputs sound like the specific user — not generic AI — is universally valuable, not writing-preset-specific.

**Anti-AI framing:** The goal is voice authenticity (Cowork outputs sound like the user), not "AI detection bypass." This distinction is architectural: the writing profile contains voice markers and preference rules derived from the user's actual writing patterns, not adversarial instructions designed to fool detectors. This framing is reflected in wizard language and the profile template.

### Options Considered

**Option A — Writing preset only**
Keep `writing-profile.md` scoped to the Writing preset. Other presets get it only if user explicitly requests.
- Pros: Simpler. Users who don't care about writing voice don't see questions.
- Cons: The anti-AI voice problem is documented as universal (spec F6 rationale). Career Manager, Research, and Study users all produce text. This option requires non-Writing users to know enough to ask for voice calibration — violating the zero-product-knowledge design principle.

**Option B — Universal, mandatory step (RECOMMENDED)**
Writing profile step appears in all 6 preset interview sequences AND in novel-goal flows. `writing-profile.md` is generated for every completed setup. Questions are 3–4 max, with explicit framing: "Even in a [goal] workspace, I'll be writing summaries and explanations for you — this helps me match your style."
- Pros: Every user gets voice calibration regardless of whether they associate themselves with "writing." Addresses the anti-AI voice problem universally. Writing-profile.md in every setup is a consistent output that CI can enforce.
- Cons: Adds 1 interview step for all users. Alex persona has documented low tolerance — mitigated by fast-track pause after Step 6 (post-writing-profile). Users can generate a substantive profile from the questions alone without providing a writing sample.

**Option C — Universal, opt-in step**
Writing profile questions appear in all flows but are explicitly optional: "Want to set up your writing voice? (Y/N)." If N, skip entirely.
- Pros: Respects user time. Alex can opt out.
- Cons: Users who opt out get no voice calibration — they will experience the AI-sounding-like-AI problem but won't know why. The wizard's job is to suggest before they can choose. Making this opt-in is premature — it assumes users understand what they're opting out of, which violates the zero-product-knowledge principle.

### Decision

**Option B — Universal mandatory step with fast-track mitigation.**

Rationale:
1. Voice calibration is universally valuable. The wizard's design principle is "suggest what users need before they know to ask." An opt-in model requires product knowledge to engage with.
2. The fast-track pause at Step 6 (after writing profile) provides the tolerance mitigation. Alex can get a working workspace AND a writing profile before fast-tracking.
3. Assumption A16 (users willing to complete writing profile in non-writing workspaces) is UNTESTED. The fallback is explicit: even if a user skips or provides minimal answers, the profile generates with substantive defaults. An empty or placeholder-only profile must never ship.

### Writing Profile Template Architecture

**File:** `templates/writing-profile-template.md`

**Required sections** (CI-enforced by ADR-014):
1. `## Tone & Voice` — register (casual/professional/academic/mixed), audience, characteristic patterns
2. `## Style Preferences` — sentence length, vocabulary, structure
3. `## Anti-AI Guidance` — avoid list, prefer list, voice markers
4. `## Workspace-Specific Rules` — goal-adapted writing conventions
5. `## Pet Peeves` — user-specified habits to avoid or preserve

**Anti-AI Guidance section design:**
The section populates with patterns from two sources:
- **Default rules** (populated from tone/audience answers): e.g., if user selects "Casual" tone, defaults include "Avoid formal transition phrases like 'Furthermore' and 'In conclusion'." If "Professional," defaults include "Avoid conversational filler like 'basically' and 'you know'."
- **Sample-derived rules** (populated only if user provides a writing sample): e.g., "Short declarative sentences (avg 12 words)" extracted from sample analysis.

**Writing sample handling:**
If user pastes a sample, the wizard extracts ≥2 observable patterns (sentence rhythm, vocabulary register, characteristic phrases) and states them explicitly for user confirmation before including in the profile. The raw sample text is NOT stored in writing-profile.md — only extracted patterns are written. This addresses E6 (user pastes content with sensitive information).

**Default generation rule:**
The writing profile must NEVER ship as empty or placeholder-only. Minimum substantive content: at minimum, the Tone & Voice and Anti-AI Guidance sections must contain non-placeholder content derived from the 3–4 interview questions, even if the user skips the optional writing sample. Spec E2 explicitly requires this.

### File Location Architecture

**In generated workspace output:**
```
<user-workspace>/
|-- writing-profile.md      # Generated by wizard, unique per user
```

**In preset folders:**
```
presets/<preset>/context/
|-- writing-profile.md      # NEW: pre-filled template with goal-appropriate defaults
```

Preset-bundled `writing-profile.md` files ship with goal-appropriate defaults populated (not blank). A Study preset writing profile pre-fills academic writing defaults; a Business/Admin preset pre-fills professional communication defaults. Users fill in personal details (name, specific preferences) during or after the wizard.

**In templates directory:**
```
templates/
|-- writing-profile-template.md    # NEW: blank template with all required sections
```

This is the canonical template used by CONTRIBUTING.md for community contributors creating new presets. CI enforces it exists and contains required sections.

### global-instructions.md Writing Profile Trigger

Every preset's `global-instructions.md` adds a writing profile trigger rule (v1.2):

> "When generating written content ≥100 words, reference `writing-profile.md` for voice and anti-AI guidance if the file exists in the project folder."

This rule connects the writing profile to actual usage behavior. Without it, the writing profile exists as a file but never gets consulted.

**Word threshold rationale:** 100 words is the threshold below which strict voice matching would be pedantic (e.g., a one-line yes/no answer). Above 100 words, voice consistency is perceptible and valuable. This threshold is a judgment call — it may need tuning post-launch.

### Repo Structure Addition (v1.2)

```
templates/
|-- writing-profile-template.md    # NEW

presets/*/context/
|-- writing-profile.md             # NEW (goal-appropriate defaults per preset)
```

### Consequences

- `templates/writing-profile-template.md` is a new required repo artifact. CI enforces existence and section headers (ADR-014).
- 6 new `presets/*/context/writing-profile.md` files ship with each preset — populated with goal-appropriate defaults, not blank.
- All 6 `global-instructions.md` files receive the writing profile trigger rule.
- `docs/OUTPUT-STRUCTURE.md` must be updated to include `writing-profile.md` in the output package.
- CONTRIBUTING.md PR checklist gains a new requirement: `writing-profile.md` context file present in preset with non-placeholder content.
- The anti-AI framing is "voice calibration" throughout — the word "bypass" does not appear in any wizard instruction, template, or documentation.

---

## ADR-014: CI Expansion v1.2 — Writing Profile Template Enforcement

**Date:** 2026-04-17
**Status:** ACCEPTED

### Context

v1.2 introduces `templates/writing-profile-template.md` as a new required repo artifact. If this file is absent or missing required sections, community contributors creating new presets have no canonical template to follow, and the CI `writing-profile-template-check` job (F10 AC) will fail. This ADR documents the job specification.

The existing 4 v1.1 CI jobs (starter-file-check, starter-safety-rule-check, skill-format-check, plus the pre-existing claude-md-safety-rule-check) remain unchanged. One new job is added.

### Decision

**New CI job: `writing-profile-template-check`**

```yaml
writing-profile-template-check:
  name: Writing Profile Template Check
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@<sha>
    - name: Verify writing profile template exists with required sections
      run: |
        if [ ! -f "templates/writing-profile-template.md" ]; then
          echo "MISSING: templates/writing-profile-template.md"
          exit 1
        fi
        FAIL=0
        for section in "## Tone & Voice" "## Anti-AI Guidance" "## Workspace-Specific Rules"; do
          if ! grep -qF "$section" "templates/writing-profile-template.md"; then
            echo "MISSING section: $section"
            FAIL=1
          fi
        done
        if [ "$FAIL" -eq 1 ]; then
          exit 1
        fi
        echo "Writing profile template present with all required sections."
```

**Required sections checked:**
- `## Tone & Voice`
- `## Anti-AI Guidance`
- `## Workspace-Specific Rules`

These three are the minimum that make a writing profile functionally useful:
- Tone & Voice defines the register
- Anti-AI Guidance prevents generic AI patterns
- Workspace-Specific Rules connects the profile to the actual workspace goal

`## Style Preferences` and `## Pet Peeves` are not CI-checked — they are useful but not required for a functional profile. This follows the principle of enforcing the minimum necessary, not the maximum possible.

**Job behavior:**
- Blocks PRs on failure (no `continue-on-error`)
- Checks file existence AND section presence in one step
- Uses `grep -qF` (fixed string, not regex) to avoid false matches from heading variations

### Updated CI Job Count

After v1.2, `.github/workflows/quality.yml` contains:

| Job | Purpose | Blocks PR? |
|-----|---------|-----------|
| markdown-lint | Markdown formatting | Yes |
| link-check (internal) | Internal link integrity | Yes |
| link-check-external | External link integrity | No (continue-on-error) |
| shellcheck | Shell script safety | Yes |
| safety-rule-check | Safety rule in global-instructions.md | Yes |
| starter-file-check | Starter files exist for all presets | Yes |
| starter-safety-rule-check | Safety rule in starter files | Yes |
| skill-format-check | folder/SKILL.md format enforced | Yes |
| claude-md-safety-rule-check | Safety rule in CLAUDE.md | Yes |
| writing-profile-template-check | Writing profile template exists + sections | Yes |

Total: 10 jobs (4 original + 5 v1.1 + 1 v1.2 = 10).

### Consequences

- `.github/workflows/quality.yml` gains one new job.
- The writing-profile-template-check job is the first CI job that enforces a content template (as opposed to a file-existence or format check). This sets a precedent for CI-enforcing template structure in future cycles.
- No changes to existing jobs.
- `claude-md-safety-rule-check` is already present from v1.1.1 — it is not a v1.2 addition, but is counted in the full job count for clarity.

---

## v1.2 Anti-Pattern Scan

Anti-pattern scan applied to v1.2 additions (ADR-010 through ADR-014):

| # | Anti-Pattern | Applies to v1.2? | Notes |
|---|-------------|-----------------|-------|
| 1 | God Class/Module | No | No code modules. CLAUDE.md/starter files are content with a single responsibility each. |
| 2 | Circular Dependencies | Watched | Dependency chain: CLAUDE.md → /setup-wizard → WIZARD.md → preset scripts → templates. One-directional, no cycles. curated-skills-registry.md has no dependencies. |
| 3 | Leaky Abstraction | No | No abstraction layers. Static content. |
| 4 | Premature Optimization | No | No runtime. curated-skills-registry.md is a static file, not a database. Decision to add CI job for template check is proportionate. |
| 5 | Over-Engineering | Watched | Tier 2 skill discovery adds complexity. Mitigated by keeping it as WIZARD.md content (no new files/jobs). Tier 2 is wizard conversation instructions, not infrastructure. |
| 6 | Tight Coupling | Watched | CLAUDE.md and starter files both contain wizard bootstrap logic — duplication, not coupling. Content duplication is an accepted trade-off per ADR-010. |
| 7 | Missing Separation of Concerns | No | Concerns are properly separated: state machine (CLAUDE.md/starter), interview scripts (WIZARD.md), skill registry (curated-skills-registry.md), templates (templates/), CI (quality.yml). |
| 8 | N+1 Query Pattern | No | No database. No queries. |
| 9 | Destructive Migration | No | No migrations. v1.2 is purely additive. Existing preset files are updated, not deleted. |

**Content duplication flag (ADR-010 trade-off):** CLAUDE.md and all 6 starter files contain equivalent wizard bootstrap logic. This is intentional (Option B decision) but creates a synchronization maintenance burden. Mitigated by: WIZARD.md as authoritative source, CONTRIBUTING.md enforcement, CI safety checks on both surfaces. If synchronization becomes a recurring issue, revisit with Option A (CLAUDE.md primary, starter files as preset-specific addendum only).

No blocking anti-patterns detected for v1.2.

---

## v1.2 Safety Architecture Update

The v1.1 four-layer safety architecture extends with one new layer:

1. **Template layer:** `templates/global-instructions-base.md` — canonical safety rule text (unchanged)
2. **Preset layer:** Every preset's `global-instructions.md` — carries safety rule + writing profile trigger (updated v1.2)
3. **Starter file layer:** Every `project-instructions-starter.txt` — safety rule verbatim (updated v1.2: dynamic wizard content)
4. **CLAUDE.md layer:** `CLAUDE.md` at repo root — safety rule verbatim (updated v1.2: dynamic wizard content)
5. **CI layer:** claude-md-safety-rule-check + starter-safety-rule-check + safety-rule-check — three independent enforcement points (v1.1.1 + v1.1; unchanged)

The writing profile trigger in `global-instructions.md` is not a safety rule but a behavioral consistency rule. It is not CI-enforced at this time — it is a CONTRIBUTING.md checklist requirement for community presets.

---

## ADR-015: Canonical 9-Section Skill Template (v1.3.0)

**Date:** 2026-04-17
**Status:** ACCEPTED

### Context

All 18 preset skills shipped in v1.0–v1.2 as 16-line stubs: YAML frontmatter, one-line "When to use," one-paragraph "Instructions," three "Example prompts." There is no quality floor — a skill does not tell Cowork what GOOD output looks like vs BAD output, and community contributors will copy whatever shape ships. v1.3.0 establishes the permanent quality baseline via a canonical template at `templates/skill-template/SKILL.md`.

Section NAMES and count are fixed by @pm's spec (B1); section CONTENTS, order, and length guidance are this ADR's responsibility.

### Options Considered

**Option A — 9-section template, order follows runtime invocation flow** (RECOMMENDED)

Order: `When to use` → `Triggers` → `Instructions` → `Output format` → `Quality criteria` → `Anti-patterns` → `Example` → `Writing-profile integration` → `Example prompts`.

Rationale for order: follows the way Cowork actually reads the skill at runtime — first decides IF it applies (`When to use` + `Triggers`), then HOW to execute (`Instructions` + `Output format`), then checks its work (`Quality criteria` + `Anti-patterns`), then references a concrete reference (`Example`), then layers voice (`Writing-profile integration`), then gives the user discoverable invocation phrasings (`Example prompts`).

- Pros: Matches execution flow; reviewer reading top-to-bottom follows a natural "decide → act → check" narrative; `Triggers` before `Instructions` is critical because `global-instructions.md` proactive trigger rules (v1.1) must stay consistent with the skill's own `Triggers` list.
- Cons: `Example prompts` at the end feels "away" from `When to use`, but splitting would fragment the trigger surface.

**Option B — Prompt-surface-first order (Example prompts after Triggers)**

Put `Example prompts` immediately after `Triggers`, before `Instructions`.

- Pros: All user-facing invocation surface is grouped at the top.
- Cons: Reviewer skims over `Instructions`/`Quality criteria` rather than reading top-down. Also weakens the existing `presets/*/skills-as-prompts.md` pattern, which already serves as the "prompt-first" copy-paste surface (ADR-007 decision to retain).

**Option C — Minimal template (6 sections, no Triggers, no Writing-profile integration)**

- Pros: Shorter skill files (~60 lines).
- Cons: Fails to integrate with v1.1 proactive triggers (regression) and v1.2 writing profile (regression). Rejected.

### Decision

**Option A — 9-section template, runtime-flow order.**

### Template Specification

| # | Section (`## heading`) | Required content | Length guidance |
|---|-----------------------|------------------|-----------------|
| 1 | `## When to use` | 2–3 sentences covering normal case + 1 edge condition. Declarative, not imperative. | 3–6 lines |
| 2 | `## Triggers` | Bullet list of signal phrases/situations that should auto-invoke. Must be consistent with the preset's `global-instructions.md` proactive rules. | 4–8 bullets |
| 3 | `## Instructions` | Numbered steps (not prose paragraph). Each step: one verb + one outcome. | 5–10 numbered steps |
| 4 | `## Output format` | Explicit structure Cowork must produce (sections, headings, tables, counts, or bullet schema). Example: "Numbered list of 10–20 items. Each item: `**Q:** ... **A:** ...` (A ≤ 3 sentences)." | 4–10 lines |
| 5 | `## Quality criteria` | 3–5 concrete, checkable criteria. Each on one line, testable (a reviewer can answer yes/no). | 3–5 bullets |
| 6 | `## Anti-patterns` | 3–5 common mistakes, one line each. What NOT to do. | 3–5 bullets |
| 7 | `## Example` | Exactly ONE worked input→output pair. A real example, not a hypothetical. | 15–40 lines |
| 8 | `## Writing-profile integration` | 1–3 sentences describing when this skill consults `context/writing-profile.md` (per v1.2 ≥100-word trigger). If skill always produces <100 words, say so. | 1–4 lines |
| 9 | `## Example prompts` | 3 bullets. Realistic invocations the user might type. | 3 bullets |

**Order justification — Triggers before Instructions:** The `Triggers` section is read by `global-instructions.md` proactive rules at session start; `Instructions` is read only when the skill actually fires. Putting `Triggers` first matches the "does this apply?" → "now execute" reading order. This ADR treats the pair as an inseparable gate.

**Order justification — Writing-profile integration near the end:** It is a cross-cutting overlay that modifies output voice, not output structure. It must be placed AFTER `Output format` and `Example` so a contributor composing a skill reads "here is the structure" → "here is a concrete example" → "now overlay voice." Placing it earlier would invite contributors to skip the structure and write voice-first skills.

### YAML Frontmatter Schema

```yaml
---
name: <skill-slug>           # required, matches folder name
description: <one sentence>  # required, ≤ 160 chars
trigger_examples:            # NEW in v1.3.0, optional
  - "example phrase 1"
  - "example phrase 2"
  - "example phrase 3"
---
```

`trigger_examples` is optional (community skills may omit) but recommended; it provides the raw strings `global-instructions.md` rules can pattern-match against without needing to parse the `## Triggers` markdown body. Field is a YAML list of strings, 3–6 entries recommended.

### Length Budget

- **Target:** 80–120 lines per SKILL.md (frontmatter + body combined).
- **Floor:** 60 lines. Below this, content depth is insufficient; CI fails (ADR-016).
- **Soft cap:** 150 lines. Above this, skill becomes over-engineered; CONTRIBUTING.md advises splitting or trimming (no CI enforcement — judgment call).
- **Hard cap:** None. CI only enforces the floor and section presence, not ceiling.

### A-v1.3-2 Stress Test (two non-Study skills on paper)

Per the spec and assumption A-v1.3-2, the template must be validated against at least one non-Study skill before other presets commit to it. Two skills were evaluated against the 9 sections as a desk-check:

**Skill 1 — `presets/writing/.claude/skills/voice-matching/SKILL.md` (exercises Writing-profile integration)**

| Section | Fits? | Note |
|---------|-------|------|
| When to use | Yes | "When Cowork-generated content must sound like the user" — existing 16-line skill already has this. |
| Triggers | Yes | "User shares a writing sample"; "User requests content in their voice"; "Output ≥100 words and a voice profile exists." |
| Instructions | Yes | Maps to existing prose as 4–5 numbered steps: read samples → identify patterns → generate → note voice choices → ask for sample if none. |
| Output format | Yes | "Text block matching user's register; 1-sentence meta-note on voice choices at the end." |
| Quality criteria | Yes | "Sentence-length distribution within 20% of sample"; "Named voice idiosyncrasy preserved"; "Meta-note present"; etc. |
| Anti-patterns | Yes | "Averaging samples to generic clear writing"; "Ignoring sample when one exists"; "Silently adopting AI tics (em-dash flood)." |
| Example | Yes | One sample paragraph → one generated paragraph in that voice. |
| Writing-profile integration | Yes (primary fit) | This skill IS the writing profile at runtime. Section states: "Always consult `context/writing-profile.md` regardless of output length — this skill's entire purpose is voice." |
| Example prompts | Yes | Existing three prompts map directly. |

Template fits `voice-matching` without contortion. Writing-profile integration section is especially valuable here — it upgrades from "when applicable" to "always primary source."

**Skill 2 — `presets/project-management/.claude/skills/status-update/SKILL.md` (exercises different output shape from flashcards)**

| Section | Fits? | Note |
|---------|-------|------|
| When to use | Yes | "Communicating project progress to stakeholders." |
| Triggers | Yes | "User says 'status update'"; "User mentions weekly report"; "User asks what's in-flight." |
| Instructions | Yes | 4–5 numbered steps: ask project/audience → gather state → structure output by four-section schema → calibrate to audience. |
| Output format | Yes (strong fit) | Fixed schema: `(1) Status (RAG), (2) Progress bullets, (3) Risks with mitigation, (4) Next steps`. Template's `Output format` section is IDEAL for fixed-schema outputs — this is where `status-update` is easier to specify than `flashcard-generation` (which has a looser schema). |
| Quality criteria | Yes | "All four sections present"; "Total ≤200 words"; "Audience-calibrated formality"; "Risks ranked by severity." |
| Anti-patterns | Yes | "RAG without evidence"; "Generic 'on track' with no progress bullets"; "Missing ownership on next steps." |
| Example | Yes | One ask → one 4-section update. |
| Writing-profile integration | Yes | Status updates are typically <200 words, so writing profile applies for the narrative clauses inside progress/risks bullets; use when voice profile exists. |
| Example prompts | Yes | Existing three prompts map directly. |

Template fits `status-update` with the `Output format` section providing structure the current 16-line stub entirely lacks. No template revision required.

**Stress test result: A-v1.3-2 VALIDATED.** The 9-section template fits both a voice-centric skill (`voice-matching`) and a fixed-schema skill (`status-update`) without requiring section additions, removals, or order changes. The template is suitable for all 18 preset skills. No revisions required before Study preset commits.

### Backwards Compatibility

Non-Study presets ship with 16-line format until their scheduled rewrite release (v1.3.1–v1.3.5):

1. `skill-format-check` CI (ADR-008) continues to validate `folder/SKILL.md` format — 16-line skills pass.
2. `skill-depth-check` CI (ADR-016) is scoped via path allowlist — does NOT run on non-rewritten presets.
3. CONTRIBUTING.md will declare the 9-section template the "community submission bar" for NEW skills in any preset, but existing 16-line skills in not-yet-rewritten presets remain valid until their cycle.
4. When a preset's release lands (e.g., v1.3.1 Research), the allowlist widens and CI begins enforcing depth for that preset's SKILL.md files. All 3 skills in that preset must be rewritten in the same release.

### Consequences

- New file: `templates/skill-template/SKILL.md` — the canonical 9-section template with inline placeholder comments for each section.
- 3 Study preset skills (`flashcard-generation`, `note-taking`, `research-synthesis`) will be rewritten to this template during v1.3.0 Phase 4 via the user-in-the-loop workflow (ADR-017).
- `templates/preset-template/.claude/skills/example-skill/SKILL.md` is NOT replaced in v1.3.0 — it remains as the minimal scaffold for NEW preset creation. A separate item (post-v1.3.5) consolidates `skill-template` + `example-skill` into one canonical scaffold after all presets are deep.
- `trigger_examples` YAML field is new; `skill-format-check` must NOT fail a skill that lacks it (optional field).
- CONTRIBUTING.md PR checklist gains an item referencing the new template for any new skill submission.

---

## ADR-016: `skill-depth-check` CI with Path Allowlist (v1.3.0)

**Date:** 2026-04-17
**Status:** ACCEPTED

### Context

The 9-section template (ADR-015) is enforceable only if CI verifies it on every PR. But rolling out to 6 presets over 6 releases (v1.3.0–v1.3.5) means non-rewritten presets must NOT fail CI while still on the 16-line format. A path allowlist is the mechanism.

### Options Considered

**Option A — Path allowlist widened per release** (RECOMMENDED — matches spec & plan)

One shell variable inside the CI job lists the currently-enforced preset paths. v1.3.0 starts with `study/`. Each v1.3.x bumps the list by one.

- Pros: Zero risk of false-positive failures on not-yet-deep presets. One-line edit per release. Failure mode (missing preset from allowlist) is silent skip — safe default.
- Cons: Allowlist can drift (preset renamed without list update = silent skip). Mitigated by a) comment documenting rollout schedule inside the CI job, b) per-release spec review confirms the path. Trade-off accepted per A-v1.3-4.

**Option B — Global enforcement on `presets/**` starting v1.3.0**

- Pros: Zero allowlist maintenance.
- Cons: Would fail CI on the 15 skills across 5 presets still on 16-line format at v1.3.0. Unacceptable — blocks v1.3.0 release. Rejected.

**Option C — File-frontmatter opt-in (`depth_format: true` field)**

Each SKILL.md opts in to the deep check via YAML frontmatter.

- Pros: Per-skill granularity.
- Cons: Contributor cognitive load (two formats to know about); future migrations require touching every skill file twice (opt-in, then remove opt-in post-v1.3.5). Rejected as over-engineering.

### Decision

**Option A — Path allowlist widened per release.** Matches spec B2 AC ("Job scope is limited to `presets/study/.claude/skills/**` in v1.3.0") and the rollout plan.

### Header-Matcher Implementation

Reuses the `grep -qF` (fixed-string header match) idiom already proven in `safety-rule-check` and `writing-profile-template-check`. Exact bash implementation:

```yaml
skill-depth-check:
  name: Skill Depth Check
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
    - name: Verify 9-section structure and line count for depth-enforced presets
      run: |
        # Path allowlist — widened one preset per release (v1.3.0–v1.3.5).
        # v1.3.0: study only. v1.3.1: study + research. ... v1.3.5: all 6.
        # See ADR-016 and docs/spec.md Rollout Plan section.
        ENFORCED_PRESETS="study"
        REQUIRED_SECTIONS=(
          "## When to use"
          "## Triggers"
          "## Instructions"
          "## Output format"
          "## Quality criteria"
          "## Anti-patterns"
          "## Example"
          "## Writing-profile integration"
          "## Example prompts"
        )
        MIN_LINES=60
        FAIL=0
        for preset in $ENFORCED_PRESETS; do
          for skill_file in presets/$preset/.claude/skills/*/SKILL.md; do
            [ -f "$skill_file" ] || continue
            # 1. All 9 section headers present (exact match)
            for section in "${REQUIRED_SECTIONS[@]}"; do
              if ! grep -qF "$section" "$skill_file"; then
                echo "MISSING section \"$section\" in: $skill_file"
                echo "  Fix: add a '$section' heading. See templates/skill-template/SKILL.md for the canonical structure."
                FAIL=1
              fi
            done
            # 2. Line-count floor
            LINES=$(wc -l < "$skill_file")
            if [ "$LINES" -lt "$MIN_LINES" ]; then
              echo "TOO SHORT ($LINES lines, minimum $MIN_LINES): $skill_file"
              echo "  Depth-enforced skills must be >=60 lines. Target range is 80-120."
              FAIL=1
            fi
          done
        done
        if [ "$FAIL" -eq 1 ]; then
          echo ""
          echo "skill-depth-check failed. Every SKILL.md in an enforced preset must have all 9 section headers (exact match) and be >=60 lines."
          echo "Reference: templates/skill-template/SKILL.md and docs/architecture.md (ADR-015)."
          exit 1
        fi
        echo "skill-depth-check passed for enforced presets: $ENFORCED_PRESETS"
```

### Non-Emptiness of Each Section (judgment call — NOT enforced in v1.3.0)

The spec open-question "each section non-empty (at least N non-whitespace lines inside)" is intentionally NOT enforced by CI in v1.3.0:

- Counting "lines inside a section" requires parsing section boundaries (next `##` heading or EOF), which is fragile.
- The risk of a "heading-only, no content" skill passing is mitigated by the line-count floor (60 lines across 9 sections implies average 6–7 lines per section).
- CONTRIBUTING.md PR review catches per-section emptiness; machine enforcement here is over-engineering.

Documented in ADR as an explicit non-goal of v1.3.0 CI. Revisit in v1.3.5 retrospective.

### Negative Test Fixture

A negative test fixture proves CI fails on malformed input without shipping the malformed file to main. Three options considered:

- Fixture at `tests/ci-fixtures/negative-skill-missing-section.md` — a committed file the CI validates separately. Reject: clutters repo.
- Inline fixture (temporary file created during CI step, asserted to fail). Reject: adds complexity.
- **ADOPTED — Documented manual negative test:** The ADR + CI job comment specifies the negative test procedure:
  1. Locally: `sed -i '/^## Anti-patterns/,/^## /d' presets/study/.claude/skills/flashcard-generation/SKILL.md`
  2. Run `act -j skill-depth-check` (or push to a throwaway branch).
  3. Expected: job fails with "MISSING section '## Anti-patterns' in: presets/study/.claude/skills/flashcard-generation/SKILL.md".
  4. `git checkout -- presets/study/.claude/skills/flashcard-generation/SKILL.md` to restore.
  5. Re-run: passes.

  This procedure is documented in the CI job comment (`# Negative test: delete ## Anti-patterns → expect fail`) and in CONTRIBUTING.md for maintainer verification. B2 AC "Deliberately deleting the `## Anti-patterns` section from any Study skill causes the job to fail" is satisfied by following this procedure at implementation time; @qa verifies during Phase 5 as part of CI validation scenarios.

### Failure Output

The CI error message MUST be contributor-friendly (A-v1.3-3 risk mitigation):

```
MISSING section "## Anti-patterns" in: presets/study/.claude/skills/flashcard-generation/SKILL.md
  Fix: add a '## Anti-patterns' heading. See templates/skill-template/SKILL.md for the canonical structure.
```

Not just exit code 1. This is the reason to prefer explicit bash output over off-the-shelf linting tools.

### Rollout Plan (CI allowlist widening)

| Release | `ENFORCED_PRESETS` value | PR diff size |
|---------|--------------------------|--------------|
| v1.3.0 | `"study"` | (initial) |
| v1.3.1 | `"study research"` | 1-line edit in CI + 3 new deep skills |
| v1.3.2 | `"study research writing"` | same |
| v1.3.3 | `"study research writing creative"` | same |
| v1.3.4 | `"study research writing creative project-management"` | same |
| v1.3.5 | `"study research writing creative project-management business-admin"` OR replace with `*` glob | final — consider retiring allowlist |

At v1.3.5, evaluate consolidation to `for preset in presets/*/; do` (no allowlist). Close the technical debt per A-v1.3-4 validation path.

### Consequences

- `.github/workflows/quality.yml` gains one new job (`skill-depth-check`). Total CI jobs: 14 → 15 after v1.3.0.
- Non-Study presets remain on 16-line format until their release — no CI regression.
- CI error output format establishes a precedent: fixable, human-readable messages with pointer to canonical reference. Future CI jobs should follow.
- Per-release spec must confirm the allowlist edit in its Phase 4 Intent Contract.

---

## ADR-017: Per-Skill User-Input Schema for User-in-the-Loop Authoring (v1.3.0)

**Date:** 2026-04-17
**Status:** ACCEPTED

### Context

B10 (spec) introduces user-in-the-loop authoring: for each of the 3 Study skills, the orchestrator asks the user 4–6 targeted questions before @dev drafts. Answers are saved as pipeline state under `.claude/projects/claude-cowork-config/cycles/v1.3.0/skill-inputs/<skill-name>.md`. This ADR locks the question set, file schema, and how @dev and @qa consume the file.

### Options Considered

**Option A — Free-form conversation, orchestrator summarizes to file**

- Pros: Lowest friction for user.
- Cons: Summary is lossy; hard for retro to compare across 3 skills; @dev input→output mapping ambiguous.

**Option B — Fixed question set + structured file format** (RECOMMENDED)

A fixed question set (the same 5 questions asked per skill, one optional 6th follow-up) saved to a templated markdown file with one section per question.

- Pros: Consistency across 3 skills; unambiguous @dev mapping; retro has clean Q&A evidence.
- Cons: 5 questions may feel formulaic for simple skills. Mitigation: question 6 is an optional free-form "anything else" follow-up.

**Option C — 6+ questions including test-case generation**

- Pros: More input material.
- Cons: Exceeds B10 spec scope and risks A-v1.3-1 fatigue. Rejected.

### Decision

**Option B — Fixed 5-question schema, 1 optional follow-up, structured file.**

### The 5 Locked Questions (+ 1 optional)

Every skill's input session asks these exact questions in this order:

1. **Quality criteria (Q1):** "What makes a GOOD `<skill-name>` output, in your experience? Give me 3–5 concrete things a reviewer could check yes/no on."
   → Feeds `## Quality criteria` section.

2. **Anti-patterns (Q2):** "What does Cowork (or AI tools in general) tend to get wrong when you use this skill today? Give me 3–5 common failure modes."
   → Feeds `## Anti-patterns` section.

3. **Worked example (Q3):** "Give me ONE real input you'd feed this skill + the ideal output you want back. Don't sanitize — a real, specific example is much more valuable than a generic one."
   → Feeds `## Example` section.

4. **Writing voice feel (Q4):** "When this skill produces prose (any amount, even a bullet), how should it feel? Clinical, conversational, academic, punchy, warm, something else? Is there a voice you actively want to avoid?"
   → Feeds `## Writing-profile integration` section.

5. **Trigger phrases (Q5):** "What phrases or situations should auto-invoke this skill proactively? Give me 3–6 real phrases you (or your user archetype) might say that should fire this skill without being asked."
   → Feeds `## Triggers` section AND YAML `trigger_examples` field.

6. **(Optional — Q6):** "Anything else about how this skill should behave that I haven't asked about?"
   → Free-form. May feed any section or inform the `## When to use` / `## Instructions` framing. Not required.

**Why these 5, not others:** Each question maps 1:1 to the template section most dependent on human judgment. `Instructions`, `Output format`, and `Example prompts` are derivable by @dev from the worked example (Q3) + existing 16-line skill as a scaffold, so they are NOT asked directly. `When to use` is a restatement of Q5 with a broader framing, so it's derivable. This keeps the user-facing ask minimum.

### Input File Schema

Location: `.claude/projects/claude-cowork-config/cycles/v1.3.0/skill-inputs/<skill-name>.md`

Not committed to product repo — pipeline state only. Lives in The-Council's project state directory.

```markdown
---
skill: <skill-slug>
preset: study
cycle: v1.3.0
session_started: <ISO-8601-UTC>
session_completed: <ISO-8601-UTC>
---

# Skill Input Session — <skill-name>

## Q1 — Quality criteria
<user's verbatim or close-paraphrase answer>

## Q2 — Anti-patterns
<user's answer>

## Q3 — Worked example
**Input:**
<user's real input>

**Desired output:**
<user's ideal output>

## Q4 — Writing voice feel
<user's answer>

## Q5 — Trigger phrases
<user's answer — list or prose>

## Q6 — Anything else (optional)
<user's answer OR "N/A">

---

## Draft → Review iterations

### Draft 1 — <ISO-8601-UTC>
<link or path to draft commit/SHA>
User feedback: <per-section good/change/replace notes>

### Draft 2 — <ISO-8601-UTC>
<link/SHA>
User feedback: ...

### Approved — <ISO-8601-UTC>
Final commit SHA: <sha>
```

### @dev → SKILL.md Mapping

Explicit mapping from input-file section to SKILL.md target section:

| Input file section | SKILL.md target | Transformation |
|-------------------|-----------------|----------------|
| Q1 (Quality criteria) | `## Quality criteria` | 3–5 bullets, one line each, rephrased for imperative ("Each card Q is answerable only by reading the source") |
| Q2 (Anti-patterns) | `## Anti-patterns` | 3–5 bullets, one line each, phrased as "Avoid X" or just the failure mode |
| Q3 (Worked example) | `## Example` | Verbatim input→output (may trim per spec E1 with user confirmation) |
| Q4 (Writing voice feel) | `## Writing-profile integration` | 1–3 sentences describing when/how `writing-profile.md` is consulted for this skill's outputs |
| Q5 (Trigger phrases) | `## Triggers` (body) + YAML `trigger_examples` (frontmatter list) | Bullet list in body; 3–6 strings in frontmatter |
| Q6 (Anything else) | Any section, judgment call | Often informs `## When to use` or step ordering in `## Instructions` |
| (derived from Q3 + existing skill) | `## When to use`, `## Instructions`, `## Output format`, `## Example prompts` | @dev drafts from worked example + v1.2 16-line skill as scaffold |

### Retro (Phase 8) Evidence

The input files provide three kinds of evidence for retro:

1. **"Did user input produce better skills?" signal:** Compare `## Quality criteria` in the final SKILL.md against Q1 answer fidelity. If user's exact criteria survive into the committed skill, the workflow worked. If @dev paraphrased away user intent, the workflow failed.
2. **A-v1.3-1 fatigue validation:** Look at `session_started` → `session_completed` span and Q6 completeness across 3 skills. If skill 3's Q6 is "N/A" while skills 1–2 have content, fatigue is confirmed.
3. **Pilot-first validation:** Compare `flashcard-generation` input file against `note-taking` input file. Did the user's quality bar rise (reflecting pilot learnings)? Did @dev's interpretation tighten?

Retro reads these three signals, writes findings to `docs/retro.md` under the v1.3.0 section.

### Consequences

- Before Phase 4 begins, `.claude/projects/claude-cowork-config/cycles/v1.3.0/skill-inputs/` directory is created by the orchestrator.
- @dev MUST NOT commit a Study skill without a corresponding input file committed to pipeline state first. Phase 7 approval checks all 3 input files exist.
- @qa (Phase 5) cross-references input file Q1 against committed SKILL.md `## Quality criteria` to verify user intent survived drafting.
- @qa (Phase 8) uses input files for retro evidence per the three signals above.
- Spec B10 AC ("User-input session file exists for all 3 Study skills") is satisfied by this schema.
- No product repo changes — all artifacts are pipeline state under `.claude/projects/claude-cowork-config/`.

---

## v1.3.0 Supporting Architecture Updates

### README "Next up" section (B9) — exact placement

- **File:** `README.md` (repo root)
- **Placement:** Immediately ABOVE the existing `## Staying up to date` heading.
- **Section heading:** `## Next up — v1.3.0 Preset Skills Depth`
- **Body (≤5 sentences):**

  > Preset skills are moving from 16-line stubs to structured, production-grade skills with explicit triggers, output formats, quality criteria, anti-patterns, and worked examples. **Study preset ships first** in v1.3.0 (pilot: `flashcard-generation`). Subsequent point releases (v1.3.1–v1.3.5) deepen one preset per release. Track progress on the pinned [Roadmap Issue](https://github.com/jmlozano1990/cowork-starter-kit/issues/2) or the [v1.3.0 Milestone](https://github.com/jmlozano1990/cowork-starter-kit/milestone/1).

- **Verification:** After edit, `grep -n "## Next up" README.md` must return a line number strictly less than the line number of `## Staying up to date` in the same file.

### Retro template carry-forward section (B8)

- **File:** `docs/retro-template.md`
- **Section heading:** `## Carry-Forward Review` (level-2, immediately after `## 1. Cycle Summary`)
- **Body structure:** One instruction line + one table:

  > Review `docs/retro.md` previous cycle's Carry-Forward Items table before writing any Phase 0 ACs. Any MEDIUM-or-higher carry-forward must be either (a) addressed in this cycle's spec or (b) explicitly deferred with rationale in the Action column below.

  | Item | Source | Priority | Disposition (addressed-in-spec / deferred-with-reason) | Reference |
  |------|--------|----------|---------------------------------------------------------|-----------|
  | - [ ] <item>         | <Phase X Finding ID> | CRITICAL / MEDIUM / LOW | <disposition> | <spec section or deferral note> |

- **CONTRIBUTING.md checklist row wording (appended to the existing numbered PR checklist):**
  > [N+1]. Carry-forward items from prior retro reviewed and actioned or explicitly deferred with rationale. See [retro-template.md](./retro-template.md#carry-forward-review) for the review procedure.

### `registry-url-check` tightening (B7)

Resolves A2 MEDIUM carry-forward from v1.2 Phase 6.

- **Allowlist regex:** `^https://github\.com/` (GitHub only) OR exact literal string `builtin`. All other URL schemes and hosts are rejected, including previously-allowed generic `https://` URLs to non-GitHub hosts.

- **Exact rejection logic (replaces current `grep -q '^http://'` check in the existing job):**

  ```bash
  # For each extracted url value:
  if [ "$url" != "builtin" ] && ! echo "$url" | grep -qE '^https://github\.com/'; then
    echo "DISALLOWED URL scheme or host: $url"
    echo "source_url must be either 'builtin' or an HTTPS URL on github.com."
    echo "Rationale: community skill sources must be reviewable on GitHub (SHA-pinnable)."
    echo "See CONTRIBUTING.md 'Registry entry URL policy' and docs/architecture.md (ADR-012)."
    FAIL=1
  fi
  ```

- **Negative test fixture layout:** An unreachable sentinel row in a test-only file `curated-skills-registry.test.md` (NOT the real registry) with a hardcoded `| ftp://NEGATIVE-TEST-FIXTURE-v1.3.0 |` entry. CI job runs the same logic against the test file in a separate step and asserts `FAIL=1` is set; if it passes instead, CI fails. This proves the check is live without risk of the sentinel leaking into production registry. Document the sentinel string in the CI job comment.

- **Error message (contributor-friendly):**

  ```
  DISALLOWED URL scheme or host: <offending-url>
  source_url must be either 'builtin' or an HTTPS URL on github.com (e.g., https://github.com/org/repo/blob/<sha>/path/SKILL.md).
  Rationale: all community skill sources must be reviewable on GitHub and SHA-pinnable.
  ```

- **Existing 18 registry entries compatibility:** Verified at Phase 4 commit time by running the tightened check against the current `curated-skills-registry.md` — if any existing entry fails, @dev escalates to @architect before merging the tightening. Current v1.2 entries are all `builtin` (Phase 5 Re-test confirmed, 2026-04-17); no non-GitHub HTTPS entries exist, so tightening is non-breaking as of Phase 1.

---

## v1.3.0 Deliverable Dependency Graph

This graph formalizes sequencing for @dev in Phase 4. Arrows mean "must complete before." Independent deliverables can parallelize.

```
                          B1 (template)
                            |
                            v
                          B2 (CI job)
                            |
                            v
                  B3 (flashcard-generation — PILOT)
                            |   (pilot approved)
                            v
                   B4a (note-taking)
                            |
                            v
                   B4b (research-synthesis)
                            |
                            v
                 B5 (regenerate skills-as-prompts.md)
                            |
                            v
              B6 (curated-skills-registry Study entries review)

  [independent tracks — parallelizable with B1-B6]:
  B7 (registry-url-check tightening)     --- resolves v1.2 A2
  B8 (retro-template carry-forward)      --- resolves v1.2 process gap
  B9 (README "Next up" + GH signals)     --- Milestone + Issue already live
  B10 (input-file schema + 3 sessions)   --- runs DURING B3 and B4, not after
```

**Hard sequencing constraints (from spec):**

1. **B1 → B2:** CI job can only check what the template defines; B1 must land first.
2. **B1 → B3/B4:** Skill rewrites reference the template; cannot begin before B1 exists.
3. **B3 (pilot) → B4a (note-taking):** `flashcard-generation` must be fully approved (committed + CI green) before `note-taking` authoring begins. Hard pilot-first sequencing — enables template revisions if pilot reveals issues.
4. **B4a → B4b:** Serial within Study preset for consistency with pilot-first ethos (ordering from spec).
5. **All 3 Study skills → B5:** `skills-as-prompts.md` regeneration reads from the final committed SKILL.md sources.
6. **B5 → B6:** Registry descriptions may shift during rewrite; B6 reconciles after B5.
7. **B10 intertwines with B3 and B4:** Each skill's input session happens immediately BEFORE @dev drafts that skill, not in a batch. B10 is a sub-step of B3/B4, not a precursor.

**Independent (parallelizable with the template track):**

- B7, B8, B9 touch entirely different files from B1–B6 and can land in any order. Recommended execution: land B7 and B8 early in Phase 4 so CI (B7) and process docs (B8) are in force before skill commits begin.

**Phase 4 recommended commit sequence:**

1. B1 — template file commit
2. B7 — registry-url-check tightening commit (independent, fast)
3. B8 — retro-template carry-forward section + CONTRIBUTING.md row commit
4. B9 — README "Next up" teaser commit
5. B2 — skill-depth-check CI commit (the CI job is inert until B3 lands, but landing it early catches any B3 drift immediately)
6. B3 + B10 (flashcard-generation) — input session → draft → approval → commit
7. B4a + B10 (note-taking) — same
8. B4b + B10 (research-synthesis) — same
9. B5 — skills-as-prompts.md regeneration
10. B6 — registry entries review
11. Version bump, CHANGELOG, release

---

## v1.3.0 Anti-Pattern Scan

Applied per `.claude/skills/architect/A1-architect-framework.md` to v1.3.0 additions (ADR-015, ADR-016, ADR-017, and the supporting architecture updates):

| # | Anti-Pattern | Applies to v1.3.0? | Notes |
|---|-------------|--------------------|-------|
| 1 | God Class/Module | No | Template is one file with nine sections — single-responsibility per section. No module aggregation. |
| 2 | Circular Dependencies | No | Dependency chain: template → CI → skill files → skills-as-prompts → registry. One-directional. |
| 3 | Leaky Abstraction | No | Template sections map to runtime behavior; no hidden implementation bleeding through. |
| 4 | Premature Optimization | No | `trigger_examples` YAML field is additive and motivated by v1.1 proactive rules (existing use case), not speculative. |
| 5 | Over-Engineering | Watched | 9 sections is near the ceiling of what a contributor can maintain. Justified by A-v1.3-2 stress test showing every section earns its presence. Revisit at v1.3.5 — if any section has been empty-or-placeholder in ≥30% of community PRs, trim. |
| 6 | Tight Coupling | Watched | `## Triggers` section in SKILL.md must stay consistent with `global-instructions.md` proactive rules. Coupling is acknowledged; mitigation is the `trigger_examples` frontmatter field as the machine-readable source of truth. |
| 7 | Missing Separation of Concerns | No | Template (structure) vs CI (enforcement) vs input-file (user judgment capture) are three clean concerns. |
| 8 | N+1 Query Pattern | No | No queries. |
| 9 | Destructive Migration | No | v1.3.0 replaces 3 Study skills' contents. Old 16-line format remains in git history and in the 5 other presets. No data loss. |

**Coupling flag (#6):** Acceptable trade-off. Template authority is `## Triggers` (human-readable bullets) for contributor ergonomics; `trigger_examples` (machine-readable YAML) is what proactive-rule tooling reads. When they diverge, CONTRIBUTING.md review is the control; if divergence becomes a recurring issue in v1.3.1+, add a CI job that asserts `trigger_examples` is a subset of `## Triggers` bullet lines.

No blocking anti-patterns detected for v1.3.0.

---

## v1.3.0 Open Issues for Phase 2 (@security) and Deliberation

1. **Template as LLM instruction surface:** `templates/skill-template/SKILL.md` becomes the canonical shape for every community Tier 2 submission. Is the template itself an injection vector (e.g., placeholder text like "[your instructions here]" that a contributor could accidentally ship verbatim)? @security to review.
2. **`skill-depth-check` allowlist drift:** If a preset folder is renamed without updating `ENFORCED_PRESETS`, the check silently skips. @security to evaluate whether this fail-open default is acceptable (vs fail-closed: unknown preset fails CI).
3. **Input file path containment:** `.claude/projects/claude-cowork-config/cycles/v1.3.0/skill-inputs/` lives outside the product repo. Confirm this path is NOT included in any product-repo commit; orchestrator must enforce.
4. **`registry-url-check` tightening breaking change risk:** Confirmed non-breaking at Phase 1 against v1.2 entries (all `builtin`). @security to re-confirm at Phase 2 in case any late-landing PR adds a non-GitHub HTTPS entry before v1.3.0 commits.

---

## ADR-015 Amendment (v1.3.1): Stress-Test Re-Validation on Research Preset Shapes + Line-Ceiling Raise

**Date:** 2026-04-18
**Status:** ACCEPTED (amendment — ADR-015 decision body unchanged)
**Amends:** ADR-015 (length budget; stress-test evidence set)

### Context

v1.3.0 validated the 9-section template on two non-Study shapes (`voice-matching`, `status-update`) and one Study pilot (`flashcard-generation`). Per v1.3.0 precedent and spec §Technical Constraints ("Template stress-test is mandatory per v1.3.0 precedent"), v1.3.1 re-validates the template against the three Research-preset shapes before committing the Research pilot:

- `literature-review` — multi-source survey; matrix + thematic synthesis + gap analysis.
- `source-analysis` — single-source deep read; evaluation criteria (primary/secondary, methodology, bias, authority).
- `research-synthesis` (Research variant) — peer-review multi-source synthesis with citation-network awareness and research-gap as first-class output.

The spec also raises the soft length ceiling from 120 → 130 for Research-preset skills only. This amendment documents the raise and its rationale.

### Line-Ceiling Raise for Research Preset (80–130)

ADR-015's length budget remains the canonical target (80–120 lines for most presets; floor 60; soft cap 150). For the Research preset specifically, the target range is **80–130**.

- Research skills must carry academic-context qualifiers (peer-reviewed vs. preprint vs. grey literature), methodology-critique prose, and citation-network distinctions (foundational vs. derivative). These add ~5–10 lines to `## Instructions` and `## Quality criteria` relative to Study skills.
- The soft cap of 150 (CONTRIBUTING.md judgment-call trim advice) is unchanged.
- CI floor (60 lines) is unchanged.
- `skill-depth-check` does not enforce a ceiling, so no CI change is needed for the Research target-range raise. The 130 target is documentation-only guidance for @dev and community contributors.

### Research Preset Stress-Test (mandatory pre-Phase-2 re-validation)

Applied the 9-section template desk-check to all three Research skills. Per v1.3.0 precedent (A-v1.3-2), one skill receives a full section-by-section fit analysis; the other two receive a verdict with focused notes on any sections that required special consideration.

#### Skill 1 (full fit analysis) — `presets/research/.claude/skills/literature-review/SKILL.md`

Pilot for the Research preset. Exercises multi-source, thematic-grouping, gap-analysis shape.

| # | Section | Fits? | Note |
|---|---------|-------|------|
| 1 | When to use | Yes | "When you have multiple sources and need to understand what the field says collectively, identify themes, and find gaps." Direct carry from current stub; 2–3 sentences + edge case ("when gap analysis is the primary deliverable, not per-source summary"). |
| 2 | Triggers | Yes | Bullets: "User says 'literature review'"; "User supplies ≥3 sources with a topic"; "User mentions 'survey the field' / 'state of the field'"; "User asks what is contested vs. settled." 4–8 bullets target met. |
| 3 | Instructions | Yes | Numbered steps map cleanly: (1) confirm scope/research question; (2) read all sources; (3) identify themes by argument type (NOT chronology, NOT by-paper); (4) classify each theme's evidence quality (peer-reviewed consensus vs. contested vs. grey-literature only); (5) identify gaps; (6) assemble 4-section output. 6 steps — within 5–10 range. |
| 4 | Output format | Yes | Schema: `(1) Scope/question; (2) Themes — one H3 per theme with evidence quality; (3) Gaps — named research gaps; (4) Suggested next sources.` Author-year citations throughout. Strong fit — the template's `Output format` section accommodates fixed multi-section academic outputs. |
| 5 | Quality criteria | Yes | "Themes named by argument type, not by paper"; "At least one gap identified that no source addresses"; "Evidence-quality label on each theme (consensus / contested / grey-literature-only)"; "Conflicting claims preserved as disagreement, not silently resolved"; "Author-year citations present for every claim." 5 checkable criteria — within 3–5. |
| 6 | Anti-patterns | Yes | "Chronological ordering instead of thematic"; "One paragraph per paper instead of per theme"; "Silently reconciling contradictory findings"; "Omitting gap analysis"; "Treating preprints identically to peer-reviewed sources." 5 items, one line each — matches target. |
| 7 | Example | Yes | ONE worked example: input = 4 papers on a topic (title + abstract excerpts); output = 4-section review with themes, gaps, next-source suggestions. Real academic example, not hypothetical. Estimated 20–30 lines — within 15–40 range. |
| 8 | Writing-profile integration | Yes | 1–3 sentences: "Literature reviews typically exceed 100 words, so consult `context/writing-profile.md` for register and tone — especially for the Introduction and Gap Analysis sections, which carry the reviewer's voice. Theme summaries should stay neutral and source-anchored regardless of voice profile." |
| 9 | Example prompts | Yes | 3 bullets. Existing three prompts from the stub map directly; realistic user invocations. |

**Verdict — `literature-review`: VALIDATED.** Template fits without contortion. No template revision required.

#### Skill 2 — `presets/research/.claude/skills/source-analysis/SKILL.md`

Single-source deep read — exercises a *different output shape* from `literature-review` (flat evaluation vs. multi-theme aggregation).

| Section | Fit verdict | Key note |
|---------|-------------|----------|
| When to use | Fits | Single-source focus; edge case: user supplies multiple sources but wants per-source deep evaluation (route to repeated `source-analysis`, not `literature-review`). |
| Triggers | Fits | "User asks 'evaluate this paper'"; "User supplies one source and asks is-it-credible"; "User asks about methodology/bias of a single source." |
| Instructions | Fits | 6–8 steps: identify source type (primary/secondary/tertiary) → check peer-review status → check citation network position → assess methodology → flag bias → note recency/authority → synthesize evaluation. |
| Output format | Fits (strong) | Fixed-schema evaluation card: `(1) Source metadata; (2) Type + peer-review status; (3) Citation network position; (4) Methodology assessment; (5) Bias notes; (6) Recency/authority; (7) Bottom line.` Template's `Output format` handles fixed schemas cleanly (confirmed by v1.3.0 `status-update` stress test). |
| Quality criteria | Fits | "Peer-review status explicitly stated"; "Methodology assessment cites the actual method used, not vibes"; "Bias source named (funding, affiliation, selection) or 'none found'"; "Citation-network position (foundational/derivative/isolated) labelled." |
| Anti-patterns | Fits | "Credibility yes/no without evidence"; "Appeal-to-authority on prestigious venue"; "Ignoring preprint status"; "Missing methodology critique on empirical claims." |
| Example | Fits | ONE worked source analysis (one real academic paper → one evaluation card). |
| Writing-profile integration | Fits | Source-analysis outputs are typically <200 words — evaluation cards are terse. Writing-profile applies selectively for the "Bottom line" narrative clause only. Section should state this explicitly. |
| Example prompts | Fits | 3 realistic invocations. |

**Verdict — `source-analysis`: VALIDATED.** No section is a stretch. The fixed-schema `Output format` section absorbs what would otherwise be prose in the 16-line stub.

#### Skill 3 — `presets/research/.claude/skills/research-synthesis/SKILL.md` (Research variant)

Peer-review multi-source synthesis — exercises *distinct content from the Study variant of the same skill slug*. Template-shape question: does the 9-section template accommodate the Research-variant's required additions (peer-review status per source, citation network awareness, research-gap as first-class section, academic citation format defaults) without structural changes?

| Section | Fit verdict | Key note |
|---------|-------------|----------|
| When to use | Fits | Multi-source synthesis for academic/professional research. Edge case: when sources span incompatible paradigms, synthesis flags paradigm differences rather than averaging. |
| Triggers | Fits | "User says 'synthesize these papers'"; "User shares ≥2 peer-reviewed sources"; "User asks 'what does the literature say about [X]' with specific sources at hand." |
| Instructions | Fits | 7–9 steps: label each source (peer-reviewed / preprint / grey); assess citation-network position per source; extract claims; flag methodology incompatibilities; identify consensus; identify research gaps; produce citation-formatted output. Fits within 5–10 numbered-step range. |
| Output format | Fits | Schema includes a **dedicated `Research gaps` section** (not an afterthought). Peer-review status appears as a column in the comparison matrix. Academic citation format (APA/MLA/Chicago) rather than GitHub-flavored markdown tables. Template absorbs this cleanly — `Output format` section is flexible on schema shape. |
| Quality criteria | Fits | Minimum per spec AC: "peer-review status per source," "methodology differences surfaced," "research gaps as distinct output section." Plus: "citation-network position noted per source," "claim→source attribution ≥1:1." |
| Anti-patterns | Fits (must diverge from Study variant per AC) | "Treating preprints identically to peer-reviewed studies"; "Ignoring citation network"; "Omitting research-gap section"; "Averaging effect sizes across incompatible study designs"; "Silently reconciling contested findings." All distinct from Study variant's anti-patterns. |
| Example | Fits | ONE worked example using real peer-reviewed academic sources (NOT the Study variant's cognitive-psychology working-memory example). |
| Writing-profile integration | Fits | Synthesis outputs typically exceed 200 words; writing-profile applies to narrative synthesis paragraphs. Reference matrix/tables remain neutral regardless of voice profile. |
| Example prompts | Fits | 3 academic-context invocations. |

**Verdict — `research-synthesis` (Research variant): VALIDATED.** Template accommodates all Research-specific requirements without structural additions. The dedicated research-gap output is expressed through `## Output format`, not via a new template section. Peer-review status enters as both a `## Output format` schema field and a `## Quality criteria` bullet — no new template section required.

#### Stress-Test Overall Result

**A-v1.3-2 re-validation on Research preset: VALIDATED.** All three Research skills fit the 9-section template without requiring section additions, removals, or reordering. The 80–130 line target (vs. Study's 80–120) is documentation guidance only — CI behaviour is unchanged. No revisions to ADR-015's template specification are required before the Research pilot (B1) commits.

---

## ADR-016 Amendment (v1.3.1): `ENFORCED_PRESETS` → `"study research"` + Word-Split-Loop Verification

**Date:** 2026-04-18
**Status:** ACCEPTED (amendment — ADR-016 decision body unchanged)
**Amends:** ADR-016 (rollout-plan row v1.3.1 was pre-declared; this amendment closes the execution commitment and verifies the loop logic)

### Decision

Update `ENFORCED_PRESETS` from `"study"` to `"study research"` in both the enforcement block (`skill-depth-check` step) and the advisory-notice block (unenforced-presets advisory step) of `.github/workflows/quality.yml`. Both string literals must match; drift is disallowed.

### Word-Split-Loop Verification (spec requirement — E4)

The existing CI logic is:

```bash
ENFORCED_PRESETS="study"
for preset in $ENFORCED_PRESETS; do
  skill_base="presets/${preset}/.claude/skills"
  ...
done
```

and in the advisory block:

```bash
for preset_dir in presets/*/; do
  preset=$(basename "$preset_dir")
  if ! echo "$ENFORCED_PRESETS" | grep -qw "$preset"; then
    UNENFORCED_PRESETS="$UNENFORCED_PRESETS $preset"
  fi
done
```

**Analysis:**

1. **Unquoted `$ENFORCED_PRESETS` expansion in `for preset in $ENFORCED_PRESETS`:** Standard POSIX-shell word-splitting on IFS (default = space/tab/newline). With `ENFORCED_PRESETS="study research"`, the loop iterates twice: `preset=study`, then `preset=research`. Verified behaviour; no shell code change required.
2. **`grep -qw "$preset"` in the advisory block:** `-w` matches `$preset` as a whole word against the entire `$ENFORCED_PRESETS` string. `grep -qw "study" <<<"study research"` → match. `grep -qw "research" <<<"study research"` → match. `grep -qw "creative" <<<"study research"` → no match (correctly continues to advisory). Verified.
3. **No glob expansion risk (spec E4):** `presets/$preset/.claude/skills/*/SKILL.md` expansion uses `$preset` as a literal directory name; `*` only expands inside `.claude/skills/`. `$preset` values (`study`, `research`) contain no glob metacharacters. Safe.
4. **Two-literals invariant:** Both the enforcement-block and advisory-block assignments must read `ENFORCED_PRESETS="study research"`. If only one is updated, non-Research presets will still receive the advisory notice correctly but the enforcement loop will silently skip Research. This is why spec AC explicitly requires both blocks updated.

**Verification verdict:** No CI shell-logic change required beyond the two string-literal edits. `@dev` MUST edit both occurrences of `ENFORCED_PRESETS="study"` in the same commit.

### Rollout-Plan Table Row (now authoritative for v1.3.1)

ADR-016's rollout table already anticipated v1.3.1:

| Release | `ENFORCED_PRESETS` | Change |
|---------|--------------------|--------|
| v1.3.0 | `"study"` | (initial) |
| **v1.3.1** | `"study research"` | **1-line edit × 2 blocks + 3 new deep skills** |

Amendment locks v1.3.1 as executed per plan.

---

## ADR-018: Preset Isolation for Skill-Slug Collisions (Research-Synthesis Dual-File Disposition)

**Date:** 2026-04-18
**Status:** ACCEPTED

### Context

`presets/study/.claude/skills/research-synthesis/SKILL.md` (shipped v1.3.0) and `presets/research/.claude/skills/research-synthesis/SKILL.md` (to land v1.3.1 B3) share a folder name and file name but live under different preset paths. The @pm spec (v1.3.1 §Technical Constraints) flags this as an open architectural question: is the dual-naming a coupling or dependency concern worth a new ADR, or a documented non-issue under existing repo-structure policy?

This ADR provides the one-sentence disposition (spec's requested outcome) and escalates it to a preset-level naming principle so future slug-collisions across presets have a named policy.

### Decision

**Dual-file skill-slug collision across different presets is a documented non-issue under the preset-isolation model.** Files are independent by repo path, CI path, registry entry, and user-installation boundary. No shared import, no runtime dependency, no file coupling.

### Evidence for Non-Issue Disposition

Four independent isolation boundaries already enforce separation:

1. **Filesystem / repo path (ADR-004):** `presets/study/.claude/skills/research-synthesis/SKILL.md` and `presets/research/.claude/skills/research-synthesis/SKILL.md` are distinct paths. No symlinks, no shared content files. Flat preset structure is canonical.
2. **CI scoping (ADR-016):** `skill-depth-check` iterates `presets/$preset/.claude/skills/*/SKILL.md` per enforced preset — each file is checked in isolation against its own preset-path loop iteration.
3. **Curated registry (ADR-012):** `curated-skills-registry.md` treats each preset's skills as independent entries. Two rows with `name=research-synthesis` are permitted when `preset` column differs. Registry cardinality CI (`registry-cardinality-check`) counts rows, not name-uniqueness.
4. **User installation boundary:** A user adopts one preset at a time. The skill slug `/research-synthesis` resolves against the installed preset's `.claude/skills/` — there is no concurrent-preset installation that would require disambiguation. Cowork's skill discovery is scoped to the installed workspace.

### Content-Divergence Requirement (preserved via spec AC, not ADR)

Spec B3 AC already requires content divergence ("file content is NOT a copy of `presets/study/.claude/skills/research-synthesis/SKILL.md` — a diff between the two files must show Research-specific content"). This ADR does NOT duplicate that requirement; content divergence is the author's responsibility and is verified by @qa in Phase 5 (E3 edge case) and by the PR review checklist. ADR-018's scope is the structural (path/CI/registry) isolation, not the content diff.

### Naming Principle (generalized policy)

**A skill slug MAY be reused across different presets when the two skills serve genuinely different user needs.** Preset-level isolation is sufficient; a shared slug across presets creates no technical coupling. Community contributors proposing a cross-preset slug reuse must:

- Include a one-paragraph rationale in the PR description explaining why the two skills share a slug.
- Confirm content divergence (per the B3-style diff requirement applied to their PR).

CONTRIBUTING.md does NOT require a change for v1.3.1 — this principle is inherited from ADR-004's flat-preset isolation and ADR-012's per-preset registry model. If a future retrospective surfaces contributor confusion around skill-slug collision, revisit whether CONTRIBUTING.md needs an explicit paragraph.

### Consequences

- No repo-structure change. No CI change. No registry-schema change.
- `research-synthesis` dual-file shipping in v1.3.1 is documented as policy-compliant.
- Future presets may reuse any skill slug from a prior preset when justified by divergent user need.
- `@qa` Phase 5 MUST still verify content divergence per spec AC B3 and edge case E3; this ADR does not override that verification.

### Consequences NOT in scope for this ADR

- Whether to add a "skill slug uniqueness across presets" CI check — rejected as over-engineering. Slug collision is not a failure mode given preset isolation.
- Whether to rename one of the two files — rejected. Slugs match user-facing invocation phrasing (`/research-synthesis`); renaming for technical convenience would degrade UX.

---

## v1.3.1 Supporting Specs (H-items)

### H1 — CLAUDE.md Trim (≤350 words) — architectural impact

H1 is a mechanical content trim with NO architectural change. No ADR required.

- **Scope:** CLAUDE.md only (385 → ≤350 words). No touch to any `presets/*/project-instructions-starter.txt`, `presets/*/global-instructions.md`, `presets/*/context/writing-profile.md`, or `templates/` files.
- **Blast-radius guard:** CLAUDE.md is the universal dynamic-wizard entry point (ADR-010). ADR-011 specifies the wizard state machine. No state-machine step, branch, or word-budget allocation may be structurally removed by H1. Permitted changes are wordsmithing within existing steps only (condensing verbose conditional prose — spec identifies Phase 2–4 wizard state-machine section as highest-yield).
- **Invariant to preserve:** All wizard branch logic (goal discovery, suggestion branch, writing profile questions, fast-track, safety rule, state machine check) must remain after trim. @qa verifies at Phase 5 via a before/after wizard-logic-preservation check.
- **CI:** `claude-md-word-count-check` must pass at ≤350 (not merely at the ≤400 hard cap). Spec AC H1-4 and E5 reinforce this.

### H2 — B10 Interview Pattern Documentation — architectural impact

H2 is a process-documentation addition to CONTRIBUTING.md. No ADR required; ADR-017's user-input-schema decision is not modified.

- **Location:** CONTRIBUTING.md, new `## Skill authoring — B10 interview pattern` heading, positioned after `## Skill content safety` (line ~72 anchor) and before `## Running CI checks locally` (line ~92 anchor). CONTRIBUTING.md currently ordered: Placeholder authoring rules (line 78) → Running CI checks locally (line 92). Verified anchors.
- **Rule (authoritative phrasing):** "First skill in a preset = full 6-Q open session (user controls every dimension). Skills 2+ in the same preset = orchestrator proposes defaults based on the first skill's established patterns, then user expands any Q they want."
- **Evidence reference:** v1.3.0 `research-synthesis` — one clarifying round needed vs. `flashcard-generation` full 6-Q session. Retro Section 2 Hardest AC.
- **Out of scope:** This is NOT a per-PR checklist item. Does NOT modify the 17-item maintainer PR reviewer checklist. Spec AC H2-5 explicitly forbids adding a per-PR check.

### H3 — Push-or-PR Cycle Checklist — architectural impact

H3 is a new process section in CONTRIBUTING.md. No ADR required; existing pipeline-policy (The-Council) already documents the merge rule. H3 brings the project-local workflow into alignment.

- **Location:** CONTRIBUTING.md, new `## Release cycle checklist` heading, positioned after `## Version management` (line ~135) and before `## Developer Certificate of Origin` (line ~141).
- **Mandatory item (authoritative phrasing):** "After Phase 7 approval — push branch, open PR, wait for all CI checks to pass, then merge. Direct push to `main` is blocked by branch protection."
- **Rationale reference:** v1.3.0 retro Section 4 (Phase 5 ~8h elapsed due to local-commits-lingering gap).
- **Out of scope:** Does NOT add a new per-PR reviewer check. Spec AC H3-5 explicitly forbids adding to the 17-item maintainer PR checklist.

---

## v1.3.1 Dependency Graph for Phase 4 (@dev commit sequencing)

Authoritative commit order for @dev implementation. Respects spec hard-sequencing constraints, pilot-first rule, CI-red-avoidance, and blast-radius ordering.

### Commit Sequence

```
1. H1 — CLAUDE.md trim (≤350 words). Verify via `wc -w CLAUDE.md`. CI claude-md-word-count-check passes.
2. H2 — CONTRIBUTING.md § "Skill authoring — B10 interview pattern" (inserted after § Skill content safety).
3. H3 — CONTRIBUTING.md § "Release cycle checklist" (inserted after § Version management).
   [H1+H2+H3 MAY ship as a single commit per spec — "single commit for all 3 hygiene items is acceptable."]
   [USER REVIEW CHECKPOINT after hygiene commit, optional — user may choose to review before B-items begin.]

4. B1 — `presets/research/.claude/skills/literature-review/SKILL.md` rewrite + corresponding input-session file at
   `.claude/projects/claude-cowork-config/cycles/v1.3.1/skill-inputs/literature-review.md` (pipeline state path, NOT product-repo commit).
   Full 6-Q B10 open session per ADR-017.
   [USER REVIEW CHECKPOINT — MANDATORY per spec B1 AC: "literature-review is approved before source-analysis authoring begins (pilot-first order, same as v1.3.0)." DO NOT PROCEED TO B2 WITHOUT USER APPROVAL.]

5. B2 — `presets/research/.claude/skills/source-analysis/SKILL.md` rewrite + input-session file. B10 "defaults + clarify" pattern (H2 rule).

6. B3 — `presets/research/.claude/skills/research-synthesis/SKILL.md` rewrite (Research variant) + input-session file. B10 "defaults + clarify" pattern. Pre-commit diff vs. Study variant MUST show Research-specific content (peer-review status, citation network, research-gap section) — edge case E3.

   [USER REVIEW CHECKPOINT after all 3 skills authored — optional; confirms no skill copied Study content.]

7. B4 — `.github/workflows/quality.yml`: update BOTH occurrences of `ENFORCED_PRESETS="study"` → `ENFORCED_PRESETS="study research"` + update CI job comment per ADR-016 amendment. Lands AFTER B1+B2+B3 so CI passes on first run of the widened allowlist (avoids red-CI mid-cycle).

8. B5 — `presets/research/skills-as-prompts.md` regeneration from the 3 new deep SKILL.md sources. Non-Research `skills-as-prompts.md` files untouched.

9. B6 — `curated-skills-registry.md` review: update any Research rows whose `description` field changed during B1/B2/B3. Non-Research rows untouched. Verify `registry-cardinality-check` still passes (≥18 entries).

10. B7 — `VERSION` → `1.3.1`, `CHANGELOG.md` `[1.3.1]` block under `[Unreleased]`. README version reference updated if present. Tag `v1.3.1` + GitHub Release after Phase 7 approval per H3 cycle checklist.
```

### Sequencing Rationale (by constraint)

| Constraint | How this sequence satisfies it |
|------------|-------------------------------|
| Spec: "H-items complete before any B-item work begins" | H1, H2, H3 are steps 1–3 (or a single combined hygiene commit); B1 is step 4. |
| Spec: `literature-review` approved before `source-analysis` begins | Step 4 pilot checkpoint is mandatory; step 5 blocked on user approval. |
| Spec: "All 3 Research skills approved before B4 CI expansion" | B4 is step 7, after B1+B2+B3 at steps 4–6. Avoids red-CI: if B4 landed at step 4 before any skill rewrite, `skill-depth-check` would fail on the unmodified stub skills immediately. |
| Spec: "B5 after all 3 skills approved; B6 after B5" | Steps 8 and 9 in order. |
| CI-red-avoidance (blast-radius ordering) | B4 (CI allowlist) lands AFTER the 3 skills pass 60-line floor. Zero red-CI window during the cycle. |
| Hygiene blast-radius (H-items first) | H1 touches CLAUDE.md — wizard entry point. If H1 accidentally broke wizard state-machine logic, catching it at step 1 (before 3+ commits of B-item work) minimizes unwinding cost. |
| Pilot-first rule (B1 before B2/B3) | Explicit mandatory checkpoint after step 4. Non-negotiable per spec AC. |

### Pre-Commit Gates (@dev self-check before each commit)

- **Before B1 commit:** verify `literature-review/SKILL.md` has all 9 section headers, line count in 80–130, input file exists at `.claude/projects/claude-cowork-config/cycles/v1.3.1/skill-inputs/literature-review.md` (pipeline path, NOT in product-repo commit — `.gitignore` pattern `cycles/v1.3.*/` covers this per v1.3.0 Phase 4).
- **Before B3 commit:** run `diff presets/study/.claude/skills/research-synthesis/SKILL.md presets/research/.claude/skills/research-synthesis/SKILL.md`. If >60% of `## Quality criteria` OR `## Anti-patterns` items are identical, STOP and flag to orchestrator (edge case E3).
- **Before B4 commit:** `grep -c 'ENFORCED_PRESETS="study research"' .github/workflows/quality.yml` must equal 2 (one in enforcement block, one in advisory block).

---

## v1.3.1 Anti-Pattern Scan

Applied per `.claude/skills/architect/A1-architect-framework.md` to v1.3.1 additions (H1, H2, H3, B1–B7 and the ADR-015/ADR-016 amendments + ADR-018).

| # | Anti-Pattern | Applies to v1.3.1? | Notes |
|---|-------------|--------------------|-------|
| 1 | God Class/Module | No | CLAUDE.md trim reduces size; does not add responsibilities. CONTRIBUTING.md additions are scoped subsections. Template unchanged. |
| 2 | Circular Dependencies | No | Same one-directional chain as v1.3.0: template → CI → skill files → skills-as-prompts → registry. v1.3.1 widens the CI allowlist only; no new edges. |
| 3 | Leaky Abstraction | No | ADR-018 explicitly closes a potential leak: preset isolation is the authoritative boundary; no skill slug "leaks" across presets into shared state. |
| 4 | Premature Optimization | No | Line-ceiling raise (120 → 130) is reactive (Research skills need qualifier prose), not speculative. |
| 5 | Over-Engineering | No | Three ADRs are minimal: two amendments + one new. No new CI job, no new file formats, no new tools. H2/H3 are documentation-only; no machine enforcement (correctly — spec explicitly forbids adding per-PR checks). |
| 6 | Tight Coupling | Watched (carry-forward from v1.3.0 flag #6) | `## Triggers` ↔ `global-instructions.md` coupling unchanged by v1.3.1. Research preset's `global-instructions.md` already ships from v1.1; Research skill `## Triggers` sections must stay consistent. @qa Phase 5 spot-check recommended but not CI-enforced. |
| 7 | Missing Separation of Concerns | No | H1 (content trim) / H2, H3 (process docs) / B1–B3 (skill content) / B4 (CI) / B5, B6 (generated artifacts) / B7 (release metadata) — seven clean concerns, seven clear ownership boundaries in the commit sequence. |
| 8 | N+1 Query Pattern | No | No queries. |
| 9 | Destructive Migration | No | Three Research skill stubs (16-line) are replaced with deep skills. Old stubs remain in git history. No data loss. Study preset's `research-synthesis/SKILL.md` is NOT touched by v1.3.1 (ADR-018 isolation). |

**Coupling carry-forward (#6):** Unchanged from v1.3.0 — acceptable trade-off with @qa Phase 5 spot-check. If Research-preset `global-instructions.md` drifts from the new `literature-review` / `source-analysis` / `research-synthesis` `## Triggers` sections, promote to a CI job in v1.3.2 retrospective.

**Duplication check (research-synthesis dual-file):** Not duplication; documented as ADR-018 preset-isolation non-issue with content-divergence verification at AC B3 + E3 + @qa Phase 5. Zero code/content duplication shipped.

**Speculative abstraction check:** None. Line-ceiling raise is evidence-driven (Research stress-test showed skills land 5–10 lines longer). No new file formats, no new template sections, no new CI primitives.

No blocking anti-patterns detected for v1.3.1.

---

## v1.3.1 Open Issues for Phase 2 (@security)

1. **CLAUDE.md trim — wizard state-machine preservation:** H1 trims 35 words. @security to confirm no wizard branch logic is structurally removed (only wordsmithing). Scan focus: Phase 2–4 state machine section + safety-rule verbatim preservation.
2. **`ENFORCED_PRESETS="study research"` shell-injection surface:** The string is a hard-coded literal in a CI YAML file. No user input flows into `ENFORCED_PRESETS`. Still, @security to confirm no future-regression path where the variable could be populated from a PR-supplied source (e.g., if someone proposes `${{ github.event.pull_request.title }}`-style injection). Should never happen; confirm defensive posture.
3. **Research skill `## Triggers` ↔ `global-instructions.md` alignment:** Research preset's `global-instructions.md` was authored in v1.1 against 16-line stubs. Now that the 3 skills will have rich `## Triggers` sections + optional `trigger_examples` YAML, @security to check whether any skill's trigger surface exceeds what `global-instructions.md` rules can match, creating a passive-skill scenario where users don't discover the skill despite its presence. This is an instruction-surface robustness check, not a security vulnerability per se.
4. **Input-file path containment (carry-forward):** `.claude/projects/claude-cowork-config/cycles/v1.3.1/skill-inputs/` must remain outside the product repo. `.gitignore` pattern `cycles/v1.3.*/` (shipped v1.3.0 Phase 4) already covers v1.3.1. @security to re-confirm pattern still matches on re-test.
5. **ADR-018 skill-slug collision policy — enforcement surface:** The policy permits future cross-preset slug reuse. @security to evaluate whether the absence of a uniqueness CI check creates any unexpected attack surface (e.g., a typosquat-adjacent scenario where two presets both offer `/delete-all-files` with different behaviours). Expected finding: non-issue given preset isolation, but worth an explicit Phase 2 pass.
