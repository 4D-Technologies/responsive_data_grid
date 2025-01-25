part of responsive_data_grid;

class ResponsiveDataGridHeaderRowWidget<TItem extends Object>
    extends StatelessWidget {
  final ResponsiveDataGridState<TItem> grid;
  final List<GridColumn<TItem, dynamic>> columns;

  ResponsiveDataGridHeaderRowWidget(this.grid, this.columns) {
    assert(TItem != Object);
  }

  @override
  Widget build(BuildContext context) {
    final grid = this.grid.widget;

    final theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final backgroundColor = theme.dataTableTheme.headingRowColor
            ?.resolve(WidgetState.values.toSet()) ??
        (colorScheme.brightness == Brightness.dark
            ? colorScheme.secondary
            : colorScheme.secondaryContainer);

    final foregroundColor = theme.dataTableTheme.headingTextStyle?.color ??
        (colorScheme.brightness == Brightness.dark
            ? colorScheme.onSurface
            : colorScheme.onPrimary);

    final iconTheme = theme.iconTheme.copyWith(color: foregroundColor);

    return IconTheme(
      data: iconTheme,
      child: Container(
        color: backgroundColor,
        margin: grid.padding,
        child: Padding(
          padding: grid.contentPadding,
          child: BootstrapRow(
            children: getColumnHeaders(context, grid),
            crossAxisAlignment: grid.headerCrossAxisAlignment ==
                        CrossAxisAlignment.start ||
                    grid.headerCrossAxisAlignment == CrossAxisAlignment.stretch
                ? WrapCrossAlignment.start
                : grid.headerCrossAxisAlignment == CrossAxisAlignment.center
                    ? WrapCrossAlignment.center
                    : WrapCrossAlignment.end,
            totalSegments: grid.reactiveSegments,
          ),
        ),
      ),
    );
  }

  List<BootstrapCol> getColumnHeaders(
      BuildContext context, ResponsiveDataGrid<TItem> grid) {
    return columns
        .map(
          (c) => BootstrapCol(
            child: Padding(
              padding: EdgeInsets.only(
                  left: columns.indexOf(c) == 0 ? 0 : grid.columnSpacing),
              child: c.getHeader(this.grid),
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
          ),
        )
        .toList();
  }
}
