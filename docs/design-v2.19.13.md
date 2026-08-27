# Design — v2.19.13 "Citation Repair + Registry-Row Integrity"

> *ISO 15288 — Technical Management: Project Planning Process.*

**Cycle:** v2.19.13 · **Phase:** 1 (Design) · **Mode:** full
**Classification:** SECURITY-SENSITIVE — Tier A · COMPLIANCE-SENSITIVE = NO
**Worktree:** `/Users/macbookpro/claude-cowork-config/.worktrees/v2.19.13-citation-repair`
**Branch:** `release/v2.19.13-citation-repair` · **Base:** `9f6ddc2e60e443297b3f1e9bbc7f9e70852b7922`

**Evidence base for every number in this document.** All measurements were re-run by @architect
during Phase 1 against the **worktree** at `9f6ddc2` (`git -C <wt> status --porcelain` → 0 lines),
never against `/Users/macbookpro/claude-cowork-config` (the `main` checkout, which is a live
parallel-session surface). Binary: `/usr/bin/grep` = **BSD grep (GNU compatible) 2.6.0-FreeBSD**,
invoked by absolute path because the bare `grep` in this harness is a ugrep shim that under-counts.
Shell: `zsh`, with `/bin/bash` cross-checked explicitly wherever shell semantics were load-bearing.

**The standing rule this cycle produced, applied to this document's own inputs:**

> A number inherited from a reviewer is not verified until the recipient re-runs it.

Every number in `phase1-binding-conditions-v2.19.13.md` was **re-run, not adopted** — including the
numbers @architect itself wrote in Round 1 and Round 2. Three inherited numbers did not survive
re-measurement; they are recorded in §B.2 with the commands that falsified them.

---

## Table of contents

- §A — Phase 1 Design Header (mandatory records)
- §B — Binding-conditions disposition + defects found IN the conditions file
- §C — Technical design
- §D — File-by-File Implementation Plan + `scope_allow_delta`
- §E — Push sequence
- §F — Residuals and carry-forwards

---

<!-- §A populated in commit 3 -->
<!-- §B populated in commit 4 -->
<!-- §C populated in commit 5 -->
<!-- §D populated in commit 6 -->
