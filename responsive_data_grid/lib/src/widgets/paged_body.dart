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
    return ListView.separated(
      separatorBuilder: (context, index) =>
          gridRowSeparator(context, gridState.widget.separatorThickness),
      shrinkWrap: wrap,
      scrollDirection: Axis.vertical,
      physics: wrap ? const NeverScrollableScrollPhysics() : null,
      padding: gridState.widget.layoutMode == GridLayoutMode.table
          ? EdgeInsets.zero
          : gridState.widget.padding.copyWith(top: 0, bottom: 0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return DataGridRowWidget<TItem>(
          item: item,
          columns: gridState.layoutColumns,
          itemTapped: gridState.widget.itemTapped,
          theme: theme,
          padding: gridState.widget.contentPadding,
        );
      },
    );
  }
}
