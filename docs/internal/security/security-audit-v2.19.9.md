# Security Audit — v2.19.9 "Truth Repair: the entry point that never fired"

**Phase:** 6 (Code Audit)
**Date:** 2026-08-11
**Scope:** `git diff f06f0cf..63e2b09` — 5 commits, 21 files
**Status:** **PASS WITH WARNINGS** — 0 CRITICAL, 0 BLOCKER, 2 MEDIUM, 1 LOW, 2 INFO
**Combined audit+approve path:** **NOT ELIGIBLE** — classification is SECURITY-SENSITIVE; the abbreviated Phase-6 path does not apply and `/approve` runs separately.

> **Authorship note.** `@security` produced this audit but declined to write the file: its output contract permits `docs/security-review.md` and `docs/pipeline.md` only, and a coordinator instruction does not widen it. The body was returned as text and landed by the orchestrator. This repository already records the same refusal as correct — see `docs/security-audit-v2.19.7.md`'s own header.
>
> This file **ships** (`git archive HEAD` lists all prior `docs/security-audit-*.md`). It has been written accordingly — see finding **A1**, which this document deliberately does not make itself an instance of.

---

## 1. Verdict

**PASS WITH WARNINGS. Nothing here should stop the merge.**

All four binding tier conditions HELD against `63e2b09`, re-verified by command rather than by reading the design. The `FROZEN v2` instrument, the `starter-sync-check` job, and every negative control were re-run against the landed tree. No CRITICAL, no BLOCKER, no dependency change, no secret.

Two MEDIUM findings, both of the same family this cycle exists to close — **a claim stated wider than the instrument that backs it** — and both cheap to fix.

---

## 2. Binding conditions — final status against `63e2b09`

| Condition | Status | Evidence (run this session) |
|---|---|---|
| `AC-TR-TIER-1` | **HELD** | `FROZEN v2` → **80** lines, `5f243f28e714e5e9fa201241ef553cabbd869ad904854801c67d9780d082cafb` — pinned baseline reproduced exactly on the landed, post-edit file |
| `AC-TR-TIER-2` | **HELD — final** | `git diff f06f0cf..63e2b09 --name-only \| grep -cE '^scripts/'` → **0** across the whole cycle. `968cf4c` grew the inline block by 19 lines; it was **not** extracted. Sole control surface: `.github/workflows/quality.yml` (Tier B row). |
| `AC-TR-TIER-3` | **HELD** | `git diff f06f0cf..63e2b09 --name-only \| grep -ic codeowners` → **0** |
| Compliance | **HELD** | No verbatim vendor text anywhere in the cycle; the single platform reference remains paraphrase-plus-citation, explicitly marked in ADR-082 |

`AC-TR-TIER-2` was the live risk at this gate — `quality.yml` changed again in `968cf4c` after the Phase 4.D pass. It changed *in place*. Tier B stands.

## 3. Guard Change Summary: **NOT OWED**

Final answer. Zero Tier-A-equivalent surfaces in the landed diff (`scripts/`, `.github/CODEOWNERS`, `cowork.lock.json`, `.cowork-allowlist.json` — all absent). Per the governing policy: if only Tier B files are present, PR ceremony applies without a Guard Change Summary. Classification unchanged: **SECURITY-SENSITIVE — Tier B · COMPLIANCE-SENSITIVE = NO.**

---

## 4. OWASP assessment

