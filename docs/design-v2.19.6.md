# Phase 1 Design — v2.19.6 "Publish What Shipped"

**Author:** `@architect` (opus) · **Date:** 2026-08-07 · **Branch:**
`release/v2.19.6-publish-what-shipped` (primary checkout, no worktree) ·
**Base:** `main` @ `5d5301bf434a73cd6b78f19451e0b5c6b7ccd4b7`

Source of record for the requirements: `docs/spec.md` §*Product Spec — Cowork Starter Kit v2.19.6*
(finalized in this branch at Phase 1 from the Council hub scratchpad's ROUND 2 draft).

---

## §0. Phase 1 Design Header

> *ISO 15288 — Technical Management: Decision Management.*

**Worktree discipline:** SKIPPED — `COUNCIL_EXPECTED_BASE_SHA` unset (single-session; the cycle
classification forbids a worktree branch on both repos, per `patterns.md:34` state-stranding and the
cycle-specific wrong-ref hazard on `git rev-parse HEAD`-derived irreversible writes).

**Buy-vs-Build:** 3 components scanned — REUSE 2 / ADOPT 0 / EXTEND 1 / BUILD 0.

### Reuse Scan

| Component | Registry hit (grep pasted) | OSS candidate (name + license + health) | Scaffold | Decision | Basis |
|---|---|---|---|---|---|
| semver ordering + floor comparison | `docs/reuse-registry.md` — **Source 1: registry not yet present (ships v0.32.2) — skipped** | none sought | n/a | **REUSE** | `scripts/semver-compare.sh` already exists in-repo (ADR-020 zero-code constraint, `AC-UPGRADE-2`). Verified live this session: `ge 1.3.2.1 2.18.0` → exit 2. Reused unchanged; **not** modified by this cycle. |
| release-body predicate | same — skipped | none | n/a | **EXTEND** | `publish-release.sh:86-89` is the existing predicate. Extended (dotted **OR** anchor) and hoisted to one shared definition rather than reimplemented. |
| fixture-based CI negative controls | same — skipped | none | n/a | **REUSE** | The house fault-injection pattern already exists at `quality.yml:421` (poisoned sha256), `:588` (unscoped-grep wrongly-passes control), `:1023` (F2 fixtures), `:955` (column-reorder regression). Adopted verbatim in shape; no new mechanism. |

**Source 2 — scaffold index:** `examples/scaffolds/INDEX.md` not present in this repo (Council-side
artifact, ships v0.32.2) — skipped. No new app/service/CLI surface this cycle regardless.
**Source 3 — CS catalog + ADR tags:** `docs/constituent-systems.md` not present for this slug. No
`Reusability: candidate-constituent` tag applies — a repo-local release-surface gate is not a
portfolio-reusable constituent. **Source 4 — SoS interfaces:**
`.claude/projects/ecosystem/sos-interfaces.json` read; no entry names a release-surface or
tag/Release-integrity capability, so no existing interface contract is being re-derived.

### EARS check

Applied to all HIGH-severity ACs (`AC-PUB-1`, `-2`, `-3`, `-6`, `-12`, `-14`, `-15`).
**0 HIGH-severity vague findings — no OQs generated.** All seven are already in event-driven or
state-driven EARS shape (`WHEN <trigger>, the <system> SHALL <response>`) with a measurable
post-condition and a named negative control. Advisory (MEDIUM, no rewrite required): `AC-PUB-7`'s
"byte-unchanged" is stated as a `sha256` equality over an explicit window, which is measurable;
`AC-PUB-10`/`-13` are documentation-only and correctly carry no system response.

### SoS classification + UAF lite

**N/A — single-project design.** The design is confined to `claude-cowork-config`; no second
registered project is a participant, producer, or consumer.
· *Strategic viewpoint:* N/A — single-project design.
· *Operational viewpoint:* N/A — single-project design.
· *Service viewpoint:* N/A — single-project design.
· *Personnel viewpoint:* N/A — single-project design.

### Reliability analysis

**N/A per NEVER-APPLY** — no multiple external API providers in a request path, no failover/fallback
mechanism, and no SLA or availability claim in the spec. (The GitHub API is a single provider on a
maintainer-invoked path, not a redundant request path.)

### Heuristics check (Rechtin)

| Heuristic | Signal produced this cycle |
|---|---|
| *"The first line of defense against complexity is simplicity of design."* | Rejected `workflow_run` chaining and a `--legacy-predicate` toggle; the gate is one script with one injectable evidence seam. |
| *"Do the hard parts first."* | The `2.0.2` containment question (`AC-PUB-14`) was answered before the predicate was written, because the predicate turned out **not** to be the control that contains it. |
| *"Relationships among elements are what give systems their added value."* | The producer and the gate now share **one** predicate definition. Two copies kept equal by a check is a weaker relationship than one definition. |
| *"A model is not reality."* | Fixtures alone were judged insufficient; the parser grammar was run against five real production CHANGELOGs (below), which is where the naive variant's failure actually showed up. |
| *"The choice between architectures may well depend upon which set of drawbacks the client can handle best."* | Not applicable as a client trade this cycle — the operator is also the maintainer, and both candidate triggers were evaluated on least-privilege, not preference. Recorded rather than omitted. |

### Production validation

**`Production validation: 4/5 projects PASS`** — the candidate parser grammar was run **read-only**
against every registered project's real `CHANGELOG.md`, not only against fixtures:

| Project | `^## \[[^]]+\]` (candidate, dash-agnostic) | `^## \[x.y.z\] - ` (naive, hyphen-anchored) |
|---|---|---|
| `claude-cowork-config` | **48** | 26 |
| `The-Council` | **91** | **0** |
| `pillar-os` | **26** | **0** |
| `confidante` | **23** | **0** |
| `six-pillars-method` | 0 | 0 |

The 5th row is not a failure: `six-pillars-method` uses `## v0.4.0 — 2026-07-18` (no brackets,
verified at `CHANGELOG.md:3`), a different convention entirely. The gate is repo-local and correctly
extracts nothing there.

**This table is the single strongest justification for the dash-agnostic grammar, and no fixture
produced it.** The naive `' - '`-anchored variant finds **zero** headers in three of the four
bracket-convention repos and only 26 of 48 in this one. A fixture-only validation would have shown a
2-header miss; production data shows a total miss on three corpora.

**Read-only invariant honored:** the loop is a `grep -c` with no `-i`, no redirect, and no write
verb; it touches live parallel-session projects under the operator's read-only invariant.

### B1 verification

**`B1 verification: N/A — deferred to the orchestrator.`** `scripts/guards/scope-allow-verify.sh`
resolves `.claude/agents/dev.md` from the Council root and is not invocable from this
worktree-isolated session against a target-repo design doc. The `scope_allow_delta` block below is
authored in full (§E) so the orchestrator can run the verify before Phase 4 dispatch. **This is a
recorded gap, not a pass.** Every plan file in §D was cross-referenced by hand against
`dev.md scope_allow.standard` — the applicable scope for an external project — and **not one of them
matches**, which is why the delta is large rather than empty.

### Maturation-path self-grep

Run after authoring, before this document was finalized (`docs/architecture.md`, target repo):

```
Future-state options: → 46
Concrete revisit triggers: → 46
Risk knowingly accepted: → 46
```

Baseline measured before authoring was **44 / 44 / 44** (this repo already carries the convention on
44 records). Two new ADRs this cycle (ADR-077, ADR-078), each carrying the section, so each header
rose by exactly 2 — the expected delta. The ADR-076 amendment extends an existing record and carries
its own §Maturation Path as well, folded into ADR-077's count for the predicate decision it belongs
to. Headers were **copied** from the binding template, not composed; a count that failed to rise by
exactly the number of new records would mean a header was paraphrased.

---

## §A. Problem framing

> *ISO 15288 — Technical: Stakeholder Needs and Requirements Definition.*

Two independent defects were bundled under one carry-forward:

1. **A missing enforcement.** Tagging is a documented manual step (`CONTRIBUTING.md:309`) with no
   gate. It was missed twice consecutively. This is the real, unchanged half.
2. **A misdiagnosed detector.** `CF-v2.19.5-F` describes a predicate that "cannot repair" five
   releases. The five were never broken; the predicate was too narrow. The proposed remedy — widen
   the repair branch — would have executed `gh release edit --notes-file` against four curated
   bodies, replacing 652 bytes of editorial narrative with 3,576 bytes of raw CHANGELOG, days before
   a public announcement.

The second defect is the more instructive one and is the reason this design carries an ADR that
states the misdiagnosis explicitly (ADR-077 §D1). A reader who finds `risk-register.md` alone will
otherwise re-derive the wrong conclusion and re-propose the destructive fix.

---

## §B. The three architectural questions

> *ISO 15288 — Technical: Architecture Definition.*

### B1. Where does a non-3-component version get classified? (N-1)

**Answer: in the parser, before the comparator is ever invoked.**

Round 2 mandates both the dash-agnostic grammar `^## \[<ver>\]` **and** reuse of
`scripts/semver-compare.sh`, without specifying how `1.3.2.1` is classified. Verified live this
session:

```
$ scripts/semver-compare.sh ge 1.3.2.1 2.18.0
::error::not a valid x.y.z semver: '1.3.2.1'
::error::malformed semver input to 'ge' — failing closed, not defaulting to false
exit=2
```

Two individually-correct decisions combine into a defect neither has alone: the dash-agnostic parser
**reaches** `1.3.2.1`; the comparator **fails closed** on it. A gate that treats non-zero as failure
fails on precisely the pre-floor data the floor exists to exclude.

Three candidate sites, evaluated:

| Site | Effect | Verdict |
|---|---|---|
| **Gate body** — treat comparator `exit 2` as "skip" inline | Works, but collapses a fail-closed code into a benign one at the call site | **REJECT.** `semver-compare.sh:51-53` states the contract explicitly: *"Malformed input is a DISTINCT return code from 'false' (fail-closed, CF-v2.19-B) — callers must not collapse 2 into 1."* Collapsing 2 into *skip* is weaker still. `CF-v2.19-B` **was** a caller that ignored a subshell's exit status; this would re-create it. |
| **Comparator wrapper** — a shim mapping `exit 2` → skip | Same defect, one indirection further from the contract it violates | **REJECT.** |
| **Parser** — capture only `^[0-9]+\.[0-9]+\.[0-9]+$` into the COMPARABLE bucket | The comparator is never called on non-3-component input, so there is no `exit 2` to interpret | **ADOPT.** |

The parser-stage answer is not merely the least-bad of three; it is the only one that leaves
`semver-compare.sh`'s fail-closed guarantee **intact rather than handled**. Handling a fail-closed
signal is how it stops being one.

The gate retains the `exit 2` branch as an **unreachable-by-construction assertion**:

```
::error::release-surface: comparator rejected '<tok>' which the parser classified COMPARABLE —
parser/comparator contract violated. Fail-closed; not a routine path.
```

If that line ever prints, the parser's guarantee has been broken and the gate hard-fails. This is the
difference between silencing a signal and proving it cannot fire.

**Bucket label and reason.** The binding wording is `skip / below-floor`. The bucket is **SKIP**, as
required. Its recorded *reason* is refined to
`non-x.y.z — not publishable by publish-release.sh:31`, because `publish-release.sh` structurally
refuses to publish any non-`x.y.z` version, so asserting a tag+Release for one would be asserting
something the house producer is incapable of providing. Today the two reasons coincide (`1.3.1.1`,
`1.3.2.1` are both pre-floor); the producer-capability reason survives a hypothetical future
`2.19.4.1`, which the floor reason would not. Flagged as a refinement, not a contradiction.

### B2. What exactly is the predicate? (N-5)

**Answer: two fixed-string legs, the anchor leg right-bounded by `---`.** Full form in `docs/spec.md`
`AC-PUB-6`; rationale and measurements in ADR-077 §D2.

`grep -F` (fixed-string), never `grep -E`: the literal contains `.` and `#`, and under a regex
engine `CHANGELOG.md#` would match `CHANGELOGXmdY`. Fixed-string also removes any metacharacter
concern from the version argument.

The `---` right boundary, verified live rather than reasoned about:

| Test | Command | Result |
|---|---|---|
| unterminated prefix vs a future `2.19.10` anchor | `grep -c 'CHANGELOG\.md#2191'` on `…#21910---2026-09-01` | **1 — false positive** |
| `---`-terminated | `grep -c 'CHANGELOG\.md#2191---'` on the same | **0 — correct** |
| naive dots-stripped `2.0.2` vs live `v2.18.0` body | `grep -cF 202` | **1 — false positive** |
| anchored `2.0.2` vs the same body | `grep -cF 'CHANGELOG.md#202---'` | **0 — correct** |
| dotted `2.0.2` vs the same body | `grep -cF '2.0.2'` | **0** |

**One deliberate, recorded limitation.** The **dotted** leg is *not* right-bounded: `grep -qF "2.19.1"`
also matches inside `2.19.10`. This is pre-existing `:86-89` behavior, and it is only ever evaluated
against the Release for that exact version, so no cross-version confusion is reachable through either
caller. Tightening it would change long-standing producer behavior for no reachable gain. Accepted
with a revisit trigger (ADR-077 §Maturation Path).

**A subtlety worth naming for Phase 2.** The five live bodies are **not** uniform in link shape.
`v2.18.0` carries the anchor in both the link text and the URL
(`[CHANGELOG.md#2180---2026-07-22](…#2180---2026-07-22)`); `v2.19.3` carries a bare link text with
the anchor only in the URL (`[CHANGELOG.md](…#2193---2026-07-27)`). The predicate matches both
because it targets the literal `CHANGELOG.md#<stripped>---`, which appears in the URL either way.
A predicate written against the *link-text* shape would have passed four bodies and failed `v2.19.3`.

### B3. Does `publish-release.sh` need a version floor? (spec deliverable 4)

**Answer: no — and the anchored predicate alone is not sufficient containment either. The correct
control is a create-path-only version precondition.** Argued in full in ADR-077 §D3; summary:

- **The predicate cannot contain this hazard at all.** `publish-release.sh 2.0.2` on `main` today
  extracts the real `## [2.0.2]` section (`CHANGELOG.md:772`) as the body. That body contains the
  literal `2.0.2`, so the dotted leg passes. The post-condition never fires. The hazard is not in the
  *detector*; it is in the *creator* — `gh release create --target "$(git rev-parse HEAD)"` would tag
  `v2.0.2` at today's `main`. (In this specific case `v2.0.2` already has a tag and a **0-byte**
  Release, so the run reaches the repair branch instead — but that is luck, not containment: any
  below-floor version with a CHANGELOG entry and no tag is a live create-path.)
