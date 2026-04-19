# Skills as Prompts — Personal Assistant Preset

Use this file if skill upload is not available. Copy the skill content below and paste it at the start of your message to Cowork:

"Using this approach: [paste skill content] — now help me with [your task]."

---

## Daily Briefing

When giving a daily briefing, follow this approach: Read Calendar/, Tasks/, and People/ folders. Identify: (1) events today; (2) tasks overdue or due today; (3) follow-ups past their expected date. Present as a short bullet list under three headings: Today's schedule, Open tasks, Pending follow-ups. Keep each bullet to one line. If a folder does not exist, skip it and note "no [folder] found." Offer to create missing folders if the user asks.

**Example prompts:**

- "Good morning — what does my day look like?"
- "What's on my plate today? Check my calendar and tasks."
- "Give me a quick briefing before I start work."

---

## Follow-Up Tracker

When tracking follow-ups, follow this approach: Read the provided content. Identify every explicit or implied commitment: (1) things the user owes (owner = user); (2) things others owe the user (owner = named person). For each item: log who, what, and by when (if stated). Save to People/<name>.md or Tasks/ if no specific person applies. Flag items with no deadline as "no deadline set." Do not invent deadlines. Present the logged items as a numbered list before saving.

**Example prompts:**

- "I just got off a call with [name]. They said they'd send the contract by Friday. Track that."
- "Here's my inbox from this week: [paste]. What do I owe people? What do they owe me?"
- "Show me all open follow-ups from my People/ folder."

---

## Spend Awareness

When summarizing spending, follow this approach: Read the pasted transaction data. Group by category (Food, Transport, Subscriptions, Entertainment, Health, Other). For each category: total amount and number of transactions. Present as a plain-language bullet list — no tables, no spreadsheet formatting. Do not make recommendations, savings suggestions, or comparisons to benchmarks. This skill is descriptive only. If the user asks for savings advice or investment guidance, decline and redirect: "I can describe where the money went — for planning, consider a financial advisor."

**Example prompts:**

- "Here are last month's transactions: [paste]. Where did the money go?"
- "Summarize my spending from this bank export: [paste]."
- "Which categories did I spend the most on this month? [paste transactions]"
