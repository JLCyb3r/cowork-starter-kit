# Curated Skills Registry

Vetted skills for use with Claude Cowork. Community PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for schema requirements and vetting guidelines.

---

## Schema

Each entry includes:

| Field | Description |
|-------|-------------|
| `name` | Slug matching `name:` frontmatter in SKILL.md (e.g., `flashcard-generation`) |
| `description` | One sentence — what this skill does for the user |
| `source_url` | GitHub URL (HTTPS only) or `builtin` for Anthropic official |
| `vetting_date` | ISO 8601 date of last manual vetting review |
| `tier` | `1` = curated/official, `2` = community |
| `goal_tags` | Comma-separated preset slugs (study, research, writing, project-management, creative, business-admin) |

---

## Tier 1 — Curated Skills

### Study

| name | description | source_url | vetting_date | tier | goal_tags |
|------|-------------|------------|--------------|------|-----------|
| flashcard-generation | Generate Anki-ready flashcards from source material using spaced-repetition best practices (atomicity, cloze deletion, minimum information principle). | builtin | 2026-04-18 | 1 | study |
| note-taking | Convert reading material into organized, concise study notes using a hybrid framework auto-selected from source type (Cornell, Outline, Zettelkasten, or Lightweight bulleted). | builtin | 2026-04-18 | 1 | study,research |
| research-synthesis | Synthesize multiple sources into a structured literature-review matrix with cross-source synthesis paragraphs, auto-selecting mode from source count (1 = atomic note, 2 = compact matrix, ≥3 = full matrix). | builtin | 2026-04-18 | 1 | study,research |

### Research

| name | description | source_url | vetting_date | tier | goal_tags |
|------|-------------|------------|--------------|------|-----------|
| literature-review | Organize multiple sources into a thematic matrix with cross-source synthesis and gap analysis, stating detected theme and source counts at the top of the output. | builtin | 2026-04-18 | 1 | research |
| source-analysis | Evaluate a single source across 7 structured fields (source type, authority, methodology, evidence quality, limitations, bias, bottom line) with an explicit citation recommendation. | builtin | 2026-04-18 | 1 | research,study |
| research-synthesis | Synthesize sources at peer-review rigor using a 7-column matrix (claim, method, evidence, limitations, authority, recency, citation-network) with structured Agreements, Disagreements, Gaps, and Synthesis sections. | builtin | 2026-04-18 | 1 | research |
| citation-formatter | Formats references and citations in APA, MLA, Chicago, or Harvard style | builtin | 2026-04-17 | 1 | research,study,writing |

### Writing

| name | description | source_url | vetting_date | tier | goal_tags |
|------|-------------|------------|--------------|------|-----------|
| voice-matching | Analyzes writing samples to match tone, vocabulary, and sentence rhythm in new content | builtin | 2026-04-17 | 1 | writing,creative |
| outline-generator | Builds a detailed hierarchical outline for any content type from a brief description | builtin | 2026-04-17 | 1 | writing,creative |
| editing-pass | Performs structured editing at light (errors), medium (clarity), or heavy (restructure) depth | builtin | 2026-04-17 | 1 | writing,creative,research |

### Project Management

| name | description | source_url | vetting_date | tier | goal_tags |
|------|-------------|------------|--------------|------|-----------|
| status-update | Drafts clear, audience-calibrated project status updates from bullet points or notes | builtin | 2026-04-17 | 1 | project-management |
| meeting-notes | Converts meeting transcripts or bullet notes into structured summaries with action items | builtin | 2026-04-17 | 1 | project-management,business-admin |
| risk-assessment | Identifies project risks, rates likelihood and impact, and proposes mitigations | builtin | 2026-04-17 | 1 | project-management |

### Creative

| name | description | source_url | vetting_date | tier | goal_tags |
|------|-------------|------------|--------------|------|-----------|
| ideation-partner | Generates diverse creative directions, builds on half-formed ideas, and breaks creative blocks | builtin | 2026-04-17 | 1 | creative |
| creative-brief | Structures a vague creative concept into a clear brief with goals, constraints, and success criteria | builtin | 2026-04-17 | 1 | creative,project-management |
| feedback-synthesizer | Consolidates feedback from multiple sources into actionable themes and prioritized revisions | builtin | 2026-04-17 | 1 | creative,writing,project-management |

### Business/Admin

| name | description | source_url | vetting_date | tier | goal_tags |
|------|-------------|------------|--------------|------|-----------|
| email-drafter | Drafts professional emails matched to audience, tone, and intent from short bullet notes | builtin | 2026-04-17 | 1 | business-admin |
| doc-summary | Summarizes long documents, reports, or proposals into executive-ready highlights | builtin | 2026-04-17 | 1 | business-admin,research,project-management |
| action-items | Extracts clear, assigned, deadline-tagged action items from meeting notes or email threads | builtin | 2026-04-17 | 1 | business-admin,project-management |

---

## Tier 2 — Community Skills

Community skills are shown only after explicit user opt-in. They are not verified by repo maintainers. Review each skill's SKILL.md carefully before installing.

> To add a Tier 2 entry: open a PR with your skill entry following the schema above. Include vetting evidence (source repo stars, last commit date, keyword scan result). See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process.

*(No Tier 2 entries at v1.2 launch — community contributions welcome via PR.)*

---

## Adding a Registry Entry

1. Fork the repo and add your entry to the appropriate section in this file
2. `source_url` must be `https://` (HTTPS only) — `http://` URLs are not accepted
3. For GitHub entries: pin `source_url` to a specific commit SHA, not a branch URL
   - Example: `https://github.com/org/repo/blob/a1b2c3d4e5f6/SKILL.md`
4. `vetting_date` is the date you personally tested the skill in a live Cowork session
5. Include a brief vetting summary in your PR description (stars, last commit, keyword scan result)
6. Open a PR with title `feat: add <skill-name> to curated-skills-registry`

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full PR checklist.
