part of '../responsive_data_grid.dart';

/// Layout numbers for one grid table so header, body, and footer share a
/// single non-wrapping row. When column segments exceed [totalSegments], the
/// table is wider than the viewport and scrolls horizontally.
class GridTableLayout extends InheritedWidget {
  final double contentWidth;
  final int totalSegments;

  const GridTableLayout({
    super.key,
    required this.contentWidth,
    required this.totalSegments,
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
        totalSegments != oldWidget.totalSegments;
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

({double contentWidth, int totalSegments}) gridTableMetrics<TItem extends Object>({
  required List<GridColumn<TItem, dynamic>> columns,
  required double viewportWidth,
  required int reactiveSegments,
  required double screenWidth,
}) {
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
