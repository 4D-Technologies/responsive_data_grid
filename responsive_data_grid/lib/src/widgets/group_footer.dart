part of '../../responsive_data_grid.dart';

class GridGroupFooter<TItem extends Object> extends StatelessWidget {
  final GroupResult group;
  final int groupCount;
  final ResponsiveDataGridState gridState;
  final ThemeData theme;

  GridGroupFooter({
    super.key,
    required this.group,
    required this.groupCount,
    required this.theme,
    required this.gridState,
  }) {
    assert(TItem != Object);
  }

  @override
  Widget build(BuildContext context) {
    final gridTheme = ResponsiveDataGridTheme.of(context);
    final layout = GridTableLayout.maybeOf(context);
    final resolved = gridTheme.resolvePadding(gridTheme.footerPadding);
    final padding = layout != null && layout.layoutMode == GridLayoutMode.table
        ? EdgeInsets.only(top: resolved.top, bottom: resolved.bottom)
        : resolved;
    final columns = gridState.layoutColumns;
    return DecoratedBox(
      decoration: BoxDecoration(color: gridTheme.groupFooterBackground),
      child: Padding(
        padding: padding,
        child: layout != null && layout.layoutMode == GridLayoutMode.table
            ? GridTableRow(
                cells: [
                  for (final column in columns)
                    _groupFooterCell(context, column),
                ],
                widths: layout.columnWidths,
                frozenCount: layout.frozenCount,
                frozenBackground: gridTheme.groupFooterBackground,
              )
            : BootstrapRow(
                textDirection: Directionality.of(context),
                crossAxisAlignment:
                    gridState.widget.rowCrossAxisAlignment ==
                            CrossAxisAlignment.start ||
                        gridState.widget.rowCrossAxisAlignment ==
                            CrossAxisAlignment.stretch
                    ? WrapCrossAlignment.start
                    : gridState.widget.rowCrossAxisAlignment ==
                          CrossAxisAlignment.center
                    ? WrapCrossAlignment.center
                    : WrapCrossAlignment.end,
                children: getColumns(context),
                totalSegments:
                    layout?.totalSegments ?? gridState.widget.reactiveSegments,
              ),
      ),
    );
  }

  Widget _groupFooterCell(
    BuildContext context,
    GridColumn<dynamic, dynamic> column,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: group.aggregates
          .where((g) => g.fieldName == column.fieldName && g.result != null)
          .map(
            (agg) => Text(
              "${agg.aggregation}: ${agg.formatResult()}",
              style: ResponsiveDataGridTheme.of(context).footerTextStyle
                  .copyWith(
                    color: ResponsiveDataGridTheme.of(
                      context,
                    ).groupFooterForeground,
                  ),
            ),
          )
          .toList(),
    );
  }

  List<BootstrapCol> getColumns(BuildContext context) {
    return gridState.layoutColumns.map((c) {
      return BootstrapCol(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: group.aggregates
              .where((g) => g.fieldName == c.fieldName && g.result != null)
              .map(
                (agg) => Text(
                  "${agg.aggregation}: ${agg.formatResult()}",
                  style: ResponsiveDataGridTheme.of(context).footerTextStyle
                      .copyWith(
                        color: ResponsiveDataGridTheme.of(
                          context,
                        ).groupFooterForeground,
                      ),
                ),
              )
              .toList(),
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
