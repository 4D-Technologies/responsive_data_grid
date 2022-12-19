part of responsive_data_grid;

class ResponsiveDataGridState<TItem extends Object>
    extends State<ResponsiveDataGrid<TItem>> {
  late LoadCriteria criteria;
  int pageNumber = 1;

  var isLoading = false;

  var _dataCache = ResponseCache<TItem>();

  ResponsiveDataGridState() {
    //Validate that everything is setup correctly.
    if (TItem == Object)
      throw UnsupportedError("You must specify a generic type for the grid.");
  }

  @override
  initState() {
    criteria = LoadCriteria(
      groupBy: widget.groups,
      skip: 0,
      take: widget.pageSize,
      aggregates: widget.aggregations,
    );
    super.initState();
  }

  FutureOr<void> refreshData() async {
    setState(() => isLoading = true);

    criteria = criteria.copyWith(
      skip: () => (pageNumber - 1) * widget.pageSize,
      take: () => widget.pageSize,
      filterBy: () => widget.columns
          .where((c) => c.filterRules.criteria != null)
          .map((c) => c.filterRules.criteria!)
          .toList(),
      orderBy: () => widget.columns
          .where((c) => c.sortDirection != OrderDirections.notSet)
          .map((e) => OrderCriteria(
                fieldName: e.fieldName,
                direction: e.sortDirection,
              ))
          .toList(),
      groupBy: () => widget.groups,
      aggregates: () => widget.aggregations,
    );

    _dataCache = ResponseCache<TItem>();

    await FetchPage(pageNumber, false);

    setState(() {
      isLoading = false;
    });
  }

  FutureOr<void> addGroup(GroupCriteria group) async {
    widget.groups.add(group);

    await refreshData();
  }

  FutureOr<void> updateGroup(GroupCriteria group) async {
    //Must use the indexWhere because the group has changed so equality won't work.
    final currentIndex =
        widget.groups.indexWhere((g) => g.fieldName == group.fieldName);

    if (currentIndex >= 0) {
      widget.groups.replaceRange(
        currentIndex,
        currentIndex + 1,
        [group],
      );
    }
    await refreshData();
  }

  FutureOr<void> removeGroup(GroupCriteria group) async {
    setState(() => isLoading = true);

    widget.groups.remove(group);

    await refreshData();
  }

  FutureOr<void> setPage(int pageNumber) async {
    setState(() => isLoading = true);

    this.pageNumber = pageNumber;

    criteria = criteria.copyWith(
      skip: () => (pageNumber - 1) * widget.pageSize,
      take: () => widget.pageSize,
      filterBy: () => widget.columns
          .where((c) => c.filterRules.criteria != null)
          .map((c) => c.filterRules.criteria!)
          .toList(),
      orderBy: () => widget.columns
          .where((c) => c.sortDirection != OrderDirections.notSet)
          .map((e) => OrderCriteria(
                fieldName: e.fieldName,
                direction: e.sortDirection,
              ))
          .toList(),
      groupBy: () => widget.groups,
      aggregates: () => widget.aggregations,
    );

    await FetchPage(pageNumber, false);

    setState(() {
      isLoading = false;
    });
  }

  Future<ListResponse<TItem>> FetchPage(
      int pageNumber, bool updateState) async {
    ListResponse<TItem> response;

    if (_dataCache.pageMap.containsKey(pageNumber))
      return _dataCache.pageMap[pageNumber]!;

    if (updateState) {
      setState(() => isLoading = true);
    }

    if (widget.items != null) {
      response = ListResponse.fromData(
        data: widget.items!,
        criteria: criteria,
        getFieldValue: (fieldName, item) => widget.columns
            .firstWhere((c) => c.fieldName == fieldName)
            .value(item),
      );
    } else if (widget.loadData != null) {
      response = await widget.loadData!(
            LoadCriteria(
              skip: (pageNumber - 1) * widget.pageSize,
              take: widget.pageSize,
              orderBy: criteria.orderBy,
              filterBy: criteria.filterBy,
              groupBy: criteria.groupBy,
            ),
          ) ??
          ListResponse(totalCount: 0, items: [], groups: [], aggregates: []);
    } else {
      throw new UnsupportedError(
          "Either the items must be specified OR the loadData function must be specified.");
    }

    if (updateState) {
      setState(() {
        _dataCache.addPage(response, pageNumber);
      });
    } else {
      _dataCache.addPage(response, pageNumber);
    }

    return response;
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

              final parts = List<Widget>.empty(growable: true);
              if (widget.title != null)
                parts.add(
                  TitleRowWidget(widget.title!),
                );

              if (widget.allowGrouping) {
                parts.add(
                  GridGroupChooser<TItem>(
                      gridState: this,
                      theme: theme,
                      addGroup: addGroup,
                      removeGroup: removeGroup,
                      updateGroup: updateGroup),
                );
              }

              parts.add(
                ResponsiveDataGridHeaderRowWidget<TItem>(this, widget.columns),
              );

              parts.add(
                FutureBuilder(
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return GridBody<TItem>(
                      gridState: this,
                      constraints: constraints,
                      pagingMode: pagingMode,
                      gridTheme: theme,
                    );
                  },
                  future: FetchPage(this.pageNumber, false),
                ),
              );

              if (_dataCache.aggregates.isNotEmpty)
                parts.add(
                  GridFooter(_dataCache, this),
                );

              if (pagingMode == PagingMode.pager)
                parts.add(
                  PagerWidget(
                    pageNumber: this.pageNumber,
                    totalCount: _dataCache.totalCount,
                    setPage: setPage,
                    theme: theme,
                    pageSize: widget.pageSize,
                  ),
                );

              return NotificationListener<GridCriteriaChangeNotification>(
                onNotification: (notification) => false,
                child: Column(
                  mainAxisSize: !constraints.hasBoundedHeight
                      ? MainAxisSize.min
                      : MainAxisSize.max,
                  children: parts,
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
    criteria = LoadCriteria();
    widget.columns.forEach((c) {
      if (c.sortDirection != OrderDirections.notSet) {
        criteria.orderBy.add(
          OrderCriteria(fieldName: c.fieldName, direction: c.sortDirection),
        );
      }

      if (c.filterRules.criteria != null) {
        criteria.filterBy.add(c.filterRules.criteria!);
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
