part of responsive_data_grid;

class ValueMapFilterRules<TItem extends Object, TValue extends dynamic>
    extends FilterRules<TItem, DataGridValuesColumnFilter<TItem, TValue>,
        TValue> {
  final Map<TValue, Widget> valueMap;

  ValueMapFilterRules({
    required this.valueMap,
    FilterCriteria<TValue>? criteria,
  }) : super(
          criteria: criteria,
        );

  @override
  DataGridValuesColumnFilter<TItem, TValue> showFilter(
          GridColumn<TItem, TValue> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridValuesColumnFilter(definition, grid);
}

class DataGridValuesColumnFilter<TItem extends Object, TValue extends dynamic>
    extends DataGridColumnFilter<TItem, TValue> {
  DataGridValuesColumnFilter(
      GridColumn<TItem, TValue> definition, ResponsiveDataGridState<TItem> grid)
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
  late Logic op;

  late ValueMapFilterRules<TItem, TValue> filterRules;

  @override
  initState() {
    filterRules =
        widget.definition.filterRules as ValueMapFilterRules<TItem, TValue>;
    final criteria = filterRules.criteria;
    if (criteria != null) {
      values = criteria.values
          .where((e) => e != null)
          .cast<TValue>()
          .toList(growable: true);
      op = criteria.logicalOperator;
    } else {
      op = Logic.equals;
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
          value: op == Logic.notEqual,
          title: Text(LocalizedMessages.doesNotInclude),
          onChanged: (value) =>
              setState(() => value ? op = Logic.notEqual : op = Logic.equals),
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
      ],
    );
  }
}
