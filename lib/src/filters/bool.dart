part of responsive_data_grid;

class DataGridBoolColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem> {
  DataGridBoolColumnFilter(
      ColumnDefinition<TItem> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() => DataGridBoolColumnFilterState<TItem>();
}

class DataGridBoolColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
