part of '../../responsive_data_grid.dart';

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
  late final PagingController<int, TItem> _controller = PagingController(
    getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
    fetchPage: (pageKey) => _fetchPage(pageKey),
  );
  late final StreamSubscription<void> _onClearedSub;

  @override
  void initState() {
    super.initState();
    _onClearedSub = widget.gridState._dataCache.onCleared.listen((void v) {
      _controller.refresh();
    });
  }

  @override
  void dispose() {
    _onClearedSub.cancel();
    _controller.dispose();
    super.dispose();
  }

  FutureOr<List<TItem>> _fetchPage(int page) async {
    try {
      _controller.value = _controller.value.copyWith(
        error: null,
        isLoading: true,
      );

      final response = await widget.gridState.fetchPage(page, false);

      final pageCount =
          (widget.gridState._dataCache.totalCount.toDouble() /
                  widget.gridState.widget.pageSize.toDouble())
              .ceil();

      _controller.value = _controller.value.copyWith(
        error: null,
        hasNextPage: page < pageCount,
        isLoading: false,
      );

      return response.items;
    } catch (error) {
      _controller.value = _controller.value.copyWith(
        error: error,
        isLoading: false,
        hasNextPage: false,
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: _controller,
      builder: (context, state, fetchNextPage) =>
          // ignore: deprecated_member_use
          MaterialUiCompatibilityBridge(
            child: PagedListView<int, TItem>.separated(
              state: state,
              fetchNextPage: fetchNextPage,
              separatorBuilder: (context, index) =>
                  widget.gridState.widget.separatorThickness == null ||
                      widget.gridState.widget.separatorThickness == 0.0
                  ? Container()
                  : Divider(
                      thickness: widget.gridState.widget.separatorThickness,
                    ),
              shrinkWrap: false,
              scrollDirection: Axis.vertical,
              padding: widget.gridState.widget.padding.copyWith(
                top: 0,
                bottom: 0,
              ),
              builderDelegate: PagedChildBuilderDelegate(
                noItemsFoundIndicatorBuilder: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.gridState.widget.noResults ??
                        Text("No results found."),
                  ],
                ),
                itemBuilder: (context, item, index) {
                  return DataGridRowWidget<TItem>(
                    item: item,
                    columns: widget.gridState.widget.columns,
                    itemTapped: widget.gridState.widget.itemTapped,
                    theme: widget.theme,
                    padding: widget.gridState.widget.contentPadding,
                  );
                },
              ),
            ),
          ),
    );
  }
}
