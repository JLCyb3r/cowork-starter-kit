# Skills as Prompts — Study Preset

Use this file if skill upload is not available. Copy the skill content below and paste it at the start of your message to Cowork:

"Using this approach: [paste skill content] — now help me with [your task]."

---

## Flashcard Generation

**When to use:** Use this skill when you ask for flashcards from provided source material for study or recall practice. Also use it when you share study material under exam or deadline pressure and need retrieval practice. If you need conceptual understanding rather than recall, prefer summary-synthesis over flashcard generation.

**Triggers:** Invoke when the user says "Make flashcards" or "Give me flashcards" with an explicit file or topic reference — highest-confidence direct invocation. Also when the user says "Help me study [topic]" or "Help me memorize [topic]" — offer flashcard generation as one option. Proactively offer when the user shares study material mentioning an exam, quiz, or test deadline. Offer when the user shares notes, a chapter excerpt, or a dense reading and asks what to review — implicit retrieval-practice signal.

**Instructions:**

1. Read the full source material provided before generating any cards.
2. Identify atomic facts — one concept each; exclude compound facts, enumerations, and ambiguous claims.
3. For each fact, choose the clearest format: plain Q/A for discrete facts, cloze deletion for facts-in-context where surrounding words aid retrieval.
4. Generate at minimum 10 cards; target 15–20 for substantial sources.
5. Review each card against the quality criteria below before output — discard any card that fails.
6. Render the cards in human-readable format first: numbered list, Q/A pairs and cloze sentences.
7. Render an Anki-importable TSV block immediately below the human-readable version (tab-separated, paste directly into Anki File > Import).
8. End with a one-line summary stating how many cards were generated and what topic tag was applied.

**Output format:** Two blocks in sequence, separated by a blank line and a `---` divider. (a) Human-readable block: numbered list with `Q:` / `A:` pairs and cloze sentences. (b) Anki TSV block: tab-separated `question[TAB]answer[TAB]tags` rows. Tags: one space-separated tag string derived from the source topic, applied uniformly to every card. Card order preserves logical source order.

**Quality criteria:**
- Each card tests exactly one concept (atomicity — no compound questions).
- Each fact is expressed with minimum information: the narrowest phrasing that still carries full meaning.
- Each question is specific and unambiguous — "What is X's role in Y?" not "Tell me about X."
- Cloze deletion is used when context matters to retrieval; plain Q/A is used when it does not.
- The card set contains at least 10 cards (target 15–20 for substantial sources).
- Each card references the source snippet or topic for retrieval cue — no free-floating facts.

**Anti-patterns to avoid:**
- Compound cards that test multiple concepts at once — ungradeable by spaced-repetition algorithms.
- Yes/no questions that permit guessing without active recall.
- Vague "Tell me about X" questions with no single correct answer.
- Cards where both question and answer copy source sentences verbatim — defeats retrieval practice.
- Single card demanding full enumeration ("Name all 5 stages of X") — split into separate cards or clozes.
- Leading questions that telegraph the answer — no cognitive work required.

**Writing-profile integration:** Flashcard content is structured data (fewer than 100 words per card) — `context/writing-profile.md` is NOT consulted for card content itself. If Cowork appends an explanatory summary paragraph after the card set (100 words or more), that summary consults `context/writing-profile.md` and applies the user's tone, sentence-length preferences, and pet peeves.

**Example prompts:**

- "Make flashcards from this biology chapter on photosynthesis."
- "Help me memorize the key cases from this legal opinion — I have the exam Tuesday."
- "Generate 20 cards from my linguistics notes."

---

## Note-Taking

**When to use:** Use this skill when you ask for notes from a source — article, textbook chapter, academic paper, lecture, or long excerpt. Also use it when you share reading material with no specific ask and the source is long enough to benefit from structure (over 200 words). If you share dense study material under exam pressure, offer note-taking alongside flashcard generation. Prefer this skill over raw summarization when you will need to review the material later — structured notes are more useful for review than a flat summary paragraph.

Cowork auto-selects a note-taking framework based on the source type and states the selection at the top of the output so you can override it.

**Triggers:** Invoke when the user says "Take notes on" or "Make notes from" with an explicit source reference — highest-confidence direct invocation. Proactively offer note-taking when the user shares an article, PDF chapter, or long excerpt with no specific ask exceeding ~200 words. Offer when the user says "I need to study [X]" or "I'm reading [Y] for class" without naming a skill. Offer structured notes as an alternative to raw summary when the user pastes a long excerpt and asks "What's important here?"

