# Security Audit — v2.19.10 "Plain Language: say it the way she'd say it"

## Phase: 6
## Date: 2026-08-20T13:40:00Z
## Status: PASS WITH WARNINGS — 0 CRITICAL, 10 WARNING, 6 INFO

**Audited:** the shipped bytes over the whole range `fd00dd2..09bbced` (17 commits — @architect's,
@dev's **and** @qa's), on `release/v2.19.10-plain-language`. 12 files changed, 3790 insertions,
17 deletions.

**Method.** Every instrument below was run against a tree where its property is **violated** and
observed **RED** before its GREEN was trusted. Every count is `grep -oF … | wc -l` (occurrences),
never `grep -cF` (lines) — per S9. Fixtures were built in a scratch directory; nothing was executed
with `cwd` inside the repository. No historical `AC-CI-*` / `AC-COMP-2` verify command was re-run
(`docs/architecture.md:9673`, `:9757-9760` are append-only records of a closed cycle, §F EXEMPT).

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| A1 | WARNING | 6 | configuration | A 25-line insertion into `CONTRIBUTING.md` displaced three canonical line-pinned anchors — `:77`, `:129`, `:309` — cited **53 times** repo-wide, including from a skill that ships into every user workspace. `CONTRIBUTING.md:129`, the forbidden-imperative-token (LLM01) recipe address, now resolves to a markdown table separator. |
| A2 | WARNING | 6 | permissions | Three registry rows now assert *"This skill is protected from being changed by any other skill."* — an unqualified wall claim that `skills/self-apply/SKILL.md:63` and `TRUST.md:16` explicitly and deliberately disclaim. |
| A3 | WARNING | 6 | permissions | `self-upgrade`'s new description states the self-integrity invariant in the **wrong order** (*write-then-check-then-replace*) and substitutes atomicity (*"can never leave things half-finished"*) for the actual security property (trust-anchor preservation). |
| A4 | WARNING | 6 | configuration | The AC-PL-6 gate's parser exists in **2** independent copies (`quality.yml:623`, `:690`). A single-line drift in the assertion copy produces a false GREEN on a genuinely unprotected row that the fault-injection copy is structurally unable to observe. Demonstrated. |
| A5 | WARNING | 6 | ui | `WIZARD.md:100` routes Claude into *F4's "Add from full pool" flow*; this cycle renamed that label at `:119` to *"Add from the full skill library"*. The quoted target no longer exists. |
| A6 | WARNING | 6 | permissions | `self-archive`'s new description promises *"a record of every move so it can always be undone"*; its own `SKILL.md:73` calls the same step *"irreversible-by-forward-motion"* and `:79` scopes rollback to verifier-FAIL only — there is no user-invocable undo. |
| A7 | WARNING | 6 | external-api | `pull-updates`' new description replaces *"the on-disk pool"* with *"the latest available version"*, converting a data-locality statement into an implied-remote one, and drops the fresh-bytes-on-both-sides staleness property. |
| A8 | WARNING | 6 | configuration | The newly-shipped `CONTRIBUTING.md § Runtime-string register` declares *"every spoken or quoted string"* in `WIZARD.md` in scope; at least **4** spoken strings still carry undefined Jargon-List terms (`bundle` ×3 at `:68`/`:355`/`:417`, `pool` ×2 at `:93`/`:97`). The register is aspirational but reads as enforced. |
| A9 | WARNING | 6 | configuration | S13's remedy landed in @qa's run, not in the durable artifact: `docs/design-v2.19.10.md:813` still publishes the **unguarded** leg-A snippet, and that file ships in the public archive. |
| A10 | WARNING | 6 | logging | S4/S16 carry-forward, correctly deferred: **14** internal reports still ship in the public archive (re-derived, see §5). Not this cycle's defect; the retrofit is properly out of scope. |
| A11 | INFO | 6 | permissions | `self-apply`'s new description inverts the actor (*"requires **you** to propose a change, check it"*; the skill proposes, the user confirms) and mis-times rollback (*"be able to reverse it **before it takes effect**"*; rollback follows a verifier FAIL, i.e. after the write). |
| A12 | INFO | 6 | ui | `anti-ai-slop`'s new description inverts the skill's purpose: *"Smooths out"* / *"flattening repetitive sentence patterns"* describes making prose **more** uniform; the skill removes *uniform sentence rhythm*. `AI-tell vocabulary` is dropped entirely. |
| A13 | INFO | 6 | ui | `prompt-gate`'s new description replaces the bound *"up to 3 …clarifying questions"* with *"a few"* — a dropped numeric bound, in a cycle that treated the `25` numeral as load-bearing. |
| A14 | INFO | 6 | ui | `CHANGELOG.md` attributes *"all three of `self-archive`'s safety phrases (…`never on its own`)"*; `never on its own` belongs to `pull-updates`, not `self-archive`. |
| A15 | INFO | 6 | configuration | AC-PL-6 asserts an **aggregate** count. A commit that adds one valid row and breaks one existing row nets zero and passes silently — the one case the pin's own "bump it" comment cannot prompt, because nothing fails. |
| A16 | INFO | 6 | configuration | No PR exists for the branch. Three PR-only CI jobs (`lock-content-sha-cross-check`, `sync-agency` dry-run, `vendored-removal-ledger`) have **never run** against `09bbced`. |

**0 CRITICAL. Phase 7 is reachable.**

---

## 1. AC-PL-6 — the adversarial read of the shipped gate

