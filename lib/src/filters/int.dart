part of responsive_data_grid;

class DataGridIntColumnFilter<TItem> extends DataGridColumnFilter<TItem> {
  DataGridIntColumnFilter(
      ColumnDefinition<TItem> definition, DataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != dynamic);
  }

  @override
  State<StatefulWidget> createState() => DataGridIntColumnFilterState<TItem>();
}

class DataGridIntColumnFilterState<TItem>
    extends DataGridColumnFilterState<TItem> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
