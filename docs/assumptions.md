# Assumptions Register — Claude Cowork Config

## About This Document

Every assumption in the product spec is catalogued here with:
- **Confidence:** [CONFIRMED], [ESTIMATED], or [UNTESTED]
- **Risk:** What breaks if this assumption is wrong
- **Validation path:** How to verify before or after shipping

Assumptions are grouped by domain. Review this register before Phase 1 (architecture) and before any preset ships.

Last updated: v1.2 — 2026-04-17T00:00:00Z

---

## A — Cowork Platform Assumptions

### A1 — Project custom instructions accepts ≤350 words
**Confidence:** [UNTESTED — CRITICAL for v1.2]
**Assumption:** Cowork's Project custom instructions field accepts multi-paragraph plain-text up to approximately 400 words without truncation, reformatting, or rendering issues. v1.2 targets ≤350 words (increased from v1.1's ≤300 to support dynamic wizard branching).
**v1.2 update:** Dynamic wizard branches (suggestion flow, writing profile step) add ~30–50 words to each starter file. The ≤350 word target keeps files within the ~400-word assumption limit. If actual field limit is proven <300 words, revert to split architecture: state machine check in instructions (≤150 words), full wizard branches in WIZARD.md referenced by pointer.
**Risk:** If the field has a shorter character limit, the dynamic wizard is truncated silently. Users see a partial wizard with no indication something is wrong. This is the highest-impact technical risk in v1.2.
**Validation path:** Before Phase 4: manually paste a 350-word block into Cowork Project Settings > Custom Instructions. Verify saved text matches input exactly. Test at 300, 350, and 400 words. Document the actual limit.
**Escalation:** If limit is <300 words: redesign starter file to ~150-word state machine check + pointer to WIZARD.md for interview script.

### A2 — SKILL.md files in .claude/skills/ are loaded by Cowork
**Confidence:** [RESOLVED — SUPERSEDED by v1.1]
**Status:** Closed. Confirmed that Cowork does NOT auto-discover SKILL.md files from filesystem. Static skill file delivery delivers zero automatic value in Cowork.
**Resolution:** Skills delivered via: (1) `/skill-creator` wizard conversation (primary), (2) Anthropic pre-built skills (zero-config defaults), (3) ZIP upload via Settings > Customize > Skills > '+' (tertiary).
**No further action required.**

### A3 — Projects feature (March 2026) is stable for documentation guidance
**Confidence:** [ESTIMATED]
**Assumption:** Cowork's Projects feature (launched March 20, 2026) is stable enough for wizard guidance.
**Risk:** Low — GA product confirmed.
**Validation path:** Walk through Projects creation flow to confirm: project-scoped instructions persist, memory is scoped per-project, folder assignment works as documented.

### A4 — Cowork connectors do not require developer credentials
**Confidence:** [ESTIMATED]
**Assumption:** Authorizing Cowork connectors (Google Drive, Gmail, Slack) is a pure OAuth flow — no API keys or developer accounts required.
**Risk:** If any connector requires technical setup, our connector checklist misleads non-technical users.
**Validation path:** Walk through connector authorization for Google Drive and Gmail as a non-developer. Document exact flow.

### A5 — Cowork respects "confirm before delete" in Project custom instructions
**Confidence:** [ESTIMATED]
**Assumption:** Including the safety rule in Project custom instructions causes Cowork to prompt before any deletion.
**Risk:** HIGH. If this instruction is ignored, users remain exposed to the documented 11GB deletion scenario. Safety-critical assumption.
**Validation path:** Set up test workspace with safety instruction. Ask Cowork to "clean up" a folder. Verify Cowork prompts before deleting. Test with ≥3 deletion phrasings.
**Escalation:** If assumption fails, add prominent WARNING to README and SETUP-CHECKLIST.md.

