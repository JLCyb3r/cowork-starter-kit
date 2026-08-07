#!/usr/bin/env bash
# scripts/release-predicate.sh — shared definitions sourced by both scripts/
# publish-release.sh (producer) and scripts/verify-release-surface.sh (standing gate),
# so the two callers are PROVABLY running the same code rather than two hand-copied
# checks that can silently drift apart.
#
# Why one definition rather than two copies plus a `cmp` mirror gate (the house pattern
# at .github/workflows/quality.yml:761, ADR-016 v2.6): drift-by-construction is
# IMPOSSIBLE with one definition and merely DETECTED with two. This has now been the
# actual failure shape TWICE in this one cycle — the producer/gate body-predicate
# disagreement (ADR-077 §D1) is the first instance; the destination-repo guard existing
# in `publish-release.sh` alone while its sibling `verify-release-surface.sh` made an
# equally redirectable `gh` call unguarded (docs/qa-report-v2.19.6.md §9.5) is the second,
# caught live, in the artifact this cycle exists to make trustworthy. Do not add a third
# copy of anything in this file elsewhere; add a caller instead.
#
# ADR-077 §D2 covers body_names_version(). Do not modify either function without reading
# the relevant section first.

# body_names_version <body-text> <x.y.z-version>
#   Returns 0 if the body names the version, in EITHER of two forms:
#     - dotted leg:  the literal "x.y.z" string appears in the body
#     - anchor leg:  the literal "CHANGELOG.md#<dots-stripped-version>---" appears in the
#                    body — this is the literal GitHub produces by slugifying this repo's
#                    "## [x.y.z] - date" CHANGELOG headers (e.g. "## [2.18.0] - 2026-07-22"
#                    -> "#2180---2026-07-22"). GitHub's slugifier itself is deliberately
#                    NOT reproduced — matching the literal this repo actually writes is a
#                    smaller, verifiable commitment than reimplementing an undocumented
#                    third-party algorithm.
#   Returns 1 otherwise.
#
#   grep -F (fixed-string), never -E: the anchor literal contains "." and "#" — under a
#   regex engine "CHANGELOG.md#" would match "CHANGELOGXmdY", and the version argument
#   would carry metacharacter risk. Fixed-string removes both concerns.
#
#   The anchor leg's trailing "---" is a load-bearing RIGHT BOUNDARY, for two
#   independently sufficient reasons (both measured live, ADR-077 §D2):
#     - without it, a future "2.19.10" anchor (`...#21910---...`) false-positives a
#       "2.19.1" lookup (`CHANGELOG.md#2191` is a substring of `CHANGELOG.md#21910`)
#     - without it, dots-stripped forms collide outright: "2.0.2" and "2.18.0"'s own
#       "2026-" date both strip/contain "202"; "2.19.0" and "21.9.0" both strip to "2190"
#
#   Known, accepted, recorded limitation (ADR-077 §Maturation Path): the DOTTED leg is
#   NOT right-bounded — "2.19.1" also matches inside "2.19.10". Pre-existing behavior,
#   unreachable through either caller because the dotted leg is only ever evaluated
#   against the Release for that exact version (no cross-version confusion is possible
#   through publish-release.sh or verify-release-surface.sh today). Tightening it would
#   change long-standing producer behavior for no reachable gain — accepted with a
#   revisit trigger, not silently left alone.
body_names_version() {
  local body="$1" version="$2"
  local stripped="${version//./}"
  printf '%s' "$body" | grep -qF "$version" && return 0                        # dotted leg
  printf '%s' "$body" | grep -qF "CHANGELOG.md#${stripped}---" && return 0     # anchor leg
  return 1
}

# refuse_if_gh_redirect_env_set <expected-owner/repo-for-the-message>
#   Returns 1 (and prints a named ERROR to stderr) if GH_REPO or GH_HOST is set in the
#   environment; returns 0 (silent) otherwise. Callers exit on a non-zero return — this
#   function never calls `exit` itself, so it behaves identically whether called from a
#   plain script (publish-release.sh, exit 1 on its own convention) or one with its own
#   documented exit-code contract (verify-release-surface.sh, exit 2 = "usage,
#   environment, or contract error" — this IS one).
#
#   docs/qa-report-v2.19.6.md §9.5 (S2/S9, the "ninth instance"): the original guard was
#   written against `publish-release.sh` alone and worded as "the pre-flight before an
#   irreversible gh write." That framing is why `verify-release-surface.sh`'s own
#   `gh release view` call (inside `evidence_body()`) went unguarded — it isn't a WRITE,
#   so it didn't look like it was in scope, even though it is exactly as redirectable.
#   The guard belongs to the HOP ("any `gh` call whose target can be redirected by these
#   two variables"), not to the caller that first prompted it. Re-worded here accordingly:
#   this function makes no claim about writing vs. reading.
#
#   Covers, per the complete `gh help environment` output (read in full, not skimmed):
#     - GH_REPO: overrides repository resolution for any `gh` subcommand that operates
#       implicitly on "the repository for the current directory" — `gh release view/
#       create/edit` (no `--repo` flag) all do this, verified live. An explicit
#       `repos/OWNER/REPO/...` path passed to `gh api` is NOT affected by GH_REPO — also
#       verified live (`GH_REPO=cli/cli gh api repos/jmlozano1990/Cowork-Starter-Kit/
#       releases/latest` still returned THIS repo's own data) — but this function does
#       not try to reason per-call about which form each caller happens to use today;
#       every caller of this file refuses uniformly, so a future caller (or a future edit
#       to an existing one) can never silently fall outside coverage.
#     - GH_HOST: overrides which GitHub host `gh` talks to. Verified live to redirect
#       `gh api repos/OWNER/REPO/...` — an EXPLICIT repo path — to a different host
#       entirely (fails closed today only because `github.example.com` doesn't resolve;
#       a real alternate host would not fail this way). So GH_HOST is a real vector even
#       for the one call form GH_REPO cannot reach, which is exactly why both variables
#       are refused together rather than matched to specific call sites.
#     - `--repo`/`-R` (a flag, not an environment variable) is out of scope for THIS
#       function by construction — grep confirms neither caller of this file passes it to
#       any `gh` invocation. An operator's own aliased wrapper injecting `--repo` is a
#       different threat model an environment-variable guard cannot observe.
#     - No other documented `gh` environment variable affects repository or host
#       resolution (`GH_TOKEN`/`GH_ENTERPRISE_TOKEN` are AUTH only, never target selection).
refuse_if_gh_redirect_env_set() {
  local expected_repo="$1"
  if [ -n "${GH_REPO:-}" ] || [ -n "${GH_HOST:-}" ]; then
    echo "ERROR: refusing to run — GH_REPO and/or GH_HOST is set in this shell." >&2
    echo "  GH_REPO='${GH_REPO:-<unset>}'  GH_HOST='${GH_HOST:-<unset>}'" >&2
    echo "  Either can redirect a 'gh' call to a repository or host other than" >&2
    echo "  ${expected_repo}, which this script must never do. Run 'unset GH_REPO GH_HOST'" >&2
    echo "  and try again." >&2
    return 1
  fi
  return 0
}
