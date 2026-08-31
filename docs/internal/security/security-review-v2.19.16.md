<!-- PERSISTED COUNCIL-SIDE BY THE ORCHESTRATOR 2026-08-30T20:10Z.
     The in-repo write of docs/internal/security/security-review-v2.19.16.md is DEADLOCKED:
     copy 1 was written (38,535 bytes, orchestrator-verified on disk with ls -l) then rm -f'd
     by bash-write-detector.sh -- its allowlist carries the FLAT Council path
     docs/security-review*.md; ORCHESTRATOR-VERIFIED: 'docs/internal' appears 0 times in that
     guard, firing control 'docs/security-review' = 1. The rewrite was then BLOCKED at write
     time by orchestrator-guard.sh. @security refused to tunnel and returned the review as
     text. This is that text.
     COMMIT THIS INTO THE COWORK REPO ONCE PHASE 3 IS APPROVED. -->

# Security Review — v2.19.16 \"The Sync That Can't Land\"

## Phase: 2 (Architecture Review)
## Date: 2026-08-30T19:41:00Z
## Status: PASS WITH WARNINGS — 1 CRITICAL bound to Phase 4, 0 gate-blocking, 7 warnings, 7 info

**Base:** `4f2fdbf4312a64dcbaac139b4404bf729b681b3e` on `release/v2.19.16-sync-repair`, verified as first action against the pinned base in the spawn prompt. Working tree clean. `COUNCIL_EXPECTED_BASE_SHA` unset (fail-open per F6), so the prompt's pinned base was the comparand.

**Instrument declaration.** `/usr/bin/grep` by absolute path (BSD grep) — bare `grep` here is a ugrep shim honouring `.gitignore` and under-counts. `-E` for every alternation. Shell probes under `/bin/bash`. Hashes via `shasum -a 256` (macOS; no `sha256sum`). The integrity strip is written `sed '1{/^$/d;}'` — the GNU form `1{/^$/d}` is rejected by BSD sed and yields the empty-string hash `e3b0c442…` for every file, which is the tell that the instrument is broken rather than the corpus. **Every zero below carries a control shown to fire, varying the property the null turns on.** Every GitHub call was a GET; PR #125, `main`, and branch protection untouched.

**Independence.** @architect's §E B1 record was NOT adopted — `scripts/guards/scope-check.sh` was read directly (S11). Every number handed to this phase by the brief or Phase 1 was re-run before use. This repo has **no** `docs/ADR-INDEX.md` and **no** `docs/DOCS-MAP.md`; the ADR index is the `## ADR Index` table inside `docs/architecture.md`.

> **Provenance note.** This file was written twice and lost twice, to two different Council guards. (1) The first copy was written and verified at 38,535 bytes, then destroyed by `bash-write-detector.sh`: its allow-list (`:126`) contains the flat Council path `docs/security-review*.md`, which does not match this repo's `docs/internal/security/` layout, so it fell to the catch-all `*)` arm. Statuses `??` and `A ` are handled identically — *\"unstage and remove\"* (`:209-215`) — so staging offers no protection and only a committed state survives. (2) The rewrite was blocked at write time by `orchestrator-guard.sh`, which resolved this subagent as `agent=orchestrator` and gated on Phase 3, unapprovable before Phase 2 ends. Recorded because it is a live, reproducible interaction between two repos' guards.

---

## Findings Summary

| ID | Severity | Phase | Surface | Description | Blocks Phase 3 |
|----|----------|-------|---------|-------------|----------------|
| S1 | CRITICAL | 2 | file-upload | `vendor-prune.sh` deletes paths **outside** `vendored/agency-agents/`. Design §C.2.3's containment claim falsified by measurement. | No — binding on Phase 4 |
| S2 | WARNING | 2 | schema | §C.1.1's floor removes the corpus-growth audit moment. The named survivor (`AC-B5-4`) covers **2** literal paths, not all declared removals. | No |
| S3 | WARNING | 2 | permissions | ADR-080 revisit trigger **(d) has fired** — first basename-changing rename observed — with a named `2026-09-01` deadline. No cycle document records it. | No |
| S4 | WARNING | 2 | configuration | Fixture branch has no construction recipe, no provenance assertion, and **a bare push runs zero checks**. | No |
| S5 | WARNING | 2 | permissions | D2(b) creates a stale-declaration condition at `security/` onboarding. `permanent` has **zero** machine consumers. | No |
| S6 | WARNING | 2 | dependency | Nothing verifies the ADR-024 attribution block on the real corpus — excluded from the integrity hash **by construction**, and its named job validates a self-written sample. Material to D1(c). | No |
| S7 | WARNING | 2 | logging | `sync-agency.yml:631` carries a **second** false claim, unscoped. Makes D1(a) materially riskier than the design states. | No |
| S8 | WARNING | 2 | external-api | The S1 content scanner cannot distinguish an injection payload from documentation of one. | No |
| S9 | INFO | 2 | external-api | PR #125's sole content-scan hit reviewed: **FALSE POSITIVE**. | No |
| S10 | INFO | 2 | external-api | Measured: **0 of 12** upstream `security/` files trip any of the 8 S1 patterns. Lowers D2(a)'s stated cost. | No |
| S11 | INFO | 2 | permissions | `.github/CODEOWNERS` absent from `scope_allow_delta.add[]` (17/18 §D rows). Mechanically a no-op. | No |
| S12 | INFO | 2 | schema | `MOVED` is hash-membership only; under auto-prune a MOVED file's disk copy disappears with no red check. | No |
| S13 | INFO | 2 | permissions | D1(b)/(c) requires **no new workflow permission and no new secret**. | No |
| S14 | INFO | 2 | configuration | `vendor-prune.sh` has no shebang and depends on bash process substitution. | No |
| S15 | INFO | 2 | permissions | D3(a) and D3(b) are **equivalent on security grounds**. | No |