### A6 — No public Cowork configuration API exists
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** No programmatic API for configuring Cowork. All configuration requires manual UI interaction.
**Risk:** Low — if API exists, our approach still works; API would be an upgrade for v2.
**Validation path:** Review Anthropic developer docs and Claude Help Center for any Cowork configuration API.

### A13 — Cowork Project memory does not auto-ingest context files
**Confidence:** [UNTESTED — unchanged]
**Assumption:** Cowork does not auto-ingest `about-me.md`, `cowork-profile.md`, or `writing-profile.md`. Users must manually seed memory.
**Risk:** If Cowork does auto-ingest, our manual memory-seeding guidance is redundant (harmless but unnecessary).
**Validation path:** Create Cowork Project with context files in project folder. Start fresh session and ask "What do you know about me?" without prompting. Document behavior.

### A14 — `/skill-creator` is a stable built-in Cowork command
**Confidence:** [ESTIMATED — carries from v1.1]
**Assumption:** `/skill-creator` is stable and produces valid `folder/SKILL.md` output. User-validated in one session (2026-04-15).
**Risk:** If deprecated or renamed, skill validation falls back to confirming file exists. Fallback path is a mandatory AC in F5.
**Validation path:** Before Phase 4: verify `/skill-creator` still exists in Cowork and produces expected output format.

### A15 — AskUserQuestion nudge causes Cowork to render clickable button UI
**Confidence:** [UNTESTED — carries from v1.1]
**Assumption:** The AskUserQuestion nudge MAY cause Cowork to render button UI.
**Risk:** Best-effort heuristic. No AC may require button rendering. Numbered list is the guaranteed fallback.
**Validation path:** Test by pasting starter file with nudge into fresh Cowork project. Observe whether buttons appear. Either outcome is acceptable.

---

## B — User Behavior Assumptions

### B1 — Non-technical users will follow a numbered checklist without abandoning
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** A non-technical user can follow the SETUP-CHECKLIST and complete setup in under 18 minutes (revised from 15 min to account for writing profile step).
**Risk:** Checklist drop-off if any step is ambiguous.
**Validation path:** Usability test with 3 non-technical users. Time from README open to first personalized session. Note every pause.

### B2 — Users are willing to complete a ≤12-step interview
**Confidence:** [ESTIMATED — REVISED for v1.2]
**v1.1 state:** 11-step interview with fast-track at Step 5.
**v1.2 change:** Writing profile adds 1 step → 12 steps. Fast-track pause moves to after Step 6.
**Alex's documented tolerance:** Alex has documented tolerance of "Minimal (2–3 max)." The 12-step plan directly contradicts this; fast-track mitigates. v1.2 fast-track pause is at Step 6 (after writing profile, before folder structure and skills).
**Mitigation:** Fast-track at Step 6 is the key mitigation. Alex can exit with a working workspace and writing profile (steps 1–6) without completing folder structure and skill discovery.
**Risk:** If >30% of users exit at fast-track without reaching skills steps, skill adoption will be low.
**Validation path:** Smoke test: measure % of test users who reach Step 9+ (first skill activation). If >40% fast-track and don't return for skill setup, consider making skills step shorter or moving it earlier.

### B3 — The 6 preset categories cover ≥80% of target user goals
**Confidence:** [ESTIMATED — revised]
**v1.2 update:** Dynamic wizard now handles novel goals (Career Manager, Home Renovation, Language Learning). The 80% coverage assumption is less critical — the wizard builds custom workspaces for the remaining 20%.
**Risk:** Reduced from v1.1. If presets are narrow, wizard's novel-goal branch handles the gap.
**Validation path:** Track novel-goal branches in test sessions and via GitHub issue analysis post-launch.

### B4 — Users have Cowork installed (or will install before using wizard)
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** Target audience is "just installed Cowork, don't know what to do next." Wizard does not install Cowork.
**Validation path:** Consider adding "Have you installed Claude Cowork? Y/N" as wizard question 0.

