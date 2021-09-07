part of responsive_data_grid;

class ResponsiveDataGridHeaderRowWidget<TItem extends Object>
    extends StatelessWidget {
  final ResponsiveDataGridState<TItem> grid;
  final List<ColumnDefinition<TItem>> columns;

  ResponsiveDataGridHeaderRowWidget(this.grid, this.columns) {
    assert(TItem != Object);
  }

  @override
  Widget build(BuildContext context) {
    final grid =
        context.findAncestorWidgetOfExactType<ResponsiveDataGrid<TItem>>();

    final theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final backgroundColor = theme.dataTableTheme.headingRowColor
            ?.resolve(MaterialState.values.toSet()) ??
        (colorScheme.brightness == Brightness.dark
            ? colorScheme.secondary
            : colorScheme.secondaryVariant);

    final foregroundColor = theme.dataTableTheme.headingTextStyle?.color ??
        (colorScheme.brightness == Brightness.dark
            ? colorScheme.onSurface
            : colorScheme.onPrimary);

    final iconTheme = theme.iconTheme.copyWith(color: foregroundColor);

    return IconTheme(
      data: iconTheme,
      child: Container(
        color: backgroundColor,
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
      ),
    );
  }

  List<BootstrapCol> getColumnHeaders(BuildContext context) {
    return columns
        .map(
          (c) => BootstrapCol(
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
          ),
        )
        .toList();
  }
}
