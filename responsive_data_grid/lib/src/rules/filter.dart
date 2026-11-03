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

  TColumnFilter showFilter(
    GridColumn<TItem, TValue> definition,
    ResponsiveDataGridState<TItem> grid,
  );
}
