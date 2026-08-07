# Security Audit — Cowork Starter Kit v2.19.6 "Publish What Shipped"

## Phase: 6
## Date: 2026-08-07T13:40:00Z
## Status: PASS WITH WARNINGS
## Audited: `release/v2.19.6-publish-what-shipped` @ `16f9c4471d97b793f1809b03b65af141219bb7e4`
## CI: verified independently — run `31174276416` ("Quality Checks"), `conclusion=success`, `headSha=16f9c447…` (matches branch HEAD). It is the only workflow that runs at this SHA; `release-surface.yml` is `push: main` + `schedule` + `workflow_dispatch` only, which is correct by design.

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S-A1 | WARNING | 6 | logging | `WRONG-LATEST` — the sole control for this cycle's stated Primary success metric — has **no negative control**; deleting it leaves 100% of CI green. Proven by running a neutered copy against every fixture-based CI step. **AMEND-gating.** |
| S-A2 | WARNING | 6 | external-api | The redirect enumeration is incomplete. `gh` resolves its target from `remote.origin.url`; git's own config-injection env vars are outside the guard's two variables and would redirect *both* evidence sources at once. `GH_CONFIG_DIR`/`XDG_CONFIG_HOME` likewise excluded by the comment's closing claim. **AMEND-gating.** |
| S-A3 | WARNING | 6 | logging | `evidence_body()`'s `exit 2` is swallowed by command substitution; any `gh` failure (missing binary, expired token, rate limit) is reported as `MISSING-RELEASE` with a wrong remedy, and exits 1 instead of the documented 2. |
| S-A4 | WARNING | 6 | configuration | The orchestrator's correction block in `docs/security-review-v2.19.6.md` is **accurate but stale** — it stops at fix pass 1 and never mentions the ninth instance, the sibling script, or the shared function. **AMEND-gating.** |
| S-A5 | WARNING | 6 | configuration | The producer-provenance check proves *clean and tracked*; its own error message claims *as-merged*. The half of the Phase-2 S2 prescription that asserted the checkout's commit did not ship, and `AC-PUB-2`'s pre-flight does not cover it either. |
| S-A6 | WARNING | 6 | configuration | Fixed-path temp file (`/tmp/publish-release-existing-body.txt`) on the irreversible path — CWE-59/CWE-377, and a redirect failure silently defeats the idempotence check. `mktemp` is already used 25 lines earlier in the same file. |
| S-A7 | WARNING | 6 | logging | The standing gate reports GREEN for a release with **zero assets**. ADR-076 D3's first-ever live test is Scope A, ×3; the halt state that leaves a public tag+Release behind is documented nowhere. Phase-2 AMEND 8 asked for this; it did not ship. |
| S-A8 | WARNING | 6 | logging | Evidence-injected runs are not self-labelling in the line most likely to be quoted. The `::warning::` banner shipped; the summary-line marker did not. AMEND 6 asked for both; the un-shipped half is the load-bearing one. |
| S-A9 | INFO | 6 | configuration | `semver_ge`'s "malformed ≠ false" contract does not hold for digit-only oversized components; `verify-release-surface.sh:216`'s fail-closed assertion cannot fire for that class. Bounded impact; Phase-2 AMEND 5 deferral upheld, now with evidence. |
| S-A10 | INFO | 6 | permissions | The CODEOWNERS deferral record names 2 of the 5 release-critical paths. The deferral *rationale* is correct (verified live: review gate is off, rows would be inert); the *list* omits the file that now carries the destination guard for both scripts. |
| S-A11 | INFO | 6 | configuration | `quality.yml:2001`'s step comment claims the version guard runs "BEFORE any gh call". It does not — `publish-release.sh:121` runs first. Right test, wrong stated reason. |
| S-A12 | INFO | 6 | external-api | Injection containment **checked and clear** — CHANGELOG content never reaches a `gh` argument, and `::notice::` workflow-command injection is structurally unreachable. Phase-2 AMEND 9 deferral upheld, with the reason. |

Zero CRITICAL. No finding can cause a wrong-destination write on the realistic operator path.

---

## Independent classification verification

The launch prompt states SECURITY-SENSITIVE. Confirmed independently against the Phase-4 diff
(`git diff --stat main...HEAD`, 29 files): three new/modified shell scripts on an irreversible
public-write path, a new GitHub Actions workflow, 375 new lines in `quality.yml`, and a
destination-authorization guard. Full OWASP pass performed. No override needed.

`npm audit`: **N/A** — no `package.json` or `package-lock.json` in this repo (verified). The only
third-party dependency introduced this cycle is one pinned GitHub Action, audited under A06 below.

---

## What I verified myself, and how

Everything below was executed read-only. No tag, no Release, no `gh release create/edit`, no
destructive probe. ADR-076 D3's failure mode was not tested.

