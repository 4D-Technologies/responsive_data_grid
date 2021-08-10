part of responsive_data_grid;

class ResponsiveDataGridBodyWidget<TItem extends Object>
    extends StatelessWidget {
  final ResponsiveDataGridState<TItem> grid;
  final ThemeData theme;
  final bool scrollable;

  ResponsiveDataGridBodyWidget(
    this.grid,
    this.theme,
    this.scrollable,
  );

  @override
  Widget build(BuildContext context) {
    final listView = ListView.separated(
      separatorBuilder: (context, index) =>
          grid.widget.separatorThickness == null ||
                  grid.widget.separatorThickness == 0.0
              ? Container()
              : Divider(
                  thickness: grid.widget.separatorThickness,
                ),
      itemCount: grid.items.length,
      shrinkWrap: !scrollable,
      scrollDirection: Axis.vertical,
      physics: grid.widget.scrollPhysics,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: grid.widget.itemTapped == null
              ? null
              : () {
                  if (grid.widget.itemTapped != null) {
                    grid.widget.itemTapped!(grid.items[index]);
                  }
                },
          enableFeedback: true,
          excludeFromSemantics: false,
          hoverColor: theme.colorScheme.secondary,
          mouseCursor: grid.widget.itemTapped != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Padding(
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: DataGridRowWidget<TItem>(
              grid.items[index],
              grid.columns,
            ),
          ),
        );
      },
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (grid.isLoading ||
            scrollInfo.metrics.pixels != scrollInfo.metrics.maxScrollExtent ||
            scrollInfo.metrics.maxScrollExtent == 0.0) {
          return true;
        }

        grid.load();
        return true;
      },
      child: scrollable ? Expanded(child: listView) : listView,
    );
  }
}
