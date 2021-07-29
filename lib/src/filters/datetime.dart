part of responsive_data_grid;

class DataGridDateTimeColumnFilter<TItem> extends DataGridColumnFilter<TItem> {
  DataGridDateTimeColumnFilter(
      ColumnDefinition<TItem> definition, DataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != dynamic);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridDateTimeColumnFilterState<TItem>();
}

class DataGridDateTimeColumnFilterState<TItem>
    extends DataGridColumnFilterState<TItem> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