- **A version floor in the producer is the wrong shape.** It hardcodes a Scope-C *policy* into a
  general-purpose *producer*; it forecloses legitimately repairing pre-floor empty-bodied Releases
  (`v2.0.2` is one, live, today); and it is under-inclusive — it does nothing about a wrong-`HEAD`
  publish of an above-floor version.
- **The right control is co-extensive with the irreversible operation.** Assert, on the create branch
  only, that the requested version equals `VERSION` at `HEAD`. Verified in advance to be free on
  every legitimate path: `VERSION` is `2.19.4` at `5fee6f9`, `2.19.5` at `7c524d4`, and `2.19.6` at
  the merge commit (guaranteed by `version-consistency-check`). It also turns the written procedure
  at `CONTRIBUTING.md:309` — *"on `main` at the commit you intend to tag"* — into an enforced one.

---

## §C. Component design

> *ISO 15288 — Technical: Design Definition.*

### C1. `scripts/release-predicate.sh` (NEW) — one definition, two callers

Holds `body_names_version()` and nothing else. Sourced by both `publish-release.sh` and
`verify-release-surface.sh`.

**Why one definition rather than two copies plus a `cmp` mirror gate** (the house pattern at
`quality.yml:761`, ADR-016 v2.6): drift-by-construction is *impossible* with one definition and
merely *detected* with two. The producer and the gate disagreeing about what "the body names its
version" means is precisely this cycle's defect class, one level up.

