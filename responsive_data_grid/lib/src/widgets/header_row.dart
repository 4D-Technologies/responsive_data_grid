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
    final gridTheme = ResponsiveDataGridTheme.of(context);

    final iconTheme = IconTheme.of(context).copyWith(
      color: gridTheme.headerForeground,
      size: gridTheme.headerIconSize,
    );

    return IconTheme(
      data: iconTheme,
      child: DefaultTextStyle(
        style: gridTheme.headerTextStyle,
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
          child: BootstrapRow(
            children: getColumnHeaders(context, grid.widget, gridTheme),
            crossAxisAlignment:
                grid.widget.headerCrossAxisAlignment ==
                        CrossAxisAlignment.start ||
                    grid.widget.headerCrossAxisAlignment ==
                        CrossAxisAlignment.stretch
                ? WrapCrossAlignment.start
                : grid.widget.headerCrossAxisAlignment ==
                      CrossAxisAlignment.center
                ? WrapCrossAlignment.center
                : WrapCrossAlignment.end,
            totalSegments:
                GridTableLayout.maybeOf(context)?.totalSegments ??
                grid.widget.reactiveSegments,
          ),
        ),
      ),
    );
  }

  List<BootstrapCol> getColumnHeaders(
    BuildContext context,
    ResponsiveDataGrid<TItem> grid,
    ResponsiveDataGridTheme gridTheme,
  ) {
    return [
      for (var i = 0; i < columns.length; i++)
        BootstrapCol(
          child: DecoratedBox(
            key: ValueKey('rdg-header-cell-${columns[i].fieldName}'),
            decoration: BoxDecoration(
              border: Border(
                right:
                    i == columns.length - 1 || gridTheme.headerDividerWidth <= 0
                    ? BorderSide.none
                    : BorderSide(
                        color: gridTheme.headerDividerColor,
                        width: gridTheme.headerDividerWidth,
                      ),
              ),
            ),
            child: columns[i].getHeader(this.grid),
          ),
          lg:
              columns[i].largeCols ??
              columns[i].mediumCols ??
              columns[i].smallCols ??
              columns[i].xsCols ??
              12,
          md:
              columns[i].mediumCols ??
              columns[i].smallCols ??
              columns[i].xsCols ??
              12,
          sm: columns[i].smallCols ?? columns[i].xsCols ?? 12,
          xl:
              columns[i].xlCols ??
              columns[i].largeCols ??
              columns[i].mediumCols ??
              columns[i].smallCols ??
              columns[i].xsCols ??
              12,
          xs: columns[i].xsCols ?? 12,
        ),
    ];
  }
}
