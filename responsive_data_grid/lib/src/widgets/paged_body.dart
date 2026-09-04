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
      return gridState.widget.noResults ?? const Text("No results found.");
    }
    if (pageData.groups.isNotEmpty) {
      return buildGroups(
        pageData,
        pageData.groups,
        pageData.items,
        nested: false,
      );
    }
    return getPage(pageData.items);
  }

  Widget buildGroups(
    ListResponse<TItem> response,
    List<GroupResult> groups,
    List<TItem> items, {
    required bool nested,
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
            .where((e) => col.value(e)?.toString() == group.value)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridGroupHeader(group: group, theme: theme),
            Padding(
              padding: EdgeInsets.only(
                left: gridState.widget.groupIndent.toDouble(),
              ),
              child: group.subGroups.isEmpty
                  ? getPage(groupItems)
                  : buildGroups(
                      response,
                      group.subGroups,
                      groupItems,
                      nested: true,
                    ),
            ),
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

  Widget getPage(List<TItem> items) {
    if (items.isEmpty) {
      return gridState.widget.noResults ?? Text("No results found.");
    }
    return ListView.separated(
      separatorBuilder: (context, index) =>
          gridState.widget.separatorThickness == null ||
              gridState.widget.separatorThickness == 0.0
          ? Container()
          : Divider(thickness: gridState.widget.separatorThickness),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      padding: gridState.widget.padding.copyWith(top: 0, bottom: 0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return DataGridRowWidget<TItem>(
          item: item,
          columns: gridState.widget.columns,
          itemTapped: gridState.widget.itemTapped,
          theme: theme,
          padding: gridState.widget.contentPadding,
        );
      },
    );
  }
}