| Category | Status | Notes |
|---|---|---|
| A01 Broken Access Control | N/A | No authn/authz surface |
| A02 Cryptographic Failures | N/A | `shasum` used as an integrity digest, not a security primitive |
| A03 Injection | **PRESERVED** | Step 8.5's literal-string write (never eval/backtick/interpolate) inside `FROZEN v2`, byte-verified. New CI code: every path expansion quoted; the two unquoted `$ENFORCED_EXAMPLES` expansions are deliberate word-splitting over a static literal |
| A04 Insecure Design | **IMPROVED** | ADR-083 D2 (an ADR may not cite a prose line as sole authority for a platform behavioral claim) removes a real provenance defect |
| A05 Security Misconfiguration | **CLOSED** | `permissions: {contents: read}` present on `starter-sync-check` (Phase-2 finding S2). No `pull_request_target` — fork PRs cannot obtain a write token |
| A06 Vulnerable Components | **CLEAN** | **Zero dependency changes.** No `package.json`/lockfile/manifest in the diff. Sole `uses:` is the pre-existing SHA-pinned `actions/checkout` |
| A07 Auth Failures | N/A | No auth surface |
| A08 Data Integrity Failures | **IMPROVED** | `FROZEN v2` closes the Phase-2 S1 gap: reverting the slug gate now goes **RED** where the prior instrument stayed green |
| A09 Logging/Monitoring | **IMPROVED, one gap** | Four previously-silent failure modes now CI-visible. Gap: an aborted `ROSTER_LINE` yields no diagnostic — finding **A3** |
| A10 SSRF | N/A | No network call; offline axiom intact |
| LLM01 Prompt Injection | **PRESERVED, honestly labeled** | Step 8 still writes model-authored instruction text into a workspace `CLAUDE.md`. Mechanism unchanged; ADR-083 names it "the only inspection-class link in the step-8 chain" |
| LLM02 Insecure Output Handling | **PRESERVED** | Bounded-trigger and block-scoped token-scan clauses now inside `FROZEN v2` (they were in neither representation before) |
| LLM06 Sensitive Info Disclosure | **⚠️ A1** | Positive data-locality allow-list is sound. But a newly-shipped artifact discloses an external control's failure mechanism — finding **A1** |

**Secrets scan:** the cycle diff filtered for credential patterns — all hits are the word *token* in "token search" / "forbidden-token" / "token-bearing content risk". **No credential, key, or secret introduced.**

---

## 5. New CI code, audited as executable code

`968cf4c` narrowed the `AREA` slot, added an `@@ROSTER@@` slot, and added a roster-duplicate check.

| Check | Result |
|---|---|
| All 7 starters byte-identical under the **new** normalization | ✅ 7/7 |
| Roster-duplicate check vs duplicate **within** core | ✅ fires |
| Roster-duplicate check vs duplicate **across** core/optional | ✅ fires |
| Roster-duplicate check vs malformed roster (no `;`) | ✅ fires; also caught independently by slot-presence |
| Slot-presence with a broken anchor | ✅ 0 placeholders → fires |
| Data-locality allow-list, both legs | ✅ PA=1, other six=0 |
| `This area is` occurrences per file | ✅ exactly 1 in all 7 — `ROSTER_LINE` is single-line |

Exit-sensitivity sweep of the new lines found one unguarded substitution — finding **A3**. `CORE_TEXT`/`OPT_TEXT` use `sed` (always exits 0) and are safe; `EXPECTED`/`REF_PRESET` are safe.

---

## 6. The shipped `qa-report-v2.19.9.md` as a public artifact

Tracked and present in `git archive HEAD`, matching four prior qa-reports. Audited as a public surface.

**Path redaction: COMPLETE.** Zero references to external-tooling topology. Every backticked path resolves to a real in-repo file.

**Person-vs-artifact framing: CLEAN.** The single `orchestrator` mention attributes a diagnosis method, not fault to a person.

One gap remained at audit time — finding **A1**, since remediated.

---

## 7. Findings

| ID | Severity | Surface | Description |
|----|----------|---------|-------------|
| A1 | **MEDIUM** | logging | The shipped qa-report described an external control's parsing rule and its overwrite behaviour; redaction had removed paths but not the mechanism |
| A2 | **MEDIUM** | schema | ADR-084 §Maturation Path (f) claimed the check asserts "no skill name repeats" without qualification; case-variant and non-comma-separated duplicates are not caught (proven) |
| A3 | **LOW** | configuration | `ROSTER_LINE=$(grep …)` was unguarded where its two siblings 8 lines away carry `\|\| true` |
| A4 | INFO | none | A pre-existing lowercase archive URL was propagated to a second site by the README restructure |
| A5 | INFO | dependency | Zero dependency changes — confirmation, no action |

### A1 — MEDIUM (remediated in `b89621c`)

The shipped qa-report stated the blocking message verbatim and then specified the external parser's matching behaviour and how the fix evaded it. Read together in a public repository — for a system itself distributed as a template — that constituted a working recipe for spoofing a phase-gate status in a control that gates implementation writes. The tooling does not ship here, so this repository is not itself exposed; the exposure was of a **different** system's enforcement logic.

