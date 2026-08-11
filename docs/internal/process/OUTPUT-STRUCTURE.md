# Output Structure — Claude Cowork Config

This document describes the files the wizard produces and where they should be placed in the user's Cowork workspace.

## Entry Routes

<!-- v2.19.9 (ADR-082/083): "Primary Entry Point" and the Layer 1a/1b ranking are corrected — Cowork
     attaches a connected folder as a browsable source, it does not inject CLAUDE.md as system
     context. Neither route below is crowned primary; see README.md's Quick Start for the two
     equally-valid routes this section describes. -->

**`CLAUDE.md`** at the repo root is the workspace's entry document for a connected folder. When the
user opens the `cowork-starter-kit` folder as a Cowork Project, Cowork attaches it as a browsable
source; the dynamic wizard reads `CLAUDE.md` and begins the setup interview whenever the model reads
or is directed to it — not guaranteed on the very first message.

**`project-instructions-starter.txt`** (per preset) is the paste route: pasted into Project Settings
> Custom Instructions, it is injected before intent classification, which is why it is used when a
user cannot open the repo folder directly (e.g. creates a fresh Cowork Project and wants
preset-flavored onboarding from message one).

After the onboarding interview (dynamic wizard flow defined in CLAUDE.md, deep interview continued via `/setup-wizard`), Cowork generates the remaining output files below.

## Generated Output

After completing the onboarding interview (triggered by `CLAUDE.md` being read, or via a pasted `project-instructions-starter.txt`, or explicit `/setup-wizard` invocation), the user's workspace should contain the following files:

```
<your-cowork-workspace>/
|
|-- cowork-profile.md                  # Your answers and selected goal preset (generated)
|-- writing-profile.md                 # Your writing voice calibration (generated, v1.2)
|-- project-instructions-starter.txt   # (present only if Layer 1b path was used)
|
|-- .claude/
|   |-- skills/
|       |-- <skill-name>/
|           |-- SKILL.md               # folder/SKILL.md format (auto-discovers as /<skill-name>)
|
|-- context/
|   |-- about-me.md                    # Fill in your details (template with prompts)
|   |-- working-rules.md               # Pre-filled rules for safe, consistent AI behavior
|   |-- output-format.md               # Pre-filled output preferences for your goal type
|   |-- writing-profile.md             # Goal-appropriate writing voice defaults (v1.2)
|
|-- <goal-specific-folders>/           # Folder structure for your preset
|   |-- (varies by preset — see your preset's folder-structure.md)
|
|-- connector-checklist.md             # Which Cowork connectors to enable and why
|-- SETUP-CHECKLIST.md                 # Manual fallback steps (paste-based path)
|-- skills-as-prompts.md               # Copy-paste fallback if skill upload unavailable
```

## File Descriptions

| File | Format | Source | User Action Required |
|------|--------|--------|---------------------|
| `CLAUDE.md` | Markdown | Shipped at repo root | Attached as a browsable source when the folder is opened as a Project; the wizard begins once the model reads it |
| `project-instructions-starter.txt` | Plain text | Pre-built per preset | Optional paste route: paste into Project Settings > Custom Instructions BEFORE any conversation |
| `cowork-profile.md` | Markdown | Generated from wizard answers | Review (read-only) |
| `writing-profile.md` | Markdown | Generated from writing-profile questions (v1.2) | Review, refine as your voice evolves |
| `.claude/skills/<name>/SKILL.md` | Markdown | Pre-built per preset | Upload as ZIP via Settings > Customize > Skills |
| `context/about-me.md` | Markdown | Template from preset | Fill in your details |
| `context/working-rules.md` | Markdown | Pre-filled from preset | Review, edit if needed |
| `context/output-format.md` | Markdown | Pre-filled from preset | Review, edit if needed |
| `context/writing-profile.md` | Markdown | Pre-filled per preset (v1.2) | Review, refine during writing-profile questions |
| `connector-checklist.md` | Markdown | Copied from preset | Work through checklist in Cowork UI |
| `skills-as-prompts.md` | Markdown | Copied from preset | Use as copy-paste fallback if skill ZIP upload fails |
| `SETUP-CHECKLIST.md` | Markdown | Copied from repo | Follow step by step |

## Important Notes

- `project-instructions-starter.txt` is plain text, not markdown. It is pasted into Cowork Project Settings > Custom Instructions — not opened as a project file.
- Every `project-instructions-starter.txt` includes the safety rule verbatim: "Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder." Do not remove this line.
- Skill files use `folder/SKILL.md` format (not flat `.md`). This is the Cowork-native format that enables auto-discovery as `/slash-commands` after ZIP upload.
- If skill upload is unavailable, `skills-as-prompts.md` in your preset folder provides all skill content as copy-paste prompt snippets.
- The state machine check in `project-instructions-starter.txt` uses the presence and content of `cowork-profile.md` to detect first vs. returning sessions. Do not delete `cowork-profile.md` after setup.
