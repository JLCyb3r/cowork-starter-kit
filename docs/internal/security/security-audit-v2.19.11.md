# Security Audit — v2.19.11 "Pay the Tier-A debt"

## Phase: 6
## Date: 2026-08-22T02:41:36Z
## Branch / SHA audited: `release/v2.19.11-tier-a-debt` @ `bbb28539c4dfd4bf3ad5053adb47e31d486c3ae3`
## Cycle base: `b7b844716aa3146f212907ee381a49256aa1fd13`
## Diff range: `b7b8447..bbb2853` — 12 files, +3374 / −11
## Classification: SECURITY-SENSITIVE, **Tier A** (settled at Phase 0; not re-litigated here)
## Status: **PASS WITH WARNINGS**

**CRITICAL: 0 · BLOCKER: 0 · WARNING: 6 · INFO: 5**

Nothing at BLOCKER or above. **The merge is not blocked by this audit.**

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | CRITICAL | 2 | configuration | **CLOSED.** AC-3 anchor guard fail-open. Corrected step verified byte-present in the SHIPPED `quality.yml`; 6 independent RED directions reproduced; the fix's own load-bearing half proven by sabotage. |
| S2 | WARNING | 2 | logging | **CLOSED.** Success line now prints measured values. Confirmed in the real CI log at HEAD, not only locally. |
| S3 | WARNING | 2 | configuration | **DEFERRED — `CF-v2.19.11-A`.** Scope is **larger than the Phase 2 text says**: 3 shipping files, not 1. See S12/S14. |
| S4 | WARNING | 2 | permissions | **CLOSED for `self-apply`'s row.** New description verified clause-by-clause against `skills/self-apply/SKILL.md:53,59`. See S11 for the residue. |
| S5 | WARNING | 2 | permissions | **OPEN — owner DEFER-AND-BUNDLE at the Phase 3 gate.** Risk row `v2.19.11-PULL-ROW-1` present and well-formed. Ships unfixed. |
| S6 | INFO | 2 | logging | Reachable, unchanged in shipped code: `FIX="$(mktemp -d)"` in AC-8b aborts undiagnosably if `mktemp -d` fails. Fail-closed. |
| S7 | INFO | 2 | ui | **Superseded by S15** — re-tested against the shipped step and widened. |
| S8 | INFO | 2 | dependency | **Confirmed against the shipped tree.** `ShellCheck` runs `scandir: "./scripts"` (`quality.yml:132`). Both new inline `run:` blocks receive **zero** static analysis. |
| S9 | INFO | 2 | configuration | Unchanged. AC-1 ships a bare `mktemp`; TMPDIR behaviour differs BSD/GNU. Not a defect. |
| S10 | INFO | 2 | configuration | Unchanged. AC-10 ships no standing CI control (design §H.5, deliberate). Compounded by the QA §H.4 finding below. |
| S11 | WARNING | 6 | permissions | S4's correction lands on **1 of 3** sibling safety-skill rows. `self-archive` and `self-upgrade` still carry the exact over-claim S4 judged inaccurate, and `pull-updates` backfills all three. Post-cycle the three rows assert three different guarantee shapes. Pre-existing; not introduced; outside AC-8's scope. |
| S12 | WARNING | 6 | configuration | **ADR-088 §Decision (3) and ADR-090 give opposite answers for the same three shipping files.** ADR-088 freezes Class-B references; ADR-090 mints a repo-wide anchored-citation convention. ADR-090 is ACCEPTED, ADR-088 is PROPOSED, and nothing in the diff reconciles them. Binding on whoever scopes `CF-v2.19.11-A`. |
| S13 | WARNING | 6 | configuration | `CONTRIBUTING.md` is `export-ignore`d; `git archive bbb2853` contains **0** entries for it. All **four** citing files DO ship. AC-2's five *repaired* citations are therefore resolvable in-repo and **unresolvable for every user** — the fix improved the maintainer surface, not the user surface. |
| S14 | WARNING | 6 | configuration | The AC-3 guard hardcodes heading level `### `. `templates/skill-template/SKILL.md:14` targets an **h2** (`CONTRIBUTING.md:114`). A naive widening of the guard to that file returns `headings=0` for a **correctly normalized** citation — a false RED. Widening needs a level-agnostic match, not just a file-list change. |
| S15 | WARNING | 6 | logging | `$ANCHOR` is derived from file contents and interpolated at **six** sites. **Command execution is impossible — proven.** But an attacker-chosen string reaches the `::error::` workflow-command payload AND, newly demonstrated, **the runner's stdout on the exit-0 success path**. GHA's `%0A` decoding at that site is **NOT RUN**. Cannot flip a RED job GREEN. |
| S16 | INFO | 6 | logging | AC-1's raw-stderr passthrough is a genuinely **new** data-exposure surface (the old `2>/dev/null` discarded it). Demonstrated verbatim reproduction of URL userinfo. Low real-world exposure; design explicitly forbids a redactor. Recorded so it is not mistaken for an oversight. |

