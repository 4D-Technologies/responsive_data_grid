part of responsive_data_grid;

class NumFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridNumColumnFilter<TItem>> {
  final String hintText;
  final int decimalPlaces;
  final num? minValue;
  final num? maxValue;
  NumFilterRules({
    String? hintText,
    this.minValue,
    this.maxValue,
    this.decimalPlaces = 2,
    bool filterable = false,
    FilterCriteria? criteria,
  })  : this.hintText = hintText ?? LocalizedMessages.value,
        super(
          criteria: criteria,
          filterable: filterable,
        );

  @override
  DataGridNumColumnFilter<TItem> filter(ColumnDefinition<TItem> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridNumColumnFilter(definition, grid);

  @override
  FilterRules<TItem, DataGridNumColumnFilter<TItem>> updateCriteria(
          FilterCriteria? criteria) =>
      NumFilterRules<TItem>(
        criteria: criteria,
        decimalPlaces: decimalPlaces,
        filterable: filterable,
        hintText: hintText,
        maxValue: maxValue,
        minValue: minValue,
      );
}

class DataGridNumColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem> {
  DataGridNumColumnFilter(
      ColumnDefinition<TItem> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() => DataGridNumColumnFilterState<TItem>();
}

class DataGridNumColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem> {
  late TextEditingController tecValue1;
  late TextEditingController tecValue2;

  num? nValue;
  num? nValue2;
  Operators? op;

  late NumFilterRules filterRules;

  @override
  void initState() {
    super.initState();

    filterRules = widget.definition.header.filterRules as NumFilterRules;

    final criteria = filterRules.criteria;
    if (criteria != null) {
      nValue = criteria.value != null ? num.parse(criteria.value!) : null;
      tecValue1 = TextEditingController(text: nValue.toString());
      nValue2 = criteria.value2 != null ? num.parse(criteria.value2!) : null;
      tecValue2 = TextEditingController(text: nValue2.toString());
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
        DropdownButtonFormField<Operators>(
            items: [
              DropdownMenuItem(
                child: Text(LocalizedMessages.any),
                value: null,
              ),
              DropdownMenuItem(
                  child: Text(Operators.greaterThan.description),
                  value: Operators.greaterThan),
              DropdownMenuItem(
                  child: Text(Operators.greaterThanOrEqualTo.description),
                  value: Operators.greaterThanOrEqualTo),
              DropdownMenuItem(
                child: Text(Operators.equals.description),
                value: Operators.equals,
              ),
              DropdownMenuItem(
                child: Text(Operators.lessThan.description),
                value: Operators.lessThan,
              ),
              DropdownMenuItem(
                  child: Text(Operators.lessThanOrEqualTo.description),
                  value: Operators.lessThanOrEqualTo),
              DropdownMenuItem(
                child: Text(Operators.between.description),
                value: Operators.between,
              ),
              DropdownMenuItem(
                child: Text(Operators.equals.description),
                value: Operators.equals,
              ),
              DropdownMenuItem(
                child: Text(Operators.notEqual.description),
                value: Operators.notEqual,
              ),
            ],
            value: op,
            onChanged: (Operators? value) {
              this.setState(() {
                op = value;
              });
            }),
        Visibility(
          visible: op != null &&
              (op == Operators.greaterThan ||
                  op == Operators.greaterThanOrEqualTo ||
                  op == Operators.between ||
                  op == Operators.equals ||
                  op == Operators.notEqual),
          child: TextField(
            decoration: InputDecoration(hintText: op?.description),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              DecimalTextInputFormatter(decimalRange: filterRules.decimalPlaces)
            ],
            controller: tecValue1,
            onChanged: (value) {
              this.setState(() {
                nValue = num.parse(value);
              });
            },
          ),
        ),
        Visibility(
          visible: op != null &&
              (op == Operators.lessThan ||
                  op == Operators.lessThanOrEqualTo ||
                  op == Operators.between),
          child: TextField(
            decoration: InputDecoration(hintText: op?.description),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              DecimalTextInputFormatter(decimalRange: filterRules.decimalPlaces)
            ],
            controller: tecValue2,
            onChanged: (value) {
              this.setState(() {
                nValue2 = num.parse(value);
              });
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: TextButton.icon(
            onPressed: () => super.filter(
              context,
              op == null
                  ? null
                  : FilterCriteria(
                      fieldName: widget.definition.fieldName,
                      logicalOperator: op!,
                      op: Logic.and,
                      value: nValue?.toString(),
                      value2: nValue2?.toString(),
                    ),
            ),
            icon: Icon(Icons.save),
            label: Text(LocalizedMessages.apply),
          ),
        )
      ],
    );
  }
}
