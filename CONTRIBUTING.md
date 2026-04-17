# Contributing

Thank you for contributing to Claude Cowork Config. This guide explains how to add a new preset.

---

## Adding a new preset

All contributions start from the template. Do not create a preset folder from scratch.

1. Copy `templates/preset-template/` to `presets/<your-preset-name>/`
2. Use a lowercase, hyphenated slug for the folder name (e.g. `legal`, `data-science`, `teaching`)
3. Fill in every file — no placeholders left blank
4. Run the CI checks locally before opening a PR (see below)
5. Open a pull request with the title `feat: add <preset-name> preset`

---

## PR review checklist for maintainers

Before merging a new preset PR, verify all 11 items:

- [ ] **`project-instructions-starter.txt` present** — file exists at `presets/<name>/project-instructions-starter.txt`
- [ ] **Starter file is ≤350 words** — run `wc -w presets/<name>/project-instructions-starter.txt` to confirm (raised from ≤300 in v1.2 for dynamic wizard branching)
- [ ] **Safety rule present verbatim in starter file** — must contain: "Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder."
- [ ] **All skills in `folder/SKILL.md` format** — no flat `.md` skill files at `presets/<name>/.claude/skills/` root; each skill is a folder with `SKILL.md` containing valid YAML frontmatter (`name:` and `description:` fields)
- [ ] **Minimum file count met** — at least 3 skills in `.claude/skills/`, at least 2 context files in `context/`, at least 1 `folder-structure.md`, at least 1 `connector-checklist.md`
- [ ] **"Try this now" prompts present** — `skills-as-prompts.md` includes at least one file-based and one file-agnostic example prompt
- [ ] **CI passes** — all GitHub Actions jobs pass: markdown lint, link check, shellcheck, safety-rule grep, starter-file-check, starter-safety-rule-check, skill-format-check, writing-profile-template-check
- [ ] **`writing-profile.md` present** — file exists at `presets/<name>/context/writing-profile.md` with non-placeholder content in Tone & Voice and Anti-AI Guidance sections; must not be blank or contain only `[bracketed placeholders]`
- [ ] **`curated-skills-registry.md` entry follows schema** — if the PR adds skills to `curated-skills-registry.md`, each entry must include: `name`, `description`, `source_url` (HTTPS only or `builtin`), `vetting_date` (ISO 8601), `tier` (1 or 2), `goal_tags`. PR description must include vetting evidence (source repo stars/health, last commit date, keyword scan result showing no flagged terms)
- [ ] **CLAUDE.md sync** — if the PR modifies the wizard flow in any `project-instructions-starter.txt`, `CLAUDE.md` must be updated to match (and vice versa). All 7 wizard surfaces (CLAUDE.md + 6 starter files) must stay in sync. PRs that touch one must touch all.
- [ ] **No `Sample:` or `Raw sample:` field** — `writing-profile.md` files must not store raw user writing samples; wizard instructions must extract patterns only
- [ ] **New/edited SKILL.md in depth-enforced preset contains all 9 sections** — `## When to use`, `## Triggers`, `## Instructions`, `## Output format`, `## Quality criteria`, `## Anti-patterns`, `## Example`, `## Writing-profile integration`, `## Example prompts` (per `templates/skill-template/SKILL.md`)
- [ ] **New SKILL.md has ≥ 60 lines** — run `wc -l presets/<preset>/.claude/skills/<skill>/SKILL.md` to confirm; the `skill-depth-check` CI job enforces this for depth-enforced presets
- [ ] **Frontmatter `trigger_examples` list has 3–6 entries if present** — the field is optional; if included it must have at least 3 and no more than 6 example phrases
- [ ] **Placeholder authoring rules followed** — see `##Placeholder authoring rules` section below
- [ ] **B10 skill-input file lives under the pipeline path** — if this PR proposes a new skill, any B10 skill-input file (session notes, Q&A responses) must live under `.claude/projects/<slug>/cycles/…` and NOT under any product repo path (presets/, docs/, templates/)
- [ ] **Prior retro carry-forwards reviewed** — per `docs/retro-template.md` §Carry-Forward Review; every item from the previous cycle's Section 8 must have an explicit disposition before this PR closes

---

## CLAUDE.md changes — high-impact notice

`CLAUDE.md` is auto-loaded as system context for any user who opens this repo folder in Cowork. It is a universal entry point — changes to it affect all users immediately, not just users of a specific preset.

**PRs that modify `CLAUDE.md` must:**

