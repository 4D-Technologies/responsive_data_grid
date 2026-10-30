---
name: rdg-open-pr
description: >
  Use when opening a GitHub pull request, creating a PR, or finishing a
  feature that needs a PR. Conventional Commits, ready not draft, then
  rdg-pr-review-loop. Never assign @copilot as a reviewer.
---

# Opening a PR

Invoked at the end of implementation, before the review loop.

**Worktree.** Work from a branch off `main`. Dirty branch with unrelated
work: stop and ask. Do not commit `.mcp.json` unless the user asked.

**Commits.** Conventional Commits `type(scope): subject`. Types: `feat`,
`fix`, `docs`, `refactor`, `test`, `chore`, `perf`. Scope is the area
(`grid`, `filter`, `example`, `docs`). Subject short and imperative. No
trailing period. Name a real symbol when one carries the change.
`Closes #N` in the body when the PR finishes that issue.

**Titles.** Same Conventional Commit form as the primary commit.

**Descriptions.** Briefing, not the lab notebook. A reviewer who has the
diff should learn why the change exists, what is out of scope, and how
you proved it. Sections in order; drop a section when it has nothing to
say:

- `## Why`
- `## Scope`
- `## Tradeoffs`
- `## Blast Radius`
- `## Verification`

Then `Closes #N` / `Refs #N`. Do not use `## Summary` or `## Test plan`
boilerplate.

**Forge.** `gh` is the default. Open ready, never draft (`draft: false`;
omit `--draft`). If it still opens as a draft, `gh pr ready <number>`.

**Copilot.** Do not add `@copilot` as a reviewer. Do not call
`request_copilot_review`. After the PR exists, run `rdg-pr-review-loop`.

**Babysit.** Opening a PR does not start a babysit. Post the URL, then
the review loop. Merge only when James asked to merge.
