part of '../../responsive_data_grid.dart';

class _GroupedInfiniteEntry<TItem extends Object> {
  final GroupResult group;
  final ListResponse<TItem> page;

  const _GroupedInfiniteEntry({required this.group, required this.page});
}

class ResponsiveGridInfiniteScrollBodyWidget<TItem extends Object>
    extends StatefulWidget {
  final ResponsiveDataGridState<TItem> gridState;
  final ThemeData theme;

  const ResponsiveGridInfiniteScrollBodyWidget({
    super.key,
    required this.gridState,
    required this.theme,
  });

  @override
  State<ResponsiveGridInfiniteScrollBodyWidget<TItem>> createState() =>
      _ResponsiveGridInfiniteScrollBodyWidgetState<TItem>();
}

class _ResponsiveGridInfiniteScrollBodyWidgetState<TItem extends Object>
    extends State<ResponsiveGridInfiniteScrollBodyWidget<TItem>> {
  late final PagingController<int, TItem> _rowController;
  late final PagingController<int, _GroupedInfiniteEntry<TItem>>
  _groupController;
  late final StreamSubscription<void> _onClearedSub;
  late bool _grouped;

  bool get _isGrouped =>
      widget.gridState.criteria.groupBy?.isNotEmpty == true;

  @override
  void initState() {
    super.initState();
    _grouped = _isGrouped;
    _rowController = PagingController(
      getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
      fetchPage: _fetchRows,
    );
    _groupController = PagingController(
      getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
      fetchPage: _fetchGroups,
    );
    _onClearedSub = widget.gridState._dataCache.onCleared.listen((void v) {
      _rowController.refresh();
      _groupController.refresh();
    });
  }

  @override
  void didUpdateWidget(
    covariant ResponsiveGridInfiniteScrollBodyWidget<TItem> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    final grouped = _isGrouped;
    if (grouped != _grouped) {
      _grouped = grouped;
      _rowController.refresh();
      _groupController.refresh();
    }
  }

  @override
  void dispose() {
    _onClearedSub.cancel();
    _rowController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  int _pageCount() {
    final total = widget.gridState._dataCache.totalCount;
    final size = widget.gridState.widget.pageSize;
    if (size <= 0) return 0;
    return (total / size).ceil();
  }

  Future<List<TItem>> _fetchRows(int page) async {
    try {
      _rowController.value = _rowController.value.copyWith(
        error: null,
        isLoading: true,
      );
      final response = await widget.gridState.fetchPage(page, false);
      _rowController.value = _rowController.value.copyWith(
        error: null,
        hasNextPage: page < _pageCount(),
        isLoading: false,
      );
      return response.items;
    } catch (error) {
      _rowController.value = _rowController.value.copyWith(
        error: error,
        isLoading: false,
        hasNextPage: false,
      );
      return [];
    }
  }

  Future<List<_GroupedInfiniteEntry<TItem>>> _fetchGroups(int page) async {
    try {
      _groupController.value = _groupController.value.copyWith(
        error: null,
        isLoading: true,
      );
      final response = await widget.gridState.fetchPage(page, false);
      _groupController.value = _groupController.value.copyWith(
        error: null,
        hasNextPage: page < _pageCount(),
        isLoading: false,
      );
      return [
        for (final group in response.groups)
          _GroupedInfiniteEntry<TItem>(group: group, page: response),
      ];
    } catch (error) {
      _groupController.value = _groupController.value.copyWith(
        error: error,
        isLoading: false,
        hasNextPage: false,
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGrouped) {
      return PagingListener(
        controller: _groupController,
        builder: (context, state, fetchNextPage) =>
            PagedListView<int, _GroupedInfiniteEntry<TItem>>(
                state: state,
                fetchNextPage: fetchNextPage,
                shrinkWrap: false,
                scrollDirection: Axis.vertical,
                padding: widget.gridState.widget.layoutMode == GridLayoutMode.table
                    ? EdgeInsets.zero
                    : widget.gridState.widget.padding.copyWith(
                        top: 0,
                        bottom: 0,
                      ),
                builderDelegate:
                    PagedChildBuilderDelegate<_GroupedInfiniteEntry<TItem>>(
                      noItemsFoundIndicatorBuilder: (context) =>
                          gridNoRecordsBody(widget.gridState),
                      itemBuilder: (context, entry, index) {
                        return GridGroupSection<TItem>(
                          response: entry.page,
                          group: entry.group,
                          items: entry.page.items,
                          depth: 0,
                          path: '',
                          gridState: widget.gridState,
                          theme: widget.theme,
                        );
                      },
                    ),
              ),
      );
    }

    return PagingListener(
      controller: _rowController,
      builder: (context, state, fetchNextPage) =>
          PagedListView<int, TItem>.separated(
              state: state,
              fetchNextPage: fetchNextPage,
              separatorBuilder: (context, index) => gridRowSeparator(
                context,
                widget.gridState.widget.separatorThickness,
              ),
              shrinkWrap: false,
              scrollDirection: Axis.vertical,
              padding: widget.gridState.widget.layoutMode == GridLayoutMode.table
                  ? EdgeInsets.zero
                  : widget.gridState.widget.padding.copyWith(
                      top: 0,
                      bottom: 0,
                    ),
              builderDelegate: PagedChildBuilderDelegate(
                noItemsFoundIndicatorBuilder: (context) =>
                    gridNoRecordsBody(widget.gridState),
                itemBuilder: (context, item, index) {
                  return DataGridRowWidget<TItem>(
                    item: item,
                    columns: widget.gridState.layoutColumns,
                    itemTapped: widget.gridState.widget.itemTapped,
                    theme: widget.theme,
                    padding: widget.gridState.widget.contentPadding,
                  );
                },
              ),
            ),
    );
  }
}
