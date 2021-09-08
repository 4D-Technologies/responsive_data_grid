part of responsive_data_grid;

class ResponsiveDataGridBodyWidget<TItem extends Object>
    extends StatefulWidget {
  final ResponsiveDataGridState<TItem> grid;
  final ThemeData theme;
  final bool scrollable;

  ResponsiveDataGridBodyWidget(
    this.grid,
    this.theme,
    this.scrollable,
  );

  @override
  _ResponsiveDataGridBodyWidgetState<TItem> createState() =>
      _ResponsiveDataGridBodyWidgetState<TItem>();
}

class _ResponsiveDataGridBodyWidgetState<TItem extends Object>
    extends State<ResponsiveDataGridBodyWidget<TItem>> {
  late ScrollController _controller;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        if (widget.grid.isLoading || isRefreshing) return;

        if (_controller.position.extentAfter == 0.0) {
          isRefreshing = true;
          widget.grid.load().then((value) => isRefreshing = false);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listView = Padding(
      padding: widget.grid.widget.padding.copyWith(top: 0, bottom: 0),
      child: ListView.separated(
        controller: _controller,
        separatorBuilder: (context, index) =>
            widget.grid.widget.separatorThickness == null ||
                    widget.grid.widget.separatorThickness == 0.0
                ? Container()
                : Divider(
                    thickness: widget.grid.widget.separatorThickness,
                  ),
        itemCount: widget.grid.items.length,
        shrinkWrap: !widget.scrollable,
        scrollDirection: Axis.vertical,
        physics: widget.grid.widget.scrollPhysics,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: widget.grid.widget.itemTapped == null
                ? null
                : () {
                    if (widget.grid.widget.itemTapped != null) {
                      widget.grid.widget.itemTapped!(widget.grid.items[index]);
                    }
                  },
            enableFeedback: true,
            excludeFromSemantics: false,
            hoverColor: widget.theme.colorScheme.secondary,
            mouseCursor: widget.grid.widget.itemTapped != null
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: Padding(
              padding: widget.grid.widget.contentPadding,
              child: DataGridRowWidget<TItem>(
                widget.grid.items[index],
                widget.grid.columns,
              ),
            ),
          );
        },
      ),
    );

    return widget.scrollable
        ? Expanded(
            child: listView,
          )
        : listView;
  }
}