The question posed: *can the shipped step be made to pass while a row is genuinely unprotected?*

### 1a. The gate is genuinely load-bearing — confirmed, not assumed

The downstream drift-verify step (`quality.yml:697-736`) **skips** any row whose field 8 is not a
valid 64-hex value:

```sh
case "$stored" in ''|*[!0-9a-f]*) continue ;; esac
[ "${#stored}" -eq 64 ] || continue
```

Reproduced on the pipe-injection fixture: `self-apply`'s field 8 becomes
`mandatory-infrastructure` (24 chars). The row is silently skipped, `CHECKED` falls 30 → 29, `FAIL`
stays 0, and the job **exits 0**. The `CHECKED -eq 0` floor does not fire at 29. So a single stray
`|` in a description turns off the poisoned-backfill defense for the single most safety-bearing skill
in the kit, and **AC-PL-6's pinned count is the only thing standing between that and a green build.**

### 1b. The canary was pressed — and it holds in the zeroing direction

A parser typo that returns **0** fails closed in both venues: the assertion step compares `0 -ne 30`
and errors; the fault-injection step's clean-fixture leg compares `0 -ne 30` and errors with
`FIXTURE-VALIDITY FAILED`. A deleted `AC_PL_6_EXPECTED_HEX_ROWS` aborts under `set -u`.
**The "pattern typo returns 0 matches, byte-identical to a genuine pass" failure mode does not exist
here** — the clean-fixture leg is exactly the control that forecloses it. That is a real, correct
design choice and it should be recorded as such.

### 1c. But the gate CAN be made to pass on an unprotected row — A4

The parser is written out **twice**, in two separate `run:` blocks (shell functions cannot cross
steps):

```
grep -oF "awk -F'|' '{s=\$8; gsub(/ /,\"\",s); if (s ~ /^[0-9a-f]{64}\$/) c++} END{print c+0}'" \
  .github/workflows/quality.yml | wc -l   →  2      (quality.yml:623 and :690)
```

The **pin** was deliberately hoisted to job level so the two steps "cannot drift apart" (S11). The
**parser** was not. Demonstrated on the shipped tree, in a scratch dir:

| parser | clean tree | pipe-injected tree | verdict |
|---|---|---|---|
| shipped (`$8`-anchored, both copies) | 30 | **29** | correct |
| a one-line drift in the **assertion** copy only (`$0 ~ /[0-9a-f]{64}/`, whole-line) | 30 | **30** | **FALSE GREEN** |

Under that drift the fault-injection step at `:623` — running its own untouched copy — still prints
`AC-PL-6 fault-injection PASSED — clean=30, both damage fixtures detected`. **Two green steps, one
genuinely unprotected row, and the self-test structurally cannot see it**, because it never executes
the parser the gate actually uses.

This is not a defect in the shipped tree — the copies are byte-identical today and CI's own numbers
confirm it (§4). It is a maintenance-drift hazard on the cycle's only new control, and it is the same
species as the five instruments this cycle already caught: *the thing that proves the check can fail
is not the thing that runs.*

**Remedy (Tier-B-preserving — inline, no `scripts/` file, so TIER-4 is untouched).** Add one step to
the same job asserting the two copies are still identical:

```sh
N=$(grep -oF "$PARSER" .github/workflows/quality.yml | wc -l)
[ "$N" -eq 2 ] || { echo "::error::AC-PL-6 parser drifted — the fault-injection step no longer exercises the parser the gate runs."; exit 1; }
```

Negative control for that remedy: mutate either copy and it returns 1, not 2.

### 1d. A15 — the pin is an aggregate

All 30 valid-hex rows are real data rows; the 20 remaining ≥9-field lines are the 10 tables' header
and separator rows (re-derived). So a "gain" can only come from **adding** a row. A commit that adds
one valid row *and* breaks one existing row nets zero and passes. The job comment correctly warns that
a future add/remove "MUST bump this value" — but that instruction is only reachable when something
goes red, and in the compensating case nothing does. INFO: a per-row assertion (every row matching
`^\| [a-z0-9-]+ \|` carries valid hex in field 8) would close it without a pin at all.

---

## 2. AC-PL-7 on shipped text — all six rows, legs (a)/(b)/(c)

All counts by occurrence. All three legs proven able to fail **on the shipped tree** before their
green was accepted.

### Row 1 — `examples/personal-assistant/…` § Data locality

| leg | pre (`fd00dd2`) | post (`09bbced`) | verdict |
|---|---|---|---|
| (a) six categories — `financial amounts`, `calendar event details`, `contact information`, `health information`, `physical addresses`, `authentication credentials` | 1 each | 1 each | GREEN |
| (b) `Never send` · `decline and offer a local alternative` | 1 · 1 | 1 · 1 | GREEN |
| (c) exception-token deny list | **0** | **0** | GREEN (equal) |
| Phase-2 binding condition: `external services or APIs` intact | 1 | 1 | GREEN |

**Addition-only, proven by bytes, not by reading the diff:** stripping the appositive from the
post-edit clause yields a file `cmp`-identical to the pre-edit clause. The edit **appends**; it does
not replace.

**Negative controls, all executed against the shipped tree:** delete `health information` → (a) 1→0
RED. Replace `decline and offer a local alternative` → (b) 1→0 RED. Append *"except where you judge
it useful"* → (c) 0→1 RED. All three legs fire.

### Row 2 — folder enumeration, all 8 files

