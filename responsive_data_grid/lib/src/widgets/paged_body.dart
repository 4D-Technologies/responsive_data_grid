part of responsive_data_grid;

class ResponsiveDataGridPagedBodyWidget<TItem extends Object>
    extends StatelessWidget {
  final ResponsiveDataGridState<TItem> grid;
  final ThemeData theme;
  final List<TItem> items;
  final bool scroll;

  ResponsiveDataGridPagedBodyWidget(
      this.grid, this.theme, this.items, this.scroll);

  @override
  Widget build(BuildContext context) {
    final child = ListView.separated(
      separatorBuilder: (context, index) =>
          grid.widget.separatorThickness == null ||
                  grid.widget.separatorThickness == 0.0
              ? Container()
              : Divider(
                  thickness: grid.widget.separatorThickness,
                ),
      shrinkWrap: !scroll,
      scrollDirection: Axis.vertical,
      physics: !scroll
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      padding: grid.widget.padding.copyWith(top: 0, bottom: 0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return DataGridRowWidget<TItem>(
          item,
          grid.widget.columns,
          grid.widget.itemTapped,
          theme,
          grid.widget.contentPadding,
        );
      },
    );

    return scroll
        ? Expanded(
            child: child,
          )
        : child;
  }
}
