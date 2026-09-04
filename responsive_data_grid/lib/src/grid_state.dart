part of '../responsive_data_grid.dart';

class ResponsiveDataGridState<TItem extends Object>
    extends State<ResponsiveDataGrid<TItem>> {
  late LoadCriteria criteria;
  int pageNumber = 1;

  var isLoading = false;
  Object? loadError;

  final _dataCache = ResponseCache<TItem>();

  int get _takeCount => widget.pagingMode == PagingMode.none
      ? widget.maximumRows
      : widget.pageSize;

  int _skipForPage(int page) =>
      widget.pagingMode == PagingMode.none ? 0 : (page - 1) * widget.pageSize;

  ResponsiveDataGridState() {
    //Validate that everything is setup correctly.
    if (TItem == Object) {
      throw UnsupportedError("You must specify a generic type for the grid.");
    }
  }

  @override
  initState() {
    super.initState();
    criteria = _criteriaFromInitial();

    refreshData();
  }

  @override
  void dispose() {
    _dataCache.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ResponsiveDataGrid<TItem> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_parentRequiresReload(oldWidget)) {
      if (oldWidget.initialLoadCriteria != widget.initialLoadCriteria) {
        criteria = _criteriaFromInitial();
      }
      refreshData();
    }
  }

  bool _parentRequiresReload(ResponsiveDataGrid<TItem> oldWidget) {
    return !identical(oldWidget.items, widget.items) ||
        oldWidget.loadData != widget.loadData ||
        oldWidget.initialLoadCriteria != widget.initialLoadCriteria ||
        oldWidget.pageSize != widget.pageSize ||
        oldWidget.pagingMode != widget.pagingMode ||
        oldWidget.maximumRows != widget.maximumRows ||
        _columnsChanged(oldWidget.columns, widget.columns);
  }

  bool _columnsChanged(
    List<GridColumn<TItem, dynamic>> oldColumns,
    List<GridColumn<TItem, dynamic>> newColumns,
  ) {
    if (identical(oldColumns, newColumns)) return false;
    if (oldColumns.length != newColumns.length) return true;
    for (var i = 0; i < newColumns.length; i++) {
      if (oldColumns[i].fieldName != newColumns[i].fieldName) return true;
    }
    return false;
  }

  LoadCriteria _criteriaFromInitial() {
    return widget.initialLoadCriteria?.copyWith(
          take: () => widget.initialLoadCriteria!.take ?? _takeCount,
          groupBy: () =>
              widget.initialLoadCriteria!.groupBy ??
              List<GroupCriteria>.empty(growable: true),
          aggregates: () =>
              widget.initialLoadCriteria!.aggregates ??
              List<AggregateCriteria>.empty(growable: true),
        ) ??
        LoadCriteria(
          skip: 0,
          take: _takeCount,
          aggregates: widget.columns
              .map((e) => e.aggregations)
              .selectMany((element, index) => element)
              .toList(),
        );
  }

  Future<void> updateFilterCriteria(
    List<FilterCriteria<dynamic>> filterCriteria,
  ) async {
    for (final filter in filterCriteria) {
      for (final column in widget.columns) {
        if (column.fieldName == filter.fieldName) {
          column.filterRules.criteria = filter;
        }
      }
    }

    await refreshData();
  }

  FutureOr<void> refreshData() async {
    setState(() {
      isLoading = true;
      loadError = null;
      criteria = criteria.copyWith(
        skip: () => _skipForPage(pageNumber),
        take: () => _takeCount,
        filterBy: () => widget.columns
            .where((c) => c.filterRules.criteria != null)
            .map((c) => c.filterRules.criteria!)
            .toList(),
        orderBy: () => widget.columns
            .where((c) => c.sortDirection != OrderDirections.notSet)
            .map(
              (e) => OrderCriteria(
                fieldName: e.fieldName,
                direction: e.sortDirection,
              ),
            )
            .toList(),
        aggregates: () => widget.columns
            .map((e) => e.aggregations)
            .selectMany((element, index) => element)
            .toList(),
      );

      _dataCache.clear();
    });

    try {
      await setPage(1);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  FutureOr<void> addGroup(GroupCriteria group) async {
    criteria.groupBy!.add(group);

    await refreshData();
  }

  FutureOr<void> updateGroup(GroupCriteria group) async {
    //Must use the indexWhere because the group has changed so equality won't work.
    final currentIndex = criteria.groupBy!.indexWhere(
      (g) => g.fieldName == group.fieldName,
    );

    if (currentIndex >= 0) {
      criteria.groupBy!.replaceRange(currentIndex, currentIndex + 1, [group]);
    }
    await refreshData();
  }

  FutureOr<void> removeGroup(GroupCriteria group) async {
    setState(() => isLoading = true);

    criteria.groupBy!.remove(group);

    await refreshData();
  }

  FutureOr<void> setPage(int pageNumber) async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    this.pageNumber = pageNumber;

    criteria = criteria.copyWith(
      skip: () => _skipForPage(pageNumber),
      take: () => _takeCount,
      filterBy: () => widget.columns
          .where((c) => c.filterRules.criteria != null)
          .map((c) => c.filterRules.criteria!)
          .toList(),
      orderBy: () => widget.columns
          .where((c) => c.sortDirection != OrderDirections.notSet)
          .map(
            (e) => OrderCriteria(
              fieldName: e.fieldName,
              direction: e.sortDirection,
            ),
          )
          .toList(),
      aggregates: () => widget.columns
          .map((e) => e.aggregations)
          .selectMany((element, index) => element)
          .toList(),
    );

    try {
      await fetchPage(pageNumber, false);
    } catch (error) {
      loadError = error;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<ListResponse<TItem>> fetchPage(
    int pageNumber,
    bool updateState,
  ) async {
    ListResponse<TItem> response;

    if (_dataCache.pageMap.containsKey(pageNumber)) {
      return _dataCache.pageMap[pageNumber]!;
    }

    if (updateState) {
      setState(() => isLoading = true);
    }

    try {
      if (widget.items != null) {
        response = ListResponse.fromData(
          data: widget.items!,
          criteria: criteria,
          getFieldValue: (fieldName, item) => widget.columns
              .firstWhere((c) => c.fieldName == fieldName)
              .value(item),
        );
      } else if (widget.loadData != null) {
        response =
            await widget.loadData!(
              criteria.copyWith(
                skip: () => _skipForPage(pageNumber),
                take: () => _takeCount,
              ),
            ) ??
            ListResponse(
              totalCount: 0,
              items: [],
              groups: [],
              aggregates: [],
            );
      } else {
        throw UnsupportedError(
          "Either the items must be specified OR the loadData function must be specified.",
        );
      }

      if (updateState) {
        setState(() {
          _dataCache.addPage(response, pageNumber);
        });
      } else {
        _dataCache.addPage(response, pageNumber);
      }

      return response;
    } catch (error, stackTrace) {
      widget.onLoadError?.call(error, stackTrace);
      rethrow;
    } finally {
      if (updateState && mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gridTheme = theme;

    return Theme(
      data: gridTheme,
      child: Card(
        borderOnForeground: false,
        elevation: widget.elevation,
        child: Padding(
          padding: widget.padding,
          child: SizedBox(
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
                    !constraints.hasBoundedHeight) {
                  throw UnsupportedError(
                    "The grid cannot be scrolled and as a result pagingModel = PagingMode.infiniteScroll cannot be supported. Please use auto or pager.",
                  );
                }

                final parts = List<Widget>.empty(growable: true);
                if (widget.title != null) {
                  parts.add(TitleRowWidget(widget.title!));
                }

                if (widget.allowGrouping) {
                  parts.add(
                    GridGroupChooser<TItem>(
                      gridState: this,
                      theme: theme,
                      addGroup: addGroup,
                      removeGroup: removeGroup,
                      updateGroup: updateGroup,
                    ),
                  );
                }

                final screenWidth = MediaQuery.sizeOf(context).width;
                final metrics = gridTableMetrics<TItem>(
                  columns: widget.columns,
                  viewportWidth: constraints.maxWidth,
                  reactiveSegments: widget.reactiveSegments,
                  screenWidth: screenWidth,
                );

                Widget tableBody;
                if (isLoading) {
                  tableBody = const Center(child: CircularProgressIndicator());
                } else if (loadError != null) {
                  tableBody = Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(LocalizedMessages.loadFailed),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => refreshData(),
                            child: Text(LocalizedMessages.retry),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  tableBody = GridBody<TItem>(
                    gridState: this,
                    constraints: constraints,
                    pagingMode: pagingMode,
                    gridTheme: theme,
                  );
                }

                final table = GridTableLayout(
                  contentWidth: metrics.contentWidth,
                  totalSegments: metrics.totalSegments,
                  child: Column(
                    mainAxisSize: constraints.hasBoundedHeight
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    children: [
                      ResponsiveDataGridHeaderRowWidget<TItem>(
                        this,
                        widget.columns,
                      ),
                      if (constraints.hasBoundedHeight)
                        Expanded(child: tableBody)
                      else
                        tableBody,
                      if (_dataCache.aggregates.isNotEmpty)
                        GridFooter(_dataCache, this, theme),
                    ],
                  ),
                );

                if (constraints.hasBoundedHeight) {
                  parts.add(
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, inner) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: metrics.contentWidth,
                              height: inner.maxHeight,
                              child: table,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  parts.add(
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: metrics.contentWidth,
                        child: table,
                      ),
                    ),
                  );
                }

                if (pagingMode == PagingMode.pager) {
                  parts.add(
                    PagerWidget(
                      pageNumber: pageNumber,
                      totalCount: _dataCache.totalCount,
                      setPage: setPage,
                      theme: theme,
                      pageSize: widget.pageSize,
                    ),
                  );
                }

                return NotificationListener<GridCriteriaChangeNotification>(
                  onNotification: (notification) {
                    refreshData();
                    return true;
                  },
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
      ),
    );
  }

  void _rebuildAllChildren() {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  void _updateAllRules() {
    refreshData();
    GridCriteriaChangeNotification().dispatch(context);
  }

  void _updateOrderByCriteria<TValue extends dynamic>(
    GridColumn<TItem, TValue> col,
  ) {
    if (widget.sortable == SortableOptions.single) {
      //Remove all other orders becuase only one is allowed at a time.
      widget.columns
          .where((c) => c != col && c.sortDirection != OrderDirections.notSet)
          .forEach((c) => c.sortDirection = OrderDirections.notSet);
    }

    _updateAllRules();
  }

  void reload() {
    _rebuildAllChildren();
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
      backgroundColor: theme.primaryColorDark,
      color: theme.primaryColor,
    );
  }
}