---

## §0. Scope, and what was actually executed

Everything below marked with a command was **run by me during this audit**, in this repo, at
`bbb2853`. Anything I could not run is labelled **NOT RUN** and is stated as a hypothesis, not a
finding.

**Structural preconditions, verified:**

| Claim | Command | Result |
|---|---|---|
| 12 files, +3374/−11 | `git diff --numstat b7b8447..bbb2853` | confirmed, matches the brief exactly |
| Deletions in exactly 4 files | same | `CHANGELOG.md` 3/3 · `curated-skills-registry.md` 2/2 · `canonicalize-scan.sh` 5/5 · `verify-release-surface.sh` 35/1 |
| **Zero renames** | `git diff --name-status -M -C b7b8447..bbb2853 \| grep -E '^[RC]'` | **empty — no file moved** |
| Append-only files show 0 deletions | `git diff --numstat` | `architecture.md`, `spec.md`, `retro.md`, `risk-register.md` all `N 0` |
| No new action, no new SHA | diff of `quality.yml` | +70/−0, contains no `uses:` |
| No new secret / token surface | diff scanned for `ghp_`/`AKIA`/`BEGIN `/`xox`/`sk-`/`token=` outside `docs/` | 0 hits |
| CI green **at HEAD** | `gh api …/commits/bbb2853/check-runs` | 31 success, 3 skipped, **0 failure** (run `32546385714`) |

**Correction to the brief.** The brief cites run `32545547627` (`edd5b82`) as the CI evidence. That
run is one commit stale. The authoritative run for the merge gate is **`32546385714` at `bbb2853`**,
which is also green. Both new steps executed in it — see §1.3.

---

## §1. S1 — confirm or overturn

### 1.1 The corrected step is in the shipped workflow, not only the design

`.github/workflows/quality.yml:1436-1468`. Extracted mechanically from the YAML (not transcribed)
and executed. Both halves of the S1 fix are present verbatim:

- **Half 1 — the `-r` precheck** loop over `"$SCRIPT"` and `"$DOC"` (`:1451-1456`).
- **Half 2 — the `"${X:-x}" != "…"` string comparisons** at `:1463`, `:1465`, `:1467`.

### 1.2 Six RED directions — all independently reproduced

I did **not** rely on the orchestrator's transcript. Every leg below was re-run by me against the
step extracted from the shipped YAML.

| Direction | Fixture | Result |
|---|---|---|
| GREEN — real tree | `scripts/canonicalize-scan.sh` + `CONTRIBUTING.md` | `anchor guard PASSED — anchor='Worked-example authoring rules (S1 security carry-forward)' distinct=1 cites=5 headings=1` · exit 0 |
| RED-a — heading renamed | `### Worked-example authoring rules RENAMED` | `resolves to 0 headings, expected 1` · exit 1 |
| RED-b — heading duplicated | heading emitted twice | `resolves to 2 headings, expected 1` · exit 1 |
| RED-c — citation typo (1 of 5) | `Worked-exmaple` in one cite | `expected 1 distinct cited anchor, found 2` · exit 1 |
| RED-d — pre-AC-2 tree | `git show b7b8447:scripts/canonicalize-scan.sh` | `expected 1 distinct cited anchor, found 0` · exit 1 |
| RED-e — `$DOC` missing | nonexistent path | precheck fires: *"missing or unreadable … must never report PASSED"* · exit 1 |
| RED-f — `$DOC` is a **directory** | `mkdir doc-isdir` | `resolves to <non-numeric> headings` · exit 1 |

### 1.3 The check that cannot fail — negative control on the negative control

RED-f is the leg that matters, because a directory **passes `-r`**. To prove Half 2 is genuinely
load-bearing rather than decorative, I built the pre-S1 form of the step (the three string
comparisons reverted to `-ne`) and ran it against the same directory fixture:

```
$ bash -e ac3-sabotage-half2.sh script-ok.sh doc-isdir
grep: doc-isdir: Is a directory
ac3-sabotage-half2.sh: line 30: [: : integer expected
anchor guard PASSED — anchor='Worked-example authoring rules (S1 security carry-forward)' distinct=1 cites=5 headings=
```

**Exit 0. `PASSED`.** That is the S1 defect, reproduced on demand. The shipped form returns exit 1
on the same input. **Both halves are load-bearing; the comment block at `:1441-1450` is accurate.**

### 1.4 It ran GREEN in real CI, not only on my machine

From the downloaded log of run `32546385714` at `bbb2853`:

```
Canonicalize + Forbidden-Token Scan Check … anchor guard PASSED — anchor='Worked-example authoring rules (S1 security carry-forward)' distinct=1 cites=5 headings=1
```

