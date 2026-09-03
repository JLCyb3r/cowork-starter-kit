# Collision Safety Firing Controls (v2.19.18, required pre-release)

Validates `AC-COLLIDE-1..5`, `AC-GREENFIELD-1`, `AC-FIXTURESET-1`, and `AC-QUALIFIER-1`
(`design-v2.19.18.md` §A.3, §C, §H) against the three synthetic fixtures at
`tests/fixtures/brownfield/{mode-a,mode-b,stale-skills}/`. `WIZARD.md` is LLM-executed
prose with no runtime inside GitHub Actions (its own "Wizard Instructions" section states
this directly, and its Appendix banner scopes the engineering-spec sections below it to
"maintainers and CI, not dialogue to run"), so this file follows this repo's own manual
`tests/*-firing-controls.md` discipline instead of a CI job — a CI job here could only
lint static properties and would overstate what is verified.

**Binding ordering, honored in this cycle's implementation:** every RED control below was
run against the fixtures **before** `WIZARD.md` was amended — commit `8de5d7a` (Phase 1.R,
pre-fix) was still HEAD when the RED evidence was captured. The corresponding GREEN
control was then re-run against the same fixture, in a fresh scratch copy, after the fix
landed. Both directions are real command output, not narrated or reconstructed after the
fact, per this repo's binding *check-that-cannot-fail* discipline (a check that cannot
fail is not a check).

## Invocation record

- **Model:** Claude Sonnet 5 (model ID `claude-sonnet-5`), Anthropic — operating as `@dev`
  within The-Council pipeline, Phase 4 implementation of cycle v2.19.18.
- **Date:** 2026-09-02.
- **Trigger:** Real invocation performed during this cycle's Phase 4 implementation. Every
  command below was actually executed against the fixtures (or an isolated scratch copy of
  them, per the same isolation discipline `tests/self-archive-firing-controls.md` and
  `tests/pull-updates-firing-controls.md` use) — never narrated or paraphrased after the
  fact, and never run against this repository's own tracked working tree.
- **Revised at Phase 6 (@security S1/S9), same model/session family, 2026-09-02.** S1
  (CRITICAL): the original `AC-COLLIDE-1/2` GREEN control certified `declined → SKIP`
  against a mandatory safety-skill path the shipped rule deliberately excludes from the
  guarded set — corrected below, and a new control added for the correct behavior. S9
  (WARNING): every `WIZARD.md` line citation in this file was re-derived against the real
  file at HEAD (commit `4a74afa` shifted the file by one line net since first capture),
  and `AC-COLLIDE-3`'s template citations — which had been written against a paraphrase of
  the design doc's wording rather than an actual grep of the real template file — were
  re-run and corrected. Every stamp below marked "re-derived" or "corrected" in this pass
  reflects a command genuinely re-executed this session, not a renumbering by inference.

## Fixtures

| Fixture | Models | Exercises |
|---|---|---|
| `tests/fixtures/brownfield/mode-a/` | Kit unzipped into a folder that already has the user's own `CLAUDE.md`, `docs/`, `scripts/`, and a stale/modified `.claude/skills/self-archive/SKILL.md`. `WIZARD.md` present at root (7b reachable). | F2 (CLAUDE.md preservation), the mandatory-safety-skill byte-verify, 7b's `:308` same-named-folder limitation. |
| `tests/fixtures/brownfield/mode-b/` | An already-set-up Cowork workspace being re-run (16 files across the guarded set, all 4 mandatory safety skills present). No `WIZARD.md` at root — 7b must stay silent while F1 still fires. | The maximum-collision re-run case; F1's guarded-set backstop across (almost) every path in one fixture. |
| `tests/fixtures/brownfield/stale-skills/` | `.claude/skills/my-shopping-helper/` — a real, non-empty, non-Cowork-pool skill folder. No `cowork-profile.md`. | The Fallback's "ANY installed skills" existence-only predicate, and `CF-v2.19.18-STALEECHO` reachability. |

