part of '../../responsive_data_grid.dart';

class ResponsiveDataGridPagedBodyWidget<TItem extends Object>
    extends StatelessWidget {
  final ResponsiveDataGridState<TItem> gridState;
  final ThemeData theme;
  final bool shrinkWrap;
  final bool neverScroll;

  const ResponsiveDataGridPagedBodyWidget({
    super.key,
    required this.gridState,
    required this.theme,
    this.shrinkWrap = false,
    bool? neverScroll,
  }) : neverScroll = neverScroll ?? shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final pageData = gridState._dataCache.pageMap[gridState.pageNumber];
    if (pageData == null) {
      return gridNoRecordsBody(gridState);
    }
    if (pageData.groups.isNotEmpty) {
      return buildGroups(
        pageData,
        pageData.groups,
        pageData.items,
        nested: false,
        depth: 0,
      );
    }
    return getPage(pageData.items);
  }

  Widget buildGroups(
    ListResponse<TItem> response,
    List<GroupResult> groups,
    List<TItem> items, {
    required bool nested,
    required int depth,
    String path = '',
  }) {
    if (!nested && !shrinkWrap) {
      return CustomScrollView(
        key: const ValueKey('rdg-body-scroll'),
        slivers: [
          for (final group in groups)
            ..._stickyGroupSlivers(
              response: response,
              group: group,
              items: items,
              depth: depth,
              path: path,
            ),
        ],
      );
    }

    // Nested group lists live inside a Column, so they must always shrink-wrap.
    final wrap = nested || shrinkWrap;
    Widget groupsList(int extra) {
      return ListView.builder(
        key: nested ? null : const ValueKey('rdg-body-scroll'),
        shrinkWrap: wrap,
        physics: nested || neverScroll
            ? const NeverScrollableScrollPhysics()
            : null,
        itemBuilder: (context, index) {
          if (index < groups.length) {
            return GridGroupSection<TItem>(
              response: response,
              group: groups[index],
              items: items,
              depth: depth,
              path: path,
              gridState: gridState,
              theme: theme,
            );
          }
          return _GridEmptyRow(
            index: index - groups.length,
            height: _fillRowHeight,
          );
        },
        itemCount: groups.length + extra,
      );
    }

    if (nested || !_usesFillChrome) return groupsList(0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return groupsList(_fillExtraCount(groups.length, constraints));
      },
    );
  }

  List<Widget> _stickyGroupSlivers({
    required ListResponse<TItem> response,
    required GroupResult group,
    required List<TItem> items,
    required int depth,
    required String path,
  }) {
    final collapsed = gridState.isGroupCollapsed(group, path: path);
    return [
      SliverMainAxisGroup(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: GridStickyGroupHeaderDelegate(
              child: GridGroupHeader(
                group: group,
                theme: theme,
                depth: depth,
                indent: gridState.widget.groupIndent,
                collapsed: collapsed,
                onToggle: () =>
                    gridState.toggleGroupCollapsed(group, path: path),
              ),
            ),
          ),
          if (!collapsed)
            SliverList.list(
              children: [
                GridGroupSection<TItem>(
                  response: response,
                  group: group,
                  items: items,
                  depth: depth,
                  path: path,
                  gridState: gridState,
                  theme: theme,
                  showHeader: false,
                ),
              ],
            ),
        ],
      ),
    ];
  }

  Widget getPage(List<TItem> items, {bool nested = false}) {
    if (items.isEmpty) {
      return gridNoRecordsBody(gridState);
    }
    final wrap = nested || shrinkWrap;
    final padding = gridState.widget.layoutMode == GridLayoutMode.table
        ? EdgeInsets.zero
        : gridState.widget.padding.copyWith(top: 0, bottom: 0);

    final top = <TItem>[];
    final bottom = <TItem>[];
    final rest = <TItem>[];
    final seen = <TItem>{};
    void take(List<TItem> bucket, TItem item) {
      if (seen.add(item)) bucket.add(item);
    }

    final pinEnabled = gridState._activePagingMode != PagingMode.infiniteScroll;
    if (pinEnabled) {
      for (final item in gridState._pinnedTop) {
        take(top, item);
      }
      for (final item in items) {
        switch (gridState.pinOf(item)) {
          case GridRowPin.top:
            take(top, item);
          case GridRowPin.bottom:
            take(bottom, item);
          case GridRowPin.none:
            take(rest, item);
        }
      }
      for (final item in gridState._pinnedBottom) {
        take(bottom, item);
      }
    } else {
      rest.addAll(items);
    }

    final spanByColumn = [
      for (final column in gridState.layoutColumns)
        computeRowspans(column, rest),
    ];
    DataGridRowWidget<TItem> rowFor(TItem item, {int? index}) {
      return DataGridRowWidget<TItem>(
        key: ObjectKey(item),
        item: item,
        columns: gridState.layoutColumns,
        itemTapped: gridState.widget.itemTapped,
        theme: theme,
        padding: gridState.widget.contentPadding,
        gridState: gridState,
        rowIndex: index,
        cellRowspans: index == null
            ? null
            : [
                for (var c = 0; c < spanByColumn.length; c++)
                  index < spanByColumn[c].length ? spanByColumn[c][index] : 1,
              ],
      );
    }

    Widget scroll = _scrollingRows(
      rest,
      wrap: wrap,
      padding: padding,
      rowFor: rowFor,
      allowReorder: top.isEmpty && bottom.isEmpty,
    );
    if (top.isEmpty && bottom.isEmpty) return scroll;

    final topRows = [for (final item in top) rowFor(item)];
    final bottomRows = [for (final item in bottom) rowFor(item)];
    if (wrap) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [...topRows, scroll, ...bottomRows],
      );
    }
    return Column(
      children: [
        ...topRows,
        Expanded(child: scroll),
        ...bottomRows,
      ],
    );
  }

  Widget _scrollingRows(
    List<TItem> items, {
    required bool wrap,
    required EdgeInsets padding,
    required DataGridRowWidget<TItem> Function(TItem item, {int? index}) rowFor,
    bool allowReorder = true,
  }) {
    const scrollKey = ValueKey('rdg-body-scroll');
    final physics = neverScroll ? const NeverScrollableScrollPhysics() : null;
    final reorder =
        allowReorder &&
        gridState.canReorderRows &&
        gridState.widget.layoutMode == GridLayoutMode.table;
    final useSticky = !reorder && items.any(gridState.isRowSticky);
    late final Widget list;
    if (reorder) {
      list = ReorderableListView.builder(
        key: scrollKey,
        shrinkWrap: wrap,
        physics: physics,
        padding: padding,
        buildDefaultDragHandles: false,
        itemCount: items.length,
        onReorderItem: (from, to) {
          gridState.reorderRow(from, to, adjustForRemoval: false);
        },
        itemBuilder: (context, index) => rowFor(items[index], index: index),
      );
    } else if (useSticky) {
      list = CustomScrollView(
        key: scrollKey,
        shrinkWrap: wrap,
        physics: physics,
        slivers: [
          for (var i = 0; i < items.length; i++)
            if (gridState.isRowSticky(items[i]))
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyRowHeaderDelegate(
                  height: 24 + gridState.widget.contentPadding.vertical,
                  background: ResponsiveDataGridTheme.of(
                    gridState.context,
                  ).rowBackground,
                  child: rowFor(items[i], index: i),
                ),
              )
            else
              SliverToBoxAdapter(child: rowFor(items[i], index: i)),
        ],
      );
    } else if (_usesFillChrome) {
      list = LayoutBuilder(
        builder: (context, constraints) {
          final extra = _fillExtraCount(items.length, constraints);
          return ListView.separated(
            key: scrollKey,
            separatorBuilder: (context, index) =>
                gridRowSeparator(context, gridState.widget.separatorThickness),
            shrinkWrap: wrap,
            scrollDirection: Axis.vertical,
            physics: physics,
            padding: padding,
            itemCount: items.length + extra,
            itemBuilder: (context, index) {
              if (index < items.length) {
                return rowFor(items[index], index: index);
              }
              return _GridEmptyRow(
                index: index - items.length,
                height: _fillRowHeight,
              );
            },
          );
        },
      );
    } else {
      list = ListView.separated(
        key: scrollKey,
        separatorBuilder: (context, index) =>
            gridRowSeparator(context, gridState.widget.separatorThickness),
        shrinkWrap: wrap,
        scrollDirection: Axis.vertical,
        physics: physics,
        padding: padding,
        itemCount: items.length,
        itemBuilder: (context, index) => rowFor(items[index], index: index),
      );
    }
    return list;
  }

  bool get _usesFillChrome => gridState.widget.sizing == GridSizing.fill;

  double get _fillRowHeight {
    final theme = ResponsiveDataGridTheme.of(gridState.context);
    return gridRowExtent(
      theme: theme,
      contentPadding: gridState.widget.contentPadding,
      rowSpacing: gridState.widget.rowSpacing,
    );
  }

  int _fillExtraCount(int realCount, BoxConstraints constraints) {
    final theme = ResponsiveDataGridTheme.of(gridState.context);
    final separator = gridState.widget.separatorThickness ?? theme.borderWidth;
    final slot = _fillRowHeight + separator;
    if (slot <= 0) return 0;
    if (!constraints.hasBoundedHeight || !constraints.maxHeight.isFinite) {
      return math.max(0, gridState._pageSize - realCount);
    }
    return math.max(0, (constraints.maxHeight / slot).ceil() - realCount);
  }
}