### B5 — Users are willing to answer writing profile questions in non-writing workspaces [NEW v1.2]
**Confidence:** [UNTESTED — MEDIUM risk]
**Assumption:** Users setting up a Study or PM workspace will answer 3–4 writing style questions even though they don't think of themselves as "writers." They understand that Cowork produces written output for all tasks.
**Risk:** Users may skip the writing profile step ("I'm not a writer — skip"), resulting in `writing-profile.md` with only default values. The profile is still generated (not empty) but is less personalized.
**Mitigation:** Wizard framing: "Even in a study/research workspace, I'll be writing summaries and explanations for you — this helps me match your style." The profile generates with substantive defaults even if questions are skipped.
**Validation path:** In smoke test: for non-Writing presets, observe whether test users complete writing profile step or attempt to skip. If >40% skip, revise framing.

---

## C — Delivery & Community Assumptions

### C1 — GitHub + LinkedIn is sufficient for initial distribution
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** LinkedIn post + quality GitHub README generates ≥200 stars within 30 days.
**Validation path:** Track referral source for first 100 GitHub visitors via UTM parameters.

### C2 — Community contributors will add skills and presets
**Confidence:** [UNTESTED — revised for v1.2]
**v1.2 change:** Community contribution now includes two paths: (a) new preset PRs (same as v1.1), (b) skill entries to `curated-skills-registry.md`. The registry path is lower-friction than a full preset PR.
**Assumption:** ≥10 community skill entries will be submitted to `curated-skills-registry.md` within 60 days.
**Risk:** Registry remains sparse — users see fewer curated skill suggestions for novel goals.
**Validation path:** Track PRs against `curated-skills-registry.md` in first 60 days. If contributions are absent, add a "contribute a skill" workflow to CONTRIBUTING.md with a template.

### C3 — Users will use ZIP download, not git clone
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** Non-technical users use GitHub's "Download ZIP." Wizard works without git installed.
**Validation path:** Download repo as ZIP and walk through full wizard flow. Verify no step requires git.

---

## D — Market/Timing Assumptions

### D1 — Cowork's non-technical user base is large enough
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** Claude Pro/Max plans have a meaningful non-technical knowledge worker user base actively trying to use Cowork.
**Validation path:** Track referral sources from Claude subreddits and knowledge worker communities vs. developer communities.

### D2 — No competing product provides this wizard experience for Cowork specifically
**Confidence:** [ESTIMATED — carries from v1.1]
**v1.2 update:** Claude Code skill ecosystem has grown (22,000+ star repos, skills.sh marketplace, Anthropic official skills registry). All of this targets Claude Code users (developers), NOT Cowork users (knowledge workers). Gap remains unserved.
**Risk:** Anthropic ships native Cowork onboarding wizard. Mitigated by: pivot to "advanced configuration" and "preset expansion beyond defaults."
**Validation path:** Search GitHub and Product Hunt monthly for Cowork-specific onboarding tools.

### D3 — Skill security risk justifies curated-first approach [NEW v1.2]
**Confidence:** [CONFIRMED]
**Evidence:** Repello AI research (2026): 13.4% of community skills contain critical security issues. Snyk ToxicSkills research (2026): prompt injection in 36% of tested skills, 1,467 malicious payloads found. Cato Networks documented weaponized Claude skills using ransomware delivery.
**Assumption:** A curated Tier 1 default is required, not optional. Tier 2 opt-in with explicit warnings is the appropriate middle ground.
**Risk:** If we ship Tier 2 as default, we expose non-technical users (Alex, Maria) to 13.4% critical risk rate with no prior safety context. This is unacceptable.
**Validation path:** Already confirmed by security research. No additional validation required — this is a design constraint, not a hypothesis.

