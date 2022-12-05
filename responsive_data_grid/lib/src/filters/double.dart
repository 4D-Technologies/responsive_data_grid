part of responsive_data_grid;

class DoubleFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridDoubleColumnFilter<TItem>, double> {
  final String hintText;
  final int decimalPlaces;
  final double? minValue;
  final double? maxValue;
  DoubleFilterRules({
    String? hintText,
    this.minValue,
    this.maxValue,
    this.decimalPlaces = 2,
    FilterCriteria<double>? criteria,
  })  : this.hintText = hintText ?? LocalizedMessages.value,
        super(
          criteria: criteria,
        );

  @override
  DataGridDoubleColumnFilter<TItem> showFilter(
          GridColumn<TItem, double> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridDoubleColumnFilter(definition, grid);
}

class DataGridDoubleColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, double> {
  DataGridDoubleColumnFilter(
      GridColumn<TItem, double> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridDoubleColumnFilterState<TItem>();
}

class DataGridDoubleColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem, double> {
  late TextEditingController tecValue1;
  late TextEditingController tecValue2;

  double? dValue;
  double? dValue2;
  Logic? op;

  late DoubleFilterRules filterRules;

  @override
  void initState() {
    super.initState();

    filterRules = widget.definition.filterRules as DoubleFilterRules;

    final criteria = filterRules.criteria;
    if (criteria != null) {
      dValue = criteria.values.length > 0 ? criteria.values.first : null;
      tecValue1 = TextEditingController(text: dValue.toString());
      dValue2 = criteria.values.length > 1 ? criteria.values.last : null;
      tecValue2 = TextEditingController(text: dValue2.toString());
      op = criteria.logicalOperator;
    } else {
      tecValue1 = TextEditingController();
      tecValue2 = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<Logic>(
            items: [
              DropdownMenuItem(
                child: Text(LocalizedMessages.any),
                value: null,
              ),
              DropdownMenuItem(
                  child: Text(Logic.greaterThan.toString()),
                  value: Logic.greaterThan),
              DropdownMenuItem(
                  child: Text(Logic.greaterThanOrEqualTo.toString()),
                  value: Logic.greaterThanOrEqualTo),
              DropdownMenuItem(
                child: Text(Logic.equals.toString()),
                value: Logic.equals,
              ),
              DropdownMenuItem(
                child: Text(Logic.lessThan.toString()),
                value: Logic.lessThan,
              ),
              DropdownMenuItem(
                  child: Text(Logic.lessThanOrEqualTo.toString()),
                  value: Logic.lessThanOrEqualTo),
              DropdownMenuItem(
                child: Text(Logic.between.toString()),
                value: Logic.between,
              ),
              DropdownMenuItem(
                child: Text(Logic.equals.toString()),
                value: Logic.equals,
              ),
              DropdownMenuItem(
                child: Text(Logic.notEqual.toString()),
                value: Logic.notEqual,
              ),
            ],
            value: op,
            onChanged: (Logic? value) {
              this.setState(() {
                op = value;
              });
            }),
        Visibility(
          visible: op != null &&
              (op == Logic.greaterThan ||
                  op == Logic.greaterThanOrEqualTo ||
                  op == Logic.between ||
                  op == Logic.equals ||
                  op == Logic.notEqual),
          child: TextField(
            decoration: InputDecoration(hintText: op?.toString()),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              DecimalTextInputFormatter(decimalRange: filterRules.decimalPlaces)
            ],
            controller: tecValue1,
            onChanged: (value) {
              this.setState(() {
                dValue = double.parse(value);
              });
            },
          ),
        ),
        Visibility(
          visible: op != null &&
              (op == Logic.lessThan ||
                  op == Logic.lessThanOrEqualTo ||
                  op == Logic.between),
          child: TextField(
            decoration: InputDecoration(hintText: op?.toString()),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              DecimalTextInputFormatter(decimalRange: filterRules.decimalPlaces)
            ],
            controller: tecValue2,
            onChanged: (value) {
              this.setState(() {
                dValue2 = double.parse(value);
              });
            },
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => super.clear(context),
              icon: Icon(Icons.clear_all),
              label: Text(LocalizedMessages.clear),
            ),
            Spacer(
              flex: 2,
            ),
            TextButton.icon(
              onPressed: () => op == null
                  ? super.clear(context)
                  : super.filter(
                      context,
                      FilterCriteria(
                        fieldName: widget.definition.fieldName,
                        logicalOperator: op!,
                        op: Operators.and,
                        values: [dValue, dValue2]
                            .where((e) => e != null)
                            .cast<double>()
                            .toList(),
                      ),
                    ),
              icon: Icon(Icons.save),
              label: Text(LocalizedMessages.apply),
            ),
          ],
        )
      ],
    );
  }
}
