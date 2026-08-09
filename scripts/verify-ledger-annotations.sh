#!/usr/bin/env bash
# scripts/verify-ledger-annotations.sh — v2.19.8 Scope B item 10 (ADR-081 D1;
# docs/spec.md AC-B-VERIFY-1..5; @architect 0.D condition B-1).
#
# RECONSTRUCTED at the Phase-3 gate. The Phase-1 copy was deleted by
# scripts/guards/bash-write-detector.sh, which removes new untracked files while Phase 3
# is unapproved — correct behaviour for a Phase-4 artifact created at Phase 1. Rebuilt
# under design authority rather than by @dev so that the anchors and the annotations they
# check have different authors; otherwise a green run at Phase 5 has no baseline behind it.
#
# WHAT THIS CHECKS, STATED NARROWLY ON PURPOSE (ADR-081 §Consequences):
#   It verifies that every anchor a v2.19.8 ledger annotation cites STILL RESOLVES TO THE
#   THING IT NAMES. It does NOT verify that an annotation says something TRUE.
#   Overclaiming that reach would be the exact false-control shape this repo has spent
#   three cycles closing: a check whose stated purpose is wider than its actual test.
#
# WHY IT EXISTS: eight annotations in this repo's ledger carried claims copied forward
# instead of re-derived. Four cited positions did not resolve, and one resolved to the
# WRONG RELEASE rather than to nothing — silent, not loud. The defect class is CITATION
# ROT OVER TIME, which is why this runs in CI on every push and pull_request, not once.
#
# --- FOUR INVARIANTS, EACH MECHANICALLY CHECKABLE BY A THIRD PARTY ---
#
# (1) SCOPE VISIBILITY [AC-B-VERIFY-5; ADR-081 §Context (3), reusing The-Council ADR-198
#     §Decision 2]. Every anchor names THE FILE IT SEARCHES. A pattern matching somewhere
#     in the repo is a DIFFERENT CLAIM from a pattern matching where the annotation says
#     it is. NEVER convert a per-file grep here into a repo-wide one: this repository
#     vendors 108 third-party files under vendored/agency-agents/, which is precisely
#     where a decoy string would be planted to satisfy a repo-wide anchor.
#     CHECKABLE:  grep -c 'grep -cE -- "$P" "$TARGET"' -> every match is file-scoped;
#                 no unscoped `grep -r` appears anywhere below.
#
# (2) NULL-DELIMITED ITERATION [ADR-084; @security S15]. The single list iteration below
#     uses a `printf '%s\0'` producer and a `read -r -d ''` consumer, so a path or pattern
#     containing a newline cannot split a record.
#     CHECKABLE:  every `while ... read` over a list pairs -d '' with a \0 producer.
#
# (3) ZERO THIRD-PARTY EGRESS [AC-B-VERIFY-4; @security S15]. The only network call is
#     `gh api` against THIS repository's own API. v2.19.8 Scope A/E handle third-party
#     content under an untrusted-data boundary (AC-A4); putting any part of that boundary
#     inside the verification harness would place untrusted input inside the control that
#     guards it.
#     CHECKABLE:  the exact egress-scan command is in docs/design-v2.19.8.md §C.4 and is
#                 DELIBERATELY NOT REPRODUCED HERE. Writing the pattern into this file
#                 makes the file match its own scan, and a check that matches itself
#                 cannot distinguish a real hit from its own documentation — which is the
#                 same "cannot fail / cannot cleanly pass" defect family this script
#                 exists to catch. Run it from §C.4; the pass condition is ZERO output.
#
# (4) NO BARE LINE NUMBERS IN ASSERTIONS. Not one assertion below keys on a line number;
#     every one keys on content. A verifier that committed the defect it detects would be
#     self-refuting. Line numbers appear ONLY in narrative comments, per this repo's
#     existing convention (verify-vendored-orphans.sh does the same).
#
# Usage: scripts/verify-ledger-annotations.sh [--repo-root DIR] [--no-probes]
#   --repo-root DIR  defaults to the repo root inferred from this script's location.
#                    TEST SEAM for fixture-based negative controls. The real call sites
#                    (quality.yml, local Phase-5 re-run) never pass it. Flag-only, never
#                    an environment variable — house convention (--vendored-dir, --lock,
#                    --base, --head).
#   --no-probes      skip SECTION 2 entirely. For offline reproduction of SECTION 1 only.
#                    Prints a loud SKIPPED line; never silent.
#
# Exit: 0 = every static anchor resolved, and SECTION 2 either succeeded or was skipped
#           for a declared, printed reason
#       1 = usage error, unreadable input, zero-scan, any static anchor failure, or a
#           SECTION 2 probe failure while a token was available

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
RUN_PROBES=1

