# Folder Structure — Personal Assistant Preset

Your Cowork Project folder for the Personal Assistant preset. Create this at:

```
~/Documents/Claude/Projects/personal-assistant/
```

## Folder tree

```
personal-assistant/
|-- Calendar/     # Upcoming events, appointments, and schedule notes
|-- Finances/     # Pasted transaction summaries, budget notes, receipts
|-- Tasks/        # To-do lists, action items, and open commitments
|-- People/       # Notes on relationships, follow-ups owed and pending
|-- Documents/    # Reference documents, contracts, and important files
```

## Folder descriptions

**Calendar/**
Your schedule in plain text. Drop in exported calendar summaries, copy-paste event lists, or write out your week. Cowork reads this folder to surface deadlines and offer your daily briefing. No calendar connector required — paste your events here directly.

**Finances/**
Pasted transaction data, spending summaries, and financial notes. Drop in a month's worth of transactions from your bank's export view, or paste individual receipts. Cowork reads this for spend-awareness summaries. **Do not store credentials, account numbers, or full card numbers here.**

**Tasks/**
Open to-dos, personal project notes, and action items. Name files clearly: `Tasks/home-renovation-checklist.md`. Cowork can read this folder to surface overdue tasks at the start of each day.

**People/**
Notes on relationships and pending commitments. Track who you owe a response, who owes you something, and relationship context for important people in your life. Example: `People/dentist-follow-up.md`.

**Documents/**
Reference material: lease agreements, warranty documents, tax summaries, and other personal files you want Cowork to be able to read when you ask about them. Store by topic: `Documents/2025-lease.pdf`.

## Creating this structure

**Option A — Run the script (macOS):**

```bash
bash scripts/setup-folders.sh personal-assistant
```

**Option B — Run the script (Windows):**

```powershell
.\scripts\setup-folders.ps1 personal-assistant
```

**Option C — Create manually:**

Open Finder or File Explorer and create the folders listed above inside `~/Documents/Claude/Projects/personal-assistant/`.
