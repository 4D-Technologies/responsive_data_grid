# Ledger and GitHub post

Orchestrator-owned. Reviewers emit rows; the orchestrator re-labels
severity using the parent skill's decision tree.

Persist at `/tmp/rdg-pr-review/<n>/ledger.md`. Create the directory.
Do not commit the ledger.

## Row

```text
S<id> [blocker|should|nit] <path>:<line> <claim>. Fix: <suggestion>
outcome: open | fixed | disagree: <evidence> | declined: <reason> | still open: <reason>
reviewer: security | quality
```

Stable ids across rounds (`S1`, `S2`, …). Never reuse. Never guess
usage/cost.

Verdict line from each reviewer: `VERDICT: APPROVE` or `VERDICT: CHANGES`.

## GitHub each round

Published `COMMENT` review (visible). Inline comments only on right-side
diff lines (added or context). Findings whose line is not in the diff go
in the review body.

Redact: cite `path:line` and secret *kind* only. Never paste tokens,
passcodes, PII, keys, or other secret *values* into the ledger, the
`/tmp` copy, or the `gh api .../reviews` payload.

1. Walk `git diff` hunks: `@@ -<old>[,c] +<new>[,c] @@`. Space and `+`
   lines increment the right-side counter; `-` lines do not.
2. Payload:

```json
{
  "commit_id": "<headSha>",
  "event": "COMMENT",
  "body": "## Round <k> ledger\n\n<rows>\n\nblocker/should/nit counts",
  "comments": [
    {
      "path": "path/to/file",
      "line": 42,
      "side": "RIGHT",
      "body": "**[S1 should][quality]** claim\n\n**Fix:** suggestion"
    }
  ]
}
```

1. `gh api repos/4D-Technologies/responsive_data_grid/pulls/<n>/reviews -X POST --input <file>`
2. HTTP 422 on a line: fold that comment into the body and retry **once**.
3. Later rounds: new COMMENT review. Prefix body with outcomes of old
   ids (`S1 fixed`, `S2 still open: …`).

Self-approval of `APPROVE` is forbidden; this loop posts `COMMENT` only.
James approves the PR in the GitHub UI when the loop reports Agreed.