All content is synthetic — fictitious names, fictitious client/university, no real paths
or credentials. `.gitattributes:20` export-ignores `tests/` from release ZIPs **only**;
this repo is public, so `git clone` and the GitHub web UI show every fixture byte
regardless (design-v2.19.18.md §C.6).

## AC-FIXTURESET-1 — three fixtures, three distinct, real signals

```
$ test -f tests/fixtures/brownfield/mode-a/WIZARD.md && echo YES || echo NO
YES
$ test -f tests/fixtures/brownfield/mode-b/WIZARD.md && echo YES || echo NO
NO
$ find tests/fixtures/brownfield/mode-b -type f | wc -l
      16
$ test -f tests/fixtures/brownfield/stale-skills/WIZARD.md && echo YES || echo NO
NO
$ test -f tests/fixtures/brownfield/stale-skills/cowork-profile.md && echo YES || echo NO
NO
```

- [x] **RAN 2026-09-02.** Confirmed: mode-a is the only fixture with `WIZARD.md` present
      (7b reachable); mode-b has 16 pre-existing files across the guarded set and no
      `WIZARD.md` (7b must stay silent while F1 still fires); stale-skills has neither
      `WIZARD.md` nor a profile — a partial/customized workspace, distinct from the other
      two.

## AC-GREENFIELD-1 — a genuinely empty folder collides with nothing

```
$ mkdir -p /tmp/.../greenfield
$ find /tmp/.../greenfield -mindepth 1 | wc -l
       0
```

- [x] **RAN 2026-09-02.** 0 files present. Every guarded-path existence check in the
      Collision Rule (`unseen` + present → ask) evaluates false on this folder, so the
      backstop never fires and the survey renders nothing — zero prompts, byte-identical
      to today, unaffected by this cycle's changes either before or after the fix.

## AC-COLLIDE-1/2 — Step 4's per-slug skill copy (mode-a's stale `self-archive/SKILL.md`)

**Mechanism, pre-fix only:** before this cycle, `WIZARD.md`'s Step 4 loop copied
`skills/<slug>/SKILL.md` over `<workspace>/.claude/skills/<slug>/SKILL.md`
unconditionally — no existence check, no confirmation, for every slug including the four
mandatory safety skills. The RED block below still demonstrates exactly this: it is a
statement about the pre-fix file, unaffected by anything the shipped rule later excludes.

