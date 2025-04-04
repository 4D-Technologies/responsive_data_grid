part of responsive_data_grid;

class DataGridRowWidget<TItem extends Object> extends StatelessWidget {
  final TItem item;
  final List<GridColumn<TItem, dynamic>> columns;
  final void Function(TItem item)? itemTapped;
  final ThemeData theme;
  final EdgeInsets padding;

  DataGridRowWidget({
    required this.item,
    required this.columns,
    required this.itemTapped,
    required this.theme,
    required this.padding,
  }) {
    assert(TItem != Object);
  }

  @override
  Widget build(BuildContext context) {
    final grid =
        context.findAncestorWidgetOfExactType<ResponsiveDataGrid<TItem>>();

    return InkWell(
      onTap: itemTapped == null
          ? null
          : () {
              if (itemTapped != null) {
                itemTapped!(item);
              }
            },
      enableFeedback: true,
      excludeFromSemantics: false,
      hoverColor:
          theme.dataTableTheme.dataRowColor?.resolve({WidgetState.hovered}) ??
              theme.colorScheme.primary,
      mouseCursor: itemTapped != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: Padding(
        padding: this.padding,
        child: BootstrapRow(
          alignment: WrapAlignment.start,
          runSpacing: grid!.rowSpacing,
          crossAxisAlignment:
              grid.rowCrossAxisAlignment == CrossAxisAlignment.start ||
                      grid.rowCrossAxisAlignment == CrossAxisAlignment.stretch
                  ? WrapCrossAlignment.start
                  : grid.rowCrossAxisAlignment == CrossAxisAlignment.center
                      ? WrapCrossAlignment.center
                      : WrapCrossAlignment.end,
          children: getColumns(context, grid, item),
          totalSegments: grid.reactiveSegments,
        ),
      ),
    );
  }

  List<BootstrapCol> getColumns(
      BuildContext context, ResponsiveDataGrid<TItem> grid, TItem item) {
    return columns.map((c) {
      return BootstrapCol(
        child: Padding(
          padding: EdgeInsets.only(
            left: columns.indexOf(c) == 0 ? 0 : grid.columnSpacing,
          ),
          child: DataGridFieldWidget<TItem, dynamic>(c, item),
        ),
        lg: c.largeCols ?? c.mediumCols ?? c.smallCols ?? c.xsCols ?? 12,
        md: c.mediumCols ?? c.smallCols ?? c.xsCols ?? 12,
        sm: c.smallCols ?? c.xsCols ?? 12,
        xl: c.xlCols ??
            c.largeCols ??
            c.mediumCols ??
            c.smallCols ??
            c.xsCols ??
            12,
        xs: c.xsCols ?? 12,
      );
    }).toList();
  }
}