**Overall: proceed to the Phase 3 owner gate.** No finding blocks the gate. S1 blocks Phase-4 implementation of `vendor-prune.sh` in its §C.2.3 form. S2/S3 warrant a fourth gate item (D4).

---

## Scope-Allow Re-Walk (B2, ADR-127 — independent, not delegated)

**PASS (structurally inapplicable) — 17/18 §D files present in `scope_allow_delta.add[]`.**

`.github/CODEOWNERS` (§D row 10) is **absent**. Firing control: `CONTRIBUTING.md` in the same block = 1, `CODEOWNERS` = 0, instrument identical.

Mechanically a no-op, verified by reading the guard rather than adopting §E: `scope-check.sh:708` — *\"External project: allow all writes within the project root\"* — returns `exit 0` for any write inside `$ACTIVE_PROJECT_PATH` **before** `scope_allow.standard[]` is consulted. There is no pattern set for `.github/CODEOWNERS` to be missing from. Recorded as INFO because if this block is ever copied as a template into a **self** cycle, the omission stops being a no-op. Correctly a `PASS on an inapplicable check`, not a PASS on a check that ran.

---

## CRITICAL

### S1 — `vendor-prune.sh` deletes files outside the vendored tree
**Binding on Phase 4. The script may not be implemented in its §C.2.3 form.**

§C.2.3 asserts: *\"`find` is rooted at `$ROOT` so nothing outside the vendored tree is reachable.\"* Measured, it is reachable.

**Mechanism.** The loop reads `find` output with `while IFS= read -r vfile` — **line-oriented**. A vendored filename containing a newline byte splits into two iterations. The second iteration's `$vfile` is the text *after* the newline, resolved **relative to the working directory** (repo root in CI), and `rm -f -- \"$vfile\"` deletes it. The deletion uses the raw `find` line `$vfile`, **not** the prefix-stripped `$rel` — so `$ROOT` never constrains the target.

**Reproduction — exact commands, run this session** (fixture at `/tmp/fx`, a copy outside the repo; never mutate-and-restore):

```bash
mkdir -p /tmp/fx/vendored/agency-agents/marketing /tmp/fx/vendored/agency-agents/engineering
printf 'a\\n' > /tmp/fx/vendored/agency-agents/marketing/m1.md
printf 'b\\n' > /tmp/fx/vendored/agency-agents/engineering/e1.md
printf 'LIC\\n' > /tmp/fx/vendored/agency-agents/LICENSE
printf '{\"files\":[{\"path\":\"marketing/m1.md\"},{\"path\":\"engineering/e1.md\"}]}\\n' > /tmp/fx/cowork.lock.json

printf 'IMPORTANT REPO FILE\\n' > /tmp/fx/DECOY.md      # sentinel at repo root
touch \"/tmp/fx/vendored/agency-agents/marketing/bad
DECOY.md\"                                               # ONE file, newline in its name

cd /tmp/fx && /bin/bash /tmp/vp.sh
```

Output:
```
vendor-prune: removed orphan vendored/agency-agents/marketing/bad
vendor-prune: removed orphan DECOY.md          <-- repo-root file, OUTSIDE $ROOT
vendor-prune: 2 orphan(s) removed.
EXIT=0

$ ls -la /tmp/fx/DECOY.md
ls: /tmp/fx/DECOY.md: No such file or directory
```

It deleted a file outside `$ROOT` and **exited 0**. An upstream filename shaped `x<newline>.github/CODEOWNERS` deletes `.github/CODEOWNERS`; `x<newline>scripts/verify-vendored-orphans.sh` deletes the guard that would have reported the tampering. An absolute path after the newline escapes the repository entirely, at runner privilege.

**Persistent, not one-shot.** The newline-bearing file is never removed — `rm` targets the truncated first half, which does not exist, and `rm -f` exits 0 on a missing path. Every subsequent run repeats the deletion. Confirmed by re-running the same fixture.

**All three designed controls pass — they do not cover this:**

| control | result |
|---|---|
| positive (lock == disk) | `0 orphan(s) removed`, exit 0, all files present — PASS |
| negative (one orphan) | `1 orphan(s) removed`, exit 0, correct file — PASS |
| refusal (`{\"files\":[]}`) | `::error::… refusing to prune.`, exit 1, **0** removed — PASS |

Additional adversarial cases, all fail-closed and therefore *not* findings: malformed lock JSON → `jq: parse error`, exit 5, nothing deleted; `.files` absent → `Cannot iterate over null`, exit 5, nothing deleted. The zero-lock refusal is well designed and works. `set -e` was verified not to abort the loop on `grep -qxF … && continue` (`printf … | grep -qxF \"zzz\" && echo matched` under `set -euo pipefail` continues, exit 0), so the loop reaches the `rm` as intended — confirmed, not assumed.

**Reachability — precise, not overstated.** The vector is **not currently reachable from a hostile upstream alone**: `sync-agency.yml`'s fetch loop (`:243`) splits the same way, but each half is filtered by `[[ \"$filename\" != *.md ]]` (`:266`) and fetched with `curl -sf` (`:277`), so a split path 404s, is recorded as a fetch failure, and the run fails closed after the loop (ADR-075 D6). The lock cannot acquire a newline path, and `vendor-agency.sh` writes only lock paths.