35 tokens across the 7 example files, **all present**. Counts reproduce the S6 measurement exactly on
shipped bytes: `Calendar/`=2, `Tasks/`=3, `People/`=3, `Finances/`=1, `Documents/`=1,
`Voice-and-Style/`=2. **The margin remains 2 tokens of 5, not 5.** Template exception (file 8): both
negative-guarantee sentences present, 1 each.

**AC-PL-8 parity holds mechanically:** `ls` finds exactly **8** `working-rules.md` files; `git diff`
over all 8 across the range shows **1 file, 1 insertion, 1 deletion** — the other 7 are byte-unchanged.

### Rows 3, 4, 5 — all GREEN

`Do not infer` 1 · `unless I ask explicitly` 1 · `must be mine` 1 · `never silently performs` 1 ·
`reversibly` 1 · `never on its own` 1.

### Row 6 — anchor-scoped, and its two Phase-2 residuals

- **Anchor uniqueness re-derived by occurrence:** `No URL paste, no external source` → **1**
  (`WIZARD.md:123`). Leg A's scoping premise holds on shipped bytes.
- **Leg A:** both halves present on the scoped line — `Installing skills from external sources isn't
  supported yet` (1) and `the wizard installs only from the local, vetted pool` (1). GREEN.
- **Leg B:** file-wide occurrences of half 1 = **2**, matching the pre-edit baseline of 2. GREEN.
- **The edit is the compliant shape the design predicted:** `…vetted pool` → `…vetted pool (already
  reviewed and included with this kit)` — an appositive appended after the restriction, exactly the
  4th row of §C.7's negative-control matrix.
- **S14 discharged on shipped bytes.** Deny-list count on `WIZARD.md:123`: **0 pre-edit → 0 post-edit**
  (measured on `fd00dd2` and `HEAD` separately, same regex as row 1). The mandated additive edit
  introduced no exception token.
- **S13 — @qa built and proved the anchor-existence guard in its own run** (`qa-report-v2.19.10.md:272-278`:
  typo'd anchor → empty `LINE` → `sed -n "p"` printed 422 lines instead of 1; the guard aborts before
  `sed`). **But the remedy did not reach the durable artifact — A9.** `docs/design-v2.19.10.md:813`
  still publishes the unguarded three-line snippet, with no `set -euo pipefail` and no `[ -z "$LINE" ]`
  check, and that file ships in the public release archive. The next agent or contributor who re-runs
  row 6 from the published procedure gets the defective form. **Remedy:** append a correction note to
  the design doc's §C.7 (the file is append-only), or fold the guard into the next cycle's spec.

### AC-PL-2 — closing-message item diff

Mechanical, not subjective: the backticked file/skill enumeration on `WIZARD.md:339` is **identical**
pre and post — zero drops, zero additions. Negative control: removing `connector-checklist.md` from
the post list makes the diff fire.

---

## 3. S15 on the shipped bytes — the verdict

**Shipped:** `…to external services or APIs (other programs or services outside this computer).`

**Phase-2 objection (against the design's proposal, *"(other programs your computer talks to over the
internet)"*):** an internet-scoped gloss removes local IPC bridges, on-device agents, and every
non-internet egress path (LAN, Bluetooth, a paired phone) from the reach of `Never send`.

### Verdict: RESOLVED. The shipped wording does not weaken the Data-locality guarantee.

The boundary @dev chose is **the machine, not the internet** — and that difference is the whole
finding. *"Outside this computer"* covers every off-machine destination irrespective of transport, so
the three classes the internet-gloss would have excluded (LAN, Bluetooth, a paired device) all remain
inside the prohibition. This is also the boundary the rest of the product uses when it is being
careful.

I ran the definitional attack rather than asserting the conclusion. The one residual reading is:
*sending to a co-located process is not "outside this computer," so it is not obviously prohibited*
— even where that process is itself an egress conduit (a local proxy, a forwarding MCP server, a sync
daemon). **That residual is closed inside the same clause, by two sentences the appositive does not
touch:** *"All sensitive personal data stays in local files"* and *"If I ask for something that would
require sending this data externally, decline and offer a local alternative."* A local conduit that
forwards off-machine **does** require sending the data externally, and is refused by the third
sentence. The appositive narrows the definition of one term in the first sentence; the guarantee rests
on three.

**Recorded, not escalated:** the residual is a wording preference, not a gap. If a future cycle
touches this clause, *"outside this program"* would close it outright — but changing it now would
replace a proven-safe sentence to buy a reading that the sentence's own neighbours already cover, and
that trade is not worth a re-verification.

### `/legal` ruling — still NOT owed. Re-derived, not restated.

The Phase-2 tripwire was **the enumerated category set**, with three named conditions under which
`/legal` becomes owed. All three re-measured on shipped bytes:

| Phase-2 condition | shipped measurement | owed? |
|---|---|---|
| the wording REPLACES rather than appends | `cmp`-proven append-only | NO |
| any row-1 protected token leaves count 1 | all 8 remain at exactly 1 | NO |
| the deny-list leaves 0 | 0 → 0 | NO |

Enumerated category set unchanged (6/6). `Never send` intact. `decline and offer a local alternative`
intact. Deny-list 0. **`/legal` is not owed for v2.19.10.**

---

## 4. The six rewritten registry descriptions — the read no instrument performs

