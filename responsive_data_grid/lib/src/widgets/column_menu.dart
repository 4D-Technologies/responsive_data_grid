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

    return Column(
      children: [
        SizedBox(height: 5),
        Material(
          elevation: 20,
          type: MaterialType.card,
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
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final navigator = Navigator.of(
                        context,
                        rootNavigator: true,
                      );
                      final route = ModalRoute.of(context);
                      column.aggregations.clear();
                      column.filterRules.criteria = null;
                      await gridState.refreshData();
                      _popMenuIfCurrent(navigator, route);
                    },
                    icon: Icon(Icons.clear_all),
                    label: Text(LocalizedMessages.clear),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final navigator = Navigator.of(
                        context,
                        rootNavigator: true,
                      );
                      final route = ModalRoute.of(context);
                      await gridState.refreshData();
                      _popMenuIfCurrent(navigator, route);
                    },
                    icon: Icon(Icons.save),
                    label: Text(LocalizedMessages.apply),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
