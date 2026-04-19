# User Personas — Claude Cowork Config (v1.2)

## How to Use This Document

These personas are the product's decision filter. Before adding a feature, removing an AC, or changing a preset, ask: does this serve Alex, Maria, Sam, or Jordan? If it serves none of them, it's out of scope.

v1.2 adds **Jordan** — the "I don't know what I want" user — as a canonical fourth persona that drives the dynamic wizard's design. Jordan is not a new user type; Jordan is Alex, Maria, and Sam on their first day.

Personas are derived from: Cowork community guides (2026), user feedback summaries (coworkhow.com), DataCamp tutorial audience analysis, brainstorm session with project owner (2026-04-14), and v1.1 production observations (2026-04-16).

---

## Primary Persona: Alex — The Student

**Name:** Alex Chen
**Age:** 20
**Role:** Junior, biochemistry major
**Cowork plan:** Claude Pro ($20/month)

### Context

Alex switched to Claude Pro after seeing a LinkedIn post about Cowork for students. He's heard Cowork can "read your PDFs and work in your files" but hasn't figured out how to set it up. His study folder is a mess. He knows he should organize it — he just doesn't know how.

He spends 3–4 hours a week re-explaining context to AI tools because there's no persistent memory.

### v1.2 Context: Alex and the Wizard

Alex is the primary design target for the dynamic wizard. He will NOT recognize himself in a preset menu. He will describe his situation in plain language: "I'm trying to get better at keeping up with my readings for biochem." The wizard must map that description to a Study workspace, suggest appropriate skills, and build the folder structure — without Alex needing to know what any of those things are.

Alex is also the primary writing profile test case. He does not think of himself as "a writer" — he writes lab reports and literature summaries. The writing profile wizard must frame this as "I'll help your work sound like how you think, not like a robot summarized your notes."

### Goals (JTBD)

**Functional jobs:**
- Synthesize 15–20 research papers into a coherent literature summary
- Generate flashcards from lecture notes for active recall studying
- Format citations in APA/Chicago without doing it manually
- Find connections between papers he might have missed
- Draft and revise lab reports with academic tone

**Social jobs:**
- Feel like a capable, effective student — not someone who's struggling
- Produce work that impresses professors
- Feel like he's using tools at their full potential

**Emotional jobs:**
- Reduce the anxiety of "I have 12 papers to read and a report due Friday"
- Feel in control of his study process
- Build confidence he can tackle research-heavy assignments independently

### Pains

| Pain | Severity | v1.2 Impact |
|------|----------|-------------|
| Doesn't know how to configure Cowork | High | Dynamic wizard solves — no product knowledge required |
| Re-explains context every session | High | cowork-profile.md + persistent instructions |
| Outputs sound like generic AI (academic integrity concern) | High | writing-profile.md calibrates to his academic voice |
| Doesn't know what skills are or how to find them | Medium | Curated Tier 1 suggestions, no GitHub browsing required |
| Fears breaking something with a wrong command | Medium | Safety rule + confirm before delete |
| Never set up instructions — every output is too generic | High | Dynamic wizard builds instructions from conversation |

### Quote (v1.2 update)

> "I just told it I was trying to keep up with my biochem readings and it figured out I needed a study workspace. I didn't have to pick from a menu or know any of the jargon. And my summaries actually sound like how I explain things, not like a textbook."

### Writing Profile for Alex

- **Tone:** Semi-formal academic (not stuffy, but not casual)
- **Audience:** Professors and lab partners
- **Anti-AI guidance focus:** Avoid passive voice overuse, overly hedged language, generic transitions ("It is important to note...")
- **Workspace-specific:** APA citation conventions, academic integrity framing (support learning, not shortcut)

### Usage Pattern

- Cowork 3–5 times per week for paper synthesis and note organization
- Most valuable: "Read these 8 PDFs and give me a structured summary with key arguments and gaps"
- Fast-track: Will likely use fast-track pause after Step 6 and return for skills later

