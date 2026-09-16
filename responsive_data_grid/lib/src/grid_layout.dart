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
  final double detailGutter;

  const GridTableLayout({
    super.key,
    required this.contentWidth,
    required this.totalSegments,
    this.columnWidths = const [],
    this.frozenCount = 0,
    this.stickyIndexes = const [],
    this.layoutMode = GridLayoutMode.table,
    this.detailGutter = 0,
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
        detailGutter != oldWidget.detailGutter ||
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

double clampGridHeight(
  double height, {
  double? minHeight,
  double? maxHeight,
  double floor = 80,
}) {
  if (minHeight != null &&
      maxHeight != null &&
      minHeight > maxHeight) {
    return maxHeight;
  }
  final lower = minHeight ?? floor;
  var next = height;
  if (next < lower) next = lower;
  if (maxHeight != null && next > maxHeight) next = maxHeight;
  return next;
}

List<int> computeRowspans<TItem extends Object>(
  GridColumn<TItem, dynamic> column,
  List<TItem> items,
) {
  if (items.isEmpty) return const [];
  final spans = List<int>.filled(items.length, 1);
  if (column.rowspanFor != null) {
    for (var i = 0; i < items.length; i++) {
      if (spans[i] == 0) continue;
      var length = column.rowspanFor!(items[i], i);
      if (length < 1) length = 1;
      if (i + length > items.length) length = items.length - i;
      spans[i] = length;
      for (var k = 1; k < length; k++) {
        spans[i + k] = 0;
      }
    }
    return spans;
  }
  if (!column.rowspan) return spans;
  var i = 0;
  while (i < items.length) {
    final value = column.getFormattedValue(items[i]);
    var j = i + 1;
    while (j < items.length &&
        column.getFormattedValue(items[j]) == value) {
      j++;
    }
    spans[i] = j - i;
    for (var k = i + 1; k < j; k++) {
      spans[k] = 0;
    }
    i = j;
  }
  return spans;
}

double clampColumnWidth(double width, double? minWidth, double? maxWidth) {
  var next = width;
  if (minWidth != null && next < minWidth) next = minWidth;
  if (maxWidth != null && next > maxWidth) next = maxWidth;
  return next;
}

/// Grow or shrink [widths] so they sum to [viewport], honoring min/max.
List<double> fitWidthsToViewport({
  required List<double> widths,
  required List<double?> minWidths,
  required List<double?> maxWidths,
  required double viewport,
}) {
  if (widths.isEmpty || viewport <= 0) return List<double>.of(widths);
  final next = [
    for (var i = 0; i < widths.length; i++)
      clampColumnWidth(widths[i], minWidths[i], maxWidths[i]),
  ];
  for (var pass = 0; pass < 16; pass++) {
    final sum = next.fold<double>(0, (a, b) => a + b);
    final remaining = viewport - sum;
    if (remaining.abs() < 0.01) break;
    final flexible = <int>[];
    for (var i = 0; i < next.length; i++) {
      if (remaining > 0) {
        final max = maxWidths[i];
        if (max == null || next[i] < max - 0.01) flexible.add(i);
      } else {
        final min = minWidths[i];
        if (min == null || next[i] > min + 0.01) flexible.add(i);
      }
    }
    if (flexible.isEmpty) break;
    final share = remaining / flexible.length;
    for (final i in flexible) {
      next[i] = clampColumnWidth(next[i] + share, minWidths[i], maxWidths[i]);
    }
  }
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
  final Widget? leading;
  final List<int>? stickyIndexes;
  final int Function(int index)? cellColspan;

  const GridTableRow({
    super.key,
    this.cells,
    this.cellBuilder,
    this.cellCount,
    required this.widths,
    this.frozenCount = 0,
    this.frozenBackground,
    this.frozenDecoration,
    this.leading,
    this.stickyIndexes,
    this.cellColspan,
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
    final gutter = GridTableLayout.maybeOf(context)?.detailGutter ?? 0;
    final frozenWidth = widths
        .take(frozenCount)
        .fold<double>(0, (sum, width) => sum + width);
    final pinnedWidth = gutter + frozenWidth;
    final sticky = [
      for (final index
          in stickyIndexes ??
              GridTableLayout.maybeOf(context)?.stickyIndexes ??
              const <int>[])
        if (index >= frozenCount && index < _count) index,
    ];
    final stickySet = sticky.toSet();
    final scrolling = _scrollingRow(context, pinnedWidth, stickySet);
    if (frozenCount <= 0 && sticky.isEmpty && gutter <= 0) {
      return scrolling;
    }
    final textDirection = Directionality.of(context);
    final scrollable = Scrollable.maybeOf(context, axis: Axis.horizontal);

    List<double> extras() {
      if (scrollable == null || !scrollable.position.hasContentDimensions) {
        return List<double>.filled(sticky.length, 0);
      }
      return stickyExtras(
        indexes: sticky,
        widths: widths,
        pixels: scrollable.position.pixels,
        viewport: scrollable.position.viewportDimension,
        frozenWidth: pinnedWidth,
      );
    }

    Widget stackFor(List<double> extras) {
      return Stack(
        children: [
          scrolling,
          if (frozenCount > 0 || gutter > 0)
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
                      if (gutter > 0)
                        SizedBox(
                          width: gutter,
                          child: leading ?? const SizedBox.shrink(),
                        ),
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
          for (var i = 0; i < sticky.length; i++)
            Positioned.directional(
              textDirection: textDirection,
              start: _naturalStart(sticky[i]),
              top: 0,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(
                  textDirection == TextDirection.rtl ? -extras[i] : extras[i],
                  0,
                ),
                child: _frozenChrome(
                  SizedBox(
                    width: sticky[i] < widths.length ? widths[sticky[i]] : 0,
                    child: _cell(sticky[i]),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    if (scrollable == null) return stackFor(extras());
    return AnimatedBuilder(
      animation: scrollable.position,
      builder: (context, _) => stackFor(extras()),
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
        Directionality.of(context) == TextDirection.rtl ||
        cellColspan != null) {
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

  int _colspanAt(int index) {
    final span = cellColspan?.call(index) ?? 1;
    if (span < 1) return 1;
    final remaining = _count - index;
    return span > remaining ? remaining : span;
  }

  double _spanWidth(int index, int span) {
    var width = 0.0;
    for (var i = 0; i < span && index + i < widths.length; i++) {
      width += widths[index + i];
    }
    return width;
  }

  Widget _fullScrollingRow(double frozenWidth, Set<int> sticky) {
    final children = <Widget>[
      if (frozenWidth > 0) SizedBox(width: frozenWidth),
    ];
    var i = frozenCount;
    while (i < _count) {
      final span = _colspanAt(i);
      children.add(
        SizedBox(
          width: _spanWidth(i, span),
          child: sticky.contains(i)
              ? Opacity(opacity: 0, child: _cell(i))
              : _cell(i),
        ),
      );
      i += span;
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
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
      if (frozenWidth > 0) SizedBox(width: frozenWidth),
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

double _widthsBefore(List<double> widths, int index) {
  var x = 0.0;
  for (var i = 0; i < index && i < widths.length; i++) {
    x += widths[i];
  }
  return x;
}

/// Per-column translate so sticky columns stack at the start or end instead
/// of covering each other. A column fully past the trailing edge stays off
/// screen until it enters view (CSS-sticky, not pulled in).
List<double> stickyExtras({
  required List<int> indexes,
  required List<double> widths,
  required double pixels,
  required double viewport,
  required double frozenWidth,
}) {
  if (indexes.isEmpty) return const [];
  final extras = List<double>.filled(indexes.length, 0);
  final startPinned = List<bool>.filled(indexes.length, false);
  var startInset = frozenWidth;
  for (var i = 0; i < indexes.length; i++) {
    final index = indexes[i];
    final width = index < widths.length ? widths[index] : 0.0;
    final visualStart = _widthsBefore(widths, index) - pixels;
    if (visualStart < startInset) {
      extras[i] = startInset - visualStart;
      startPinned[i] = true;
      startInset += width;
    }
  }
  var endInset = 0.0;
  for (var i = indexes.length - 1; i >= 0; i--) {
    if (startPinned[i]) continue;
    final index = indexes[i];
    final width = index < widths.length ? widths[index] : 0.0;
    final visualStart = _widthsBefore(widths, index) - pixels;
    final visualEnd = visualStart + width;
    final endLimit = viewport - endInset;
    if (visualStart < endLimit && visualEnd > endLimit) {
      extras[i] = endLimit - width - visualStart;
      endInset += width;
    }
  }
  return extras;
}