### D4 — `curated-skills-registry.md` is maintainable as a static file [NEW v1.2]
**Confidence:** [UNTESTED — LOW risk]
**Assumption:** A manually maintained markdown registry is sufficient for v1.2. Skills remain installable at their documented source URLs without a live API or package manager.
**Risk:** Skills at external URLs become unavailable (repo deleted, renamed, rate-limited). Registry entries become stale.
**Mitigation:** Vetting date in each registry entry. CONTRIBUTING.md instructs contributors to verify URL accessibility before submitting.
**Validation path:** After 60 days post-launch, audit registry entries for broken URLs. If >15% are stale, evaluate adding an automated URL health check to CI.

---

## v1.3.0 Assumptions

_Added: 2026-04-17T21:00:00Z — v1.3.0 Preset Skills Depth cycle_

### B10 — Users will complete the per-skill input session without fatigue [NEW v1.3.0]
**ID:** A-v1.3-1
**Confidence:** [UNTESTED — MEDIUM risk]
**Assumption:** The project owner will answer 4–6 targeted questions for each of the 3 Study skills during `/implement` without abandoning the session partway through. Total input load: 12–18 questions across 3 sessions.
**Risk:** If the owner fatigues mid-session, a skill may be drafted with incomplete quality criteria or a missing worked example, reducing the template's signal quality for future community contributors.
**Mitigation:** Only 3 skills in v1.3.0 (hybrid cadence). Sessions are spread across 3 separate commits, not batched. Orchestrator saves partial answers to `skill-inputs/<skill-name>.md` so a session can resume if interrupted.
**Validation path:** Monitor whether all 3 input files exist and are complete at Phase 5. If any file is missing answers for quality criteria or worked example, flag as incomplete before Phase 7 approval.

### A-v1.3-2 — The 9-section template fits all 18 preset skills [NEW v1.3.0]
**ID:** A-v1.3-2
**Confidence:** [UNTESTED — MEDIUM risk]
**Assumption:** The 9-section template (`When to use`, `Triggers`, `Instructions`, `Output format`, `Quality criteria`, `Anti-patterns`, `Example`, `Writing-profile integration`, `Example prompts`) is structurally appropriate for all 18 preset skills across 6 presets — not just Study.
**Risk:** A non-Study skill (e.g., `voice-matching` in Writing, or `ideation-partner` in Creative) may require a section that doesn't map cleanly to the template, forcing a template revision after v1.3.0 ships. If the template changes post-v1.3.0, the Study skills (already committed) may need retroactive updates.
**Mitigation:** Pilot `flashcard-generation` first. If the pilot reveals a structural mismatch, adjust the template before `note-taking` and `research-synthesis` are authored. Template is considered provisional until all 3 Study skills are approved.
**Validation path:** At Phase 1 design, @architect reviews the template against 1–2 non-Study skill examples (e.g., `voice-matching`, `status-update`) and confirms or adjusts fit. Document in ADR.

### A-v1.3-3 — Community contributors will accept the deeper template as the submission bar [NEW v1.3.0]
**ID:** A-v1.3-3
**Confidence:** [UNTESTED — LOW risk (aspirational)]
**Assumption:** When `templates/skill-template/SKILL.md` ships with v1.3.0 and `skill-depth-check` CI enforces the 9-section format, community Tier 2 contributors will adopt the template rather than submitting stub-quality skills or abandoning PRs.
**Risk:** If the template is perceived as too onerous, community contributions to `curated-skills-registry.md` and new preset PRs stall. This risks the v1.2 metric of ≥10 community registry entries within 60 days.
**Mitigation:** Template ships with clear inline placeholder comments. CONTRIBUTING.md PR checklist includes a reference to the template. `skill-depth-check` CI failure message is human-readable (not just "exit code 1").
**Validation path:** Track Tier 2 PR submissions after v1.3.0 launch. If zero PRs attempt the new template format within 30 days, add a "Getting started" tutorial section to CONTRIBUTING.md.