---

## Secondary Persona: Maria — The Knowledge Worker

**Name:** Maria Santos
**Age:** 35
**Role:** Research analyst at a mid-size consultancy
**Cowork plan:** Claude Max ($100/month)

### Context

Maria has tried every AI tool in the last two years. She's gotten real value from them. She's never fully cracked how to configure them to match her professional standard. Every time she uses Cowork, she pastes 3–4 paragraphs of context before the first task because there's nowhere to store it permanently.

She manages 4–5 active projects at once. She's tried Cowork Projects but hasn't set up per-project instructions because it takes time she doesn't have.

### v1.2 Context: Maria and the Wizard

Maria will arrive knowing roughly what she wants ("something for research and project management") but not knowing how to configure it. The dynamic wizard recognizes her goal as a Research/PM hybrid and proposes a workspace that spans both presets. It then asks the writing profile questions — Maria will be the most engaged with this step, because every output she produces has to sound like a senior analyst, not a chatbot.

Maria is also the primary persona for Tier 2 skill discovery. She'll ask "are there any other skills for analyst workflows?" and opt into advanced search with full awareness of the risk context.

### Goals (JTBD)

**Functional jobs:**
- Produce a structured literature review from 20+ source documents in 90 minutes
- Draft client-ready reports with her firm's standard format
- Triage and prioritize her inbox to the 3 emails needing responses today
- Track deliverable status across multiple projects
- Onboard to a new research topic quickly

**Social jobs:**
- Maintain reputation as a rigorous, fast researcher
- Deliver work that impresses senior partners
- Be the team's AI tool power user

**Emotional jobs:**
- Reduce the "constant context tax"
- Feel like she has a reliable AI assistant, not a generic chatbot
- Trust that Cowork won't modify her client files without approval

### Pains

| Pain | Severity | v1.2 Impact |
|------|----------|-------------|
| Re-explains professional context every session | High | cowork-profile.md + writing-profile.md together eliminate this |
| No per-project instructions — generic output | High | Dynamic wizard builds custom instructions per workspace |
| Outputs don't match professional standard | High | Writing profile with sample analysis captures her firm's style conventions |
| Doesn't know which connectors to prioritize | Medium | Goal-filtered connector checklist |
| 3 half-configured setups from different experiments | Medium | /setup-wizard reset path; fresh start |
| Worried about Cowork modifying client files | High | Safety rule non-negotiable |

### Quote (v1.2 update)

> "The writing profile thing was what sold me. I pasted a paragraph from one of my reports and it said 'I notice you lead with the conclusion and use tight, declarative sentences.' That's exactly right. Now my Cowork outputs actually sound like I wrote them."

### Writing Profile for Maria

- **Tone:** Professional, authoritative, structured
- **Audience:** Senior partners and clients
- **Characteristic patterns:** Executive summary first, tight paragraphs, conclusion before reasoning, footnoted citations
- **Anti-AI guidance focus:** Avoid filler phrases, hedged language, "In conclusion" openers, bullet-point overuse when prose is more authoritative
- **Workspace-specific:** Executive summary format, footnote citation style, "never modify files" rule prominent

### Usage Pattern

- Cowork daily, 1–2 hours per day
- Most valuable: "Read all documents in /Project-Alpha/Research/ and produce a structured synthesis"
- Second most valuable: "Go through my Gmail inbox and identify the 5 emails needing responses this week"
- Will use Tier 2 skill discovery; will read safety warnings carefully before installing

---

## Tertiary Persona: Sam — The Creator

**Name:** Sam Rivera
**Age:** 28
**Role:** Freelance writer / newsletter author
**Note:** Writing and Creative presets. Do not over-optimize wizard flow for Sam at the expense of Alex and Maria.

### Context

Sam's pain is specific and urgent: every Cowork output sounds like generic AI, not like Sam. The writing profile step in v1.2 directly solves Sam's core problem in a way v1.1 could not.