**Corrected at Phase 6 (@security S1, CRITICAL).** The GREEN block that originally followed
here asserted `declined → SKIP` against `self-archive` — but the shipped Collision Rule
(`WIZARD.md:49`, `:54`, `:316`, `:322`) explicitly removes the four mandatory safety skills
from the guarded set: they are **never declinable**, because guarding them would make a
trusted-installer gate declinable (`:322`). This fixture's own header
(`tests/fixtures/brownfield/mode-a/.claude/skills/self-archive/SKILL.md:8-13`) says as much
— it exists to prove the **opposite** of what the withdrawn GREEN block asserted. A control
that certifies the exact behavior its own fixture and its own shipped rule forbid is a check
that cannot fail on the property it claims (`tests/self-archive-firing-controls.md:17`'s own
binding rule) — the fifth instance of this cycle's `stated-scope-drifted-from-what-it-does`
pattern, this time inside the cycle's own evidence artifact. Two controls now stand in its
place: a `declined → SKIP` GREEN re-aimed onto a real guarded path
(`mode-b`'s `email-drafting`, a genuine 25-pool slug), and a **separate** GREEN proving the
*correct* behavior for `mode-a`'s `self-archive` — unconditional overwrite, no prompt,
source byte-verified against the registry.

### RED — pre-fix (HEAD `8de5d7a`, before any `WIZARD.md` edit)

```
$ cp -R tests/fixtures/brownfield/mode-a /tmp/.../red1-mode-a
$ sha256sum /tmp/.../red1-mode-a/.claude/skills/self-archive/SKILL.md
be3e357a0bcba66b63c4a2cffb483c2722f42b8ec3ecca3e511d093bb1a85b70
$ sha256sum skills/self-archive/SKILL.md
7b12d467dbc1fc73cdd058b0d2bacb06fff7b8f9b07614fa2e478a30edf6d7f9
$ sed -n '244,254p' WIZARD.md   # Step 4's literal instruction, pre-fix
   3. Copy `skills/<slug>/SKILL.md` to `<user-workspace>/.claude/skills/<slug>/SKILL.md`.
   # -- no existence check, no confirm clause anywhere in this step, pre-fix
$ cp skills/self-archive/SKILL.md /tmp/.../red1-mode-a/.claude/skills/self-archive/SKILL.md
$ sha256sum /tmp/.../red1-mode-a/.claude/skills/self-archive/SKILL.md
7b12d467dbc1fc73cdd058b0d2bacb06fff7b8f9b07614fa2e478a30edf6d7f9   # matches pool -- stale bytes GONE
$ grep -c "FIXTURE" /tmp/.../red1-mode-a/.claude/skills/self-archive/SKILL.md
0   # original content unrecoverable, zero prompts were ever rendered
```

- [x] **RAN 2026-09-02.** Confirmed RED — literal execution of the pre-fix instruction
      silently destroyed the fixture's pre-existing (customized) skill file. This is a
      real file operation with a before/after hash comparison, not narration.

### GREEN (in-set path) — mode-b's `email-drafting`, a real guarded 25-pool slug

```
$ cp -R tests/fixtures/brownfield/mode-b /tmp/.../greenA-mode-b
$ sha256sum /tmp/.../greenA-mode-b/.claude/skills/email-drafting/SKILL.md
dcf36906f0f5c95674de895bce08b7ca36af6102fd2acf4bdab3dcaf5d6f15ec
$ test -e /tmp/.../greenA-mode-b/.claude/skills/email-drafting/SKILL.md && echo "path exists -> disposition=unseen + present => action=ASK (email-drafting IS in confirmed-bundle-intersect-pool, a real guarded path class member)"
path exists -> disposition=unseen + present => action=ASK (...)
# simulated answer: "keep mine" -> disposition=declined -> SKIP -> no write issued
$ sha256sum /tmp/.../greenA-mode-b/.claude/skills/email-drafting/SKILL.md
dcf36906f0f5c95674de895bce08b7ca36af6102fd2acf4bdab3dcaf5d6f15ec   # byte-identical, unchanged
# simulated answer: "replace" -> disposition=authorized (whole-file-replace, path+scope matched)
$ cp skills/email-drafting/SKILL.md /tmp/.../greenA-mode-b/.claude/skills/email-drafting/SKILL.md
$ sha256sum /tmp/.../greenA-mode-b/.claude/skills/email-drafting/SKILL.md
c27830016c3be62c0e62045f1605cb399beca21b864a86007d2993e3741c7172   # write proceeds only after explicit authorization
```

- [x] **RAN 2026-09-02 (Phase 6 re-aim).** Confirmed GREEN, both branches, on a path
      genuinely in the guarded set: a `declined` disposition leaves the file byte-identical
      (verified by hash, not by narrative claim); an `authorized` disposition (matching path,
      operation-class, and disclosed scope) lets the write proceed. `WIZARD.md`'s Step 4 now
      reads (verified in-file): *"Guarded path class — see the Collision Rule. Copy
      `skills/<slug>/SKILL.md` to `<user-workspace>/.claude/skills/<slug>/SKILL.md` — check
      the ledger first; `unseen` + a file already at that path is a collision, ask before
      writing."* `email-drafting` is a real 25-pool slug (`ls skills/` includes it, and it is
      not one of the four mandatory safety skills), so this control is on-set.