**That containment is incidental, not designed.** It lives in a different file, depends on an extension filter and a fetch-failure branch, and **this cycle modifies that very file**. Any other writer into `vendored/agency-agents/` reopens it: a contributor PR against a public repo, a maintainer commit, or a future change to the writer. Under D1(b)/(c) the prune runs **unattended on the monthly cron**, inside the job holding `contents: write`.

**Why CRITICAL.** A finding in guard/enforcement infrastructure (`vendor-prune.sh` is ADR-080 leg 2), an arbitrary-path deletion primitive, and the design **asserts** the containment measurement disproves. A control whose stated safety property is false is not a control.

**Remedy — binding on Phase 4, ~3 lines:**
1. NUL-delimit — closes the class, not the instance: `find … -print0` with `while IFS= read -r -d '' vfile`.
2. **And** a prefix assertion, because enumeration is not the only way a bad path arrives:
   ```bash
   case \"$vfile\" in
     \"$ROOT\"/*) ;;
     *) echo \"::error::vendor-prune: refusing to act on '${vfile}' — outside ${ROOT}.\"; exit 1 ;;
   esac
   ```
3. Add `#!/usr/bin/env bash` (S14).
4. Add a **fourth** control to `tests/vendor-prune-firing-controls.md`: newline filename + root sentinel — sentinel MUST survive, script MUST exit non-zero. A control whose absence is the alarm.

**Note for the implementer.** `verify-vendored-orphans.sh:80-90` has the **identical** loop shape. There it is safe *by consequence* — it only reports, so a split path yields a false orphan and a red check, failing closed. Copying a report-only loop into a delete-only script inverts its failure mode from fail-closed to fail-destructive. Fixing it too is optional and out of scope.

---

## WARNING

### S2 — The cardinality floor removes an audit moment the step's own comment identifies as its purpose
§C.1.1 replaces `[ \"$LOCK_COUNT\" -ne 108 ]` / `[ \"$DISK_COUNT\" -ne 108 ]` (`quality.yml:2365`, `:2369` — re-derived) with equality + `VENDORED_FLOOR=108`.

The soundness argument is correct as far as it goes: forward (lock ⊆ disk) + orphan (disk ⊆ lock) already prove set equality. I verified the precondition that argument needs — `vendored-integrity-check` (job start `:2277`) has **no** job-level `if:`, so all three legs run on every `pull_request`/`workflow_dispatch`. Firing control: the three gated jobs at `:1977`, `:2229`, `:2441` all carry one, so the instrument discriminates.

**But the design answers only half the comment it quotes.** It leans on *\"AC-B5-4's per-path assertions are what survive that.\"* Read at `:2380-2383`, `AC-B5-4` iterates a **hardcoded two-element array** (`marketing-carousel-growth-engine.md`, `project-manager-senior.md`). The surviving tripwire covers those two v2.19.7 paths and **no future declared removal**. Under the current pin any corpus-size change forces a human to edit a constant. Under the floor, growth (108 → 150 →) requires **no edit at all** and the board stays green.

**I considered CRITICAL and did not assign it.** The exact pin is *noisy* — it fires on every sync that changes size, including PR #125's 44 legitimate additions, and its routine remedy is \"bump the constant.\" A tripwire routinely cleared by editing a number is already degraded. ADR-080 §Consequences accepts the residual: re-entering content *\"arrives as a reviewable addition.\"* The floor removes a weak signal, not a strong one. A real loss, not a critical one.

**Remedy (~10 lines, no schema change, read-only; closes S2 and half of S3/S5):** generalise `AC-B5-4` from the hardcoded array to `jq -r '.blocked_files[].path'` — sub-assertions 1–2 (absent from disk, absent from lock) for **every** entry; 3–4 (`blocked_files`/`blocked_patterns` coverage) only where `permanent == true`. Restores the tripwire for every declared removal, and gives `permanent` its first machine consumer (S5). Does not close the *rename* case — that needs S3's hash half.

### S3 — ADR-080's own revisit trigger (d) has fired, and no cycle document says so
ADR-080 §Concrete revisit triggers, item **(d)**: *\"the first sync in which a basename-changing rename is observed — that is the trigger to implement S11's content-hash blocking, and it arms no later than the 2026-09-01 cron.\"*

It has fired. PR #125 carries **two** basename-changing renames:

| old basename | new basename | content |
|---|---|---|
| `engineering-threat-detection-engineer.md` | `security-threat-detection-engineer.md` | **byte-identical** |
| `engineering-security-engineer.md` | `security-architect.md` | changed |

Verified independently: `shasum -a 256` of the upstream file at pin `3c958888` gives `83bfaabe485d51965ba6474de3eb6e00f67fd7f76e5b34ca1d3fb385a8fa3d97` — **exactly** `main`'s lock `content_sha256` for `engineering/engineering-threat-detection-engineer.md`. Discriminating control: `security/security-architect.md` = `b1a68e9614f7…` ≠ `d6ce02769f3d…`, so the test distinguishes rather than matching everything.

Deadline is **2026-09-01 — two days out.** Neither the spec's v2.19.16 section nor the design mentions S11, content-hash blocking, or trigger (d). Firing control: the sole `revisit trigger` match in the design is the ADR-100 self-grep header count at §A.7; `ADR-080` matches 11 times in the same file, so the instrument works and the absence is real.

