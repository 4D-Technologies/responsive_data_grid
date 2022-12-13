part of responsive_data_grid;

class ResponsiveDataGridPagedBodyWidget<TItem extends Object>
    extends StatelessWidget {
  final ResponsiveDataGridState<TItem> gridState;
  final ThemeData theme;

  ResponsiveDataGridPagedBodyWidget({
    required this.gridState,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    final pageData = gridState._dataCache.pageMap[gridState.pageNumber]!;
    if (pageData.groups.isNotEmpty) {
      child = buildGroups(
        pageData,
        pageData.groups,
        pageData.items,
      );
    } else {
      child = getPage(pageData.items);
    }

    return child;
  }

  Widget buildGroups(ListResponse<TItem> response, List<GroupResult> groups,
      List<TItem> items) {
    final col = gridState.widget.columns
        .firstWhere((c) => c.fieldName == groups.first.fieldName);

    return ListView.builder(
      itemBuilder: (context, index) {
        final group = groups[index];

        final groupItems = items
            .where((e) => col.value(e)?.toString() == group.value)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridGroupHeader(
              group: group,
              theme: theme,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: group.subGroups.isEmpty
                  ? getPage(
                      groupItems,
                    )
                  : buildGroups(
                      response,
                      group.subGroups,
                      groupItems,
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
      shrinkWrap: true,
    );
  }

  Widget getPage(List<TItem> items) {
    return ListView.separated(
      separatorBuilder: (context, index) =>
          gridState.widget.separatorThickness == null ||
                  gridState.widget.separatorThickness == 0.0
              ? Container()
              : Divider(
                  thickness: gridState.widget.separatorThickness,
                ),
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