**Sourcing hazard, and how it is handled.** `publish-release.sh` is invoked in Scope A by absolute
path with `cwd` inside a detached worktree at a commit where this file does not exist. Resolution is
therefore `BASH_SOURCE`-relative to the *invoked script*, not `cwd`:

```sh
. "${BASH_SOURCE[0]%/*}/release-predicate.sh" || {
  echo "ERROR: scripts/release-predicate.sh not found beside $0 — refusing to publish." >&2
  exit 1
}
```

Fail-closed, never a silent fallback to an inline copy. `AC-PUB-2`'s pre-flight adds a readability
assertion so this is caught **before** the irreversible call rather than at the post-condition.

### C2. `scripts/publish-release.sh` (EDIT) — two changes, both minimal

1. `:86-89` → `body_names_version "$BODY" "$VERSION"`, with the failure message widened to name both
   accepted forms and to say plainly that a curated body is expected to carry the anchor form.
2. **New, create-path only** (`AC-PUB-14`), immediately before the `gh release create` call at `:74`:

   ```sh
   VERSION_AT_HEAD="$(tr -d '[:space:]' < VERSION)"
   if [ "$VERSION" != "$VERSION_AT_HEAD" ]; then
     echo "ERROR: refusing to CREATE tag v${VERSION} — VERSION at HEAD is '${VERSION_AT_HEAD}'." >&2
     echo "  publish-release.sh creates tags only at the commit whose VERSION matches the request" >&2
     echo "  (CONTRIBUTING.md pre-release checklist). To repair an EXISTING release's body, the tag" >&2
     echo "  must already exist — this guard does not apply on the repair path." >&2
     exit 1
   fi
   ```

