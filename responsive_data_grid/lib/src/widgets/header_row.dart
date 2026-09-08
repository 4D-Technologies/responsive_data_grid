part of '../../responsive_data_grid.dart';

class ResponsiveDataGridHeaderRowWidget<TItem extends Object>
    extends StatelessWidget {
  final ResponsiveDataGridState<TItem> grid;
  final List<GridColumn<TItem, dynamic>> columns;

  ResponsiveDataGridHeaderRowWidget(this.grid, this.columns, {super.key}) {
    assert(TItem != Object);
  }

  @override
  Widget build(BuildContext context) {
    final grid = this.grid.widget;

    final theme = Theme.of(context);
    final gridTheme = ResponsiveDataGridTheme.of(context);

    final iconTheme = theme.iconTheme.copyWith(
      color: gridTheme.headerForeground,
    );

    return IconTheme(
      data: iconTheme,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gridTheme.headerBackground,
          border: Border(
            bottom: BorderSide(
              color: gridTheme.borderColor,
              width: gridTheme.borderWidth,
            ),
          ),
        ),
        child: Padding(
          padding: gridTheme.resolvePadding(grid.contentPadding),
          child: BootstrapRow(
            children: getColumnHeaders(context, grid),
            crossAxisAlignment:
                grid.headerCrossAxisAlignment == CrossAxisAlignment.start ||
                    grid.headerCrossAxisAlignment == CrossAxisAlignment.stretch
                ? WrapCrossAlignment.start
                : grid.headerCrossAxisAlignment == CrossAxisAlignment.center
                ? WrapCrossAlignment.center
                : WrapCrossAlignment.end,
            totalSegments:
                GridTableLayout.maybeOf(context)?.totalSegments ??
                grid.reactiveSegments,
          ),
        ),
      ),
    );
  }

  List<BootstrapCol> getColumnHeaders(
    BuildContext context,
    ResponsiveDataGrid<TItem> grid,
  ) {
    return columns
        .map(
          (c) => BootstrapCol(
            child: Padding(
              padding: EdgeInsets.only(
                left: columns.indexOf(c) == 0 ? 0 : grid.columnSpacing,
              ),
              child: c.getHeader(this.grid),
            ),
            lg: c.largeCols ?? c.mediumCols ?? c.smallCols ?? c.xsCols ?? 12,
            md: c.mediumCols ?? c.smallCols ?? c.xsCols ?? 12,
            sm: c.smallCols ?? c.xsCols ?? 12,
            xl:
                c.xlCols ??
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
