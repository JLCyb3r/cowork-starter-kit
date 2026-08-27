# S15 — Log-Injection Negative Control (committed fixture, never a shell one-liner)

This fixture exists only to be read by the anchor-resolution guard's failure-sink
sanitizer (`.github/workflows/quality.yml`, AC-S15 / ADR-092 Decision (5) and (6)).
It never resolves to a real heading and does not ship — see `docs/spec.md`
Technical Constraints, Lint surface.

The payload lives here, as a file, because the naive shell form of this exact
string errors out under zsh and silently drops the percent sign under bash
(reproduced at Phase 1 in both shells) — the one property this control exists to
exercise. Where a shell must ever emit this payload, the form is
`printf '%s\n' '<payload>'`, never `printf "<payload>"`.

See `CONTRIBUTING.md § Bogus%0A::error::INJECTED-MARKER-7f3a`.