Sam will be the most deliberate writing profile user — they will provide a writing sample, review the extracted patterns carefully, and likely refine before confirming.

### v1.2 Context

Sam is the validation case for the writing profile's optional sample analysis. If the sample analysis doesn't produce recognizable patterns for Sam, the feature has failed.

### Goals (JTBD)

**Functional jobs:**
- Maintain consistent voice across all newsletter outputs
- Generate outlines and drafts in their voice from notes
- Get structural feedback that respects their style

**Social jobs:**
- Consistent brand voice — readers know it's Sam's writing, not AI

**Emotional jobs:**
- Feel like Cowork is a creative collaborator, not a ghost-writer who writes in the wrong voice

### Pains

| Pain | Severity | v1.2 Impact |
|------|----------|-------------|
| Every output sounds like generic AI | High | Writing profile with sample analysis = primary v1.2 gain for Sam |
| No persistent brand voice document | High | writing-profile.md is exactly this |
| Voice inconsistency across outputs | Medium | Profile referenced by global-instructions on every ≥100 word output |

### Quote (v1.2 update)

> "I pasted one paragraph from my newsletter and it caught that I start sentences with conjunctions and use em-dashes a lot. My outputs actually sound like my newsletter now."

### Writing Profile for Sam

- **Tone:** Conversational, distinct, personal
- **Audience:** Newsletter readers
- **Characteristic patterns:** Short paragraphs, em-dashes for asides, sentence-starting conjunctions, specific concrete examples over generalizations
- **Anti-AI guidance focus:** Avoid formal academic transitions, passive voice, "it's important to" openers, comma-heavy long sentences

---

## New Persona: Jordan — "I Don't Know What I Want"

**Name:** Jordan (any age, any role)
**This is a state, not a person.** Jordan is Alex, Maria, or Sam on their first session. They exist to ensure the dynamic wizard is designed for uncertainty.

### What Jordan Represents

Jordan just installed Cowork. Jordan knows AI is useful. Jordan has heard Cowork is powerful. Jordan has no idea how to get started. Jordan cannot identify with any preset in a menu — not because their goal is exotic, but because they don't know what a "preset" is or why they'd pick one.

Jordan describes their situation:
- "I want to use this for work stuff"
- "Something to help me with my job"
- "I'm a teacher and I want to use AI to help me plan lessons, grade, communicate with parents..."
- "I'm trying to manage my job search"

None of these are "Study" or "Research" or "Business/Admin" in the way a menu item presents them.

### Why Jordan Is a Canonical Persona

Every design decision that requires "the user knows what they want" fails Jordan. v1.2 exists because Jordan is not an edge case — Jordan is the median new Cowork user.

### Jordan's Requirements from the Wizard

1. The wizard must NOT require Jordan to identify a preset before asking questions
2. The wizard must suggest options when Jordan is uncertain — not wait for Jordan to figure it out
3. If Jordan's goal resembles a preset, the wizard can offer the preset as a shortcut — but Jordan never has to know the preset existed
4. If Jordan's goal is novel (Career Manager, Home Renovation, Language Learning), the wizard must still produce a complete, useful workspace

### Jordan's Success Criteria

Jordan completes setup. Jordan's workspace matches what they actually wanted. Jordan does not know or care that it was built from a "preset scaffold" or a "novel-goal flow." Jordan just has a workspace that works.

### Design Principle Derived from Jordan

**The wizard must assume zero product knowledge at every step.** When the wizard says "skill," it immediately explains what a skill is. When it says "folder structure," it explains why you'd want one. When it suggests a connector, it explains what that connector will let you do. Every term is introduced with context the first time it appears.

---

---

## Tertiary Persona (v1.4): Casey — The Life Admin Juggler

**Name:** Casey (any age, parent/caretaker archetype)
**Role:** Parent, caretaker, or anyone simultaneously managing family logistics, shared finances, and relationship networks.
**Cowork plan:** Claude Pro ($20/month)
**Note:** Tertiary persona added in v1.4. Does not displace Alex, Maria, or Sam. Do not over-optimize for Casey at the expense of the primary/secondary personas.

