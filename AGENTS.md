# responsive_data_grid

Binding contract for this repository.

## How a PR is opened

Skill `rdg-open-pr`. Conventional Commits. Open ready, never draft. Then
run `rdg-pr-review-loop`.

## How a PR is reviewed

Skill `rdg-pr-review-loop` (+ `rdg-review-security` / `rdg-review-quality`).
Never assign `@copilot` as a reviewer. That assignment starts Copilot
code review. Do not use the bundled `/review` skill or
`request_copilot_review` for PRs in this repo.

The GitHub issue named by the PR is the spec. James Hancock is the court
on slop disputes.

## MUSTS

1. **Anti-slop** — no filler layers, no wrappers whose only caller is a
   one-line forward of the same signature, no speculative hooks.
2. **Anti-complexity** — smallest change that matches existing patterns.
3. **Evidence first** — prove with `dart analyze` / `flutter test` in the
   package that changed (`responsive_data_grid/`, `client_filtering/`,
   `dotnet/`, `javascript/`).
4. **Dart naming** — types UpperCamelCase, members lowerCamelCase, files
   snake_case.
