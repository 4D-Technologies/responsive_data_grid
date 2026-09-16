# Change Log

## Unreleased

- Columns can be `sticky`: they keep their place in the order and stay visible while the table scrolls horizontally, pinning to the start or end of the viewport only as they would otherwise leave view. Frozen columns still lock to the leading edge.
- Optional `rowDecoration` and `cellDecoration` callbacks for per-row and per-cell `BoxDecoration`.
- RTL: `Directionality.rtl` places columns from the start and pins frozen columns to the visual start. Numeric/date cells default to end alignment.
- Table mode virtualizes off-screen columns (120px overscan). Frozen columns stay mounted.
- Body loading/error overlay the grid instead of replacing it, so height stays stable. Infinite scroll no longer uses `MaterialUiCompatibilityBridge`. Large paged lists virtualize rows (`ListView.builder`).
- Optional `GridToolbar` for search, column chooser, refresh, density, and export. Built-ins appear only when enabled.
- `ResponsiveDataGridController` refreshes, pages, clears filters, and captures state without a `GlobalKey`.
- `GridStateSnapshot` captures and restores page, page size, criteria, and column visibility/order/width/frozen via `captureState` / `restoreState` / `initialState` / `onStateChanged`.
- Headers, cells, pager buttons, and rows expose Semantics. Enter/Space activate a focused row; Enter on a sortable header toggles sort.
- Grouped pager bodies pin the current group header while its rows scroll; the next group header replaces it.
- Infinite scroll keeps group headers, nested groups, and group footers. Grouped pages load incrementally (client-side groups are paged as groups; servers should return the same).
- Groups expand/collapse, nested headers indent with `groupIndent`, and group membership matches DateTime/enum/num values without relying only on `toString()`.
- `FilterableMode` adds an always-visible filter row (`row` / `menuAndRow`) that shares `FilterCriteria` with the column menu.
- Filter menus show type-appropriate operators including null/empty. Multiple column filters combine with AND unless a clause sets `Operators.or`.
- Column menu adds sort, pin left, hide, and autosize alongside filter/aggregates, and scrolls on small screens.
- Grid chrome uses `GridLocalizations` (English and Spanish). Hosts add `GridLocalizations.delegate` and can switch locale; dates/numbers follow `Intl.defaultLocale`.
- Columns can be hidden (`visible`), frozen (`frozen`), resized (`width` / `setColumnWidth`), and reordered (`reorderColumn`). Frozen columns stay in view while the rest of the table scrolls.
- Pager shows compact page numbers that collapse with width, `1–50 of N` range text, and an optional page-size selector (`pageSizeOptions`). First/last stay disabled on empty data and never navigate to page 0.
- Table layout is the default (`GridLayoutMode.table`): one shared column geometry, sticky header while the body scrolls, and horizontal scroll that moves header, body, and footers together. `GridLayoutMode.reflow` restores bootstrap wrapping for card/form layouts.
- Empty grids show themed "No records available." chrome (`GridNoRecords`); `noResults` remains the full template override. Empty-state text uses the body color, not header foreground.
- Replacing or clearing `initialLoadCriteria.orderBy` no longer keeps stale column sorts; filter-only criteria updates keep extra clicked sorts.
- `SortableOptions.multiColumn` keeps click order in `orderBy`, uses `thenBy` for later columns, and shows 1-based sort indexes when two or more columns are sorted.
- Header cells use Kendo-like padding, compact sort/menu actions, and a column divider so the next label does not collide with the menu.
- `ResponsiveDataGridTheme` adds per-element tokens (header actions, dividers, title, pager, footer padding) and `ColumnHeader` can override padding, icon size, and action colors.
- The grid resolves chrome under both `MaterialApp` (`fromTheme`) and `CupertinoApp` (`fromCupertino`) via `material_ui` / `cupertino_ui`.
- Grouping UI is a labeled Kendo-style "Group by" panel (`GroupPanelDisplay.always`, `.collapsed`, or `.hidden`) with contrasting chips; grouping is also available from the column menu.