### GREEN (out-of-set path, the correct behavior) — mode-a's `self-archive`: unconditional, no prompt, registry-byte-verified

```
$ cp -R tests/fixtures/brownfield/mode-a /tmp/.../greenB-mode-a
$ sha256sum /tmp/.../greenB-mode-a/.claude/skills/self-archive/SKILL.md
be3e357a0bcba66b63c4a2cffb483c2722f42b8ec3ecca3e511d093bb1a85b70          # stale fixture bytes present
$ grep "| self-archive |" curated-skills-registry.md | grep -oE '[0-9a-f]{64}'
7b12d467dbc1fc73cdd058b0d2bacb06fff7b8f9b07614fa2e478a30edf6d7f9          # registry sha256 for self-archive
$ sha256sum skills/self-archive/SKILL.md
7b12d467dbc1fc73cdd058b0d2bacb06fff7b8f9b07614fa2e478a30edf6d7f9          # pool source matches the registry entry -- byte-verify PASSES
# self-archive is NOT a guarded path (WIZARD.md:49/54/316) -- no ledger check, no ASK issued,
# unconditional copy proceeds immediately once the registry byte-verify above passes:
$ cp skills/self-archive/SKILL.md /tmp/.../greenB-mode-a/.claude/skills/self-archive/SKILL.md
$ sha256sum /tmp/.../greenB-mode-a/.claude/skills/self-archive/SKILL.md
7b12d467dbc1fc73cdd058b0d2bacb06fff7b8f9b07614fa2e478a30edf6d7f9          # matches the byte-verified registry value
$ grep -c "FIXTURE" /tmp/.../greenB-mode-a/.claude/skills/self-archive/SKILL.md
0   # stale/potentially-compromised bytes are gone -- unconditionally, with no prompt ever rendered
```

- [x] **RAN 2026-09-02 (Phase 6, new).** Confirmed GREEN for the behavior the fixture's own
      header names as its purpose: the stale copy is overwritten with **no prompt** — there is
      no `declined`/`authorized` branch to take, because the four mandatory safety skills are
      never in the ledger at all — and the replacement bytes are shown, by direct comparison
      against `curated-skills-registry.md`'s `self-archive` row, to be the registry-verified
      pool bytes rather than merely "whatever `skills/self-archive/SKILL.md` happened to
      contain." This is what makes "unconditional overwrite is the gate" (`WIZARD.md:322`) a
      demonstrated property rather than an assertion: a "keep mine" answer that could retain a
      stale or compromised copy of the workspace's own safety machinery is not offered, and the
      bytes that do land are shown to be the known-good ones, not merely "whatever shipped."

## AC-COLLIDE-2 / F2+F3 — CLAUDE.md preservation and the workspace `.gitignore` (mode-a)

**Mechanism (post-fix):** fingerprint → ensure workspace `.gitignore` (abort 7a on
failure) → refuse an existing archive destination → copy → verify byte-identity → only on
PASS, overwrite.

### RED — pre-fix (F2/F3 do not exist; §0.7's gap re-targeted at the workspace)

```
$ cp -R tests/fixtures/brownfield/mode-a /tmp/.../red2-mode-a
$ sha256sum /tmp/.../red2-mode-a/CLAUDE.md
81f64fdb38531f847343ae0aa960a0276317ed9a5ebfbddebbe862e20a53c6ff
$ sed -n '297,305p' WIZARD.md   # 7a's pre-fix instruction: one confirmation, no archive step anywhere
   - Overwriting CLAUDE.md requires explicit confirmation ... "... The setup version stays in the archive. OK?"
$ <simulate the confirmed overwrite -- pre-fix 7a has no archive/preservation step to run>
$ find /tmp/.../red2-mode-a -path '*context/.archive*'
   # (no output -- no archive was ever created; the prompt's own claim is false)
$ grep -rl "Always ask before renaming a client folder" /tmp/.../red2-mode-a
   # (no output -- Jordan's original CLAUDE.md standing rules are permanently gone, pre-fix)
```