**Not changed:** the repair branch (`:67-70`), the idempotent-skip branch (`:65-66`), the asset poll
(`:102-129`), the `^[0-9]+\.[0-9]+\.[0-9]+$` gate (`:31`), and the ADR-076 D3 remedy text. The
narrowest edit that closes both findings.

### C3. `scripts/verify-release-surface.sh` (NEW) — pure predicate + injectable evidence

```
Usage: scripts/verify-release-surface.sh [--floor X.Y.Z] [--changelog PATH] [--evidence-dir DIR]
Exit:  0 = all in-scope versions pass
       1 = one or more in-scope versions failed (findings printed, one line per failed conjunct)
       2 = usage, environment, or contract error — fail-closed, never a pass
```

Five stages:

1. **Parse.** `^## \[([^]]+)\]` over `CHANGELOG.md`. Dash-agnostic by construction — the grammar
   never looks past the closing bracket, so ASCII-hyphen, em-dash, and parenthetical-title headers
   are all reached. Production-validated above.
2. **Classify.** `^[0-9]+\.[0-9]+\.[0-9]+$` → COMPARABLE. `Unreleased` (case-insensitive) → SKIP
   (in-flight section). Anything else → SKIP with reason `non-x.y.z`. Counted and printed as
   `::notice::`, never as an error. **§B1.**
