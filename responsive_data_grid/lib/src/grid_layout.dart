part of '../responsive_data_grid.dart';

/// Layout numbers for one grid table so header, body, and footer share a
/// single non-wrapping row. When column segments exceed [totalSegments], the
/// table is wider than the viewport and scrolls horizontally.
class GridTableLayout extends InheritedWidget {
  final double contentWidth;
  final int totalSegments;
  final List<double> columnWidths;
  final int frozenCount;
  final List<int> stickyIndexes;
  final GridLayoutMode layoutMode;

  const GridTableLayout({
    super.key,
    required this.contentWidth,
    required this.totalSegments,
    this.columnWidths = const [],
    this.frozenCount = 0,
    this.stickyIndexes = const [],
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
        !_sameInts(stickyIndexes, oldWidget.stickyIndexes) ||
        !_sameWidths(columnWidths, oldWidget.columnWidths);
  }

  static bool _sameWidths(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _sameInts(List<int> a, List<int> b) {
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
  final List<Widget>? cells;
  final Widget Function(int index)? cellBuilder;
  final int? cellCount;
  final List<double> widths;
  final int frozenCount;
  final Color? frozenBackground;
  final Decoration? frozenDecoration;

  const GridTableRow({
    super.key,
    this.cells,
    this.cellBuilder,
    this.cellCount,
    required this.widths,
    this.frozenCount = 0,
    this.frozenBackground,
    this.frozenDecoration,
  });

  static const double overscan = 120;

  int get _count => cellCount ?? cells?.length ?? 0;

  Widget _cell(int index) {
    if (cellBuilder != null) return cellBuilder!(index);
    return cells![index];
  }

  Widget _frozenChrome(Widget child) {
    if (frozenDecoration != null) {
      child = DecoratedBox(decoration: frozenDecoration!, child: child);
    }
    return ColoredBox(
      color: frozenBackground ?? const Color(0x00000000),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final frozenWidth = widths
        .take(frozenCount)
        .fold<double>(0, (sum, width) => sum + width);
    final sticky = {
      for (final index
          in GridTableLayout.maybeOf(context)?.stickyIndexes ?? const <int>[])
        if (index >= frozenCount && index < _count) index,
    };
    final scrolling = _scrollingRow(context, frozenWidth, sticky);
    if (frozenCount <= 0 && sticky.isEmpty) return scrolling;
    final textDirection = Directionality.of(context);
    return Stack(
      children: [
        scrolling,
        if (frozenCount > 0)
          Positioned.directional(
            textDirection: textDirection,
            start: 0,
            top: 0,
            bottom: 0,
            child: PinToHorizontalViewport(
              child: _frozenChrome(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < frozenCount && i < _count; i++)
                      SizedBox(
                        width: i < widths.length ? widths[i] : 0,
                        child: _cell(i),
                      ),
                  ],
                ),
              ),
            ),
          ),
        for (final index in sticky)
          Positioned.directional(
            textDirection: textDirection,
            start: _naturalStart(index),
            top: 0,
            bottom: 0,
            child: StickyToHorizontalViewport(
              naturalStart: _naturalStart(index),
              width: index < widths.length ? widths[index] : 0,
              frozenWidth: frozenWidth,
              child: _frozenChrome(
                SizedBox(
                  width: index < widths.length ? widths[index] : 0,
                  child: _cell(index),
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _naturalStart(int index) {
    var x = 0.0;
    for (var i = 0; i < index && i < widths.length; i++) {
      x += widths[i];
    }
    return x;
  }

  Widget _scrollingRow(
    BuildContext context,
    double frozenWidth,
    Set<int> sticky,
  ) {
    final position = Scrollable.maybeOf(
      context,
      axis: Axis.horizontal,
    )?.position;
    if (position == null ||
        cellBuilder == null ||
        !position.hasContentDimensions ||
        Directionality.of(context) == TextDirection.rtl) {
      return _fullScrollingRow(frozenWidth, sticky);
    }
    return AnimatedBuilder(
      animation: position,
      builder: (context, _) {
        if (!position.hasContentDimensions) {
          return _fullScrollingRow(frozenWidth, sticky);
        }
        return _virtualScrollingRow(
          frozenWidth,
          sticky,
          position.pixels,
          position.viewportDimension,
        );
      },
    );
  }

  Widget _fullScrollingRow(double frozenWidth, Set<int> sticky) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (frozenCount > 0) SizedBox(width: frozenWidth),
        for (var i = frozenCount; i < _count; i++)
          SizedBox(
            width: i < widths.length ? widths[i] : 0,
            child: sticky.contains(i) ? null : _cell(i),
          ),
      ],
    );
  }

  Widget _virtualScrollingRow(
    double frozenWidth,
    Set<int> sticky,
    double pixels,
    double viewport,
  ) {
    final start = pixels - overscan;
    final end = pixels + viewport + overscan;
    var x = frozenWidth;
    final children = <Widget>[
      if (frozenCount > 0) SizedBox(width: frozenWidth),
    ];
    var gap = 0.0;
    for (var i = frozenCount; i < _count; i++) {
      final width = i < widths.length ? widths[i] : 0.0;
      final cellStart = x;
      final cellEnd = x + width;
      x += width;
      if (sticky.contains(i) || cellEnd < start || cellStart > end) {
        gap += width;
        continue;
      }
      if (gap > 0) {
        children.add(SizedBox(width: gap));
        gap = 0;
      }
      children.add(SizedBox(width: width, child: _cell(i)));
    }
    if (gap > 0) children.add(SizedBox(width: gap));
    return Row(mainAxisSize: MainAxisSize.min, children: children);
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
        final dx = Directionality.of(context) == TextDirection.rtl
            ? -offset
            : offset;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: child,
    );
  }
}

/// Pins a mid-grid column to the viewport start or end only when it would
/// otherwise scroll out of view. Unlike [PinToHorizontalViewport], the child
/// stays in column order until it hits an edge.
class StickyToHorizontalViewport extends StatelessWidget {
  final double naturalStart;
  final double width;
  final double frozenWidth;
  final Widget child;

  const StickyToHorizontalViewport({
    super.key,
    required this.naturalStart,
    required this.width,
    required this.frozenWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scrollable = Scrollable.maybeOf(context, axis: Axis.horizontal);
    if (scrollable == null) return child;
    return AnimatedBuilder(
      animation: scrollable.position,
      builder: (context, child) {
        if (!scrollable.position.hasContentDimensions) return child!;
        final extra = stickyOffset(
          pixels: scrollable.position.pixels,
          viewport: scrollable.position.viewportDimension,
          naturalStart: naturalStart,
          width: width,
          frozenWidth: frozenWidth,
        );
        if (extra == 0) return child!;
        final dx = Directionality.of(context) == TextDirection.rtl
            ? -extra
            : extra;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: child,
    );
  }
}

double stickyOffset({
  required double pixels,
  required double viewport,
  required double naturalStart,
  required double width,
  required double frozenWidth,
}) {
  final visualStart = naturalStart - pixels;
  final visualEnd = visualStart + width;
  if (visualStart < frozenWidth) return frozenWidth - visualStart;
  if (visualStart < viewport && visualEnd > viewport) {
    return viewport - visualEnd;
  }
  return 0;
}
