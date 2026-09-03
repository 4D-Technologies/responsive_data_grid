part of '../../responsive_data_grid.dart';

class IntFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridIntColumnFilter<TItem>, int> {
  final String hintText;
  final int? minValue;
  final int? maxValue;
  IntFilterRules({
    String? hintText,
    this.minValue,
    this.maxValue,
    super.criteria,
  }) : hintText = hintText ?? LocalizedMessages.value;

  @override
  DataGridIntColumnFilter<TItem> showFilter(
    GridColumn<TItem, int> definition,
    ResponsiveDataGridState<TItem> grid,
  ) => DataGridIntColumnFilter(definition, grid);
}

class DataGridIntColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, int> {
  DataGridIntColumnFilter(super.definition, super.grid, {super.key}) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() => DataGridIntColumnFilterState<TItem>();
}

class DataGridIntColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem, int> {
  late TextEditingController tecValue1;
  late TextEditingController tecValue2;

  int? iValue;
  int? iValue2;
  Logic? logic;

  late IntFilterRules filterRules;

  void applyCriteria() {
    if (logic == null || (iValue == null && iValue2 == null)) {
      filterRules.criteria = null;
    } else {
      List<int> values = List<int>.empty(growable: true);

      if (iValue != null) values.add(iValue!);
      if (iValue2 != null) values.add(iValue2!);

      filterRules.criteria = FilterCriteria<int>(
        fieldName: widget.definition.fieldName,
        op: Operators.and,
        values: values,
        logicalOperator: logic!,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    filterRules = widget.definition.filterRules as IntFilterRules;

    final criteria = filterRules.criteria;
    if (criteria != null) {
      iValue = criteria.values.isNotEmpty ? criteria.values.first : null;
      tecValue1 = TextEditingController(text: iValue.toString());
      iValue2 = criteria.values.length > 1 ? criteria.values.last : null;
      tecValue2 = TextEditingController(text: iValue2.toString());
      logic = criteria.logicalOperator;
    } else {
      tecValue1 = TextEditingController();
      tecValue2 = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        DropdownButton<Logic?>(
          isExpanded: true,
          items: [
            DropdownMenuItem<Logic?>(
              value: null,
              child: Text(LocalizedMessages.any),
            ),
            DropdownMenuItem<Logic?>(
              value: Logic.greaterThan,
              child: Text(Logic.greaterThan.toString()),
            ),
            DropdownMenuItem<Logic?>(
              value: Logic.greaterThanOrEqualTo,
              child: Text(Logic.greaterThanOrEqualTo.toString()),
            ),
            DropdownMenuItem<Logic?>(
              value: Logic.lessThan,
              child: Text(Logic.lessThan.toString()),
            ),
            DropdownMenuItem<Logic?>(
              value: Logic.lessThanOrEqualTo,
              child: Text(Logic.lessThanOrEqualTo.toString()),
            ),
            DropdownMenuItem<Logic?>(
              value: Logic.between,
              child: Text(Logic.between.toString()),
            ),
            DropdownMenuItem<Logic?>(
              value: Logic.equals,
              child: Text(Logic.equals.toString()),
            ),
            DropdownMenuItem<Logic?>(
              value: Logic.notEqual,
              child: Text(Logic.notEqual.toString()),
            ),
          ],
          value: logic,
          onChanged: (Logic? value) {
            setState(() {
              logic = value;
              applyCriteria();
            });
          },
        ),
        Visibility(
          visible:
              logic != null &&
              (logic == Logic.greaterThan ||
                  logic == Logic.greaterThanOrEqualTo ||
                  logic == Logic.between ||
                  logic == Logic.equals ||
                  logic == Logic.notEqual),
          child: TextField(
            decoration: InputDecoration(hintText: logic?.toString()),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: tecValue1,
            onChanged: (value) {
              setState(() {
                iValue = int.tryParse(value);
                applyCriteria();
              });
            },
          ),
        ),
        Visibility(
          visible:
              logic != null &&
              (logic == Logic.lessThan ||
                  logic == Logic.lessThanOrEqualTo ||
                  logic == Logic.between),
          child: TextField(
            decoration: InputDecoration(hintText: logic?.toString()),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: tecValue2,
            onChanged: (value) {
              setState(() {
                iValue2 = int.tryParse(value);
                applyCriteria();
              });
            },
          ),
        ),
      ],
    );
  }
}
