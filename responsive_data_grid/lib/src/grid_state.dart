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
  final Set<String> _collapsedGroups = <String>{};

  String groupCollapseKey(GroupResult group, {String path = ''}) =>
      '$path\u0001${group.fieldName}\u0001${group.value ?? ''}';

  bool isGroupCollapsed(GroupResult group, {String path = ''}) =>
      _collapsedGroups.contains(groupCollapseKey(group, path: path));

  void toggleGroupCollapsed(GroupResult group, {String path = ''}) {
    final key = groupCollapseKey(group, path: path);
    setState(() {
      if (!_collapsedGroups.add(key)) {
        _collapsedGroups.remove(key);
      }
    });
  }

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

  void setColumnFrozen(String fieldName, bool frozen) {
    for (final column in widget.columns) {
      if (column.fieldName == fieldName) {
        column.frozen = frozen;
        break;
      }
    }
    setState(() {});
    _notifyState();
  }

  void setColumnSort<TValue>(
    GridColumn<TItem, TValue> column,
    OrderDirections direction,
  ) {
    if (widget.sortable == SortableOptions.none) return;
    column.sortDirection = direction;
    _updateOrderByCriteria(column);
  }

  void autosizeColumn(String fieldName, {required TextStyle style}) {
    GridColumn<TItem, dynamic>? column;
    for (final candidate in widget.columns) {
      if (candidate.fieldName == fieldName) {
        column = candidate;
        break;
      }
    }
    if (column == null) return;
    final painter = TextPainter(
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      maxLines: 1,
      textScaler: MediaQuery.textScalerOf(context),
    );
    var width = 48.0;
    void measure(String text) {
      painter.text = TextSpan(text: text, style: style);
      painter.layout();
      if (painter.width > width) width = painter.width;
    }

    measure(column.header.text ?? fieldName);
    final page = _dataCache.pageMap[pageNumber];
    if (page != null) {
      for (final item in page.items) {
        measure(column.getFormattedValue(item) ?? '');
      }
    }
    painter.dispose();
    setColumnWidth(fieldName, width + 48);
  }

  void setColumnVisible(String fieldName, bool visible) {
    for (final column in widget.columns) {
      if (column.fieldName == fieldName) {
        column.visible = visible;
        break;
      }
    }
    setState(() {});
    _notifyState();
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
    _notifyState();
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
    _notifyState();
  }

  GridStateSnapshot captureState() {
    return GridStateSnapshot(
      pageNumber: pageNumber,
      pageSize: _pageSize,
      criteria: LoadCriteria(
        skip: criteria.skip,
        take: criteria.take,
        filterBy: List.of(criteria.filterBy),
        orderBy: List.of(criteria.orderBy),
        groupBy: criteria.groupBy == null ? null : List.of(criteria.groupBy!),
        aggregates: criteria.aggregates == null
            ? null
            : List.of(criteria.aggregates!),
      ),
      columns: [
        for (final name in _columnOrder)
          for (final column in widget.columns)
            if (column.fieldName == name)
              GridColumnSnapshot(
                fieldName: name,
                visible: column.visible,
                frozen: column.frozen,
                width: column.width,
              ),
      ],
    );
  }

  void restoreState(GridStateSnapshot snapshot) {
    _applySnapshot(snapshot, notify: false);
    Future(() async {
      await _reloadSnapshotPage();
      _notifyState();
    });
  }

  void _applySnapshot(GridStateSnapshot snapshot, {required bool notify}) {
    pageNumber = snapshot.pageNumber < 1 ? 1 : snapshot.pageNumber;
    if (snapshot.pageSize > 0) {
      _pageSize = snapshot.pageSize;
    }
    criteria = snapshot.criteria;
    if (snapshot.columns.isNotEmpty) {
      _columnOrder = [
        for (final column in snapshot.columns) column.fieldName,
      ];
      for (final snap in snapshot.columns) {
        for (final column in widget.columns) {
          if (column.fieldName == snap.fieldName) {
            column.visible = snap.visible;
            column.frozen = snap.frozen;
            column.width = snap.width;
            break;
          }
        }
      }
    }
    for (final column in widget.columns) {
      column.sortDirection = OrderDirections.notSet;
      column.filterRules.criteria = null;
    }
    _applyOrderByToColumns(criteria.orderBy);
    for (final filter in criteria.filterBy) {
      for (final column in widget.columns) {
        if (column.fieldName == filter.fieldName) {
          column.filterRules.criteria = filter;
        }
      }
    }
    if (notify) {
      setState(() {});
      _notifyState();
    }
  }

  void _notifyState() {
    widget.onStateChanged?.call(captureState());
    widget.controller?._emit();
  }

  Future<void> clearFilters() async {
    for (final column in widget.columns) {
      column.filterRules.criteria = null;
    }
    await refreshData();
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
    widget.controller?._attach(this);
    _columnOrder = [for (final c in widget.columns) c.fieldName];
    criteria = _criteriaFromInitial();
    _applyOrderByToColumns(criteria.orderBy);
    if (widget.initialState != null) {
      _applySnapshot(widget.initialState!, notify: false);
      Future(() async {
        await _reloadSnapshotPage();
      });
    } else {
      refreshData();
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _dataCache.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ResponsiveDataGrid<TItem> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }

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
      _notifyState();
    }
  }

  Future<void> _reloadSnapshotPage() async {
    final target = pageNumber;
    setState(() {
      isLoading = true;
      loadError = null;
      _dataCache.clear();
      _loadId++;
    });
    await fetchPage(1, false);
    final pageCount = pagerPageCount(
      totalCount: _dataCache.totalCount,
      pageSize: _pageSize,
    );
    final page = target < 1
        ? 1
        : (pageCount > 0 && target > pageCount ? pageCount : target);
    if (page == 1) {
      if (mounted) setState(() => isLoading = false);
      return;
    }
    await setPage(page);
    if (mounted) setState(() => isLoading = false);
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
          criteria: criteria.copyWith(
            skip: () => _skipForPage(pageNumber),
            take: () => _takeCount,
          ),
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
                      child: Semantics(
                        container: true,
                        label:
                            widget.title?.title ??
                            GridLocalizations.of(context).dataGrid,
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
