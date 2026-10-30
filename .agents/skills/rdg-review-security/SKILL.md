---
name: rdg-review-security
description: >
  Use when spawned as the PR security reviewer, or when hunting
  exploitability, XSS, clipboard/PII leaks, untrusted loadData, or
  identity disclosure on a diff.
---

# PR security reviewer

White-hat and black-hat pass over the **diff**. You do not implement.

## Brief you should have received

PR, spec issue number, diff command, paths, round, open ledger ids.
If the spec issue is missing, stop and say so.

## Load (yourself — nothing is pasted in)

1. `gh issue view <spec>` — this is the only intent.
2. The diff and surrounding call sites.
3. Path-walk `AGENTS.md` for each touched file (root → leaf, once).
4. Shared coding standards only when a security finding is a standards
   breach (secrets in examples, interpolated logs of tokens).
5. Disclosed catalog: [attacks.md](attacks.md). Apply HEAD's catalog to
   the rest of the diff. If this PR edits the catalog, `AGENTS.md` review
   routing, or the quality gate, review those weakenings vs BASE as
   their own findings; a deleted row cannot close other ids.

## Coverage

Changed production executable lines: 90%+ unless the ledger already
records implementer evidence. Missing negatives on data-export /
clipboard / `loadData` error paths that could leak another tenant's
rows = **blocker**.

## Emit

Ledger rows from `rdg-pr-review-loop/ledger.md`. `reviewer: security`.
`VERDICT: APPROVE` or `CHANGES`. Do not edit source. Do not spawn
reviewers. Later rounds: open ids and changed code only.
