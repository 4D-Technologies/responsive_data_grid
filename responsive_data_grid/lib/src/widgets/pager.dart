part of responsive_data_grid;

class PagerWidget<TItem extends Object> extends StatefulWidget {
  final ResponsiveDataGridState<TItem> gridState;
  PagerWidget(this.gridState);

  @override
  State<PagerWidget<TItem>> createState() => _PagerWidgetState<TItem>();
}

class _PagerWidgetState<TItem extends Object>
    extends State<PagerWidget<TItem>> {
  late int pages;
  int currentPage = 1;

  void initState() {
    super.initState();

    pages = (widget.gridState.totalCount.toDouble() /
            widget.gridState.widget.pageSize.toDouble())
        .ceil();
  }

  Future<void> setPage(int page) {
    setState(() => currentPage = page);
    return widget.gridState.setPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
          onPressed: currentPage == pages
              ? null
              : () => setPage(math.min(pages, currentPage + 1)),
          icon: Icon(
            Icons.fast_forward,
          ),
        ),
        IconButton(
          onPressed: () => setPage(pages),
          icon: Icon(
            Icons.last_page,
          ),
        ),
      ],
    );
  }
}