### A-v1.3-4 — CI allowlist approach is sustainable through v1.3.5 [NEW v1.3.0]
**ID:** A-v1.3-4
**Confidence:** [ESTIMATED — LOW risk (accepted trade-off)]
**Assumption:** Maintaining a path allowlist in `skill-depth-check` CI (widening by one preset per point release) is operationally sustainable for 6 releases (v1.3.0–v1.3.5) without accumulating technical debt. Each release requires a 1-line CI edit to add the new preset path.
**Risk:** If a preset is renamed or reorganized before its scheduled release, the allowlist entry must be updated manually. Missed update would silently skip enforcement for that preset.
**Mitigation:** CI job comment documents the rollout schedule and next-preset path explicitly. Each v1.3.x spec revision confirms the path before Phase 4.
**Validation path:** At v1.3.5, evaluate whether to consolidate to a global glob. If all 6 presets are on the new template format, replace the allowlist with `presets/**` and close the technical debt.

---

## v1.3.1 Assumptions

_Added: 2026-04-18T00:00:00Z — v1.3.1 Research Preset Depth + Carry-Forward Hygiene cycle_

No new assumptions for v1.3.1. Existing assumptions that carry forward and remain active:

- **A-v1.3-2** ([ESTIMATED]) — The 9-section template fits all 18 preset skills. v1.3.1 is the second validation point (Research preset). Template is still provisional until all 6 presets have at least one skill approved; v1.3.1 extends validation from Study to Research. If Research skills reveal structural gaps in the template, @architect Phase 1 may make targeted amendments before skill authoring.
- **A-v1.3-3** ([UNTESTED]) — Community contributors will accept the deeper template as the submission bar. v1.3.1 does not change this assumption; observable signal will arrive post-launch.
- **A-v1.3-4** ([ESTIMATED]) — CI allowlist approach is sustainable through v1.3.5. v1.3.1 widens to `"study research"` — this is the planned next step and does not change the risk profile.

**New observational signal (not a formal assumption):** The B10 "propose defaults + clarify" pattern validated in v1.3.0 for skills 2+ is being codified in H2 but remains [UNTESTED] as a controlled comparison. The v1.3.1 `source-analysis` and `research-synthesis` B10 sessions will be the second and third data points. If either session produces materially lower-quality skill output than the pilot, revisit whether the reduced-friction pattern sacrifices too much user input specificity.

---

## v1.4 Assumptions

_Added: 2026-04-19T00:00:00Z — v1.4 Personal Assistant Preset cycle_

### A-v1.4-1 — Users want a tactical personal-life PA separate from business-admin [NEW v1.4]
**ID:** A-v1.4-1
**Confidence:** [ESTIMATED]
**Assumption:** A meaningful segment of cowork-starter-kit users wants a personal-life PA preset that is distinct from the business-admin (work-focused) preset. The desired use cases are tactical and daily: morning briefing, relationship/commitment follow-up tracking, basic spend awareness.
**Evidence:** 5+ research sources (Superhuman blog, Copilot PA product surveys, Reclaim.ai user research, Motion feature prioritization data, Rabbit R1 post-mortem analysis) show daily-briefing rituals, commitment-tracking labor, and spend-awareness as the three highest-retention behaviors in personal AI assistant products. No current Cowork resource addresses this combination.
**Risk:** If users are satisfied adapting the business-admin preset for personal use, the new preset sees low adoption. Risk is LOW — the folder structure, writing tone, and skill set of business-admin are demonstrably wrong for personal-life contexts (formal/authoritative tone vs. warm/direct; professional skills vs. personal-life skills).
**Validation path:** After v1.4 launch, track wizard Q1 selection rate for Personal Assistant (option 7) vs. other options. If <5% of wizard completions select Personal Assistant in 60 days, evaluate whether the persona (Life Admin Juggler) is underserved or undiscoverable.

