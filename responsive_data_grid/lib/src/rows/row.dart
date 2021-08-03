part of responsive_data_grid;

class DataGridRowWidget<TItem extends Object> extends StatelessWidget {
  final TItem item;
  final List<ColumnDefinition<TItem>> columns;

  DataGridRowWidget(this.item, this.columns) {
    assert(TItem != Object);
  }

  @override
  Widget build(BuildContext context) {
    final grid =
        context.findAncestorWidgetOfExactType<ResponsiveDataGrid<TItem>>();

    return BootstrapRow(
      crossAxisAlignment: grid!.rowCrossAxisAlignment,
      children: getColumns(context, item),
      totalSegments: grid.reactiveSegments,
    );
  }

  List<BootstrapCol> getColumns(BuildContext context, TItem item) {
    return columns.map((c) {
      return BootstrapCol(
        child: DataGridFieldWidget(c, item),
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
