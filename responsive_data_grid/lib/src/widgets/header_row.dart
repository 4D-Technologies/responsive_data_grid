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
          child: _headerCells(context, gridTheme),
        ),
      ),
    );
  }

  Widget _headerCells(
    BuildContext context,
    ResponsiveDataGridTheme gridTheme,
  ) {
    final layout = GridTableLayout.maybeOf(context);
    final cells = [
      for (var i = 0; i < columns.length; i++) _headerCell(i, gridTheme),
    ];
    if (layout != null && layout.layoutMode == GridLayoutMode.table) {
      return GridTableRow(
        cells: cells,
        widths: layout.columnWidths,
        frozenCount: layout.frozenCount,
        frozenBackground: gridTheme.headerBackground,
      );
    }
    return BootstrapRow(
      children: getColumnHeaders(context, grid.widget, gridTheme),
      crossAxisAlignment:
          grid.widget.headerCrossAxisAlignment == CrossAxisAlignment.start ||
              grid.widget.headerCrossAxisAlignment ==
                  CrossAxisAlignment.stretch
          ? WrapCrossAlignment.start
          : grid.widget.headerCrossAxisAlignment == CrossAxisAlignment.center
          ? WrapCrossAlignment.center
          : WrapCrossAlignment.end,
      totalSegments: layout?.totalSegments ?? grid.widget.reactiveSegments,
    );
  }

  Widget _headerCell(int i, ResponsiveDataGridTheme gridTheme) {
    final column = columns[i];
    final cell = DecoratedBox(
      key: ValueKey('rdg-header-cell-${column.fieldName}'),
      decoration: BoxDecoration(
        border: Border(
          right: i == columns.length - 1 || gridTheme.headerDividerWidth <= 0
              ? BorderSide.none
              : BorderSide(
                  color: gridTheme.headerDividerColor,
                  width: gridTheme.headerDividerWidth,
                ),
        ),
      ),
      child: column.getHeader(grid),
    );
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        grid.reorderColumnByField(details.data, column.fieldName);
      },
      builder: (context, candidate, rejected) {
        final layout = GridTableLayout.maybeOf(context);
        return Stack(
          children: [
            Draggable<String>(
              data: column.fieldName,
              feedback: Material(
                color: gridTheme.headerBackground,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    column.header.text ?? column.fieldName,
                    style: gridTheme.headerTextStyle,
                  ),
                ),
              ),
              child: cell,
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 8,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  key: ValueKey('rdg-header-resize-${column.fieldName}'),
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    final widths = layout?.columnWidths ?? const [];
                    final current = i < widths.length ? widths[i] : null;
                    final start = current ?? column.width ?? 80;
                    grid.setColumnWidth(
                      column.fieldName,
                      start + details.delta.dx,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
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