**There is no CI check anywhere that compares a registry `description` cell against the skill it
describes.** Confirmed: `registry-sha256-check` verifies field 8 against the pool file's bytes;
`registry-cardinality-check`, `registry-url-check` and `wizard-consistency-check` check counts, URLs,
and slug↔preset↔menu agreement. None reads the prose. The only gate on description **meaning** is
Q3 of the 3-question read — *"is meaning preserved vs. pre-edit?"* — which the spec itself labels
**human judgment**. @qa recorded Q3 = Y for all six rows. This section is the independent second read
that Q3's own labelling invites, and it disagrees on four of them.

### A2 — three rows assert a wall the kit deliberately does not claim (the most serious)

Shipped, **3 occurrences** (`curated-skills-registry.md:31`, `:32`, `:33`):

> *"This skill is protected from being changed by any other skill."*

Pre-edit, in each row: *"(deny-listed — never itself an apply target)"* — a claim that **names its
mechanism** (the deny-list) and **scopes itself to one channel** (an apply).

The rewrite drops both the mechanism and the scope and states an unconditional guarantee. The kit's
own documents refuse that guarantee, in writing, twice:

- `skills/self-apply/SKILL.md:63` — *"Be honest about what kind of wall this is: **nothing in Cowork
  structurally stops a `Write`/`Edit` call from targeting a path outside this list** … What actually
  holds the line is this instruction being followed, plus the confirmation below making every write
  visible before it happens."*
- `TRUST.md:16` — *"What contains this is a bounded allow-list plus your own confirmation, **not a wall
  that makes the write impossible.**"*

`curated-skills-registry.md` is a root file the README tells users to browse; it ships in the archive.
A reader now gets a stronger security belief from the registry than the kit delivers, in a repo whose
previous release was named *Truth Repair* and which maintains a `TRUST.md` specifically to avoid this.

**Not CRITICAL:** no render path consumes a Group B description (the design's §A establishes this and
I did not find one), no runtime behaviour changes, and nothing becomes exploitable. It is a
truthfulness regression on a security claim, not a vulnerability.
**Remedy — three cells, one clause each:** *"This skill is on the deny-list: the apply channel can
never target it."*

### A3 — `self-upgrade` states the invariant in the wrong order, and names the wrong reason

Shipped (`:33`): *"…protects itself with a **write-then-check-then-replace** process so an update can
**never leave things half-finished**."*

`skills/self-upgrade/SKILL.md:41`, the invariant this replaced:

> *"**Verifies the incoming new machinery UNDER the pre-upgrade (known-good) gate BEFORE it goes
> live** — verify-then-swap, **never** swap-then-verify-under-the-incoming-gate. The old gate remains
> the acting authority until the new machinery passes verification under it. This order is an
> **inherited imperative** … and it MUST hold here exactly as stated."*

and `:72`: *"Verify-then-swap is the entire point of this skill; **the reverse order lets
attacker-chosen code become the authority that then verifies itself.**"*

Three defects in one clause:

1. **The order reads verify-second.** *Write-then-check* puts the write first and never says **under
   which gate** the check runs — which is the entire content of the invariant. The ambiguity it
   introduces is precisely `swap-then-verify-under-the-incoming-gate`.
2. **The stated purpose is substituted.** *"Never leave things half-finished"* is atomicity /
   crash-safety. The two-write-class model defends **trust-anchor preservation**, not atomicity. A
   reader now believes the control protects against a different threat than the one it protects
   against.
3. **`can never`** is an unconditional guarantee the source text does not make.

The skill's own frontmatter (`SKILL.md:3`) still reads `verify-then-swap`, so the shipped tree now
carries **two descriptions of the same control stating different orders**, and the user-facing one is
the wrong one. (Frontmatter `description:` fields were correctly out of scope this cycle — recorded at
0.D as a successor carry-forward — so the divergence is expected; that it is now a *contradiction*
rather than a *register difference* is what elevates it.)

**Systematic, not incidental — and the same shape as S15.** `verify-then-swap` is Jargon-List term
#15. AC-PL-1 **required** removing it. The AC's own mandated remedy is what produced the error. This
is the third confirmed instance of the pattern: *the corrective action is the defect vector.*

**Remedy:** *"…checks the new version against the version you already trust before it takes over, so
new code can never be the thing that approves itself."*

### A6 — `self-archive` promises an undo the skill does not offer

Shipped (`:32`): *"…keeps a record of every move so it **can always be undone**."*
Closing message (`WIZARD.md:339`): *"…and does so reversibly, **meaning any move it makes can always
be undone**."*

`skills/self-archive/SKILL.md` says otherwise, in its own words:

- `:73` — after both checks pass, the source is unlinked: *"**the one point at which this operation
  becomes irreversible-by-forward-motion**"*.
- `:79` — *"Rollback … **only ever follows a verifier FAIL**."* There is no user-invocable "undo that
  archive move" path.
- `:71` — a named accepted limit: a prose-only reference is not caught by the reference-integrity
  check.

`reversibly` (the AC-PL-7 row-5 protected token) is preserved verbatim — the AC passes. The **gloss
appended to it** is what over-promises. Practical harm is bounded: nothing is deleted, the file is in
`context/.archive/`, and a user can move it back by hand — so *"can be undone"* is true manually. But
a user who reads *"always be undone"* will approve archive proposals with less scrutiny than the
turn-two confirmation is designed to attract.
**Remedy:** *"…and keeps a record of where every file came from, so you can always put it back."*

### A7 — `pull-updates` turns a locality statement into an implied-remote one

| | text |
|---|---|
| pre | *"classifies every installed curated skill via **fresh-bytes-on-both-sides** against **the on-disk pool** and **the workspace's own install manifest**"* |
| post | *"Checks every skill you've installed against **the latest available version**, comparing them byte-for-byte so it only flags real differences"* |

