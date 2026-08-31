# vendor-prune.sh Firing Controls (v2.19.16, required pre-release)

Validates `scripts/vendor-prune.sh` against the four controls
`docs/internal/security/security-review-v2.19.16.md` S1 (CRITICAL) makes mandatory: positive,
negative, refusal, and the S1 newline-filename reproduction. Every control below was run for real
(not narrated) during Phase 4 implementation, against a fixture tree under `/tmp` — the real repo
tree was never mutated, per this repo's binding rule that test fixtures live outside the repo. Per
the repo's own *check-that-cannot-fail* discipline (`docs/patterns.md`), a control whose absence is
the alarm is included as its own item (§4b) — S1's own remedy would otherwise never be independently
exercised, since `find "$ROOT" …` is structurally rooted and can never itself produce a path outside
`$ROOT` regardless of whether the prefix check exists.

Run this before any future edit to `scripts/vendor-prune.sh`, and again before the first real sync
PR exercises D1(b)/(c)'s new `sync-agency.yml` steps.

## 1. Positive control — lock and disk agree

**Fixture:** `/tmp/fx-vp1/` — 2 files (`marketing/m1.md`, `engineering/e1.md`) + `LICENSE`, lock lists
both.

```bash
cd /tmp/fx-vp1 && bash /Users/macbookpro/claude-cowork-config/scripts/vendor-prune.sh
# -> vendor-prune: 0 orphan(s) removed.
# -> EXIT=0
ls vendored/agency-agents/marketing/m1.md vendored/agency-agents/engineering/e1.md vendored/agency-agents/LICENSE
# -> all three present
```

- [x] **RAN 2026-08-31.** Exit 0, `0 orphan(s) removed`, all three files (2 vendored + LICENSE)
      confirmed present afterward via `ls`. PASS.

## 2. Negative control — one real orphan

**Fixture:** `/tmp/fx-vp2/` — disk has `marketing/m1.md` and `engineering/e1.md`; lock lists only
`marketing/m1.md`. `engineering/e1.md` is a genuine orphan.

```bash
cd /tmp/fx-vp2 && bash /Users/macbookpro/claude-cowork-config/scripts/vendor-prune.sh
# -> vendor-prune: removed orphan vendored/agency-agents/engineering/e1.md
# -> vendor-prune: 1 orphan(s) removed.
# -> EXIT=0
ls vendored/agency-agents/marketing/m1.md            # -> present
ls vendored/agency-agents/engineering/e1.md           # -> No such file or directory
```

- [x] **RAN 2026-08-31.** Exit 0, exactly 1 orphan removed, the correct file named
      (`engineering/e1.md`), `marketing/m1.md` confirmed still present. PASS.

## 3. Refusal control — empty lock

**Fixture:** `/tmp/fx-vp3/` — disk has 1 file; lock is `{"files":[]}`.

```bash
cd /tmp/fx-vp3 && bash /Users/macbookpro/claude-cowork-config/scripts/vendor-prune.sh
# -> ::error::vendor-prune: cowork.lock.json has 0 files[] entries — refusing to prune against an
#    empty or unreadable lock.
# -> EXIT=1
ls vendored/agency-agents/marketing/m1.md   # -> present (0 files deleted)
```

- [x] **RAN 2026-08-31.** Exit 1, the file survives — an empty lock deletes nothing, making "an
      empty lock deletes the corpus" structurally unreachable (docs/architecture.md ADR-100 D5).
      PASS.

## 4. S1 (CRITICAL) reproduction — newline filename + repo-root sentinel

`docs/internal/security/security-review-v2.19.16.md` S1: a vendored filename containing a newline
byte splits a **line-oriented** `while IFS= read -r vfile` loop into two iterations; the second
iteration's `$vfile` resolves relative to the working directory (the repo root in CI), and an
unconstrained `rm -f -- "$vfile"` deletes it, exiting 0. Two independent controls close this
(NUL-delimited enumeration, and a `"$ROOT"/*` prefix assertion) — this section proves BOTH fire
independently, so a future regression that silently drops either one is still caught by the other.

### 4a. Reproduce the ORIGINAL vulnerability (naive §C.2.3 form, never shipped)

**Fixture:** `/tmp/fx-vp6/` — a sentinel `DECOY.md` at the fixture root; a vendored file whose name
is literally `bad<LF>DECOY.md` (created via `pathlib.Path(...).touch()` to get a real newline byte
in the filename, since shell quoting of an embedded newline is unreliable); lock lists only
`marketing/legit.md`, so the newline file is an orphan under either script form.

```bash
bash -c 'cd /tmp/fx-vp6; LOCK=cowork.lock.json; ROOT=vendored/agency-agents;
  LOCK_PATHS="$(jq -r ".files[].path" "$LOCK")"; PRUNED=0;
  while IFS= read -r vfile; do
    rel="${vfile#$ROOT/}"
    printf "%s\n" "$LOCK_PATHS" | grep -qxF "$rel" && continue
    rm -f -- "$vfile"; PRUNED=$((PRUNED+1)); echo "removed orphan: ${vfile}"
  done < <(find "$ROOT" ! -name LICENSE \( -type f -o -type l \))
  echo "PRUNED=${PRUNED}"'
# -> removed orphan: vendored/agency-agents/marketing/bad
# -> removed orphan: DECOY.md
# -> PRUNED=2
# -> EXIT=0
ls /tmp/fx-vp6/DECOY.md
# -> ls: /tmp/fx-vp6/DECOY.md: No such file or directory
```

