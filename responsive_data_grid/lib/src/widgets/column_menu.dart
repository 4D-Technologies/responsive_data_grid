part of '../../responsive_data_grid.dart';

class ColumnMenu<T extends Object> extends DropDownViewWidget {
  final GridColumn<T, dynamic> column;
  final ResponsiveDataGridState<T> gridState;

  ColumnMenu({
    super.key,
    required this.column,
    required super.theme,
    required this.gridState,
  }) : super(
         icon: Icon(
           Icons.menu,
           color:
               column.aggregations.isNotEmpty ||
                   column.filterRules.criteria != null
               ? theme.colorScheme.secondary
               : theme.iconTheme.color,
           size: theme.iconTheme.size,
         ),
         dropDownWidth: 250,
       );

  void updateAggregations(AggregateCriteria aggregation, bool selected) {
    if (selected) {
      if (column.aggregations.any((a) => a == aggregation)) return;

      column.aggregations.add(aggregation);
    } else {
      column.aggregations.removeWhere((a) => a == aggregation);
    }
  }

  @override
  Widget build(
    BuildContext context,
    void Function(BuildContext context) close,
  ) {
    final aggregates = gridState.widget.allowAggregations
        ? column.getAggregations(
            selected: column.aggregations,
            update: updateAggregations,
          )
        : <AggregationChooser<T>>[];

    return Material(
      elevation: 4,
      type: MaterialType.card,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (aggregates.isNotEmpty)
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  "Aggregates",
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ),
          ...aggregates,
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text("Filter", style: theme.textTheme.labelLarge),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: column.filterRules.showFilter(column, gridState),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      column.aggregations.clear();
                      column.filterRules.criteria = null;
                      close(context);
                      gridState.refreshData();
                    },
                    icon: const Icon(Icons.clear_all),
                    label: Text(
                      LocalizedMessages.clear,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      close(context);
                      gridState.refreshData();
                    },
                    icon: const Icon(Icons.save),
                    label: Text(
                      LocalizedMessages.apply,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
