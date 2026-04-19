# Connector Checklist — Personal Assistant Preset

Review each connector below. For each one you want to use: open Cowork Settings > Connectors > Authorize.

---

## Google Calendar

- **What it enables:** Lets Cowork read your calendar events — the highest-value connector for this preset. Powers the Daily Briefing skill.
- **Do you need this?** Recommended if you use Google Calendar as your primary calendar. Enables Cowork to surface today's schedule without manual pasting.
- **Permission scope:** Cowork requests read-only access to your calendar events.
- **Data boundary:** Cowork reads event titles, times, and locations. It does not write to your calendar. Event data stays local — Cowork does not send calendar details to any external service.

---

## Gmail

- **What it enables:** Lets Cowork read your inbox — useful for the Follow-Up Tracker skill and for catching up on pending messages.
- **Do you need this?** Optional. Useful if you want Cowork to surface emails that need a reply or contain commitments you should track.
- **Permission scope:** Cowork requests access to read messages and create drafts.
- **Data boundary:** Cowork reads email content locally. It does not send your email contents to any external service. Drafts are created in your Gmail — you send them manually.

---

## Finance: paste-only

> **Finance: paste-only.** Do NOT authorize banking, financial, or transaction-history connectors (Plaid, Yodlee, bank APIs, or similar) for this preset. Cowork's Data-Locality Rule requires financial data to stay local — paste transactions or statements directly into the chat instead.

**Why paste-only?** Authorizing a banking connector would give Cowork continuous access to your transaction history, balance, and account details. Even if Cowork handles this data carefully, connecting your bank account to any third-party system introduces risk that a simple paste-and-analyze workflow does not. The Spend Awareness skill is designed specifically for paste-based analysis — it works well without a connector.

**How to use Spend Awareness without a connector:**
1. Log into your bank's website
2. Export or copy-paste your recent transactions
3. Paste them into a Cowork message and ask for a summary

---

## Google Workspace note

If your Google account is managed by an organization (employer), your IT admin must authorize Claude in Google Workspace Admin Console before your personal authorization will work. For a personal Google account, authorization works directly through your Google login.
