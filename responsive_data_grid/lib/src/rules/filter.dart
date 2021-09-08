part of responsive_data_grid;

@immutable
class NotSetFilterRules<TItem extends Object, TValue extends dynamic>
    extends FilterRules<TItem, DataGridColumnFilter<TItem, TValue>, TValue> {
  const NotSetFilterRules() : super(filterable: false);

  @override
  DataGridColumnFilter<TItem, TValue> filter(
          ColumnDefinition<Object, TValue> definition,
          ResponsiveDataGridState<TItem> grid) =>
      throw UnimplementedError();

  @override
  FilterRules<TItem, DataGridColumnFilter<TItem, TValue>, TValue>
      updateCriteria(FilterCriteria? criteria) => throw UnimplementedError();
}

@immutable
abstract class FilterRules<
    TItem extends Object,
    TColumnFilter extends DataGridColumnFilter<TItem, TValue>,
    TValue extends dynamic> {
  final bool filterable;

  final FilterCriteria<TValue>? criteria;

  const FilterRules({this.criteria, this.filterable = false});

  TColumnFilter filter(
    ColumnDefinition<TItem, TValue> definition,
    ResponsiveDataGridState<TItem> grid,
  );

  FilterRules<TItem, TColumnFilter, TValue> updateCriteria(
      FilterCriteria<TValue>? criteria);
}
