part of '../../responsive_data_grid.dart';

class NumFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridNumColumnFilter<TItem>, num> {
  final String hintText;
  final int decimalPlaces;
  final num? minValue;
  final num? maxValue;
  NumFilterRules({
    String? hintText,
    this.minValue,
    this.maxValue,
    this.decimalPlaces = 2,
    super.criteria,
  }) : hintText = hintText ?? LocalizedMessages.value;

  @override
  DataGridNumColumnFilter<TItem> showFilter(
    GridColumn<TItem, num> definition,
    ResponsiveDataGridState<TItem> grid,
  ) => DataGridNumColumnFilter(definition, grid);
}

class DataGridNumColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, num> {
  DataGridNumColumnFilter(super.definition, super.grid, {super.key}) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() => DataGridNumColumnFilterState<TItem>();
}

class DataGridNumColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem, num> {
  late TextEditingController tecValue1;
  late TextEditingController tecValue2;

  num? nValue;
  num? nValue2;
  Logic? op;

  late NumFilterRules filterRules;

  @override
  void initState() {
    super.initState();

    filterRules = widget.definition.filterRules as NumFilterRules;

    final criteria = filterRules.criteria;
    if (criteria != null) {
      nValue = criteria.values.isNotEmpty ? criteria.values.first : null;
      tecValue1 = TextEditingController(text: nValue.toString());
      nValue2 = criteria.values.length > 1 ? criteria.values.last : null;
      tecValue2 = TextEditingController(text: nValue2.toString());
      op = criteria.logicalOperator;
    } else {
      tecValue1 = TextEditingController();
      tecValue2 = TextEditingController();
    }
  }

  @override
  void dispose() {
    tecValue1.dispose();
    tecValue2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<Logic?>(
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
          initialValue: op,
          onChanged: (Logic? value) {
            setState(() {
              op = value;
            });
          },
        ),
        Visibility(
          visible:
              op != null &&
              (op == Logic.greaterThan ||
                  op == Logic.greaterThanOrEqualTo ||
                  op == Logic.between ||
                  op == Logic.equals ||
                  op == Logic.notEqual),
          child: TextField(
            decoration: InputDecoration(hintText: op?.toString()),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              DecimalTextInputFormatter(
                decimalRange: filterRules.decimalPlaces,
              ),
            ],
            controller: tecValue1,
            onChanged: (value) {
              setState(() {
                nValue = num.parse(value);
              });
            },
          ),
        ),
        Visibility(
          visible:
              op != null &&
              (op == Logic.lessThan ||
                  op == Logic.lessThanOrEqualTo ||
                  op == Logic.between),
          child: TextField(
            decoration: InputDecoration(hintText: op?.toString()),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              DecimalTextInputFormatter(
                decimalRange: filterRules.decimalPlaces,
              ),
            ],
            controller: tecValue2,
            onChanged: (value) {
              setState(() {
                nValue2 = num.parse(value);
              });
            },
          ),
        ),
      ],
    );
  }
}
