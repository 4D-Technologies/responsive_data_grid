part of responsive_data_grid;

class ResponsiveGridInfiniteScrollBodyWidget<TItem extends Object>
    extends StatefulWidget {
  final ResponsiveDataGridState<TItem> gridState;
  final ThemeData theme;

  ResponsiveGridInfiniteScrollBodyWidget(
    Key key,
    this.gridState,
    this.theme,
  ) : super(key: key);

  @override
  State<ResponsiveGridInfiniteScrollBodyWidget<TItem>> createState() =>
      _ResponsiveGridInfiniteScrollBodyWidgetState<TItem>();
}

class _ResponsiveGridInfiniteScrollBodyWidgetState<TItem extends Object>
    extends State<ResponsiveGridInfiniteScrollBodyWidget<TItem>> {
  final _controller = PagingController<int, TItem>(firstPageKey: 1);

  late ListResponse<TItem>? _allItems;
  late int pageSize;

  @override
  void initState() {
    super.initState();

    pageSize = widget.gridState.widget.pageSize;

    if (widget.gridState.widget.items != null) {
      _allItems = ListResponse.fromData(
        data: widget.gridState.widget.items!,
        criteria: widget.gridState.criteria,
        getFieldValue: (fieldName, item) => widget.gridState.widget.columns
            .firstWhere((c) => c.fieldName == fieldName)
            .value(item),
      );
    } else {
      _allItems = null;
    }

    _controller.addPageRequestListener((pageKey) => _fetchPage(pageKey));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  FutureOr<void> _fetchPage(int page) async {
    late int totalCount;
    late List<TItem> items;

    try {
      if (_allItems != null) {
        totalCount = _allItems!.totalCount;
        int start = (page - 1) * pageSize;
        items = _allItems!.items.sublist(
          start,
          math.min(start + pageSize, _allItems!.totalCount),
        );
      } else {
        final result = await widget.gridState.widget.loadData!(
          LoadCriteria(
            skip: (page - 1) * pageSize,
            take: pageSize,
            orderBy: widget.gridState.criteria.orderBy,
            filterBy: widget.gridState.criteria.filterBy,
          ),
        );

        totalCount = result!.totalCount;
        items = result.items;
      }

      final pageCount = (totalCount.toDouble() / pageSize.toDouble()).ceil();
      if (pageCount == page) {
        _controller.appendLastPage(items);
      } else {
        _controller.appendPage(items, page + 1);
      }
    } catch (error) {
      _controller.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final listView = PagedListView<int, TItem>.separated(
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

    if (_allItems != null) {
      return Expanded(child: listView);
    } else {
      return Expanded(
        child: RefreshIndicator(
          child: listView,
          onRefresh: () => Future.sync(() => _controller.refresh()),
        ),
      );
    }
  }
}