**Instructions:**

1. Read the full source before choosing a framework.
2. Apply the framework decision rule:
   - Dense study material with concepts/definitions (textbook, academic paper) → Cornell (Cues + Notes + Summary): generates review cues naturally; matches exam-prep use case.
   - Lecture or chapter with natural hierarchy (section headers, bullet structure) → Outline (nested bullets): source already has hierarchy; low-ceremony fit.
   - Multi-source research needing cross-linking (papers citing each other) → Zettelkasten (atomic notes + cross-references): cross-source synthesis requires linkable atoms.
   - Short excerpt (under 500 words) → Lightweight bulleted outline: no ceremony for small inputs.
3. State the chosen framework in one line at the top of the output (e.g., "Framework auto-selected: Cornell (dense definitions + citations)."). The user can override before reviewing the notes.
4. Write notes in your own words — do not transcribe the source verbatim.
5. Preserve the source's hierarchy — use markdown headers and indented bullets to reflect parent/child structure.
6. For each main claim, include enough context that the user can trace it back to the source section or paragraph.
7. For Cornell format: populate three sections — `## Cues` (question-mode keywords), `## Notes` (synthesized body), `## Summary` (closing paragraph).
8. For Outline format: use nested markdown bullets reflecting the source's section hierarchy.
9. For Zettelkasten format: write atomic note blocks, each with a one-line title and cross-references to related blocks using plain text references (not wikilinks).
10. End every set of notes with a review layer — Cornell summary paragraph, Outline section keywords, or Zettelkasten reference list — so you have a retrieval hook.
11. Aim for 20–30% of the original source length. Condense supporting detail; capture main ideas in full.

**Output format:** Plain markdown in the chat — standard `.md` output with headers and bullets. No Obsidian `[[wikilinks]]`. No JSON or YAML sidecar. No Cornell box art — Cornell structure is shown via `## Cues`, `## Notes`, `## Summary` markdown headers, not a boxed layout. Output is portable across Obsidian, Notion, Apple Notes, Logseq, and plain text editors.

**Quality criteria:**
- Framework auto-selected per the decision rule and stated at the top of the output.
- Notes written in the user's own words — no verbatim copy-paste from the source.
- Clear hierarchy — parent/child structure visible via markdown headers and indentation.
- Source cues — each main claim is traceable to its origin section or paragraph.
- Review layer present — Cornell cues OR section-heading keywords for Outline/Zettelkasten.
- Summary or synthesis at the end — one sentence for short sources, a short paragraph for long ones.
- Length discipline — main ideas captured; supporting detail condensed, not transcribed.

**Anti-patterns to avoid:**
- Transcribing the source verbatim instead of synthesizing in your own words — defeats the point of note-taking.
- Notes with no hierarchy — a wall of bullets with no parent/child structure.
- Over-detailed (every word captured) or under-detailed (main claim lost).
- No source cue — a claim that cannot be traced back to its origin section or page.
- Missing review layer — no questions, keywords, or summary at the end.
- Ignoring structural signals in the source — section headers and bold/italic emphasis exist to guide note structure.
- Framework mismatch — forcing Cornell onto a source that is naturally outline-shaped, or vice versa.

**Writing-profile integration:** Three-tier rule based on note section and word count. Cues column (Cornell): always terse — question fragments, not prose; writing profile is not consulted. Notes body: neutral reference style by default; if any single note-item paragraph exceeds approximately 80 words, consult `context/writing-profile.md` for tone and sentence-length guidance. Summary: typically meets or exceeds 100 words — full writing-profile consultation applies. For Outline and Zettelkasten notes: apply writing-profile only to any closing synthesis paragraph that exceeds 100 words. Bullet content remains neutral reference style.

**Example prompts:**

- "Take notes on this biology chapter."
- "Make notes from my Notes/psychology-reading.md."
- "I'm reading this paper for class — can you help me study it?"
- "What's important in this article? Give me something I can review later."

---

## Research Synthesis

**When to use:** Use this skill when you supply two or more sources — papers, abstracts, excerpts, or articles — and need a structured comparison rather than a flat summary. Also use it when you paste a single source but mention you plan to add more, so an atomic note can be linked later.

Source count drives the mode. Apply the rule before reading:
- 1 source → Atomic note (Zettelkasten-style): one self-contained claim block, traceable to the source, ready for later cross-linking.
- 2 sources → Compact 2-row matrix + 1-paragraph comparison: matrix scales down; comparison paragraph carries the cross-source weight.
- 3 or more sources → Full matrix + synthesis paragraph(s): matrix surfaces patterns; synthesis extracts the insight.

