part of responsive_data_grid;

class ColumnMenu<T extends Object> extends DropDownViewWidget {
  final GridColumn<T, dynamic> column;
  final ResponsiveDataGridState<T> gridState;

  ColumnMenu({
    required this.column,
    required ThemeData theme,
    required this.gridState,
  }) : super(
          icon: Icon(
            Icons.menu,
            color: gridState.widget.aggregations
                        .where((a) => a.fieldName == column.fieldName)
                        .isNotEmpty ||
                    column.filterRules.criteria != null
                ? theme.colorScheme.secondary
                : theme.iconTheme.color,
            size: theme.iconTheme.size,
          ),
          theme: theme,
          dropDownWidth: 250,
        );

  void updateAggregations(AggregateCriteria aggregation, bool selected) {
    if (selected) {
      if (column.aggregations.any((a) => a.aggregation == aggregation)) return;

      column.aggregations.add(
        AggregateCriteria(
          fieldName: column.fieldName,
          aggregation: aggregation.aggregation,
        ),
      );
    } else {
      column.aggregations
          .removeWhere((a) => a.aggregation == aggregation.aggregation);
    }
  }

  @override
  Widget build(
      BuildContext context, void Function(BuildContext context) close) {
    final aggregates = column.getAggregations(
      selected: column.aggregations,
      update: updateAggregations,
    );

    return Column(
      children: [
        SizedBox(height: 5),
        Material(
          elevation: 20,
          type: MaterialType.card,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: aggregates.isNotEmpty,
                  child: SizedBox(
                    width: 250,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.black38),
                      child: Padding(
                        padding: EdgeInsets.all(3),
                        child: Text("Aggregates"),
                      ),
                    ),
                  ),
                ),
                ...aggregates,
                SizedBox(
                  width: 250,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black38),
                    child: Padding(
                      padding: EdgeInsets.all(3),
                      child: Text("Filter"),
                    ),
                  ),
                ),
                column.filterRules.showFilter(column, gridState),
                Divider(),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        column.aggregations.clear();
                        column.filterRules.criteria = null;
                        await gridState.refreshData();
                        close(context);
                      },
                      icon: Icon(Icons.clear_all),
                      label: Text(LocalizedMessages.clear),
                    ),
                    Spacer(
                      flex: 2,
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await gridState.refreshData();
                        close(context);
                      },
                      icon: Icon(Icons.save),
                      label: Text(LocalizedMessages.apply),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
