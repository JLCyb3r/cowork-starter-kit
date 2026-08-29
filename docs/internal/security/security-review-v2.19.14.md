# Security Review — v2.19.14 "The Parser and the Premise"

## Phase: 2 (Architecture Review) — pass 2 (`2.R1`, re-review of `1.R1`)
## Date: 2026-08-29T09:20:00Z (corrected −4h at Phase 6.R1 from `2026-08-29T13:20:00Z`, a local-time reading mislabelled `Z` in the original — audit finding A7; this host's real UTC offset is UTC+4, verified via `date`/`date -u`, not the audit's own stated CEST/UTC+2)
## Status: PASS WITH WARNINGS — 0 blocking, 6 warnings, 4 info

> **Provenance note (orchestrator, 2026-08-29).** This file was persisted by the orchestrator from
> `@security`'s returned text, not written by `@security` itself. `@security`'s own `Write` call
> returned `File created successfully` and the ~40 KB of content existed nowhere afterwards — not in
> this repo, not in The-Council, not in the agent's worktree (`find` for `*2.19.14*` over both trees
> → 0 hits; control: `security-review-v2.19.11.md` present). The mechanism was **not** established.
> Three candidate causes were tested and refuted: `orchestrator-guard.sh` (gates the orchestrator,
> not `@security`), `bash-write-detector.sh` (a non-allow-listed probe file at this exact path
> **survived**), and directory/size (a 21-byte `Write` and a 42 KB Bash write both persisted here).
> Recorded as an open, unexplained condition — see the standing consequence in `## Findings`, S21.

**Base:** `a546292` on `release/v2.19.14-ci-parser-and-premise`. Working tree at review time:
`M docs/architecture.md`, `M docs/spec.md`. `.github/workflows/quality.yml` unmodified — the Tier A
change is designed, not built.

**Instrument declaration.** `/usr/bin/grep` by absolute path (BSD grep 2.6.0-FreeBSD). Bare `grep` on
this host is a ugrep shim honouring `.gitignore` and under-counts. **Alternation requires `-E`** — in a
BRE, `|` is a literal; that defect corrupted this review's own first pass (S20). Shell probes under
`/bin/bash` (CI runs `bash -e`; `zsh` does not reproduce the glob vector). Every zero below carries a
firing negative control.

---

## Findings Summary

| ID | Severity | Surface | Description | Blocks Phase 3 |
|----|----------|---------|-------------|----------------|
| S1 | RESOLVED | schema | Phase 1 had no design for Items 1/2/5. Closed by ADR-098. | No |
| S2 | RESOLVED | configuration | `grep -qw` regex/substring bypass. Closed by `case` membership. | No |
| S3 | RESOLVED | configuration | Unquoted `for` → pathname expansion. Closed by loop-scoped `set -f`. | No |
| S4 | RESOLVED | schema | `AC-CF25F-1` control falsified + non-discriminating. Four-assertion control adopted. | No |
| S5 | RESOLVED | permissions | PROPOSED-as-authority. `⚠ NOT IN FORCE` banners + gate-then-rewrite ordering. | No |
| S10 | RESOLVED | dependency | Version-conditional `.jsonc` discovery. Matrix adopted; pinning deferred to its own row. | No |
| S11 | RESOLVED | logging | ADR-096 §D5 export-ignore leg WITHDRAWN, withdrawal recorded. | No |
| S14 | RESOLVED | configuration | NBSP — `tr -d '[:space:]'` is byte-oriented; cannot split. | No |
| S15 | RESOLVED | configuration | Empty-array guard as shell test, not grep. | No |
| S6 | WARNING | schema | `dormant` = **2**, not 1. Spec's `AC-OT4-1` grep-to-zero unamended; mandates editing out-of-scope OT-7. | No |
| S7 | WARNING | configuration | `awk` frontmatter scan fails **open** for a file with no frontmatter. Recorded as Maturation option (d); `CF-v2.5-E` territory. | No |
| S8 | WARNING | schema | `CF-v2.5-A` silently discharged — the spec calls the MF-S1 defect "`CF-v2.5-A`'s residue" yet lists `A` out of scope. | No |
| S9 | WARNING | permissions | `AC-PARSE-1` unlocks multi-tool declarations while `CF-v2.5-ARCH-C` / `CF-v2.5-G` remain OPEN/ORPHANED. | No |
| S12 | WARNING | configuration | `install-pre-commit.sh:4` "same ruleset as CI" false on a second axis (CI globs exclude `docs/**`); outside the 5-site population, survives the fix. | No |
| S17 | WARNING | configuration | Shape precheck is `grep -q` (any-line). Duplicate `tools:` keys pass. No vocabulary bypass. | No |
| S16 | INFO | configuration | `.bak` clobbered on second install. | No |
| S18 | INFO | configuration | `tools: [claude-code,]` accepted — invalid YAML flow sequence. | No |
| S19 | INFO | configuration | `case` safety rests solely on `" $token "` quoting; `set -f` does not protect it. | No |
| S20 | WARNING | process | This review's own first-pass S1 measurement used BRE alternation — a vacuous zero with a control that did not exercise the pattern shape. | No |
| S21 | WARNING | process | A `Write` reported success and the content existed nowhere. Mechanism unestablished; three candidates refuted. | No |

**Gate disposition (owner, 2026-08-29): APPROVED with S6, S17 and S19 folded into Phase 4.**

