---
name: research-synthesis
description: Synthesize multiple sources into a structured literature-review matrix with cross-source synthesis paragraphs, auto-selecting mode from source count (1 = atomic note, 2 = compact matrix, ≥3 = full matrix).
trigger_examples:
  - "Synthesize / compare these papers"
  - "Cross-reference these sources"
  - "I'm writing a lit review on [X]"
  - "What do these all say?"
---

## When to use

Use this skill when the user supplies two or more sources — papers, abstracts, excerpts, or articles — and needs a structured comparison rather than a flat summary. Also use it when the user pastes a single source but mentions they plan to add more, so an atomic note can be linked later.

Source count drives the mode. Apply the rule before reading:

| Source count | Mode | What you produce |
|--------------|------|-----------------|
| 1 source | Atomic note (Zettelkasten-style) | One self-contained claim block, traceable to the source, ready for later cross-linking |
| 2 sources | Compact 2-row matrix + 1-paragraph comparison | Matrix scales down; comparison paragraph carries the cross-source weight |
| ≥3 sources | Full matrix + synthesis paragraph(s) | Matrix surfaces patterns; synthesis extracts the insight |

State the selected mode in one line at the top of every output so the user can override before reading further.

If the user needs recall practice from the same sources, suggest flashcard-generation after synthesis. If they need organized notes from a single source, prefer note-taking instead.

## Triggers

- User says "Synthesize / compare these papers" or "Cross-reference these sources" with an explicit multi-source ask — highest-confidence direct invocation.
- User pastes 2 or more abstracts, excerpts, or links with no specific ask — proactively offer research synthesis as the primary deliverable.
- User says "I'm writing a lit review on [X]" or "I need to cover the literature on [Y]" — offer synthesis as the primary deliverable.
- User pastes multiple sources and asks "What do these all say?" or "Summarise these" — offer a matrix as a richer alternative to a flat summary; frame it as more useful for comparison and citation tracing.

## Instructions

1. Read all provided sources fully before choosing a mode.
2. Count distinct sources. Apply the source-count mode rule from `## When to use`. State the selected mode in one line at the top of the output.
3. For **1-source mode**: write a single atomic note block — one clear claim, one evidence sentence, one source attribution. Add a "Link to" line listing 1–2 related concepts for future cross-referencing.
4. For **2-source mode**: build a 2-row matrix with columns: Source | Claim | Method | Evidence | Limitations | Links. Then write one comparison paragraph surfacing where the sources agree, where they differ, and why.
5. For **≥3-source mode**: build a full matrix (rows = sources, columns = Claim | Method | Evidence | Limitations | Links). Then write one or more synthesis paragraphs that:
   - Surface the cross-source insight — what the field collectively says, not each source in sequence.
   - Explicitly surface any disagreements — methodology differences, conflicting effect sizes, or definitional gaps.
   - Distinguish primary, secondary, and tertiary sources where relevant; note if a source is a review paper vs. an original empirical study.
   - Call out methodology mismatches when sources use incompatible study designs that make direct comparison unreliable.
6. Keep matrix cells terse — short noun phrases only. No prose in cells.
7. For every claim in the synthesis, verify it traces back to at least one named matrix row before writing it.
8. Apply the writing-profile rule from `## Writing-profile integration` to synthesis prose.
9. Apply the BibTeX extension if the user has supplied citation keys or `.bib` entries.

## Output format

Plain GitHub-flavored markdown in the chat.

**Header line (required):** One sentence stating the mode auto-selected and source count. Example: `**Mode auto-selected:** Full matrix + synthesis (3 sources).`

**Matrix block:** Standard markdown table — rows = sources, columns = Source | Claim | Method | Evidence | Limitations | Links. For 2-source mode, same structure with two rows.

**Synthesis section:** One or more paragraphs headed `## Synthesis`. Prose, not bullets.

**BibTeX-aware extension (conditional):** If the user supplies citation keys or `.bib` entries, render each source row with an `@key` label and use `[@key]` inline citations in the synthesis. Otherwise use `Author (Year)` format.

No Obsidian `[[wikilinks]]`. No JSON or YAML sidecar. No CSV export. Output is portable across Obsidian, Notion, Apple Notes, Logseq, plain text editors, and academic writing tools.

## Quality criteria

