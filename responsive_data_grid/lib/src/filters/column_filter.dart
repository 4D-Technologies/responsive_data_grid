part of responsive_data_grid;

abstract class DataGridColumnFilter<TItem extends Object,
    TValue extends dynamic> extends StatefulWidget {
  final ColumnDefinition<TItem, TValue> definition;
  final ResponsiveDataGridState<TItem> grid;

  DataGridColumnFilter(this.definition, this.grid);
}

abstract class DataGridColumnFilterState<TItem extends Object,
    TValue extends dynamic> extends State<DataGridColumnFilter<TItem, TValue>> {
  void filter(BuildContext context, FilterCriteria<TValue>? criteria) {
    widget.definition.header.filterRules =
        widget.definition.header.filterRules.updateCriteria(criteria);

    widget.grid.updateColumnRules(widget.definition);
    Navigator.of(context).pop();
  }
}