| Claim | Method | Result |
|---|---|---|
| `gh` resolves its repo from the git remote | scratch repo, `origin` = `cli/cli`, `gh repo view --json nameWithOwner` | `cli/cli` — confirms the S2 no-op diagnosis |
| `gh api` with an **explicit** repo path ignores `GH_REPO` | `GH_REPO=cli/cli gh api repos/jmlozano1990/Cowork-Starter-Kit/releases/latest` | `v2.19.3` (ours) — @dev's claim is **correct** |
| …but is redirected by `GH_HOST` | `GH_HOST=github.example.invalid` same call | `error connecting to github.example.invalid` — @dev's claim is **correct** |
| A positive destination assertion is available | `GH_REPO=cli/cli gh api "repos/{owner}/{repo}" --jq .full_name` | `cli/cli` (baseline: `jmlozano1990/Cowork-Starter-Kit`) — **same implicit resolution family as `gh release create/edit/view`** |
| `GH_CONFIG_DIR` affects gh's host/auth state | injected scratch config dir, `gh auth status` | flipped from "Logged in to github.com" to "not logged into any GitHub hosts" |
| The guard's enumeration vs. the real doc | `gh help environment`, read in full | `GH_REPO`, `GH_HOST` correct; `GH_CONFIG_DIR` (and `XDG_CONFIG_HOME` via its documented default) not covered |
| `WRONG-LATEST` fires for the right reason | cloned `evidence-clean`, set `latest.txt` = `v2.18.0`, ran the **unmodified** script | `WRONG-LATEST — /releases/latest resolves to 'v2.18.0', expected 'v9.9.9'`, exit 1 — **the code is correct** |
| `WRONG-LATEST` has no CI control | neutered copy (`:291` → `if false`), ran all three fixture-based CI steps | **every assertion still passes** — see S-A1 |
| `semver-compare` on an oversized component | `bash scripts/semver-compare.sh ge 99999999999999999999.0.0 2.18.0` | `integer expected` ×2 on stderr, prints `false`, **exit 1 not 2** |
| The AC-PUB-11 stderr grep can actually fire | `grep -n` for the literal in `semver-compare.sh` | `:44` emits `::error::not a valid x.y.z semver: '<v>'` — **not** a check that cannot fail |
| Live enforcement state of `main` | `gh api repos/…/branches/main/protection`, `…/rulesets` | `require_code_owner_reviews=false`, `required_approving_review_count=0`, **no `required_status_checks` key**, rulesets empty; `enforce_admins=true`, force-push and deletion blocked; repo `public` |
| Live `/releases/latest` | `gh api repos/…/releases/latest` | `v2.19.3` — Scope A's ascending-order requirement is live and load-bearing |

**One probe I could not run.** The harness refused every command setting `GIT_CONFIG_COUNT`
(worktree-isolation guard). So the composed chain in S-A2 — git-config env override → redirected
`remote.origin.url` → redirected `gh` target — is **reasoned from documented behaviour plus a proven
resolution path, not executed end-to-end**. Marked unverified there, and it is the one claim in this
audit I would want re-run by someone without that constraint.

---

## The two questions the task put to me first

### Is my own Phase-2 remedy's correction accurate and sufficient?

**Accurate: yes.** I re-derived the mechanism rather than inheriting it. `gh repo view` resolves from
the git remote (proven above, in a scratch repo whose only remote was `cli/cli`), and the
`release`-family commands honour `GH_REPO` (proven above via the `{owner}/{repo}` placeholder, which
resolves through the same path). The correction's central claim — *the guard passed precisely when the
redirect was active* — is correct, and the diagnosis "it passes when the attack succeeds" is the right
way to say it.

**Sufficient: no — see S-A4.** Two gaps, both in `docs/security-review-v2.19.6.md:230`:

1. It describes what shipped as an inline two-variable test in `publish-release.sh`, at `c33cb22`.
   What is actually at HEAD (`16f9c44`) is `refuse_if_gh_redirect_env_set()` in
   `scripts/release-predicate.sh:97`, called by **two** scripts. The ninth instance — the sibling-script
   gap that is the entire reason the guard moved into shared code — appears nowhere in the document:
   `grep` returns zero hits for `ninth`, `verify-release-surface`, `evidence_body`, and
   `refuse_if_gh_redirect`. A future cycle reading this review learns the publish-only story, and the
   lesson it teaches is *"guard the write"* rather than *"guard the hop"* — which is exactly the framing
   that produced the ninth instance. The correction block's own closing paragraph names this failure
   mode; it now exhibits a milder form of it.
2. Its closing sentence — *"No other documented `gh` environment variable affects repo/host
   resolution"* — is over-broad. `GH_CONFIG_DIR` is documented and does affect host/auth resolution
   (proven above). See S-A2.

Nobody has reviewed that correction until now. Both gaps are text-only fixes.

### Is the shared guard actually sound, or does it merely look sound?

**Sound as far as it reaches, and it reaches further than the previous form by a wide margin.** Three
properties I confirmed rather than assumed:

- It is `gh`-independent and runs **before** the first `gh` call in each caller
  (`publish-release.sh:84` vs. `:121`; `verify-release-surface.sh:104` vs. the seam functions defined
  at `:107`+). The earlier idempotence read really was exposed, and now is not.
- It is anchored in CI **through the real shipped scripts at both call sites**
  (`quality.yml:2010`, `:2073`), not against a re-implementation. Both negative controls are genuinely
  load-bearing: with the guard removed, `verify-release-surface.sh` under `GH_REPO=cli/cli` would exit
  1 (not 2) and would print a `release-surface: N checked` summary — and the step asserts against
  **both** of those. Deleting the `source` line or the call would go red.
- It fires in `--evidence-dir` mode too, which is asserted (`quality.yml` "Defense-in-depth" leg) and
  visible in the code ordering. The seam cannot route around it.

**But its stated coverage is broader than its actual coverage** (S-A2). The guard refuses on two
environment variables and its comment argues, at `release-predicate.sh:75-96`, that this is the
complete set. Two things fall outside:

