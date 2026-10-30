# Language addenda

Load only the section whose files are in the diff.

## Dart / Flutter

cwd `responsive_data_grid` (or `client_filtering` when that package is
in the diff). `dart analyze` / `flutter analyze` warnings on the delta
are should. Coverage: `dart-collect-coverage` on changed production
Dart when tests exist. Example app lives under
`responsive_data_grid/example`.

## C#

cwd `dotnet`. Microsoft C# naming. Types/methods/properties = PascalCase.
Locals = camelCase. Private instance fields = `_camelCase`. Tests via
`dotnet test ClientFiltering.sln`. Mechanical BUILD is the
orchestrator's job.

## TypeScript

cwd `javascript`. Match existing `src/lib` models. Tests via the
package's `test/` contract tests.