**S1: CONFIRMED CLOSED.**
**S2: CONFIRMED CLOSED** — the success line carries `distinct=1 cites=5 headings=1` as *measured*
values in that same production log, so the S1 fail-open transcript is no longer
byte-indistinguishable from a true pass.

---

## §2. AC-8b/AC-9b — the second new inline step

Also extracted from the shipped YAML and executed (`quality.yml:723-756`).

| Direction | Result |
|---|---|
| GREEN — real registry | both slugs OK; self-test PASSED; exit 0 |
| pipe injected into `self-apply` description | RED (step's own self-test) |
| pipe injected into `prompt-gate` description | RED (step's own self-test) |
| `self-apply` row deleted | RED (step's own self-test) |
| benign whitespace reflow | GREEN (no false positive) |
| **duplicate `self-apply` row** (my fixture) | RED · exit 1 |
| **uppercase hex in field 8** (my fixture) | RED · exit 1 |
| **registry file missing** (my fixture) | RED · exit 1 |

**Anti-vacuity guard proven to fire.** I fed the step a registry whose `| self-apply |` anchor was
already reflowed, making the `sed` fixture a no-op:

```
::error::AC-8b FIXTURE SETUP FAILED - the reflow fixture was a no-op; its field-2 anchor no longer
exists in the registry. Repair the FIXTURE anchor. Do NOT relax the assertions below.
```

This is the leg that converts a sabotaged checker's unearned GREEN into RED. It works. That matters
directly: it is the load-bearing basis on which the owner accepted S5 (risk row
`v2.19.11-PULL-ROW-1`), and I can now say the gate it rests on is not vacuous.

**Executed in real CI at HEAD:**
`AC-8b/AC-9b PASSED - gated slugs verified: self-apply prompt-gate.`

---

## §3. The new attack surface nobody had audited

`$ANCHOR` is derived from **file contents** (`scripts/canonicalize-scan.sh`) and interpolated into
shell. Re-checked against the **shipped** step, not the design.

### 3.1 The six interpolation sites

| Line | Site | Context |
|---|---|---|
| `quality.yml:1461` | `ANCHOR="$(grep -oE … \| sed … \| sort -u \|\| true)"` | assignment; `grep -oE` pattern excludes backticks by construction, so `ANCHOR` can never contain one |
| `:1462` | `printf "%s\n" "$ANCHOR" \| grep -c .` | double-quoted; `printf` format string is a literal, `$ANCHOR` is an **argument** — no format-string injection |
| `:1464` | `grep -cF "\`CONTRIBUTING.md § ${ANCHOR}\`" "$SCRIPT"` | `-F` fixed-string; pattern begins with a literal backtick so no leading-`-` option injection |
| `:1466` | `grep -cF "### ${ANCHOR}" "$DOC"` | `-F`; pattern begins `### ` so no option injection |
| `:1467` | `echo "::error::… '${ANCHOR}' resolves to …"` | **GitHub Actions workflow-command payload** |
| `:1468` | `echo "anchor guard PASSED — anchor='${ANCHOR}' …"` | **runner stdout, on the exit-0 path** |

### 3.2 Command injection — RULED OUT, by execution

Fixture: a `canonicalize-scan.sh` whose five citations carry the anchor
`$(id > …/PWNED); ; %0A::notice::injected`.

```
::error::anchor guard — '$(id > …/PWNED); ; %0A::notice::injected' resolves to 0 headings, expected 1.
$ ls …/PWNED
No such file or directory
```

No subshell ran. This is correct and not accidental: **every** site expands `$ANCHOR` inside double
quotes, and bash does not re-scan a parameter-expansion result for command substitution. Newline
injection is also structurally excluded — `grep -oE` matches within a line, and the `N_DISTINCT != 1`
gate rejects a multi-line `ANCHOR` before either `grep -cF` runs.

### 3.3 What is NOT ruled out — S15 (WARNING)

The attacker-chosen bytes **do** reach two output sinks verbatim. New this phase: I demonstrated the
**exit-0 success path**, which the Phase 2 review did not have.

```
$ bash -e ac3.sh script-exit0-inject.sh doc-exit0-inject.md
anchor guard PASSED — anchor='SAFE%0A::stop-commands::zzz' distinct=1 cites=5 headings=1
```

Exit **0**. To reach this the attacker must land a PR editing **both** `scripts/canonicalize-scan.sh`
(5 citations) **and** `CONTRIBUTING.md` (a matching heading) — a change that is conspicuous in a diff
on a human-reviewed merge path.

**Honest bounds:**

- **NOT RUN:** whether GitHub Actions decodes `%0A` at these two sites into a second workflow
  command on a live runner. Documented behaviour says it does for `::error::` message payloads. I
  did not test it. **Treat that leg as a hypothesis.**
- **Cannot flip RED to GREEN.** Workflow annotations are not the failure mechanism; step exit codes
  are. `::stop-commands::` suppresses annotations, not exits.
- **No token reachable.** Neither host job (`registry-sha256-check:556`,
  `canonicalize-scan-check:1311`) declares `permissions:`, uses `secrets.`, or is triggered by
  `pull_request_target`. Nothing in the diff escalates permissions.
- **No static tool would catch this** (S8): `ShellCheck` is scoped `scandir: "./scripts"` and never
  sees an inline workflow `run:` block.

**Recommended (non-blocking, one line):** emit `$ANCHOR` via `printf '%s\n'` to stdout rather than
inside the `::error::` payload, or strip `%` from `ANCHOR` before echo. Route to the same follow-up
cycle as `CF-v2.19.11-A`.

---

## §4. OWASP / LLM sweep over the implemented diff

| Category | Status | Notes (evidence) |
|---|---|---|
| **A01 Broken Access Control** | PASS | No `permissions:` added or widened; neither host job declares one, uses `secrets.`, or runs on `pull_request_target`. No auth surface in this repo. |
| **A02 Cryptographic Failures** | PASS | Both gated `sha256` cells **byte-unchanged** and still match their files: `shasum -a 256 skills/{self-apply,prompt-gate}/SKILL.md` == the field-8 values. `git diff --name-only b7b8447..bbb2853 -- skills/` → **empty**. |
| **A03 Injection** | PASS | §3.2 — command injection ruled out **by execution**, not by inspection. `grep -F` throughout; no `eval`, no unquoted expansion, no `2>&1` stream merge. |
| **A04 Insecure Design** | PASS | The cycle's whole content is control-hardening. Both new controls carry firing negative controls; AC-8b carries an anti-vacuity self-test that I proved fires. |
| **A05 Security Misconfiguration** | **WARNING** | S13 — `CONTRIBUTING.md` `export-ignore`d (`.gitattributes:16`); `git archive bbb2853` → **0** entries. All 4 citing files ship. S14 — the guard's hardcoded `### ` level blocks a naive widening. |
| **A06 Vulnerable Components** | PASS | No new `uses:`, no new SHA, no `pip`/`npm`/`curl`/`wget` added. `SF-S-1` green. |
| **A07 Auth Failures** | N/A | No authentication surface. |
| **A08 Data Integrity** ← *called out* | PASS | The two gated registry rows: descriptions rewritten, **field-8 hashes untouched and still correct**; row structure intact (9 fields, 1 row each); a **standing** per-row gate now makes structural damage unmergeable — verified RED in 8 damage directions. `Registry Cardinality Check`, `Registry sha256 Drift-Verify Check`, `Registry URL Integrity Check` all green at HEAD. **Semantic integrity also checked, not assumed** — see §5. |
| **A09 Logging & Monitoring** ← *called out* | **WARNING** | Net large improvement: AC-1 converts an opaque exit-128 abort into a diagnosed `exit 2` fail-closed; AC-3 prints measured values. Two residues: **S15** (attacker-influenced bytes reach two log sinks) and **S16** (AC-1's raw-stderr passthrough is a new exposure surface). **S6** unchanged. |
| **A10 SSRF** | N/A | No new network egress. `git ls-remote origin` is pre-existing; `--evidence-dir` mode still makes no network call. |
| **LLM01 Prompt Injection** | PASS | 6-token ADR-055 scan over the two rewritten registry rows → **0**. Non-ASCII scan over the same rows → **0** (no homoglyph, no zero-width). Both rows remain data, not instruction. |
| **LLM02 Insecure Output Handling** | **WARNING** | S15 is the LLM02-adjacent case: content-derived bytes reaching a command-interpreting sink. Bounded as above. |
| **LLM06 Sensitive Info Disclosure** | INFO | S16. Also confirmed: `git archive` at HEAD carries **0** `docs/internal/` entries and **0** `CONTRIBUTING.md`; the pre-existing 14-file leak (`^docs/(qa-report\|security-audit\|security-review)-`) is **still exactly 14 — it did not grow.** This cycle placed both of its own reports under `docs/internal/`. |

---

## §5. Semantic integrity of the two rewritten registry rows (A08, second half)

A structural gate proves the row *parses*. It cannot prove the row *tells the truth*. I checked the
claims against the files they describe.

**`prompt-gate` — "Asks up to 3 clarifying questions":** ACCURATE.
`skills/prompt-gate/SKILL.md:3` — *"asking up to 3 grounded clarifying questions"*; `:73` — *"Cap at
3 questions."* The prior "a few" was vaguer, not wrong; the new form is verifiable.

**`self-apply` — the S4 rewrite:** ACCURATE, clause by clause, against
`skills/self-apply/SKILL.md:53` (the deny-list) and `:59` (the channel-scope carve-out).

| New claim | Verified against |
|---|---|
| "nothing is written until you say yes" | the turn-two confirm→write→verify→rollback gate |
| "you can still undo it from the copy saved beforehand" | `:110` — `context/.apply-backups/<file>.<timestamp>.pre` + transcript fingerprint |
| the 5-member protected list, enumerated | `:53` — all five present, none dropped, `` `self-` `` and `context/.kit-migrations/` preserved per AC-8's token constraint |
| "That list guards this flow, not the whole kit … the updater still installs it … from bytes checked against the published checksum" | `:59` (MF-1c channel scope) + `skills/pull-updates/SKILL.md:47` (AC-PULL-7 / ADR-073) |

**This is the S4 fix working as intended:** an unqualified guarantee replaced by a scoped guarantee
with its exception named. **S4: CONFIRMED CLOSED for this row.**

### S11 (WARNING) — but only for this row

`curated-skills-registry.md` still says, of **`self-archive`** and **`self-upgrade`**:

> *"This file can never be changed or moved by this or any other skill — it's on a fixed, protected
> list that both processes always skip."*

That is the exact over-claim S4 raised, and it is false for the same reason:
`skills/pull-updates/SKILL.md:3` and `:47` name **all three** safety skills as backfill targets. AC-8
was scoped to `self-apply` alone (`docs/spec.md:8813`), so this is **outside the cycle's scope and
not introduced by it** — but the cycle's effect is that the three sibling rows now assert **three
different guarantee shapes**, and a user comparing them cannot tell which is authoritative.

AC-8b/AC-9b also covers only these two slugs, deliberately (`docs/spec.md:8953`) — the sibling rows
have no per-row structural gate.

**Disposition:** bundle with `CF-v2.19.11-A` + S5 in the proposed **v2.19.13**. All three touch the
same registry/skill prose surface, so one review event covers them. Do not open a fourth cycle.

---

## §6. `CF-v2.19.11-A` — the corrected scope (binding on whoever scopes it)

**The Phase 2 text under-scopes this by two files. Anyone scoping v2.19.12/v2.19.13 from the Phase 2
review alone will get it wrong.** The corrected picture, measured at `bbb2853`:

| # | File | Form | Why it fails today | Ships to users? |
|---|---|---|---|---|
| 1 | `skills/self-apply/SKILL.md:45` | backticked, anchor `… , rule 2` | no heading `### Worked-example authoring rules, rule 2` exists → **0 headings** | **YES** |
| 2 | `PROMOTE.md:34` | backticked, anchor `… , rule 2` | same | **YES** |
| 3 | `templates/skill-template/SKILL.md:14` | **unbackticked**, `§Placeholder authoring rules` (**no space**) | target is `## Placeholder authoring rules` at `CONTRIBUTING.md:114` — an **h2**. The guard's hardcoded `### ` returns **0 even for a correctly normalized citation** (**S14**) | **YES** |
| — | `scripts/canonicalize-scan.sh` ×5 | backticked, correct | **already repaired this cycle** — resolves to exactly 1 heading | **YES** |

**Out of scope (Class B, frozen):** `CHANGELOG.md:335`, `tests/fixtures/canonicalization/*.md` (×6),
`docs/spec.md:826`, `.github/workflows/release-assets.yml:4` — none of these ship
(`export-ignore`d), and all are historical or fixture-header records.

**Ambiguous — must be settled first (S12):** `docs/architecture.md` **does ship** and carries
several `CONTRIBUTING.md §` references in a third variant form (`:2069`, `:2070`, `:10847`,
`:11058`). **ADR-088 §Decision (3)** rules these Class B and **frozen**. **ADR-090** mints a
repo-wide anchored-citation convention that says otherwise. ADR-090 is **ACCEPTED**; ADR-088 is
**PROPOSED**; nothing in this diff reconciles them. **Resolve that conflict before writing the
v2.19.13 AC**, or the cycle will freeze exactly what its own ADR requires anchored.

**And S13, which reframes the whole item:** `CONTRIBUTING.md` is `export-ignore`d. `git archive
bbb2853` contains **0** entries for it, while all four citing files **do** ship. So the five
citations this cycle just repaired are *still* unresolvable for every user — the repair fixed the
maintainer surface, not the user surface. Fixing the three broken ones without addressing this
leaves users pointed at a file they do not have. That is a decision for the next cycle's `/spec`,
not a defect in this one.

---

## §7. Adjudication of @qa's two INFO findings

### 7.1 Design §H.4 RED-d goes RED for the wrong reason — **UPHELD**

Independently reproduced, not accepted on narrative:

```
$ sed 's/^- \*\*The F4 bundle/- **The F4X bundle/' CHANGELOG.md > ch-end-renamed.md
$ awk '/^- \*\*The wizard.s setup-complete closing message rewritten/,/^- \*\*The F4 bundle/' ch-end-renamed.md | grep -c .
886
$ grep -n "all three" CHANGELOG.md
110: … on all three of its …
256: … explicitly naming all three: `self-apply`, `self-archive`, `self-upgrade` …
```

The design's transcript claims *"bullet extraction returned 0 lines"*. It returns **886 non-empty
lines** — the `awk` range runs unterminated to EOF, and the RED arrives from leg 2 (`N_ALLTHREE`
matching `:110` and `:256`), never from the vacuity guard. Renaming the **start** anchor, not the
end anchor, is what reproduces the documented 0-line transcript. @qa is correct.

**Disposition: CARRY-FORWARD, not a pre-merge blocker.** Three grounds, in order of weight:

1. **It ships no executable control.** Design §H.5 is explicit that AC-10 is Phase-4/5-only. A wrong
   transcript in a doc cannot produce a wrong runtime outcome.
2. **The correction costs a re-push on a Tier A branch**, which re-runs the entire CI surface —
   including the two brand-new inline steps whose GREEN at `bbb2853` is the evidence this audit
   rests on. Re-running a verified-green surface to correct a doc transcript is a non-zero risk
   taken against a zero-risk defect.
3. **`docs/design-v2.19.11.md` is cycle-scoped** and superseded at close, unlike ADR-088's Status
   field, whose falsified-claim precedent might otherwise seem to apply.

**But it must not be lost.** The vacuity guard is precisely the class of control this cycle exists
to make trustworthy, and §H.5 instructs a future @qa to *"re-derive it from this document."* A
re-deriver would rename the end anchor, see RED, and conclude the vacuity guard fired when it did
not — the same shape as S1. **Carry as `CF-v2.19.11-B`**, with the exact correction: *split RED-d
into (i) start-anchor renamed → vacuity guard fires, 0 lines; (ii) end-anchor renamed → range runs
to EOF, caught incidentally by `N_ALLTHREE`.* **If the branch is re-pushed for any other reason,
this correction rides along.**

### 7.2 AC-1's credential-leak assertion only fires against a synthetic fixture — **UPHELD, with one correction**

@qa is right that the RED direction never fires against a real git failure. But the report leaves
the reader with the wrong inference — that the assertion tests nothing real. It does. **The reason
no real git failure leaks userinfo is a property of *git*, not of this code.** The code is a pure
passthrough. Demonstrated with a stub `git` that emits what real git does not:

```
::error::release-surface: 'git ls-remote --tags origin' failed (exit 128) —
  … Failing closed. Raw git error:
    fatal: unable to access 'https://ghp_FAKE0000TOKEN@github.com/o/r.git/': Could not resolve host: github.com
TOP-LEVEL EXIT=2
```

The assertion is legitimate defense-in-depth against a *future* git whose error text changes.
**Non-blocking.** Recommend one clause in the design's Leg-2 note: *"the GREEN direction holds
because git omits userinfo, not because this code redacts it — the code is a passthrough by
design (see §Do NOT add a `sed` redactor)."* Carry with `CF-v2.19.11-B`.

**This same run is the AC-1 positive control.** It confirms three shipped claims at once:
`rc=$?` **is** reachable inside `$( )` (so the `inherit_errexit` comment at `:136-141` is accurate);
the failure is **diagnosed**, not opaque; and the exit is **2** (fail-closed), not 128 and not 1.

---

## §8. ADR / placement confirmations

| Confirmation | Evidence |
|---|---|
| **ADR-088 is still `PROPOSED`** | `docs/architecture.md:14105` — *"**PROPOSED (deferred at v2.19.10 Phase 1.3 — number reserved for the S4 retrofit cycle).**"* Index row `:111` agrees. The v2.19.10 deferral record at `:14221-14238` is intact and untouched by this diff. **Not flipped.** |
| ADR-089 / ADR-090 | Both `ACCEPTED (v2.19.11)` — correct, both are implemented and executing in CI at HEAD. |
| **No file moved** | `git diff --name-status -M -C b7b8447..bbb2853` produces **no `R` or `C` entry**. |
| **No `docs/` root report added** | The only new `docs/` root file is `docs/design-v2.19.11.md`, matching 5 existing siblings (`design-v2.19.6` … `design-v2.19.10`). Both reports this cycle went to `docs/internal/{qa,security}/`. |
| Archive leak count did not grow | `git archive bbb2853 \| grep -cE '^docs/(qa-report\|security-audit\|security-review)-'` → **14**, unchanged. `docs/internal/` → **0**. |

---

## §9. Verdict

**PASS WITH WARNINGS. CRITICAL: 0. BLOCKER: 0.**

The Phase 2 BLOCKER is closed and I confirmed it by executing the shipped code against six failure
directions **and** by sabotaging the fix to prove its own load-bearing half. Both new controls are
non-vacuous, both fire, and both are green in production CI at the exact SHA proposed for merge.
The six WARNINGs are follow-up scope, not merge impediments: one is an owner-accepted deferral with
a live risk row (S5), two are pre-existing conditions this cycle merely made visible (S11, S13), and
three are inputs the next cycle needs in order not to under-scope itself (S12, S14, S15).

**Recommended follow-up bundle — one cycle, not four:** `CF-v2.19.11-A` (3 citations) + **S5** +
**S11** + **S14** + **S15**, plus `CF-v2.19.11-B` (the two doc corrections from §7). **S12 must be
resolved first**, because it determines what `CF-v2.19.11-A`'s AC is even allowed to say.

---

## Guard Change Summary

*This section is written for the owner. It is the thing you decide on. You should not need to read
a single line of code to make the call.*

✅ **MERGE — 0 permissions changed, 0 files moved, 31/31 CI checks green at the exact commit being merged. Two things ship knowingly unfixed; neither can hide a problem from you.**

| Fact | Status |
|---|---|
| Permissions / scope | ✅ **0 changed** — no new access, no new secret, no new outside service. Verified in the diff and in both affected CI jobs. |
| CI | ✅ **31/31 pass, 0 fail** at `bbb2853`, the exact commit you are merging. Both new checks ran and passed in that run. |
| Can it block you? | ⚠️ **Yes — and that is the point.** Two new checks can stop a future change from merging. Neither can stop *you* doing anything today, and neither touches anyone's files. |
| Known problems shipping unfixed | ⚠️ **2 named** — the `pull-updates` gap (S5, your own decision at the gate) and 3 broken doc references (`CF-v2.19.11-A`). Both have a written record and a named next cycle. |
| Forward-only caveats | ⚠️ **2** — the new checks only guard *future* changes; they do not repair anything already shipped, and they cover 2 of 30 registry rows, on purpose. |
| What we could not prove | ⚠️ **2** — see the last line of this summary. |

**What you're approving:** two new automatic checks that refuse to let a future edit quietly damage
the two most safety-critical rows of the skills list, or quietly break a reference the kit relies
on — plus a repair to a release-check script that used to fail with no explanation at all.

**What you're accepting:**
1. A gap in `pull-updates` ships unfixed — *your decision at the gate.* *(Unlikely to be hit. Medium harm if it were. **The one worth your attention.**)*
2. Three broken references ship to users today. *(Certain — they are broken now. Low harm.)*
3. Those references, and the five just fixed, point at a file users never receive. *(Certain. Low harm.)*
4. A cosmetic way to write noise into the build log. *(Unlikely. Low harm — cannot hide a failure.)*

---

### What changed

Three things now behave differently. **First**, two automatic checks were added to the build. One
refuses any change that structurally damages the `self-apply` or `prompt-gate` rows of the skills
list — the rows that record the fingerprints used to verify safety skills are genuine. The other
refuses any change that breaks the link between a script and the contributor rule it says it
follows. **Second**, the descriptions of those two skills were rewritten in plainer, and more
accurate, language — `self-apply` no longer promises something it cannot deliver, and now names the
one situation where the protection does not apply. **Third**, a release-check script that used to
die silently when it could not reach GitHub now says exactly what went wrong and stops — instead of
carrying on and reporting "tags are missing" when the truth was "we could not look."

### What could break

**1. The `pull-updates` gap ships unfixed. *(Unlikely to be reached. Medium harm if reached. This
is the one worth your attention.)*** The instructions for the updater say what to do if the install
record is damaged, but say nothing about what to do if a row in the skills list is damaged — and
that row is where it reads the fingerprint it verifies against. Undefined is not the same as safe.
**You chose to defer this at the gate and bundle it with the reference repairs**, because both need
the same file edited and bundling means one review instead of two. That decision is recorded as
risk `v2.19.11-PULL-ROW-1`. What makes it acceptable is item 1 under *What's protected* below.

**2. Three references ship broken to users today. *(Certain — they are broken right now. Low
harm.)*** Three files that go into every user's workspace point at a section of the contributor
guide using a name that no longer matches any heading. Nothing stops working; a reader who follows
the pointer finds nothing. This cycle deliberately fixed only the five references inside the script
the new check guards; the other three are `CF-v2.19.11-A`. **My Phase 2 note said one file. It is
three.** The third is written differently again and points at a different kind of heading, which
means the new check cannot simply be pointed at it — it would report a failure on a *correctly*
written reference. Anyone planning that repair from my earlier note would have under-scoped it by
two files and hit that surprise. That correction is the main reason this paragraph exists.

**3. All of those references — including the five just fixed — point at a file users never
receive. *(Certain. Low harm.)*** `CONTRIBUTING.md` is deliberately excluded from the release
download. I confirmed it: the release archive contains zero copies of it, while all four files that
cite it are included. So this cycle improved the reference for maintainers, not for users. Fixing
the remaining three without deciding what users should be pointed at instead would just create
three more dead ends. That is a question for the next cycle, not a defect in this one.

**4. A cosmetic way to write noise into the build log. *(Unlikely. Low harm.)*** The new reference
check reads a name out of a file and prints it. Someone who could already edit two tracked files in
a pull request could choose a name that prints odd-looking text into the build log. I tested
whether that could run commands: **it cannot** — I tried, and nothing executed. It also cannot make
a failing build look like a passing one, because pass/fail is decided by exit codes, not by log
text. It is untidy, not dangerous, and the fix is one line in a follow-up.

**5. Sibling inconsistency. *(Certain. Low harm.)*** `self-apply`'s description is now precise
while its two sibling safety skills still carry the older, looser wording. Nothing breaks; a reader
comparing the three sees three different promises. Folded into the same follow-up bundle.

### What's protected

**1. The poisoned-backfill defense — and this is load-bearing.** When the updater installs a
missing safety skill, it checks the bytes against a fingerprint stored in the skills list. If
someone could damage that row, the fingerprint would no longer be where the updater looks, and the
check could silently become meaningless. **The new row check makes that damage impossible to merge
into this repository.** I verified it refuses eight different kinds of damage — a stray `|`
character in either description, a deleted row, a duplicated row, a wrong-case fingerprint, a
missing file — and correctly *allows* a harmless whitespace tidy-up, so it will not cry wolf.
**This is the specific control that makes deferring item 1 acceptable.** If it is ever removed or
loosened, that acceptance is void and must be re-decided. That condition is written into the risk
record itself, so a future reader cannot miss it.

**2. The check cannot pass by accident.** I sabotaged it on purpose — fed it a setup where its own
self-test would have been meaningless — and it detected that and failed, with an error telling the
next person to repair the test rather than weaken it. A check that stays green when it has stopped
checking anything is the failure mode that started this cycle. This one does not have it.

**3. The reference check cannot report success when it cannot do its job.** This was the blocking
problem I raised at Phase 2: the original version printed `PASSED` when the file it needed was
missing — the exact situation it existed to catch. That is fixed. I confirmed it against six
different ways of breaking it, including the awkward one (pointing it at a folder instead of a
file). I also rebuilt the broken version and confirmed it still prints `PASSED` on that input — so
the fix is doing real work, not decoration.

**4. Nothing about who can do what changed.** No new permission, no new password or key, no new
outside service, no new third-party code. No file was moved or renamed. The proposed change to move
14 internal reports out of the public download is still marked *proposed*, not done — I checked,
and this cycle did not quietly flip it.

**5. The public download did not get leakier.** 14 internal reports were already included in it
before this cycle. Still exactly 14 — this cycle's own two reports were correctly filed in the
internal folder, which is excluded.

### What to verify after merge

Concrete signals, in documents you already read. **The absence of any of these is the alarm.**

1. **Next time anyone edits the skills list, the build tells them exactly what they broke.** The
   check prints `AC-8b/AC-9b PASSED - gated slugs verified: self-apply prompt-gate.` when all is
   well. If a future change damages a row, the failure message names the row and says *"Repair the
   ROW; do NOT widen NF and do NOT relax the hex shape."* **If you ever see that message followed by
   someone loosening the check instead of fixing the row, that is the moment to intervene** — that
   is the exact failure this cycle was written to prevent.

2. **The next cycle's spec names three files, not one.** `CF-v2.19.11-A` covers
   `skills/self-apply/SKILL.md`, `PROMOTE.md`, **and** `templates/skill-template/SKILL.md`. If a
   future spec says "the one remaining citation," it was scoped from my outdated Phase 2 note and
   will silently leave two files broken.

3. **The next cycle's spec settles the `docs/architecture.md` question before writing its
   acceptance criteria.** Two decisions in this repo currently disagree about whether references in
   that file should be repaired or frozen. If the next spec picks one without saying it noticed the
   other, it will get it wrong in a way that is expensive to unwind.

4. **The risk record stays open until it is genuinely closed.** Risk `v2.19.11-PULL-ROW-1` says it
   closes only when `pull-updates` carries an explicit refusal clause **and** that clause has been
   tested by something that actually fails. **If you see it closed on the strength of the new build
   check alone, push back** — the build check protects this repository, not a copy that already
   sits in a user's workspace.

5. **The release download still contains no internal reports.** It should stay at zero
   `docs/internal/` entries. The 14 already-public reports should stay at 14 and not grow — the next
   cycle to add one without filing it internally is the one to catch.

**What we could not prove:** two things, named plainly. **First**, whether GitHub's build system
interprets the odd-looking text from item 4 as a real instruction rather than plain text. That is
documented behaviour, but I did not test it on a live build, so treat it as a suspicion rather than
a fact. It does not change the conclusion — even in the worst case it cannot turn a failing build
into a passing one. **Second**, whether the `pull-updates` gap in item 1 would actually cause a
refusal or a silent skip in practice. It is undefined in the instructions, which is why it is on the
risk register, and "undefined" is exactly the thing that cannot be tested — only specified. That is
the work the follow-up cycle owes.
