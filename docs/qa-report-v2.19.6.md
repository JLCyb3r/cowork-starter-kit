# QA Report — Cowork Starter Kit v2.19.6 "Publish What Shipped"

## Phase: 5
## Date: 2026-08-07T11:15:00Z (original) / 2026-08-07T12:05:00Z (re-verification, §9)
## Status: AMEND actioned and independently re-verified — see §9 for the discharge check. Original findings below (§0-§8) are preserved as the historical record; do not re-derive, read §9 for current state.

Every verdict below rests on a command I ran myself this session — live CI logs pulled via `gh run
view`, the shipped scripts executed locally against the shipped fixtures, or read-only `gh`
calls against the real repo. No verdict rests on @dev's or @architect's narrative alone.
Scope A (the three publishes) was **not** run, no tag was created, no release body was touched,
no `--force` worktree operation was attempted — consistent with this phase's boundary.

---

## 0. Full existing suite — honest counts

CI run for `f160393` (the branch HEAD, pushed): `gh run view 31170327841`.

| Conclusion | Count |
|---|---|
| success | 26 |
| failure | **3** |
| skipped | 2 (`lock-content-sha-cross-check`, `/sync-agency Dry-Run` — pre-existing path-gated jobs, unrelated to this diff) |

Both pushes to this branch (`c653141` and `f160393`) show the **same 3 failing jobs** — this is not
flaky, it is a consistent, reproducible RED. `main`'s last 5 runs are all green (`gh run list
--branch main`), so all three are newly introduced by this cycle, not pre-existing debt:

1. **ShellCheck** — `scripts/verify-release-surface.sh:173:3: warning: GE_OUT appears unused
   [SC2034]`. Real: `GE_OUT="$("$SEMVER_CMP" ge "$tok" "$FLOOR" ...)"` is assigned and never read
   anywhere (`GE_RC=$?` is the only thing consumed). Trivial fix (`>/dev/null` or drop the
   capture). Also an `SC1091` "note" on the `source` line in both new scripts — cosmetic, not
   independently failing (default `shellcheck` severity is "style", so both together push exit
   code to 1).
2. **Markdown Lint** — `tests/fixtures/release-surface/bodies/v2180-real.md:7 MD012/no-multiple-blanks`.
   The fixture has two trailing blank lines instead of one. Trivial fix.
3. **AC-PUB-14 CI step** — exits 127, not 1. Root-caused below (§2); **this is a test-harness bug,
   not evidence the guard itself is broken** — see the distinct, more serious finding in §3 for the
   guard that actually doesn't work.

None of these three block on a design decision; all are same-PR fixable. But CI is red today and
this report cannot recommend PASS while it is.

---

## 1. AC-by-AC verification

| AC | Verdict | Evidence |
|---|---|---|
| AC-PUB-1 (standing gate, 3-token discrimination) | **PASS**, spec text needs a second correction beyond @dev's (§4) | Live run against real repo data confirms all three token classes fire correctly with real evidence — see §4. |
| AC-PUB-2 (v2.19.4 backfill procedure) | **Not runnable this phase** (Scope A); pre-flight logic reviewed, **destination-repo assertion inside it is broken** — BLOCKER, see §3 | — |
| AC-PUB-3 (v2.19.5 backfill procedure) | Same as AC-PUB-2 | — |
| AC-PUB-4 | WITHDRAWN — struck in spec, confirmed still struck, not silently deleted | `docs/spec.md:6510` |
| AC-PUB-5 | RETIRED — confirmed absorbed into AC-PUB-1/-7 | `docs/spec.md:6513` |
| AC-PUB-6 (predicate: dotted OR anchor, `---` boundary) | **PASS** | Ran the exact `release-predicate-check` fixture logic locally (not just trusted CI): all 6 sub-assertions + both fixture-validity controls pass. See §5. |
| AC-PUB-7 (5 bodies byte-unchanged across cycle) | **PASS so far (pre-Scope-A baseline captured by @qa this session)** | sha256 of all 5 live bodies captured now, method documented, so the "after Scope A" comparison in a future session is mechanical. See §6. Zero `gh release edit`/`create` calls were fired by this session. |
| AC-PUB-8 (`CF-v2.19.5-F` → MISDIAGNOSED) | **PASS** | `docs/risk-register.md:17-31` — plain misdiagnosis statement, cites the corrected root cause, no longer in the open-rows table. |
| AC-PUB-9 (v2.19.6 own artifacts) | **PASS** | `VERSION`=`2.19.6`, `README.md:7` badge=`2.19.6`, `CHANGELOG.md:7` `## [2.19.6]` all agree; `Version Consistency Check` CI job = `success` on this run. |
| AC-PUB-10 (pre-v2.18.0 mismatch, 3 items) | **PASS** | `docs/risk-register.md:12` — 3 items (`v1.0.0`, `v1.1.1`, `v2.0.1`), correctly excludes `1.3.1.1`/`1.3.2.1` which have real entries. |
| AC-PUB-11 (parser/comparator contract) | **PASS** | Ran the exact fixture locally: RC=1 (not 2), zero `not a valid x.y.z semver` in stderr, `'1.3.2.1' SKIP` and `'Unreleased' SKIP` both present, `2 checked`. See §5. |
| AC-PUB-12 (Scope C CI wiring + controls) | **PASS** | Workflow triggers verified (`push:[main]`, `schedule`, `workflow_dispatch`, no `pull_request`, no `workflow_run`), `permissions: contents: read` at both levels. Negative control (untagged fixture) reproduced locally: RC=1, `9.9.9 MISSING-TAG` present. Positive control (clean fixture) reproduced locally: RC=0. |
| AC-PUB-13 (ADR-076 D3, documentation only) | **PASS, thin** | Script header documents it fully (`publish-release.sh:150-167` — S8 remedy). `docs/architecture.md` records it only as a single ADR-index-table row (`:99`), not a full "## ADR-076 amendment (v2.19.6)" section — the pre-existing v2.19.5 ADR-076 body's own `§Maturation Path` (lines ~12300-12310) already names this exact trigger ("the first release cut... at this cycle's Phase 5"), so the substance is covered, but the trail for this specific v2.19.6 refinement (halt-on-first-failure serialization; corrected remedy wording) is thinner than the two brand-new ADRs get. Not a blocker; worth tightening. |
| AC-PUB-14 (create-path version guard) | **PASS in design, correctly documented, correctly ordered in code; CI's own negative-control test is broken (§2)** | Code review: version-guard check runs before `assert_destination_repo()` and before any `gh release create` call in the create branch — confirmed by reading `publish-release.sh:112-158` line by line. Could not re-execute the *script itself* this session (see §7 — classifier declined the run, this repo's own rule bars @qa from running `publish-release.sh` against any version this phase regardless of intent). CI's attempt to prove this fails for a harness reason, not a guard reason — see §2. |
| AC-PUB-15 (v2.19.6 tagged/released in-cycle) | **Not runnable this phase** (Scope A) | Live gate confirms the negative control fires correctly today: `2.19.6 MISSING-TAG` — see §4. |

