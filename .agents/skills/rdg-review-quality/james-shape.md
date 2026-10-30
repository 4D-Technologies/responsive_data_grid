# James Hancock gold standard

In each touched module, `git log` / `git blame` authors matching James
Hancock, JohnGalt1717, and the emails already on those commits are the
local shape. Match neighbors in that folder.

Treat as **should** slop when the delta adds:

- a wrapper/adapter whose only caller is a one-line forward of the same
  signature
- speculative types, options, or hooks the spec does not need
- comment essays, filler layers, duplicate seed/config paths
- a second way to do what the file already does

Analyzer and linter hits are should, not taste.

If the implementer disputes “this is slop” with evidence that the shape
matches James-authored neighbors, mark `disagree` and let the
orchestrator ask James. Do not force a rewrite of taste.