**Hop:** *redaction of a report that ships publicly must remove the failure MECHANISM of any external control, not only its file paths. The path is the low-value half; the parsing rule and its behaviour are the actionable half, and a reader who cannot locate the file can still reproduce the bypass.*

Remediation preserved the passage's teaching value — a status-parsing gap in external tooling produced a false BLOCK on a correct implementation; the input was wrong, not the parser; it was fixed by correcting the input rather than by editing a status field to satisfy the check — while dropping the reproducible half.

### A2 — MEDIUM (remediated in `71fded0`)

ADR-084 §Maturation Path (f) is otherwise the most scrupulously honest limit-statement in the cycle — it names the `weekly-review` roster gap, the word-budget freeze, and the absence of a canonical slug-to-display-name source. But one sentence claimed more than the check delivers:

- **Case variation is not caught.** A `Note-Taking` / `note-taking` pair returns empty from `uniq -d`. A genuinely duplicated skill passes.
- **Non-comma separators are not caught.** Splitting occurs on commas only.

Neither is reachable in the current tree — all seven rosters are comma-separated and consistently cased — so this was a latent claim defect, not a live hole. It is exactly the family the Phase-2 S3 finding named, recurring one artifact later.

**Hop:** *a statement of what a check asserts must be bounded by what the check was tested against. "No X repeats" is a universal claim; if the comparison is case-sensitive and separator-specific, the normalization basis belongs in the same sentence.*

### A3 — LOW (remediated in `71fded0`)

`ROSTER_LINE=$(grep 'This area is' "$f")` was unguarded. Under the runner's `bash -e`, a file lacking that line aborts the step. It fails **closed** — the job goes red, nothing ships — so this was not a vulnerability. But it aborted mid-loop, so presets after the failing one were never checked (`cmp`, slot-presence and the data-locality allow-list all skipped), and it emitted no diagnostic naming the offending file. Its two siblings in the same block carry the guard; this one, added a commit later, did not.

**Hop:** *when a fix establishes a guard idiom for a command class, later additions of that same class in the same block must adopt it. A fix that is not turned into a local convention regresses at the next edit — which is precisely what happened here, one commit after the class was closed.*

### A4 — INFO

A lowercase `cowork-starter-kit` archive URL existed once at base and now appears twice, the second instance introduced by the two-route README restructure. GitHub resolves repository names case-insensitively and `link-check-external` passed in the green run, so it works. Recorded because this project carries a case-collision discipline for tracked paths and a second divergent spelling is a maintenance seam. No action.

---

## 8. Prior-phase findings, as built

| Finding | Status | Evidence |
|---|---|---|
| S1 (freeze under-covers) | **CLOSED, better than specified** | `FROZEN v2` replaced enumeration with subtraction. The S1 attack now goes RED |
| S2 (CI job permissions) | **CLOSED** | `permissions: {contents: read}` on the job |
| S3 (guarantee wider than instrument) | **CLOSED** | ADR-083 D1 now names instrument, scope, coverage figure and controls in one sentence |
| S4 (unreproducible count) | **CLOSED** | Landed predicate reproduces **8** at `f06f0cf`, **12** at HEAD — verified both |
| S5 (S4's prose-only closure) | **CLOSED** | Dated correction in `docs/retro.md` + register row element (5) |
| F1 / F6 (Phase 0.D) | **CLOSED** | All four true sentences byte-unchanged; the discovery-brief security-invariant line annotated with zero deletions, carrying the required ADR-044 pointer verbatim |
| AC-TR-A2 | **PASS** | 4 removed lines cycle-wide in `architecture.md`, all ADR **Index rows**; zero ADR-body lines |
| AC-TR-A3 / B2 / C4 | **PASS** | TRUST split both legs; zero `primary`/`Alternative paths` in the user-facing set; PA 397/400 |

---

## 9. Recommended for `docs/patterns.md` at Phase 8

**The "claim wider than its instrument" row.** It has now recurred **four times in four phases** by four different authors — ADR-083 D1 (Phase 1), the annotated-row count (three values across three phases), ADR-084 (f) (Phase 4), and the qa-report redaction boundary (Phase 5). That is well past the 3-cycle promotion threshold, and it outranks the freeze-scoping row proposed at Phase 2.