- [x] **RAN 2026-08-31.** Confirmed RED, independently, on a fixture built for this session (not
      copied from the security review's own reproduction): the naive form reports `PRUNED=2`
      (having counted the sentinel as a second "orphan"), exits **0** (success), and the
      repo-root sentinel `DECOY.md` is **destroyed**. This is character-for-character the S1
      mechanism — the sentinel's absence is the alarm, and it fired.

### 4b. The SHIPPED script (both fixes applied) — sentinel survives

**Fixture:** `/tmp/fx-vp4/` — identical shape to 4a (sentinel at fixture root, same newline
filename, same lock), run against the actual `scripts/vendor-prune.sh`.

```bash
cd /tmp/fx-vp4 && bash /Users/macbookpro/claude-cowork-config/scripts/vendor-prune.sh
# -> vendor-prune: removed orphan vendored/agency-agents/marketing/bad
# -> DECOY.md
# -> vendor-prune: 1 orphan(s) removed.
# -> EXIT=0
cat /tmp/fx-vp4/DECOY.md
# -> IMPORTANT REPO FILE
```

- [x] **RAN 2026-08-31.** Sentinel **survives** — `cat` returns its original content. Exactly
      **1** orphan removed (the whole `marketing/bad<LF>DECOY.md` path, treated as ONE atomic
      unit by NUL-delimited enumeration — the two printed lines are one `echo` of one path whose
      own name happens to contain a newline, not two separate deletions). This is the CORRECT,
      safe outcome: the newline-named file genuinely lives inside `$ROOT` and genuinely is not in
      the lock, so deleting it as one atomic orphan is right; what must never happen is the
      SENTINEL — outside `$ROOT` — being reached, and it was not.

### 4c. The prefix check fires independently of NUL-delimited enumeration

Because `find "$ROOT" …` is rooted, it can **never** itself produce a path outside `$ROOT` — so 4b
alone cannot prove the prefix check (`case "$vfile" in "$ROOT"/*) ;; *) … exit 1 ;; esac`) is a real,
firing control rather than dead code that happens to never execute. Tested in isolation, feeding it
exactly the string the OLD naive loop's second iteration would have produced (`DECOY.md`, no `$ROOT`
prefix — the literal value that killed the sentinel in §4a):

```bash
bash -c 'ROOT="vendored/agency-agents"; vfile="DECOY.md";
  case "$vfile" in
    "$ROOT"/*) echo "ALLOWED: $vfile" ;;
    *) echo "::error::vendor-prune: refusing to act on '"'"'${vfile}'"'"' — outside ${ROOT}."; exit 1 ;;
  esac'
# -> ::error::vendor-prune: refusing to act on 'DECOY.md' — outside vendored/agency-agents.
# -> EXIT=1
```

- [x] **RAN 2026-08-31 — firing negative control.** Refuses, exit 1, names the offending path.
      Proves the prefix check would independently have stopped the exact §4a exploit shape even
      if NUL-delimited enumeration were ever reverted in a future edit — "either control alone
      stops the attack" is not asserted, it is demonstrated.

```bash
bash -c 'ROOT="vendored/agency-agents"; vfile="vendored/agency-agents/marketing/legit.md";
  case "$vfile" in
    "$ROOT"/*) echo "ALLOWED: $vfile" ;;
    *) echo "::error:: refusing $vfile"; exit 1 ;;
  esac'
# -> ALLOWED: vendored/agency-agents/marketing/legit.md
# -> EXIT=0
```

- [x] **RAN 2026-08-31 — firing positive control.** A genuine in-root path is allowed through,
      exit 0 — the negative control above is not a check hardcoded to `exit 1` in disguise.

## Summary

| # | Control | Fixture | Result |
|---|---------|---------|--------|
| 1 | Positive (lock == disk) | `/tmp/fx-vp1` | 0 removed, exit 0, all files present |
| 2 | Negative (1 real orphan) | `/tmp/fx-vp2` | 1 removed (correct file), exit 0 |
| 3 | Refusal (empty lock) | `/tmp/fx-vp3` | exit 1, 0 removed |
| 4a | S1 reproduction — naive form | `/tmp/fx-vp6` | sentinel destroyed, exit 0 (the bug) |
| 4b | S1 reproduction — shipped form | `/tmp/fx-vp4` | sentinel survives, exit 0 (the fix) |
| 4c | Prefix check in isolation | n/a (unit test) | refuses out-of-root, allows in-root |

All four required controls, plus the two isolated unit tests proving belt-and-suspenders
independence, ran GREEN against the shipped script and RED against the naive form it replaces.