1. Also update all 6 `presets/*/project-instructions-starter.txt` files to match (wizard flow must stay in sync — ADR-010)
2. Include a clear explanation of what changed and why in the PR description
3. Be reviewed by a maintainer before merge — treat `CLAUDE.md` edits as security-relevant changes

Similarly: PRs that modify wizard flow in any starter file must also update `CLAUDE.md`.

---

## Registry entries — `curated-skills-registry.md`

When adding entries to `curated-skills-registry.md`:

- `source_url` must use HTTPS (not `http://`). Use `builtin` only for Anthropic official skills — do not claim `builtin` for community-sourced skills.
- **Pin to a specific commit SHA**, not a branch URL, to prevent URL rotation attacks:
  - Correct: `https://github.com/org/repo/blob/a1b2c3d4e5f6/path/SKILL.md`
  - Avoid: `https://github.com/org/repo/blob/main/path/SKILL.md`
- `vetting_date` is the date you personally tested the specific SHA above
- Include vetting evidence in your PR description: source repo stars, last commit date, keyword scan result

The Tier 2 community skill search list in `WIZARD.md` is maintained by repo maintainers. Do not submit PRs that add new repos to that list — open an issue to request additions.

---

## Skill content safety

Before submitting any skill content from external sources, scan it at [SkillRisk.org](https://skillrisk.org). Do not submit skill content that was not written by you or sourced from Anthropic's official materials.

---

## Placeholder authoring rules

When writing placeholder text in SKILL.md files (the bracketed `[...]` tokens contributors fill in), follow these five rules to avoid shipping unintended runtime instructions to Cowork:

1. **Placeholders are bracketed nouns, never imperatives.** Write `[action description]`, not `[Do X]` or `[Tell Cowork to…]`.
2. **Never include the words `Ignore`, `Disregard`, `Override`, `Instead`, or `Always` inside a placeholder.** These terms can leak as LLM instructions if a placeholder is left unfilled or partially filled.
3. **Use inline HTML comments for contributor guidance.** Intent and instructions for the contributor belong in `<!-- HTML comment -->` blocks, not in the visible placeholder text. HTML comments are invisible at Cowork runtime.
4. **No safety-rule pattern in placeholders.** Do not write placeholder text that could be read as a rule about confirming, deleting, or overwriting files — that surface is reserved for the canonical safety rule in `global-instructions.md`.
5. **Example section placeholders must read as contributor-guidance, not Cowork-instructions.** Placeholder text inside `## Example` must clearly signal that the contributor should paste a real input/output pair there — it must not read as an instruction Cowork would follow if left unfilled (e.g., use "Paste a real input/output here" not "Show an example").

These rules are enforced by review, not by CI. The `safety-rule-check` CI job does not parse placeholder content.

---

## Running CI checks locally

```bash
# Markdown lint
npx markdownlint-cli2 "**/*.md"

# ShellCheck (requires shellcheck installed)
shellcheck scripts/setup-folders.sh

# Safety rule grep — global-instructions.md
SAFETY_RULE="Always ask for explicit confirmation before deleting"
for f in presets/*/global-instructions.md; do
  if ! grep -q "$SAFETY_RULE" "$f"; then
    echo "MISSING safety rule: $f"
  fi
done

# Safety rule grep — starter files (.txt)
for f in presets/*/project-instructions-starter.txt; do
  if ! grep -q "$SAFETY_RULE" "$f"; then
    echo "MISSING safety rule: $f"
  fi
done

# Starter file existence check
for preset in study research writing project-management creative business-admin; do
  if [ ! -f "presets/$preset/project-instructions-starter.txt" ]; then
    echo "MISSING starter file: presets/$preset/project-instructions-starter.txt"
  fi
done

# Skill format check — no flat .md files at skills root
for skills_dir in presets/*/.claude/skills; do
  for f in "$skills_dir"/*.md; do
    if [ -f "$f" ]; then
      echo "FLAT SKILL FILE: $f (must be in folder/SKILL.md format)"
    fi
  done
done
```

---

## Version management

Do not modify the `VERSION` file or `CHANGELOG.md`. Maintainers handle versioning at release time. Your PR should contain only files in `presets/<your-preset-name>/`.

---

## Developer Certificate of Origin

All contributions must be signed off with `git commit -s` (Developer Certificate of Origin). By signing off, you certify that you wrote the contribution or have the right to submit it.

By submitting a PR, you agree that your contribution is licensed under MIT.

---

## Questions?

Open an issue and tag it `question`. We're happy to help.
