# registry-cardinality-check Firing Controls (v2.19.16, required pre-release)

Validates the fix to `.github/workflows/quality.yml`'s `registry-cardinality-check` job
(`AC-CARD-1`/`AC-CARD-2`/`AC-CARD-3`). Root cause: `grep -c` prints its own `0` on zero matches
**and** exits 1, so `DATA_ROWS=$(grep -cE '…' … || echo 0)` fires the `|| echo 0` branch **in
addition to** the printed `0`, producing the literal two-line string `"0\n0"`. `[ "0\n0" -lt 18 ]`
then errors at runtime **inside an `if` condition** — a context `set -e` does not abort on — so
control falls through to the pass branch. Fix: `|| true` (the house standard, already used at 7
sibling `$(grep -c …)` sites in this file). Every control below was run for real this session, not
narrated, against fixtures under `/tmp` — the real repo tree was never mutated.

## 1. Reproduce the ORIGINAL bug (pre-fix guard, zero-row fixture)

**Fixture:** `/tmp/fx-card-zero.md` — a registry table with 0 rows matching `\| (builtin|https?://)`.

```bash
bash -c 'DATA_ROWS=$(/usr/bin/grep -cE "\| (builtin|https?://)" /tmp/fx-card-zero.md || echo 0);
  if [ "$DATA_ROWS" -lt 18 ]; then echo "RED: only $DATA_ROWS entries"; exit 1; fi;
  echo "Registry cardinality check passed: $DATA_ROWS entries found (minimum: 18)."'
# -> bash: line 1: [: 0
# -> 0: integer expected
# -> Registry cardinality check passed: 0
# -> 0 entries found (minimum: 18).
# -> EXIT=0
```

- [x] **RAN 2026-08-31.** Confirmed, independently: the pre-fix guard reports the exact two-line
      `"0\n0"` value, the `[` comparison errors at runtime (visible on stderr), `set -e` does not
      abort inside the `if` condition, and control falls through to the **PASS** branch with
      **exit 0** — a guard that cannot fail at the one value it exists to catch. Character-for-
      character the defect `docs/architecture.md` ADR-100 §C.5 (via `docs/spec.md` Item 5)
      describes.

## 2. Negative control (zero) — repaired guard

Same fixture, `|| true` in place of `|| echo 0`.

```bash
bash -c 'DATA_ROWS=$(/usr/bin/grep -cE "\| (builtin|https?://)" /tmp/fx-card-zero.md || true);
  if [ "$DATA_ROWS" -lt 18 ]; then echo "RED: only $DATA_ROWS entries (minimum: 18)"; exit 1; fi;
  echo "PASS: $DATA_ROWS entries found (minimum: 18)."'
# -> RED: only 0 entries (minimum: 18)
# -> EXIT=1
```

- [x] **RAN 2026-08-31.** Exit 1, message correctly names `0`. PASS (the guard fails as required).

## 3. Negative control (boundary — 17 rows)

**Fixture:** `/tmp/fx-card-17.md` — 17 rows matching the pattern (one below the minimum), generated
programmatically and independently re-counted (`/usr/bin/grep -cE '\| (builtin|https?://)'` → `17`)
before use.

```bash
bash -c 'DATA_ROWS=$(/usr/bin/grep -cE "\| (builtin|https?://)" /tmp/fx-card-17.md || true);
  if [ "$DATA_ROWS" -lt 18 ]; then echo "RED: only $DATA_ROWS entries (minimum: 18)"; exit 1; fi;
  echo "PASS: $DATA_ROWS entries found (minimum: 18)."'
# -> RED: only 17 entries (minimum: 18)
# -> EXIT=1
```

- [x] **RAN 2026-08-31.** Exit 1. PASS — the guard correctly fails one row below the boundary.

## 4. Positive control (boundary — 18 rows)

**Fixture:** `/tmp/fx-card-18.md` — 18 rows (exactly the minimum), independently re-counted before
use.

```bash
bash -c 'DATA_ROWS=$(/usr/bin/grep -cE "\| (builtin|https?://)" /tmp/fx-card-18.md || true);
  if [ "$DATA_ROWS" -lt 18 ]; then echo "RED: only $DATA_ROWS entries (minimum: 18)"; exit 1; fi;
  echo "PASS: $DATA_ROWS entries found (minimum: 18)."'
# -> PASS: 18 entries found (minimum: 18).
# -> EXIT=0
```

