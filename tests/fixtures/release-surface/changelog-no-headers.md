# Fixture — zero-header CHANGELOG (@qa Phase 5 WARNING, docs/qa-report-v2.19.6.md §7)

A CHANGELOG-shaped file containing zero `## [x.y.z]`-style headers at all. Not a real scenario
for the live `CHANGELOG.md` (always 45+ headers), but `--changelog` is a user-facing flag on the
evidence-injection seam, and a malformed file pointed at by it deserves the documented
`CHECKED == 0` fail-closed diagnostic (`exit 2`), not a silent `exit 1` from an unrelated `grep -o`
pipeline failure under `pipefail`. This fixture exercises exactly that path.

No headers below this line — that absence is the point.