while [ $# -gt 0 ]; do
  case "$1" in
    --repo-root)  REPO_ROOT="${2:-}"; shift 2 ;;
    --no-probes)  RUN_PROBES=0; shift ;;
    *)
      echo "ERROR: verify-ledger-annotations: unknown argument '$1' (usage: --repo-root DIR --no-probes)" >&2
      exit 1 ;;
  esac
done

if [ ! -d "$REPO_ROOT" ]; then
  echo "ERROR: verify-ledger-annotations: '${REPO_ROOT}' is not a directory." >&2
  exit 1
fi

FAIL=0
CHECKED=0
FAILED=0        # STATIC-ANCHOR failures only. Never incremented by SECTION 2.
PROBE_FAILED=0  # SECTION 2 failures only.
UTC_NOW="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# UNITS ARE DECLARED, NOT INFERRED. CHECKED counts STATIC ANCHORS (SECTION 1) and nothing
# else; the live probe is a separate population and is counted separately. This repo has
# been bitten four times in one cycle by a count whose unit was left implicit — once
# inside the very document arguing for counting precision (docs/patterns.md WATCH item).
# An earlier revision of THIS script reported "7 of 19 static anchors" after a probe
# failure, when only 6 static anchors had failed. Same defect, caught by running it.

# ---------------------------------------------------------------------------
# SECTION 1 — STATIC ANCHORS (LA-01 .. LA-10b, 19 total)
#
# Deterministic, offline, reproducible from a clean checkout. Record layout:
#   ID <US> FILE <US> MODE <US> EXPR <US> DESCRIPTION
# <US> = \037 between fields, \0 between records (invariant 2 above).
#
# MODE:
#   exists   EXPR ignored — FILE must exist
#   min1     `grep -cE EXPR FILE` >= 1
#   eq:N     `grep -cE EXPR FILE` == N exactly
#   all      EXPR is a \036-separated list; EVERY pattern must have >= 1 match.
#            Used where an anchor must track TWO co-located facts, so that deleting
#            either one turns it RED (see LA-05a).
#
# THE TABLE IN docs/design-v2.19.8.md §C.2 HAS ONE ROW PER ID HERE. That equality is
# itself the anti-drift control: 19 records, 19 rows. If you add an anchor, add a row.
#
# EVERY FAILURE IS REPORTED, never just the first — a run that stops at the first bad
# anchor hides how much of the ledger has rotted, and the count is the signal.
# ---------------------------------------------------------------------------

US=$'\037'
RS=$'\036'