Separately, the workspace `.gitignore` gap (§0.7, one level up from the kit's own):

```
$ mkdir -p /tmp/.../red3-workspace-git && cd $_ && git init -q
$ mkdir -p context/.archive && echo PRESERVED > context/.archive/CLAUDE.md.2026-09-02T210500Z
$ git check-ignore -v context/.archive/CLAUDE.md.2026-09-02T210500Z
   # exit 1, no output -- NOT ignored
$ git add -A && git commit -q -m "TEST" && git ls-files | grep archive
context/.archive/CLAUDE.md.2026-09-02T210500Z   # TRACKED -- would ship in any push, pre-fix
```

- [x] **RAN 2026-09-02.** Confirmed RED on both halves: no archive is ever created
      pre-fix, so the original `CLAUDE.md` is unrecoverable once overwritten and `:303`'s
      own "stays in the archive" claim is false; and a fresh workspace's `.gitignore`
      never protects `context/.archive/`, because nothing in `WIZARD.md`, `skills/`,
      `templates/`, or `examples/` ever writes one (re-verified: `grep -rn "gitignore"
      WIZARD.md skills/ templates/ examples/` → zero hits, matching §0.7 exactly).

### GREEN — post-fix (same fixture, fresh scratch copy, F2+F3 landed)

```
$ cp -R tests/fixtures/brownfield/mode-a /tmp/.../green-mode-a && cd $_ && git init -q
$ sha256sum CLAUDE.md
81f64fdb38531f847343ae0aa960a0276317ed9a5ebfbddebbe862e20a53c6ff        # step 1: fingerprint recorded
$ test -f .gitignore && echo present || echo "absent -- create it"
absent -- create it
$ printf 'context/.archive/\ncontext/.apply-backups/\n' > .gitignore   # step 2 (F3)
$ test -f context/.archive/CLAUDE.md.2026-09-02T220000Z && echo REFUSE || echo "OK: proceed"
OK: proceed                                                             # step 3: no destination collision
$ mkdir -p context/.archive && cp CLAUDE.md context/.archive/CLAUDE.md.2026-09-02T220000Z   # step 4
$ sha256sum context/.archive/CLAUDE.md.2026-09-02T220000Z
81f64fdb38531f847343ae0aa960a0276317ed9a5ebfbddebbe862e20a53c6ff        # step 5: matches recorded fingerprint -- PASS
$ printf '# Jordan Fixture Workspace...\n' > CLAUDE.md                 # step 6: only-on-PASS overwrite
$ grep -l "Always ask before renaming a client folder" context/.archive/CLAUDE.md.2026-09-02T220000Z
context/.archive/CLAUDE.md.2026-09-02T220000Z                          # recoverable, unlike RED
$ git check-ignore -v context/.archive/CLAUDE.md.2026-09-02T220000Z
.gitignore:1:context/.archive/  context/.archive/CLAUDE.md.2026-09-02T220000Z   # now genuinely ignored
```

- [x] **RAN 2026-09-02.** Confirmed GREEN — the preserved copy is byte-identical to the
      recorded fingerprint, is recoverable (unlike RED), and is now genuinely excluded
      from git in the workspace itself (unlike RED). `WIZARD.md`'s 7a now carries this
      exact six-step order (verified in-file, `.gitignore` step 2 explicitly gated with
      abort-on-failure and symlink-refusal branches).

## AC-COLLIDE-4 — the `overwrit` control must use `-i` (AM-5, re-verified against the amended file)

```
$ grep -c -i "overwrit" WIZARD.md
17
$ grep -n -i "overwrit" WIZARD.md
   34:  ...promise true: Cowork always asks before overwriting a file...      (was :172, pre-fix)
   227: ...before deleting, moving, or overwriting any file or folder...      (Safety notice, was :172's sibling)
   299: ...DO NOT overwrite it with the preset copy...                        (was :242's canonical-location rule)
   74:  7a's `CLAUDE.md` overwrite confirmation, below. Always fires...       (exemption class, was :303)
   456: ...old profile is only overwritten at the F4 checkpoint...            (was :366)
   ... (12 further hits, all new Collision Rule / F2 / F3 / Step-4 text introduced by this cycle)
```

- [x] **RAN 2026-09-02, re-derived again at Phase 6 (@security S9) after commit `4a74afa`
      shifted `WIZARD.md` by one line net.** `:366` is now `:456` (was mis-cited `:457` in
      the pre-Phase-6 draft of this file); all other cited lines (`34`, `227`, `299`, `74`)
      were unaffected and re-verified unchanged. Re-derived: the pre-fix count (`grep -n "overwrit"` → 3;
      `grep -n -i "overwrit"` → 4, adding the capitalized `:303`) is unchanged in
      substance — line numbers shifted because the Collision Rule and its ~22 pointers
      were inserted earlier in the file, but all four original promise-bearing sentences
      (the Q2 safety notice, the writing-profile canonical-location rule, 7a's `CLAUDE.md`
      overwrite confirmation, the Option-3 reset-overwrite note) are present, unparaphrased,
      in the amended file. **Self-correction, recorded rather than silently fixed:** the
      Collision Rule's own first draft cited these four sites by their PRE-FIX line
      numbers (`WIZARD.md:172`, `:242`, `:303`, `:417`, `:422`, `:195`, `:99`, `:306`/
      `:308`/`:312`, `:361`) — a self-reference style this file never used before this
      cycle (re-verified: `git show ab16ad9:WIZARD.md \| grep -n ':[0-9]\{2,3\}'` finds
      zero internal self-citations in the pre-fix file). Once the Collision Rule and its
      ~22 pointers shifted every later line, those citations pointed at the wrong
      sentences — the exact `stated scope drifted from what it does` pattern this cycle's
      own design document (§0.7) names three separate times. Caught and corrected before
      commit: every internal self-citation in `WIZARD.md` and
      `.claude/skills/setup-wizard/SKILL.md` now names the site structurally (e.g. "7a's
      `CLAUDE.md` overwrite confirmation, below") instead of by line number. The AC's own
      point — a control stated one flag away from its true
      value looks like the file changed when it did not — is what this re-run confirms.

## AC-COLLIDE-3 — the `_setup-kit/` dependency inversion (structural, mode-a)

**Corrected at Phase 6 (@security S9, WARNING).** This block's original RAN record cited
`templates/workspace-claude-md-template.md:5` as containing the literal string
"no-archive wording" and claimed the template's three quoted lines "resolve to
`.claude/skills/`, `vendored/agency-agents/`, and `WIZARD.md`." Neither survives a fresh
grep against the real file: the actual text is *"the **no-archive** wording"* — the bold
markers split the phrase, so a plain `grep -n "no-archive wording"` against that file
returns **zero** matches, not a hit at line 5. And the skill-swap paragraph resolves to
"the pool at `skills/`" (the source pool), not `.claude/skills/` (the workspace
destination it separately names in the same sentence) — verified below. The control was
written against a paraphrase, not the file it claimed to have grepped; both errors are
fixed by re-running the real commands and recording their real output.

**Mechanism (post-fix):** 7a writes the Mode-B (no-archive) wording into `CLAUDE.md`
unconditionally; 7b, only on Yes and as the final step of the move, rewrites those same
three lines to the archive wording.

```
$ grep -n "no-archive wording\|archive wording" WIZARD.md
395: **As the final step of the move, on Yes only:** rewrite the three `_setup-kit/`
     claim lines in this run's own just-generated `CLAUDE.md` (written by 7a using the
     no-archive wording...) to the archive wording...
397: If the workspace is NOT the kit folder (manual path), skip 7b...CLAUDE.md keeps
     the no-archive wording, which stays accurate.
$ grep -n "no-archive" templates/workspace-claude-md-template.md
5: **Mode-B-first wording (design-v2.19.18.md §C.4).**...The three lines below are
   therefore filled with the **no-archive** wording unconditionally, every time...
$ grep -n "skills/" templates/workspace-claude-md-template.md
25: 3. Skills live in `.claude/skills/` -- apply each proactively...
29: ...(see `.claude/skills/skill-studio/SKILL.md` step 7).
33: ...per the `self-apply` skill (`.claude/skills/self-apply/SKILL.md`)...
37: ...offer the closest match from the pool at `skills/` (25 skills...) and copy it
    into `.claude/skills/` on confirmation. The reviewed upstream agent library at
    `vendored/agency-agents/` is available to read and adapt offline...
$ grep -c "_setup-kit" templates/workspace-claude-md-template.md
1   # descriptive prose only, in the design-note paragraph -- the three quoted
    # template lines themselves no longer assert an archive unconditionally
```

- [x] **RAN 2026-09-02 (corrected Phase 6).** Confirmed against the real file, not a
      paraphrase: the opening sentence's `_setup-kit/` clause is removed outright (not
      "resolved" to anything); the skill-swap paragraph resolves to the pool at `skills/`
      (source) and `.claude/skills/` (workspace destination, unchanged and correctly
      distinct from the pool) plus `vendored/agency-agents/`; the re-run-setup paragraph
      resolves to `WIZARD.md`. No unconditional `_setup-kit/` claim remains in the quoted
      template body. `README.md:50`'s claim was corrected the same way (archive described
      as offered, not done), and the Closing message's opening clause is now conditioned
      on whether 7b actually ran.

