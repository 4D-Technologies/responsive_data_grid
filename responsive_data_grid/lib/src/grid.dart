part of responsive_data_grid;

class ResponsiveDataGrid<TItem extends Object> extends StatefulWidget {
  final Future<ListResponse<TItem>?> Function(LoadCriteria criteria)? loadData;
  final List<TItem>? items;

  final void Function(TItem)? itemTapped;

  final List<GridColumn<TItem, dynamic>> columns;
  final List<GroupCriteria> groups;
  final List<AggregateCriteria> aggregations;
  final int pageSize;
  final double? height;
  final double? separatorThickness;

  final SortableOptions sortable;

  final Widget? noResults;

  final CrossAxisAlignment rowCrossAxisAlignment;
  final CrossAxisAlignment headerCrossAxisAlignment;
  final int reactiveSegments;
  final TitleDefinition? title;
  final EdgeInsets padding;
  final EdgeInsets contentPadding;
  final double elevation;
  final PagingMode pagingMode;
  final int maximumRows;

  final int groupIndent;
  final bool allowGrouping;

  ResponsiveDataGrid.serverSide({
    GlobalKey<ResponsiveDataGridState<TItem>>? key,
    required Future<ListResponse<TItem>?> Function(LoadCriteria criteria)
        loadData,
    required this.columns,
    List<GroupCriteria>? groups,
    List<AggregateCriteria>? aggregations,
    this.itemTapped,
    this.separatorThickness,
    this.pageSize = 50,
    this.height,
    this.sortable = SortableOptions.single,
    this.noResults,
    this.groupIndent = 15,
    this.allowGrouping = false,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.headerCrossAxisAlignment = CrossAxisAlignment.center,
    this.reactiveSegments = 12,
    this.title,
    this.padding = const EdgeInsets.all(5),
    this.contentPadding = const EdgeInsets.all(3),
    this.elevation = 0,
    this.pagingMode = PagingMode.auto,
    this.maximumRows = 99999,
  })  : this.items = null,
        this.loadData = loadData,
        this.groups = groups ?? List<GroupCriteria>.empty(growable: true),
        this.aggregations =
            aggregations ?? List<AggregateCriteria>.empty(growable: true);

  ResponsiveDataGrid.clientSide({
    GlobalKey<ResponsiveDataGridState<TItem>>? key,
    required List<TItem> items,
    required this.columns,
    List<GroupCriteria>? groups,
    this.groupIndent = 15,
    this.allowGrouping = false,
    List<AggregateCriteria>? aggregations,
    this.itemTapped,
    this.separatorThickness,
    this.pageSize = 50,
    this.height,
    this.sortable = SortableOptions.single,
    this.noResults,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.headerCrossAxisAlignment = CrossAxisAlignment.center,
    this.reactiveSegments = 12,
    this.title,
    this.padding = const EdgeInsets.all(5),
    this.contentPadding = const EdgeInsets.only(
      left: 10,
      top: 3,
      right: 10,
      bottom: 3,
    ),
    this.elevation = 0,
    this.pagingMode = PagingMode.auto,
    this.maximumRows = 99999,
  })  : this.items = items,
        this.loadData = null,
        this.groups = groups ?? List<GroupCriteria>.empty(growable: true),
        this.aggregations =
            aggregations ?? List<AggregateCriteria>.empty(growable: true);

  @override
  State<StatefulWidget> createState() => ResponsiveDataGridState<TItem>();
}
