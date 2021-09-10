part of responsive_data_grid;

class PagerWidget<TItem extends Object> extends StatefulWidget {
  final ResponsiveDataGridState<TItem> gridState;
  final ThemeData theme;

  PagerWidget(
    Key key,
    this.gridState,
    this.theme,
  ) : super(key: key);

  @override
  State<PagerWidget<TItem>> createState() => PagerWidgetState<TItem>();
}

class PagerWidgetState<TItem extends Object> extends State<PagerWidget<TItem>> {
  late int pageSize;

  int pageCount = -1;
  int currentPage = 1;
  bool isLoading = true;

  final pageCache = Map<int, List<TItem>>();
  List<TItem> pageItems = List<TItem>.empty();

  void initState() {
    super.initState();

    reload();
  }

  void reload() {
    pageSize = widget.gridState.widget.pageSize;

    if (widget.gridState.widget.items != null) {
      //load everything into the page cache
      final items = _applyCriteria(widget.gridState);
      pageCount = (items.length.toDouble() / pageSize.toDouble()).ceil();

      for (int page = 1; page <= pageCount; page++) {
        int start = (page - 1) * pageSize;

        pageCache[page] =
            items.sublist(start, math.min(start + pageSize, items.length));
      }
    }
  }

  Future<void> setPage(int page) async {
    setState(() => isLoading = true);

    if (pageCache.containsKey(page)) {
      pageItems = pageCache[page]!;
    } else {
      final result = await widget.gridState.widget.loadData!(
        LoadCriteria(
          skip: (page - 1) * pageSize,
          take: pageSize,
          orderBy: widget.gridState._criteria.orderBy,
          filterBy: widget.gridState._criteria.filterBy,
        ),
      );

      pageCount = (result!.totalCount.toDouble() / pageSize.toDouble()).ceil();
      pageItems = result.items;
      pageCache[page] = pageItems;
    }

    setState(() {
      currentPage = page;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: constraints.hasBoundedHeight
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              children: [CircularProgressIndicator()],
            ),
          );

        return Flexible(
          fit: FlexFit.loose,
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: constraints.hasBoundedHeight
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              children: [
                ResponsiveDataGridPagedBodyWidget(
                  widget.gridState,
                  widget.theme,
                  pageItems,
                  constraints.hasBoundedHeight,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setPage(1),
                      icon: Icon(
                        Icons.first_page,
                      ),
                    ),
                    IconButton(
                      onPressed: currentPage == 1
                          ? null
                          : () => setPage(
                                math.max(1, currentPage - 1),
                              ),
                      icon: Icon(
                        Icons.fast_rewind,
                      ),
                    ),
                    Spacer(),
                    Spacer(),
                    IconButton(
                      onPressed: currentPage == pageCount
                          ? null
                          : () => setPage(math.min(pageCount, currentPage + 1)),
                      icon: Icon(
                        Icons.fast_forward,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setPage(pageCount),
                      icon: Icon(
                        Icons.last_page,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      future: setPage(currentPage),
    );
  }
}
