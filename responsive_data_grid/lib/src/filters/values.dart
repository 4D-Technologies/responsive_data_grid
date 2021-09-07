part of responsive_data_grid;

class ValueMapFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridValuesColumnFilter<TItem>> {
  final Map<String, Widget> valueMap;

  ValueMapFilterRules({
    required this.valueMap,
    FilterCriteria? criteria,
    bool filterable = false,
  }) : super(
          criteria: criteria,
          filterable: filterable,
        );

  @override
  DataGridValuesColumnFilter<TItem> filter(ColumnDefinition<TItem> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridValuesColumnFilter(definition, grid);

  @override
  FilterRules<TItem, DataGridValuesColumnFilter<TItem>> updateCriteria(
          FilterCriteria? criteria) =>
      ValueMapFilterRules<TItem>(
        valueMap: valueMap,
        criteria: criteria,
        filterable: filterable,
      );
}

class DataGridValuesColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem> {
  DataGridValuesColumnFilter(
      ColumnDefinition<TItem> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridValuesColumnFilterState<TItem>();
}

class DataGridValuesColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem> {
  String? value;

  late ValueMapFilterRules filterRules;

  @override
  initState() {
    filterRules = widget.definition.header.filterRules as ValueMapFilterRules;
    final criteria = widget.definition.header.filterRules.criteria;
    if (criteria != null) {
      value = criteria.value;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String?>(
          onChanged: (value) {
            setState(() {
              this.value = value;
            });
          },
          value: value,
          items: [
            DropdownMenuItem<String?>(
              child: Text(LocalizedMessages.any),
              value: null,
            ),
            ...filterRules.valueMap.entries
                .map(
                  (entry) => DropdownMenuItem<String>(
                    child: entry.value,
                    value: entry.key,
                  ),
                )
                .toList(),
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: TextButton.icon(
            onPressed: () => super.filter(
              context,
              value == null
                  ? null
                  : FilterCriteria(
                      fieldName: widget.definition.fieldName,
                      logicalOperator: Operators.equals,
                      op: Logic.and,
                      value: value!.toString(),
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
