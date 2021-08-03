part of responsive_data_grid;

class DataGridValuesColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem> {
  DataGridValuesColumnFilter(
      ColumnDefinition<TItem> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridValuesColumnFilterState<TItem>();
}

class DataGridValuesColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