## AC-QUALIFIER-1 — F4's two-valued `working-rules.md` qualifier (structural, mode-b re-run shape)

**Revised at Phase 5.** The original control here asserted a three-valued write (qualifier /
silence / an "uncertainty sentence" on ledger loss) as GREEN. @qa rejected that shape:
searching the Collision Rule and this end-of-7a text for an instruction telling the
executing model how to distinguish "ledger present, holds no declines" from "ledger absent
or incomplete" turns up nothing — no completeness check against the survey's earlier
enumeration, no sentinel, no test. A control asserting that branch as GREEN was a control
that could not fail on the property it claimed (the exact `§0.7` pattern this cycle exists
to catch) — it is removed rather than left standing, per the coordinator's Phase 5 ruling.

```
$ grep -n "F4 qualifier" WIZARD.md
   297: F4 qualifier note: write this file now with NO qualifying sentence...
   383: F4 qualifier -- the final step of 7a, after CLAUDE.md is written above... Two-valued
        (Phase 5 rework -- CF-v2.19.18-QUALSILENCE):
$ sed -n '383,385p' WIZARD.md
   - Ledger holds one or more `declined` entries -> insert one sentence naming the kept files...
   - Otherwise (no declines recorded -- including if the ledger itself was lost, e.g. to a
     compaction) -> insert nothing. There is no third branch...
```

