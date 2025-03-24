part of responsive_data_grid;

class NoFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridColumnFilter<TItem, void>, void> {
  @override
  DataGridColumnFilter<TItem, void> showFilter(
          GridColumn<TItem, void> definition,
          ResponsiveDataGridState<TItem> grid) =>
      throw UnsupportedError("This column does not support filtering");
}