### A-v1.4-2 — 3-skill stub preset is sufficient for v1.4 [NEW v1.4]
**ID:** A-v1.4-2
**Confidence:** [CONFIRMED — user decision 2026-04-19]
**Assumption:** A 3-skill stub preset (daily-briefing, follow-up-tracker, spend-awareness as 16-line stubs) is a complete and shippable v1.4 deliverable. Deeper skill development (9-section rewrites, B10 input sessions) is deferred to v1.4.1 or later.
**Risk:** LOW — this is a deliberate scope boundary decided by the product owner, not an untested hypothesis. The preset itself (folders, connectors, global-instructions, wizard integration) is the primary value; skill depth is a quality enhancement.
**Validation path:** N/A — confirmed by user. Close this assumption at Phase 4 completion.

### A-v1.4-3 — Data-locality rule is enforceable via instruction-surface wording [NEW v1.4]
**ID:** A-v1.4-3
**Confidence:** [UNTESTED — to be validated in Phase 2]
**Assumption:** Including "Never echo raw financial amounts, full calendar events, or contact details to external services or APIs" in `global-instructions.md` is sufficient to prevent unintended data exfiltration when users connect Google Calendar or Gmail via the connector-checklist. The instruction wording creates an adequate behavioral constraint on Cowork's connector use.
**Risk:** MEDIUM. LLM instruction surfaces are best-effort; a sufficiently complex connector workflow (e.g., "summarize my Gmail and post to Slack") might cause Cowork to transmit calendar or contact data to a third-party service despite the rule. The "paste-only" finance instruction is stronger (no connector exists to violate it) but the calendar/contact constraint depends on Cowork respecting the instruction in edge cases.
**Mitigation:** Phase 2 (@security) is asked to explicitly evaluate whether the instruction wording is sufficient or whether a stronger control (e.g., connector allowlist, explicit Cowork connector guidance) is needed. The data-locality rule's heading (`## Data Locality Rule`) is implementation-verifiable by grep.
**Validation path:** @security Phase 2 assessment determines whether [UNTESTED] status resolves to [ESTIMATED] (instruction is likely sufficient) or escalates to a CRITICAL finding requiring additional controls.

### A-v1.4-4 — 5-folder structure covers common personal PA use cases [NEW v1.4]
**ID:** A-v1.4-4
**Confidence:** [ESTIMATED]
**Assumption:** The `Calendar/`, `Finances/`, `Tasks/`, `People/`, `Documents/` folder structure is appropriate for the Life Admin Juggler persona and covers the common personal-life PA workflows without over-prescribing a life taxonomy.
**Risk:** LOW. Users who need a different structure can modify `folder-structure.md`. The folder structure is guidance, not enforcement — Cowork does not create folders automatically (user follows the setup checklist). Worst case: a user ignores the suggested structure and creates their own.
**Validation path:** Post-launch GitHub issue analysis. If >3 issues request a different default folder structure, revisit for v1.4.1.

### A-v1.4-5 — spend-awareness delivers value from a single paste without persistent history [NEW v1.4]
**ID:** A-v1.4-5
**Confidence:** [UNTESTED]
**Assumption:** The `spend-awareness` skill can deliver useful categorical observations and 1–2 proactive flags (subscription detection, unusual spend) from a single user-pasted transaction list, without needing a persistent transaction schema, historical comparison, or live bank feed.
**Risk:** MEDIUM. "What's unusual?" requires some baseline. A single paste with no history limits the AI to intra-statement comparisons (e.g., "this category is larger than typical household ratios") rather than personal-baseline comparisons (e.g., "you spent 40% more on dining than last month"). The skill's value is real but is bounded by the single-paste constraint.
**Mitigation:** Stub instructions explicitly scope the skill to "categorized summary + 1–2 proactive observations from the provided data." No claim of historical trend analysis is made. The limitation is surfaced in the README positioning statement ("tactical awareness only").
**Validation path:** At v1.4.1 depth-rewrite, assess whether a structured input format (user pastes current month + prior month) would increase skill utility without introducing persistent storage. If yes, add as a v1.4.1 instruction enhancement.
