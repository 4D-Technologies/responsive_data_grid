part of responsive_data_grid;

class ResponsiveDataGrid<TItem extends Object> extends StatefulWidget {
  final Future<LoadResult<TItem>?> Function(LoadCriteria criteria)? loadData;
  final List<TItem>? items;

  final void Function(TItem)? itemTapped;

  final List<GridColumn<TItem, dynamic>> columns;
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

  ResponsiveDataGrid.serverSide({
    GlobalKey<ResponsiveDataGridState<TItem>>? key,
    required Future<LoadResult<TItem>?> Function(LoadCriteria criteria)
        loadData,
    required this.columns,
    this.itemTapped,
    this.separatorThickness,
    this.pageSize = 50,
    this.height,
    this.sortable = SortableOptions.none,
    this.noResults,
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
        this.loadData = loadData;

  ResponsiveDataGrid.clientSide({
    GlobalKey<ResponsiveDataGridState<TItem>>? key,
    required List<TItem> items,
    required this.columns,
    this.itemTapped,
    this.separatorThickness,
    this.pageSize = 50,
    this.height,
    this.sortable = SortableOptions.none,
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
  final List<GridColumn<TItem, dynamic>> columns;
  final _reloadSubject = BehaviorSubject<List<TItem>>();

  late bool scrollable;
  late PagingMode pagingMode;
  late double?
      height; //This will be used once we figure out how, to maintain the same height when using paging.

  bool isDisposed = false;

  int totalCount = -1;

  ResponsiveDataGridState({required this.columns}) {
    //Validate that everything is setup correctly.
    if (TItem == Object)
      throw UnsupportedError("You must specify a generic type for the grid.");
  }

  @override
  void dispose() {
    isDisposed = true;
    _reloadSubject.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    scrollable = widget.height != null ||
        context.findAncestorWidgetOfExactType<Scrollable>() == null;

    if (!scrollable && widget.pagingMode == PagingMode.infiniteScroll)
      throw UnsupportedError(
          "The grid cannot be scrolled and as a result pagingModel = PagingMode.infiniteScroll cannot be supported. Please use auto or pager.");
    if (widget.pagingMode == PagingMode.auto) {
      pagingMode = scrollable ? PagingMode.infiniteScroll : PagingMode.pager;
    } else {
      pagingMode = widget.pagingMode;
    }

    height = widget.height;
  }

  Stream<List<TItem>> get onReload => _reloadSubject.stream.asBroadcastStream();

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

    return Theme(
      data: gridTheme,
      child: Padding(
        padding: widget.padding,
        child: Card(
          borderOnForeground: false,
          elevation: widget.elevation,
          margin: EdgeInsets.all(0),
          child: Container(
            height: height,
            child: FutureBuilder(
              future: _load(clear: true),
              builder: (context, snapshot) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      mainAxisSize:
                          !scrollable ? MainAxisSize.min : MainAxisSize.max,
                      children: [
                        Visibility(
                          child: widget.title == null
                              ? Container()
                              : TitleRowWidget(widget.title!),
                          visible: widget.title != null,
                        ),
                        ResponsiveDataGridHeaderRowWidget(
                            this, this.widget.columns),
                        ResponsiveDataGridBodyWidget(this, theme, scrollable,
                            snapshot.connectionState != ConnectionState.done),
                        Visibility(
                          child: PagerWidget(this),
                          visible: pagingMode == PagingMode.pager,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  ThemeData mergeTheme(BuildContext context) {
    final theme = Theme.of(context);

    return theme.copyWith(
        dataTableTheme: theme.dataTableTheme.copyWith(
      headingRowColor: MaterialStateProperty.all(theme.colorScheme.secondary),
      headingTextStyle: theme.textTheme.caption,
    ));
  }

  void _updateAllRules() {
    filterBy.clear();
    orderBy.clear();
    columns.forEach((c) {
      if (c.sortDirection != OrderDirections.notSet) {
        orderBy.add(
          OrderCriteria(fieldName: c.fieldName, direction: c.sortDirection),
        );
      }

      if (c.filterRules.criteria != null) {
        filterBy.add(c.filterRules.criteria!);
      }
    });
  }

  Future<void> _updateOrderByCriteria<TValue extends dynamic>(
      GridColumn<TItem, TValue> col) {
    if (widget.sortable == SortableOptions.single) {
      //Remove all other orders becuase only one is allowed at a time.
      columns
          .where((c) => c != col && c.sortDirection != OrderDirections.notSet)
          .forEach(
            (c) => c.sortDirection = OrderDirections.notSet,
          );
    }

    return _load(clear: true);
  }

  Future<void> setPage(int page) =>
      _load(clear: true, skip: (page - 1) * widget.pageSize);

  Future<void> _load({bool clear = false, int? skip}) async {
    if (!clear && this.items.length >= this.totalCount) return;

    try {
      if (clear) {
        this.items.clear();
        _updateAllRules();
      }

      final results = await _getData(this, skip ?? this.items.length);
      this.items.addAll(results?.items ?? []);
      totalCount = results?.totalCount ?? 0;
      if (clear) _reloadSubject.sink.add(this.items);
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