Two losses:

- **Locality.** *"The on-disk pool"* states plainly that the comparison never leaves the machine.
  *"The latest available version"* reads as a check against something newer and elsewhere. Nineteen
  lines from `WIZARD.md:123`'s *"No URL paste, no external source, no registry `source_url` direct
  fetch"*, the registry now describes the same kit as checking for the latest version. A user would
  reasonably infer the kit reaches out. **The word `latest` is doing the damage; `available` is fine.**
- **The freshness property.** *Fresh-bytes-on-both-sides* is a staleness defence — it re-reads bytes
  from disk on **both** sides rather than trusting a cached hash, so a stale or tampered manifest
  cannot mask a difference. *"Byte-for-byte so it only flags real differences"* captures the comparison
  and loses the defence. The second comparison source (the install manifest) is dropped entirely.

Same species as S15: neither leg (a), (b) nor (c) can see it, because nothing was deleted and nothing
was added — the *reference* moved.
**Remedy:** *"…against the copies included with this kit on your own computer, re-reading both files
fresh each time so a stale record can't hide a difference."*

### A11 / A12 / A13 — accuracy, not safety

- **A11, `self-apply`:** *"requires **you** to propose a change, check it, and be able to reverse it
  **before it takes effect**"* inverts the actor — `SKILL.md:41` has the **skill** render the
  four-part proposal and the **user** give the fresh yes — and mis-times rollback, which follows a
  verifier FAIL after the write (`:100`, `:108`). Also *"records every change you approve"*
  misdescribes the ledger, which records **behavioural friction** (`SKILL.md:29`), not approvals.
  The inversion errs toward *more* user vigilance, which is why this is INFO and not WARNING.
- **A12, `anti-ai-slop`:** the original removes *"uniform sentence rhythm"*. The rewrite says the skill
  *"**Smooths out** text"* and works by *"**flattening** repetitive sentence patterns"* — both words
  describe making prose **more** uniform, the opposite of the skill's purpose. `AI-tell vocabulary`,
  one of the original's three targets, is dropped. `anti-ai-slop` **is** a Group A row with a real
  render path (role-generation ≤12-word fallback), so this one is actually read aloud to users.
  **Remedy:** *"breaking up repetitive sentence patterns"*.
- **A13, `prompt-gate`:** *"up to 3 grounded clarifying questions"* → *"a few clarifying questions"*.
  A bound became a vague quantity, in a cycle that treated the `25` numeral as load-bearing enough to
  bind an AC around it. `up to 3` is not on the Jargon List and did not need to go.
- **A14, `CHANGELOG.md`:** *"all three of `self-archive`'s safety phrases … `never on its own`"* —
  `never on its own` is `pull-updates`'. AC-PL-7 row 5 groups all three under *"WIZARD.md Closing"*,
  not under one skill. Public-facing attribution error.

---

## 5. Deferred ACs — confirmed NOT partially implemented

| check | command | result |
|---|---|---|
| no file moved under `docs/` | `git diff --stat -M fd00dd2..09bbced -- docs/` | 4 files, **0 renames** |
| `.gitattributes` untouched | same, `-- .gitattributes` | absent from output = unmodified |
| the 14 leaked reports still at `docs/` root | `ls docs/ \| grep -c 'qa-report\|security-review\|security-audit'` | **14** — unchanged from Phase 2 |
| AC-PL-11's archive-leak gate not built | `grep -c 'archive-leak\|AC-PL-9…13' .github/workflows/quality.yml` | **0** |
| deferral marked and greppable | `grep -rn DEFERRED-TO-RETROFIT-CYCLE docs/` | 11 hits across `spec.md`, `design-v2.19.10.md` |

`docs/spec.md:8601-8602` binds it explicitly: *"@dev MUST NOT implement AC-PL-9 … AC-PL-13"* /
*"@qa MUST NOT test"*. **No half-landed deferred AC. The separation is clean.**

**The one deletion in the append-only docs is legitimate.** `docs/architecture.md`'s ADR-**INDEX**
row for ADR-037 was amended in place — the index is the mutable pointer, ADR bodies are append-only —
and the amendment is honest about its own state: *"ADR-088, which supplies the remedy, is PROPOSED
(deferred) as of Phase 1.3 — the corrections stand, the retrofit that closes them has not yet
shipped."*

---

## 6. Classification re-derivation — Tier B, no Guard Change Summary owed