anchor_records() {
  printf '%s\0' \
"LA-01${US}docs/risk-register.md${US}min1${US}CF-v2\.19\.6-A${US}CF-v2.19.6-A row present and citable" \
"LA-02a${US}scripts/verify-vendored-orphans.sh${US}exists${US}-${US}CF-v2.19.5-B closure command (orphan check on disk)" \
"LA-02b${US}.github/workflows/sync-agency.yml${US}min1${US}exit 1${US}CF-v2.19.5-D closure command (LICENSE branch really exits 1)" \
"LA-02c${US}.github/workflows/sync-agency.yml${US}min1${US}flagged_files<<${US}CF-v2.19.5-E closure command (heredoc delimiter form present)" \
"LA-03a${US}docs/security-audit-v2.19.6.md${US}min1${US}S-A3${US}S-A3 recorded in its REAL location (not docs/retro.md, where it occurs 0 times)" \
"LA-03b${US}docs/security-audit-v2.19.6.md${US}min1${US}S-A9${US}S-A9 recorded in its REAL location" \
"LA-03c${US}docs/security-audit-v2.19.6.md${US}min1${US}S-A10${US}S-A10 recorded in its REAL location" \
"LA-04a${US}CHANGELOG.md${US}eq:1${US}^## \[1\.0\.0\]${US}AC-PUB-10 v1.0.0 anchor (replaces the stale CHANGELOG.md:1038 citation)" \
"LA-04b${US}CHANGELOG.md${US}eq:1${US}^## \[1\.1\.1\]${US}AC-PUB-10 v1.1.1 anchor (replaces the stale CHANGELOG.md:991 citation)" \
"LA-04c${US}CHANGELOG.md${US}eq:1${US}^## \[2\.0\.1\]${US}AC-C1 backfilled 2.0.1 section (FORWARD — RED until Phase 4)" \
"LA-05a${US}.github/workflows/sync-agency.yml${US}all${US}Check blocked files${RS}grep -qxF \"\\\$file_path\"${US}allowlist reader anchor, CONJUNCTIVE per S21 — the comment AND the reader it labels" \
"LA-05b${US}docs/architecture.md${US}min1${US}CI fails if any blocked file${US}allowlist false-safety-claim anchor (replaces the stale architecture.md:3187 citation)" \
"LA-05c${US}.cowork-allowlist.json${US}eq:0${US}[A-Za-z0-9_./-]*[A-Za-z_-]:[0-9]+${US}AC-B5-2 / AC-B5-2a EXTENSION-AGNOSTIC NC — zero bare file:line citations anywhere in the allowlist, including extensionless files (CODEOWNERS, VERSION) the prior (md|yml|sh|json) whitelist could not see" \
"LA-06${US}docs/risk-register.md${US}min1${US}v2\.19\.7-LEDGER-FP${US}v2.19.7-LEDGER-FP row present and citable" \
"LA-07${US}docs/retro.md${US}min1${US}the next PR touching${US}the invented closing condition is still where the correction points" \
"LA-08${US}docs/owner-tasks.md${US}eq:1${US}ONESKILL KIT-VS-SKILL FIT${US}C-5 OneSkill tracked row (FORWARD — RED until Phase 4)" \
"LA-09${US}docs/spec.md${US}eq:1${US}^AC-OT3-2-DISPOSITION: (DETERMINATE|INDETERMINATE)\$${US}AC-A3 disposition token, line-anchored distinct key (FORWARD — RED until Phase 4)" \
"LA-10a${US}CHANGELOG.md${US}eq:1${US}^## Release surface${US}AC-C2 preamble subsection stating the invariant (FORWARD — RED until Phase 4)" \
"LA-10b${US}CHANGELOG.md${US}eq:2${US}never tagged, never released${US}AC-C2 per-version release-surface notes, one each for 1.0.0 and 1.1.1 (FORWARD — RED until Phase 4)"
}

echo "verify-ledger-annotations: SECTION 1 — static anchors (repo root: ${REPO_ROOT})"

