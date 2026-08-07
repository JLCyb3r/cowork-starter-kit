# Fixture CHANGELOG — AC-PUB-12 negative control

A single dated, in-scope, synthetic version (`9.9.9` — never a real release in this repo) that
has NOT been tagged. Exercises the case a `pull_request`-triggered run of the live gate would
hit on its own introducing PR: `## [x.y.z]` lands with the feature merge, before Scope A
publishes it. Asserts `verify-release-surface.sh` exits 1 with a `MISSING-TAG` line — exactly
what `push: pull_request` would have done to this cycle's own PR (which is why that trigger is
prohibited — `docs/design-v2.19.6.md` §C4).

## [9.9.9] - 2026-01-01

Fixture body text — not a real release note.