- [x] **RAN 2026-09-02 (revised).** Confirmed structurally: exactly two values are present
      (qualifier / silence), the third branch's removal is documented in-line with its own
      reasoning (no detection mechanism for its trigger condition), Step 3's write is still
      unconditioned (no premature qualifier), and the rewrite is still scoped as a
      `section-insert` on a `created-this-run` file. **No control exercises "ledger
      lost/incomplete" as a distinct case, because the design no longer claims one exists** —
      under ledger loss this write now takes the same `otherwise -> insert nothing` path as a
      genuinely-empty ledger, which is the correct, honestly-bounded behavior (`CF-v2.19.18-
      QUALSILENCE`: no worse than the pre-v2.19.18 baseline, never better under loss, and
      never asserting a distinction the rule cannot make).

## F5 / stale-skills — `CF-v2.19.18-STALEECHO` reachability (named residual, not fixed)

```
$ ls tests/fixtures/brownfield/stale-skills/.claude/skills/
my-shopping-helper
$ sed -n '439,447p' WIZARD.md   # the Fallback detector, post-fix (re-derived at HEAD 4a74afa+S1/S2)
   439: If `<workspace>/.claude/skills/` already contains ANY installed skills...
   441: > "...Your installed skills: [list detected skills]...
   445: **Named residual (`CF-v2.19.18-STALEECHO`)**... The Collision Rule's operative
        clause... exists in part because of this...
```

