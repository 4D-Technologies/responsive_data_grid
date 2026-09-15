part of '../responsive_data_grid.dart';

class ResponsiveDataGridState<TItem extends Object>
    extends State<ResponsiveDataGrid<TItem>> {
  late LoadCriteria criteria;
  int pageNumber = 1;
  late int _pageSize;

  var isLoading = false;
  Object? loadError;
  int _loadId = 0;

  final _dataCache = ResponseCache<TItem>();

  int get _takeCount => widget.pagingMode == PagingMode.none
      ? widget.maximumRows
      : _pageSize;

  int _skipForPage(int page) =>
      widget.pagingMode == PagingMode.none ? 0 : (page - 1) * _pageSize;

  late List<String> _columnOrder;

  List<GridColumn<TItem, dynamic>> get layoutColumns {
    final byName = {for (final c in widget.columns) c.fieldName: c};
    final ordered = <GridColumn<TItem, dynamic>>[
      for (final name in _columnOrder)
        if (byName.containsKey(name) && byName[name]!.visible) byName[name]!,
    ];
    final frozen = ordered.where((c) => c.frozen).toList();
    final rest = ordered.where((c) => !c.frozen).toList();
    return [...frozen, ...rest];
  }

  void setColumnVisible(String fieldName, bool visible) {
    for (final column in widget.columns) {
      if (column.fieldName == fieldName) {
        column.visible = visible;
        break;
      }
    }
    setState(() {});
  }

  void setColumnWidth(String fieldName, double width) {
    for (final column in widget.columns) {
      if (column.fieldName == fieldName) {
        var next = width;
        if (column.minWidth != null && next < column.minWidth!) {
          next = column.minWidth!;
        }
        if (column.maxWidth != null && next > column.maxWidth!) {
          next = column.maxWidth!;
        }
        column.width = next;
        break;
      }
    }
    setState(() {});
  }

  void reorderColumnByField(String fromField, String toField) {
    reorderColumn(_columnOrder.indexOf(fromField), _columnOrder.indexOf(toField));
  }

  void reorderColumn(int from, int to) {
    if (from < 0 || to < 0 || from >= _columnOrder.length) return;
    final last = _columnOrder.length - 1;
    final clampedTo = to < 0 ? 0 : (to > last ? last : to);
    if (from == clampedTo) return;
    final name = _columnOrder.removeAt(from);
    _columnOrder.insert(clampedTo, name);
    setState(() {});
  }

  ResponsiveDataGridState() {
    //Validate that everything is setup correctly.
    if (TItem == Object) {
      throw UnsupportedError("You must specify a generic type for the grid.");
    }
  }

  @override
  initState() {
    super.initState();
    _pageSize = widget.pageSize;
    _columnOrder = [for (final c in widget.columns) c.fieldName];
    criteria = _criteriaFromInitial();
    _applyOrderByToColumns(criteria.orderBy);

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

    if (oldWidget.pageSize != widget.pageSize) {
      _pageSize = widget.pageSize;
    }
    if (_columnsChanged(oldWidget.columns, widget.columns)) {
      _columnOrder = [for (final c in widget.columns) c.fieldName];
    }

    if (_parentRequiresReload(oldWidget)) {
      if (oldWidget.initialLoadCriteria != widget.initialLoadCriteria) {
        final previousInitialOrderBy =
            oldWidget.initialLoadCriteria?.orderBy ?? const <OrderCriteria>[];
        criteria = _criteriaFromInitial();
        if (!_sameOrderBy(previousInitialOrderBy, criteria.orderBy)) {
          _applyOrderByToColumns(
            criteria.orderBy,
            previousInitialOrderBy: previousInitialOrderBy,
          );
        }
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
        orderBy: () => _orderByFromColumns(),
        aggregates: () => widget.columns
            .map((e) => e.aggregations)
            .selectMany((element, index) => element)
            .toList(),
      );

      _dataCache.clear();
      _loadId++;
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
    final current = List<GroupCriteria>.from(
      criteria.groupBy ?? const <GroupCriteria>[],
    )..add(group);
    criteria = criteria.copyWith(groupBy: () => current);
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

  FutureOr<void> setPageSize(int pageSize) async {
    if (pageSize <= 0 || pageSize == _pageSize) return;
    _pageSize = pageSize;
    pageNumber = 1;
    _dataCache.clear();
    _loadId++;
    await refreshData();
  }

  FutureOr<void> setPage(int pageNumber) async {
    if (pageNumber < 1) return;
    final pageCount = pagerPageCount(
      totalCount: _dataCache.totalCount,
      pageSize: _pageSize,
    );
    if (pageCount == 0) {
      if (pageNumber != 1) return;
    } else if (pageNumber > pageCount) {
      return;
    }

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
      orderBy: () => _orderByFromColumns(),
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

    final loadId = _loadId;

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
            ListResponse(totalCount: 0, items: [], groups: [], aggregates: []);
        if (loadId != _loadId) {
          return _dataCache.pageMap[pageNumber] ??
              ListResponse(
                totalCount: 0,
                items: [],
                groups: [],
                aggregates: [],
              );
        }
      } else {
        throw UnsupportedError(
          "Either the items must be specified OR the loadData function must be specified.",
        );
      }

      if (loadId != _loadId) {
        return _dataCache.pageMap[pageNumber] ?? response;
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
    return wrapGridHost(
      context: context,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Card(
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

                    if (widget.allowGrouping &&
                        widget.groupPanel != GroupPanelDisplay.hidden) {
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
                    final columns = layoutColumns;
                    final metrics = gridTableMetrics<TItem>(
                      columns: columns,
                      viewportWidth: constraints.maxWidth,
                      reactiveSegments: widget.reactiveSegments,
                      screenWidth: screenWidth,
                      layoutMode: widget.layoutMode,
                    );
                    final columnWidths = gridColumnPixelWidths<TItem>(
                      columns: columns,
                      contentWidth: metrics.contentWidth,
                      totalSegments: metrics.totalSegments,
                      screenWidth: screenWidth,
                    );
                    final widthSum = columnWidths.fold<double>(
                      0,
                      (sum, width) => sum + width,
                    );
                    final contentWidth = math.max(
                      metrics.contentWidth,
                      widthSum,
                    );
                    final frozenCount = columns
                        .takeWhile((column) => column.frozen)
                        .length;

                    Widget tableBody;
                    if (isLoading) {
                      tableBody = const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else if (loadError != null) {
                      tableBody = Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(GridLocalizations.of(context).loadFailed),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => refreshData(),
                                child: Text(GridLocalizations.of(context).retry),
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
                      contentWidth: contentWidth,
                      totalSegments: metrics.totalSegments,
                      columnWidths: columnWidths,
                      frozenCount: frozenCount,
                      layoutMode: widget.layoutMode,
                      child: Column(
                        mainAxisSize: constraints.hasBoundedHeight
                            ? MainAxisSize.max
                            : MainAxisSize.min,
                        children: [
                          ResponsiveDataGridHeaderRowWidget<TItem>(
                            this,
                            columns,
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
                                  width: contentWidth,
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
                            width: contentWidth,
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
                          setPageSize: isLoading ? null : setPageSize,
                          theme: theme,
                          pageSize: _pageSize,
                          pageSizeOptions: widget.pageSizeOptions,
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
          );
        },
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

  void _applyOrderByToColumns(
    List<OrderCriteria> orderBy, {
    List<OrderCriteria> previousInitialOrderBy = const [],
  }) {
    if (orderBy.isNotEmpty) {
      final fields = {for (final order in orderBy) order.fieldName};
      for (final column in widget.columns) {
        if (!fields.contains(column.fieldName)) {
          column.sortDirection = OrderDirections.notSet;
        }
      }
    } else {
      for (final order in previousInitialOrderBy) {
        for (final column in widget.columns) {
          if (column.fieldName == order.fieldName) {
            column.sortDirection = OrderDirections.notSet;
          }
        }
      }
    }
    for (final order in orderBy) {
      for (final column in widget.columns) {
        if (column.fieldName == order.fieldName) {
          column.sortDirection = order.direction;
        }
      }
    }
  }

  bool _sameOrderBy(List<OrderCriteria> left, List<OrderCriteria> right) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }

  List<OrderCriteria> _orderByFromColumns() {
    final remaining = widget.columns
        .where((c) => c.sortDirection != OrderDirections.notSet)
        .toList();
    final result = <OrderCriteria>[];

    for (final existing in criteria.orderBy) {
      final index = remaining.indexWhere(
        (c) => c.fieldName == existing.fieldName,
      );
      if (index >= 0) {
        final column = remaining.removeAt(index);
        result.add(
          OrderCriteria(
            fieldName: column.fieldName,
            direction: column.sortDirection,
          ),
        );
      }
    }

    for (final column in remaining) {
      result.add(
        OrderCriteria(
          fieldName: column.fieldName,
          direction: column.sortDirection,
        ),
      );
    }
    return result;
  }

  int? sortIndexFor(String fieldName) {
    if (widget.sortable != SortableOptions.multiColumn) return null;
    if (criteria.orderBy.length < 2) return null;
    final index = criteria.orderBy.indexWhere((o) => o.fieldName == fieldName);
    return index < 0 ? null : index + 1;
  }

  void reload() {
    _rebuildAllChildren();
  }
}
