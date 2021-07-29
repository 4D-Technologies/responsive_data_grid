part of responsive_data_grid;

class DataGridDoubleColumnFilter<TItem> extends DataGridColumnFilter<TItem> {
  DataGridDoubleColumnFilter(
      ColumnDefinition<TItem> definition, DataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != dynamic);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridDoubleColumnFilterState<TItem>();
}

class DataGridDoubleColumnFilterState<TItem>
    extends DataGridColumnFilterState<TItem> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