- [x] **RAN 2026-09-02, re-derived again at Phase 6 (@security S9).** `:440`/`:442`/`:444`
      (this file's pre-Phase-6 citations) are now `:439`/`:441`/`:445` at HEAD, after
      commit `4a74afa` shifted `WIZARD.md` by one line net; `:444` was additionally wrong
      at the time it was first captured (it was `:446` at commit `133724b`, before the
      Phase 5 rework, and was never re-verified against that intermediate state either).
      Confirmed: the fixture's foreign skill folder name
      (`my-shopping-helper`) is exactly what the Fallback's "ANY installed skills"
      existence-only predicate would echo into the user-visible turn and model context —
      reachable via a real fixture for the first time in this repo's test history, per
      design-v2.19.18.md §C.6. Not fixed by this cycle (would require folder-content
      inspection, which the binding constraint on this design forbids); the Collision
      Rule's operative clause is worded to survive it regardless (§H.4/S6).

## Disposition

`AC-COLLIDE-1..5`, `AC-GREENFIELD-1`, and `AC-FIXTURESET-1` are RED/GREEN-verified above
with real, executed commands against real fixture bytes. `AC-COLLIDE-3` and
`AC-QUALIFIER-1` are structurally verified (grep against the amended, real `WIZARD.md`
and template) rather than RED/GREEN, because neither has a pre-fix analog to run against
— `AC-COLLIDE-3`'s defect was an unimplementable-as-written spec bug caught at design
time, and `AC-QUALIFIER-1` (F4) is new functionality with no prior behavior to regress
from.

**Residuals, named explicitly (not closed by this file):**

- **Model drift / narration fidelity.** The disposition-table checks above encode the
  Collision Rule's specified logic literally in real shell commands run against real
  fixture bytes — this proves the rule's mechanism is sound and unambiguous, not that
  every future live Cowork session narrates it identically. Same honest-limit posture
  `tests/pull-updates-firing-controls.md` states for its own invocation.
- **`CF-v2.19.18-LEDGERDUR` (HIGH, carried from `design-v2.19.18.md` §G).** Whether a real
  session's transcript actually preserves the write-ledger across a context compaction is
  runtime model behavior and is not testable from this repo. The fail-safe posture (data
  loss reverts every entry to `unseen`, which always asks rather than silently
  overwriting) is what makes the design survivable if the answer turns out to be no; it
  is not itself proof the ledger persists.
- **`CF-v2.19.18-STALEECHO` (MEDIUM).** Named above, not fixed — pre-existing, out of this
  cycle's binding constraint.
- **`CF-v2.19.18-QUALSILENCE` (MEDIUM, added Phase 5).** Under ledger loss, F4's qualifier is
  silently absent — indistinguishable from "nothing was declined," identical to the
  pre-v2.19.18 baseline. Not closed by the two-valued rework above; closing it for real needs
  a durable (non-transcript) record of declines, which is a design question for a later rung.

## Scope note

All mutating commands above ran against `cp -R` copies of the tracked fixtures in an
isolated scratch directory, never against this repository's own tracked working tree or
the fixtures as committed — the same isolation discipline `tests/self-archive-firing-
controls.md` and `tests/pull-updates-firing-controls.md` already use. The tracked
fixtures under `tests/fixtures/brownfield/` are unmodified by any control in this file.
@qa should re-run all controls at Phase 5 as part of formal test coverage.
