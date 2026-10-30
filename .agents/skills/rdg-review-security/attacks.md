# Security attack catalog

Apply every row whose surface exists in the diff. Cite file:line.

## Untrusted data

- `loadData` / `serverSide` criteria that concatenate strings into
  queries, URLs, or HTML.
- Cell `customBody` / `WidgetColumn` that interpolates row values into
  `Html`, `Uri.parse` of user text, or `eval`.
- Export / clipboard of selection that includes hidden columns or
  fields the host marked non-copyable.

## Web / XSS

- `innerHtml`, `dart:html` `document.write`, or `IFrame` with row
  content.
- `javascript:` or `data:` URLs from formatted cell values.

## PII / logs

- `debugPrint` / `print` of full row payloads, tokens, or credentials
  in example or library code.
- Error overlays that echo raw `loadData` exceptions containing
  Authorization headers or other users' ids.

## Authz (host-owned, still flag)

- Example `loadData` that ignores skip/take and returns the full
  dataset to the client when the spec said server-side paging.
- New public APIs that take a row id and return data without the same
  visibility rules as the grid's current page.

## Secrets in tree

- Hard-coded API keys, passwords, or `.mcp.json` dart-defines with
  live tokens.
- Publishing `pubspec.yaml` that pulls a path override to a private
  package.
