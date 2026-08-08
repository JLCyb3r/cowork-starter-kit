<!-- Fix contribution prepared by cowork-starter-kit for msitarzewski/agency-agents.
     Maps to this repo's v2.19.7 disclosure finding H-2 (see vendored/README.md
     §Disclosure). Filing, not acceptance, is the deliverable — see docs/spec.md
     v2.19.7 AC-B4-1. Prepared by @dev; actual PR filing against the upstream repo
     is an orchestrator/owner action outside this file's own scope. -->

# Suggested fix — corrupted emoji headings in 2 files

## Finding

`engineering/engineering-mobile-app-builder.md` and
`marketing/marketing-app-store-optimizer.md` each carry 14 level-2 (`##`) headings
whose leading emoji renders as garbage bytes — e.g. `## =­ Your Communication
Style` — instead of the intended emoji.

## Root cause (byte-verified, not guessed)

The corruption is a specific, reproducible transformation, verified against every
recoverable heading in both files: take the emoji's UTF-16 surrogate pair, keep
**only the low byte of each 16-bit code unit** (discarding the high byte), then
interpret those two raw bytes as Latin-1 codepoints and re-encode as UTF-8.

```python
def corrupt(emoji: str) -> str:
    cp = ord(emoji)
    if cp > 0xFFFF:                      # astral emoji -> UTF-16 surrogate pair
        v = cp - 0x10000
        high = 0xD800 + (v >> 10)
        low = 0xDC00 + (v & 0x3FF)
        return chr(high & 0xFF) + chr(low & 0xFF)
    return chr(cp & 0xFF)                # BMP emoji -> single UTF-16 code unit
```

Running `corrupt()` against the expected emoji (recovered by cross-referencing the
many OTHER files in this same corpus that use the identical heading text with an
intact emoji, e.g. "Your Identity & Memory" -> 🧠 everywhere else) reproduces the
exact corrupted bytes in **19 of 19** directly-verifiable cases across both files —
this is not a guess, every claimed mapping below was forward-computed from the
proposed clean emoji and diffed byte-for-byte against what is actually in the file
today. This is consistent with a lossy encoding round-trip in whatever tool last
touched these two files (most likely: something that read UTF-16 code units and
wrote only their low byte, then a downstream step re-interpreted that byte stream
as Latin-1/CP-1252 and saved it as UTF-8) — a tooling artifact, not a content
choice, and not present anywhere else in this corpus.

## Suggested replacements

Cross-referenced against identical heading text elsewhere in this same corpus
(high confidence — the corrupted bytes forward-verify byte-for-byte against these):

| Heading text | Corrected emoji |
|---|---|
| Your Identity & Memory | 🧠 |
| Your Core Mission | 🎯 |
| Critical Rules You Must Follow | 🚨 |
| Your Technical Deliverables | 📋 |
| Your Workflow Process | 🔄 |
| Your Deliverable Template | 📋 |
| Performance Optimization | ⚡ |
| Learning & Memory | 🔄 |
| Your Success Metrics | 🎯 |
| Advanced Capabilities | 🚀 |
| Your Communication Style | 💭 (disambiguated from 💬 — only 💭's surrogate pair reproduces the exact observed bytes) |

Unique to these 2 files (no cross-reference elsewhere in the corpus), reconstructed
by reversing the transformation above: of the 4 codepoints consistent with each
file's remaining corrupted bytes, exactly one is a real, commonly-used emoji and
the other 3 are unassigned or obscure — reported at "good confidence," not
"byte-verified," since this file's own text is the only source:

| Heading text | Corrected emoji | Confidence |
|---|---|---|
| Platform Strategy | 📱 (vs. 3 unassigned/obscure alternatives) | Good |
| Platform-Specific Implementation | 🎨 (vs. 3 unassigned/obscure alternatives) | Good |
| Platform Integrations | 🔧 (vs. 🐧/😧/an alchemical symbol — 🔧 fits "Integrations") | Good |
| ASO Objectives | 🎯 (vs. 3 unassigned codepoints; also matches this file's own reuse of 🎯 for "Your Core Mission"/"Your Success Metrics") | Good |
| Optimization Strategy | 📱 (vs. 3 unassigned/obscure alternatives) | Good |
| Testing and Optimization | 📊 (vs. a note-pad/girls-symbol/star glyph) | Good |

## Flagged, not guessed

`marketing/marketing-app-store-optimizer.md`'s "Market Analysis" heading lost its
emoji's SECOND byte entirely rather than corrupting it — the raw byte was
apparently `0x0A` (newline), which split the heading across two physical lines:

```
## =
 Market Analysis
```

The 4 codepoints consistent with the recoverable first byte have no standout
common-emoji candidate (🐊/🔊/😊/an alchemical symbol) the way every other
position above did, so this one is reported as "corruption confirmed, original
character not recoverable from this file alone" rather than guessed. The
structural break (heading text pushed to its own line, no longer parsed as a
Markdown heading at all by most renderers) is worth fixing regardless of which
emoji is chosen — even just rejoining the line restores a working heading.

## Suggested general remediation

Given the specific, mechanical nature of the corruption, the two files are very
likely recoverable to their true original text by locating this content in
whatever authoring system produced it (git history, an editor's local history, or
an earlier export) rather than by field-guessing every byte — the table above is
offered as a stopgap that closes the majority of instances with verified evidence,
not a substitute for checking against a clean source if one exists upstream.
