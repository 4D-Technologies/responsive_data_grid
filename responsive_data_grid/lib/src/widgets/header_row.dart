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
      color: gridTheme.header.foreground,
      size: gridTheme.header.iconSize,
    );

    return IconTheme(
      data: iconTheme,
      child: DefaultTextStyle(
        style: gridTheme.header.textStyle,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: gridTheme.header.background,
            border: Border(
              bottom: BorderSide(
                color: gridTheme.chrome.borderColor,
                width: gridTheme.chrome.borderWidth,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (grid.widget.headerGroups != null &&
                  grid.widget.headerGroups!.isNotEmpty &&
                  GridTableLayout.maybeOf(context)?.layoutMode ==
                      GridLayoutMode.table)
                _groupHeaderRow(context, gridTheme),
              grid.widget.filterable.usesRow
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _headerCells(context, gridTheme),
                        GridFilterRow<TItem>(grid: grid, columns: columns),
                      ],
                    )
                  : _headerCells(context, gridTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _groupHeaderRow(
    BuildContext context,
    ResponsiveDataGridTheme gridTheme,
  ) {
    final layout = GridTableLayout.maybeOf(context);
    if (layout == null) return const SizedBox.shrink();
    final spans = headerGroupSpans(
      columns: columns,
      widths: layout.columnWidths,
      groups: grid.widget.headerGroups ?? const [],
    );
    var consumed = 0;
    var frozenSpans = 0;
    while (frozenSpans < spans.length && consumed < layout.frozenCount) {
      consumed += spans[frozenSpans].fieldNames.length;
      if (consumed <= layout.frozenCount) {
        frozenSpans++;
      } else {
        break;
      }
    }
    final stickyFields = {
      for (final column in columns)
        if (column.sticky) column.fieldName,
    };
    final stickySpans = [
      for (var i = 0; i < spans.length; i++)
        if (i >= frozenSpans &&
            spans[i].fieldNames.any(stickyFields.contains))
          i,
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: gridTheme.header.dividerColor,
            width: gridTheme.header.dividerWidth <= 0
                ? 0
                : gridTheme.header.dividerWidth,
          ),
        ),
      ),
      child: SizedBox(
        height: 32,
        child: GridTableRow(
          cellCount: spans.length,
          widths: [for (final span in spans) span.width],
          frozenCount: frozenSpans,
          stickyIndexes: stickySpans,
          frozenBackground: gridTheme.header.background,
          cellBuilder: (i) {
            final span = spans[i];
            return SizedBox(
              key: span.title.isEmpty
                  ? null
                  : ValueKey(
                      'rdg-header-group-${span.title}-${span.fieldNames.first}',
                    ),
              child: span.title.isEmpty
                  ? const SizedBox.shrink()
                  : Center(
                      child: Text(
                        span.title,
                        style: gridTheme.header.textStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _headerCells(
    BuildContext context,
    ResponsiveDataGridTheme gridTheme,
  ) {
    final layout = GridTableLayout.maybeOf(context);
    if (layout != null && layout.layoutMode == GridLayoutMode.table) {
      return GridTableRow(
        cells: [
          for (var i = 0; i < columns.length; i++) _headerCell(i, gridTheme),
        ],
        widths: layout.columnWidths,
        frozenCount: layout.frozenCount,
        frozenBackground: gridTheme.header.background,
      );
    }
    return BootstrapRow(
      textDirection: Directionality.of(context),
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
          right: i == columns.length - 1 || gridTheme.header.dividerWidth <= 0
              ? BorderSide.none
              : BorderSide(
                  color: gridTheme.header.dividerColor,
                  width: gridTheme.header.dividerWidth,
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
                color: gridTheme.header.background,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    column.header.text ?? column.fieldName,
                    style: gridTheme.header.textStyle,
                  ),
                ),
              ),
              child: cell,
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              end: 0,
              top: 0,
              bottom: 0,
              width: 10,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  key: ValueKey('rdg-header-resize-${column.fieldName}'),
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    final widths = layout?.columnWidths ?? const [];
                    final current = i < widths.length ? widths[i] : null;
                    final start = current ?? column.width ?? 80;
                    final delta =
                        Directionality.of(context) == TextDirection.rtl
                        ? -details.delta.dx
                        : details.delta.dx;
                    grid.setColumnWidth(
                      column.fieldName,
                      start + delta,
                      userResize: true,
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
                    i == columns.length - 1 || gridTheme.header.dividerWidth <= 0
                    ? BorderSide.none
                    : BorderSide(
                        color: gridTheme.header.dividerColor,
                        width: gridTheme.header.dividerWidth,
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
