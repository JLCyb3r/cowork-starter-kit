# Personal Assistant Preset

For busy individuals managing the demands of everyday life — calendar, finances, tasks, relationships, and documents. This preset configures Cowork to help you stay on top of your personal commitments, track what you owe and what others owe you, and surface your day clearly each morning — without ever sending your sensitive personal data anywhere.

---

## Who this is for

People juggling multiple personal responsibilities: family logistics, personal finances, health appointments, social commitments, and a growing inbox. Particularly useful for anyone who wants a calm, organized start to the day and a single place to catch up on what needs attention — without needing to manage a complex productivity system.

---

## What this preset configures

- **Custom instructions:** Warm but concise tone, proactive daily briefing, follow-up tracking, spend awareness — all local-only
- **Skills:** Daily Briefing, Follow-Up Tracker, Spend Awareness
- **Folder structure:** Calendar/, Finances/, Tasks/, People/, Documents/
- **Data Locality Rule:** Sensitive personal data (finances, calendar details, contacts, health, addresses, credentials) stays in local files only — no external service calls for sensitive data

---

## How to use this preset

1. Run the setup wizard (open the cowork-starter-kit folder in Cowork — the wizard runs automatically)
2. Describe your goal as "personal assistant", "daily planning", "life management", or similar
3. Answer the setup questions to calibrate your voice and daily routine
4. Follow SETUP-CHECKLIST.md to complete configuration

---

## Finance: paste-only

This preset is designed for personal financial awareness — pasting bank statements, receipts, or transaction lists for local review. Do NOT authorize banking or financial connectors (Plaid, Yodlee, or similar). See `connector-checklist.md` for the full policy and the reasoning behind it.

---

## First session prompts to try

- "Good morning — what does my day look like? Check my Calendar/ folder."
- "I just got off a call with [name]. They said they'd send the contract by Friday. Track that follow-up."
- "Here are last month's transactions: [paste]. Give me a plain-language summary of where the money went."