State the selected mode in one line at the top of every output so the user can override before reading further. If the user needs recall practice from the same sources, suggest flashcard-generation after synthesis. If they need organized notes from a single source, prefer note-taking instead.

**Triggers:** Invoke when the user says "Synthesize / compare these papers" or "Cross-reference these sources" with an explicit multi-source ask — highest-confidence direct invocation. Proactively offer research synthesis when the user pastes two or more abstracts, excerpts, or links with no specific ask. Offer synthesis when the user says "I'm writing a lit review on [X]." Offer a matrix as a richer alternative to a flat summary when the user asks "What do these all say?" or "Summarise these."

**Instructions:**

1. Read all provided sources fully before choosing a mode.
2. Count distinct sources. Apply the source-count mode rule. State the selected mode in one line at the top of the output.
3. For 1-source mode: write a single atomic note block — one clear claim, one evidence sentence, one source attribution. Add a "Link to" line listing 1–2 related concepts for future cross-referencing.
4. For 2-source mode: build a 2-row matrix with columns: Source | Claim | Method | Evidence | Limitations | Links. Then write one comparison paragraph surfacing where the sources agree, where they differ, and why.
5. For 3-or-more-source mode: build a full matrix (rows = sources, columns = Claim | Method | Evidence | Limitations | Links). Then write one or more synthesis paragraphs that: surface the cross-source insight (what the field collectively says, not each source in sequence); explicitly surface any disagreements (methodology differences, conflicting effect sizes, definitional gaps); distinguish primary, secondary, and tertiary sources where relevant; call out methodology mismatches when sources use incompatible study designs.
6. Keep matrix cells terse — short noun phrases only. No prose in cells.
7. For every claim in the synthesis, verify it traces back to at least one named matrix row before writing it.
8. Apply the writing-profile rule to synthesis prose.
9. Apply the BibTeX extension if the user has supplied citation keys or `.bib` entries: render each source row with an `@key` label and use `[@key]` inline citations in the synthesis. Otherwise use `Author (Year)` format.

**Output format:** Plain GitHub-flavored markdown in the chat. Required header line: one sentence stating the mode auto-selected and source count (e.g., "Mode auto-selected: Full matrix + synthesis (3 sources)."). Matrix block: standard markdown table — rows = sources, columns = Source | Claim | Method | Evidence | Limitations | Links. Synthesis section: one or more paragraphs headed `## Synthesis`. No Obsidian `[[wikilinks]]`. No JSON or YAML. Output is portable across Obsidian, Notion, Apple Notes, Logseq, plain text editors, and academic writing tools.

**Quality criteria:**
- Mode auto-selected per source-count rule; stated at the top of the output.
- Every synthesis claim traces back to at least one named source row — no citation drift.
- Disagreements between sources explicitly surfaced, not glossed over.
- Primary, secondary, and tertiary sources distinguished where possible.
- Methodology differences called out when sources use incompatible study designs.
- Synthesis produces a cross-source insight — not a concatenated restatement of each source.
- Matrix cells terse; synthesis prose adapts to writing-profile.md.

**Anti-patterns to avoid:**
- Source-by-source summary with no cross-linking — matrix rows never reference each other.
- No disagreement surfaced — treating all sources as agreeing when they differ on methodology or conclusions.
- No distinction between primary, secondary, and tertiary sources.
- Ignoring methodology differences — comparing effect sizes across incompatible study designs without noting the mismatch.
- Citation drift — a claim in the synthesis cannot be traced back to a specific source row.
- Recency blindness — old and new sources weighted equally when the field has moved.
- Synthesis = concatenation — restating each source in sequence instead of producing a new cross-source insight.

**Writing-profile integration:** Three-tier rule based on output section. Matrix cells: always terse — short noun phrases, no prose; `context/writing-profile.md` is not consulted. Mode line: one-sentence factual statement; profile-neutral. Synthesis paragraph(s): full writing-profile consultation applies — tone, sentence-length preferences, and pet peeves from `context/writing-profile.md`. Synthesis paragraphs typically exceed 100 words, triggering the v1.2 adapt-to-profile rule. Apply the user's style to cross-source prose, not to matrix rows.

**Example prompts:**

- "Synthesize the papers in my Papers/ folder on [topic]."
- "I have three papers on protein folding. What do they agree on and where do they differ?"
- "I'm writing a lit review on attention and working memory — can you compare these abstracts?"
- "What do these two articles say? I want something I can cite."
