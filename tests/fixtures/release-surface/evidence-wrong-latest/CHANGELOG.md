# Fixture CHANGELOG — S-A1 negative control (@security Phase 6, docs/security-audit-v2.19.6.md)

Same shape as `evidence-clean` (single dated, in-scope, synthetic version `9.9.9`, correctly
tagged, with a Release body naming its version) — but this fixture's `latest.txt` deliberately
does NOT match the highest in-scope version. Every per-version conjunct (TAG, RELEASE) passes;
only the WRONG-LATEST assertion fires. This is the control that was missing: before this fixture,
deleting the WRONG-LATEST check entirely (`verify-release-surface.sh`'s S4/AMEND-4 addition) left
100% of this job's CI green — @security proved this by running a neutered copy against every
other fixture-based step. WRONG-LATEST is the sole automated check on the cycle's own Primary
success metric (`docs/spec.md`) and on Scope A's ascending-publish-order requirement.

## [9.9.9] - 2026-01-01

Fixture body text — not a real release note.
