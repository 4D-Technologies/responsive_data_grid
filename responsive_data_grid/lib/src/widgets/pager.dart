part of '../../responsive_data_grid.dart';

/// Visible page numbers for a compact pager. `null` is an ellipsis slot.
List<int?> compactPagerPages({
  required int pageCount,
  required int currentPage,
  required int maxSlots,
}) {
  if (pageCount <= 0 || maxSlots <= 0) return const [];
  final current = currentPage < 1
      ? 1
      : (currentPage > pageCount ? pageCount : currentPage);
  if (pageCount <= maxSlots) {
    return [for (var i = 1; i <= pageCount; i++) i];
  }
  if (maxSlots == 1) return [current];
  if (maxSlots == 2) return [1, pageCount];

  final selected = <int>{1, pageCount, current};

  bool fits() {
    final sorted = selected.toList()..sort();
    var length = sorted.length;
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i] - sorted[i - 1] > 1) length++;
    }
    return length <= maxSlots;
  }

  var offset = 1;
  while (true) {
    var added = false;
    final left = current - offset;
    final right = current + offset;
    if (left >= 1) {
      selected.add(left);
      if (!fits()) {
        selected.remove(left);
      } else {
        added = true;
      }
    }
    if (right <= pageCount) {
      selected.add(right);
      if (!fits()) {
        selected.remove(right);
      } else {
        added = true;
      }
    }
    if (!added) break;
    offset++;
  }

  final sorted = selected.toList()..sort();
  final result = <int?>[];
  for (var i = 0; i < sorted.length; i++) {
    if (i > 0 && sorted[i] - sorted[i - 1] > 1) {
      result.add(null);
    }
    result.add(sorted[i]);
  }
  while (result.length > maxSlots) {
    final ellipsisAt = result.lastIndexOf(null);
    if (ellipsisAt == -1) break;
    result.removeAt(ellipsisAt);
  }
  if (result.length > maxSlots) {
    if (maxSlots == 1) return [current];
    if (maxSlots == 2) return [1, pageCount];
    return [current];
  }
  return result;
}

String pagerRangeLabel({
  required int pageNumber,
  required int pageSize,
  required int totalCount,
}) {
  if (totalCount <= 0 || pageSize <= 0) return '0–0 of 0';
  final start = (pageNumber - 1) * pageSize + 1;
  final end = math.min(pageNumber * pageSize, totalCount);
  return '$start–$end of $totalCount';
}

int pagerPageCount({required int totalCount, required int pageSize}) {
  if (totalCount <= 0 || pageSize <= 0) return 0;
  return (totalCount / pageSize).ceil();
}

class PagerWidget extends StatelessWidget {
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final List<int> pageSizeOptions;
  final FutureOr<void> Function(int pageNumber) setPage;
  final FutureOr<void> Function(int pageSize)? setPageSize;
  final ThemeData theme;

