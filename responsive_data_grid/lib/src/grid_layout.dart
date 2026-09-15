part of '../responsive_data_grid.dart';

/// Layout numbers for one grid table so header, body, and footer share a
/// single non-wrapping row. When column segments exceed [totalSegments], the
/// table is wider than the viewport and scrolls horizontally.
class GridTableLayout extends InheritedWidget {
  final double contentWidth;
  final int totalSegments;
  final List<double> columnWidths;
  final int frozenCount;
  final GridLayoutMode layoutMode;

  const GridTableLayout({
    super.key,
    required this.contentWidth,
    required this.totalSegments,
    this.columnWidths = const [],
    this.frozenCount = 0,
    this.layoutMode = GridLayoutMode.table,
    required super.child,
  });

  static GridTableLayout? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GridTableLayout>();
  }

  static GridTableLayout of(BuildContext context) {
    final layout = maybeOf(context);
    assert(layout != null, 'GridTableLayout not found in context');
    return layout!;
  }

  @override
  bool updateShouldNotify(GridTableLayout oldWidget) {
    return contentWidth != oldWidget.contentWidth ||
        totalSegments != oldWidget.totalSegments ||
        frozenCount != oldWidget.frozenCount ||
        layoutMode != oldWidget.layoutMode ||
        !_sameWidths(columnWidths, oldWidget.columnWidths);
  }

  static bool _sameWidths(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

double clampColumnWidth(double width, double? minWidth, double? maxWidth) {
  var next = width;
  if (minWidth != null && next < minWidth) next = minWidth;
  if (maxWidth != null && next > maxWidth) next = maxWidth;
  return next;
}

List<double> gridColumnPixelWidths<TItem extends Object>({
  required List<GridColumn<TItem, dynamic>> columns,
  required double contentWidth,
  required int totalSegments,
  required double screenWidth,
}) {
  if (columns.isEmpty) return const [];
  final segments = [
    for (final column in columns) gridColumnSegments(column, screenWidth),
  ];
  final used = segments.fold<int>(0, (sum, value) => sum + value);
  final denom = used <= 0 ? totalSegments : used;
  return [
    for (var i = 0; i < columns.length; i++)
      clampColumnWidth(
        columns[i].width ?? contentWidth * segments[i] / denom,
        columns[i].minWidth,
        columns[i].maxWidth,
      ),
  ];
}

class GridTableRow extends StatelessWidget {
  final List<Widget> cells;
  final List<double> widths;
  final int frozenCount;
  final Color? frozenBackground;

  const GridTableRow({
    super.key,
    required this.cells,
    required this.widths,
    this.frozenCount = 0,
    this.frozenBackground,
  });

  @override
  Widget build(BuildContext context) {
    final frozenWidth = widths
        .take(frozenCount)
        .fold<double>(0, (sum, width) => sum + width);
    final scrolling = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (frozenCount > 0) SizedBox(width: frozenWidth),
        for (var i = frozenCount; i < cells.length; i++)
          SizedBox(
            width: i < widths.length ? widths[i] : 0,
            child: cells[i],
          ),
      ],
    );
    if (frozenCount <= 0) return scrolling;
    return Stack(
      children: [
        scrolling,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: PinToHorizontalViewport(
            child: ColoredBox(
              color: frozenBackground ?? const Color(0x00000000),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < frozenCount && i < cells.length; i++)
                    SizedBox(
                      width: i < widths.length ? widths[i] : 0,
                      child: cells[i],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

int gridColumnSegments<TItem extends Object>(
  GridColumn<TItem, dynamic> column,
  double screenWidth,
) {
  int? value;
  if (screenWidth >= 1600) {
    value =
        column.xlCols ??
        column.largeCols ??
        column.mediumCols ??
        column.smallCols ??
        column.xsCols;
  } else if (screenWidth >= 1200) {
    value =
        column.xlCols ??
        column.largeCols ??
        column.mediumCols ??
        column.smallCols ??
        column.xsCols;
  } else if (screenWidth >= 992) {
    value =
        column.largeCols ??
        column.mediumCols ??
        column.smallCols ??
        column.xsCols;
  } else if (screenWidth >= 768) {
    value = column.mediumCols ?? column.smallCols ?? column.xsCols;
  } else if (screenWidth >= 576) {
    value = column.smallCols ?? column.xsCols;
  } else {
    value = column.xsCols;
  }
  return value ?? 12;
}

({double contentWidth, int totalSegments})
gridTableMetrics<TItem extends Object>({
  required List<GridColumn<TItem, dynamic>> columns,
  required double viewportWidth,
  required int reactiveSegments,
  required double screenWidth,
  GridLayoutMode layoutMode = GridLayoutMode.table,
}) {
  if (layoutMode == GridLayoutMode.reflow) {
    return (contentWidth: viewportWidth, totalSegments: reactiveSegments);
  }
  var used = 0;
  for (final column in columns) {
    used += gridColumnSegments(column, screenWidth);
  }
  if (used <= 0) used = reactiveSegments;
  if (used <= reactiveSegments) {
    return (contentWidth: viewportWidth, totalSegments: reactiveSegments);
  }
  return (
    contentWidth: viewportWidth * used / reactiveSegments,
    totalSegments: used,
  );
}

/// Keeps [child] in the horizontal viewport while its ancestors scroll.
///
/// Group titles and full-width aggregate labels live inside the table's
/// horizontal scroll so they stay as wide as the columns. Translating by the
/// current scroll offset pins the label without breaking column alignment.
class PinToHorizontalViewport extends StatelessWidget {
  final Widget child;

  const PinToHorizontalViewport({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scrollable = Scrollable.maybeOf(context, axis: Axis.horizontal);
    if (scrollable == null) {
      return child;
    }

    return AnimatedBuilder(
      animation: scrollable.position,
      builder: (context, child) {
        final offset = scrollable.position.pixels;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: child,
    );
  }
}
