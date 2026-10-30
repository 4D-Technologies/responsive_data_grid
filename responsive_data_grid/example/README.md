# example

Example for Responsive Data Grid.

The default home is a catalog grouped into Overview, Data, Paging, Height, and Columns. Jump straight to one screen with:

```
flutter run --dart-define=DEMO_SCREEN=paged-fill-tab
```

`DEMO_SCREEN` values:

- Overview: `kitchen-sink`
- Data: `server-side`, `load-error`, `empty`
- Paging: `paging-none`, `paging-auto`
- Height: `paged-fill-tab`, `paged-fill-tall`, `paged-fill-unbounded`, `paged-fill-groups`, `infinite-bounds`, `infinite-unbounded`, `shrink-wrap`
- Columns: `column-types`, `sort-none`, `freeze-visibility`

Kitchen sink: pager, grouping, filters, multi-column sort, and Light / Dark / Branded theme. `flutter-skill` MCP is wired with `cwd` `responsive_data_grid/example` so those screens can be driven as separate apps.
