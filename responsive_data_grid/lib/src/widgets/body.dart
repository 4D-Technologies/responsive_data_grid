part of responsive_data_grid;

class ResponsiveDataGridBodyWidget<TItem extends Object>
    extends StatefulWidget {
  final ResponsiveDataGridState<TItem> grid;
  final ThemeData theme;
  final bool scrollable;
  final bool loading;

  ResponsiveDataGridBodyWidget(
    this.grid,
    this.theme,
    this.scrollable,
    this.loading,
  );

  @override
  _ResponsiveDataGridBodyWidgetState<TItem> createState() =>
      _ResponsiveDataGridBodyWidgetState<TItem>();
}

class _ResponsiveDataGridBodyWidgetState<TItem extends Object>
    extends State<ResponsiveDataGridBodyWidget<TItem>> {
  late ScrollController _controller;
  late StreamSubscription<List<TItem>> _reloads;

  bool isRefreshing = false;

  @override
  void initState() {
    _reloads = widget.grid.onReload.listen((event) {
      setState(() {}); //Force a reload
    });
    super.initState();
    isRefreshing = widget.loading;

    _controller = ScrollController()
      ..addListener(() async {
        if (isRefreshing) return;
        if (_controller.offset >= _controller.position.maxScrollExtent &&
            !_controller.position.outOfRange) {
          setState(() => isRefreshing = true);
          await widget.grid._load();

          setState(() => isRefreshing = false);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _reloads.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stack = Stack(
      fit: StackFit.passthrough,
      children: [
        ListView.separated(
          controller: widget.scrollable ? _controller : null,
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
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: widget.grid.widget.itemTapped == null
                  ? null
                  : () {
                      if (widget.grid.widget.itemTapped != null) {
                        widget
                            .grid.widget.itemTapped!(widget.grid.items[index]);
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
        Visibility(
          visible: isRefreshing,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize:
                widget.scrollable ? MainAxisSize.min : MainAxisSize.min,
            mainAxisAlignment: widget.loading
                ? MainAxisAlignment.center
                : MainAxisAlignment.end,
            children: [CircularProgressIndicator()],
          ),
        ),
      ],
    );

    final child = Padding(
      padding: widget.grid.widget.padding.copyWith(top: 0, bottom: 0),
      child: RefreshIndicator(
        child: stack,
        onRefresh: refresh,
        notificationPredicate: (notification) => true,
      ),
    );

    return widget.scrollable
        ? Expanded(
            child: child,
          )
        : child;
  }

  Future<void> refresh() async {
    await widget.grid._load(clear: true);
    setState(() {});
  }
}
