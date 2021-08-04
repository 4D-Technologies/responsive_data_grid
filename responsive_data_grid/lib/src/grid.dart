part of responsive_data_grid;

class ResponsiveDataGrid<TItem extends Object> extends StatefulWidget {
  final Future<LoadResult<TItem>?> Function(LoadCriteria) loadData;

  final void Function(TItem)? itemTapped;

  final List<ColumnDefinition<TItem>> columns;
  final int pageSize;
  final double? height;

  final SortableOptions sortable;
  final bool filterable;

  final ThemeData? columnTheme;
  final ThemeData? headerTheme;

  final Widget? noResults;

  final CrossAxisAlignment rowCrossAxisAlignment;
  final CrossAxisAlignment headerCrossAxisAlignment;
  final int reactiveSegments;

  ResponsiveDataGrid({
    GlobalKey<ResponsiveDataGridState<TItem>>? key,
    required this.loadData,
    required this.columns,
    this.itemTapped,
    this.pageSize = 50,
    this.height,
    this.columnTheme,
    this.sortable = SortableOptions.none,
    this.filterable = false,
    this.headerTheme,
    this.noResults,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.headerCrossAxisAlignment = CrossAxisAlignment.center,
    this.reactiveSegments = 12,
  }) : super(key: key) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() => ResponsiveDataGridState<TItem>();
}

class ResponsiveDataGridState<TItem extends Object>
    extends State<ResponsiveDataGrid<TItem>> {
  List<FilterCriteria> filterBy = List<FilterCriteria>.empty(growable: true);
  List<OrderCriteria> orderBy = List<OrderCriteria>.empty(growable: true);

  late List<TItem> items;
  late List<ColumnDefinition<TItem>> columns;

  bool isLoading = true;
  bool isInitialized = false;
  bool isDisposed = false;

  int totalCount = 0;

  ResponsiveDataGridState() {
    assert(TItem != Object);
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    items = List<TItem>.empty(growable: true);
    columns = widget.columns;
    isLoading = true;
    isInitialized = false;
    totalCount = 0;
    filterBy = List<FilterCriteria>.empty(growable: true);
    orderBy = List<OrderCriteria>.empty(growable: true);

    SchedulerBinding.instance?.addPostFrameCallback((_) async {
      updateAllRules();
      try {
        final result = await this.widget.loadData(
              LoadCriteria(
                skip: 0,
                take: this.widget.pageSize,
                orderBy: this.orderBy,
                filterBy: this.filterBy,
              ),
            );

        if (this.isDisposed) return;
        setState(() {
          items.clear();
          items.addAll(result?.items ?? []);
          isLoading = false;
          isInitialized = true;
        });
      } on Exception catch (e) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(LocalizedMessages.applicationError),
            content: SelectableText(e.toString()),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.check),
                label: Text(LocalizedMessages.ok),
              )
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = mergeTheme(context);

    if (!isInitialized && !isLoading) return Container();

    return Theme(
        data: theme,
        child: Container(
          height: widget.height,
          child: Column(
            mainAxisSize:
                widget.height == null ? MainAxisSize.min : MainAxisSize.max,
            children: [
              ResponsiveDataGridHeaderRowWidget(this, this.widget.columns),
              Visibility(
                child: ResponsiveDataGridBodyWidget(this, theme),
                visible: isInitialized,
              ),
              Visibility(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [CircularProgressIndicator()],
                  ),
                ),
                visible: isInitialized && isLoading,
              ),
            ],
          ),
        ));
  }

  ThemeData mergeTheme(BuildContext context) => Theme.of(context);

  void updateColumnRules(ColumnDefinition<TItem> col) {
    updateOrderByCriteria(col);

    updateAllRules();
    load();
  }

  void updateAllRules() {
    columns.where((c) => c.fieldName != null).forEach((c) {
      if (c.header.orderRules.direction != OrderDirections.notSet) {
        orderBy.add(OrderCriteria(
            fieldName: c.fieldName!, direction: c.header.orderRules.direction));
      }

      if (c.header.filterRules.criteria != null) {
        filterBy.add(c.header.filterRules.criteria!);
      }
    });
  }

  void updateOrderByCriteria(ColumnDefinition<TItem> col) {
    if (widget.sortable != SortableOptions.single) return;

    columns
        .where((c) =>
            c != col && c.header.orderRules.direction != OrderDirections.notSet)
        .forEach((c) => c.header.orderRules =
            OrderRules(direction: OrderDirections.notSet));
  }

  Future<void> load({bool clear = false}) async {
    setState(() {
      this.isLoading = true;
    });
    try {
      final results = await this.widget.loadData(LoadCriteria(
          skip: this.items.length,
          take: this.widget.pageSize,
          filterBy: this.filterBy,
          orderBy: this.orderBy));
      this.setState(() {
        if (clear) this.items.clear();
        this.items.addAll(results?.items ?? []);
        this.isLoading = false;
      });
    } on Exception catch (e) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(LocalizedMessages.applicationError),
          content: Text(e.toString()),
          actions: [
            TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.check),
                label: Text("Ok"))
          ],
        ),
      );
    }
  }
}

class GridTheme {
  final GridHeaderTheme header;

  GridTheme({required this.header});

  factory GridTheme.fromContext(BuildContext context) {
    return GridTheme(header: GridHeaderTheme.fromContext(context));
  }

  ThemeData getThemeData() {
    return ThemeData();
  }
}

class GridHeaderTheme {
  final Color backgroundColor;
  final Color color;

  GridHeaderTheme({required this.backgroundColor, required this.color});

  factory GridHeaderTheme.fromContext(BuildContext context) {
    final theme = Theme.of(context);
    return GridHeaderTheme(
        backgroundColor: theme.primaryColorDark, color: theme.primaryColor);
  }
}