Not a demand to implement S11 now — a demand that the **re-deferral be a recorded decision** rather than a silent lapse past a dated obligation. Same standard ADR-080 applies to removals, applied to itself.

**Remedy:** a `docs/risk-register.md` row (§D row 14 is already open) recording that (d) fired 2026-08-30, that S11 is re-deferred, by whom, with what new trigger. Cheap detection half: record `content_sha256` on each `blocked_files[]` entry at declaration and assert it is absent from `.files[].content_sha256` — S11's *detection*, not a new blocking mechanism in `sync-agency.yml`, which sidesteps exactly why ADR-080 declined S11.

### S4 — The fixture branch has no construction recipe, and a bare push exercises nothing
`CF-v2.19.16-FIXTURE-BRANCH` is correctly HIGH. Two load-bearing gaps unnamed.

**(a) `quality.yml` has no `push` trigger** — `on:` is `pull_request` and `workflow_dispatch` only (`:15-17`), `push` dropped by ADR-099 A1. And **no other workflow verifies vendored integrity**: `/usr/bin/grep -cE 'vendor|orphan|integrity|cowork.lock'` over `release-surface.yml` and `release-assets.yml` returns **0**; firing control, same instrument over `quality.yml` returns **64**. So pushing the fixture branch and checking the Actions tab produces **zero runs** — visually indistinguishable from \"nothing failed.\" A check-that-cannot-fail sitting in the evidence base for five ACs. It must be exercised by `gh workflow run quality.yml --ref <fixture-branch>`, the mechanism ADR-099 proved yields SHA-bound check-runs.

**The alternative is worse and should be named forbidden:** opening a PR for the fixture branch would make CI run — but that PR targets `main` carrying 150 third-party files, i.e. X1 by the back door, the exposure X2 was chosen to eliminate.

**(b) No provenance assertion.** §B says only *\"a fixture branch built from PR #125's tree.\"* On a supply-chain gate the evidence branch's provenance must be assertable, not narrated. A fixture hand-assembled or re-vendored from a different pin gives **false assurance on exactly the five ACs checkable nowhere else**.

**Remedy (binding on Phase 5):** create from the PR head ref; @qa records three mechanical facts, not a narrative:
```
git diff <fixture-sha> c43d56f438ee820af427c889e1fff6cc6294fb25 -- cowork.lock.json   # must be EMPTY
jq '.files | length' cowork.lock.json                                                  # must be 150
jq -r '.pinned_commit_sha' cowork.lock.json                                            # must be 3c958888…
```
`mergeable: true`, head `c43d56f438ee820af427c889e1fff6cc6294fb25`, base `main`, same-repo (not a fork), labels `agency-sync` + `security-review-required` — all re-verified live via GET, not quoted from the brief.

**One further exposure §B does not name:** the re-vendored fixture materialises `project-management/project-management-meeting-notes-specialist.md` here for the first time — one of the 44 additions, absent from `main`'s lock and from disk (verified). That is the file carrying PR #125's only content-scan hit. It is a false positive (S9), so this is a recorded fact rather than an objection — but the owner reading §B's risk statement should know the fixture ingests the flagged file.

### S5 — D2(b) creates a declaration that will become false, and `permanent` has no reader
Measured: `/usr/bin/grep -nE 'permanent' .cowork-allowlist.json scripts/*.sh .github/workflows/*.yml` matches **only inside `.cowork-allowlist.json`** (3 field occurrences + prose in `reason` strings). Firing control: `blocked_files` **is** consumed — `sync-agency.yml:228`, `verify-lock-removals.sh`, `quality.yml` AC-B5-4 sub-assertion 3.

So `permanent: false` is prose. The design's *\"no reader is consuming it as anything else\"* is true but understates it: **nothing consumes it at all**, and `permanent: false` is machine-indistinguishable from `permanent: true`.

Forward consequence, unnamed. Under D2(b)-now / onboarding-later:
1. This cycle adds `engineering/engineering-threat-detection-engineer.md` to `blocked_files[]` and deletes the vendored copy. `83bfaabe…` leaves the corpus.
2. Later, `security/` is allowlisted and `security/security-threat-detection-engineer.md` — **byte-identical**, per S3 — enters as an ordinary addition. Exact-path block does not match. Ledger sees no removal. Under S2's floor, count is green.
3. `blocked_files[]` now asserts a file is blocked while the same bytes are vendored under another path — **a declared control that is factually false, detected by nothing.**
4. ADR-080 Decision 5 forbids removing the entry: `verify-lock-removals.sh:170-180` fails closed on any shrink.

That is the \"control described as stronger than it is\" family ADR-080 itself calls this repo's dominant defect — the result of expressing a *deferral* through a mechanism built for *rejections*.

**Smaller edge:** while the entry stands, if upstream restores `engineering/engineering-security-engineer.md` at its original path, `sync-agency.yml:228` silently declines to fetch it; the only signal is one `BLOCKED (exact path):` log line.

**Remedy:** S2's generalised `AC-B5-4` makes `permanent` load-bearing and reddens the same-path case. Cross-path needs S3's hash assertion. At minimum, §D row 14 must carry an explicit un-block trigger naming both entries.

### S6 — Nothing verifies the ADR-024 attribution block on the real corpus
The design established this premise at §C.1.3 and used it as a green light for D1(c). The security inference was not drawn, and it joins the cycle's own `CF-v2.19.16-ATTRIB-SAMPLE` to close a loop neither half closes alone.

