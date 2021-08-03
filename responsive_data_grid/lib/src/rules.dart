part of responsive_data_grid;

@immutable
class FilterRules<TItem extends Object> {
  final bool filterable;
  final Map<String, dynamic>? valueMap;
  final DataGridColumnFilter<TItem>? customFilter;
  final FilterCriteria? criteria;

  FilterRules(
      {this.criteria,
      this.filterable = false,
      this.valueMap,
      this.customFilter});

  const FilterRules.notSet()
      : this.filterable = false,
        this.criteria = null,
        this.valueMap = null,
        this.customFilter = null;

  FilterRules<TItem> copyWith({
    bool? filterable,
    Map<String, dynamic>? valueMap,
    DataGridColumnFilter<TItem>? customFilter,
    FilterCriteria? criteria,
  }) =>
      FilterRules(
          criteria: criteria ?? this.criteria,
          customFilter: customFilter ?? this.customFilter,
          filterable: filterable ?? this.filterable,
          valueMap: valueMap ?? this.valueMap);
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