---

## 2. AC-PUB-14 CI failure, root-caused (test-harness bug, not a guard bug)

CI log (`31170327841`, step "AC-PUB-14 — create-path version guard fires with gh ABSENT from
PATH"):

```
/home/runner/work/_temp/....sh: line 12: bash: command not found
exit code: 127
##[error]AC-PUB-14 FAILED — exit 127 (gh command-not-found reached the create path unguarded)
```

The failure message is **wrong about its own cause**. It is not "gh reached unguarded" — it's
`bash` itself that went missing. The step's `PATH` filter (`quality.yml:1943-1961`) strips out
*every directory that contains a `gh` executable*. On `ubuntu-latest`, `gh` (installed via the
`cli/cli` apt package) and `bash` both live in `/usr/bin`. Stripping `gh`'s directory strips
`bash`'s directory too, so `PATH="$FILTERED" bash scripts/publish-release.sh 1.0.0` cannot even
find `bash` to exec — the failure happens before `publish-release.sh` runs at all, let alone
before it reaches a `gh` call.

**This means AC-PUB-14 has never actually been exercised correctly in CI** — the test's method for
simulating "`gh` absent" is broken by a coincidence of the runner's filesystem layout, not a
property of the guard. I did not attempt to work around this by re-running
`scripts/publish-release.sh` myself locally (this cycle's own instructions bar @qa from running
that script against any version this phase, and the harness's own action-classifier declined the
one attempt made — see §7); code review of the shipped script (line-by-line, §1 above) shows the
guard is correctly ordered. **Fix needed in the test, not (as far as this review can tell) the
guard**: filter out the specific `gh` binary path with an `rm`/bind-mount trick, or shadow only
`gh` (e.g. a wrapper directory prepended to `PATH` containing nothing, combined with a real
`command -v gh` check), rather than deleting whole directories by content.

---

## 3. NEW FINDING (BLOCKER) — `assert_destination_repo()` verifies the wrong command's repo resolution and provides zero protection against the threat it was written for

This is the "seventh instance" the task asked me to go looking for. It's a big one, and it
undermines a Phase-2 HIGH finding (`docs/security-review-v2.19.6.md:213-217`, `:492-493`) that both
the security review and the CHANGELOG (`CHANGELOG.md:22`: *"a sixth confirms the destination
repository, closing two ways an irreversible public write could target the wrong code or the
wrong place"*) claim is closed. It is not closed.

**The claim as written** (`publish-release.sh:62-68`, sourced from `security-review-v2.19.6.md:213-217`):
> `gh` honors the `GH_REPO` environment variable, which overrides repository resolution from the
> git remote. Assert `gh repo view --json nameWithOwner` equals the expected repo in the pre-flight.

**Empirically false for the specific command chosen.** I tested this live, read-only, three ways,
from inside the real repo checkout (`gh version 2.96.0`):

```
$ GH_REPO="octocat/Hello-World" gh repo view --json nameWithOwner -q .nameWithOwner
jmlozano1990/Cowork-Starter-Kit          # ignores GH_REPO — resolves via git remote regardless
```

Repeated with no git remote present at all (`git init` in a scratch dir, no origin) — still
refuses to consult `GH_REPO`, fails instead with `no git remotes found`. `gh repo view` with no
positional argument is documented (`gh repo view --help`) as showing "the repository for the
current directory" — that is a *git-remote* resolution, by design, distinct from the general
`GH_REPO`-aware resolution most other `gh` subcommands use.

**But the commands `assert_destination_repo()` exists to protect — `gh release view`, `gh release
edit`, `gh release create` — genuinely DO honor `GH_REPO`:**

```
$ GH_REPO="cli/cli" gh release list --limit 3
GitHub CLI 2.97.0   Latest   v2.97.0   2026-07-31T02:04:00Z
...                                    # real cli/cli data, not this repo's

$ GH_REPO="cli/cli" gh release view v2.96.0 --json name -q .name
GitHub CLI 2.96.0                      # confirmed: gh release view also honors GH_REPO
```

**The consequence:** if `GH_REPO` is exported in the operator's shell when Scope A's runbook is
executed (leftover from another project, a poisoned dotfile, anything), `assert_destination_repo()`
queries `gh repo view` — which **ignores** `GH_REPO` and reports the true repo, matching
`EXPECTED_REPO`, and **passes** — while the very next line's `gh release create`/`gh release
edit`/the idempotence check's `gh release view "$TAG"` **does** honor `GH_REPO` and operates
against the redirected repo, undetected. The guard is not merely weak; it is a check that passes
*because of* the exact attack it claims to test for, in the same "green for the wrong reason"
family this whole cycle is about closing — except this instance was never caught, because nobody
ran it against a real `gh` process before this session.

Also worth noting: the idempotence check (`gh release view "$TAG"`, `publish-release.sh:98`) runs
**before** `assert_destination_repo()` is ever called on either branch — so even a corrected guard
would need to move earlier, or the very first read already happens against the wrong repo if
`GH_REPO` is set.

**Recommended fix direction (not prescribing the exact patch):** don't try to verify what `gh
repo view` reports — verify the property that actually matters. The simplest, most robust option
is probably to *refuse to run at all* if `GH_REPO` is set (`[ -n "${GH_REPO:-}" ] && exit 1`) rather
than trying to out-guess `gh`'s per-subcommand resolution rules, since this script never has a
legitimate reason to run with `GH_REPO` exported.

This is a **BLOCKER** on AC-PUB-2/AC-PUB-3 as currently implemented, and the CHANGELOG.md line
claiming this gap is "closed" is a false public claim until it's actually fixed.

---

## 4. Two spec corrections — both independently re-verified; one of them is itself incomplete

### 4a. AC-PUB-14's negative-control token: `1.0.0`, not `2.0.2` — **CONFIRMED CORRECT**

```
$ git ls-remote --tags origin | grep v2.0.2
4ffb2b26...  refs/tags/v2.0.2                    # 2.0.2 IS tagged
$ gh release view v2.0.2 --json body -q '.body' | wc -c
1                                                  # ...with a live 1-byte body
$ gh release view v1.0.0
release not found                                  # 1.0.0 has neither
```

`2.0.2` would reach the **repair** branch with `gh` present and never exercise the create-path
guard at all — exactly the defect class this cycle diagnosed in `v2.19.1`'s stray digit. `1.0.0`
correctly reaches the create branch either way. Shipped code (`quality.yml:1961`) uses `1.0.0`.
Confirmed correct; needs a `[P4-CORRECTION]` note in `docs/spec.md` AC-PUB-14 (which still says
`2.0.2`).

### 4b. AC-PUB-1 State B — @dev's "3, not 2" is right about the mechanism, wrong about the number

@dev's claim: State B = 2× MISSING-TAG + 1× WRONG-LATEST = **3**, verified live against
current (pre-merge) `main` ("`Latest` is `v2.19.3`, expected `v2.19.5`"). I reproduced this
exactly:

```
$ git show main:CHANGELOG.md > /tmp/main-changelog.md
$ bash scripts/verify-release-surface.sh --floor 2.18.0 --changelog /tmp/main-changelog.md
2.19.5 MISSING-TAG
2.19.4 MISSING-TAG
WRONG-LATEST — resolves to 'v2.19.3', expected 'v2.19.5'
release-surface: 7 checked, 3 failed, ...
```

That's genuinely 3 — **but it's the wrong checkpoint.** "State B" is defined as *predicate fixed,
before Scope A* — i.e., **after** this PR (Scope B) has merged to `main`, not before. The moment
this PR merges, `main`'s `CHANGELOG.md` also gains the `## [2.19.6]` section (already present on
this branch, per `[P1-CORRECTION-3]`, which the spec itself acknowledges creates a "legitimately
RED" window for `2.19.6` between merge and Scope A). Running the same fixed script against
**this branch's own CHANGELOG.md** (i.e., what `main` will look like the instant this PR lands),
combined with today's live tag/release evidence:

```
$ bash scripts/verify-release-surface.sh --floor 2.18.0
2.19.6 MISSING-TAG
2.19.5 MISSING-TAG
2.19.4 MISSING-TAG
WRONG-LATEST — resolves to 'v2.19.3', expected 'v2.19.6'
release-surface: 8 checked, 4 failed, ...
```

**State B, correctly measured, is 4 failures** (`2.19.4`, `2.19.5`, `2.19.6` all MISSING-TAG, plus
WRONG-LATEST expecting `v2.19.6`), not 3. @dev's correction fixed the WRONG-LATEST omission but
evaluated it at a checkpoint (pre-merge `main`) that ceases to exist the moment Scope B lands —
it's a snapshot of a state that will never actually be observed, since `2.19.6`'s own CHANGELOG
entry rides the same merge as the predicate fix. Both `docs/spec.md` and `AC-PUB-1`'s State B
description need a `[P5-CORRECTION]` (or amended `[P1-CORRECTION-3]`) reflecting **4**, not 3, not
2. I'm not applying this myself — `docs/spec.md` is outside `@qa`'s write scope; returning as text
per the task's instruction not to tunnel.

---

## 5. Predicate + parser/comparator fixtures — re-run locally, not trusted from CI narrative

Ran the exact logic CI runs, directly, this session (not merely reading the CI transcript):

- **AC-PUB-6**: `neither.md` correctly rejected; `v2180-real.md` correctly rejects the `2.0.2`
  substring collision (with the fixture-validity control confirming the naive `202` match IS
  present, so the RED means something) while still matching its own `2.18.0`; `v21910-anchor.md`
  correctly rejects the `2191`-inside-`21910` boundary (fixture-validity control confirms the
  unterminated substring is present) while still matching its own `2.19.10`. All PASS.
- **AC-PUB-11**: dash-agnostic fixture (`changelog-headers.md` — ASCII hyphen, em-dash +
  parenthetical, em-dash below-floor, 4-component, `Unreleased`) → RC=1 (never 2), zero
  `not a valid x.y.z semver` in stderr, `'1.3.2.1' SKIP` and `'Unreleased' SKIP` both present,
  exactly `2 checked`.
- **AC-PUB-12**: negative fixture (`evidence-untagged`) → RC=1, `9.9.9 MISSING-TAG` present.
  Positive fixture (`evidence-clean`) → RC=0.
- **C3 seam containment**: planted `--evidence-dir` into a scratch copy of
  `release-surface.yml` and re-ran the literal grep the meta-check uses — confirms it goes RED
  when the flag is present, not just green on the current (clean) file. The real
  `release-surface.yml` carries neither flag.

---

## 6. AC-PUB-7 — pre-Scope-A sha256 baseline (captured this session, read-only)

`gh release view v<X> --json body -q '.body'` piped to a file, `shasum -a 256`:

| Version | sha256 (of `gh release view --json body -q .body` output) |
|---|---|
| 2.18.0 | `eca0f67e00540c5fc765c312e935f00c6eeaaf58a5fdf2a138aefa72a6ddb7f5` |
| 2.19.0 | `53bd21812863486e73a08cece033f801fa9cff668cb48dd533e1daf08b4975c1` |
| 2.19.1 | `1ade97f9c6f3a118afc5cb626b768b37108f4d3f506a69f0f77b4de52780ca31` |
| 2.19.2 | `bcce040c20782fc174587187f200b0ae3bab88d58103b0454664ae611e0b32ba` |
| 2.19.3 | `46375ab50a3d408957c467284124a1bb4809bd3ae977640293c1e2fd65a3df36` |

Whoever executes Scope A should re-run the identical command after all three publishes complete
and diff against this table — that's AC-PUB-7's whole test. Zero writes were made to capture this.

---

## 7. NEW FINDING (WARNING, narrow blast radius) — `CHECKED == 0` fail-closed path is dead code for one of its two trigger conditions

The spec's own edge-case list requires: *"`CHECKED == 0` (zero versions in scope) treated as
fail-closed, never a silent pass."* The script has this branch
(`verify-release-surface.sh:238-241`, prints `::error::...0 versions checked...` and `exit 2`).

Tested both ways CHECKED can reach 0:

- **CHANGELOG has headers, all below floor** → works correctly: `exit 2`, error printed. Verified
  with a synthetic `## [1.0.0]`-only fixture.
- **CHANGELOG has zero `## [...]`-shaped headers at all** → **dies silently with `exit 1` and zero
  output**, never reaching the documented branch. Root cause: `ALL_TOKENS="$(grep -o '^## \[...\]'
  "$CHANGELOG_PATH" | sed ...)"` — when `grep -o` finds no match it exits 1, and under `set -euo
  pipefail` that aborts the whole script at the assignment, before the loop or the CHECKED-eq-0
  check is ever reached. Confirmed with `bash -x`: trace stops immediately after `+ ALL_TOKENS=`.

Not reachable in normal CI/production use (the real `CHANGELOG.md` always has 45+ headers), so this
is not a live risk — but it is a genuinely dead branch for a documented contract, and a `--changelog`
pointed at any malformed file (a real possibility given `--changelog` is a user-facing flag on the
evidence-injection seam) gets a silent, unexplained `exit 1` instead of the documented diagnostic.
Cheap fix: `grep -o '...' "$CHANGELOG_PATH" || true` on that one line.

**Minor, INFO-level, same area:** `quality.yml:1951`'s `SAFE_PATH` variable is computed and never
read (the actual filtering happens in the `FILTERED` loop below it) — harmless dead code, not
caught by ShellCheck because workflow YAML isn't in its `scandir`.

---

## 8. What was not runnable this phase, and why

- **Scope A itself** (the three publishes) — explicitly out of bounds per this cycle's boundary;
  not attempted.
- **AC-PUB-13's live test of ADR-076 D3** — explicitly documentation-only per spec; not attempted.
- **Re-executing `scripts/publish-release.sh` locally** (to independently reproduce AC-PUB-14
  rather than rely on code review) — one attempt was made with `gh` filtered from `PATH` and
  version `1.0.0` (a config designed to be side-effect-free: no tag exists for `1.0.0`, and the
  guard should fire before any `gh` call regardless). The harness's action-classifier declined the
  call. Per this session's own instruction not to attempt workarounds, I did not retry with a
  modified invocation — verification for AC-PUB-14 rests on line-by-line code review (§1) plus the
  root-caused CI failure (§2) instead. Flagging this rather than silently downgrading the
  verification method.
- **GH_REPO redirection tested against `gh release create`/`edit` specifically (the actual write
  commands)** — I verified the *read* commands (`gh release list`, `gh release view`) honor
  `GH_REPO` live, which is sufficient to establish the finding in §3 (the guard checks a command
  that behaves differently from the family it's meant to represent), without needing to fire an
  actual `gh release create`/`edit` against any repo, real or scratch.

---

## 9. Re-verification (2026-08-07T12:05:00Z) — fix pass at `c33cb22` + `752ccbf`

Coordinator asked for a discharge check, not a re-review from scratch. Judged each of my §0-§8
findings against the actual code at `752ccbf`, re-running real controls myself rather than trusting
the fix-pass narrative or the new CI step in isolation.

### 9.1 BLOCKER (§3) — DISCHARGED, independently re-verified

`assert_destination_repo()` (the `gh repo view` no-op) is gone. Replaced with an unconditional
`[ -n "${GH_REPO:-}" ] || [ -n "${GH_HOST:-}" ]` refusal, hoisted above the first `gh` call in the
script (`publish-release.sh:112-119`) — closes the ordering gap too (previously the idempotence
check's own `gh release view` ran unprotected before any destination check existed at all).

I ran the **real, shipped script** three ways myself (not the CI step, not a mock):

```
$ GH_REPO="octocat/Hello-World" bash scripts/publish-release.sh
ERROR: refusing to publish — GH_REPO and/or GH_HOST is set in this shell. ... EXIT=1

$ GH_HOST="evil.example.com" bash scripts/publish-release.sh
ERROR: refusing to publish — GH_REPO and/or GH_HOST is set in this shell. ... EXIT=1

$ env -u GH_REPO -u GH_HOST bash scripts/publish-release.sh 1.0.0
Extracted CHANGELOG section for 1.0.0 (22 lines).
ERROR: refusing to CREATE tag v1.0.0 — VERSION at HEAD is '2.19.6'. ... EXIT=1
```

All three match the new `quality.yml` "Destination-repo guard fires..." step's own three
assertions exactly — confirmed by reading that step (`quality.yml:2010-2070`) after running the
equivalent by hand, not before. `--repo`/`-R` coverage claim independently re-grepped: zero
`--repo`/`-R` on any real `gh release *` call in the file (only inside printed remedy text a
human would type, never executed by the script). The genuine close is real.

### 9.2 Three CI failures (§0, §2) — DISCHARGED

- **ShellCheck**: `GE_OUT` capture dropped, stdout redirected to `/dev/null`, only the exit code
  kept. Re-ran the AC-PUB-11/-12 fixtures against the patched `verify-release-surface.sh` myself —
  identical results to before the fix (`2 checked`, RC=1, no `not a valid x.y.z semver`; untagged
  fixture RC=1 with `9.9.9 MISSING-TAG`) — the fix didn't silently change behavior along the way.
- **Markdown Lint**: trailing blank line removed from the fixture. Confirmed @dev's reasoning
  directly rather than accepting it: `$(cat file)` strips all trailing newlines unconditionally
  regardless of source file content — verified `wc -c`/`tail -c` on the actual captured `$BODY`
  value, then re-ran all three `AC-PUB-6(ii)` assertions (`2.0.2` rejected, own `2.18.0` still
  matches, naive-`202` fixture-validity control still present) against the trimmed file — all
  still PASS. Not a lint-config change; the byte the file lost was never load-bearing.
- **AC-PUB-14 step**: PATH-subtraction replaced with a `gh`-only shim (temp dir holding a fake
  `gh` that itself exits 127, prepended to `PATH`) that shadows nothing else. Reproduced the exact
  mechanism by hand (own shim dir, own `mktemp -d`) against the real script: `EXIT=1`, guard fired,
  not 127. Root cause (shared-`/usr/bin` directory-subtraction) confirmed fixed at the mechanism
  level, not just at the assertion level.

CI at `31173062583` (`752ccbf`, the docs-only correction commit): **29 success, 2 skipped
(pre-existing, path-gated, unrelated), 0 failures.**

### 9.3 Minor finding (§7) — DISCHARGED

`ALL_TOKENS="$(... || true)"` added. Reproduced the exact zero-header repro from §7 against the
patched script: `EXIT=2`, `::error::...0 versions checked...` printed — no longer a silent
`exit 1`. The below-floor CHECKED==0 path (the one that already worked) re-confirmed unaffected.
One minor note, not a defect: the new CI step (`quality.yml:1909`) only regression-tests the
zero-header trigger; the below-floor trigger has no dedicated CI step (it's covered by my own
manual verification, both before and after this fix pass, but not pinned in CI). Not blocking —
flagging so it doesn't quietly rot.

### 9.4 Spec / security-review corrections (§4) — applied faithfully

`docs/spec.md` `[P5-CORRECTION-1]` (State B = 4, not 2 or 3) and `[P4-CORRECTION-1]` (token
`1.0.0`) both present, both accurate, both in the append-only strike-through convention — no
history silently erased. `docs/security-review-v2.19.6.md` corrected at both the S2 prose site and
AMEND item 11, explicitly marking the original `gh repo view` prescription "WRONG and must not be
implemented as written" so a future cycle reading the review doesn't re-derive the no-op. Read
both corrections in full; they match what actually shipped.

### 9.5 NEW FINDING (WARNING, not a blocker on this discharge) — the same defect class is still live in `verify-release-surface.sh`, and I demonstrated it produces a false PASS, not just a false failure

The fix pass touched only `publish-release.sh`. Its sibling, `verify-release-surface.sh`
(`evidence_body()`, line ~107) calls `gh release view "v${version}"` via the same
implicit-resolution form that honors `GH_REPO` — with **no** guard at all. Lower severity than the
original BLOCKER because this script is read-only (a report can mislead; it cannot itself publish
to the wrong repo) — but I did not stop at "it's read-only, therefore fine." I ran it, live,
read-only, against the real repo:

```
$ GH_REPO="cli/cli" bash scripts/verify-release-surface.sh --floor 2.18.0
2.19.6/2.19.5/2.19.4 MISSING-TAG   (unaffected — tag check uses `git ls-remote --tags origin`)
2.19.3/2.19.2/2.19.1 MISSING-RELEASE   (FALSE — these releases exist; cli/cli has no such tags)
2.18.0, 2.19.0 — NEITHER reported as failed
release-surface: 8 checked, 7 failed, ...
```

`2.18.0` and `2.19.0` silently **passed** against `cli/cli`'s own, unrelated releases. Traced why:
`GH_REPO=cli/cli gh release view v2.18.0 --json body -q .body` returns cli/cli's real v2.18.0
release notes, which happen to contain the literal substring `2.18.0` — not about our repo at all,
but GitHub's own auto-generated footer: `**Full Changelog**:
https://github.com/cli/cli/compare/v2.17.0...v2.18.0`. That's a coincidental dotted-string
collision satisfying `body_names_version()` for a completely unrelated release. So a poisoned run
of this script doesn't just fail loud in the wrong way (MISSING-RELEASE on real releases) — it can
also **silently mask a real problem with a false PASS**, for any version number common enough to
collide with another repo's own release history. This is exactly the "green for the wrong reason"
pattern the whole cycle exists to close, demonstrated live, in the one script the fix pass didn't
touch.

**Not blocking this discharge** — Scope A's actual write path is now genuinely protected, and this
script never fires a write. But it should be closed before this class of gap is considered fully
retired repo-wide. Recommend the same unconditional `GH_REPO`/`GH_HOST` refusal be added to
`verify-release-surface.sh`, or a follow-up carry-forward if the owner prefers to scope it
separately (`docs/risk-register.md`, this cycle's OT/CF conventions).

---

## Verdict

**PASS** — for this discharge check: the BLOCKER is genuinely fixed and independently re-verified
against the real shipped script (not just the new CI assertions), the three CI failures are
genuinely fixed with their underlying claims independently re-confirmed (not merely re-read), CI is
green at `752ccbf` (29/29 non-skipped jobs), and both doc corrections are faithful. §9.5 is a real,
live-demonstrated new finding of the same defect class in a sibling script — recorded so it isn't
lost, not held back to gate this discharge, since it's read-only and Scope A's actual write path is
sound.

---

## Original verdict (superseded by §9, preserved for the record)

**AMEND.**

Not FAIL: every substantive defect found (§2, §3, §7) is narrowly scoped and fixable inside this
same PR without a design rework — none requires revisiting Scope A/B/C's shape. Not PASS: CI is
red today for reasons beyond the harness-bug in §2, and §3 is a confirmed BLOCKER — a HIGH
security finding that the security review, the code, and the CHANGELOG all currently claim is
closed, and isn't.

**Required before re-review:**
1. Fix `assert_destination_repo()` (§3) — BLOCKER.
2. Fix or replace the AC-PUB-14 CI negative control (§2) so it actually tests what it claims.
3. Fix `ShellCheck` (`GE_OUT` unused) and `Markdown Lint` (MD012) — mechanical.
4. Apply `[P4-CORRECTION]`/`[P5-CORRECTION]` notes to `docs/spec.md` for AC-PUB-14's token (§4a,
   confirmed correct as shipped) and AC-PUB-1 State B's count (§4b, **4**, not 3 or 2) —
   `docs/spec.md` is outside `@qa` write scope; returning as text.
5. Consider fixing the `CHECKED == 0` dead branch (§7) — WARNING, not blocking, but cheap.

Everything else — the predicate, the parser/comparator contract, the standing-gate wiring, the
provenance check, the post-upload body re-assertion, the risk-register closure, the version
artifacts — is real, independently re-verified this session, and sound.

---

## 10. Phase 7 — Final Approval

**Date:** 2026-08-07T14:20:00Z
**Reviewed:** `release/v2.19.6-publish-what-shipped` @ `85eaf3968c6464185615486f1ee03919251c42bc` (PR [#101](https://github.com/jmlozano1990/Cowork-Starter-Kit/pull/101), 12 commits ahead of `main`)

Everything below rests on a command I ran myself this session, independently of the audit's or
the fix-pass commit messages' narrative — reproduced from the real repo, the real CI, or a
neutered local copy of the shipped script. Scope A was not touched: no tag pushed, no Release
created or edited, `gh release create`/`gh release edit` never invoked. `verify-release-surface.sh`
was run live and read-only, exactly as its own `schedule`/`workflow_dispatch` triggers do in
production.

### 10.1 CI

`gh pr checks 101`: every named job reports `pass`; the two `skipping` rows
(`/sync-agency Dry-Run`, `lock-content-sha-cross-check`) are pre-existing path-gated jobs unrelated
to this diff, same as at Phase 5. Zero `fail` rows. `gh pr view 101` confirms `headRefOid` matches
the reviewed SHA and `mergeable: MERGEABLE`.

### 10.2 The three items @security left gating, independently re-verified — not re-read

**S-A1 (WRONG-LATEST negative control).** I reproduced the destructive test myself rather than
trusting the commit message: ran the real `verify-release-surface.sh` against
`tests/fixtures/release-surface/evidence-wrong-latest/` — `RC=1`, fires
`WRONG-LATEST — /releases/latest resolves to 'v2.18.0', expected 'v9.9.9'`. Then took my own copy
of the script, changed line 335's guard to `if false && [...]`, and reran it against the identical
fixture: `RC=0`, `0 failed`. Same fixture, same inputs, opposite verdict, purely from disabling the
one line the WRONG-LATEST stage lives on — confirming the fixture and the CI assertion that checks
for it are load-bearing on the actual code path, not passing by coincidence.

**S-A2 (destination-repo enumeration).** Both call sites run both checks: `publish-release.sh:111`
calls `assert_gh_destination_repo` unconditionally after the free env-var check; `verify-release-
surface.sh:116` calls it gated on `EVIDENCE_DIR` being unset (so the offline fixture seam stays
network-free — confirmed by code read, not assumption). `assert_gh_destination_repo()` itself
(`release-predicate.sh:162`) is a positive `gh api "repos/{owner}/{repo}"` assertion, fail-closed on
any error. The new CI unit test (`quality.yml:2155`) exercises both branches live against the real
repo — a deliberately wrong expected value (must refuse) and the correct one (must accept) — and
passed in the run I checked. I also grepped every `gh api`/`gh release` call left in the three
touched scripts: all of them execute after `assert_gh_destination_repo` in their respective control
flow, none bypass it.

**S-A2 fix-pass CI break, and the fix.** `902bf9e` is disclosed, not squashed — a real CI failure
(`CHECKED==0` step lost its `GH_TOKEN`-free path once the positive assertion went live) that
`@dev` fixed by adding `--evidence-dir` and then swept every remaining invocation for the same gap,
re-verifying under a simulated unauthenticated `gh` (`GH_CONFIG_DIR` pointed at an empty directory)
rather than the session's own already-authenticated one. I re-read the sweep's stated scope against
a full `grep` of every `verify-release-surface.sh` invocation in `quality.yml` myself; the claim —
all others either already pass `--evidence-dir` or hit the free env-var check first — holds.

Both were scored WARNING/AMEND-gating by `@security`, not CRITICAL — correct, since neither is
exploitable data loss and both are pre-merge catches, not live incidents. Gating was the right
call regardless: S-A1 guards the cycle's own stated Primary success metric, S-A2 guards the one
irreversible public write this whole cycle exists to make trustworthy.

### 10.3 The eleventh-instance sweep

The pattern this cycle exists to close — a control that reads as protective but isn't — has
produced ten confirmed instances across `v2.19.5`/`v2.19.6` (`@qa` found #7 and #9, the orchestrator
found #8, `@security` found #10/S-A1, with S-A2 a closely related eleventh candidate that `@security`
correctly did not let ride on S-A1's fix). I did not treat this fix pass as clean because it is the
last one before merge. Beyond re-deriving S-A1 and S-A2 myself (10.2), I checked the newly-added
S-A6/S-A7/S-A3/S-A5/S-A8/S-A11 fixes against the code, not just the commit message:

- **S-A6** — `publish-release.sh:123-124` now uses `mktemp` for both `NOTES_FILE` and the
  previously fixed-path `EXISTING_BODY_FILE`; `verify-release-surface.sh:253` replaced its
  `$$`-suffixed temp file with `mktemp` too. Confirmed by reading both files, not the diff summary.
- **S-A7** — `CONTRIBUTING.md:310` documents the 0-asset halt-state gap and names `v2.12.0` as the
  live precedent. I checked this live rather than trusting the doc: `gh release view v2.12.0
  --json assets` → `0` assets, today, on the real repo. The claim is true right now, not merely
  written down.
- **S-A3** — `evidence_body()` now surfaces `gh`'s real stderr via a `mktemp`'d capture instead of
  `2>/dev/null`, so a transient `gh` failure reports its real cause instead of being reported as
  `MISSING-RELEASE` with the wrong remedy. Confirmed by reading the function.
- **S-A11** — the AC-PUB-14 CI step's `gh` shim now answers `gh api` calls (needed once
  `assert_gh_destination_repo` runs ahead of it on the live path); the step comment states the
  corrected ordering. Confirmed present and consistent with the commit message.
- **S-A5, S-A8, S-A9, S-A10, S-A12** — message-wording, logging-marker, and deferral-rationale
  items; read directly, no functional guard behavior involved, nothing to destructively test.

No new unguarded surface found in this sweep. That is a statement about what I checked, not a
claim of exhaustiveness the cycle's own history argues against — see 10.7.

### 10.4 15 ACs

All 15 named in `docs/spec.md`. Nine (AC-PUB-1, -6, -8, -9, -10, -11, -12, -13, -14) are
independently re-verifiable pre-merge and I re-ran or re-read every one myself this session, not
merely re-read Phase 5's table:

- **AC-PUB-1** — ran the real `verify-release-surface.sh` against live data (no `--evidence-dir`):
  `8 checked, 4 failed` (`2.19.4`/`2.19.5`/`2.19.6` MISSING-TAG + WRONG-LATEST, `v2.19.3` currently
  Latest). Matches `[P5-CORRECTION-1]`'s State B = 4 exactly, reproduced independently rather than
  taken on the spec's word. This is also the live negative control for **AC-PUB-15** (below).
- **AC-PUB-6** — predicate function read directly (`release-predicate.sh`); the `2.0.2`/`21910`
  collision-avoidance logic and the `---` right-boundary match the spec's exact form. CI's
  `AC-PUB-6` fixture steps (`quality.yml:1799`) passed in the run checked.
- **AC-PUB-8** — `docs/risk-register.md:17`: `CF-v2.19.5-F` closed as MISDIAGNOSED, plain language,
  no longer in the open-rows table.
- **AC-PUB-9** — `VERSION`=`2.19.6`, `CHANGELOG.md:7` `## [2.19.6] - 2026-08-07`, `README.md:7`
  badge=`2.19.6`, all read directly; `Version Consistency Check` = `pass` in `gh pr checks`.
- **AC-PUB-10** — `docs/risk-register.md:12`: 3-item pre-`v2.18.0` mismatch, documentation-only,
  OPEN, no target cycle, cross-referenced to ADR-077/078 §Maturation Path.
- **AC-PUB-11** — `quality.yml:1865` fixture step present and passed; spec's exact assertions
  (COMPARABLE set, IN-SCOPE set, `1.3.2.1` SKIP, exit ≠ 2, zero `not a valid x.y.z semver` in
  stderr) are what the step checks, confirmed by reading it.
- **AC-PUB-12** — `release-surface.yml` triggers read directly: `push: branches:[main]`, `schedule`,
  `workflow_dispatch`; no `pull_request`, no `workflow_run`; `permissions: contents: read` at both
  levels. `quality.yml`'s meta-check greps this file for live-wiring; passed.
- **AC-PUB-13** — documentation-only; `publish-release.sh:216` carries the `[ESTIMATED, not
  verified]` ADR-076 D3 note verbatim; ADR-076's index row (`docs/architecture.md:99`) records the
  v2.19.6 amendment. Thin (single index row, not a full new ADR section) but present, as scoped.
- **AC-PUB-14** — code read confirms the version-mismatch guard (`publish-release.sh:167`) is
  ordered ahead of every `gh` call on the create path; CI's negative control now uses a shimmed
  `gh` (`quality.yml:2044`) rather than the PATH-deleting form that broke Phase 5's first pass, and
  passed in the run checked.

**Three ACs are genuinely not verifiable pre-merge, named as such rather than counted as passing**:
**AC-PUB-2** and **AC-PUB-3** (the `v2.19.4`/`v2.19.5` backfill procedures — Scope A, unrun by this
review's own boundary) and **AC-PUB-15** (`v2.19.6` tagged/released in-cycle — same reason). Their
negative controls are live and RED right now (confirmed in AC-PUB-1 above: all three MISSING-TAG),
which is the correct pre-Scope-A state, not a defect.

**AC-PUB-7** is half-verifiable: the "before" sha256 baseline of all five curated bodies was
captured at Phase 5 and is unchanged (no `gh release edit`/`create` has fired since — confirmed,
zero such calls made by this review either). The "after Scope A" half of the control cannot run
until Scope A does; this is not a gap in this review, it is what the AC itself specifies.

**AC-PUB-4, AC-PUB-5** — WITHDRAWN/RETIRED, confirmed still struck in `docs/spec.md`, not silently
deleted.

No AC claimed as passing here is inferred from narrative; each has a command or a direct code read
behind it, listed above.

### 10.5 Topology

All five phase artifacts (`docs/spec.md`, `docs/design-v2.19.6.md`, `docs/security-review-v2.19.6.md`,
`docs/qa-report-v2.19.6.md`, `docs/security-audit-v2.19.6.md`) are `git ls-files`-tracked at HEAD,
`git status --short` is clean, and `git log main..HEAD` shows real commits touching all five —
nothing living only in a working tree. `docs/spec.md` also exists on `main` (it is this project's
cumulative, cross-cycle spec file by house convention, not a per-cycle artifact) — expected, not a
stranding signal. No Council-hub pipeline state applies here (this is an external registered
project on its own branch/PR, not a Council self-improvement worktree); the relevant topology
question — are this cycle's own artifacts in the PR — is answered yes, directly, by the above.

### 10.6 Scope A readiness

`@security` said it would run Scope A once S-A6/S-A7 landed. Both are in this PR (10.3) and CI is
green. **I concur Scope A is ready to run**, with three things that must hold at run time, not
merely at merge time:

1. **Ascending order, one sitting, halt-on-first-failure** — `v2.19.4` → `v2.19.5` → `v2.19.6`, per
   `docs/spec.md` AC-PUB-2/3/15 and ADR-076's amendment. `AC-PUB-1`'s live State B (10.4) is the
   before-picture; a `workflow_dispatch` re-run of `release-surface.yml` after Scope A is the only
   way to observe State C (`0 failed`) — confirmed the workflow has that trigger (10.4, AC-PUB-12).
2. **OT-8** — `docs/owner-tasks.md` now has a named row requiring the offline smoke-test
   scorecard be current *before* Scope A, and it fires three times (once per tag), not once for the
   batch. Confirmed present in the diff.
3. **This is `publish-release.sh`'s first production use** — zero prior invocations against a real
   release (confirmed at Phase 6, unchanged since). ADR-076 D3's `push: tags`-from-API-created-tag
   assumption is `[ESTIMATED, not verified]` by the script's own header (10.4, AC-PUB-13) and gets
   its first live test here, three times. The halt-state gap (S-A7) is now documented, not closed —
   a halted publish still leaves a public tag+Release behind with no automated cleanup.

None of this is a reason to withhold merge — Scope A is explicitly out of this PR's scope and
stays read-only against the live repo per the boundary given to this review. It is what an operator
running Scope A afterward should have in front of them.

### 10.7 Rework rate, and the estimate miss reported as a miss

`git diff --shortstat c653141 HEAD -- scripts/ .github/workflows/ tests/` (Phase 4 commit → this
review's HEAD, code surface only): **645 insertions, 62 deletions = 707 changed lines** of rework.
`git diff --shortstat main c653141 -- scripts/ .github/workflows/ tests/` (Phase 4's own
delivery): **776 insertions, 3 deletions = 779 changed lines**. **Rework rate ≈ 707 / 779 ≈ 91%** —
nearly as much code churned after the first implementation pass as the first pass itself contained.
Across the full cycle (`main` → HEAD, same surface): **1,364 insertions, 8 deletions = 1,372
lines**, of which 707 (52%) landed after Phase 4 was marked DONE.

This cycle was estimated at 1.5–2 hours (`next-cycle-v2.19.6-publish-what-shipped.md`) and consumed
four implementation passes (`c653141`, `f160393` doc-landing, `c33cb22`, then the two-commit Phase 6
fix pass `89b7843`/`902bf9e`), three QA passes (this one, the Phase 5 AMEND, the Phase 5
re-verification PASS), and two security passes (Phase 2 review, Phase 6 audit). **That is the
estimate miss, stated plainly, not netted against the catch count.** Ten confirmed
green-for-the-wrong-reason defects across this arc is a good outcome for the review layers that
caught them and a bad one for whatever kept producing them at this rate — two of the last three fix
passes each introduced at least one fresh instance of the same class they were fixing (10.3). The
pipeline held the line each time; it should not have needed to hold it this many times on one
cycle sized at under two hours.

### 10.8 Issues prevented this cycle (would have shipped without the pipeline)

| Severity | Count | Items |
|---|---|---|
| Blocker-equivalent (gating, would have shipped a false-safe control on the irreversible write path) | 3 | Phase 5's `assert_destination_repo()` no-op (found by `@qa`); S-A1 WRONG-LATEST no negative control; S-A2 incomplete redirect enumeration (both found by `@security`) |
| Issue (WARNING, fixed pre-merge, non-gating) | 7 | Phase 5's 3 CI failures (ShellCheck, Markdown Lint, AC-PUB-14 harness bug) + S-A3, S-A5, S-A6, S-A7, S-A8, S-A11 minus overlap — see note |
| Info (accepted/deferred, documented) | 3 | S-A9, S-A10, S-A12 |

Note on the issue count: S-A3/S-A5/S-A6/S-A7/S-A8/S-A11 is 6 items; combined with the 3 Phase-5 CI
failures that is 9, not 7 — I am stating the arithmetic rather than quietly rounding: 9 issue-level
items, not 7. Corrected: **9 issue-level items**, all confirmed fixed in 10.3/10.4 above.

### 10.9 Verdict

**APPROVE MERGE.**

What the owner is approving: the release-surface tooling and CI gates in this PR — the shared
predicate, the standing read-only gate, the create-path version guard, the destination-repo
assertions, and their tests — as they exist at `85eaf39`, with CI green and every gating finding
independently re-verified against the code and, where possible, against live data, not merely
re-read from commit messages. Scope A (publishing `v2.19.4`, `v2.19.5`, `v2.19.6`) is **not**
covered by this approval — it has not run, this review did not run it, and per 10.6 it is ready but
carries real first-use risk (ADR-076 D3 untested, 0-asset halt state documented but not closed).

What remains owner-only after merge: running Scope A itself (ascending order, halt-on-first-failure,
`gh` authenticated as the actual repo owner) or delegating it with the OT-8 pre-check satisfied each
time; `OT-7` step 2 (enabling the CODEOWNERS review gate) remains a separate, already-tracked owner
action, unaffected by this cycle; confirming the offline smoke-test scorecard is current before
each of the three tags per OT-8.

---

## v2.19.8 amendment — S-A3 / S-A9 / S-A10 closed-by-v2.19.7

**Additive record.** This report already noted S-A3 as fixed and S-A9/S-A10 as accepted/documented
at v2.19.6 QA (10.3 above); the following re-verifies all three against the shipped v2.19.7 code,
live, this session, and gives each a re-runnable command:

- **S-A3 CLOSED** — `grep -n 'AC-E1-1, v2.19.7' scripts/verify-release-surface.sh` resolves
  (`evidence_body()`'s rc=2 now propagates instead of collapsing into `MISSING-RELEASE`).
- **S-A9 CLOSED** — `bash scripts/semver-compare.sh ge 99999999999999999999.0.0 2.18.0` exits `2`
  (fail-closed on an oversized component, reproduced live).
- **S-A10 CLOSED** — `grep -n 'release-predicate.sh' .github/CODEOWNERS` resolves to
  `@jmlozano1990` (the release-predicate.sh gap named in S-A10 is filled; all four release-critical
  paths now have a real code owner).
