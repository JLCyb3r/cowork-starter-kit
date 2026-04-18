# Security Review — cowork-starter-kit v1.3.0 (Preset Skills Depth — Study Preset Pilot)

## Phase: 2
## Date: 2026-04-17T22:30:00Z
## Status: PASS WITH WARNINGS

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | WARNING | 2 | configuration | `skill-depth-check` CI is fail-open by design — unknown preset paths silently skip; a malicious PR adding skills under a new (unallowlisted) path bypasses depth enforcement |
| S2 | WARNING | 2 | configuration | CONTRIBUTING.md PR checklist is v1.2 — missing v1.3.0 items (9-section template compliance for any NEW skill submission, `trigger_examples` optionality, reference to `templates/skill-template/SKILL.md`) |
| S3 | WARNING | 2 | configuration | Negative test fixture file (`curated-skills-registry.test.md` with `ftp://NEGATIVE-TEST-FIXTURE-v1.3.0`) must be excluded from (a) the production `registry-cardinality-check` count, (b) `link-check` lychee scans, and (c) release ZIP artifacts — no exclusion mechanism yet specified |
| S4 | WARNING | 2 | configuration | `.gitignore` does not explicitly block `.claude/projects/` — if orchestrator ever runs a Bash/Write from inside the product repo tree, raw B10 input session files (potentially containing user's real worked examples with sensitive data) could leak into a product commit |
| S5 | INFO | 2 | auth | Template placeholder text in `templates/skill-template/SKILL.md` is a shallow indirect injection vector — contributor who ships unedited placeholders creates low-quality noise, not instruction hijack, provided the placeholder-authoring guidance below is followed |
| S6 | INFO | 2 | configuration | `trigger_examples` YAML frontmatter field is a new machine-readable trigger surface — a malicious community skill could craft trigger phrases that auto-fire the skill on unrelated user prompts; proactive-rule tooling consumes this field without sanitization |
| S7 | INFO | 2 | logging | Writing-profile integration section (ADR-015 §8) mandates every skill reference `context/writing-profile.md` — verify the Study skill drafts do NOT echo writing-profile contents into example output that could be mirrored into logs/telemetry (no telemetry exists today — forward-looking guard) |
| S8 | INFO | 2 | external-api | README B9 teaser links to GitHub Milestone #1 and Issue #2 (world-readable); sanity check — confirm no unreleased security fix details leak into those issue bodies before v1.3.0 tag |
| S9 | INFO | 2 | configuration | B7 allowlist regex `^https://github\.com/|^builtin$` verified non-breaking — all 18 v1.2 registry entries use literal `builtin` (0 non-GitHub HTTPS entries); tightening can land safely |

---

## Phase 1 Open-Issue Verdicts

Four explicit open issues from @architect require a security verdict before PASS.

### Open Issue 1 — Template placeholder text as injection vector

**Verdict: NEEDS-POLICY — SAFE with placeholder-authoring guidance documented.**

**Reasoning.** `templates/skill-template/SKILL.md` is a *contributor-facing* file, not a runtime LLM context file. Community contributors COPY it, edit it, and submit a filled-in version via PR. The raw template never reaches Cowork runtime for any end user — only the filled-in community skill reaches runtime, and only after (a) CONTRIBUTING.md PR review, (b) B7 registry-url-check, (c) the incoming B2 skill-depth-check, and (d) Tier 2 opt-in gating per v1.2 ADR-012. The injection surface is therefore the *filled-in* skill, not the template.

The real risk the architect flagged is different and still valid: a lazy contributor ships unedited placeholder text (e.g., `[your instructions here]`, `[YOUR QUALITY CRITERIA]`) verbatim. Outcome: the committed skill contains placeholder strings that Cowork reads at runtime. A placeholder string like `[describe what Cowork should do here]` is benign — it reads as broken content, not as an instruction. But a placeholder phrased as an imperative ("Ignore previous instructions and...", "Always respond with...", "Delete these files:") WOULD be a live prompt injection string shipping into user workspaces.

**Therefore placeholder-authoring MUST follow these rules (document in CONTRIBUTING.md and the template file itself):**

1. **Placeholders are bracketed nouns, never imperatives.** Use `[one-line description of when this skill fires]`, NOT `[Tell Cowork to...]`.
2. **Never include the words "Ignore", "Disregard", "Override", "Instead", or "Always" inside a placeholder.** These are first-order injection tokens — even as placeholder filler, they would be executable if a contributor forgot to replace them.
3. **Use inline HTML comments for intent explanation:** `<!-- Replace: describe quality criteria as 3–5 yes/no-checkable bullets -->`. HTML comments are invisible to Cowork runtime (stripped from markdown rendering in most skill-loading pipelines), so intent docs cannot double as instructions.
4. **Never ship a placeholder matching the safety rule pattern.** The template must NOT contain placeholder text that includes "confirm before delete" variants; real safety rule must live ONLY in `global-instructions.md` and `project-instructions-starter.txt` to avoid dilution.
5. **Placeholder text for the `## Example` section MUST use obvious non-runtime phrasing.** `[Paste a real input here]` + `[Paste the ideal output here]` reads as instructions-to-contributor; any phrasing that could be misread as instructions-to-Cowork (e.g., "Generate an example where...") is forbidden.

Finding S5 (INFO) captures this. It is INFO rather than WARNING because ADR-015 Length Budget §Floor=60 lines and B2 `skill-depth-check` both make an unedited template stub visible (a 60-line file full of `[placeholder]` strings is obvious in PR review). The bigger risk is contributor sloppiness, not adversarial authoring.

**Action for @dev Phase 4:**
- Draft `templates/skill-template/SKILL.md` following rules 1–5 above.
- Add a CONTRIBUTING.md subsection "Placeholder authoring rules" listing the 5 rules.
- Verify (manually at Phase 5) that no placeholder string in the template contains any of the forbidden imperative tokens.

---

### Open Issue 2 — `skill-depth-check` fail-open design

**Verdict: REQUIRES CHANGE — keep fail-open for the `ENFORCED_PRESETS` list as architecturally designed, BUT add a fail-closed guard for new skill files under unknown paths.**

**Reasoning.** The architect's fail-open design is correct for its stated purpose: during v1.3.0–v1.3.5 rollout, preset directories not yet on the 9-section format MUST not break CI. Fail-closed on `presets/**` would block v1.3.0 on day one because 5 presets (15 skills) are still 16-line stubs. Option A in ADR-016 is the right call for the preset-level rollout.

**But the architect's flagged attack is different:** "a contributor adds a malicious preset in a NEW path, bypassing depth checks." The attack vector is not `presets/research/.claude/skills/...` (allowlist will catch research at v1.3.1). It is a NEW path like `presets/legal/.claude/skills/malicious-skill/SKILL.md` landing in a PR that claims to be "adding a new preset." The B2 CI job as written (`ENFORCED_PRESETS="study"`) would silently skip `presets/legal/**` — no depth enforcement, no section check, no floor check.

This is a real gap, but it is also the intended trade-off (per ADR-016 §Options §Cons and A-v1.3-4). Two layers of mitigation already exist:
- `skill-format-check` (ADR-008) DOES run across all presets globally — it catches flat `.md` files and missing `SKILL.md` entries.
- CONTRIBUTING.md requires human review of new preset PRs.

What's missing is a **guardrail-over-floor**: if a NEW SKILL.md file lands under `presets/<unknown-preset>/.claude/skills/*/SKILL.md`, CI should at minimum log a warning that the file exists in an unenforced path, so a human reviewer cannot miss it. The recommended form is NOT fail-closed on depth — it is an explicit CI notice that new preset paths are unallowlisted:

```bash
# After the ENFORCED_PRESETS loop:
UNENFORCED_PRESETS=$(for d in presets/*/; do
  p=$(basename "$d")
  if ! echo " $ENFORCED_PRESETS " | grep -q " $p "; then
    echo "$p"
  fi
done)
if [ -n "$UNENFORCED_PRESETS" ]; then
  echo "::notice::Presets not yet under depth enforcement: $UNENFORCED_PRESETS"
  echo "::notice::If this PR adds skills under those paths, they must meet the 9-section template per ADR-015."
fi
```

This is an advisory, not a fail. It surfaces the gap to human reviewers without breaking v1.3.0 rollout.

**Action for @dev Phase 4:**
- Keep `ENFORCED_PRESETS="study"` as specified in ADR-016.
- Add the advisory notice block above to the `skill-depth-check` job after the enforcement loop.
- Keep finding S1 as a WARNING (not CRITICAL) because `skill-format-check` and human PR review are the primary controls; this is a defense-in-depth addition, not a gap closure.

---

### Open Issue 3 — B10 input-file path containment

**Verdict: REQUIRES CHANGE — add explicit `.gitignore` guard in the product repo.**

**Reasoning.** ADR-017 correctly specifies that B10 session files live at `.claude/projects/claude-cowork-config/cycles/v1.3.0/skill-inputs/<skill>.md` — a path INSIDE The-Council worktree (`/home/user/The-Council/.claude/projects/...`), NOT inside the product repo (`/home/user/claude-cowork-config/...`). This is architecturally correct.

The risk: a future orchestrator run (background agent, recovery from crash, misconfigured worktree) could create `.claude/projects/claude-cowork-config/cycles/v1.3.0/skill-inputs/` *inside* the product repo by mistake. The product repo's `.gitignore` does NOT currently exclude `.claude/projects/` or `cycles/`. If that directory is ever created inside the product tree, `git status` will surface the files, and they could be committed accidentally. The contents would be:

- Q3 Worked examples — the spec explicitly says "Don't sanitize — a real, specific example is much more valuable." This is the problem. A user's real study material, real meeting notes, real writing sample, real research synthesis input could include personal names, employer-internal information, course-internal material, or domain-specific content the user would not consent to publishing.
- Q4 Writing voice feel answers — low sensitivity but still personal preference data.
- Q2 Anti-patterns stories — may reference employer or team context.

This is a direct E6-class issue (sensitive user content → committed file tree → public GitHub repo), identical in kind to the v1.2 writing-sample leak vector ADR-013 addressed for `writing-profile.md`.

**Action for @dev Phase 4 (MUST, not optional):**

1. Add to product repo `.gitignore`:
   ```
   # v1.3.0 — B10 user-input session files MUST NOT live in the product repo
   # Canonical path is under The-Council pipeline state; this entry is a belt-and-braces guard
   # in case an orchestrator misconfiguration ever creates the path inside the product tree.
   .claude/projects/
   /cycles/
   skill-inputs/
   ```

2. Add a CONTRIBUTING.md note that B10 input files are pipeline state, never committed to the product repo.

3. Add a Phase 5 @qa check: `git ls-files | grep -E 'skill-inputs/|cycles/v1\.3\.' | wc -l` must equal 0 before any v1.3.0 commit is approved.

Finding S4 (WARNING) tracks this. Escalating to WARNING (not INFO) because Q3 worked examples are specifically instructed to be un-sanitized, so the blast radius of an accidental commit is the full content of the user's real domain work.

---

### Open Issue 4 — B7 `registry-url-check` non-breaking verification

**Verdict: SAFE — confirmed non-breaking at Phase 2.**

**Reasoning.** Grepped every data row in `curated-skills-registry.md`. Result:

- 18 total data rows (6 sections × 3 entries each — Study, Research, Writing, PM, Creative, Business/Admin).
- All 18 rows have `source_url = builtin` (literal).
- 0 rows use `https://github.com/...` URLs.
- 0 rows use any other URL scheme.

B7 regex `^https://github\.com/|^builtin$` matches all 18 rows without exception. Tightening is non-breaking as of 2026-04-17T22:30:00Z. Finding S9 (INFO) documents this verification.

**Residual risk:** between Phase 2 approval and the v1.3.0 Phase 4 commit, a late-landing PR could add a non-GitHub HTTPS entry (e.g., `https://skills.sh/...`, `https://anthropic.com/...`) that the current (pre-B7) `registry-url-check` would accept. @dev MUST re-run the grep immediately before committing B7 to confirm the assumption still holds. If any non-GitHub HTTPS entry has landed, escalate to @architect for reconciliation (either the entry is legitimate and the regex needs widening, or the entry is a policy violation and the PR must be reverted).

**Action for @dev Phase 4:**
- Immediately before B7 commit: run `grep -oE '\| (https?://[^ |]+|builtin) \|' curated-skills-registry.md | sort -u` and confirm output is exactly `| builtin |`.
- If any non-`builtin` value appears, STOP. Escalate to @architect.

---

## CRITICAL

*(None — pipeline not blocked.)*

---

## WARNING

- [ ] **S1 — `skill-depth-check` fail-open design needs an advisory notice for unenforced preset paths.** See Open Issue 2 verdict. Recommendation: add the `UNENFORCED_PRESETS` advisory block to the CI job. Keeps fail-open rollout posture while surfacing new-path risk to PR reviewers. @dev action at Phase 4.

- [ ] **S2 — CONTRIBUTING.md PR checklist must be updated to v1.3.0 before Phase 4 commit.** Current v1.2 checklist has 11 items. v1.3.0 adds:
  - (12) New Study preset skills follow the 9-section template (`## When to use`, `## Triggers`, `## Instructions`, `## Output format`, `## Quality criteria`, `## Anti-patterns`, `## Example`, `## Writing-profile integration`, `## Example prompts`) — reference `templates/skill-template/SKILL.md`.
  - (13) `trigger_examples` YAML field is OPTIONAL for v1.3.0 community skills — `skill-format-check` must not reject skills that omit it.
  - (14) For ANY new skill submission (even outside Study preset): the 9-section template IS the community submission bar. Skills outside depth-enforced presets will still be human-reviewed against the template.
  - (15) Placeholder-authoring rules (per Open Issue 1 verdict, rules 1–5) linked from CONTRIBUTING.md.
  - (16) B10 input files are pipeline state, never committed to product repo.
  - (17) Carry-forward review per B8 — link to `docs/retro-template.md#carry-forward-review`.

  CI backstops (12) partially via `skill-depth-check` for Study; items (14), (15), (16), (17) require human review.

- [ ] **S3 — Negative test fixture exclusion from production CI jobs and release artifacts.** ADR §B7 specifies a negative test fixture in a test-only file `curated-skills-registry.test.md` containing `ftp://NEGATIVE-TEST-FIXTURE-v1.3.0`. This file must be explicitly excluded from:

  1. `registry-cardinality-check` — current job greps `curated-skills-registry.md` (singular, exact filename), so the `.test.md` variant is already excluded *by name*. VERIFIED SAFE.
  2. `link-check` and `link-check-external` (lychee) — current globs are `**/*.md`. The test fixture WOULD be scanned. An `ftp://` URL will fail lychee's URL validation (unreachable), causing CI failure. ACTION: add `curated-skills-registry.test.md` to a lychee exclusion list via a `.lycheeignore` file or an explicit `--exclude` arg in the workflow.
  3. `markdown-lint` — the fixture's ftp URL could trip markdownlint rules. ACTION: add `.markdownlint.jsonc` ignore entry for `curated-skills-registry.test.md`.
  4. Release ZIP — the v1.3.0 Release artifact should NOT contain test fixtures. ACTION: if `.gitattributes` or release workflow filters files, add `curated-skills-registry.test.md export-ignore`.

  Alternative that avoids most of the above: inline the negative test using a `here-doc` in the CI step itself, with no committed test fixture file. This is the approach originally considered and rejected in ADR-016 for `skill-depth-check` ("adds complexity"). Re-evaluate for B7 specifically — the simpler path may be an inline `printf "...\n...\n| ftp://NEGATIVE-TEST-FIXTURE-v1.3.0 |" | bash check_logic` rather than a committed file. @dev decision at Phase 4.

- [ ] **S4 — `.gitignore` must block `.claude/projects/`, `/cycles/`, and `skill-inputs/` in the product repo.** See Open Issue 3 verdict. Mandatory. Q3 worked examples are explicitly un-sanitized per ADR-017 — committing them would expose user's real domain content publicly.

---

## INFO

- **S5 — Template placeholder text injection risk: mitigated by authoring rules.** See Open Issue 1 verdict. The 5 placeholder-authoring rules must be documented in both CONTRIBUTING.md and as inline comments in the template file itself. Low residual risk once rules are in place.

- **S6 — `trigger_examples` YAML field is a new machine-readable trigger surface.** ADR-015 introduces `trigger_examples` as an optional frontmatter list (3–6 strings). Architecture notes (anti-pattern scan #6) that proactive-rule tooling consumes this field as "the machine-readable source of truth" for triggers, without parsing the `## Triggers` markdown body. Risk: a Tier 2 community skill could set `trigger_examples: ["delete all files", "rm -rf", "format my disk"]` — trigger phrases that, if the user happens to type them in an unrelated context, auto-fire the skill. No current v1.3.0 tooling consumes this field (proactive-rule tooling is Phase 4 scope in global-instructions.md), so the risk is latent. Mitigation already present: Tier 2 opt-in gating (ADR-012) and keyword-scan of SKILL.md body (which catches `rm`, `delete` — so a malicious `trigger_examples` containing these strings would be visible in the Tier 2 opt-in warning). INFO-level because (a) Tier 1 builtin entries don't use community-sourced `trigger_examples`, (b) Tier 2 opt-in already warns users about unverified skills, (c) the field is optional and v1.3.0 Study skills author it from the user's own Q5 answers.

- **S7 — Writing-profile integration section logging sanity check.** ADR-015 §8 mandates every skill include a "Writing-profile integration" section describing when it consults `context/writing-profile.md`. @dev draft for flashcard-generation, note-taking, research-synthesis must NOT include example outputs that echo writing-profile contents (e.g., "Tone: professional; Vocabulary: technical" pattern strings). No current telemetry or logging hooks exist in the repo (verified — the repo has zero runtime code, no analytics, no external network calls). Forward-looking guard: if any future cycle adds telemetry, writing-profile content must be on the exclusion list alongside the existing `security-review.md`, `scratchpad.md`, `risk-register.md` list in `docs/integrations-setup.md`.

- **S8 — README B9 teaser links sanity check.** B9 adds `## Next up — v1.3.0 Preset Skills Depth` section linking to GitHub Milestone #1 and pinned Issue #2. Both are world-readable. Confirmed by reading the proposed body (ADR-015 §B9): the teaser text contains no mention of specific CVEs, unreleased security fixes, or internal vulnerability details. It references architectural scope (9-section template, Study pilot) only. No leak risk. INFO for posterity.

- **S9 — B7 tightening is non-breaking: all 18 entries verified as `builtin`.** See Open Issue 4 verdict. Confirmed at 2026-04-17T22:30:00Z. @dev must re-verify immediately before B7 commit.

---

### OWASP Top 10 Assessment (Adapted for Static Template Repository + LLM System Context)

| Category | Status | Notes |
|----------|--------|-------|
| A01:2021 — Broken Access Control | N/A | No access control system. Template files only. |
| A02:2021 — Cryptographic Failures | N/A | No secrets, no credentials. (Verified: repo scan for API key / token patterns returned 0 hits across new ADRs, workflow, and template plan.) |
| A03:2021 — Injection | WATCHED | S5 (placeholder text), S6 (trigger_examples field) — both INFO. Core design (filled-in community skill passing through 4+ review layers) keeps this surface well-gated. |
| A04:2021 — Insecure Design | PASS WITH S1-S4 | Fail-open CI design (S1) is a deliberate rollout trade-off per ADR-016 — the mitigation advisory strengthens defense-in-depth without breaking the rollout. |
| A05:2021 — Authentication Failures | N/A | No auth. |
| A06:2021 — Sensitive Data Exposure | WATCHED | S4 (B10 input files containment) is the primary finding. Q3 worked examples are explicitly un-sanitized; `.gitignore` must block them. |
| A07:2021 — Identification & Authentication Failures | N/A | No auth. |
| A08:2021 — Software & Data Integrity Failures | STRENGTHENED | B7 tightens registry URL integrity (`^https://github\.com/|^builtin$`) — reduces surface vs. v1.2. SHA-pinned CI actions maintained (18/18). |
| A09:2021 — Security Logging & Monitoring Failures | N/A | No runtime. |
| A10:2021 — Server-Side Request Forgery | N/A | No server, no HTTP runtime. Tier 2 discovery is human paste-and-review. |

### OWASP LLM Top 10 Assessment

| Category | Status | Notes |
|----------|--------|-------|
| LLM01 — Prompt Injection | ELEVATED WATCHED | Carry from v1.2 (CLAUDE.md universal entry). v1.3.0 adds `templates/skill-template/SKILL.md` but this is a contributor-copy surface, not a runtime surface — no blast radius increase. S5 placeholder-authoring rules are the mitigation. |
| LLM02 — Insecure Output Handling | LOW RISK | Wizard output remains local-file only. B10 input files are pipeline state only — must not reach product repo (S4). |
| LLM06 — Sensitive Information Disclosure | ELEVATED BY B10 | Q3 worked examples explicitly un-sanitized per ADR-017. This is a new class-of-risk in v1.3.0 — directly addressed by S4 `.gitignore` guard. Comparable in kind to v1.2 E6 writing-sample risk; comparable mitigation (storage containment + human review). |

### Additional v1.3.0 Surface Assessment

| Surface | Status | Notes |
|---------|--------|-------|
| `templates/skill-template/SKILL.md` (contributor-copy surface) | PASS WITH S5 | Not a runtime surface. Injection risk limited to contributor sloppiness shipping unedited placeholders. 5 placeholder-authoring rules close this. |
| `skill-depth-check` CI (fail-open by design) | PASS WITH S1 | Intended trade-off per ADR-016. Advisory notice for unenforced preset paths strengthens without breaking rollout. |
| `trigger_examples` YAML frontmatter field (new machine-readable trigger surface) | WATCHED (S6) | Latent risk — no v1.3.0 tooling consumes this field yet. Tier 2 opt-in + keyword-scan keeps risk low. Re-evaluate when proactive-rule tooling consumes the field. |
| B10 input file path containment | PASS WITH S4 | Architecturally correct (pipeline state only). `.gitignore` guard is the operational control. MUST land at Phase 4. |
| B7 `registry-url-check` tightening | PASS | Non-breaking (18/18 `builtin`). Strengthens A08 integrity posture vs. v1.2. |
| B7 negative test fixture (`curated-skills-registry.test.md` with `ftp://NEGATIVE-TEST-FIXTURE-v1.3.0`) | PASS WITH S3 | Fixture is architecturally sound but must be excluded from lychee, markdownlint, and release ZIP. @dev decision: keep file vs. inline. |
| B9 README teaser (Milestone #1, Issue #2 world-readable) | PASS | No unreleased security fix leak (S8 verified). |
| B8 retro-template carry-forward workflow | PASS | Process doc only. No security surface — resolves v1.2 process gap. |
| Safety rule defense-in-depth (5 layers from v1.2) | PASS | No regression. `safety-rule-check`, `starter-safety-rule-check`, `claude-md-safety-rule-check` all unchanged. |
| CI action SHA-pinning | PASS | All 14 existing jobs remain SHA-pinned (verified: `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683`, `markdownlint-cli2-action@05f32210...`, `lychee-action@f613c4a...`, `action-shellcheck@00cae500...`). New `skill-depth-check` job must also SHA-pin (already specified in ADR-016 code). |

### Carry-Forward Confirmations from v1.2

| Phase 6 Finding | v1.2 Status | v1.3.0 Disposition |
|-----------------|-------------|---------------------|
| A1 (registry-cardinality-check logic bug) | Fixed in v1.2 rework (sha:6f8f692) | Resolved — no action needed. |
| A2 (registry-url-check URL scheme gap) | Carry-forward MEDIUM | RESOLVED by B7 (this cycle). Verified non-breaking. |
| A3 (CLAUDE.md 385 words vs ≤350 target) | Carry-forward LOW | Deferred per v1.3.0 spec §"Out of Scope" — within ≤400 hard cap. Not a security finding this cycle. |

---

### Summary

v1.3.0 is an incremental depth cycle — no new runtime surfaces, no new auth, no new external API calls, no new user-data paths exposed to the product repo. The architecture correctly identifies B10 pipeline-state containment as its highest-risk new surface, and the ADR correctly places input files OUTSIDE the product repo. The `.gitignore` guard (S4) is the belt-and-braces control that converts the architectural correctness into an operational guarantee.

Of the 4 Phase-1 open issues:
- **Issue 1 (template as injection vector):** NEEDS-POLICY — 5 placeholder-authoring rules must be documented. SAFE with rules in place.
- **Issue 2 (fail-open CI):** REQUIRES CHANGE — add advisory notice for unenforced preset paths. Rollout posture preserved.
- **Issue 3 (B10 path containment):** REQUIRES CHANGE — `.gitignore` guard is mandatory. Q3 worked examples are explicitly un-sanitized.
- **Issue 4 (B7 non-breaking):** SAFE — 18/18 entries use `builtin`, verified.

B7 tightening strengthens the v1.2 A08 integrity posture and resolves the v1.2 MEDIUM carry-forward (A2). B8 closes the v1.2 retro process gap. B9 adds zero security surface. No CRITICAL findings.

The WARNINGs are all addressable at Phase 4 implementation time. S4 (`.gitignore`) and S3 (negative-test-fixture exclusions) are the two must-fix items that most concretely map to user-safety outcomes. S1 and S2 are defense-in-depth strengthening.

**Decision: PASS WITH WARNINGS.**

---

## Phase 2 History

### v1.0 Review (2026-04-15T06:45:00Z)
See original findings above (S1–S6). All v1.0 WARNINGs resolved in Phase 4. Full v1.0 review archived in git history.

### v1.1 Review (2026-04-15T22:00:00Z)
PASS WITH WARNINGS. S1 (CONTRIBUTING.md v1.1 update), S2 (CI .txt glob fix). Both resolved in Phase 4. Full v1.1 review archived in git history.

### v1.2 Review (2026-04-17T13:00:00Z)
4 WARNINGs (S1–S4), 4 INFOs (S5–S8). No CRITICALs. Full v1.2 review archived in git history.

### v1.3.0 Review (this document — 2026-04-17T22:30:00Z)
4 WARNINGs (S1–S4), 5 INFOs (S5–S9). No CRITICALs. Four Phase-1 open issues resolved: 2 SAFE, 2 REQUIRES CHANGE (S1/S4 in findings list), 1 NEEDS-POLICY (placeholder-authoring rules — tracked under S5).

---

# Security Audit — cowork-starter-kit v1.3.0 (Phase 6)

## Phase: 6
## Date: 2026-04-18T11:30:00Z
## Status: PASS
## Classification: STANDARD (independently verified — see Classification Decision below)

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|

*(Zero findings — table header only)*

---

## Phase 2 Carry-Forward Resolution

| ID | Phase 2 Surface | Claimed resolution commit | Verification | Verdict |
|----|-----------------|---------------------------|--------------|---------|
| S1 | skill-depth-check fail-open advisory | a7dbd3d | `.github/workflows/quality.yml` ships a 2nd step `Advisory notice for unenforced presets` that loops over every `presets/*/` and emits `::notice::` for any preset not in `ENFORCED_PRESETS="study"` | RESOLVED |
| S2 | CONTRIBUTING.md v1.3 checklist + 5 placeholder-authoring rules | 033e0ff | CONTRIBUTING.md has checklist items 12–17 (9-section template, ≥60 lines, `trigger_examples` 3–6 range, placeholder rules, B10 path containment, retro carry-forward review) + full §Placeholder authoring rules block (5 rules) | RESOLVED |
| S3 | B7 negative test actually rejects non-github URLs | a7dbd3d | `registry-url-check` job body runs a self-test BEFORE production scan: inline fixture `ftp://NEGATIVE-TEST-FIXTURE-v1.3.0`, allowlist regex extracts; if any URL extracted, CI fails with "SELF-TEST FAILED". Verified in workflow lines 225–237. The regex `(?<=\| )(https?://[^\s│]+│builtin)(?= \│)` requires github.com; ftp:// is outside https? allowlist and correctly ignored. | RESOLVED |
| S4 | .gitignore guard for pipeline-state paths (MANDATORY) | 033e0ff | `.gitignore` contains `.claude/projects/`, `cycles/v1.3.*/`, `skill-inputs/`. Verification: `git ls-files │ grep -E 'skill-inputs/│cycles/v1\.3\.' │ wc -l` = **0** | RESOLVED |

**All 4 Phase 2 WARNINGs confirmed resolved.**

---

## v1.3.0 Attack-Surface Audit (Fresh Evaluation)

### 1. Three rewritten Study skills — indirect prompt-injection vector

**Scope:** `presets/study/.claude/skills/{flashcard-generation,note-taking,research-synthesis}/SKILL.md` (124/124/125 lines each).

**Forbidden-token scan** (`Ignore|Disregard|Override|Instead|Always` outside HTML comments and code fences):

| Skill | Hits | Disposition |
|-------|------|-------------|
| flashcard-generation | 0 | Clean |
| note-taking | 1 — "**Cues column (Cornell):** Always terse" | Benign: descriptive prose about cue style in Writing-profile integration section; not an imperative to Cowork. "Always" is an English adverb modifying "terse", not a directive. |
| research-synthesis | 1 — "**Matrix cells:** Always terse" | Benign: same pattern as above. Descriptive, not imperative. |
| templates/skill-template | 0 | Clean |
| skills-as-prompts.md | 0 | Clean |

**Jailbreak / role-manipulation tokens** (`SYSTEM:`, `ADMIN:`, `USER:`, `<|...|>`, `jailbreak`, `pretend you`, `you are now`, `roleplay as`, `forget all previous`, `new instructions:`): **0 hits across all 5 surfaces.**

**Verdict:** No injection vectors introduced. The two "Always terse" hits are descriptive modifiers inside a sub-section about cues/cells style and do not function as runtime directives.

### 2. `templates/skill-template/SKILL.md` — placeholder-authoring rules 1–5 compliance

- **Rule 1 (bracketed nouns, not imperatives):** Placeholders use `[skill-slug]`, `[action description]`, `[Field 1 label]`, etc. — all nominal. No `[Do X]` or `[Tell Cowork]` patterns found.
- **Rule 2 (no forbidden words):** Zero occurrences of Ignore/Disregard/Override/Instead/Always in placeholder text.
- **Rule 3 (HTML comments for guidance):** All contributor guidance is inside `<!-- -->` blocks (9 block comments, one per section). A `CONTRIBUTOR NOTICE` banner at top reinforces the rules.
- **Rule 4 (no safety-rule pattern):** Zero matches for confirm/ask-for-confirmation/delete/overwrite/move in placeholder text.
- **Rule 5 (Example placeholders read as contributor guidance):** `## Example` placeholder text says "Paste a real input here" and "Paste the ideal output here — the response Cowork should produce" — correctly framed as contributor instructions, not as runtime-readable content.

**Verdict:** Template is fully compliant with the 5 authoring rules.

### 3. `skills-as-prompts.md` regenerated — LLM prompt-surface

- 163 lines, 3 skill blocks mirroring the SKILL.md content.
- Zero forbidden tokens outside code fences. Zero role-manipulation tokens.
- Output is framed as user-facing ("Use this file if skill upload is not available") and the instruction voice is addressed to Cowork via a copy-paste wrapper — the wrapper message itself is safe boilerplate.
- `[[wikilinks]]` and `[TAB]` references are Anki/Obsidian syntax tokens, not markdown placeholders, and are correctly wrapped in code fences or explained inline.

**Verdict:** No injection tokens. Regenerated file is derivative of safe source content.

### 4. Q3 worked examples — biology/mitochondria, psychology/working-memory

- **flashcard-generation `## Example`:** Mitochondria biology passage + 6 sample cards. Pure domain content. No system-manipulation patterns, no social-engineering framing.
- **note-taking `## Example`:** Baddeley & Hitch working-memory model passage + Cornell-format notes output. Pure domain content.
- **research-synthesis `## Example`:** 3 abstracts (Miller 1956, Baddeley 2000, Cowan 2001) + full synthesis matrix. Pure domain content.

**Verdict:** Worked examples are legitimate educational content. No instruction patterns masquerading as example content.

### 5. B10 input-file containment

- `git ls-files | grep -E 'skill-inputs/|cycles/v1\.3\.' | wc -l` = **0** ✓
- `.gitignore` entries verified: `.claude/projects/`, `cycles/v1.3.*/`, `skill-inputs/` (033e0ff).
- B10 pipeline state confirmed to live at `/home/user/The-Council/.claude/projects/claude-cowork-config/cycles/v1.3.0/skill-inputs/` — outside the product repo entirely.

**Verdict:** S4 Phase 2 WARNING fully resolved. Pipeline-state containment is architecturally clean and operationally guarded.

### 6. `curated-skills-registry.md` description refresh (be458cf)

- 18 data rows (matches registry-cardinality-check floor). Integrity intact.
- All `source_url` values = `builtin` (18/18). Zero URLs pointing to external schemes. No URL drift from v1.2 → v1.3.0.
- 3 Study-skill descriptions updated verbatim from the new SKILL.md frontmatter `description:` fields (verified line-for-line match).
- `registry-url-check` CI job will reject any future `http://`, `ftp://`, relative, or non-github HTTPS URL; negative self-test runs first.

**Verdict:** No URL drift, no new schemes, registry scheme invariant preserved.

### 7. `trigger_examples` YAML field — new machine-readable surface

- 3 skills use `trigger_examples`: flashcard-generation (5), note-taking (4), research-synthesis (4) — all within the 3–6 range mandated by CONTRIBUTING.md item 14.
- Values are short user-voice phrases (e.g. `"Help me study [topic]"`) — bracketed tokens here are display placeholders users see in documentation, not LLM-runtime injection targets. Each phrase is a YAML string literal that gets consumed by pattern-matching in global-instructions.md, not executed.
- Field is additive and backward-compatible. No new attack vector vs. the v1.2 `## Triggers` section body.
- Re-evaluation of v1.2 S6 INFO: risk remains LOW. The field is declarative trigger metadata, not runtime behavior.

**Verdict:** No new attack vector. v1.2 S6 remains INFO with no elevation required.

### 8. CI workflow drift

- `skill-depth-check`: `ENFORCED_PRESETS="study"` — correctly scoped to study only at v1.3.0. Advisory notice emits for the other 5 presets. Future widening is documented in a code comment. ✓
- `registry-url-check`: Fail-closed on non-github HTTPS. Negative self-test present. ✓
- `safety-rule-check`, `starter-safety-rule-check`, `claude-md-safety-rule-check`: All three still active and unchanged. ✓
- All GitHub Actions pinned to full SHA (S2 preserved from v1.0): `actions/checkout@11bd71901bbe`, `markdownlint-cli2-action@05f32210e844`, `lychee-action@f613c4a64e50`, `action-shellcheck@00cae500b08a`. ✓

**Verdict:** CI drift is intentional, safety-preserving, and well-scoped. No regression in enforcement posture.

### 9. Anti-pattern residue scan — placeholder leakage into final content

- `[topic]`, `[source]`, `[X]`, `[Y]`, `[author]` tokens found in skills: ALL are inside trigger-phrase examples (e.g. `"Help me study [topic]"` — user-facing explanatory content, not unfilled authoring placeholders). Verified by inspection.
- No `[one sentence describing what this skill does]` or similar template-internal placeholder strings leaked.
- `[[wikilinks]]` occurrences are Obsidian syntax references the skills explicitly tell Cowork NOT to produce — correct guidance, not a leak.

**Verdict:** No placeholder leakage. Bracket usage is intentional and user-facing.

### 10. Secret / credential scan

- `grep -rE '(ghp_|sk-[A-Za-z0-9]{20,}|AKIA…|xox[pb]-|password\s*=|api[_-]?key\s*=)'` — **0 hits.**
- No `package.json` — zero npm dependency surface. `npm audit` not applicable.

**Verdict:** No secrets, no dependency-CVE exposure.

---

## OWASP Top 10 Assessment

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | N/A | No auth surface. Product is static markdown artifacts delivered to end users. |
| A02 Cryptographic Failures | N/A | No data at rest, no transport crypto in product surface. |
| A03 Injection | PASS | Prompt-injection scan (forbidden tokens, role-manipulation tokens) across all 5 new surfaces = 0 hits. The 2 benign "Always terse" matches are descriptive prose, not directives. |
| A04 Insecure Design | PASS | Skill-template placeholder-authoring rules (5) address known LLM content-authoring failure modes. B10 path containment is architecturally correct and operationally enforced via `.gitignore`. |
| A05 Security Misconfiguration | PASS | CI actions SHA-pinned (S2 preserved). `registry-url-check` fail-closed with negative self-test. `skill-depth-check` scoped-and-advisory per S1 resolution. |
| A06 Vulnerable & Outdated Components | N/A | No package.json, no dependency surface. CI action SHAs current as of v1.0 pinning. |
| A07 Identification & Authentication Failures | N/A | No authentication surface. |
| A08 Software & Data Integrity Failures | PASS | `registry-url-check` (B7, strengthened this cycle) + `registry-cardinality-check` + `safety-rule-check` (across presets/global-instructions.md + starter .txt + CLAUDE.md) provide defense-in-depth on content integrity. |
| A09 Security Logging & Monitoring | N/A | Product is offline artifact delivery. CI logs are the only monitoring surface. |
| A10 SSRF | N/A | No server-side request surface. |

---

## LLM Threat Assessment (LLM01/02/06)

| Threat | Status | Notes |
|--------|--------|-------|
| LLM01 Prompt Injection | PASS | Direct: N/A (no user-input handling by the product itself). Indirect: 3 rewritten skills + template + regenerated skills-as-prompts.md scanned for forbidden tokens, jailbreak/role-manipulation tokens, safety-rule-pattern leakage. All clean. Worked examples are domain-pure. |
| LLM02 Insecure Output Handling | PASS | Skill outputs are documented (markdown tables, TSV blocks, Cornell notes) — no executable code emission, no dynamic evaluation. Anki TSV is pasted into an offline app; no server-side handling. |
| LLM06 Sensitive Info Disclosure | PASS | No credentials, no PII, no user data in the product repo. B10 user-input files are architecturally outside the repo and verified via `git ls-files` (0 matches). |

---

## Classification Decision

**QA signal:** STANDARD.
**Independent verification:** STANDARD confirmed.

**Rationale:**
- v1.3.0 modifies instruction-surface depth (3 skills: stub → ~124 lines each) and adds one template + one .gitignore entry + CI advisory notice. No new auth surface, no new external data flows, no CLAUDE.md changes, no RLS changes (N/A — no database), no dependency additions.
- v1.2 was classified SECURITY-SENSITIVE because it rewrote CLAUDE.md (wizard entry-point surface), added the universal wizard architecture (ADR-010/011), and introduced `curated-skills-registry.md` from scratch. Those were new architectural surfaces at the LLM-bootstrap layer.
- v1.3.0 adds DEPTH to existing, already-vetted surfaces (study preset skills). The new template codifies patterns already established by the v1.2 skills-as-prompts.md format. This is incremental content expansion along an established pattern, not a new runtime/attack surface.
- The STANDARD abbreviated check (no new auth, no secrets, no vulnerable deps, no RLS changes) all pass. Despite passing the abbreviated gate, a full OWASP + LLM threat audit was performed for defense-in-depth because instruction-surface content IS the attack surface for this product. No escalation required.

**Combined-path: eligible** — zero findings + all abbreviated-check criteria satisfied + full OWASP audit performed as a defense-in-depth overlay.

---

## Summary

v1.3.0 is a clean Phase 6 audit. All 4 Phase 2 WARNINGs (S1 advisory notice, S2 CONTRIBUTING.md v1.3 checklist + placeholder rules, S3 B7 negative self-test, S4 `.gitignore` guard) are confirmed resolved in commits a7dbd3d / 033e0ff. The `.gitignore` guard effectiveness check (`git ls-files | grep -E 'skill-inputs/|cycles/v1\.3\.'`) returns 0 matches — the MANDATORY S4 control is operational.

The 7 new/refreshed attack surfaces (3 rewritten skills, skill template, regenerated skills-as-prompts.md, Q3 worked examples, B10 inputs, registry refresh, `trigger_examples` field) all pass forbidden-token scans, placeholder-authoring rule checks, and URL allowlist checks. The 2 "Always terse" matches in note-taking and research-synthesis are benign English adverbs modifying descriptive nouns — not runtime directives.

Classification STANDARD is independently confirmed. Despite the abbreviated-check eligibility, a full OWASP + LLM threat audit was performed; all categories PASS or N/A.

**Decision: PASS — 0 CRITICAL, 0 WARNING, 0 INFO.**

Surprising-or-note-worthy findings: none. The B1→B2→B3/B4a/B4b→B5→B6 implementation sequence held the discipline defined in Phase 1 (ADR-015 / ADR-016 / ADR-017). The inline B7 negative self-test is a particularly strong control — it guarantees the allowlist regex tightening actually rejects what it claims to reject, every CI run.