---

## Verdict on the reworked design

**`case " $ALLOWED " in *" $token "*)` — ACCEPTED**, over this reviewer's own `grep -qxF` proposal.
Attacked with 8 vectors, all closed: space-join, whole-list-as-token, glob `*`, glob `?`, bracket
class, regex dot, NBSP, double comma. Controls fire in both directions (`claude-code` accepts, `emacs`
rejects), run in a directory where a file named `copilot` exists so the glob vector was live. 29/29
production skills PASS, re-run independently via the workflow's own `awk`. Superior to `grep -qxF`: no
`:1167` change, no subprocess per token, no regex/locale surface.

**Correcting the record on the refutation itself.** ADR-098 tested `grep -qxF` against the
*unconverted* space-separated `ALLOWED`; this reviewer's constraint had named a newline-delimited
`ALLOWED_LINES`. So "adopted verbatim, all 29 skills fail" refutes a simplification of the constraint.
**The fair criticism stands and is accepted:** the constraint never named the `:1167` edit that creates
that variable — an under-specified constraint handed to `@dev`. `case` is better regardless.

**`set -f` scoped to the token loop — DECISION CORRECT, STATED REASON FALSIFIED.** Step-scope `set -f`
does **not** "pass vacuously". MF-3's outer loop has no `[ -f ]` guard (unlike the sibling step at
`:996`), so the literal `skills/*/SKILL.md` reaches `awk`, `TOOLS_LINE` comes back empty, the
`missing tools: frontmatter field` branch fires, `BAD_FILES` is populated and the step **fails loudly
on every run** — a permanent false RED, not a silent green. Scope it to the loop; do not record
vacuous-pass as the reason. The ADR leans on the claim for a *security* conclusion, so a future editor
reasoning from it has a false model of the failure.

---

## OWASP Top 10

| Category | Status | Notes |
|---|---|---|
| A01 Broken Access Control | RESOLVED IN DESIGN | Membership test closes the vocabulary; verdict no longer depends on CWD. |
| A02 Cryptographic Failures | N/A | No cryptographic surface. |
| A03 Injection | RESOLVED IN DESIGN | Token no longer enters a regex or a glob context. Residual: S19 (quoting is the only guard). |
| A04 Insecure Design | WARNING | S9 — capability unlocked ahead of `CF-v2.5-ARCH-C`/`-G` governance. |
| A05 Security Misconfiguration | WARNING | S7 frontmatter fail-open; S12 hook/CI population divergence; S17 any-line precheck. |
| A06 Vulnerable/Outdated Components | WARNING | S10 — unpinned `npm install -g`; Actions correctly SHA-pinned. |
| A07 Identification & Authentication | N/A | OT-7 owner-only, out of scope. |
| A08 Software & Data Integrity | WARNING | The gate protecting pool integrity is the one being widened; CMP byte-mirror and lock integrity untouched. |
| A09 Logging & Monitoring | RESOLVED IN DESIGN | Three-outcome split gives each failure its true message; S13 CRLF residual. |
| A10 SSRF | N/A | No outbound request surface. |

**LLM01/02/06.** LLM01 — MF-3 gates what instruction content enters the shipped skill pool; S7 and S17
weaken that perimeter without breaching the vocabulary. LLM02 — unchanged. LLM06 — `docs/architecture.md`
ships (1 of 419 archive entries; `docs/internal/**` → 0, control `docs/spec.md` → 0, `docs/roadmap.md`
→ 1), so ADR narrative reaches downstream consumers; materially mitigated because the repository is
PUBLIC, and ADR-096 has withdrawn the unsound export-ignore-as-confidentiality claim.

---

## S21 — a reported write that did not land

Standing consequence for every downstream phase of this cycle and the next:
**treat "the agent said it wrote the file" as unverified.** Before relying on any review or QA report,
`ls` the exact path. The orchestrator has since bound this as a phase-row precondition and logged it to
the cycle observation log; `@qa`'s Phase-5 report is planned as return-text-plus-orchestrator-persist
for the independent reason below.

**Independent Phase-5 constraint, verified twice.** `docs/internal/qa/qa-report-v2.19.14.md` is not
writable by `@qa` under current scope rules — `orchestrator-guard.sh`'s `*/docs/qa-report*.md` is a
**suffix** wildcard after the literal prefix `docs/qa-report`, which cannot span the `internal/`
component (the version suffix was never the problem), and independently `qa.md`'s own `scope_allow`
regex `docs/qa-report\.md` does not match that path. Both agents' house convention is invisible to the
allow-list family.

---

## Classification

**CONFIRMED SECURITY-SENSITIVE / Tier A.** Surface: `.github/workflows/quality.yml`, the merge gate.
Re-derived, not inherited: the gate carried two live authorization bypasses, and the change's purpose
is to widen what it admits. Second Tier A surface: `scripts/install-pre-commit.sh` (executes on
contributor machines, writes `.git/hooks/`), strictly improved by this cycle. No downgrade available.

---

## Gate recommendation

**OPEN.** All four blocking findings resolved. Six warnings and four info items ship unfixed and are
dispositioned above rather than silently carried. Recommended before Phase 4 — **all three accepted by
the owner at the gate**: re-anchor `AC-OT4-1`'s control (S6), assert `TOOLS_LINE` is a single line
(S17), and add an inline comment plus a permanent `tools: [*]` fixture guarding the `case` quoting (S19).
