# Skills as Prompts — Research Preset

Use this file if skill upload is not available. Copy the skill content below and paste it at the start of your message to Cowork:

"Using this approach: [paste skill content] — now help me with [your task]."

---

## Literature Review

**When to use:** Use this skill when you supply multiple sources — papers, abstracts, excerpts, or articles — and need a structured thematic review rather than a flat summary or per-source analysis. Literature review is thematic by definition: it organizes the source set by concept or argument, not by publication date. Also use it when you need a review-style document for a paper, thesis, or survey chapter. If you need a per-source authority evaluation, prefer source-analysis. If you need peer-review-rigor synthesis with authority and citation-network columns, prefer research-synthesis.

**Triggers:** Invoke when the user says "Write a literature review on [X]" or "Give me a lit review of these papers" — highest-confidence direct invocation. Proactively offer when the user pastes 3 or more abstracts, excerpts, or papers with no specific ask. Offer literature review as the primary deliverable when the user says "I'm writing a survey on [X]" or "I need to cover the field of [Y]." Offer with expanded gap analysis when the user says "I need the lit review chapter for [Z]" in a thesis or dissertation context.

**Instructions:**

1. Read all provided sources fully before detecting themes.
2. Auto-detect themes from the source set — do not impose themes from outside the sources. A theme is a concept or argument that at least two sources address.
3. State the detected theme count and source count in one line at the top of the output (e.g., "**Themes detected:** 3 (Capacity, Components, Evolution). **Sources:** 3.") so the user can recalibrate.
4. Build the thematic matrix: rows = themes, columns = sources. Each cell describes how that source addresses the theme, in terse noun phrases. Write "—" if absent.
5. For each theme, write a thematic synthesis paragraph comparing how sources treat the theme — do not summarize sources in sequence.
6. Write the `## Research Gaps` section: list 2–5 gaps, each with a bold gap name and a short explanatory clause.
7. Distinguish primary, secondary, and tertiary sources where relevant.
8. Note methodological differences in the matrix cell or synthesis where sources use incompatible designs.
9. Apply the writing-profile rule to synthesis paragraphs and gap clauses.
10. Apply the BibTeX extension if the user has supplied citation keys or `.bib` entries.

**Output format:** Plain GitHub-flavored markdown. Required header line: theme count, theme names, source count. Thematic matrix: markdown table — rows = themes, columns = sources, cells terse. Thematic synthesis: one subsection per theme (prose paragraph). `## Research Gaps` section: bullet list of 2–5 gaps. BibTeX-aware: use `@key` column headers and `[@key]` inline citations if user provides keys; otherwise `Author (Year)`. No Obsidian `[[wikilinks]]`, no JSON/YAML sidecar.

**Quality criteria:**
- Themes auto-detected from the source set; count and source count stated at top.
- Every matrix cell traces back to a specific source passage — no hallucinated claims.
- Thematic synthesis produces cross-source comparison, not per-source summary.
- Primary, secondary, and tertiary sources are distinguished.
- Methodology assessment present where sources use incompatible designs.
- `## Research Gaps` section lists 2–5 gaps with explanatory clauses.
- Matrix cells terse; synthesis prose and gap clauses adapt to writing-profile.md.

**Anti-patterns to avoid:**
- Chronological-only ordering — literature review is thematic by definition.
- No cross-source thematic synthesis — theme rows must compare, not list.
- No research gap identification — a literature review without gaps is a summary.
- Treating review papers as primary sources — meta-reviews must be labeled tertiary.
- Citation drift — synthesis claim cannot be traced to a specific source column.
- No methodology assessment across sources with incompatible designs.
- Listing sources without critical evaluation — descriptive paraphrases only.

**Writing-profile integration:** Four-tier rule. Matrix cells: always terse — no writing profile consulted. Theme + source count line: profile-neutral factual statement. Thematic synthesis paragraphs: full writing-profile consultation (tone, sentence-length, pet peeves). Research Gaps bullets: adapt writing profile to the explanatory clause after the bold gap name; gap name stays terse.

**Example prompts:**

