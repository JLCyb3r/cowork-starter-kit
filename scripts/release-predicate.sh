#!/usr/bin/env bash
# scripts/release-predicate.sh — the ONE shared definition of "does a Release body name
# its version," sourced by both scripts/publish-release.sh (producer) and
# scripts/verify-release-surface.sh (standing gate).
#
# Why one definition rather than two copies plus a `cmp` mirror gate (the house pattern
# at .github/workflows/quality.yml:761, ADR-016 v2.6): drift-by-construction is
# IMPOSSIBLE with one definition and merely DETECTED with two. The producer and the gate
# disagreeing about what "the body names its version" means is this cycle's defect class
# (docs/architecture.md ADR-077 §D1) one level up — a duplicated-and-mirrored predicate
# would only ever detect that disagreement after the fact, never prevent it.
#
# ADR-077 §D2. Do not modify without reading that section first.

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
