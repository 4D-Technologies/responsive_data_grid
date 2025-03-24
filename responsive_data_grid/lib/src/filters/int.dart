part of responsive_data_grid;

class IntFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridIntColumnFilter<TItem>, int> {
  final String hintText;
  final int? minValue;
  final int? maxValue;
  IntFilterRules({
    String? hintText,
    this.minValue,
    this.maxValue,
    FilterCriteria<int>? criteria,
  })  : this.hintText = hintText ?? LocalizedMessages.value,
        super(
          criteria: criteria,
        );

  @override
  DataGridIntColumnFilter<TItem> showFilter(GridColumn<TItem, int> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridIntColumnFilter(definition, grid);
}

class DataGridIntColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, int> {
  DataGridIntColumnFilter(
      GridColumn<TItem, int> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
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
  Logic? logic = null;

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
      iValue = criteria.values.length > 0 ? criteria.values.first : null;
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
                child: Text(LocalizedMessages.any),
                value: null,
              ),
              DropdownMenuItem<Logic?>(
                child: Text(Logic.greaterThan.toString()),
                value: Logic.greaterThan,
              ),
              DropdownMenuItem<Logic?>(
                child: Text(Logic.greaterThanOrEqualTo.toString()),
                value: Logic.greaterThanOrEqualTo,
              ),
              DropdownMenuItem<Logic?>(
                child: Text(Logic.lessThan.toString()),
                value: Logic.lessThan,
              ),
              DropdownMenuItem<Logic?>(
                child: Text(Logic.lessThanOrEqualTo.toString()),
                value: Logic.lessThanOrEqualTo,
              ),
              DropdownMenuItem<Logic?>(
                child: Text(Logic.between.toString()),
                value: Logic.between,
              ),
              DropdownMenuItem<Logic?>(
                child: Text(Logic.equals.toString()),
                value: Logic.equals,
              ),
              DropdownMenuItem<Logic?>(
                child: Text(Logic.notEqual.toString()),
                value: Logic.notEqual,
              ),
            ],
            value: logic,
            onChanged: (Logic? value) {
              this.setState(() {
                logic = value;
                applyCriteria();
              });
            }),
        Visibility(
          visible: logic != null &&
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
              this.setState(() {
                iValue = int.tryParse(value);
                applyCriteria();
              });
            },
          ),
        ),
        Visibility(
          visible: logic != null &&
              (logic == Logic.lessThan ||
                  logic == Logic.lessThanOrEqualTo ||
                  logic == Logic.between),
          child: TextField(
            decoration: InputDecoration(hintText: logic?.toString()),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: tecValue2,
            onChanged: (value) {
              this.setState(() {
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