- "Conduct a literature review on cognitive load theory using the papers in my Literature/ folder."
- "Organize these 5 papers into themes for a literature review section."
- "What gaps exist in the literature on attention and working memory based on my sources?"
- "I need the lit review chapter for my thesis on [topic] — start with these abstracts."

---

## Source Analysis

**When to use:** Use this skill when you have a single source — a paper, article, book chapter, or preprint — and need a structured evaluation of its credibility, authority, and citability. Source analysis produces a judgment, not a summary. The key question is "Can I cite this? For what kinds of claims? With what caveats?" If you share multiple sources and want comparison, prefer literature review or research synthesis.

**Triggers:** Invoke when the user says "Evaluate / critique / analyze this paper" or "How good is this source?" — highest-confidence direct invocation. Proactively offer when the user pastes a single paper abstract or excerpt with no specific ask. Offer with citation-recommendation framing when the user asks "Can I cite this?" or "Is this source any good?" Offer with Bottom line tuned to the specific claim when the user says "I'm thinking of citing [X] for [claim]."

**Instructions:**

1. Read the provided source fully before beginning the evaluation.
2. State the source type at the top (Primary / Secondary / Tertiary) with a one-sentence justification so the user can recalibrate citation strategy.
3. Complete all 7 fields in order. Do not skip any field.
4. **Source type** — Primary (original empirical data or argument), Secondary (review or commentary on primary), or Tertiary (meta-review, encyclopedia, textbook). Justify in one sentence.
5. **Authority** — author credentials, institutional affiliation, track record, and domain fit.
6. **Methodology** — study design, sample, and measures. Assess whether the method is appropriate for the main claim.
7. **Evidence quality** — strength of evidence, convergence with other studies, replication status.
8. **Limitations** — distinguish what the author acknowledges and what the author omits.
9. **Bias assessment** — funding, ideological framing, methodological narrowness. State level explicitly (low / moderate / high) with reasoning.
10. **Bottom line** — narrative judgment paragraph: can this source be cited? for what? with what caveats? Apply writing-profile to this paragraph.
11. Apply the BibTeX extension if the user supplies citation keys.

**Output format:** Plain markdown. Source type declaration at top: `**Source type:** [type] — one-sentence justification.` Seven fields as bold-label lines with field content. Fields 1–6: typically 1–3 sentences each. Bottom line: standalone paragraph (≥100 words typical) with citation recommendation. No tables by default. No Obsidian `[[wikilinks]]`, no JSON/YAML.

**Quality criteria:**
- Source type stated at top with one-sentence justification.
- All 7 fields populated — none skipped without explanation.
- Authority field addresses credentials, domain fit, and track record.
- Methodology field describes design, sample, and measures.
- Limitations distinguishes author-acknowledged from author-omitted.
- Bias assessment is explicit (low/moderate/high) with reasoning.
- Bottom line delivers a citation recommendation with caveats.

**Anti-patterns to avoid:**
- Summarizing instead of evaluating — a good summary is not source analysis.
- Accepting the author's framing uncritically — surface what the author is not saying.
- Ignoring methodology — a 30-subject pilot and a 3000-subject RCT are not equivalent.
- No authority assessment when the author is writing outside their field.
- No limitations surfaced — every source has limitations.
- Conflating primary with secondary — a review paper's claim is not original evidence.
- No bottom-line judgment — analysis must end with a citation recommendation.

**Writing-profile integration:** Two-tier rule. Fields 1–6: structured judgment — terse, no writing profile consulted. Bottom line: full writing-profile consultation — tone, sentence-length, pet peeves apply.

**Example prompts:**

- "Analyze this paper: [paste abstract or filename]."
- "Is this source credible and relevant to my research on [topic]?"
- "Can I cite this for my claim about [X]?"
- "What are the methodological strengths and limitations of this study?"

---

## Research Synthesis

**When to use:** Use this skill when you need a rigorous multi-source synthesis at peer-review standards — where source authority, citation networks, and methodology comparisons matter as much as the substantive claims. This skill always operates at peer-review rigor regardless of source count.

