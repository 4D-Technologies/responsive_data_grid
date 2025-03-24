part of responsive_data_grid;

abstract class FilterRules<
    TItem extends Object,
    TColumnFilter extends DataGridColumnFilter<TItem, TValue>,
    TValue extends dynamic> {
  FilterCriteria<TValue>? criteria;

  FilterRules({this.criteria});

  TColumnFilter
      showFilter(
    GridColumn<TItem, TValue> definition,
    ResponsiveDataGridState<TItem> grid,
  );
}
