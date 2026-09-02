# Workspace CLAUDE.md Template (post-setup handover)

This is the template for the **workspace** `CLAUDE.md` that WIZARD.md Step 7 generates when setup completes. It REPLACES the kit's wizard-bootstrap `CLAUDE.md` in the user's workspace (with explicit confirmation — Safety rule). Fill every `[bracket]` from the interview answers; keep the generated file under 350 words; do not use em dashes (they inflate the CI word count under C.UTF-8).

**Mode-B-first wording (design-v2.19.18.md §C.4).** 7a runs before 7b decides whether `_setup-kit/` will ever exist — 7b is Mode-A-only and declinable — so 7a cannot know yet. The three lines below are therefore filled with the **no-archive** wording unconditionally, every time. If 7b later runs and the user says Yes, 7b's own final step rewrites these same three lines, in this already-written file, to the archive wording — a `created-this-run` edit that never re-prompts. On Mode B, or a declined 7b, these lines are simply correct as filled and are never touched again.

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
2. Write in the voice defined by `context/writing-profile.md`; format per `context/output-format.md` (default: [PRESET DEFAULT]; change anytime on request).
3. Skills live in `.claude/skills/` — apply each proactively per its Triggers section. Installed: [SKILL LIST].

## Proactive skill behavior

Apply installed skills proactively based on context; do not wait to be asked. Skill Studio adds an entry here automatically each time it generates and surfaces a new skill (see `.claude/skills/skill-studio/SKILL.md` step 7).

## Noticing friction

When a correction or ask repeats, note it in `context/memory-of-use.md` (create it if absent) per the `self-apply` skill (`.claude/skills/self-apply/SKILL.md`) — never interrupt just to announce it.

## Skill swap

If [NAME] asks for a capability outside the installed bundle, offer the closest match from the pool at `skills/` (25 skills; suggestions ≤3 at a time) and copy it into `.claude/skills/` on confirmation. The reviewed upstream agent library at `vendored/agency-agents/` is available to read and adapt offline. These personas are illustrative fiction, not licensed professionals; verify any finance or legal guidance independently before acting on it. Never fetch skills from GitHub or external URLs.

## Re-run or extend setup

Type `/setup-wizard` anytime — the script is at `WIZARD.md` and detects this existing workspace (add/remove skills without resetting).

## Offline

Everything this workspace needs is local. No internet access is required; never treat missing network access as an error.

## Safety

Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder.
```
