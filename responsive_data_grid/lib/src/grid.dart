part of responsive_data_grid;

class ResponsiveDataGrid<TItem extends Object> extends StatefulWidget {
  final Future<LoadResult<TItem>?> Function(LoadCriteria criteria)? loadData;
  final List<TItem>? items;

  final void Function(TItem)? itemTapped;

  final List<ColumnDefinition<TItem, dynamic>> columns;
  final int pageSize;
  final double? height;
  final double? separatorThickness;

  final SortableOptions sortable;
  final bool filterable;

  final ScrollPhysics scrollPhysics;

  final Widget? noResults;

  final CrossAxisAlignment rowCrossAxisAlignment;
  final CrossAxisAlignment headerCrossAxisAlignment;
  final int reactiveSegments;
  final TitleDefinition? title;
  final EdgeInsets padding;
  final EdgeInsets contentPadding;
  final double elevation;

  ResponsiveDataGrid.serverSide({
    GlobalKey<ResponsiveDataGridState<TItem>>? key,
    required Future<LoadResult<TItem>?> Function(LoadCriteria criteria)
        loadData,
    required this.columns,
    this.itemTapped,
    this.separatorThickness,
    this.pageSize = 50,
    this.height,
    this.scrollPhysics = const BouncingScrollPhysics(),
    this.sortable = SortableOptions.none,
    this.filterable = false,
    this.noResults,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.headerCrossAxisAlignment = CrossAxisAlignment.center,
    this.reactiveSegments = 12,
    this.title,
    this.padding = const EdgeInsets.all(5),
    this.contentPadding = const EdgeInsets.all(3),
    this.elevation = 0,
  })  : this.items = null,
        this.loadData = loadData;

  ResponsiveDataGrid.clientSide({
    GlobalKey<ResponsiveDataGridState<TItem>>? key,
    required List<TItem> items,
    required this.columns,
    this.itemTapped,
    this.separatorThickness,
    this.pageSize = 50,
    this.height,
    this.scrollPhysics = const BouncingScrollPhysics(),
    this.sortable = SortableOptions.none,
    this.filterable = false,
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
  })  : this.items = items,
        this.loadData = null;

  @override
  State<StatefulWidget> createState() =>
      ResponsiveDataGridState<TItem>(columns: columns);
}

class ResponsiveDataGridState<TItem extends Object>
    extends State<ResponsiveDataGrid<TItem>> {
  List<FilterCriteria> filterBy = List<FilterCriteria>.empty(growable: true);
  List<OrderCriteria> orderBy = List<OrderCriteria>.empty(growable: true);

  final items = List<TItem>.empty(growable: true);
  final List<ColumnDefinition<TItem, dynamic>> columns;

  bool isLoading = true;
  bool isInitialized = false;
  bool isDisposed = false;

  bool scrollable = true;

  int totalCount = -1;

  ResponsiveDataGridState({required this.columns}) {
    //Validate that everything is setup correctly.
    if (TItem == Object)
      throw UnsupportedError("You must specify a generic type for the grid.");
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((_) async {
      updateAllRules();
      try {
        if (this.isDisposed) return;
        items.clear();
        final result = await _getData(this, 0);
        if (this.isDisposed) return;
        items.addAll(result?.items ?? []);

        if (this.isDisposed) return;

        setState(() {
          totalCount = result?.totalCount ?? 0;
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
    final theme = Theme.of(context);
    final gridTheme = theme.copyWith(
      dataTableTheme: theme.dataTableTheme.copyWith(
        headingRowColor: theme.dataTableTheme.headingRowColor ??
            MaterialStateProperty.all(theme.appBarTheme.backgroundColor),
        headingTextStyle: theme.dataTableTheme.headingTextStyle ??
            theme.primaryTextTheme.headline5!
                .apply(color: theme.primaryColorLight),
      ),
    );

    if (!isInitialized && !isLoading) return Container();

    return LayoutBuilder(
      builder: (context, constraints) {
        scrollable = constraints.hasBoundedHeight || widget.height != null;
        return Theme(
          data: gridTheme,
          child: Padding(
            padding: widget.padding,
            child: Card(
              borderOnForeground: false,
              elevation: widget.elevation,
              margin: EdgeInsets.all(0),
              child: Container(
                height: widget.height,
                child: Column(
                  mainAxisSize:
                      !scrollable ? MainAxisSize.min : MainAxisSize.max,
                  children: [
                    Visibility(
                      child: widget.title == null
                          ? Container()
                          : TitleRow(widget.title!),
                      visible: widget.title != null,
                    ),
                    ResponsiveDataGridHeaderRowWidget(
                        this, this.widget.columns),
                    Visibility(
                      child:
                          ResponsiveDataGridBodyWidget(this, theme, scrollable),
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
              ),
            ),
          ),
        );
      },
    );
  }

  ThemeData mergeTheme(BuildContext context) {
    final theme = Theme.of(context);

    return theme.copyWith(
        dataTableTheme: theme.dataTableTheme.copyWith(
      headingRowColor: MaterialStateProperty.all(theme.accentColor),
      headingTextStyle: theme.textTheme.caption,
    ));
  }

  void updateColumnRules<TValue extends dynamic>(
      ColumnDefinition<TItem, TValue> col) {
    final column = columns.firstWhere((c) => c.fieldName == col.fieldName);

    columns.replaceRange(
        columns.indexOf(column), columns.indexOf(column) + 1, [col]);

    updateOrderByCriteria(col);

    updateAllRules();
    load(clear: true);
  }

  void updateAllRules() {
    filterBy.clear();
    orderBy.clear();
    columns.forEach((c) {
      if (c.header.orderRules.direction != OrderDirections.notSet) {
        orderBy.add(
          OrderCriteria(
              fieldName: c.fieldName, direction: c.header.orderRules.direction),
        );
      }

      if (c.header.filterRules.criteria != null) {
        filterBy.add(c.header.filterRules.criteria!);
      }
    });
  }

  void updateOrderByCriteria<TValue extends dynamic>(
      ColumnDefinition<TItem, TValue> col) {
    if (widget.sortable != SortableOptions.single) return;

    columns
        .where((c) =>
            c != col && c.header.orderRules.direction != OrderDirections.notSet)
        .forEach((c) => c.header.orderRules =
            OrderRules(direction: OrderDirections.notSet));
  }

  Future<void> load({bool clear = false}) async {
    if (!clear && this.items.length >= this.totalCount) return;
    setState(() {
      this.isLoading = true;
    });
    try {
      if (clear) this.items.clear();

      final results = await _getData(this, this.items.length);
      this.items.addAll(results?.items ?? []);
      this.setState(() {
        this.totalCount = results?.totalCount ?? 0;
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
