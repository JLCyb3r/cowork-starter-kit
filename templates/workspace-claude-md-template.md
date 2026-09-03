# Workspace CLAUDE.md Template (post-setup handover)

Template for the **workspace** `CLAUDE.md` WIZARD.md Step 7 generates at setup completion (explicit confirmation — Safety rule), replacing the kit's bootstrap `CLAUDE.md`. Fill every `[bracket]`; keep under 350 words; avoid em dashes (inflates the CI count under C.UTF-8).

**Reachability wording, not mode wording (§C.4; closes S10).** 7a can't know if 7b will run, so Skill-swap/Re-run-setup below check for the path rather than assert it — true whether the kit is unarchived here (Mode A) or never here (Mode B). 7b's final step, on Yes, rewrites those two lines to the confirmed path — `created-this-run`, no re-prompt.

---

```markdown
# [WORKSPACE NAME] — Cowork Workspace

Setup is complete. This file is your workspace's standing instructions.

## Who you're working with

- **Name:** [NAME]
- **Role / context:** [ROLE]
- **Goal:** [GOAL, verbatim from setup]
- **Deadlines to track:** [DEADLINES or "none yet"]

## Every session

1. Read `cowork-profile.md`. Greet [NAME] by name; surface any deadline within 7 days.
2. Write in the voice from `context/writing-profile.md`; format per `context/output-format.md` (default [PRESET DEFAULT]; change anytime).
3. Skills live in `.claude/skills/` — apply each proactively per its Triggers section. Installed: [SKILL LIST].

## Proactive skill behavior

Apply installed skills proactively; don't wait to be asked. Skill Studio adds an entry here automatically on generating a skill (`.claude/skills/skill-studio/SKILL.md` step 7).

## Noticing friction

When a correction or ask repeats, note it in `context/memory-of-use.md` (create if absent) per `self-apply` (`.claude/skills/self-apply/SKILL.md`) — never interrupt just to announce it.

## Skill swap

If [NAME] wants a capability outside the bundle, check `skills/` (25 skills) or `vendored/agency-agents/`; offer and copy into `.claude/skills/` on confirmation if found, else say so. Personas are illustrative fiction, not licensed professionals — verify finance/legal guidance independently. Never fetch skills from external URLs.

## Re-run or extend setup

Type `/setup-wizard` anytime to add/remove skills without resetting — the script is `WIZARD.md` if reachable here.

## Offline

Everything here is local; no internet is required, and missing network access is never an error.

## Safety

Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder.
```
