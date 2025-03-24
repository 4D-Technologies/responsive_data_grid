part of responsive_data_grid;

class ResponsiveGridInfiniteScrollBodyWidget<TItem extends Object>
    extends StatefulWidget {
  final ResponsiveDataGridState<TItem> gridState;
  final ThemeData theme;

  ResponsiveGridInfiniteScrollBodyWidget({
    Key? key,
    required this.gridState,
    required this.theme,
  }) : super(key: key);

  @override
  State<ResponsiveGridInfiniteScrollBodyWidget<TItem>> createState() =>
      _ResponsiveGridInfiniteScrollBodyWidgetState<TItem>();
}

class _ResponsiveGridInfiniteScrollBodyWidgetState<TItem extends Object>
    extends State<ResponsiveGridInfiniteScrollBodyWidget<TItem>> {
  late final PagingController<int, TItem> _controller = PagingController(
      getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
      fetchPage: (pageKey) => _fetchPage(pageKey));

  @override
  void initState() {
    super.initState();
    widget.gridState._dataCache.onCleared.listen((void v) {
      _controller.refresh();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  FutureOr<List<TItem>> _fetchPage(int page) async {
    try {
      _controller.value = _controller.value.copyWith(
        error: null,
        isLoading: true,
      );

      final response = await widget.gridState.FetchPage(page, false);

      final pageCount = (widget.gridState._dataCache.totalCount.toDouble() /
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
          PagedListView<int, TItem>.separated(
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
        padding: widget.gridState.widget.padding.copyWith(top: 0, bottom: 0),
        builderDelegate: PagedChildBuilderDelegate(
          noItemsFoundIndicatorBuilder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.gridState.widget.noResults ?? Text("No results found."),
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
    );
  }
}
