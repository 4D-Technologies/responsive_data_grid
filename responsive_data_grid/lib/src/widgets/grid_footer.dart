part of '../../responsive_data_grid.dart';

class GridFooter<TItem extends Object> extends StatelessWidget {
  final ResponseCache<TItem> data;
  final ResponsiveDataGridState<TItem> gridState;
  final ThemeData theme;

  GridFooter(this.data, this.gridState, this.theme, {super.key}) {
    assert(TItem != Object);
  }

  @override
  Widget build(BuildContext context) {
    final gridTheme = ResponsiveDataGridTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gridTheme.pager.background,
          border: Border(
            top: BorderSide(
              color: gridTheme.chrome.borderColor,
              width: gridTheme.chrome.borderWidth,
            ),
          ),
        ),
        child: Padding(
          padding: _footerPadding(context, gridTheme),
          child: _footerCells(context, gridTheme),
        ),
      ),
    );
  }

  EdgeInsets _footerPadding(
    BuildContext context,
    ResponsiveDataGridTheme gridTheme,
  ) {
    final resolved = gridTheme.resolvePadding(gridTheme.pager.padding);
    final layout = GridTableLayout.maybeOf(context);
    if (layout != null && layout.layoutMode == GridLayoutMode.table) {
      return EdgeInsets.only(top: resolved.top, bottom: resolved.bottom);
    }
    return resolved;
  }

  Widget _footerCells(
    BuildContext context,
    ResponsiveDataGridTheme gridTheme,
  ) {
    final layout = GridTableLayout.maybeOf(context);
    final columns = gridState.layoutColumns;
    if (layout != null && layout.layoutMode == GridLayoutMode.table) {
      return GridTableRow(
        cells: [
          for (final column in columns) _footerCell(context, column, columns),
        ],
        widths: layout.columnWidths,
        frozenCount: layout.frozenCount,
        frozenBackground: gridTheme.pager.background,
      );
    }
    return BootstrapRow(
      textDirection: Directionality.of(context),
      horizontalSpacing: gridState.widget.columnSpacingOf(gridTheme),
      crossAxisAlignment:
          gridState.widget.rowCrossAxisAlignment == CrossAxisAlignment.start ||
              gridState.widget.rowCrossAxisAlignment ==
                  CrossAxisAlignment.stretch
          ? WrapCrossAlignment.start
          : gridState.widget.rowCrossAxisAlignment == CrossAxisAlignment.center
          ? WrapCrossAlignment.center
          : WrapCrossAlignment.end,
      children: getColumns(context),
      totalSegments: layout?.totalSegments ?? gridState.widget.reactiveSegments,
    );
  }

  Widget _footerCell(
    BuildContext context,
    GridColumn<TItem, dynamic> column,
    List<GridColumn<TItem, dynamic>> columns,
  ) {
    final gridTheme = ResponsiveDataGridTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: columns.indexOf(column) == 0
            ? 0
            : gridState.widget.columnSpacingOf(gridTheme),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: data.aggregates
            .where((g) => g.fieldName == column.fieldName && g.result != null)
            .map(
              (agg) => Text(
                "${agg.aggregation}: ${agg.formatResult()}",
                style: gridTheme.pager.textStyle.copyWith(
                  color: gridTheme.pager.foreground,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  List<BootstrapCol> getColumns(BuildContext context) {
    final columns = gridState.layoutColumns;
    final gridTheme = ResponsiveDataGridTheme.of(context);
    return columns.map((c) {
      return BootstrapCol(
        child: Padding(
          padding: EdgeInsets.only(
            left: columns.indexOf(c) == 0
                ? 0
                : gridState.widget.columnSpacingOf(gridTheme),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: data.aggregates
                .where((g) => g.fieldName == c.fieldName && g.result != null)
                .map(
                  (agg) => Text(
                    "${agg.aggregation}: ${agg.formatResult()}",
                    style: gridTheme.pager.textStyle.copyWith(
                      color: gridTheme.pager.foreground,
                    ),
                  ),
                )
                .toList(),
          ),
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
      );
    }).toList();
  }
}