3. **Floor.** `semver-compare.sh ge <tok> <FLOOR>` on COMPARABLE tokens only. `0` → IN-SCOPE;
   `1` → SKIP/below-floor (counted); `2` → hard fail, contract violation (**unreachable**).
4. **Assert**, per in-scope version, two independently named conjuncts:
   - **TAG** — `git ls-remote --tags origin "refs/tags/v$V"` non-empty. Origin is authoritative.
   - **RELEASE** — `gh release view "v$V" --json body` succeeds **and**
     `body_names_version "$BODY" "$V"`.
5. **Report.** Three stable, greppable tokens, each with its own remedy, because these are different
   remedies and `AC-PUB-1` requires naming which half failed:

   ```
   ::error::release-surface: 2.19.4 MISSING-TAG — no refs/tags/v2.19.4 on origin.
     Remedy: bash scripts/publish-release.sh 2.19.4 at the commit you intend to tag.
   ::error::release-surface: 2.19.4 MISSING-RELEASE — tag exists but no GitHub Release.
     Remedy: same producer; it creates tag and Release atomically (ADR-076).
   ::error::release-surface: 2.18.0 DEFECTIVE-RELEASE-BODY — Release exists but its body names
     neither "2.18.0" nor "CHANGELOG.md#2180---".
     Remedy: gh release edit v2.18.0 --notes-file <curated body>. Do NOT regenerate from
     CHANGELOG.md — the curated editorial bodies are the house convention (ADR-077).
   ```

   Summary: `release-surface: <N> checked, <F> failed, <S> skipped (<Sn> non-x.y.z, <Sb> below-floor).`

**The local-tag conjunct, and why it is mode-gated.** The spec's predicate says "a tag on **both**
local and origin." In a CI runner, `actions/checkout` at the default `fetch-depth: 1` fetches **no**
tags, and at `fetch-depth: 0` fetches exactly origin's — so in CI the local conjunct is either
vacuously false for everything or trivially identical to the origin conjunct. Either way it is **not
a check**. It is therefore:

- **ACTIVE** when `CI` is unset (an operator on a workstation, where "I tagged but never pushed" —
  a named edge case — is real); and
- **SKIPPED** in CI with an explicit `::notice::release-surface: local-tag conjunct SKIPPED — the
  runner's local tag set is a checkout artifact, not a fact about the repository.`