while IFS= read -r -d '' RECORD; do
  [ -z "$RECORD" ] && continue

  ID="${RECORD%%"${US}"*}";          REST="${RECORD#*"${US}"}"
  AFILE="${REST%%"${US}"*}";         REST="${REST#*"${US}"}"
  MODE="${REST%%"${US}"*}";          REST="${REST#*"${US}"}"
  EXPR="${REST%%"${US}"*}";          DESC="${REST#*"${US}"}"

  CHECKED=$((CHECKED + 1))
  TARGET="${REPO_ROOT}/${AFILE}"

  if [ "$MODE" = "exists" ]; then
    if [ -e "$TARGET" ]; then
      echo "  ${ID} PASS — ${AFILE} exists (${DESC})"
    else
      echo "::error::verify-ledger-annotations: ${ID} FAILED — ${AFILE} does not exist. Annotation: ${DESC}" >&2
      FAIL=1; FAILED=$((FAILED + 1))
    fi
    continue
  fi

  if [ ! -r "$TARGET" ]; then
    echo "::error::verify-ledger-annotations: ${ID} FAILED — cannot read '${AFILE}' (the anchor names a file that is not there). Annotation: ${DESC}" >&2
    FAIL=1; FAILED=$((FAILED + 1))
    continue
  fi

  case "$MODE" in
    min1|eq:*)
      # `|| true` guards grep's exit 1 on zero matches under `set -e`. The COUNT is the
      # assertion, never grep's exit status — zero IS the expected value for eq:0
      # anchors, so treating exit 1 as an error would invert LA-05c.
      COUNT="$(grep -cE -- "$EXPR" "$TARGET" 2>/dev/null || true)"
      [ -z "$COUNT" ] && COUNT=0
      ;;
  esac

  case "$MODE" in
    min1)
      if [ "$COUNT" -ge 1 ]; then
        echo "  ${ID} PASS — ${COUNT} match(es) in ${AFILE} (${DESC})"
      else
        echo "::error::verify-ledger-annotations: ${ID} FAILED — anchor did not resolve in ${AFILE}. Expected >=1 match for /${EXPR}/, got ${COUNT}. Annotation: ${DESC}" >&2
        FAIL=1; FAILED=$((FAILED + 1))
      fi
      ;;
    eq:*)
      WANT="${MODE#eq:}"
      if [ "$COUNT" -eq "$WANT" ]; then
        echo "  ${ID} PASS — exactly ${COUNT} match(es) in ${AFILE} (${DESC})"
      else
        echo "::error::verify-ledger-annotations: ${ID} FAILED — anchor did not resolve in ${AFILE}. Expected exactly ${WANT} match(es) for /${EXPR}/, got ${COUNT}. Annotation: ${DESC}" >&2
        FAIL=1; FAILED=$((FAILED + 1))
      fi
      ;;
    all)
      # Conjunctive anchor [S21]. Every \036-separated pattern must match in the SAME
      # named file. The failure this closes: LA-05a used to anchor only the comment
      # "Check blocked files", so replacing the `grep -qxF` reader underneath it while
      # leaving the comment in place kept the anchor GREEN and made its claim FALSE.
      # An anchor that survives the deletion of the thing it tracks is not an anchor.
      ALL_OK=1; SUB="$EXPR"; SEEN=""
      while [ -n "$SUB" ]; do
        P="${SUB%%"${RS}"*}"
        if [ "$P" = "$SUB" ]; then SUB=""; else SUB="${SUB#*"${RS}"}"; fi
        [ -z "$P" ] && continue
        PC="$(grep -cE -- "$P" "$TARGET" 2>/dev/null || true)"
        [ -z "$PC" ] && PC=0
        SEEN="${SEEN} [/${P}/ -> ${PC}]"
        if [ "$PC" -lt 1 ]; then
          echo "::error::verify-ledger-annotations: ${ID} FAILED — conjunct did not resolve in ${AFILE}. Expected >=1 match for /${P}/, got ${PC}. Annotation: ${DESC}" >&2
          ALL_OK=0
        fi
      done
      if [ "$ALL_OK" -eq 1 ]; then
        echo "  ${ID} PASS — all conjuncts resolved in ${AFILE}:${SEEN} (${DESC})"
      else
        FAIL=1; FAILED=$((FAILED + 1))
      fi
      ;;
    exists)
      : ;;
    *)
      echo "::error::verify-ledger-annotations: ${ID} FAILED — internal: unknown MODE '${MODE}'." >&2
      FAIL=1; FAILED=$((FAILED + 1))
      ;;
  esac
done < <(anchor_records)

# Zero-scan guard — house pattern (verify-vendored-orphans.sh, quality.yml's
# vendored-integrity-check, lock-content-sha-cross-check). A check that never checked
# anything is not a passing check, and this is the single most common way a control in
# this repo has historically reported success while verifying nothing.
if [ "$CHECKED" -eq 0 ]; then
  echo "::error::verify-ledger-annotations: CHECKED=0 — no anchors were evaluated. A zero-scan run must never report success." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# SECTION 2 — LIVE PROBE                        [AC-B-VERIFY-3, rewritten per S23]