This is the Research preset variant, intentionally distinct from the Study preset's `research-synthesis` (which auto-selects a simplified mode by source count for exam-prep use). Use this skill when the output will inform a paper, thesis, systematic review, or peer-review process. If you need a thematic review with gap analysis rather than per-source authority evaluation, prefer literature-review instead.

**Triggers:** Invoke when the user says "Synthesize these papers rigorously" or "Cross-reference these sources at peer-review rigor" — direct invocation. Offer with disagreement-surfacing emphasis when the user says "I'm preparing to review / referee [paper]." Offer full matrix + gap analysis when the user asks for a "systematic review of [X]." Offer as qualitative prelude when the user asks for "meta-analysis inputs for [Z]" — surface methodology compatibility explicitly.

**Instructions:**

1. Read all provided sources fully before beginning the matrix.
2. State the synthesis mode at the top in one line: "Peer-review synthesis, N sources."
3. Build the 7-column matrix: rows = sources, columns = Claim | Method | Evidence | Limitations | Authority | Recency | Citation network. Cells terse.
4. Complete each column for every source. Claim: central thesis or finding. Method: study design + sample. Evidence: strength + convergence. Limitations: most significant limitation for citation use. Authority: credentials + citation weight + domain fit. Recency: publication date + replication status. Citation network: foundational node or citation chain.
5. Write four synthesis subsections in order: **Agreements**, **Disagreements**, **Gaps**, **Synthesis**.
6. Agreements: where sources converge, and whether convergence is independent or a citation chain. Disagreements: methodological divergences, conflicting findings, competing frames — name them explicitly. Gaps: topical and methodological gaps. Synthesis: closing paragraph integrating the full picture.
7. Verify every synthesis claim traces to at least one named matrix row — no citation drift.
8. Apply the writing-profile rule to synthesis prose.
9. Apply the BibTeX extension if the user has supplied citation keys.

**Output format:** Plain markdown. Mode line at top: "Peer-review synthesis, N sources." 7-column markdown table (rows = sources). Four synthesis subsections: `### Agreements`, `### Disagreements`, `### Gaps`, `### Synthesis`. Prose in each subsection, not bullets. BibTeX-aware: use `@key` in Source column and `[@key]` inline if user provides keys. No Obsidian `[[wikilinks]]`, no JSON/YAML.

**Quality criteria:**
- Mode line states "Peer-review synthesis, N sources" at top.
- All 7 matrix columns populated for every source.
- Authority column addresses credentials, domain fit, and citation weight.
- Citation-network column distinguishes independent replication from citation chain.
- All four synthesis sections present (Agreements, Disagreements, Gaps, Synthesis).
- Disagreements section names divergent programs or conflicting findings explicitly.
- Every synthesis claim traces to at least one matrix cell — no citation drift.

**Anti-patterns to avoid:**
- Equal-authority treatment — a dissertation and a Nobel laureate's RCT are not equivalent.
- No citation-network analysis — apparent convergence across sources citing one foundational paper is a chain.
- Ignoring publication venue rigor — a conference poster and a *Nature* paper are not equivalent.
- No methodology comparison — empirical, theoretical, and simulation studies produce different evidence types.
- Citation drift — synthesis claims not traceable to matrix cells.
- Recency bias — newer sources do not automatically supersede older ones.
- Synthesis = concatenation — restating each source in sequence instead of producing cross-source insight.

**Writing-profile integration:** Four-tier rule. Matrix cells: always terse — no writing profile consulted. Mode line: profile-neutral. Agreements / Disagreements / Gaps paragraphs: full writing-profile consultation. Disagreement framing sentences: profile-neutral — clarity takes precedence over voice. Closing Synthesis paragraph: full writing-profile consultation.

**Example prompts:**

- "Synthesize these papers on protein folding at peer-review rigor."
- "I'm preparing to referee this paper — can you cross-reference its sources?"
- "Give me a systematic review of the evidence on [topic] from my Literature/ folder."
- "I need meta-analysis inputs on [topic] — synthesize these sources qualitatively first."