Never silently degenerate. A check that cannot fail must be *labelled* as not-a-check, not quietly
counted as a pass.

**Fail-closed environment handling:** `gh` absent or unauthenticated, `git ls-remote` failure, or
`CHECKED == 0` → exit 2 with a named `::error::`. The `CHECKED == 0` rule follows the house precedent
at `quality.yml:498`.

**The evidence seam.** Two functions, `evidence_tags()` and `evidence_body <tag>`, default to
`git ls-remote` / `gh release view` and are redirected to a fixture directory by `--evidence-dir`.
This is what makes every AC's negative control executable offline, against no live release. It is a
test seam, not dead code — CI exercises it on every PR.

**Seam abuse, and its containment (flagged for Phase 2).** `--evidence-dir` can make the gate pass on
fabricated evidence. Containment: `release-surface.yml` invokes the script with **no** flags, and a
`quality.yml` meta-check greps `release-surface.yml` to assert the live invocation carries neither
`--evidence-dir` nor `--changelog`. Residual exposure is bounded by the fact that anyone who can edit
the workflow can equally delete the gate — the seam adds no privilege that editing the workflow does
not already confer. `@security` should confirm that reasoning rather than inherit it.

### C4. `.github/workflows/release-surface.yml` (NEW)

```yaml
name: Release Surface
on:
  push:
    branches: [main]
  schedule:
    - cron: '17 6 * * *'
  workflow_dispatch:
permissions:
  contents: read
concurrency:
  group: release-surface-${{ github.ref }}
  cancel-in-progress: true
jobs:
  verify:
    name: Verify tag + Release for every CHANGELOG version >= 2.18.0
    runs-on: ubuntu-latest
    permissions:
      contents: read   # least-privilege, matching quality.yml:1332 / :1732
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - name: verify-release-surface
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: bash scripts/verify-release-surface.sh --floor 2.18.0
```

Three triggers, each earning its place:

- **`push: branches: [main]`** — the primary need: immediate post-merge signal. This is what would
  have caught `v2.19.4` and `v2.19.5`.
- **`schedule` (daily)** — catches drift that happens with **no push**: a tag deleted, or a Release
  body edited in the GitHub UI. That class is not hypothetical here; the entire cycle is about the
  release surface being mutated outside git. The repo is **PUBLIC** (verified), so Actions minutes
  are unmetered and this is cost-neutral. *Known limitation:* GitHub auto-disables `schedule` after
  60 days of repository inactivity — recorded in ADR-078 §Maturation Path, not assumed away.
- **`workflow_dispatch`** — **mandatory, not convenience.** Scope A produces no commit, so without a
  manual trigger there is no way to re-run the gate and observe `AC-PUB-1` State C.

**`workflow_run` explicitly rejected**, not merely unchosen: it executes in default-branch context
with a token that is not restricted the way a `pull_request` token is, which is a known
privilege-escalation shape. It buys ordering this design does not need.

**`pull_request` prohibited** per the spec's own proof: the gate would fail on its own introducing PR
(`## [2.19.6]` is untagged at PR time, by definition) and on every release PR after.

**`fetch-depth` left at the default `1`** — deliberate. The authoritative tag check is `ls-remote`
against origin; deepening the fetch would only manufacture a local tag set that makes the mode-gated
local conjunct *look* like a check.

### C5. `quality.yml` (EDIT) — one new job, `release-predicate-check`

Pure fixture tests, no network, safe on `pull_request` — which is exactly why the network gate lives
in its own workflow. Covers `AC-PUB-6` (i)(ii)(iii) with their fixture-validity controls,
`AC-PUB-11`'s parser↔comparator contract, `AC-PUB-12`'s executable negative control, `AC-PUB-14`'s
guard (run with `gh` removed from `PATH`, so a regression fails loudly instead of publishing), and
the C3 seam meta-check.

---

## §D. File-by-file implementation plan

> *ISO 15288 — Technical: Implementation.*

