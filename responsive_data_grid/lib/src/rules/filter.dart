part of '../../responsive_data_grid.dart';

abstract class FilterRules<
  TItem extends Object,
  TColumnFilter extends DataGridColumnFilter<TItem, TValue>,
  TValue extends dynamic
> {
  FilterCriteria<TValue>? criteria;

  FilterRules({this.criteria});

  void applyEquals(String fieldName, TValue value) {
    criteria = FilterCriteria<TValue>.value(
      fieldName: fieldName,
      op: Operators.and,
      logicalOperator: Logic.equals,
      value: value,
    );
  }

  void applyBetween(String fieldName, TValue start, TValue end) {
    criteria = FilterCriteria<TValue>.between(
      fieldName: fieldName,
      op: Operators.and,
      logicalOperator: Logic.between,
      value1: start,
      value2: end,
    );
  }

  void applyGreaterThanOrEqualTo(String fieldName, TValue value) {
    criteria = FilterCriteria<TValue>.value(
      fieldName: fieldName,
      op: Operators.and,
      logicalOperator: Logic.greaterThanOrEqualTo,
      value: value,
    );
  }

  void applyLessThanOrEqualTo(String fieldName, TValue value) {
    criteria = FilterCriteria<TValue>.value(
      fieldName: fieldName,
      op: Operators.and,
      logicalOperator: Logic.lessThanOrEqualTo,
      value: value,
    );
  }

  TColumnFilter showFilter(
    GridColumn<TItem, TValue> definition,
    ResponsiveDataGridState<TItem> grid,
  );
}
