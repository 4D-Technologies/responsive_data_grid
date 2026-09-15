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
  }) {
    final col = gridState.widget.columns.firstWhere(
      (c) => c.fieldName == groups.first.fieldName,
    );

    // Nested group lists live inside a Column, so they must always shrink-wrap.
    // Only the top-level groups list may scroll when the grid has a bounded height.
    final wrap = nested || shrinkWrap;

    return ListView.builder(
      shrinkWrap: wrap,
      physics: wrap ? const NeverScrollableScrollPhysics() : null,
      itemBuilder: (context, index) {
        final group = groups[index];

        final groupItems = items
            .where((e) => gridMatchesGroupValue(col.value(e), group.value))
            .toList();
        final collapsed = gridState.isGroupCollapsed(group);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridGroupHeader(
              group: group,
              theme: theme,
              depth: depth,
              indent: gridState.widget.groupIndent,
              collapsed: collapsed,
              onToggle: () => gridState.toggleGroupCollapsed(group),
            ),
            if (!collapsed)
              Padding(
                padding: gridState.widget.layoutMode == GridLayoutMode.table
                    ? EdgeInsets.zero
                    : EdgeInsets.only(
                        left: gridState.widget.groupIndent.toDouble(),
                      ),
                child: group.subGroups.isEmpty
                    ? getPage(groupItems, nested: true)
                    : buildGroups(
                        response,
                        group.subGroups,
                        groupItems,
                        nested: true,
                        depth: depth + 1,
                      ),
              ),
            if (!collapsed)
              GridGroupFooter<TItem>(
                group: group,
                gridState: gridState,
                theme: theme,
                groupCount: response.groups.length,
              ),
          ],
        );
      },
      itemCount: groups.length,
    );
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