- **git's own configuration surface.** `gh` derives its target from `remote.origin.url`. `git-config(1)`
  documents `GIT_CONFIG_COUNT` / `GIT_CONFIG_KEY_<n>` / `GIT_CONFIG_VALUE_<n>` as overriding
  configuration-file values for any git process, and `gh` inherits the environment when it shells out.
  A single env triple would therefore redirect **both** `gh release view/create/edit` **and**
  `evidence_tags()`'s `git ls-remote --tags origin` — the two evidence sources the guard's own comment
  cites as independently safe. @dev's statement that "`git ls-remote` reads neither" is true of the two
  `GH_*` variables and is not a safety property of the tag conjunct. *(Mechanism documented and the
  resolution path proven; the composed chain is **unverified** — the harness blocked the probe.)*
- **`GH_CONFIG_DIR`, and `XDG_CONFIG_HOME` behind it.** Proven to change gh's authenticated-host state.
  Its *proven* effect is fail-closed (unauthenticated → the `gh` call fails). Whether a crafted config
  directory can produce a **false PASS** rather than a false RED is **unverified** — it would require
  standing up a responding host, which is outside this audit's read-only constraint.

Extending the deny-list is the wrong remedy: `XDG_CONFIG_HOME` is set for entirely benign reasons on
many workstations, so refusing on it would be a usability regression, and the list can never be closed
by construction. **The right remedy exists and I verified it works:**

```sh
ACTUAL_REPO="$(gh api "repos/{owner}/{repo}" --jq '.full_name')"
[ "$ACTUAL_REPO" = "$EXPECTED_REPO" ] || refuse
```

`gh` resolves the `{owner}/{repo}` placeholder through **the same implicit path** `gh release
create/edit/view` uses — confirmed live: `GH_REPO=cli/cli` makes it return `cli/cli`, baseline returns
`jmlozano1990/Cowork-Starter-Kit`. Being a positive assertion, it is true-by-construction against every
redirect vector simultaneously, including the aliased-`--repo` wrapper the guard's comment explicitly
excludes (an alias that injects `--repo X` into `gh` would inject it into the assertion too, and the
assertion would fail). It costs one authenticated API call, so it complements the env refusal rather
than replacing it: keep the refusal for the offline/evidence-dir path, add the assertion on the live
path. This is what my Phase-2 "sixth recommendation" should have said.

---

## CRITICAL

*(none)*

## WARNING

### S-A1 — `WRONG-LATEST` ships with no negative control, and CI cannot detect its removal

`scripts/verify-release-surface.sh:283-297` · absent from `.github/workflows/quality.yml:1790-2166`

`grep` for `WRONG-LATEST` and `latest.txt` across `quality.yml` and `release-surface.yml` returns
**zero hits**. The only fixture carrying a `latest.txt` is `evidence-clean`, where it is *correct*
(`v9.9.9`) — that proves the check does not false-fire, and proves nothing about whether it fires.

I tested removal directly. A copy of the script with `:291` changed to `if false; then`, run against
every fixture-based CI step in the job:

- `AC-PUB-11` — exit 1, `2 checked`, both `SKIP` lines, no `not a valid x.y.z semver` on stderr → **all four assertions pass**
- `AC-PUB-12` negative — exit 1, `9.9.9 MISSING-TAG` → **both assertions pass**
- `AC-PUB-12` positive — exit 0 → **passes**
- `CHECKED==0`, and both destination-guard steps → unaffected, they exit before this code

The `AC-PUB-11` step asserts the *checked* count but never the *failed* count, which is why the
difference (2 failed vs. 3 failed) goes unnoticed. **Deleting the conjunct entirely leaves this
cycle's CI 100% green.**

Why this is the finding that matters most in this particular cycle:

- It is the sole control for the spec's own **Primary success metric** (`docs/spec.md:6674-6676` — "a
  visitor following `homepageUrl` … sees a Release body that describes the version they clicked").
- It is the sole automated check on **Scope A's ascending-order requirement**
  (`docs/spec.md:6300`), which is about to execute three irreversible publishes.
- `/releases/latest` is `v2.19.3` today (verified live), so this conjunct will be RED at the
  feature-merge run and GREEN only if Scope A is ordered correctly. It is doing real work, untested.

The remedy is one fixture and one step, and I have already run both: clone `evidence-clean` to
`tests/fixtures/release-surface/evidence-wrong-latest/`, set `latest.txt` to an older in-scope version,
and assert exit 1 plus a `WRONG-LATEST` line. Against the **unmodified** script that fixture produces
exactly `::error::release-surface: WRONG-LATEST — /releases/latest resolves to 'v2.18.0', expected
'v9.9.9'` and exit 1. The control works; nothing exercises it.

### S-A2 — the redirect enumeration is incomplete, and the comment says otherwise

`scripts/release-predicate.sh:75-96` (the coverage claim) · `:97-108` (the guard)

Full argument and remedy under *"Is the shared guard actually sound"* above. In short: the guard covers
the two variables `gh help environment` documents for repo/host selection, which is right as far as it
goes. It does not cover `gh`'s **inherited** resolution surface (git config, env-injectable per
`git-config(1)`) or `GH_CONFIG_DIR`/`XDG_CONFIG_HOME`, and `:96` asserts there is nothing else. Fix the
sentence at minimum; add the positive `gh api "repos/{owner}/{repo}"` assertion for a real close.

### S-A3 — `evidence_body()`'s `exit 2` is swallowed; every `gh` failure becomes `MISSING-RELEASE`

`scripts/verify-release-surface.sh:121-132`, called at `:260`

```sh
if ! BODY="$(evidence_body "$tok")"; then
```

