part of '../../responsive_data_grid.dart';

abstract class DataGridColumnFilter<
  TItem extends Object,
  TValue extends dynamic
>
    extends StatefulWidget {
  final GridColumn<TItem, TValue> definition;
  final ResponsiveDataGridState<TItem> grid;

  const DataGridColumnFilter(this.definition, this.grid, {super.key});
}

abstract class DataGridColumnFilterState<
  TItem extends Object,
  TValue extends dynamic
>
    extends State<DataGridColumnFilter<TItem, TValue>> {
  void writeCriteria(Logic? op, List<TValue> values) {
    if (op == null || values.isEmpty) {
      widget.definition.filterRules.criteria = null;
    } else {
      widget.definition.filterRules.criteria = FilterCriteria<TValue>(
        fieldName: widget.definition.fieldName,
        op: Operators.and,
        values: values,
        logicalOperator: op,
      );
    }
  }
}