| # | File | Action | Owner / phase | Scope | Notes |
|---|---|---|---|---|---|
| 1 | `scripts/release-predicate.sh` | NEW | @dev / P4 | B+C | Sole definition of `body_names_version()`. |
| 2 | `scripts/publish-release.sh` | EDIT | @dev / P4 | B | Two changes only (C2). Do not touch the poll, the repair branch, or `:31`. |
| 3 | `scripts/verify-release-surface.sh` | NEW | @dev / P4 | C | Read-only. Exit contract 0/1/2. |
| 4 | `.github/workflows/release-surface.yml` | NEW | @dev / P4 | C | Post-merge triggers only; `contents: read` at both levels. |
| 5 | `.github/workflows/quality.yml` | EDIT | @dev / P4 | B+C | Add `release-predicate-check` job. No other job touched. |
| 6 | `tests/fixtures/release-surface/changelog-headers.md` | NEW | @dev / P4 | C | AC-PUB-11 parser fixture. |
| 7 | `tests/fixtures/release-surface/bodies/neither.md` | NEW | @dev / P4 | B | AC-PUB-6 (i). |
| 8 | `tests/fixtures/release-surface/bodies/v2180-real.md` | NEW | @dev / P4 | B | Verbatim copy of the live `v2.18.0` body — carries the `2026-` date that makes the `2.0.2` collision real. AC-PUB-6 (ii). |
| 9 | `tests/fixtures/release-surface/bodies/v21910-anchor.md` | NEW | @dev / P4 | B | AC-PUB-6 (iii) boundary. |
| 10 | `tests/fixtures/release-surface/evidence-untagged/` | NEW | @dev / P4 | C | `tags.txt` + `*.body` — AC-PUB-12 negative control. |
| 11 | `tests/fixtures/release-surface/evidence-clean/` | NEW | @dev / P4 | C | AC-PUB-12 positive control. |
| 12 | `docs/spec.md` | EDIT (append) | @architect / P1 | — | **DONE this phase.** |
| 13 | `docs/design-v2.19.6.md` | NEW | @architect / P1 | — | **This file.** |
| 14 | `docs/architecture.md` | EDIT (append + index) | @architect / P1 | — | **DONE this phase** — ADR-077, ADR-078, ADR-076 amendment, ADR Index rows. |
| 15 | `docs/risk-register.md` | EDIT | @dev / P4 | — | AC-PUB-8 (close `CF-v2.19.5-F` as MISDIAGNOSED) + AC-PUB-10 (new pre-floor carry-forward). |
| 16 | `VERSION` | EDIT | @dev / P4 | — | `2.19.6`. |
| 17 | `CHANGELOG.md` | EDIT | @dev / P4 | — | `## [2.19.6] - 2026-08-07`. |
| 18 | `README.md` | EDIT | @dev / P4 | — | Version badge → `2.19.6`. |
| 19 | `CONTRIBUTING.md` | EDIT | @dev / P4 | — | Pre-release checklist: add the standing gate, and the Scope-A ordering constraint (tag **before** the retro merge, so the tag lands on the feature-merge commit per repo precedent). |
| 20 | `docs/owner-tasks.md` | EDIT | @dev / P4 | — | `[P1-CORRECTION-5]` — offline smoke-test scorecard obligation fires once per tag; Scope A pushes three. |

**Scope A is not in this table.** It is an operator procedure executed on `main` after the PR merges,
not a file @dev writes. Its steps are `AC-PUB-2` / `-3` / `-15`.

---

## §E. `scope_allow_delta`

The applicable scope for this external project is `dev.md scope_allow.standard`, whose entries are
`^src/`, `/src/`, `docs/pipeline\.md`, `\.claude/scratchpad\.md`, `package\.json`, `tsconfig`,
`vitest\.config`, `next\.config`, `eslint`, and the `\.claude/projects/…` state paths. **No §D file
matches any of them** — this repo is a Markdown/Bash template kit with no `src/` tree — so every
Phase-4 write path is listed.

```yaml
scope_allow_delta:
  add:
    - '^scripts/release-predicate\.sh$'
    - '^scripts/publish-release\.sh$'
    - '^scripts/verify-release-surface\.sh$'
    - '^\.github/workflows/release-surface\.yml$'
    - '^\.github/workflows/quality\.yml$'
    - '^tests/fixtures/release-surface/'
    - '^docs/risk-register\.md$'
    - '^docs/owner-tasks\.md$'
    - '^VERSION$'
    - '^CHANGELOG\.md$'
    - '^README\.md$'
    - '^CONTRIBUTING\.md$'
  remove: []
```

