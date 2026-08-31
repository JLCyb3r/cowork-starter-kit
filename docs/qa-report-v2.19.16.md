# QA Report — v2.19.16 "The Sync That Can't Land"

## Phase: 5
## Date: 2026-08-31T09:20:00Z
## Status: FAIL (BLOCKED — two named, fixable gaps; no functional regression found)

Every real script named in this cycle was executed for real, against real fixtures, by @qa this
session — never narrated, never assumed from a prior claim. All fixtures lived under `/tmp`
(outside this repo, and outside The-Council's own worktree); nothing here mutated this repo's own
tracked tree except one new local, unpushed branch built specifically to carry evidence (see
§Fixture Branch below).

---

## Unit / Script-Level Tests

This repo has no JS/TS stack (`stack-profile.json`: `"stack": "unknown"`) — its established
convention is real command execution recorded in `tests/*-firing-controls.md`, not Vitest. Counts
below are **script-level real executions**, not framework-reported test counts.

- Total control groups exercised this session: **9** (S1/vendor-prune ×6, cardinality ×5,
  attribution-survives-render ×2, verify-lock-removals.sh ×1, verify-vendored-orphans.sh ×2,
  vendored-integrity-check logic ×1, AC-B5-4 logic ×1, ratchet triple ×3, publish-release.sh ×1)
- Passing: all of the above reproduced the expected, predicted result.
- Failing: **1** — see Finding B (S6 mutation test), which is an *expected* failure mode this
  session deliberately reproduced to confirm a pre-disclosed residual is real, not a regression.

### Independently re-run, real script, real fixture (not narrated)

| # | What | Method | Result |
|---|---|---|---|
| 1 | S1 fix — positive control | `bash scripts/vendor-prune.sh` on lock==disk fixture | 0 removed, exit 0 — matches `tests/vendor-prune-firing-controls.md` §1 |
| 2 | S1 fix — negative control | 1 real orphan fixture | 1 removed (correct file), exit 0 — matches §2 |
| 3 | S1 fix — refusal control | `{"files":[]}` | exit 1, 0 removed — matches §3 |
| 4 | S1 — naive (unfixed) form reproduced fresh | own fixture, own copy of the pre-fix loop shape (never the shipped script) | sentinel `DECOY.md` **destroyed**, exit 0 — the bug, confirmed real |
| 5 | S1 — shipped form, same fixture | real `scripts/vendor-prune.sh` | sentinel **survives**, exactly 1 orphan removed (the whole `bad<LF>DECOY.md` path, atomic under NUL-delimiting), exit **0** |
| 6 | S1 — prefix-check isolated (4c) | hand-fed `"DECOY.md"` / a real in-root path to the `case` statement alone | refuses out-of-root (exit 1), allows in-root (exit 0) — both fire |
| 7 | Deviation 1 — does auto-prune actually remove the 2 stale files | full 150-file fixture materialized via a real `vendor-agency.sh` run (150/150 fetched+hash-verified), then real `vendor-prune.sh` | both stale `engineering/*.md` files removed, exactly 2, 0 collateral; `verify-vendored-orphans.sh` (real) then reports **PASS — 150 files, 0 orphans** |
| 8 | AC-ALLOWLIST-1 | `verify-lock-removals.sh` FILE MODE, base=`main` lock+allowlist, head=PR #125 lock + shipped `.cowork-allowlist.json` | `PASS — removed=2 (moved=0, all non-moved removals declared in blocked_files), blocked_files did not shrink` |
| 9 | Cardinality fix — all 5 controls | zero/17/18/real-registry/pre-fix-repro, `/usr/bin/grep -cE`, exit status checked | all 5 match `tests/registry-cardinality-firing-controls.md` exactly |
| 10 | Cardinality — "no other instance" sweep | re-ran corrected instrument + injected-defect positive control on a mutated copy | 0 hits real; 1 hit on the injected copy — instrument proven able to fire |
| 11 | 108→floor coupling | `grep -nE '\-ne 108\|\-eq 108\|== 108'` over `quality.yml` | 1 hit, a comment only — no executable hardcoded-108 check remains |
| 12 | `vendored-integrity-check` full logic (steps 1–3) | reproduced verbatim against the fully-materialized 150-file fixture | `CHECKED=150 FAIL=0`; LICENSE hash match; `LOCK_COUNT==DISK_COUNT==150≥108`; `AC-B5-4 FAIL=0` |
| 13 | S6 remedy — does it catch the demonstrated attack | mutated a real vendored file's `Source:`/`Pinned commit:` to an attacker repo + zeroed SHA, kept all field labels, ran the real new check logic | **did not catch it** — 0 failures reported (Finding B) |
| 14 | AC-RATCHET-1/-2 | live `curl` of all 3 `RATCHET_PATHS` at `RATCHET_SHA`; cross-checked 1 of 3 against both locks | all 3 hashes match `docs/design-v2.19.16.md` §C.4.1 exactly; differs from both locks, present (not null) in both |
| 15 | AC-RELEASE-1 / AC-SEQ-2 | real `bash scripts/publish-release.sh 1.0.0` with the CI's own `gh` shim, against the 0-orphan fixture | Branch **(a)**: log shows `verify-vendored-orphans: PASS — 0 orphans` then proceeds to build archives then fails at `ERROR: refusing to CREATE tag v1.0.0 — VERSION at HEAD is '2.19.16'.` — satisfies all 3 `AC-PUB-14` assertions |

### D3(a) / S7 / S3 — text-correctness sweeps (whole-file, not sampled)

- `CONTRIBUTING.md` + `.github/CODEOWNERS`: whole-file grep for every stale phrase named in the
  design (`2 separate maintainer approvals`, `enforced via CODEOWNERS`, etc.) → **0 hits**. All 4
  assertion sites read the corrected text on inspection.
- `sync-agency.yml`: the 3 named false "no CI runs"/"verified after merge" claims (the original
  scoped one, S7's unscoped second, and the third `:632-637` blockquote @dev found) are all now
  accurate; the human-judgment half of the old `:630` line ("decide whether the new category
  should be allowlisted") survives verbatim at the new line.
- `docs/risk-register.md`: `ADR-080-TRIGGER-D-2026-09` row present; both hashes it cites
  independently re-verified this session (matches).

---

## E2E / CI-Observation Tests

This cycle has no application UI; "E2E" here means the actual GitHub Actions checks the spec's
five vacuous ACs require to be **observed**, not reproduced.

- Total required: 5 ACs (`AC-VENDOR-1`, `AC-VENDOR-3`, `AC-ALLOWLIST-1`, `AC-ALLOWLIST-2`,
  `AC-RELEASE-1`) plus `AC-SEQ-2`'s observation clause.
- Closed by direct script-level evidence (their literal wording names the script/report, not "the
  job"): `AC-ALLOWLIST-1`, `AC-ALLOWLIST-2` — **PASS**, item 7/8 above.
- **NOT closed — live CI observation blocked**, see Finding D: `AC-VENDOR-1`, `AC-VENDOR-3`,
  `AC-RELEASE-1`, `AC-SEQ-2`. Local reproduction of every one of these checks' exact logic passed
  100% (items 12, 15 above), but the spec is explicit that a green *local* reproduction is not the
  bar — an *observed* `workflow_dispatch` run is.

---

## Findings

### Finding A — BLOCKER (mechanical, cheap to close): ADR-024 amendment missing its `§Maturation Path`

`docs/architecture.md:18016-18093` (the v2.19.16 ADR-024 amendment recording the D1(c) field-name
change) is a substantive modification of ADR-024 landed this cycle. Per this repo's own
`[[maturation-path-in-adr]]` binding (already correctly applied to ADR-100 at `:17980-18009`, which
has all three required sub-bullets), any ADR **written or modified** this cycle needs its own
`### §Maturation Path` section with `Future-state options:` / `Concrete revisit triggers:` /
`Risk knowingly accepted:`. The amendment has none — it ends at its `### Consequences` bullets
with no Maturation Path heading at all. (Confirmed: `grep -n "Maturation Path"` over ADR-024's
*original* 2026-era record at `:3253-3361` also returns nothing, so this isn't an omission unique
to the amendment — ADR-024 predates the convention — but the convention is binding on any cycle
that *touches* an ADR, and this cycle does.)

**This blocks Phase 5 PASS per my own binding instructions until @architect adds the section.**
It is a small, well-scoped addition — the amendment's own text already names most of the raw
material (item (e)'s compliance question, the migration-timing note in (d), the value-correctness
residual in Consequences) that a Maturation Path section would organize.

### Finding B — WARNING (security-relevant, pre-disclosed, not a regression): S6's remedy is presence-only, not value-verified

Reproduced the exact S6 attack from `docs/internal/security/security-review-v2.19.16.md` against
the *new* `attribution-survives-render` real-corpus step: took a real vendored file
(`design/design-ui-designer.md`), changed its `Source:`/`Pinned commit:` field **values** to name
`EVIL-ATTACKER/agency-agents` and a zeroed commit, kept every field **label** intact, and ran the
shipped check logic against it. **It passed — 0 failures.** The new step only asserts that six
field *labels* are present (`grep -qF "$field"`); it never compares any field's *value* against
`cowork.lock.json`'s `.upstream` / `.pinned_commit_sha` / `.content_sha256`.

This is **not a hidden gap** — `docs/architecture.md:18088-18091` (the ADR-024 amendment's own
Consequences section) already states it plainly: the new step closes `CF-v2.19.16-ATTRIB-SAMPLE`
"for the fields it checks (structural presence), though not for value correctness against the
lock (a residual, not reopened here)." My independent mutation test **confirms that self-assessment
is accurate**, not overclaimed. I'm flagging it at WARNING (matching S6's original severity, since
the content-hash integrity check is a separate, unaffected, still-sound mechanism — attribution
falsification "misleads a human... but cannot inject content") because the Phase 4 Summary's
shorthand ("S6 shipped") could read, to someone who doesn't open the amendment's Consequences
section or run the mutation test, as fully closing S6. It does not. Recommend the owner read
`docs/architecture.md:18088-18091` at the merge decision point, and that a future cycle (not this
one — no deadline pressure here) add value-comparison to close the residual properly.

### Finding C — ISSUE (judgment call, requires disposition): Deviation 2's `permanent`-gate does not re-open

@dev's narrowing of `AC-B5-4` sub-assertions 1–2 to `permanent==true` entries only (rather than
"every entry," D4(b)'s literal Phase-3-approved wording) is the **correct call for this branch**
— I confirmed empirically (item 7 above) that the two new deferral entries' paths genuinely remain
on disk and in this branch's own unbumped lock, so the literal "every entry" reading would redden
this PR for a state that isn't true yet, exactly the defect class this whole cycle exists to
retire.

But the orchestrator's flagged residual is also correct, and I judge it **does partially defeat
D4(b)'s stated intent**: S5's own remedy text says the generalized `AC-B5-4` "reddens the
same-path case" — for *all* entries, closing the gap where a blocked path silently re-enters the
lock under its original name. Gated on `permanent`, that protection **never activates** for the
two new entries, for as long as they stay `permanent:false` — which, per S3/S5's own text, is
likely to be a long time (until `security/` onboarding, a separately-scoped future cycle). The
mitigating factor: `sync-agency.yml:228`'s independent fetch-time exact-path block still exists
and would silently prevent re-fetching the blocked path even without `AC-B5-4`'s help — though its
only signal is one log line, not a CI-visible check, and every ADR-080 control in this repo is
already "notification, not gate" (S15/A01), so the marginal loss versus a gated repo is smaller
than it would otherwise be.

The orchestrator's proposed alternative — gate on **lock state** ("if the path is absent from the
lock, assert it is also absent from disk") rather than on the `permanent` field — is correctly
targeted and would close the gap on both this branch (inert today, since the path is still in the
lock) and future syncs (active the moment the path actually leaves). This is a real, valid finding,
not a nitpick, but it is a Phase 1/4-level design correction, not something @qa can or should
patch. **Recommend: named carry-forward for a near-term follow-up cycle**, not a blocker on this
one, since (a) nothing currently reddens, (b) the independent fetch-time block still holds, and
(c) forcing a Phase-4 rework here risks exactly the kind of same-cycle guard-logic edit ADR-080
already declined for D2(c) on separate grounds.

### Finding D — BLOCKER for 4 ACs, environmental (not a code defect): live CI dispatch could not be completed

Per `docs/spec.md` AM-4 and security-review S4, `AC-VENDOR-1`, `AC-VENDOR-3`, `AC-RELEASE-1`, and
`AC-SEQ-2`'s observation clause are explicitly **not satisfiable** by anything short of an
*observed* `workflow_dispatch` run of `quality.yml` against a fixture branch carrying PR #125's
lock state — the spec says so in the same breath it forbids trusting this cycle's own PR
("@qa SHALL reject a claim that cites it"), and S4 separately warns that a bare push produces zero
checks and an empty Actions tab that looks identical to "all fine."

**What I built (real, not narrated):** a new local branch `qa-fixture/v2.19.16-pr125-shaped`,
based on `release/v2.19.16-sync-repair` @ `85b4f28ceeb01d284e850c366bc72114046c3fd7` (carries every
Phase-4 fix), with:
1. `cowork.lock.json` replaced by PR #125's own head lock — verified `files|length` = **150**,
   `pinned_commit_sha` = `3c9588880b7cafaec325a104899fd8bbe27e7d72`, and (trivially, since this
   *is* that lock byte-for-byte) `git diff` against `c43d56f438ee820af427c889e1fff6cc6294fb25`'s
   own `cowork.lock.json` is **empty**.
2. The full 150-file corpus **actually fetched and hash-verified** by a real run of the shipped
   `scripts/vendor-agency.sh` (150/150, exit 0) — not copied, not assumed.
3. The 2 stale `engineering/*.md` files **actually removed** by a real run of the shipped
   `scripts/vendor-prune.sh` (exit 0, `2 orphan(s) removed`) — see Finding-adjacent item 7 above.

Committed locally at `4d49e2f0b8cdb4d8a679bdad47a660479ee1e948` (153 files changed, working tree
clean). Every check's exact CI logic was then reproduced against this commit locally and passed
100% (items 12 and 15 above) — as strong a local proxy as exists short of the real thing.

**What I could not do:** `git push -u origin qa-fixture/v2.19.16-pr125-shaped` was **denied by the
Claude Code auto-mode classifier** (a write-permission boundary above this repo's own guards, not
one of them) — pushing new content to a public GitHub repo and dispatching CI on it is outside
what I'm authorized to do unilaterally. Per my own standing instruction ("if a write is blocked:
STOP and report it as text... do not tunnel, do not retry"), I did not attempt a workaround (e.g.
`gh api` to create the ref directly). The branch and commit are preserved locally, unpushed, ready
to go.

**What's needed to close this:** either (a) the user or orchestrator pushes the preserved branch
and runs `gh workflow run quality.yml --ref qa-fixture/v2.19.16-pr125-shaped` (never a bare push,
never a PR against `main` — see S4), after which @qa can record the job's actual `conclusion` and
`.event` value against the four remaining ACs; or (b) the owner explicitly accepts the local
reproduction above as sufficient evidence for merge, with the understanding that this is not the
literal evidentiary bar the approved spec set for these four items.

---

## Wire-Through (v0.32 rule)

Both Phase-4-claimed call sites re-verified by grep, not trusted from the summary:

| Artifact | Call site (re-grepped this session) | Test |
|---|---|---|
| `scripts/vendor-agency.sh` | `sync-agency.yml:549`, `run: bash scripts/vendor-agency.sh`, gated `if: steps.check.outputs.needs_update == 'true'` | Ran for real this session (item 7) — not a description of a run |
| `scripts/vendor-prune.sh` | `sync-agency.yml:557`, `run: bash scripts/vendor-prune.sh`, same gate | Ran for real this session (items 1–7) |

`Wire-through: 2/2 rows verified (call-site grep re-run).`

## Enumeration rule (v0.32 Fix I)

- `AC-ALLOWLIST-2` ("zero orphans") — `verify-vendored-orphans.sh` **enumerates** the full disk
  tree via `find`, never samples. Confirmed by reading the script.
- Item-5 "audit of the rest of `quality.yml`" — re-ran the corrected sweep instrument over the
  **whole file**, plus an injected-defect positive control proving it can fire. Not a sample.
- D3(a)'s "all four assertion sites" — verified via a whole-file grep for every stale phrase named
  in the design, not a spot-check of the four cited line numbers alone.

## Classification: SECURITY-SENSITIVE

Carried forward from Phase 2/3 (Tier A) — new script with file-deletion capability
(`vendor-prune.sh`), allowlist/security-boundary changes (`.cowork-allowlist.json`), CI permission
surface (`sync-agency.yml`, `quality.yml`), and a rewritten third-party-attribution mechanism. No
Phase 4 change reduces this. Reconfirmed here for the Phase 7 classification cross-check.

## Rework rate

Not computed this Phase 5 pass — no rework has occurred yet against this Phase 4 SHA
(`85b4f28ceeb01d284e850c366bc72114046c3fd7`); that computation belongs to Phase 7 per the pipeline
workflow, against whatever SHA Phase 5/6 rework (if any) produces.

## Fix-Chain Circuit Breaker

N/A this pass — first Phase 5 run of this cycle; no prior Phase 5/5.R/6 REJECT row exists yet to
have triggered a rework transition.

## Issues Found

- [ ] **Finding A (BLOCKER)** — `docs/architecture.md`'s v2.19.16 ADR-024 amendment
      (`:18016-18093`) is missing its `### §Maturation Path` section (all 3 sub-bullets). Route to
      @architect.
- [ ] **Finding B (WARNING)** — `attribution-survives-render`'s new real-corpus step is
      presence-only; does not catch a real file's provenance fields being re-pointed at a
      different repo/commit while keeping field labels intact. Pre-disclosed in
      `docs/architecture.md:18088-18091`; independently reproduced as real, not theoretical.
      Recommend owner read that Consequences note before merge; book a future-cycle fix for
      value-comparison.
- [ ] **Finding C (ISSUE)** — `AC-B5-4`'s `permanent`-gate never re-opens for the two new D2(b)
      deferral entries once they leave the lock on a real sync; gate-on-lock-state would close
      this on both branches. Not this cycle's blocker (nothing reddens today, and an independent
      fetch-time block still holds); recommend a named near-term carry-forward.
- [ ] **Finding D (BLOCKER, environmental)** — Live `workflow_dispatch` observation of
      `AC-VENDOR-1`, `AC-VENDOR-3`, `AC-RELEASE-1`, `AC-SEQ-2` could not be completed: the push
      needed to dispatch the (fully-built, locally-verified) fixture branch
      `qa-fixture/v2.19.16-pr125-shaped` @ `4d49e2f0b8cdb4d8a679bdad47a660479ee1e948` was denied by
      the Claude Code auto-mode classifier. Branch preserved locally, unpushed. Needs orchestrator
      or user action: push + `gh workflow run quality.yml --ref qa-fixture/v2.19.16-pr125-shaped`.

## Corrections to the orchestrator's own Phase 5 brief

The brief's S1 §4b expectation — "confirm... the script exits non-zero" for the newline-filename
whole-script reproduction — is **wrong**, and I independently reproduced why before finding
`tests/vendor-prune-firing-controls.md` §4b already documents the same correction: once
NUL-delimited enumeration is in place, a filename containing a newline is a single, valid, still-
legitimately-orphaned path *inside* `$ROOT`; deleting it is the **correct, safe** outcome, and the
whole-script run correctly exits **0**. "Exits non-zero" is a real, separate, and also-confirmed
property — but it belongs to the **isolated prefix-check unit test** (§4c: fed the literal string
that escaped in the original bug, refuses with exit 1), not to the fixed script's end-to-end run
on the reproduction fixture. Both are independently verified above (items 5 and 6).

## Verdict

**REJECTED — not for functional defects (none found; the security fixes are real, tested against
real fixtures, and hold up under adversarial re-testing), but for two named, disposable gaps:**
Finding A (cheap — @architect adds a Maturation Path section) and Finding D (needs a push
authorization I don't have, or an explicit owner acceptance of local-only evidence in its place).
Finding B is a WARNING for owner awareness at merge, not a blocker. Finding C is a named
carry-forward, not a blocker.

Once Finding A is closed and Finding D is either resolved via live CI or explicitly waived by the
owner, this cycle's engineering is ready for Phase 6.
