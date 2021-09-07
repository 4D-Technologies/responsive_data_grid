part of responsive_data_grid;

class NotSetFilterRules
    extends FilterRules<Object, DataGridColumnFilter<Object>> {
  const NotSetFilterRules() : super(filterable: false);

  @override
  DataGridColumnFilter<Object> filter(ColumnDefinition<Object> definition,
          ResponsiveDataGridState<Object> grid) =>
      throw UnimplementedError();

  @override
  FilterRules<Object, DataGridColumnFilter<Object>> updateCriteria(
          FilterCriteria? criteria) =>
      throw UnimplementedError();
}

@immutable
abstract class FilterRules<TItem extends Object,
    TColumnFilter extends DataGridColumnFilter<TItem>> {
  final bool filterable;

  final FilterCriteria? criteria;

  const FilterRules({
    this.criteria,
    this.filterable = false,
  });

  const FilterRules.notSet()
      : this.filterable = false,
        this.criteria = null;

  TColumnFilter filter(
    ColumnDefinition<TItem> definition,
    ResponsiveDataGridState<TItem> grid,
  );

  FilterRules<TItem, TColumnFilter> updateCriteria(FilterCriteria? criteria);
}

@immutable
class OrderRules {
  final bool? showSort;
  final OrderDirections direction;

  OrderRules({this.showSort = false, this.direction = OrderDirections.notSet});

  const OrderRules.notSet()
      : this.showSort = null,
        this.direction = OrderDirections.notSet;

  OrderRules copyWith({bool? showSort, OrderDirections? direction}) =>
      OrderRules(
          showSort: showSort ?? this.showSort,
          direction: direction ?? this.direction);
}