- Mode auto-selected per source-count rule; stated at the top of the output.
- Every synthesis claim traces back to at least one named source row — no citation drift.
- Disagreements between sources explicitly surfaced, not glossed over.
- Primary, secondary, and tertiary sources distinguished where possible (noted in matrix or synthesis).
- Methodology differences called out when sources use incompatible study designs.
- Synthesis produces a cross-source insight — not a concatenated restatement of each source.
- Matrix cells terse; synthesis prose adapts to writing-profile.md.

## Anti-patterns

- Source-by-source summary with no cross-linking — matrix rows never reference each other.
- No disagreement surfaced — treating all sources as agreeing when they differ on methodology or conclusions.
- No distinction between primary, secondary, and tertiary sources — treating a review paper identically to an original empirical study.
- Ignoring methodology differences — comparing effect sizes across incompatible study designs without noting the mismatch.
- Citation drift — a claim in the synthesis cannot be traced back to a specific source row.
- Recency blindness — old and new sources weighted equally when the field has moved.
- Synthesis = concatenation — restating each source in sequence instead of producing a new cross-source insight.

## Example

**Input (3 abstracts):**

> **Miller (1956).** "The Magical Number Seven, Plus or Minus Two." Reviews span-of-attention and immediate-memory experiments. Concludes short-term memory capacity is approximately 7±2 items across modalities.
>
> **Baddeley (2000).** "The Episodic Buffer." Extends the 1974 Baddeley & Hitch working-memory model with a fourth component — the episodic buffer — a limited-capacity store that integrates information from the phonological loop, visuospatial sketchpad, and long-term memory.
>
> **Cowan (2001).** "The Magical Number 4 in Short-Term Memory." Reviews evidence from multiple paradigms (visual arrays, running span, auditory recall) and argues the true capacity of active focus is ~4 items, with higher counts reflecting chunking or rehearsal rather than raw capacity.

**Output:**

```markdown
# Research synthesis: Working-memory capacity estimates

**Mode auto-selected:** Full matrix + synthesis (3 sources).

| Source | Claim | Method | Evidence | Limitations | Links |
|--------|-------|--------|----------|-------------|-------|
| Miller (1956) | Capacity ≈ 7±2 items | Review of span & immediate-memory tasks | Convergence across modalities | Conflates chunked & unchunked units | Superseded by Cowan (2001) on raw capacity |
| Baddeley (2000) | 4-component working-memory model (adds episodic buffer) | Theoretical extension of Baddeley & Hitch (1974) | Integrates LTM with WM subsystems | Component boundaries under-specified | Orthogonal to Miller/Cowan capacity debate |
| Cowan (2001) | Raw capacity ≈ 4 items | Cross-paradigm review controlling for chunking/rehearsal | Visual arrays, running span, auditory recall | Focused on active-focus capacity, not total WM | Revises Miller (1956) downward |

## Synthesis

The field has shifted from Miller's (1956) 7±2 estimate toward Cowan's (2001) tighter ~4-item bound once chunking and rehearsal are controlled for — the two are not contradictory but operate at different levels of analysis (Miller measured observable span; Cowan measured underlying focus capacity). Baddeley's (2000) episodic-buffer extension is orthogonal to this capacity debate: it addresses what working memory integrates rather than how much. A modern summary: short-term storage spans ~4 items of active focus, extensible via chunking and long-term-memory integration through the episodic buffer.
```

## Writing-profile integration

Three-tier rule based on output section:

- **Matrix cells:** Always terse — short noun phrases, no prose. `context/writing-profile.md` is not consulted; cells are structured data, not sentences.
- **Mode line** (top of output): one-sentence factual statement; profile-neutral.
- **Synthesis paragraph(s):** Full writing-profile consultation applies — tone, sentence-length preferences, and pet peeves from `context/writing-profile.md`. Synthesis paragraphs typically exceed 100 words, triggering the v1.2 adapt-to-profile rule. Apply the user's style to cross-source prose, not to matrix rows.

## Example prompts

- "Synthesize the papers in my Papers/ folder on [topic]."
- "I have three papers on protein folding. What do they agree on and where do they differ?"
- "I'm writing a lit review on attention and working memory — can you compare these abstracts?"
- "What do these two articles say? I want something I can cite."
