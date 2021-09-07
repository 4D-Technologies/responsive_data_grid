part of responsive_data_grid;

class BoolFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridBoolColumnFilter<TItem>> {
  final String title;
  BoolFilterRules({
    String? title,
    bool filterable = false,
    FilterCriteria? criteria,
  })  : this.title = title ?? LocalizedMessages.state,
        super(
          criteria: criteria,
          filterable: filterable,
        );

  @override
  DataGridBoolColumnFilter<TItem> filter(ColumnDefinition<TItem> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridBoolColumnFilter(definition, grid);

  @override
  FilterRules<TItem, DataGridBoolColumnFilter<TItem>> updateCriteria(
          FilterCriteria? criteria) =>
      BoolFilterRules<TItem>(
        title: title,
        filterable: filterable,
        criteria: criteria,
      );
}

class DataGridBoolColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem> {
  DataGridBoolColumnFilter(
      ColumnDefinition<TItem> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() => DataGridBoolColumnFilterState<TItem>();
}

class DataGridBoolColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem> {
  bool? value;

  @override
  initState() {
    final criteria = widget.definition.header.filterRules.criteria;
    if (criteria != null) {
      value = criteria.value == null
          ? null
          : criteria.value == "true" ||
                  criteria.value == "True" ||
                  criteria.value == "1"
              ? true
              : false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile(
          title: Text(LocalizedMessages.state),
          value: value,
          onChanged: (value) {
            setState(() {
              this.value = value;
            });
          },
          tristate: true,
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