### Context

Casey has three different inboxes (work email, family group chat, school portal) and a mental model of who owes whom what — a birthday gift to buy, a callback to a sibling, a reimbursement from the carpool. Casey is constantly managing relationship labor that falls through the cracks precisely because it lives nowhere: not in a task app, not in a calendar, not in a notes app.

Casey also runs the family finances but has no time for deep budgeting — they just want to know if anything looks weird this month and whether there's a subscription nobody uses.

Casey has tried ChatGPT and Copilot but gets frustrated re-explaining context every session. Casey is not a knowledge worker in a professional sense — their "work" is the domestic and relational coordination of a household.

### Goals (JTBD)

- Surface missed commitments before they cause relationship damage ("You were supposed to call Mom on Tuesday")
- Get a structured morning view of the day without building it manually
- Catch unusual or duplicate charges without spending an hour on Mint or a spreadsheet
- Keep personal files organized without a system that requires constant maintenance

### Why Casey Validates the Personal Assistant Preset

Casey is the persona for whom the three PA skills (`daily-briefing`, `follow-up-tracker`, `spend-awareness`) have the highest retention signal. They are not a productivity optimizer — they are an overloaded coordinator who needs to reduce the cognitive overhead of domestic administration.

**Under 200 words:** Casey is a parent or caretaker archetype who manages family logistics, commitments, and finances simultaneously. The Personal Assistant preset — with its tactical daily-briefing, relationship-labor follow-up tracker, and one-glance spend-awareness summary — is designed for this exact overload profile.

---

## Persona Priority Matrix (v1.2)

| Decision | Alex | Maria | Sam | Jordan |
|----------|------|-------|-----|--------|
| Wizard entry point | Dynamic description → Study scaffold | Dynamic description → Research/PM hybrid | Dynamic description → Writing scaffold | Dynamic description → anything |
| Writing profile engagement | Medium (frames as "academic voice") | High (professional standard) | Very high (brand voice) | Unknown — wizard must make case |
| Technical comfort | Low — zero-code required | Medium — tolerates checklist | Low-medium | Low — assume Alex level |
| Safety sensitivity | Medium — student files | Very high — client files | Low | Unknown — default to high |
| Skill discovery | Tier 1 curated only | Tier 1 + optional Tier 2 | Tier 1 curated only | Tier 1 curated only (can't opt into Tier 2 safely without safety literacy) |
| Primary success metric | Workspace matched goal + used within 7 days | Hours saved + professional quality output | Voice consistency | Setup completed — workspace matched what they described |
| Fast-track behavior | Will likely fast-track at Step 6 | Will complete all steps | Will complete writing profile but maybe fast-track skills | Will fast-track — come back later |

---

## Design Principles from Personas (v1.2)

1. **Lowest common denominator = Jordan.** If Jordan can navigate a step without product knowledge, Alex can too. Maria is never blocked by a step designed for Jordan.

2. **Safety is Maria's hard requirement, and Jordan's unspoken one.** Jordan doesn't know to ask for safety. We provide it by default because Jordan cannot protect themselves from a file deletion they didn't anticipate.

3. **Context persistence is the #1 gain for Alex and Maria.** `cowork-profile.md` + `writing-profile.md` together eliminate the "constant context tax." Both files are created in every setup.

4. **Voice is Sam's primary requirement and Maria's secondary.** The writing profile is not optional for Sam — it IS the product. For Maria, it elevates already-good work to something that sounds like her specifically.

5. **Jordan must not feel lost when given options.** Every AskUserQuestion button set must include an "I'm not sure / help me decide" path. The wizard never dead-ends on uncertainty.

6. **Skill discovery must protect Jordan by default.** Jordan cannot assess security risk. Tier 1 curated skills are Jordan's path. Tier 2 is only available after explicit opt-in with a clear explanation of what "community-sourced, unverified" means.