- [x] **RAN 2026-08-31.** Exit 0. PASS — the guard correctly passes exactly at the boundary. This
      is the required mirror-image of item 3: a guard hardcoded to `exit 1` would satisfy item 2
      and item 3 alone; this item is what rules that out.

## 5. Positive control (real registry)

Row count re-derived at fix time, exit status explicitly checked (not assumed from the printed
value alone — the whole point of this cycle's fix):

```bash
cd /Users/macbookpro/claude-cowork-config
/usr/bin/grep -cE '\| (builtin|https?://)' curated-skills-registry.md; echo "exit=$?"
# -> 30
# -> exit=0
bash -c 'cd /Users/macbookpro/claude-cowork-config;
  DATA_ROWS=$(/usr/bin/grep -cE "\| (builtin|https?://)" curated-skills-registry.md || true);
  if [ "$DATA_ROWS" -lt 18 ]; then echo "RED: only $DATA_ROWS entries (minimum: 18)"; exit 1; fi;
  echo "PASS: $DATA_ROWS entries found (minimum: 18)."'
# -> PASS: 30 entries found (minimum: 18).
# -> EXIT=0
```

- [x] **RAN 2026-08-31.** Real registry: 30 rows (well above the 18 minimum), `grep`'s own exit
      status checked separately (`exit=0`, a genuine non-zero match count — not the `0`-prints-
      and-exits-1 case items 1-2 exist to catch), guard reports PASS, exit 0.

## Audit of the rest of `quality.yml` for the same defect class

`docs/architecture.md` ADR-100 D8 records that the first regex written to sweep for further
`|| echo` instances (`\$\((/usr/bin/)?grep -[a-zA-Z]*c[^)]*\|\|[[:space:]]*echo`) returned **0**
against a file containing the defect on line 562, because `[^)]*` stops at the `)` inside the
pattern `(builtin|https?://)` — that Phase-1/2 audit is not re-cited verbatim here because this
cycle's own Phase 4 edits (the `attribution-survives-render` real-corpus step, the generalised
`AC-B5-1`/`AC-B5-4` step) shifted every subsequent line number in the file — quoting the old line
numbers here would itself be exactly the kind of stale citation this cycle exists to catch.
Re-derived fresh, post-edit, with a corrected instrument that matches on the whole `||`, not just
`|| echo`:

```bash
/usr/bin/grep -nE '\$\(.*grep -[a-zA-Z]*c.*\|\|' /Users/macbookpro/claude-cowork-config/.github/workflows/quality.yml
# -> 14 executable $(grep -c ... || ...) sites, EVERY ONE already `|| true` (including the just-
#    fixed :562) -- :287, :324, :562, :725, :907, :1536, :1601, :1621, :1627, :1648, :1668, :1675,
#    :2065, :2612
/usr/bin/grep -nE '\$\(.*grep -[a-zA-Z]*c.*\|\|[[:space:]]*echo' /Users/macbookpro/claude-cowork-config/.github/workflows/quality.yml
# -> (no output, exit 1) -- zero executable `|| echo N` sites remain anywhere in the file
```

- [x] **RAN 2026-08-31.** After the fix at `:562`, **every** executable `$(grep -c … || …)` site in
      `quality.yml` (14 total) uses the house-standard `|| true`. Zero executable `|| echo N`
      instances remain. Two prose-only `|| echo` mentions remain (a comment describing this exact
      defect class, and an unrelated `git show … || echo '{}'` idiom ADR-080 separately forbids)
      — read individually and confirmed non-executable, not counted.

## Summary

| # | Control | Fixture | Result |
|---|---------|---------|--------|
| 1 | Pre-fix guard, zero rows | `/tmp/fx-card-zero.md` | false PASS, exit 0 (the bug, reproduced) |
| 2 | Negative (zero) | `/tmp/fx-card-zero.md` | RED, exit 1 |
| 3 | Negative (boundary, 17) | `/tmp/fx-card-17.md` | RED, exit 1 |
| 4 | Positive (boundary, 18) | `/tmp/fx-card-18.md` | PASS, exit 0 |
| 5 | Positive (real registry) | `curated-skills-registry.md` | PASS, 30 entries, exit 0 |

All required controls (`AC-CARD-1`, `AC-CARD-2`, `AC-CARD-3`) ran GREEN against the repaired guard
and RED against the guard it replaces.
