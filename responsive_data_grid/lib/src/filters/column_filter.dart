part of responsive_data_grid;

abstract class DataGridColumnFilter<TItem extends Object>
    extends StatefulWidget {
  final ColumnDefinition<TItem> definition;
  final ResponsiveDataGridState<TItem> grid;

  DataGridColumnFilter(this.definition, this.grid);
}

abstract class DataGridColumnFilterState<TItem extends Object>
    extends State<DataGridColumnFilter<TItem>> {
  void filter(BuildContext context, FilterCriteria? criteria) {
    widget.definition.header.filterRules =
        widget.definition.header.filterRules.updateCriteria(criteria);

    widget.grid.updateColumnRules(widget.definition);
    Navigator.of(context).pop();
  }
}