**Half 1 — excluded from the integrity hash by construction.** The strip is `sed \"1,/^${END_MARK}$/d\"`: everything up to and including the END marker is discarded before hashing. Verified on a **real vendored file** (`design/design-ui-designer.md`), mutated on a copy outside the repo, varying provenance:
```
mutation:  Source: …/msitarzewski/…  ->  Source: …/EVIL-ATTACKER/…
           Pinned commit: 783f6a72…  ->  Pinned commit: 0000000000…
cmp null mut            -> differ at line 4        (the mutation is real)
stripped(null)          = 3130768958d3b3d38178aaec91cf789e01ecca4984c8674d4aaea446b6cba240
stripped(mutated)       = 3130768958d3b3d38178aaec91cf789e01ecca4984c8674d4aaea446b6cba240
cowork.lock.json stored = 3130768958d3b3d38178aaec91cf789e01ecca4984c8674d4aaea446b6cba240
```
A vendored file whose block names a **different upstream repository** and a zeroed pinned commit passes `vendored-integrity-check` byte-for-byte.

**Half 2 — the job named after the block never reads the corpus.** `attribution-survives-render` writes `/tmp/sample-attributed.md` via heredoc at `quality.yml:1833` and asserts the six ADR-024 fields against **that**. Measured: within `:1820-1920` there are zero references to `vendored/agency-agents`; every assertion targets `/tmp/sample-attributed.md`.

**Joined: the provenance record for all 108 vendored files is verified by nothing.** Content integrity is sound — `vendor-agency.sh:54,74-78` refuses any file whose fetched SHA-256 mismatches, fail-closed. It is *attribution* that is unverified — the repo's entire ADR-024/ADR-025 compliance story.

Pre-existing, not introduced here, hence WARNING: falsifying the block misleads a human and breaks the MIT notice obligation, but cannot inject content.

**Material to D1.** D1(c) rewrites this exact block; its feasibility argument is *\"the header interior is not part of the integrity hash\"* — simultaneously why it is safe to change and why nobody would notice a malicious change. If D1(c) is selected, the smallest honest fix is to extend `attribution-survives-render` to assert the six fields against the **real** corpus (or a sampled subset) in the same cycle that rewrites them — converting `CF-v2.19.16-ATTRIB-SAMPLE` from a deferred residual into a precondition of the option that touches it.

### S7 — `sync-agency.yml:631` carries a second false claim, unscoped
§D row 2 scopes only *\"`:631` correct the false 'no CI runs on a sync PR at all' sentence.\"* The line contains **two** false claims:

> `- [ ] Run bash scripts/vendor-agency.sh and commit the refreshed vendored/agency-agents/ — this is a maintainer step verified AFTER merge, by the vendored-integrity-check CI job running on the push to main. It does not gate this PR: no CI runs on a sync PR at all.`

(a) *\"no CI runs on a sync PR at all\"* — false since ADR-099's `dispatch-quality`. Scoped.
(b) *\"verified AFTER merge, by the `vendored-integrity-check` CI job running on the **push to main**\"* — **also false, and unscoped.** `quality.yml` has no `push` trigger, and no other workflow verifies vendored integrity (0 matches; control 64). False since v2.19.15 dropped `push`.

**This is the strongest measured argument against D1(a), and it is not in the design.** Under D1(a) the manual re-vendor is verified by **nothing** — not at PR time (already merged), not at push time (no trigger), not until someone opens an unrelated PR. The design argues against D1(a) because the check is *red on arrival*; the sharper problem is that after merge it is **unrun**.

