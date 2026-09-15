part of '../../responsive_data_grid.dart';

class GridGroupSection<TItem extends Object> extends StatelessWidget {
  final ListResponse<TItem> response;
  final GroupResult group;
  final List<TItem> items;
  final int depth;
  final String path;
  final ResponsiveDataGridState<TItem> gridState;
  final ThemeData theme;

  const GridGroupSection({
    super.key,
    required this.response,
    required this.group,
    required this.items,
    required this.depth,
    required this.path,
    required this.gridState,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final col = gridState.widget.columns.firstWhere(
      (c) => c.fieldName == group.fieldName,
    );
    final groupItems = items
        .where((e) => gridMatchesGroupValue(col.value(e), group.value))
        .toList();
    final collapsed = gridState.isGroupCollapsed(group, path: path);
    final nextPath = gridState.groupCollapseKey(group, path: path);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridGroupHeader(
          group: group,
          theme: theme,
          depth: depth,
          indent: gridState.widget.groupIndent,
          collapsed: collapsed,
          onToggle: () => gridState.toggleGroupCollapsed(group, path: path),
        ),
        if (!collapsed)
          group.subGroups.isEmpty
              ? gridGroupedRows<TItem>(
                  gridState: gridState,
                  theme: theme,
                  items: groupItems,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final sub in group.subGroups)
                      GridGroupSection<TItem>(
                        response: response,
                        group: sub,
                        items: groupItems,
                        depth: depth + 1,
                        path: nextPath,
                        gridState: gridState,
                        theme: theme,
                      ),
                  ],
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
  }
}

Widget gridGroupedRows<TItem extends Object>({
  required ResponsiveDataGridState<TItem> gridState,
  required ThemeData theme,
  required List<TItem> items,
}) {
  if (items.isEmpty) {
    return gridNoRecordsBody(gridState);
  }
  return ListView.separated(
    separatorBuilder: (context, index) =>
        gridRowSeparator(context, gridState.widget.separatorThickness),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
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
