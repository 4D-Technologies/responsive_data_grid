part of '../../responsive_data_grid.dart';

class GridFooter<TItem extends Object> extends StatelessWidget {
  final ResponseCache<TItem> data;
  final ResponsiveDataGridState gridState;
  final ThemeData theme;

  GridFooter(this.data, this.gridState, this.theme, {super.key}) {
    assert(TItem != Object);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 3, bottom: 3),
          child: BootstrapRow(
            horizontalSpacing: gridState.widget.columnSpacing,
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
            totalSegments: gridState.widget.reactiveSegments,
          ),
        ),
      ),
    );
  }

  List<BootstrapCol> getColumns(BuildContext context) {
    return gridState.widget.columns.map((c) {
      return BootstrapCol(
        child: Padding(
          padding: EdgeInsets.only(
            left: gridState.widget.columns.indexOf(c) == 0
                ? 0
                : gridState.widget.columnSpacing,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: data.aggregates
                .where((g) => g.fieldName == c.fieldName && g.result != null)
                .map(
                  (agg) => Text(
                    "${agg.aggregation}: ${agg.formatResult()}",
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
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