**Also unscoped:** under D1(b)/(c), `:630` (*\"delete the orphaned copy\"*) and `:631` (*\"Run vendor-agency.sh\"*) become instructions to do work automation already did. A MANDATORY checklist telling a reviewer to perform completed steps is how tick-box review is trained. `:630`'s second half — *\"AND decide whether the new category should be allowlisted\"* — is a human judgement that must survive; only its mechanical half is automated.

*Checked and withdrawn before reporting:* I expected auto-prune to remove the forcing function that makes a maintainer confront an un-allowlisted rename. It does not — `verify-lock-removals.sh:147-165` still fails closed on any lock removal absent from `blocked_files[]`, and that job runs on `workflow_dispatch`, which is how sync PRs get checks. Recorded because a plausible finding that measurement refutes is worth as much as one it confirms.

### S8 — The content scanner cannot distinguish a payload from documentation of a payload
PR #125's only hit is `project-management/project-management-meeting-notes-specialist.md`, matching `forget (the |your |all |these )?(rules?|instructions?|…)`. Read at the pin (S9), the matching text is the persona's **own prompt-injection defence rule**, quoting attack phrases to instruct the agent to ignore them.

The 8 `SCAN_PATTERNS` (`sync-agency.yml:183-192`) are fixed known-phrase regexes with no notion of quoting, negation, or context. Any upstream file that *teaches injection resistance* trips them — and upstream is moving that way, having created a 12-file `security/` category since the last pin. The consequence is warning fatigue on the **only automated LLM01 control in the ingestion path**: a scanner flagging defensive text trains reviewers to clear `security-review-required` without reading, and the one real payload arrives wearing the same label as a dozen false ones.

Not introduced here and not fixable here. Recorded because this cycle writes the §D row 14 risk-register entry, and this belongs in it: the eventual D2(a) cycle must budget for triage, not a green scan. **Durable remedy (out of cycle):** record per-file scan disposition in the lock (`requires_review` already exists) so a reviewed false positive stays reviewed across syncs. Book against the same trigger as `CF-v2.19.16-SECURITY-ONBOARD`.

---

## INFO

- **S9 — PR #125's content-scan hit: FALSE POSITIVE.** Fetched read-only at pin `3c958888`, inspected as data. The match is line 29, inside `## Critical Rules`: the persona instructing itself to treat pasted content as data, quoting attack phrases as *examples of what to ignore*. Benign and consistent with this repo's posture. **Recorded so the 2026-09-01 sync does not re-litigate it** — the same file arrives again with the same flag. It is **not** currently vendored and **not** in `main`'s lock (verified); it is one of the 44 additions, so the fixture branch materialises it here first (S4).

- **S10 — 0 of 12 upstream `security/` files trip any S1 pattern.** All twelve fetched at pin `3c958888`, run against all 8 patterns as one `-ilE` alternation: **zero** matches. Firing control: injecting the known-hit file into the same directory and re-running the identical instrument returns exactly that file and nothing else. **This falsifies a hypothesis I held before measuring** — that D2(a) would produce a false-positive burst — and *lowers* D2(a)'s cost versus the design's account. Limit stated: scan-clean means \"no known-phrase payload,\" not \"reviewed.\" The patterns would not catch a subtle or novel injection, and 10 of the 12 have never been read here. Residual D2(a) cost is **human review burden, not detected payload risk**.

- **S11 — `.github/CODEOWNERS` absent from `scope_allow_delta.add[]`.** See Re-Walk. No-op via `scope-check.sh:708`; matters only if reused as a template for a `self` cycle.

- **S12 — `MOVED` is hash-membership only.** `verify-lock-removals.sh:155` tests whether the removed path's `content_sha256` reappears **anywhere** in the new lock — no rename confirmation, no path relationship. With auto-prune under D1(b)/(c), a MOVED file's disk copy is deleted with no red check. Correct for a genuine rename and harm is low (bytes remain under the new path). Noted because D2(c) proposes to *extend* MOVED; worth knowing it is content-only and blind to filenames.

- **S13 — D1(b)/(c) needs no new permission and no new secret.** `sync-upstream` already declares `contents: write` + `pull-requests: write` (`:40-42`); the two scripts need only workspace write and unauthenticated `raw.githubusercontent.com` GETs. ADR-099's A7 discipline preserved — `actions: write` stays isolated in `dispatch-quality` (`:686-687`) and does **not** move to the job handling untrusted content. Load-bearing for the GCS.

- **S14 — no shebang; depends on bash.** §C.2.3 shows no `#!` line and uses process substitution. `run: bash scripts/vendor-prune.sh` makes it work, but every other script in `scripts/` carries `#!/usr/bin/env bash`. Folded into S1's remedy.

- **S15 — D3(a) ≡ D3(b) on security grounds.** Live protection re-read via GET: `required_status_checks` **ABSENT**, `enforce_admins: true`, `required_approving_review_count: 0`, `require_code_owner_reviews: false`, force-push/deletion `false`. Neither changes any of those. Both are corrections to currently-false claims; the choice is doc-truth and readability, not security, and I decline to manufacture a distinction. I concur D3(a) is better — a control that cannot fire should be removed or repaired, not annotated — and D3(c) is unexecutable in-cycle. §0.3 confirmed independently: wide regex **4** sites, narrow **3**, `.github/CODEOWNERS:10` invisible to the narrow one; `enforced via CODEOWNERS` matches once, `CONTRIBUTING.md:359`.

---

## Gate Additions (recommended for Phase 3)

**D4 — the cardinality assertion (S2, S3):**

| | option | security posture |
|---|---|---|
| **D4(a)** | §C.1.1 as written — equality + floor | Rot-free. Loses the corpus-growth audit moment for every future declared removal. |
| **D4(b)** *(recommended)* | equality + floor **+ generalised `AC-B5-4`** over all `blocked_files[].path` | Rot-free **and** strictly stronger than today: covers every declared removal instead of two. ~10 lines, no schema change. Gives `permanent` its first reader. |
| **D4(c)** | keep the exact pin, bump to 150 | Strongest tripwire, guaranteed to rot; leaves `vendored-integrity-check` red on arrival monthly — the condition that makes arming the gate unsafe. |

D4(b) is the only option leaving the repo stronger than it started. Whichever is chosen, S3's re-deferral must be recorded in `docs/risk-register.md`.

---

## OWASP Top 10 Assessment

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | **WARNING** | `required_status_checks` ABSENT, `required_approving_review_count: 0`, `require_code_owner_reviews: false` — re-verified live. Every ADR-080 control is a **notification, not a gate**. This cycle does not change that (arming is v2.19.17) and correctly does not claim to. S15's corrections make the repo's text match reality. |
| A02 Cryptographic Failures | PASS | SHA-256 pinning throughout; `vendor-agency.sh:54,74-78` refuses unverifiable content fail-closed. No secrets in scope. |
| A03 Injection | **CRITICAL (S1)** | Newline-in-filename splits a line-oriented loop into an arbitrary-path `rm`. Currently unreachable from upstream by an *incidental* filter, which is not a control. |
| A04 Insecure Design | **WARNING (S2, S5)** | A floor replacing a pinned constant removes an audit moment; a deferral expressed through a rejection mechanism produces a declaration that will become false with nothing to detect it. |
| A05 Security Misconfiguration | PASS | No permission and no secret added (S13). ADR-099's `actions: write` isolation preserved. `enforce_admins: true` untouched. |
| A06 Vulnerable/Outdated Components | PASS | No new dependency. Actions SHA-pinned (`peter-evans/create-pull-request@67ccf781…`, `actions/checkout@11bd7190…`). The one BUILD component is in-repo. |
| A07 Auth Failures | N/A | No authentication surface. Sole-collaborator model unchanged. |
| A08 Software/Data Integrity Failures | **WARNING (S3, S4, S6)** | The core of this review. Content integrity sound; **provenance** integrity is not (S6). ADR-080's own S11 trigger has fired with a dated deadline (S3). The evidence base for five ACs has no provenance assertion and can run zero checks while appearing green (S4). |
| A09 Logging & Monitoring Failures | **WARNING (S7)** | `sync-agency.yml:631` asserts a post-merge CI verification that does not exist. Two checklist items go stale under D1(b)/(c). |
| A10 SSRF | PASS | Fetches target fixed hosts with paths from an allowlisted category set. `UPSTREAM_REPO` is a workflow constant. ADR-099's `env:`-not-`${{ }}` discipline preserved. |

## LLM Threat Assessment

| ID | Category | Status | Notes |
|----|----------|--------|-------|
| LLM01 | Prompt Injection | **WARNING (S8)** | The 8-pattern scan is the only automated control on ingested personas installed into user workspaces. It cannot distinguish payload from documentation-of-payload — confirmed live (S9, false positive). 0/12 `security/` files trip it (S10), with a firing control. Fixed known-phrase regexes; no defence against novel phrasing. |
| LLM02 | Insecure Output Handling | N/A | No model output is executed or rendered by anything in scope. |
| LLM06 | Sensitive Information Disclosure | PASS | No credential, token or PII surface. `GITHUB_TOKEN` auto-provisioned and scoped; no new secret. |

**Untrusted-content handling in this review.** Fifteen upstream files were fetched read-only at pin `3c958888` and treated as **data, never instructions**. Nothing in any of them was executed, obeyed, or propagated into a finding as an imperative. One file's content is quoted in S9 for disposition; the quotation describes what the file says, it is not an instruction adopted from it.

---

## Guard Change Summary

*Mandatory at Tier A. The owner decides MERGE / REJECT on this section alone, not on the diff.*

⚠️ **MERGE WITH CONDITIONS — 0 permission changes; 1 proven defect in the one new script that deletes files, fixable in 3 lines**

| Fact | Status |
|---|---|
| Permissions / scope | ✅ 0 changed — no new workflow permission, no new secret; `actions: write` stays isolated from the job handling upstream content |
| CI | ⚠️ Not yet run — branch unpushed, no PR, nothing built. The 4 red checks live on PR #125, not here |
| Can it block you? | ✅ No — no check is required on `main`, so nothing here can stop you merging. It can *delete* files on the monthly job (risk 1) |
| Known problems shipping unfixed | ⚠️ 3 filed, 1 HIGH — none can inject content past the per-file hash check (load-bearing) |
| Forward-only caveats | ⚠️ 3 — five checks can't be proven on this cycle's own PR; the new \"never shrink\" rule is a comment, not a check; one ADR deadline is being re-deferred |
| What we could not prove | ⚠️ 1 — that the delete bug is *unreachable*; I proved today's path blocks it, not that every future path will |

**What you're approving:** the monthly job that pulls in third-party agent files gets its four broken checks repaired — and, if you choose it, starts copying those files in automatically instead of you doing it by hand.

**What you're accepting:**
1. A new script that can delete a file outside the folder it is supposed to touch. *(Possible. High harm — the one worth your attention.)*
2. Losing the safety net that made someone look whenever the content library changed size. *(Likely. Medium harm.)*
3. If you keep copying manually, nothing checks that you did it. *(Likely. Medium harm.)*
4. The \"where did this file come from\" stamp on all 108 third-party files is checked by nothing. *(Unlikely. Medium harm — pre-existing.)*
5. Evidence for five checks that can look green while having run nothing at all. *(Possible. Medium harm.)*
6. The injection scanner keeps crying wolf on files that *defend against* injection. *(Likely. Low harm now.)*

---

### What changed

Four automated checks currently fail on the monthly third-party content sync, so that sync can never land cleanly. This cycle repairs all four, and adds one new script that deletes vendored files the content list no longer includes. You will also decide whether copying that content moves from a manual step you do after merging into the automated job itself.

### What could break

1. **The new delete script can delete the wrong file.** I ran it against a test folder. A single upstream file whose name contains a line break made it delete a file at the top of the repository — outside the folder it is meant to touch — and exit reporting success. It repeats on every run. Today nothing upstream can actually trigger this, but only because an unrelated filter in a different file happens to stop it, and this cycle edits that file. The fix is three lines and I have marked it as required before this ships. *(Possible. High harm.)*
2. **A safety net is being removed and the replacement covers less than claimed.** Today a hardcoded number forces someone to notice whenever the content library grows or shrinks. The design replaces it with a floor, which stops the number rotting every month — a real improvement. But the design says an existing check \"survives\" that change; that check only covers two specific files by name, not every file you have ever declined. A ten-line change makes the replacement stronger than what you have now instead of slightly weaker. I have put this on the gate as decision D4. *(Likely. Medium harm.)*
3. **If you choose to keep copying manually, nothing verifies it.** The workflow tells reviewers this step is \"verified after merge by CI.\" I checked: that CI trigger was removed in the previous cycle and no other job checks it. So under the manual option the copy step is verified by nothing until someone opens an unrelated pull request. *(Likely. Medium harm.)*
4. **The provenance stamp on third-party files is verified by nothing.** Each vendored file carries a block saying which repository and which commit it came from. I took a real file, changed that block to name an attacker's repository and a fake commit, and it still passed the integrity check byte-for-byte — because the check deliberately skips the block. The one job named after that block tests a sample it writes itself, never your real files. This is pre-existing, but it matters now because one option on your menu rewrites exactly that block. *(Unlikely. Medium harm.)*
5. **Five checks cannot be proven on this cycle's own work.** They need a separate test branch built from the stuck sync PR. Two traps: pushing that branch runs *zero* checks (an empty Actions tab looks identical to \"all fine\"), and the design never says how to prove the test branch really matches the stuck PR. Both are fixable by writing down three mechanical checks. *(Possible. Medium harm.)*
6. **The injection scanner flags files that teach injection resistance.** The stuck sync PR's only security flag turned out to be a file instructing itself to ignore injection attempts, quoting the attack phrases as examples. Harmless — but a scanner that flags defensive writing trains reviewers to dismiss its warnings. *(Likely. Low harm now, higher as more security-related content arrives.)*

### What's protected

- **No new permission and no new secret.** The automated job already had the access it needs; the one permission that could delete workflow logs stays in a separate job, away from the code that handles untrusted upstream content.
- **`main` is untouched.** No branch-protection setting changes. Nothing here arms or disarms a merge gate.
- **The removal ledger still fires.** I expected the new auto-delete to remove the prompt that forces a human to decide about an upstream rename. I tested it — it does not. That check still fails closed. Recorded because a suspicion that measurement kills is worth as much as one it confirms.
- **The load-bearing control, named:** every third-party file is fetched and its fingerprint checked against the stored list before it is written, and the script **refuses to write anything that does not match**. That is what stands between a compromised upstream and your content, and it is why items 4 and 6 above are acceptable to ship unfixed — neither lets anyone change what a file *contains*. **This is load-bearing.** If it were ever weakened, those two items would have to be reopened immediately.

### What to verify after merge

Each is something you will see in a document you already read. In each case, **absence is the alarm**.

- **The 2026-09-01 sync PR should show \"Vendored Integrity Check\" green.** If it is red on the file count again, the D4 decision did not land.
- **That PR's Reviewer Checklist should no longer tell you to run the copy script by hand** (if you chose automation). If it still does, the stale-instruction problem was not fixed and the checklist is training you to tick boxes.
- **`docs/risk-register.md` should contain a new row naming the deferred `security/` category.** If there is no such row, an obligation with a 2026-09-01 deadline was dropped silently.
- **`tests/vendor-prune-firing-controls.md` should list FOUR tests, one involving a file with a line break in its name.** Three tests means the delete bug's fix was never actually tested.
- **The QA report should cite a separate test-branch commit, plus a line showing its content list matches the stuck PR exactly.** If it cites this cycle's own pull request instead, the evidence for five checks is worthless.

**What we could not prove:** that the delete bug is unreachable. I proved that today's upstream path fails safely before a bad filename could reach the script — but \"no one can get there right now\" is a snapshot of one route, not a property of the script. Anything else that ever writes into the vendored folder reopens it. That is why I am asking for the three-line fix rather than accepting the current containment.

---

## Summary

The design is strong and its two structural findings (§0.1, §0.2) are correct — I re-derived both rather than adopting them, and the `108` pin, the two-lock coupling, the rename byte-identity, and the four approval-claim sites all hold. §B's X2 choice is right on security grounds: keeping the lock bump off this branch is a genuine reduction in exposure.

**One finding blocks the implementation as specified.** `vendor-prune.sh` is the cycle's only deleting artefact, and the containment property the design asserts for it is false: a single newline-bearing filename turns it into an arbitrary-path `rm` relative to the repository root, persistently. Not currently reachable from upstream — but only because of an extension filter in a different file that this cycle modifies. The fix is three lines and a fourth control.

**Two findings deserve a decision rather than a fix.** §C.1.1's floor is a good change that quietly retires an audit moment the step's own comment identifies as its purpose, and the compensating control the design names covers two literal paths rather than all declared removals — a ~10-line generalisation makes it strictly stronger than the status quo instead of slightly weaker. And ADR-080's own revisit trigger (d) fired on this exact event, with a deadline two days out, and no document in this cycle says so.

**The most durable thing found here was not in scope.** The ADR-024 attribution block — the repo's entire third-party provenance and MIT-notice story — is verified by nothing on the real corpus. It is excluded from the integrity hash by construction, and the job named after it validates a sample it writes itself. This cycle discovered both halves independently (§C.1.3 and `CF-v2.19.16-ATTRIB-SAMPLE`) and did not join them. It matters now because D1(c) proposes to rewrite that block, and its feasibility argument is the same fact that makes the gap invisible.

On the three open decisions: **D1(a) is materially the riskiest**, for a measured reason the design does not state — after merge the manual re-vendor is verified by nothing at all. **D2(a) is cheaper than the design says** (0/12 files trip the content scan, with a firing control) but its residual is human review, not detection. **D3(a) and D3(b) are equivalent on security grounds** and I decline to invent a difference.

**Status: PASS WITH WARNINGS.** Proceed to the Phase 3 owner gate, with D4 added to the agenda.