# Responsive Data Grid for Flutter and Client Filtering

[![CI](https://github.com/4D-Technologies/responsive_data_grid/actions/workflows/ci.yml/badge.svg)](https://github.com/4D-Technologies/responsive_data_grid/actions/workflows/ci.yml)

This is a group of functionality that makes it easy to implement a data grid within flutter with full Kendo UI style functionality AND provide full client side filtering, order by, take, skip functionliaty that automatically translates to Linq expressions in .NET. (other languages can easily be added).

For more details go to the given project directories for more information.

## Agent / example app setup (Windows, macOS, Linux)

The example app is instrumented with [`flutter_skill`](https://pub.dev/packages/flutter_skill) so an AI agent can screenshot, tap, type, and inspect the running grid. The MCP server is configured in the repo-root `.mcp.json`.

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and put it on your `PATH` so `dart` and `flutter` work in a terminal (`dart` is `dart.bat` on Windows).
2. From the repo root:

```bash
cd responsive_data_grid/example
flutter pub get
```

3. Restart Grok (or your MCP host) so it reloads `.mcp.json`. The `flutter-skill` server is started with:

```text
dart run flutter_skill:flutter_skill server
```

from `responsive_data_grid/example`. That uses the Dart SDK, not the npm `flutter-skill` native binary (which fails to spawn on some machines).

4. Run the example in **debug** (the binding is only registered in debug):

```bash
cd responsive_data_grid/example
flutter run -d macos      # macOS
flutter run -d windows    # Windows
flutter run -d linux      # Linux
```

If the MCP server reports that another instance is already running, delete the stale lock and retry:

- macOS / Linux: `rm ~/.flutter_skill.lock`
- Windows: `del %USERPROFILE%\.flutter_skill.lock`