  const PagerWidget({
    super.key,
    required this.pageNumber,
    required this.totalCount,
    required this.pageSize,
    this.pageSizeOptions = const [10, 25, 50, 100],
    required this.setPage,
    this.setPageSize,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final pageCount = pagerPageCount(
      totalCount: totalCount,
      pageSize: pageSize,
    );
    final atStart = pageCount <= 0 || pageNumber <= 1;
    final atEnd = pageCount <= 0 || pageNumber >= pageCount;
    final gridTheme = ResponsiveDataGridTheme.of(context);
    final sizes = {...pageSizeOptions, pageSize}.toList()..sort();
    final showPageSize = setPageSize != null && sizes.length > 1;

    return Focus(
      key: const ValueKey('rdg-pager'),
      autofocus: false,
      canRequestFocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          if (!atStart) setPage(pageNumber - 1);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          if (!atEnd) setPage(pageNumber + 1);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.home) {
          if (!atStart) setPage(1);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.end) {
          if (!atEnd) setPage(pageCount);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Builder(
        builder: (context) {
          final focused = Focus.of(context).hasFocus;
          return GestureDetector(
            onTap: () => Focus.of(context).requestFocus(),
            child: IconTheme(
        data: IconThemeData(
          color: gridTheme.pagerIconColor,
          size: gridTheme.headerIconSize + 4,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: gridTheme.footerBackground,
            border: Border(
              top: BorderSide(
                color: focused
                    ? gridTheme.headerSortActiveColor
                    : gridTheme.borderColor,
                width: focused ? gridTheme.borderWidth + 1 : gridTheme.borderWidth,
              ),
            ),
          ),
          child: Padding(
            padding: gridTheme.resolvePadding(gridTheme.footerPadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const iconExtent = 36.0;
                const pageExtent = 36.0;
                final rangeLabel = pagerRangeLabel(
                  pageNumber: pageNumber,
                  pageSize: pageSize,
                  totalCount: totalCount,
                );
                final chrome = iconExtent * 4 + (showPageSize ? 64 : 0) + 120;
                final remaining = constraints.maxWidth - chrome;
                final maxSlots = math.max(1, remaining ~/ pageExtent);
                final pages = compactPagerPages(
                  pageCount: pageCount,
                  currentPage: pageNumber,
                  maxSlots: maxSlots,
                );

                return Row(
                  children: [
                    GridChromeIconButton(
                      tooltip: 'First page',
                      onPressed: atStart ? null : () => setPage(1),
                      icon: Icon(gridTheme.pagerFirstIcon),
                      color: gridTheme.pagerIconColor,
                      disabledColor: gridTheme.pagerDisabledIconColor,
                      size: gridTheme.headerIconSize + 4,
                      extent: iconExtent,
                    ),
                    GridChromeIconButton(
                      tooltip: 'Previous page',
                      onPressed: atStart
                          ? null
                          : () => setPage(math.max(1, pageNumber - 1)),
                      icon: Icon(gridTheme.pagerPreviousIcon),
                      color: gridTheme.pagerIconColor,
                      disabledColor: gridTheme.pagerDisabledIconColor,
                      size: gridTheme.headerIconSize + 4,
                      extent: iconExtent,
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final page in pages)
                              if (page == null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: Text(
                                    '…',
                                    style: gridTheme.footerTextStyle.copyWith(
                                      color: gridTheme.footerForeground,
                                    ),
                                  ),
                                )
                              else
                                _PagerPageButton(
                                  page: page,
                                  selected: page == pageNumber,
                                  gridTheme: gridTheme,
                                  onPressed: page == pageNumber
                                      ? null
                                      : () => setPage(page),
                                ),
                          ],
                        ),
                      ),
                    ),
                    GridChromeIconButton(
                      tooltip: 'Next page',
                      onPressed: atEnd
                          ? null
                          : () => setPage(math.min(pageCount, pageNumber + 1)),
                      icon: Icon(gridTheme.pagerNextIcon),
                      color: gridTheme.pagerIconColor,
                      disabledColor: gridTheme.pagerDisabledIconColor,
                      size: gridTheme.headerIconSize + 4,
                      extent: iconExtent,
                    ),
                    GridChromeIconButton(
                      tooltip: 'Last page',
                      onPressed: atEnd ? null : () => setPage(pageCount),
                      icon: Icon(gridTheme.pagerLastIcon),
                      color: gridTheme.pagerIconColor,
                      disabledColor: gridTheme.pagerDisabledIconColor,
                      size: gridTheme.headerIconSize + 4,
                      extent: iconExtent,
                    ),
                    Flexible(
                      child: Text(
                        rangeLabel,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: gridTheme.footerTextStyle.copyWith(
                          color: gridTheme.footerForeground,
                        ),
                      ),
                    ),
                    if (showPageSize) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<int>(
                        key: const ValueKey('rdg-pager-page-size'),
                        tooltip: 'Page size',
                        enabled: setPageSize != null,
                        initialValue: pageSize,
                        onSelected: setPageSize,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            '$pageSize',
                            style: gridTheme.footerTextStyle.copyWith(
                              color: gridTheme.footerForeground,
                            ),
                          ),
                        ),
                        itemBuilder: (context) => [
                          for (final size in sizes)
                            PopupMenuItem<int>(
                              value: size,
                              child: Text('$size'),
                            ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
            ),
          );
      },
      ),
    );
  }
}

class _PagerPageButton extends StatelessWidget {
  final int page;
  final bool selected;
  final ResponsiveDataGridTheme gridTheme;
  final VoidCallback? onPressed;

  const _PagerPageButton({
    required this.page,
    required this.selected,
    required this.gridTheme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Page $page',
      child: Tooltip(
        message: 'Page $page',
        child: GestureDetector(
          key: ValueKey('rdg-pager-page-$page'),
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: SizedBox(
            width: 36,
            height: 36,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: selected ? gridTheme.headerBackground : null,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '$page',
                  style: gridTheme.footerTextStyle.copyWith(
                    color: selected
                        ? gridTheme.headerForeground
                        : gridTheme.footerForeground,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
