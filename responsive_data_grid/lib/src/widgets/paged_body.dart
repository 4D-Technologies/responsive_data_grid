part of '../../responsive_data_grid.dart';

class ResponsiveDataGridPagedBodyWidget<TItem extends Object>
    extends StatelessWidget {
  final ResponsiveDataGridState<TItem> gridState;
  final ThemeData theme;
  final bool shrinkWrap;

  const ResponsiveDataGridPagedBodyWidget({
    super.key,
    required this.gridState,
    required this.theme,
    this.shrinkWrap = false,
  });

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

    return ListView.builder(
      shrinkWrap: wrap,
      physics: wrap ? const NeverScrollableScrollPhysics() : null,
      itemBuilder: (context, index) {
        return GridGroupSection<TItem>(
          response: response,
          group: groups[index],
          items: items,
          depth: depth,
          path: path,
          gridState: gridState,
          theme: theme,
        );
      },
      itemCount: groups.length,
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

    final pinEnabled =
        gridState._activePagingMode != PagingMode.infiniteScroll;
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
    required DataGridRowWidget<TItem> Function(TItem item, {int? index})
    rowFor,
    bool allowReorder = true,
  }) {
    const scrollKey = ValueKey('rdg-body-scroll');
    final physics = wrap ? const NeverScrollableScrollPhysics() : null;
    final reorder =
        allowReorder &&
        gridState.canReorderRows &&
        gridState.widget.layoutMode == GridLayoutMode.table;
    final useSticky = !reorder && items.any(gridState.isRowSticky);
    if (reorder) {
      return ReorderableListView.builder(
        key: scrollKey,
        shrinkWrap: wrap,
        physics: physics,
        padding: padding,
        buildDefaultDragHandles: false,
        itemCount: items.length,
        onReorderItem: (from, to) {
          gridState.reorderRow(from, to, adjustForRemoval: false);
        },
        itemBuilder: (context, index) =>
            rowFor(items[index], index: index),
      );
    }
    if (useSticky) {
      return CustomScrollView(
        key: scrollKey,
        shrinkWrap: wrap,
        physics: physics,
        slivers: [
          for (var i = 0; i < items.length; i++)
            if (gridState.isRowSticky(items[i]))
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyRowHeaderDelegate(
                  height:
                      24 +
                      gridState.widget.contentPadding.vertical,
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
    }
    return ListView.separated(
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