#
# S23 found the previous version had NO REACHABLE FAILURE STATE: its only defined failure
# was "the probe did not execute", and the design excused exactly that whenever a token
# was absent. A section that cannot fail is not a check — the same finding this whole
# script exists to prevent, committed inside the script itself.
#
# The split, and one refinement of S23 stated openly rather than smuggled:
#
#   NO TOKEN AVAILABLE      -> SKIPPED (no token). Printed loudly. Build PASSES.
#                              Rationale: a STATIC-anchor regression is the finding this
#                              script exists for; making it hostage to token availability
#                              would let the unimportant half veto the important half.
#   TOKEN AVAILABLE, and
#     probe returns 2xx     -> EXECUTED. Output recorded with a UTC timestamp.
#     probe returns 404     -> EXECUTED. Recorded as a MEANINGFUL NEGATIVE ANSWER.
#     anything else         -> FAILED. exit 1.
#     (401/403/5xx, network error, `gh` missing, unparseable JSON)
#
# REFINEMENT OF S23, FLAGGED FOR @security RATHER THAN APPLIED SILENTLY: S23 says any
# non-200 must fail. 404 is excluded here on purpose. This endpoint returns 404 when
# branch protection is simply not configured — that is the API healthily answering "no
# protection", which is exactly the currency evidence v2.19.5-CODEOWNERS-1 wants, and it
# is a state OT-7 step 2 could legitimately produce. Failing on it would mean the probe
# breaks precisely when it reports the answer we are watching for. The distinction being
# preserved is "the API answered, and the answer was no" versus "we could not ask".
# Every genuine could-not-ask case (auth, transport, malformed body) still fails.
#
# PASS CONDITION IS NEVER "REPRODUCES". Live API state is not a reproducible fixture;
# branch protection can change between two honest runs, and a control demanding a stable
# value from an unstable source teaches its readers to ignore it.
#
# Separated from SECTION 1 rather than interleaved: merging them would hand SECTION 2's
# non-reproducibility to SECTION 1, which IS reproducible and is where regressions show.
#
# [Phase-6 S1 correction, CRITICAL] THIS REPO'S CI DOES NOT SUPPLY A TOKEN, DELIBERATELY,
# AND SECTION 2 IS NOT MANDATORY IN CI. An earlier revision of docs/design-v2.19.8.md
# claimed the opposite ("SECTION 2 is effectively mandatory on every CI run") — false,
# and disproved by CI itself: `branches/{branch}/protection` requires `administration:
# read`, which this job's `permissions: { contents: read }` (S24, least-privilege) does
# not grant and never will — granting it would hand a probe that only records information
# the same read-scope as a repo admin, on a public repo. `secrets.GITHUB_TOKEN` under
# `contents: read` therefore 403s here on EVERY push and PR, structurally, not as a
# flake (reproduced live, run 31315509218/31316499420). The `ledger-annotations` job in
# .github/workflows/quality.yml no longer passes GH_TOKEN as of this fix, so SECTION 2
# takes its own SKIPPED (no token) path on every CI run; it is now an owner-side/local
# check only (a developer's own authenticated `gh` session, run locally, carries broader
# scopes than a workflow's GITHUB_TOKEN). SECTION 1's 19 static anchors are unaffected —
# see docs/design-v2.19.8.md §C.5's Phase-6 correction for the full record.
# ---------------------------------------------------------------------------

echo "verify-ledger-annotations: SECTION 2 — live probe"

if [ "$RUN_PROBES" -eq 0 ]; then
  echo "  LP-01 SKIPPED (--no-probes) at ${UTC_NOW} — SECTION 1 only, by explicit request."
