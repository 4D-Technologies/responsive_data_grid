part of responsive_data_grid;

class ValueMapFilterRules<TItem extends Object, TValue extends dynamic>
    extends FilterRules<TItem, DataGridValuesColumnFilter<TItem, TValue>,
        TValue> {
  final Map<TValue, Widget> valueMap;

  ValueMapFilterRules({
    required this.valueMap,
    FilterCriteria<TValue>? criteria,
    bool filterable = false,
  }) : super(
          criteria: criteria,
          filterable: filterable,
        );

  @override
  DataGridValuesColumnFilter<TItem, TValue> filter(
          ColumnDefinition<TItem, TValue> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridValuesColumnFilter(definition, grid);

  @override
  FilterRules<TItem, DataGridValuesColumnFilter<TItem, TValue>, TValue>
      updateCriteria(FilterCriteria<TValue>? criteria) =>
          ValueMapFilterRules<TItem, TValue>(
            valueMap: valueMap,
            criteria: criteria,
            filterable: filterable,
          );
}

class DataGridValuesColumnFilter<TItem extends Object, TValue extends dynamic>
    extends DataGridColumnFilter<TItem, TValue> {
  DataGridValuesColumnFilter(ColumnDefinition<TItem, TValue> definition,
      ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridValuesColumnFilterState<TItem, TValue>();
}

class DataGridValuesColumnFilterState<TItem extends Object,
    TValue extends dynamic> extends DataGridColumnFilterState<TItem, TValue> {
  late List<TValue> values;
  late Operators op;

  late ValueMapFilterRules filterRules;

  @override
  initState() {
    filterRules = widget.definition.header.filterRules as ValueMapFilterRules;
    final criteria = widget.definition.header.filterRules.criteria;
    if (criteria != null) {
      values = criteria.values
          .where((e) => e != null)
          .cast<TValue>()
          .toList(growable: true);
      op = criteria.logicalOperator;
    } else {
      op = Operators.equals;
      values = List<TValue>.empty(growable: true);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          value: op == Operators.notEqual,
          title: Text(LocalizedMessages.doesNotInclude),
          onChanged: (value) => setState(
              () => value ? op = Operators.notEqual : op = Operators.equals),
        ),
        ...filterRules.valueMap.entries.map(
          (e) => CheckboxListTile(
            onChanged: (value) {
              setState(() {
                if (value != null && value && !values.contains(e.key))
                  values.add(e.key);

                if (value == null || !value && values.contains(e.key))
                  values.remove(e.key);
              });
            },
            value: values.contains(e.key),
            tristate: false,
            title: e.value,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => super.filter(context, null),
              icon: Icon(Icons.clear_all),
              label: Text(LocalizedMessages.clear),
            ),
            Spacer(
              flex: 2,
            ),
            TextButton.icon(
              onPressed: () => super.filter(
                context,
                values.isEmpty
                    ? null
                    : FilterCriteria(
                        fieldName: widget.definition.fieldName,
                        logicalOperator: op,
                        op: Logic.and,
                        values: values,
                      ),
              ),
              icon: Icon(Icons.save),
              label: Text(LocalizedMessages.apply),
            )
          ],
        ),
      ],
    );
  }
}
