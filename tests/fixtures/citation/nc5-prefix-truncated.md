# NC-5 — Prefix-Truncation Negative Control

This fixture exists only to be read by the anchor-resolution guard's extraction
pipeline (`.github/workflows/quality.yml`, AC-S14 item 1 / ADR-092 Decision (1)).
It is not a template and does not ship — see `docs/spec.md` Technical Constraints,
Lint surface, for why a file under `tests/` still has to be markdownlint-clean and
carry no lychee-resolvable link.

The citation below quotes the real `CONTRIBUTING.md` h3 heading minus its trailing
parenthetical. Under whole-line equality this resolves to zero headings, which is
the point of the control: a forbidden prefix test such as `index($0,s)==1` would
wrongly certify a truncated anchor like this one as resolved.

See `CONTRIBUTING.md § Worked-example authoring rules`.
