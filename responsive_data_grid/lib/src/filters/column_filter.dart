part of '../../responsive_data_grid.dart';

bool gridLogicRequiresValue(Logic logic) {
  switch (logic) {
    case Logic.isNull:
    case Logic.isNotNull:
    case Logic.isEmpty:
    case Logic.isNotEmpty:
      return false;
    default:
      return true;
  }
}

const List<Logic> gridStringFilterLogics = [
  Logic.contains,
  Logic.startsWith,
  Logic.endsWith,
  Logic.equals,
  Logic.notEqual,
  Logic.notContains,
  Logic.notStartsWith,
  Logic.notEndsWith,
  Logic.isEmpty,
  Logic.isNotEmpty,
  Logic.isNull,
  Logic.isNotNull,
];

const List<Logic> gridComparableFilterLogics = [
  Logic.equals,
  Logic.notEqual,
  Logic.greaterThan,
  Logic.greaterThanOrEqualTo,
  Logic.lessThan,
  Logic.lessThanOrEqualTo,
  Logic.between,
  Logic.isNull,
  Logic.isNotNull,
];

TextStyle gridMenuFilterTextStyle(BuildContext context) {
  final theme = ResponsiveDataGridTheme.of(context);
  return theme.body.textStyle.copyWith(color: theme.menu.itemForeground);
}

InputDecoration gridMenuFilterDecoration(
  BuildContext context, {
  String? hintText,
  String? labelText,
}) {
  final menu = ResponsiveDataGridTheme.of(context).menu;
  return InputDecoration(
    isDense: true,
    filled: false,
    fillColor: const Color(0x00000000),
    hintText: hintText,
    labelText: labelText,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    contentPadding: EdgeInsets.symmetric(
      horizontal: menu.itemPadding.left,
      vertical: 4,
    ),
  );
}

List<DropdownMenuItem<Logic?>> gridFilterLogicItems(
  BuildContext context,
  List<Logic> logics,
) {
  final style = gridMenuFilterTextStyle(context);
  return [
    DropdownMenuItem<Logic?>(
      value: null,
      child: Text(GridLocalizations.of(context).any, style: style),
    ),
    for (final logic in logics)
      DropdownMenuItem<Logic?>(
        value: logic,
        child: Text(logic.toString(), style: style),
      ),
  ];
}

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
  void writeCriteria(
    Logic? op,
    List<TValue> values, {
    Operators join = Operators.and,
  }) {
    if (op == null || (values.isEmpty && gridLogicRequiresValue(op))) {
      widget.definition.filterRules.criteria = null;
    } else {
      widget.definition.filterRules.criteria = FilterCriteria<TValue>(
        fieldName: widget.definition.fieldName,
        op: join,
        values: values,
        logicalOperator: op,
      );
    }
  }
}
