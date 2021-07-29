part of responsive_data_grid;

class DataGridHeaderRowWidget<TItem extends dynamic> extends StatelessWidget {
  final DataGridState<TItem> grid;
  final List<ColumnDefinition<TItem>> columns;

  DataGridHeaderRowWidget(this.grid, this.columns) {
    assert(TItem != dynamic);
  }

  @override
  Widget build(BuildContext context) {
    final grid = context.findAncestorWidgetOfExactType<DataGrid<TItem>>();

    return Container(
      color: Theme.of(context).primaryColorDark,
      margin: EdgeInsets.only(
        bottom: 5,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: BootstrapRow(
          children: getColumnHeaders(context),
          crossAxisAlignment: grid!.headerCrossAxisAlignment,
          totalSegments: grid.reactiveSegments,
        ),
      ),
    );
  }

  List<BootstrapCol> getColumnHeaders(BuildContext context) {
    return columns
        .map((c) => BootstrapCol(
              child: !c.header.empty
                  ? ColumnHeaderWidget<TItem>(grid, c)
                  : Container(),
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
            ))
        .toList();
  }
}