class _GridEmptyRow extends StatelessWidget {
  final int index;
  final double? height;

  const _GridEmptyRow({required this.index, this.height});

  @override
  Widget build(BuildContext context) {
    final gridTheme = ResponsiveDataGridTheme.of(context);
    final layout = GridTableLayout.maybeOf(context);
    final row = layout != null && layout.layoutMode == GridLayoutMode.table
        ? GridTableRow(
            cellCount: layout.columnWidths.length,
            widths: layout.columnWidths,
            frozenCount: layout.frozenCount,
            frozenBackground: gridTheme.rowBackground,
            cellBuilder: (_) => const SizedBox.expand(),
          )
        : const SizedBox.expand();
    final body = height == null
        ? SizedBox.expand(child: row)
        : SizedBox(height: height, width: double.infinity, child: row);
    return ExcludeSemantics(
      key: ValueKey('rdg-empty-row-$index'),
      child: ColoredBox(color: gridTheme.rowBackground, child: body),
    );
  }
}

class _StickyRowHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final Color background;

  _StickyRowHeaderDelegate({
    required this.child,
    required this.height,
    required this.background,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(color: background, child: child);
  }

  @override
  bool shouldRebuild(covariant _StickyRowHeaderDelegate oldDelegate) {
    return child != oldDelegate.child ||
        height != oldDelegate.height ||
        background != oldDelegate.background;
  }
}
