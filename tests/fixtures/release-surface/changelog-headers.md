# Fixture — AC-PUB-11 parser/comparator contract

Standalone CHANGELOG-shaped fixture, deliberately NOT copied from the live CHANGELOG.md (so it
stays stable regardless of future real edits). Exercises `scripts/verify-release-surface.sh`
against `--floor 2.18.0` (the same default the live gate uses):

| Header | Dash glyph | Component count | Expected classification |
|---|---|---|---|
| `## [2.19.5]` | ASCII hyphen | 3 | COMPARABLE, IN-SCOPE (above floor) |
| `## [2.99.9]` | em-dash + parenthetical title | 3 | COMPARABLE, IN-SCOPE (above floor) |
| `## [2.0.2]` | em-dash | 3 | COMPARABLE, SKIP/below-floor |
| `## [1.3.2.1]` | em-dash | 4 | NOT COMPARABLE — SKIP/non-x.y.z (real data: `CHANGELOG.md:847`) |
| `## [Unreleased]` | n/a | n/a | NOT COMPARABLE — SKIP/non-x.y.z (in-flight) |

`2.99.9` is a synthetic, never-real version chosen deliberately (not `2.6.0`, which is the
repo's own real em-dash example but is itself BELOW the `2.18.0` floor — `2.6.0 < 2.18.0`
numerically, exactly the lexical-vs-numeric trap `scripts/semver-compare.sh` exists to avoid).
This fixture needs an em-dash header that is also above the floor to test dash-agnostic
parsing on an IN-SCOPE token, which the live CHANGELOG does not currently contain (all of its
real above-floor headers use ASCII hyphen — the em-dash convention predates the floor).

A parser anchored on the literal `' - '` (ASCII hyphen only) would extract just the first
header, missing the em-dash ones entirely — the negative control this fixture backs
(`AC-PUB-11`).

---

## [2.19.5] - 2026-08-04

Fixture body text — not a real release note.

---

## [2.99.9] — 2026-05-10 (Dynamic Preset Scaffolds)

Fixture body text — not a real release note.

---

## [2.0.2] — 2026-05-07

Fixture body text — not a real release note.

---

## [1.3.2.1] — 2026-04-20

Fixture body text — not a real release note.

---

## [Unreleased]

Fixture body text — not a real release note.