## [1.0.3] - September 3rd, 2026

- Fix date/time filters after `date_field` 7.
- Use `material_ui` for Material types (`TimeOfDay`, `InputDecoration`, icons) without taking a `cupertino_ui` dependency.
- Keep shared Flutter widgets (`Column`, `Text`, layout) from `flutter/widgets` via `material_ui`.
- Bridge `infinite_scroll_pagination` (still on SDK Material) with `MaterialUiCompatibilityBridge`.

## [1.0.2] - March 24th, 2025

- Update to infinite scroll 5.0.0

## [1.0.1] - February 14th, 2025

- Significant updates and improvements with breaking changes to formatting and a few other areas.
- Enables infinite scrolling on non-grouped grids.

## [0.0.25] - May 18th, 2022

- Update to Dart 2.17
- Update to Flutter 3.0.0

## [0.0.24] - April 19th, 2022

- Update to Dart 2.16
- Update to Flutter 2.10
- Update Github repro address
- Fix issue with latest Bootstrap_grid.

## [0.0.21] - September 10th, 2021

1. Added Pager control with paging functionality instead of just infinite scroll. Does not have the page numbers, just forward and back for now. Next step will be adding them.
2. Added pagerMode property that defaults to automatic which prefers infinite scroll, but in cases where there is unbounded height it will automatically use the pager and size the grid according to the contents.
3. Added pagerMode = none which will pull all of the data from the source up to the maxItems property.
4. Added serverSide and clientSide constructors that allow you to define how you're going to use the grid. Server mode pulls data as before using the loadData() method, whereas clientSide provides a list of items to be used.
5. Enabled client side full filtering and ordering when using a in memory list for the contents of the grid.
6. Improved filter types to include clear options.
7. Fixed a number of stubtle issues with generics.
8. Added InfiniteScollingList and updated the infinite scrolling functionality to use it with all of it's abilities which makes hte scrolling much smoother when getting from the data source, and handles errors better.
9. Refactored Columns to be explicit types to fix a series of issues with Dart not being able to infer column typing properly from what was put in. Added EnumColumn which allows you to quickly create a column that can filter on the values of an enum.
10. Depends on Dart 2.14 for better enum functionality (Enum can now be a constraint on generics!)
11. Updated to Flutter 2.5 implicitly, but still only depends on Flutter 2.2.
12. Updated linting to the new flutter 2.5 linting functionality.
13. Add Widget column type to pass in a hard coded widget quickly.

## [0.0.13] - September 7th, 2021

1. Added the remaining filter types and ensured that custom filters are possible. Cleaned up the entire filter process.
2. Fixed an issue with order by
3. Fixed multiple filter issue.
4. Made FieldName required.

## [0.0.12] - August 11th, 2021

1. Improved scrolling functionality so that the grid will scale automatically to whatever content there is, unless the height parameter is specified or it reaches the totality of the parent's height. If the grid is in a scrollable it will not itself scroll as this would cause an infinite height. Instead it will allow the parent scrollable to scroll and be the full size unless the height property is specified in which case there is a defined total height and it will then allow internal scrolling inside the parent scrollable.
2. Enabled scroll physics as an option on the grid that defaults to Bouncing.
3. Enable row divider option by setting separatorThickness. (Null = none)
4. Add Title support with themeing based on the appbar by default but you can override it.
5. Add elevation support - Give the grid a drop shadow
6. Add padding support - Add the grid in it's parent.
7. Added support for the DataTableTheme within theming so that all elements follow the same rules for styling by default as the DataTableTheme that you have assigned on your MaterialApp.
8. Added textStyle properties to both the header and the fields so that you can override the values on a case by case basis.

## [0.0.7]

- Updated to use client_filtering shared library

## [0.0.2]

- Changed LoadResult.items to List<TItem>

## [0.0.1]

- Initial commit of Responsive Data Grid