`exit 2` inside `$( )` terminates only the subshell, and `set -e` is suppressed inside an `if`
condition. So the gh-unavailable branch at `:127-130` does not reach the documented contract at `:14`
(*"2 = usage, environment, or contract error — fail-closed, never a pass"*). Instead the run prints
`MISSING-RELEASE` for **every** in-scope version and exits 1.

The same collapse covers realistic transient failures — expired token, rate limit, network — because
`gh release view` returns non-zero for "no such release" and for "could not reach GitHub" alike, and
`2>/dev/null` discards the distinction. The printed remedy (`:262`, "same producer; it creates tag and
Release atomically") is then wrong advice about releases that already exist.

Note the inconsistency across the three seams: `evidence_tags()` (`:180`) and `evidence_latest()`
(`:289`) are plain assignments, so `set -e` **does** abort with 2 there. Only the one wrapped in an
`if` loses it.

This is the same shape `scripts/semver-compare.sh:36-40` already carries a written warning about
(CF-v2.19-B: *"an `exit` there only kills that subshell … the return code went unnoticed"*). The lesson
was recorded in one file and re-made in a new one.

Verdict impact is fail-closed (still RED). The **diagnosis** is what is wrong, in the artifact this
cycle exists to make trustworthy.

### S-A4 — the review-document correction is accurate but stale

`docs/security-review-v2.19.6.md:221-232`, `:504-512` — full argument above.

### S-A5 — the provenance check proves less than its error message claims

`scripts/publish-release.sh:55-66`

`git status --porcelain -- scripts/publish-release.sh scripts/release-predicate.sh` proves the two
files are **tracked and clean**. `:64` prints *"This script must run as-merged, with no ad-hoc local
edit."* It enforces the second clause only. A `MAIN_REPO_ROOT` sitting on the feature branch, or on an
older `main`, passes silently.

My Phase-2 S2 prescription had two halves (`docs/security-review-v2.19.6.md:206-211`: *"the main
checkout is at the expected merge commit, its working tree is clean … and both files are tracked at
`HEAD`"*). The first half did not ship, and `AC-PUB-2`'s pre-flight (`docs/spec.md:6483-6493`) does not
compensate: all four of its assertions are about the **detached worktree**, none about the checkout the
executing **code** is read from — which is precisely the split `BASH_SOURCE` resolution creates and
which the provenance check was added to cover.

Harmless this cycle (branch and post-merge `main` will carry identical bytes for these two files). The
check simply does not prove what it says, and a later reader will believe it does. Remedy: either add
the commit assertion, or soften `:64` to what is actually enforced.

### S-A6 — fixed-path temp file on the irreversible path

`scripts/publish-release.sh:121-123`

```sh
if gh release view "$TAG" --json body -q '.body' > /tmp/publish-release-existing-body.txt 2>/dev/null; then
```

A fully predictable name in a world-writable directory, on the operator's workstation, in a script
about to perform three irreversible public writes. The same file uses `mktemp` twenty-five lines
earlier (`:96`) — the inconsistency is the tell, not a judgement call.

Two consequences:

1. **CWE-59 / CWE-377.** A symlink pre-planted at that name causes `>` to truncate and write through
   to the link target as the invoking user. Worth noting in combination with S-A5: this is an
   attacker-influenced write that the new provenance check **cannot see**, because it modifies nothing
   tracked. Hardening the script's bytes while leaving a predictable `/tmp` path beside it leaves the
   softer door open.
2. **The idempotence check can be silently defeated.** If the redirect merely *fails* (the path exists,
   owned by another user), the `if` condition is false, control falls to the CREATE branch for a tag
   that already exists, and `gh release create` errors out. Fail-closed, but for a reason the operator
   will not be able to read off the output.

`scripts/verify-release-surface.sh:213,218-219,222` is the same class with a `$$` suffix — meaningfully
weaker exposure (PID-scoped, CI-side), same one-line fix. Remedy for both: `mktemp` plus the `trap`
that is already there.

### S-A7 — the standing gate reports GREEN for a release with zero assets

`scripts/verify-release-surface.sh` (whole file — tag, Release existence, body, latest; **no** asset
conjunct) · `scripts/publish-release.sh:187-214`

The asset poll halts **after** `gh release create` has already made the tag and Release public. ADR-076
D3 — whether an API-created tag raises `push: tags` — is still unverified, and Scope A is its first
live test, three times consecutively. If it fails, the operator is left with:

- a published, publicly visible tag and Release with 0 assets,
- a script that exited 1, and
- a standing gate that will report that version **green**, because assets are outside its predicate.

`v2.12.0` is the live precedent — 0 assets today after a failed run, and the new gate would call the
release surface clean with it in place.

The remedy steps **did** ship, and in the better location (`publish-release.sh:203-212`, the
delete-and-recreate sequence, correctly replacing the no-op "re-push the tag"). What did not ship is
the *"the gate goes green anyway"* fact. My Phase-2 AMEND 8 asked for it in `CONTRIBUTING.md`; the
`CONTRIBUTING.md` diff adds the standing-gate bullet and the per-tag smoke-test note and not this.

This item has **become load-bearing since Phase 2** — precisely because the gate now exists. Before this
cycle there was no green signal available to be misled by. It is one paragraph.

### S-A8 — evidence-injected runs are not self-labelling where it counts

`scripts/verify-release-surface.sh:77` (banner, shipped) · `:299` (summary, unmarked)

Phase-2 AMEND 6 asked for two things: a `::warning::` banner **and** an explicit marker in the summary
line. The banner shipped. The summary did not — observed directly in my own runs:

```
release-surface: 1 checked, 0 failed, 0 skipped (0 non-x.y.z, 0 below-floor).
```

That line is byte-identical whether the run read live data or a fixture directory. The banner is the
half that survives in a full CI log; the summary line is the half that survives a copy-paste into a
retro, a PR body, or a risk-register row. For a cycle whose subject is records that read as
authoritative while being false, the un-shipped half is the load-bearing one. One string change.

---

## INFO

### S-A9 — `semver_ge`'s fail-closed contract does not hold for oversized components

Ran: `bash scripts/semver-compare.sh ge 99999999999999999999.0.0 2.18.0` →
`[: 99999999999999999999: integer expected` (×2, stderr), prints `false`, **exit 1**.

`scripts/semver-compare.sh:43` accepts it (the regex is `[0-9]+`, unbounded); `:63`/`:64`'s `[ -gt ]`
and `[ -lt ]` both return 2 on a value beyond bash's integer range, so both `if`s fall through and
`:65` compares *minors* — yielding a clean "false". `:50-52`'s *"Malformed input is a DISTINCT return
code from 'false' (fail-closed, CF-v2.19-B)"* is therefore false for this input class, in the file
written to close CF-v2.19-B.

Downstream in `verify-release-surface.sh`: such a token is reported `SKIP — below floor 2.18.0` — a
wrong reason — and the `GE_RC -eq 2` branch at `:216`, documented at `:204-209` as an
*"UNREACHABLE-BY-CONSTRUCTION assertion"*, turns out to be unreachable partly because the comparator
never returns 2 for the one malformed class the parser lets through. A check that cannot fail.

Impact is bounded: it requires a merged CHANGELOG header with a >19-digit component, and the outcome is
a skipped version, never a false green on a real one. My Phase-2 AMEND 5 named this and the deferral
**remains sound on impact** — it now rests on evidence instead of assertion. Cheapest fix is AMEND 5's:
bound the component length in the parser regex at `verify-release-surface.sh:198`.

### S-A10 — the CODEOWNERS deferral record names 2 of 5 release-critical paths

`docs/spec.md:6374-6378`

The deferral *rationale* is correct and I verified it live, read-only:
`require_code_owner_reviews=false`, `required_approving_review_count=0`, **no `required_status_checks`
key at all**, and `rulesets` empty. The rows would be inert, exactly as the record says. **Deferral
upheld** — this is not a request to reopen it.

What has changed is the *list*. The record names `publish-release.sh` and `release-assets.yml`. Not
named: `scripts/release-predicate.sh`, `scripts/verify-release-surface.sh`,
`.github/workflows/release-surface.yml`. `.github/CODEOWNERS` is unmodified this cycle (confirmed
absent from `git diff --stat main...HEAD`).

`scripts/release-predicate.sh` is now the single highest-leverage file in the release path — it carries
both the body predicate and the destination guard for two scripts — and it is missing from the list a
future implementer of OT-7 step 2 will work from. Of the seven deferred Phase-2 AMEND items, this
(AMEND 10) is the **one that has become load-bearing**, and its cost is three lines of deferral text.

Worth stating alongside it, since it bounds every other control in this audit: with no
`required_status_checks` on `main`, `quality.yml` — where **every** negative control for the
destination guard lives — is advisory. A red CI does not block a merge here. That is pre-existing and
already accepted (`v2.19.5-CODEOWNERS-1`, OT-7 step 2, both OPEN), not new this cycle; but this cycle
places materially more security-critical logic behind it.

### S-A11 — a step comment claims a placement the code does not have

`.github/workflows/quality.yml:2001` — *"expected exit 1 from the version guard BEFORE any gh call."*
The version guard is `scripts/publish-release.sh:145-152`; `gh release view` runs first, at `:121`. The
step tests the right property (the guard fires with `gh` shimmed to exit 127, distinguishing 1 from 127
correctly) for a stated reason that is wrong. Comment-only fix; named because mis-stated rationales are
this cycle's subject.

### S-A12 — injection containment: checked, and clear

Recorded as a finding so that "we looked" is distinguishable from "nobody looked."

- **CHANGELOG content reaching `gh` arguments: contained.** Notes travel by file
  (`publish-release.sh:128`, `:159` — `--notes-file "$NOTES_FILE"`, a `mktemp` path), never as an
  inline argument. `$VERSION` is validated `^[0-9]+\.[0-9]+\.[0-9]+$` at `:90` before every subsequent
  use, including the `awk -v ver=` at `:102`. `body_names_version` uses `grep -qF` on both legs, so
  neither the body nor the version argument is ever a regex.
- **Workflow-command injection via printed tokens: unreachable.** `verify-release-surface.sh:194` and
  `:199` do print the raw CHANGELOG header token *before* classification, into `::notice::` lines. But
  `grep -o '^## \[[^]]*\]'` (`:178`) is line-oriented and its character class excludes `]`, so a token
  can contain neither a newline nor a bracket — and a GitHub workflow command must begin a line. There
  is no way to reach column 0 from inside `release-surface: '<tok>' SKIP …`.
- My Phase-2 AMEND 9 (S12/S13) asked for `::`-stripping and a written containment requirement. **The
  deferral is sound**, and the reason above is why. Writing the requirement down (the other half of
  AMEND 9) would still be worth a line, since the property currently holds by accident of the parser
  rather than by stated contract.

---

## Controls that hold — audited against this cycle's base rate

Nine green-for-the-wrong-reason instances in one cycle, two introduced by fixes for earlier ones, one
authored by my own review. Every control below was checked for whether it fails for the reason it
claims, not merely whether it is green.

| Control | Fails for the reason it claims? |
|---|---|
| Destination guard, `publish-release.sh` (`quality.yml:2010`) | **Yes.** Asserts exit 1 *and* the specific message, both variables, plus a positive control that reaches the *next* real guard (`refusing to CREATE tag`) — so a false-positive firing is caught too. |
| Destination guard, `verify-release-surface.sh` (`quality.yml:2073`) | **Yes**, and this is the strongest control in the cycle. It asserts exit **2** *and* that no `release-surface: N checked` summary is ever printed. Remove the guard and both flip (exit 1, summary printed). It also asserts the guard fires **with `--evidence-dir` given**, closing the seam-bypass question by test rather than by argument. |
| `AC-PUB-6` predicate fixtures | **Yes.** Each negative leg is paired with a *fixture-validity* control asserting the naive predicate **does** match — so a fixture that stops carrying the collision fails loudly instead of passing vacuously. This is the pattern the rest of the cycle should be measured against. |
| `AC-PUB-11` stderr assertion | **Yes.** The grepped literal is the one `semver-compare.sh:44` really emits (verified) — not a string that can never appear. |
| `AC-PUB-12` positive control | **Yes, and discriminatingly.** `evidence-clean/bodies/9.9.9.body` contains no dotted `9.9.9` — only `CHANGELOG.md#999---`. It exercises the **anchor leg specifically**, which is the leg this cycle added. |
| `AC-PUB-14` (create-path guard, `gh` shimmed) | **Yes** — distinguishes exit 1 from exit 127, which is exactly what @qa's root-cause required. Stated rationale is wrong (S-A11); the test is right. |
| `CHECKED==0` fail-closed | **Yes** — asserts exit 2 *and* the documented diagnostic string. |
| C3 seam containment | **Yes** — greps the live workflow for the flags; `release-surface.yml`'s header even avoids naming them in prose so it cannot trip its own guard. Careful work. |
| `WRONG-LATEST` | **No control exists.** S-A1. |

Two structural points worth recording as sound:

- **One shared definition beats two copies plus a `cmp` mirror.** I endorsed this at Phase 2 and it has
  now been vindicated twice within the same cycle (`release-predicate.sh:7-15` records both). More to
  the point, the shared function is anchored in CI at **both** call sites through the real scripts, so
  removing the `source` line or the call goes red. Sharing without that anchoring would have been worse
  than copying; it has the anchoring.
- **The guard belongs to the hop, not the caller.** `release-predicate.sh:66-73` re-words the guard
  around *"any `gh` call whose target can be redirected"* rather than *"the pre-flight before an
  irreversible write."* That re-framing is the actual fix for the ninth instance — the code change
  alone would have left the next `gh` call to be added just as exposed. It is correct and it is the
  right lesson. It only needs to reach the review document too (S-A4).

---

## Re-examining my Phase-2 residual on the `--evidence-dir` seam

Phase 2 concluded: *the seam confers no new privilege, because editing the workflow and deleting the
gate require the same access.*

**The relative claim still holds.** `--evidence-dir` changes where evidence is **read from**, not
whether the guard runs — asserted by test now, not just by construction (`quality.yml`, the
defence-in-depth leg). CI invokes the script with no flags and `quality.yml`'s C3 step greps the live
workflow to keep it that way. And the seam is genuinely earning its place: every negative control in
this cycle is executable offline because of it.

**Two things have changed underneath it**, and both make the residual weaker in absolute terms even
though the comparison it makes is still true:

1. **The blast radius of one file grew.** `scripts/release-predicate.sh` now carries the body predicate
   **and** the destination guard for two scripts. A single edit to one file can neuter both. Phase 2
   reasoned about a seam next to a predicate; the object it sits beside is now the release path's
   authorization check as well. The mitigation is real — `quality.yml` would go red at both call sites
   — but see the next point.
2. **The "same access" floor is lower than the Phase-2 sentence implied.** Verified live: no required
   status checks, no required approvals, `require_code_owner_reviews=false`, no rulesets. So "requires
   the same access" resolves to "requires the ability to merge", and a red `quality.yml` does not stop
   a merge. The CI anchoring that makes the shared guard tamper-evident is **detective, not
   preventive**, on this repository today.

Neither changes my Phase-2 disposition on the seam itself — I would ship it again. But the sentence
should not be quoted forward as though it establishes an absolute floor. It establishes a comparison,
and the floor it compares against is at ground level until OT-7 step 2 lands.

---

## Scope A: would I run it as specified?

**Yes — with S-A6 fixed first and S-A7's halt-state fact written down before the operator starts.**
Both are cheap; neither is a redesign.

The pre-flight is a genuinely good last line of defence, and I want to be specific about why rather
than wave at it. Layered, in execution order, everything below fails closed:

1. `BASH_SOURCE`-relative include with an explicit refusal if the predicate is missing
   (`publish-release.sh:40-43`) — the one thing the detached-worktree procedure could plausibly break.
2. Producer provenance — tracked and clean (`:56-66`; weaker than advertised, S-A5, but not absent).
3. Unconditional environment refusal before any `gh` call (`:84`).
4. Semver validation of the version (`:90`).
5. Non-empty dated CHANGELOG section, or refuse (`:112-115`).
6. Create-path-only `VERSION`-at-HEAD precondition (`:145-152`) — with @qa's corrected negative-control
   token behind it.
7. Body post-condition (`:163-175`) **and** a second body post-condition after the asset upload
   (`:229-236`) — S3's fix, and the only body check covering the three new releases.
8. `AC-PUB-2`'s four worktree assertions, full 40-char SHA (`docs/spec.md:6486-6493`).

Against three irreversible publishes on a script that has never created a release, that is a
proportionate set. My two pre-conditions:

- **S-A6 (`mktemp`)** — one line, in the file, on the path, before the first-ever production run.
  Leaving a predictable `/tmp` write beside a freshly added provenance check is the wrong shape to ship.
- **S-A7 (halt state, one paragraph)** — this changes what the operator *does* when the most likely
  failure occurs. ADR-076 D3 is unverified; if the asset poll fails on publish #1, the operator needs
  to already know that the tag and Release are public, that the script's remedy block is the correct
  path, and that the standing gate will read green regardless. Discovering that at 2am mid-backfill is
  the avoidable part.

Not pre-conditions, but I would want them before the *next* use rather than this one:

- **S-A2's positive destination assertion.** The env refusal covers the realistic accidental case
  (`GH_REPO` exported in a shell), which is the case that actually happens. The uncovered vectors need
  either an attacker on the box or an unusual configuration. I would not hold three publishes for it —
  but it is the assertion that makes the whole question go away, and it is four lines.
- **S-A1's fixture.** Ascending order is the constraint Scope A must satisfy, and `WRONG-LATEST` is the
  only thing that checks it. It will be exercised for real either way, and its output is human-readable;
  I would rather it were also tested.

One operational note, not a finding: `/releases/latest` is `v2.19.3` right now. After publish #1 it
becomes `v2.19.4`, after #2 `v2.19.5`, after #3 `v2.19.6`. If the run halts partway, the public landing
page is left pointing at an **intermediate** version until the sequence resumes — correct behaviour,
worth expecting rather than being surprised by.

---

## The three new releases have no standing body-integrity baseline

Raised here because it did not exist at Phase 2 — the releases did not exist.

`AC-PUB-7`'s `sha256` window covers the **five pre-existing curated bodies** and closes after Scope A.
Nothing establishes a baseline for `v2.19.4`, `v2.19.5`, `v2.19.6` after they are published.
`publish-release.sh:229-236` re-asserts each body within its own run, which is the right control at the
right moment and covers the asset-upload hazard — but it is a point-in-time check, not a standing one.

The standing gate's predicate is *"the body names its version"*. A body edited afterwards in the GitHub
UI — the exact mutation this cycle exists because of — keeps the gate green as long as the version
string or anchor survives anywhere in it. That is by design (ADR-077 chose a naming predicate, and I
still think that is right), but it means the surface that motivated the cycle is only partly covered
for the three releases the cycle creates.

**INFO, no action requested this cycle.** Recording it so a future `AC-PUB-7`-style window can be
opened over the new bodies deliberately rather than discovered missing.

---

## OWASP Top 10 Assessment

Mapped to this surface (shell producer + CI detector + GitHub API), not to a web application.

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | **PARTIAL** | Destination authorization is now real and CI-anchored at both call sites — a large improvement over Phase 2, where it did not exist, and over fix pass 1, where it was a no-op. Incomplete enumeration (S-A2). Repository-level review gate remains off (`require_code_owner_reviews=false`, 0 approvals, no required checks — verified live); pre-existing, accepted, tracked as OT-7 step 2 / `v2.19.5-CODEOWNERS-1`. |
| A02 Cryptographic Failures | **PASS** | No secrets handled beyond `GH_TOKEN` passed via workflow `env`. The guard echoes `GH_REPO`/`GH_HOST` values only — never a token. No credential is written to a file or a log by any script audited. |
| A03 Injection | **PASS** | See S-A12. CHANGELOG content never becomes a `gh` argument; version strings are regex-validated before use; both predicate legs use `grep -F`; workflow-command injection via printed tokens is structurally unreachable. |
| A04 Insecure Design | **PARTIAL** | The core design calls are right (shared definition; parser-stage classification; `pull_request` prohibited; `workflow_run` rejected; the seam). Gaps are in control *coverage*, not shape: S-A1 (untested conjunct), S-A7 (asset blind spot + undocumented halt state), S-A3 (contract collapse). |
| A05 Security Misconfiguration | **PASS** | `release-surface.yml`: `permissions: contents: read` at both workflow and job level; `concurrency` with `cancel-in-progress`; triggers each justified in-file; `pull_request` explicitly prohibited with the reason. No misconfiguration found in the new workflow. |
| A06 Vulnerable and Outdated Components | **PASS** | No package manifest in this repo (`npm audit` N/A — verified). One third-party dependency added: `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683` — full-SHA pinned, comment-tagged `v4.2.2`, matching the SHA used elsewhere in `quality.yml`. Correct supply-chain hygiene. |
| A07 Identification and Authentication Failures | **PASS** | No authentication logic introduced. `GH_TOKEN` is scoped to the one step that needs it; `permissions: contents: read` bounds it. |
| A08 Software and Data Integrity Failures | **PARTIAL** | Producer provenance added (S-A5: weaker than its own message). Release-body integrity is asserted twice per run including after the third-party `softprops/action-gh-release` step — the right fix for S3. No standing baseline for the three new bodies (§ above). Supply-chain review gate off (A01). |
| A09 Security Logging and Monitoring Failures | **PARTIAL** | The standing gate **is** the new monitoring, and it is a real improvement — three distinct, greppable, non-collapsed failure tokens each with its own remedy, plus a documented fail-closed `CHECKED==0` path. Three defects in its reporting: S-A1 (untested conjunct), S-A3 (misdiagnosis on `gh` failure), S-A8 (evidence-injected runs not self-labelling in the summary). |
| A10 Server-Side Request Forgery | **N/A / covered** | The closest analogue is `GH_HOST` host redirection, which the guard refuses (and which I confirmed redirects even explicit-path `gh api` calls). No user-supplied URL is fetched by any script audited. |

**LLM threat assessment (LLM01/02/06):** N/A. No LLM-facing surface, no prompt construction, no
model-consumed untrusted content in the audited code.

---

## Phase-2 AMEND items 5-11: is the deferral still sound?

Confirmed against the shipped code, not against the Phase-2 reasoning.

| # | Item | Shipped? | Disposition now |
|---|---|---|---|
| 5 | (S11) semver component-range bound | No | **Deferral upheld** — mechanism confirmed live (S-A9), impact still bounded to a skipped version. Now evidence-backed. |
| 6 | (S6) self-identifying injected runs | **Half** | **Became load-bearing** — the shipped half (banner) is the one that survives in a full log; the un-shipped half (summary marker) is the one that survives a paste. S-A8. |
| 7 | (S9) capture the RED-window run ID | No | **Deferral upheld, and my Phase-2 framing was wrong.** I called the evidence "perishable"; it is not — the `push: main` run persists in Actions history and is retrievable by workflow name. Lower urgency than I claimed. |
| 8 | (S8) document the halt state | No | **Became load-bearing** — because the gate now exists and will read green over a 0-asset release. S-A7. |
| 9 | (S12/S13) injection containment as a requirement | No | **Deferral upheld**, with the reachability argument now written down (S-A12). Worth one line stating the property as a contract rather than a parser accident. |
| 10 | (S7) widen the CODEOWNERS deferral list | No | **Became load-bearing** — `release-predicate.sh` now carries the destination guard and is absent from the list OT-7 step 2 will work from. Rationale for the deferral itself verified correct and upheld. S-A10. |
| 11 | (S2) destination assertion | **Yes**, differently and better | Implemented as an unconditional refusal rather than my (wrong) `gh repo view` form. Correct call. Coverage claim over-broad (S-A2); review-document record stale (S-A4). |

Three of seven have become load-bearing (6, 8, 10). All three are text or one-string changes. None
requires code redesign.

---

## Summary

The shipped guard is materially better than what I prescribed at Phase 2, and better than what shipped
at fix pass 1. Moving it into a shared function, re-framing it around the **hop** rather than the
**caller**, running it before the first `gh` call in both scripts, and anchoring it in CI against the
real shipped scripts at both call sites — that is the right fix, arrived at by the right reasoning. The
sibling-script catch (`@qa` §9.5) is the strongest single piece of work in the cycle: it found a false
PASS, demonstrated it live, and the fix generalised the control rather than patching the instance.

My own Phase-2 sixth recommendation was wrong, was implemented verbatim, and shipped as a no-op. The
orchestrator's correction of it is accurate and I re-derived the mechanism rather than accepting it.
The correction is **not sufficient** — it stops at fix pass 1 and never mentions the ninth instance,
the sibling script, or the shared function, so the document still teaches *"guard the write"* instead
of *"guard the hop"*, which is the framing that produced the ninth instance in the first place. Fixing
that is two paragraphs, and it is the highest-value item in this audit after S-A1.

Against a base rate of nine green-for-the-wrong-reason instances in one cycle, I checked every control
that ships for whether it fails for the reason it claims. Most do, and several — the `AC-PUB-6`
fixture-validity controls, the `verify-release-surface.sh` guard test that asserts the summary line is
*never printed*, the anchor-only positive-control body — are better than the cycle needed them to be.
One does not: `WRONG-LATEST` has no control at all, and I proved by execution that deleting it leaves
CI entirely green. It is the sole check on the cycle's stated Primary success metric and on Scope A's
ascending-order requirement. In this cycle, of all cycles, that one has to be closed before the pattern
is called retired.

No CRITICAL. Nothing here can cause a wrong-destination write on the realistic operator path — the env
refusal covers the accidental `GH_REPO` case and is proven to fire through both real scripts. Scope A
can proceed once S-A6 (one line) and S-A7 (one paragraph) are in place.

**Unverified, stated as such:** (a) the composed git-config-env → redirected `gh` target chain in S-A2
— mechanism documented and resolution path proven, but the harness refused every `GIT_CONFIG_COUNT`
probe, so it was not run end-to-end; (b) whether a crafted `GH_CONFIG_DIR` can produce a false PASS
rather than the fail-closed behaviour I did observe; (c) ADR-076 D3 — untested by design, and I did not
test it.

---

## Verdict

**AMEND**

Gating on three items, all text or one-line changes:

1. **S-A1** — add the `WRONG-LATEST` negative control. One fixture (`evidence-wrong-latest/`, a clone
   of `evidence-clean` with `latest.txt` set to an older in-scope version) and one `quality.yml` step
   asserting exit 1 and a `WRONG-LATEST` line. Both built and run during this audit; the unmodified
   script produces the expected RED.
2. **S-A2** — correct `scripts/release-predicate.sh:96`'s completeness claim to what is actually
   covered. Adding the positive `gh api "repos/{owner}/{repo}"` assertion is the real close and is
   recommended, but only the corrected claim is gating.
3. **S-A4** — extend the correction block in `docs/security-review-v2.19.6.md:230` to describe what is
   at HEAD: the shared function, both callers, and the ninth instance that caused the move.

Plus two before Scope A executes: **S-A6** (`mktemp`) and **S-A7** (halt-state paragraph).

The remaining WARNINGs (S-A3, S-A5, S-A8) and all INFO items are recordable as carry-forwards and do
not gate this merge.
