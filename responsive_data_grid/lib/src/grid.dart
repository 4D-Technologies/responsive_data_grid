part of '../responsive_data_grid.dart';

typedef GridDetailBuilder<TItem extends Object> =
    Widget Function(BuildContext context, TItem item);

enum GridDetailExpandMode { single, multiple }

enum GridRowPin { none, top, bottom }

class ResponsiveDataGrid<TItem extends Object> extends StatefulWidget {
  final Future<ListResponse<TItem>?> Function(LoadCriteria criteria)? loadData;
  final List<TItem>? items;

  final void Function(TItem)? itemTapped;

  final List<GridColumn<TItem, dynamic>> columns;
  final LoadCriteria? initialLoadCriteria;
  final GridStateSnapshot? initialState;
  final void Function(GridStateSnapshot state)? onStateChanged;
  final ResponsiveDataGridController<TItem>? controller;
  final int pageSize;
  final List<int> pageSizeOptions;
  final double? height;
  final bool resizable;
  final double? minHeight;
  final double? maxHeight;
  final double? separatorThickness;

  final SortableOptions sortable;

  final Widget? noResults;

  final CrossAxisAlignment rowCrossAxisAlignment;
  final CrossAxisAlignment headerCrossAxisAlignment;
  final int reactiveSegments;
  final GridLayoutMode layoutMode;
  final FilterableMode filterable;
  final TitleDefinition? title;
  final GridToolbar? toolbar;
  final GridRowDecoration<TItem>? rowDecoration;
  final GridCellDecoration<TItem>? cellDecoration;
  final GridDetailBuilder<TItem>? detailBuilder;
  final bool Function(TItem item)? isRowExpandable;
  final GridDetailExpandMode detailExpandMode;
  final Set<TItem>? expandedItems;
  final void Function(Set<TItem> items)? onExpandedChanged;
  /// When true, a drag handle reorders rows on the current page. Disabled
  /// while sorted, grouped, in infinite scroll, or in reflow layout.
  final bool allowRowReorder;

  /// Called after a reorder. [from] and [to] are indices on the current page
  /// (not the full dataset). Client-side already updated page order.
  final void Function(int from, int to, TItem item)? onRowReorder;

  /// Declarative pin. Distinct from [isRowSticky]: pinned rows leave the
  /// scroll flow and park at the top or bottom of the ungrouped pager body.
  /// Ignored in infinite scroll and when grouping is active.
  final GridRowPin Function(TItem item)? rowPin;

  /// When true, the row stays in sort order but sticks to the top of the
  /// scrolling viewport as you scroll past it. Ungrouped pager only.
  final bool Function(TItem item)? isRowSticky;
  final List<GridHeaderGroup>? headerGroups;

  /// When true, visible columns size to their widest header or cell on first
  /// load. Per-column [GridColumn.autoSize] still applies when this is false.
  final bool autoSize;
  final EdgeInsets padding;
  final EdgeInsets contentPadding;
  final double columnSpacing;
  final double rowSpacing;
  final double elevation;
  final PagingMode pagingMode;
  final int maximumRows;

  final int groupIndent;
  final bool allowGrouping;
  final GroupPanelDisplay groupPanel;
  final String? groupPanelHint;
  final bool allowAggregations;
  final void Function(Object error, StackTrace stackTrace)? onLoadError;

  const ResponsiveDataGrid.serverSide({
    GlobalKey<ResponsiveDataGridState<TItem>>? key,
    required Future<ListResponse<TItem>?> Function(LoadCriteria criteria)
    this.loadData,
    required this.columns,
    this.initialLoadCriteria,
    this.initialState,
    this.onStateChanged,
    this.controller,
    this.columnSpacing = 10,
    this.rowSpacing = 2,
    this.itemTapped,
    this.separatorThickness,
    this.pageSize = 50,
    this.pageSizeOptions = const [10, 25, 50, 100],
    this.height,
    this.resizable = false,
    this.minHeight,
    this.maxHeight,
    this.sortable = SortableOptions.single,
    this.noResults,
    this.groupIndent = 15,
    this.allowGrouping = false,
    this.groupPanel = GroupPanelDisplay.collapsed,
    this.groupPanelHint,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.headerCrossAxisAlignment = CrossAxisAlignment.center,
    this.reactiveSegments = 12,
    this.layoutMode = GridLayoutMode.table,
    this.filterable = FilterableMode.menu,
    this.title,
    this.toolbar,
    this.rowDecoration,
    this.cellDecoration,
    this.detailBuilder,
    this.isRowExpandable,
    this.detailExpandMode = GridDetailExpandMode.multiple,
    this.expandedItems,
    this.onExpandedChanged,
    this.allowRowReorder = false,
    this.onRowReorder,
    this.rowPin,
    this.isRowSticky,
    this.headerGroups,
    this.autoSize = false,
    this.padding = const EdgeInsets.all(5),
    this.contentPadding = const EdgeInsets.all(3),
    this.elevation = 0,
    this.pagingMode = PagingMode.auto,
    this.allowAggregations = false,
    this.maximumRows = 99999,
    this.onLoadError,
  }) : items = null,
       super(key: key);

  const ResponsiveDataGrid.clientSide({
    GlobalKey<ResponsiveDataGridState<TItem>>? key,
    required List<TItem> this.items,
    required this.columns,
    this.initialLoadCriteria,
    this.initialState,
    this.onStateChanged,
    this.controller,
    this.groupIndent = 15,
    this.allowGrouping = false,
    this.groupPanel = GroupPanelDisplay.collapsed,
    this.groupPanelHint,
    this.itemTapped,
    this.separatorThickness,
    this.pageSize = 50,
    this.pageSizeOptions = const [10, 25, 50, 100],
    this.height,
    this.resizable = false,
    this.minHeight,
    this.maxHeight,
    this.sortable = SortableOptions.single,
    this.noResults,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.headerCrossAxisAlignment = CrossAxisAlignment.center,
    this.reactiveSegments = 12,
    this.layoutMode = GridLayoutMode.table,
    this.filterable = FilterableMode.menu,
    this.title,
    this.toolbar,
    this.rowDecoration,
    this.cellDecoration,
    this.detailBuilder,
    this.isRowExpandable,
    this.detailExpandMode = GridDetailExpandMode.multiple,
    this.expandedItems,
    this.onExpandedChanged,
    this.allowRowReorder = false,
    this.onRowReorder,
    this.rowPin,
    this.isRowSticky,
    this.headerGroups,
    this.autoSize = false,
    this.padding = const EdgeInsets.all(5),
    this.contentPadding = const EdgeInsets.only(
      left: 10,
      top: 3,
      right: 10,
      bottom: 3,
    ),
    this.columnSpacing = 3,
    this.rowSpacing = 3,
    this.elevation = 0,
    this.pagingMode = PagingMode.auto,
    this.allowAggregations = false,
    this.maximumRows = 99999,
    this.onLoadError,
  }) : loadData = null,
       super(key: key);

  @override
  State<StatefulWidget> createState() => ResponsiveDataGridState<TItem>();
}
