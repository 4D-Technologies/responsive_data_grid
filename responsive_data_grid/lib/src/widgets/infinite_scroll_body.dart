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
  final _controller = PagingController<int, TItem>(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    widget.gridState._dataCache.onCleared.listen((void v) {
      _controller.refresh();
    });
    _controller.addPageRequestListener((pageKey) => _fetchPage(pageKey));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  FutureOr<void> _fetchPage(int page) async {
    try {
      await widget.gridState.FetchPage(page, false);

      final pageCount = (widget.gridState._dataCache.totalCount.toDouble() /
              widget.gridState.widget.pageSize.toDouble())
          .ceil();
      if (pageCount == page) {
        _controller
            .appendLastPage(widget.gridState._dataCache.pageMap[page]!.items);
      } else {
        _controller.appendPage(
            widget.gridState._dataCache.pageMap[page]!.items, page + 1);
      }
    } catch (error) {
      _controller.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, TItem>.separated(
      pagingController: _controller,
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
    );
  }
}
