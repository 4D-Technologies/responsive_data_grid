part of responsive_data_grid;

class GridGroupChooser<TItem> extends StatelessWidget {
  final ResponsiveDataGridState gridState;
  final ThemeData theme;
  final FutureOr<void> Function(GroupCriteria) addGroup;
  final FutureOr<void> Function(GroupCriteria) removeGroup;
  final FutureOr<void> Function(GroupCriteria) updateGroup;
  GridGroupChooser({
    required this.gridState,
    required this.theme,
    required this.addGroup,
    required this.removeGroup,
    required this.updateGroup,
  });

  @override
  Widget build(BuildContext context) {
    final iconTheme = theme.iconTheme;
    final accentIconTheme = theme.iconTheme;

    List<Widget> children = this.gridState.criteria.groupBy == null
        ? List<Widget>.empty(growable: true)
        : this.gridState.criteria.groupBy!.map<Widget>((g) {
            final col = gridState.widget.columns
                .where((c) => c.fieldName == g.fieldName)
                .firstOrDefault();
            if (col == null)
              throw UnsupportedError(
                  "The group fieldname must match that of a valid column.");

            return Padding(
              padding: EdgeInsets.only(right: 4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.buttonTheme.colorScheme!.background,
                ),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 4, bottom: 4, left: 3, right: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_tree,
                        color: theme.primaryIconTheme.color,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(col.header.text ?? col.fieldName),
                      ),
                      IconButton(
                        onPressed: () {
                          OrderDirections newDirection;
                          switch (g.direction) {
                            case OrderDirections.notSet:
                              newDirection = OrderDirections.ascending;
                              break;
                            case OrderDirections.ascending:
                              newDirection = OrderDirections.descending;
                              break;
                            case OrderDirections.descending:
                              newDirection = OrderDirections.ascending;
                              break;
                          }
                          updateGroup(
                            GroupCriteria(
                                fieldName: g.fieldName,
                                aggregates: g.aggregates,
                                direction: newDirection),
                          );
                        },
                        icon: Icon(
                          color: accentIconTheme.color ?? iconTheme.color,
                          g.direction == OrderDirections.descending
                              ? Icons.arrow_downward
                              : g.direction == OrderDirections.ascending
                                  ? Icons.arrow_upward
                                  : Icons.sort,
                        ),
                      ),
                      Visibility(
                        visible: gridState.widget.allowAggregations,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.assessment,
                              color: theme.primaryIconTheme.color),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          removeGroup(g);
                        },
                        icon: Icon(Icons.delete, color: theme.errorColor),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(growable: true);

    children.add(
      Padding(
        padding: EdgeInsets.only(top: 4, bottom: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.buttonTheme.colorScheme!.background,
          ),
          child: Padding(
            padding: theme.buttonTheme.padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  color: theme.primaryIconTheme.color,
                ),
                DropdownButton<String>(
                    items: gridState.widget.columns
                        .orderBy((e) => e.header.text ?? e.fieldName)
                        .map((e) => DropdownMenuItem(
                            child: Text(e.header.text ?? e.fieldName),
                            value: e.fieldName))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      addGroup(
                        GroupCriteria(
                          fieldName: value,
                          aggregates: [],
                          direction: OrderDirections.ascending,
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black26,
      ),
      child: Padding(
        padding: EdgeInsets.all(1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