Paths are anchored (`^…$`) except the fixture directory prefix, which is deliberately a prefix so the
eleven fixture files do not need eleven entries. No entry carries a trailing inline comment —
`extract_scope_patterns()` strips quotes only when the line ends on the closing quote
(`CF-V0.37.5-SCAFFOLDCOMMENT`).

---

## §F. Classification re-run

> *ISO 15288 — Technical Management: Risk Management.*

**Result: CONFIRMED — SECURITY-SENSITIVE (Tier B), zero Tier A files, no Guard Change Summary.**

Re-evaluated against the **final** §D file list after all Open Questions were resolved. The list grew
by six files relative to the Round-2 draft (`release-predicate.sh`, `verify-release-surface.sh`,
`release-surface.yml`, the fixture tree, `CONTRIBUTING.md`, `owner-tasks.md`), and gained one new
edit to an existing workflow (`quality.yml`).

`.github/workflows/` is matched **directly and unconditionally** — two files now, not one. That is
the Tier B trigger (`pipeline-policy.md:510` + `:516`), and it is a direct match rather than a
contingent one, so the `:519` downgrade path is closed and the `:525` fail-closed rule is not
being relied upon. **Recorded as CONFIRMED, not DOWNGRADED.**

**No Tier A file enters scope.** No `scripts/guards/`, no `.claude/settings.json`, no
`docs/pipeline-policy.md`, no `.claude/agents/*.md`. The one candidate — CODEOWNERS coverage for
`publish-release.sh` / `release-assets.yml` (`@security` S4) — is deferred to the v2.19.7 governance
bundle by owner decision, which is what keeps this cycle Tier B. That deferral is now
**load-bearing on the classification**, not merely a scope preference; if it is reversed, the cycle
escalates to Tier A and requires a Guard Change Summary.

No upward flip. Phase 2 is mandatory and is not being skipped. Phase 6 is required. No combined
audit+approve path.

---

## §G. Anti-pattern scan

> *ISO 15288 — Technical: Verification.*

| # | Anti-pattern | Finding |
|---|---|---|
| 1 | God class/module | Clear. `verify-release-surface.sh` has one responsibility; the predicate is hoisted out precisely so it does not accrete into either caller. |
| 2 | Circular dependencies | Clear. `release-predicate.sh` depends on nothing; both callers depend on it; it depends on neither. |
| 3 | Leaky abstraction | **Present, accepted and named.** `body_names_version` leaks the house *documentation* convention (`CHANGELOG.md#…---`) into the *producer*. The alternative — reproducing GitHub's slugifier — is a far larger leak of an undocumented third-party algorithm. Recorded in ADR-077 §Maturation Path with a revisit trigger. |
| 4 | Premature optimization | Clear. |
| 5 | Over-engineering | Watched. The evidence seam is one indirection; it is justified by making every negative control executable offline, which is a binding requirement here, not a nicety. `workflow_run` chaining and a `--legacy-predicate` toggle were both rejected as over-engineering. |
| 6 | Tight coupling | Clear — the evidence seam is the injection point. |
| 7 | Missing separation of concerns | Clear, and actively enforced: fixture tests (no network, PR-safe) in `quality.yml`; the live gate in its own post-merge workflow. |
| 8 | N+1 query | **Present, accepted.** The gate makes one `gh release view` per in-scope version. In-scope count is 7 today and grows by one per release. `git ls-remote` is called once and cached. Revisit trigger in ADR-078 §Maturation Path. |
| 9 | Destructive migration | Clear — and this is the cycle's central invariant. **Zero `gh release edit` calls fire against any release at or above the floor** (`AC-PUB-7`). |
| 10 | SoS interface discontinuity | N/A — single-project design. |
| 11 | Cross-project tight coupling | Clear. The production-validation loop is read-only and touches no other project's state. |

---

## §H. Open questions

None outstanding. N-1 is closed in §B1 and `AC-PUB-11`; N-5 is closed in §B2 and `AC-PUB-6`; the
Scope-A location question is closed by `CONTRIBUTING.md:309` (on `main`, post-merge) rather than by
judgment; the `git worktree remove --force` question is closed by removing its cause (§C1 / `AC-PUB-2`
step 3 copies nothing into the worktree, so plain `remove` succeeds).

Five items are raised **for `@security` at Phase 2** rather than left as open design questions —
listed in the Phase 1 report to the orchestrator.