else
  TOKEN_AVAILABLE=0
  if [ -n "${GH_TOKEN:-}" ] || [ -n "${GITHUB_TOKEN:-}" ]; then
    TOKEN_AVAILABLE=1
  elif command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    TOKEN_AVAILABLE=1
  fi

  if [ "$TOKEN_AVAILABLE" -eq 0 ]; then
    echo "  LP-01 SKIPPED (no token) at ${UTC_NOW} — neither GH_TOKEN/GITHUB_TOKEN is set nor is"
    echo "        'gh' authenticated. SECTION 1 stands on its own; this is a declared skip, not a"
    echo "        silent pass. Provide a token to make the probe mandatory."
  elif ! command -v gh >/dev/null 2>&1; then
    echo "::error::verify-ledger-annotations: LP-01 FAILED at ${UTC_NOW} — a token is available but 'gh' is not on PATH, so the probe could not be attempted." >&2
    FAIL=1; PROBE_FAILED=$((PROBE_FAILED + 1))
  else
    # LP-01 — currency evidence for docs/risk-register.md's v2.19.5-CODEOWNERS-1 row,
    # whose stated closing condition is `require_code_owner_reviews` confirmed enabled.
    # RECORDED, never asserted: this script does not decide whether OT-7 step 2 landed.
    PROBE_ERR="$(mktemp)"
    set +e
    PROBE_OUT="$(gh api "repos/{owner}/{repo}/branches/main/protection" 2>"$PROBE_ERR")"
    PROBE_RC=$?
    set -e

    if [ "$PROBE_RC" -eq 0 ]; then
      if printf '%s' "$PROBE_OUT" | jq -e 'type == "object"' >/dev/null 2>&1; then
        echo "  LP-01 EXECUTED at ${UTC_NOW} — gh api repos/{owner}/{repo}/branches/main/protection"
        echo "  LP-01 OUTPUT (recorded, not asserted):"
        printf '%s\n' "$PROBE_OUT" | sed 's/^/    /'
      else
        echo "::error::verify-ledger-annotations: LP-01 FAILED at ${UTC_NOW} — probe returned success but the body is not a JSON object. Could not ask, rather than asked-and-answered." >&2
        FAIL=1; PROBE_FAILED=$((PROBE_FAILED + 1))
      fi
    elif grep -q 'Branch not protected' "$PROBE_ERR" 2>/dev/null; then
      # [Phase-6 S3 — @security] The prior form matched bare 'HTTP 404', which is the
      # SAME status code GitHub returns for a branch that does not exist at all
      # (`Branch not found`, confirmed live against branches/nonexistent-branch-xyz).
      # Those are two different answers wearing the same status code: "the branch
      # exists and has no protection" (the meaningful negative this probe wants) versus
      # "we could not even find what we asked about" (a probe misfire — wrong branch
      # name, a rename, a typo). The prior form could not tell them apart and would
      # have printed the recorded-negative claim below for either one. Tightened to
      # require GitHub's own documented message string. LIMIT, stated rather than
      # implied: this was not observed positively — protection is currently ENABLED on
      # `main` (this probe's own live run above returns 200), and manufacturing the
      # `Branch not protected` case would mean disabling protection on this shared
      # public repo, which was refused. This branch rests on GitHub's documented
      # message text plus the observed `Branch not found` counter-example, not on an
      # observed positive.
      echo "  LP-01 EXECUTED at ${UTC_NOW} — HTTP 404 'Branch not protected': branch protection is NOT configured on main."
      echo "  LP-01 RESULT (recorded, not asserted): a meaningful negative answer, not a probe failure."
      echo "        v2.19.5-CODEOWNERS-1 remains OPEN; OT-7 step 2 has not landed."
    else
      echo "::error::verify-ledger-annotations: LP-01 FAILED at ${UTC_NOW} — a token was available but the probe did not complete (rc=${PROBE_RC}). This is 'could not ask', not 'the answer was no'." >&2
      sed 's/^/    /' "$PROBE_ERR" >&2 || true
      FAIL=1; PROBE_FAILED=$((PROBE_FAILED + 1))
    fi
    rm -f "$PROBE_ERR"
  fi
fi

# ---------------------------------------------------------------------------

if [ "$FAIL" -ne 0 ]; then
  # Both units are named on the same line, and neither is folded into the other.
  echo "::error::verify-ledger-annotations: FAILED — ${FAILED} of ${CHECKED} STATIC ANCHORS did not resolve, and ${PROBE_FAILED} LIVE PROBE(S) failed. These are two separate populations; the probe is not one of the ${CHECKED}. Each failure is named above with the file it was searched in." >&2
  exit 1
fi

echo "verify-ledger-annotations: PASS — ${CHECKED} of ${CHECKED} static anchors resolved; 0 live-probe failures; SECTION 2 completed at ${UTC_NOW}."
exit 0
