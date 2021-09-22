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
  Operators? op;

  late IntFilterRules filterRules;

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
        DropdownButton<Operators?>(
            items: [
              DropdownMenuItem(
                child: Text(LocalizedMessages.any),
                value: null,
              ),
              DropdownMenuItem(
                child: Text(Operators.greaterThan.description),
                value: Operators.greaterThan,
              ),
              DropdownMenuItem(
                child: Text(Operators.greaterThanOrEqualTo.description),
                value: Operators.greaterThanOrEqualTo,
              ),
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
                value: Operators.lessThanOrEqualTo,
              ),
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
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: tecValue1,
            onChanged: (value) {
              this.setState(() {
                iValue = int.parse(value);
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
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: tecValue2,
            onChanged: (value) {
              this.setState(() {
                iValue2 = int.parse(value);
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
                        op: Logic.and,
                        values: [iValue, iValue2]
                            .where((e) => e != null)
                            .cast<int>()
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
