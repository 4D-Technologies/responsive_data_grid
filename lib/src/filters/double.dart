part of responsive_data_grid;

class DataGridDoubleColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem> {
  DataGridDoubleColumnFilter(
      ColumnDefinition<TItem> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridDoubleColumnFilterState<TItem>();
}

class DataGridDoubleColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
