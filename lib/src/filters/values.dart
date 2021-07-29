part of responsive_data_grid;

class DataGridValuesColumnFilter<TItem> extends DataGridColumnFilter<TItem> {
  DataGridValuesColumnFilter(
      ColumnDefinition<TItem> definition, DataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != dynamic);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridValuesColumnFilterState<TItem>();
}

class DataGridValuesColumnFilterState<TItem>
    extends DataGridColumnFilterState<TItem> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
