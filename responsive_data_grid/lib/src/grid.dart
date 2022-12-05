part of responsive_data_grid;

class ResponsiveDataGrid<TItem extends Object> extends StatefulWidget {
  final Future<SimpleListResponse<TItem>?> Function(LoadCriteria criteria)?
      loadData;
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
    required Future<SimpleListResponse<TItem>?> Function(LoadCriteria criteria)
        loadData,
    required this.columns,
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
        this.loadData = null;

  @override
  State<StatefulWidget> createState() => ResponsiveDataGridState<TItem>();
}

class ResponsiveDataGridState<TItem extends Object>
    extends State<ResponsiveDataGrid<TItem>> {
  var _criteria = LoadCriteria();

  late ValueKey<LoadCriteria> pagerKey;

  @override
  initState() {
    pagerKey = ValueKey(_criteria);

    super.initState();
  }

  ResponsiveDataGridState() {
    //Validate that everything is setup correctly.
    if (TItem == Object)
      throw UnsupportedError("You must specify a generic type for the grid.");
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

    return Theme(
      data: gridTheme,
      child: Card(
        borderOnForeground: false,
        elevation: widget.elevation,
        margin: widget.padding,
        child: Container(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              late PagingMode pagingMode;

              if (widget.pagingMode == PagingMode.auto) {
                pagingMode = constraints.hasBoundedHeight
                    ? PagingMode.infiniteScroll
                    : PagingMode.pager;
              } else {
                pagingMode = widget.pagingMode;
              }

              if (pagingMode == PagingMode.infiniteScroll &&
                  !constraints.hasBoundedHeight)
                throw UnsupportedError(
                    "The grid cannot be scrolled and as a result pagingModel = PagingMode.infiniteScroll cannot be supported. Please use auto or pager.");

              return NotificationListener<GridCriteriaChangeNotification>(
                onNotification: (notification) => false,
                child: Column(
                  mainAxisSize: !constraints.hasBoundedHeight
                      ? MainAxisSize.min
                      : MainAxisSize.max,
                  children: [
                    Visibility(
                      child: widget.title == null
                          ? Container()
                          : TitleRowWidget(widget.title!),
                      visible: widget.title != null,
                    ),
                    ResponsiveDataGridHeaderRowWidget(
                        this, this.widget.columns),
                    pagingMode == PagingMode.infiniteScroll
                        ? ResponsiveGridInfiniteScrollBodyWidget(
                            ValueKey(_criteria),
                            this,
                            theme,
                          )
                        : pagingMode == PagingMode.none
                            ? ResponsiveDataGridPagedBodyWidget(
                                this,
                                theme,
                                _applyCriteria(this),
                                constraints.hasBoundedHeight,
                              )
                            : PagerWidget(
                                ValueKey(_criteria),
                                this,
                                theme,
                              ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  void _updateAllRules() {
    _criteria = LoadCriteria();
    widget.columns.forEach((c) {
      if (c.sortDirection != OrderDirections.notSet) {
        _criteria.orderBy.add(
          OrderCriteria(fieldName: c.fieldName, direction: c.sortDirection),
        );
      }

      if (c.filterRules.criteria != null) {
        _criteria.filterBy.add(c.filterRules.criteria!);
      }
    });

    _rebuildAllChildren(context);
  }

  void _updateOrderByCriteria<TValue extends dynamic>(
      GridColumn<TItem, TValue> col) {
    if (widget.sortable == SortableOptions.single) {
      //Remove all other orders becuase only one is allowed at a time.
      widget.columns
          .where((c) => c != col && c.sortDirection != OrderDirections.notSet)
          .forEach(
            (c) => c.sortDirection = OrderDirections.notSet,
          );
    }

    _updateAllRules();
  }

  void reload() {
    _rebuildAllChildren(context);
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
