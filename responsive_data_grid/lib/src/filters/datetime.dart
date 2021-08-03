part of responsive_data_grid;

class DataGridDateTimeColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem> {
  DataGridDateTimeColumnFilter(
      ColumnDefinition<TItem> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridDateTimeColumnFilterState<TItem>();
}

class DataGridDateTimeColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
