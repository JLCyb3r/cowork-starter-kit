# cowork-starter-kit

> Set up your Claude Cowork workspace in 15 minutes. No code. No configuration files. Just answer 5 questions.

[![CI](https://github.com/JLCyb3r/cowork-starter-kit/actions/workflows/quality.yml/badge.svg)](https://github.com/JLCyb3r/cowork-starter-kit/actions/workflows/quality.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](CHANGELOG.md)

---

## The problem

Claude Cowork is powerful — but a blank project is intimidating. Most people never configure it properly, so they get generic answers instead of a workspace tuned for how they actually work.

This fixes that.

---

## How it works

Open this folder in Cowork. Say "Help me set up." Cowork reads the wizard, asks you 5 questions, and generates your personalized workspace files — custom instructions, context files, starter skills, and a step-by-step checklist. Takes about 15 minutes. No terminal required.

```
You                          Cowork
 |                              |
 |  "Help me set up"            |
 | ---------------------------> |
 |                              |  Reads WIZARD.md
 |                              |  Q1: What's your main goal?
 |  "Research"                  |
 | ---------------------------> |
 |                              |  Q2: How do you want answers?
 |  "Bullet points"             |
 | ---------------------------> |
 |                              |  Q3: Tell me about your work
 |  [your answer]               |
 | ---------------------------> |
 |                              |  Q4: Which tools do you use?
 |  "Google Drive, Gmail"       |
 | ---------------------------> |
 |                              |  Q5: Safety check
 |  [your answer]               |
 | ---------------------------> |
 |                              |  Generates your workspace:
 |                              |    project-instructions.txt
 |                              |    cowork-profile.md
 |                              |    context/ folder
 |                              |    connector-checklist.md
 |  "Done — follow checklist."  |
 | <--------------------------- |
```

---

## Quick start

1. **[Download ZIP](https://github.com/JLCyb3r/cowork-starter-kit/archive/refs/heads/main.zip)** — unzip anywhere on your computer
2. Open Claude Cowork → create a new Project → point it at the unzipped folder
3. Say: **"Help me set up my workspace"**

That's it. Cowork takes it from there.

> **No Cowork yet?** Use the manual path: open `SETUP-CHECKLIST.md` and follow every step by hand.

---

## Six goal presets

Pick the one that matches your work. The wizard auto-selects the right preset and personalizes it for you.

| Preset | Best for | What you get |
|--------|----------|--------------|
| **Study** | Students, exam prep, coursework | Research synthesis, note-taking, flashcard generation |
| **Research** | Academics, analysts, lit review | Literature review, source analysis, synthesis |
| **Writing** | Authors, bloggers, journalists | Voice matching, editing pass, outline generator |
| **Project Management** | PMs, team leads, ops | Status updates, meeting notes, risk assessment |
| **Creative** | Designers, storytellers, strategists | Ideation, creative brief, feedback synthesis |
| **Business/Admin** | Executives, assistants, owners | Email drafting, report summary, action items |

**Each preset includes:**

- `project-instructions.txt` — paste into Cowork Project Settings > Custom Instructions
- `context/about-me.md` — fill in your name, role, and goals
- `context/working-rules.md` — safe defaults (includes confirm-before-delete rule)
- `context/output-format.md` — pre-filled for your preset
- `connector-checklist.md` — which connectors to authorize and why
- `skills-as-prompts.md` — skill content as copy-paste prompts if skill upload is unavailable
- `folder-structure.md` — recommended folder layout for your workspace

---

## Safety first

Every preset includes a non-negotiable rule: **Cowork will always ask for your confirmation before deleting, moving, or overwriting any file or folder.** This rule is built into every workspace this wizard generates and is enforced by CI on every community contribution.

---

## Staying up to date

This repo uses [semantic versioning](https://github.com/JLCyb3r/cowork-starter-kit/releases). When a new version ships, check the [Releases](https://github.com/JLCyb3r/cowork-starter-kit/releases) tab. The CHANGELOG lists which presets changed. To update: download the new preset folder and replace only the template files. Your `cowork-profile.md` and `project-instructions.txt` are yours and are never overwritten.

---

## Contribute a preset

Want to add a preset for a use case not covered here? See CONTRIBUTING.md — the templates/preset-template/ folder gives you a ready-to-fill scaffold. All contributions require a DCO sign-off and pass CI automatically.

---

## Star this repo

If this saved you setup time, a star helps other Claude Cowork users find it.

---

## License

MIT — see LICENSE.