Re-derived on the **final** diff `fd00dd2..09bbced` (17 commits: @architect's, @dev's and @qa's), not
on @architect's or the gate's record.

| condition | command | result |
|---|---|---|
| **TIER-1** — any file under `scripts/` added or modified | `git diff --name-only fd00dd2..09bbced -- scripts/` | **empty** |
| **TIER-2** — `cowork.lock.json` / `.cowork-allowlist.json` modified | `git diff --name-only fd00dd2..09bbced -- cowork.lock.json .cowork-allowlist.json` | **empty** |
| **TIER-3** — `.github/CODEOWNERS` modified, incl. adding a path this cycle touches | `git diff --name-only fd00dd2..09bbced -- .github/CODEOWNERS` | **empty** |
| **TIER-4** — AC-PL-6's control implemented under `scripts/` | `git diff --name-only fd00dd2..09bbced \| grep -c '^scripts/'` | **0** |

**The zeros are non-vacuous, and that was proven, not assumed** — `git diff -- <path>` also returns
empty for a path that does not exist:

- all four paths are tracked: `git ls-files scripts/ \| wc -l` → **16**;
  `git ls-files cowork.lock.json .cowork-allowlist.json .github/CODEOWNERS` → all three listed.
- **negative control on the TIER-1 command itself:** run over a range where `scripts/` genuinely
  changed (`adf2586..4fc20dd`) it returns `scripts/verify-ledger-annotations.sh`. The command can
  return non-empty; the empty result means *not modified*.
- AC-PL-6's control is **inline** at `quality.yml:614-695`, inside the existing `registry-sha256-check`
  job — never a file under `scripts/`.

The full changed-file list is 12 files: `.github/workflows/quality.yml`, `CHANGELOG.md`,
`CONTRIBUTING.md`, `README.md`, `VERSION`, `WIZARD.md`, `curated-skills-registry.md`,
`docs/architecture.md`, `docs/design-v2.19.10.md`, `docs/internal/qa/qa-report-v2.19.10.md`,
`docs/spec.md`, `examples/personal-assistant/context/working-rules.md`. **No `scripts/`, no `.claude/`,
no lock, no allowlist, no CODEOWNERS.**

### Ruling

**Tier B — worktree branch + PR required. Guard Change Summary NOT required.**

`.github/workflows/` is the only ceremony-bearing surface touched, and per
`docs/pipeline-policy.md §PostOQClassificationReRun` (and CLAUDE.md's PR-only-surfaces rule) that is
**Tier B**: PR required, GCS not required. Nothing in the range touches `scripts/guards/`,
`.claude/settings.json`, `docs/pipeline-policy.md`, or any `scope_allow:` block — the four Tier-A
surfaces. **No Guard Change Summary is owed for v2.19.10.** This matches the Phase-2 and Phase-2.1
derivations, arrived at independently over the larger final range.

---

## 7. CI — job by job, not summary

Run `32367404750`, commit `09bbced`, event **`push`**, `Quality Checks`, 41s.

**31 success · 0 failure · 3 skipped.** The three skipped are exactly the three jobs carrying
`if: github.event_name == 'pull_request'` — `lock-content-sha-cross-check`, `/sync-agency Dry-Run`,
`Vendored Removal Ledger` — consistent with a push event, not a silent bypass.

**The AC-PL-6 steps ran, and CI's own numbers were read rather than @dev's report:**

```
AC-PL-6 fixture 'clean': 30 valid-hex rows.
AC-PL-6 fixture 'pipe': 29 valid-hex rows.
AC-PL-6 fixture 'compound': 29 valid-hex rows.
AC-PL-6 fault-injection PASSED — clean=30, both damage fixtures detected.
AC-PL-6 PASSED — 30 rows carry a valid sha256 cell in field 8 (pin: 30).
```

Both new steps show `conclusion: success` in the job's step list — neither was skipped. These figures
reproduce my own independent local run of the same fixtures **exactly** (30 / 29 / 29).

**A16 — no PR exists.** `gh pr list --head release/v2.19.10-plain-language --state all` → `[]`.
Tier B requires one, and the three PR-only jobs above have never executed against `09bbced`. Per
CLAUDE.md's pre-merge gate, `gh pr checks <PR>` must be fully green **before** the merge confirmation
is presented. This is an orchestrator action, not a defect in the work.

---

## 8. The register defect class — the sweep

The brief asks for other in-scope strings where the rewrite changed **meaning** rather than register,
noting that a missed occurrence and a changed meaning are different failure modes. The sweep found a
**third** mode neither category anticipated.

### A1 — the displaced address (the finding of this audit)

The cycle inserted `## Runtime-string register`, 25 lines, at `CONTRIBUTING.md:72`. Every line-pinned
citation into that file at line ≥ 72 shifted by exactly 25. **`CONTRIBUTING.md` is one of the most
heavily line-pinned files in the repo.** Three anchor families confirmed broken:

| cited anchor | what it was | where it is now | what the cited line says today |
|---|---|---|---|
| `CONTRIBUTING.md:129` | the ADR-055 forbidden-imperative-token scan recipe (LLM01) | **:154** | `\|---\|-------\|--------------------------\|` — a markdown table separator |
| `CONTRIBUTING.md:77` | the SkillRisk external-content scan rule | **:102** | a line of the newly-inserted §Runtime-string register |
| `CONTRIBUTING.md:309` | the release-tagging procedure (ADR-076), called *"the governing written procedure"* at `docs/spec.md:6406` | **:334** | unrelated workflow-name-parsing guidance |

**The recipe text itself is byte-unchanged** — `cmp` of `fd00dd2:CONTRIBUTING.md` line 129 against
`HEAD` line 154 is identical. Only the address moved. So the `AC-F3-1` / `MF-S-5` invariant
(*the scan pattern in `scripts/canonicalize-scan.sh` must be byte-identical to `CONTRIBUTING.md:129`*)
is still true in substance and false in citation.

**Reach:** `grep -roF "CONTRIBUTING.md:129"` → **53 occurrences**, **15 of them outside `docs/`**, i.e.
in live operational surfaces:

- `skills/self-apply/SKILL.md:45` — **ships into every user workspace.** The runtime instruction that
  tells the model which recipe to run before quoting a ledger `Note` into a proposal. This is the
  LLM01 control in the apply flow.
- `scripts/canonicalize-scan.sh` — 5 occurrences, including the header's byte-identity claim.
- `tests/fixtures/canonicalization/f2-1`, `f2-2`, `f2-3` — 6 occurrences, each instructing a manual
  *"run the ADR-055 scan (CONTRIBUTING.md:129 recipe)"*.
- `PROMOTE.md:34`, `.github/workflows/quality.yml:1309`, `CHANGELOG.md`.

**No instrument saw it and none could.** `markdown-lint`, `link-check` (lychee does not resolve
`file.md:NNN` prose citations), `wizard-consistency-check`, and `canonicalize-scan-check` all passed;
`quality.yml`'s only `CONTRIBUTING.md` mention is an error-message string at `:486`, not a line
resolution. **Nothing goes red — which is the worse mode for a broken anchor.** The one way it could
become actively harmful: someone re-verifying the byte-identity invariant reads `:129` literally, sees
a table separator, and "repairs" the discrepancy by editing `canonicalize-scan.sh` to match — forking
the scan pattern that three cycles of work exist to keep unforked.

**Not CRITICAL:** the recipe is present, byte-identical, CI-enforced, and each citation also names it
descriptively (*"the forbidden-imperative-token recipe"*), so the control degrades rather than
disappears. **It is the one item I would fix before merge** — the cost is a `sed` over 15 non-docs
occurrences, or better, de-pinning to a section reference
(`CONTRIBUTING.md § Placeholder authoring rules, rule 2`) so the class cannot recur.

### A5 — the dangling label

`WIZARD.md:100` (Path C, the zero-coverage branch): *"Then route into F4's **"Add from full pool"**
flow."* — `WIZARD.md:119` renamed that label to **"Add from the full skill library"** this cycle.
`grep -rn 'Add from full pool' WIZARD.md` → **0 hits.** The routing instruction names a target that
no longer exists, 19 lines away in the same file, in the branch that fires precisely when nothing
matched the user's goal. `wizard-consistency-check` verifies slug↔registry↔preset↔menu agreement and
personalization placeholders; it does not resolve WIZARD-internal cross-references, so this is
uncovered. **Remedy:** one-line edit at `:100`.

### A8 — the register declares a scope the tree does not meet

The new `CONTRIBUTING.md § Runtime-string register` lists as in-scope: *"`WIZARD.md` — **every** spoken
or quoted string (`Say:`, `respond:`, `Display as:`)"*. Shipped, still carrying undefined Jargon-List
terms inside quoted or `Say:`-prefixed strings:

| line | term | text |
|---|---|---|
| `:68` | `bundle` | *"…or set it aside and build a custom bundle from scratch?"* |
| `:355` | `bundle` | *"…2) Add or remove skills from your bundle …"* |
| `:417` | `bundle` ×2 | `Say:` *"…we confirmed this bundle: [Confirmed bundle]."* |
| `:93` | `pool` | *"…a draft team I pulled from the pool…"* |
| `:97` | `pool` | `Say:` *"Nothing in the pool matched a starting draft for this one…"* |

**These are correctly out of AC-PL-3's scope** — the AC scopes itself to the F4 block and states the
in-scope `bundle` count as 2. So this is not an AC failure and not a missed occurrence within the
declared scope. It is a **newly-minted governance document that reads as describing enforced state
when it describes intent.** A contributor will believe the rule already holds repo-wide.
**Remedy:** one sentence — *"v2.19.10 applied this to the surfaces listed in `docs/spec.md`
§AC-PL-1…8; the remaining `WIZARD.md` spoken strings are a tracked follow-up."*

### What the sweep confirms about the class

@qa found a **missed occurrence** (`WIZARD.md:132`, `bundle`). I found **changed meanings** (A2, A3,
A6, A7, A11, A12) and a **displaced address** (A1) — three distinct failure modes from one cycle of
"just rewording." A5 is a fourth: a rename that broke its own cross-reference. The generalizable
lesson, and it is the same one S1/S2/S15 taught at Phase 2: **the mandated corrective action is itself
the defect vector**, and the instruments minted to police a rewrite police only the axis the rewrite
was expected to damage.

---

## OWASP Top 10 Assessment (Phase 6)

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | **WARN** | A2 — three registry rows assert an unqualified protection guarantee over the `self-*` deny-list that `SKILL.md:63` and `TRUST.md:16` explicitly disclaim. The control itself is unchanged and intact; its **description** over-claims. |
| A02 Cryptographic Failures | N/A | No cryptography in scope. |
| A03 Injection | PASS | No new parser consumes external input. AC-PL-6's `awk` reads this repository's own registry only. No new user-supplied value reaches a shell. |
| A04 Insecure Design | **WARN** | A4 — the only new control's self-test does not exercise the parser the control runs; demonstrated false-green under a one-line drift. A15 — the pin is an aggregate with a compensating-pair blind spot. Both have inline, Tier-B-preserving remedies. |
| A05 Security Misconfiguration | **WARN** | A1 — three canonical anchors displaced, 53 citations, no instrument resolves them. A9 — the unguarded leg-A procedure still ships publicly. |
| A06 Vulnerable Components | PASS | No dependency change in the range. All Action SHAs remain pinned (`actions/checkout@11bd719…`). No `npm`/lock surface in this repo. |
| A07 Identification & Auth Failures | N/A | No authentication surface. |
| A08 Software & Data Integrity Failures | **PASS WITH NOTE** | `registry-sha256-check` fail-closed and green; AC-PL-6 correctly lands **before** the first description edit (`1e5d44d` precedes `ea22a09`), so the instrument existed before the damage was possible. The note is A4. |
| A09 Security Logging & Monitoring | **WARN** | Unchanged from Phase 2: still zero CI coverage of the 8 `working-rules.md` files; AC-PL-7 remains a hand-run audit. A5's dangling reference and A1's displaced anchors each passed 31 green jobs. |
| A10 SSRF | **PASS WITH NOTE** | The pool boundary at `WIZARD.md:123` is intact and strengthened (leg A both halves, leg B = 2). Note A7: `pull-updates`' description now *reads* as though the kit checks for a "latest available version" — a description-level drift toward an egress reading, with no corresponding behaviour. |

## LLM Threat Assessment (Phase 6)

| Category | Status | Notes |
|----------|--------|-------|
| LLM01 Prompt Injection | **WARN** | A1 — `skills/self-apply/SKILL.md:45`, the runtime instruction naming the injection re-scan recipe, cites `CONTRIBUTING.md:129`, which is now a table separator. The recipe is byte-unchanged at `:154` and the citation also names it descriptively, so the control degrades rather than fails. No new untrusted-input path was introduced by this cycle. |
| LLM02 Insecure Output Handling | PASS | The 6 rewritten descriptions were read for instruction-shaped content: all declarative, no imperative verbs, no `Ignore`/`Disregard`/`Override`/`Instead of`/`Always respond`/`New instruction` tokens. `canonicalize-scan-check` green. Group A rows (`prompt-gate`, `anti-ai-slop`) do reach role-generation; their new text is safe to render (A12 is an accuracy defect, not a safety one). |
| LLM06 Sensitive Information Disclosure | **WARN** | A10 — **14** internal QA/security reports still ship in every public release archive, enumerating this kit's own unfixed gaps and inert controls. Correctly deferred; the retrofit forces Tier A. A9 adds `docs/design-v2.19.10.md`'s unguarded procedure to the public surface. |
| LLM08 Excessive Agency | PASS | No new autonomous capability. `never on its own` and `never silently performs` both preserved verbatim. A3's *"It **handles** moving your setup forward when a newer release … becomes available"* was checked against `SKILL.md:14` — the skill is dormant and invoked, not self-triggering; the sentence is loose but does not assert autonomy. |

---

## Archive check — neither report ships

```
git archive HEAD | tar -tf - | grep -c 'security-.*v2\.19\.10'   →  0
git archive HEAD | tar -tf - | grep -c '^docs/internal/'          →  0
```

**Negative control, because a zero from an untested grep is worth nothing.** The identical grep shape
with one fewer digit — `grep -c 'security-.*v2\.19'` — returns **7**, matching the pre-existing leaked
reports at `docs/` root. The command can return non-zero; the **0** above means genuinely absent, not
silently broken.

`docs/internal/` is excluded wholesale (0 entries in the archive), which also confirms @qa's report at
`docs/internal/qa/qa-report-v2.19.10.md` is correctly out. Both of this cycle's security artifacts are
at `docs/internal/security/` and neither reaches a user.

---

## Summary

**PASS WITH WARNINGS — 0 CRITICAL. Phase 7 is reachable.**

The engineered parts of this cycle are sound and, in two places, better than their own record.
AC-PL-6 is genuinely load-bearing — I proved the drift-verify step silently skips a row whose field 8
has shifted, so the pinned count really is the sole gate — and the clean-fixture leg forecloses the
"typo returns 0, looks like a pass" mode outright. AC-PL-7 is GREEN across all six rows on shipped
bytes, with every leg re-proven able to fail first. The `APIs` appositive is **addition-only by
`cmp`**, all three of my Phase-2 binding conditions hold, and **`/legal` is not owed.** S15 is
resolved: @dev chose the machine boundary over the internet boundary, which is the difference between
a narrowed guarantee and an intact one. The deferred set is cleanly separated — 14 files still at
`docs/` root, 0 renames, 0 CI lines. Tier B re-derives with a firing negative control; **no Guard
Change Summary is owed.**

**What the instruments could not see is where this cycle actually cost something.** Five instruments
this cycle returned green on the condition they existed to catch; @qa hunted a sixth and found none.
The sixth was not another instrument — it was **the absence of one**. Nothing in this repository
compares a registry description against the skill it describes, and the plain-language pass used that
freedom to state three security claims the kit's own `TRUST.md` refuses (A2), to restate a security
invariant in the wrong order and for the wrong reason (A3), to promise an undo that does not exist
(A6), and to turn a locality statement into an implied-remote one (A7). Separately, a 25-line
insertion displaced three canonical line-pinned anchors cited 53 times, one of them the address of
this repo's prompt-injection recipe, now a markdown table separator (A1) — a failure mode that is
neither a missed occurrence nor a changed meaning, and that 31 green CI jobs could not have caught.

None of it is exploitable and none of it blocks. All of it is prose about security machinery, in a
public repository, in a release whose predecessor was named *Truth Repair*. **A1, A2 and A3 are the
three I would fix before the PR is opened** — together they are roughly six sentences and one `sed`,
they need no new instrument, and they do not touch a Tier-A surface.

**The pattern worth carrying to Phase 8:** across S1, S2, S15, A3 and A12, the cycle's own **mandated
corrective action was the defect vector** — the fixture anchored on the string the AC required
rewriting; the appositive the AC required adding narrowed the term; the jargon term the AC required
removing (`verify-then-swap`) took the invariant's order with it. That is now five instances across
two phases and it is the generalizable finding of v2.19.10, more than any individual row.
