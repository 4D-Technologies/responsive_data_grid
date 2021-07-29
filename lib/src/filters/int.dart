part of responsive_data_grid;

class DataGridIntColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem> {
  DataGridIntColumnFilter(
      ColumnDefinition<TItem> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() => DataGridIntColumnFilterState<TItem>();
}

class DataGridIntColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
