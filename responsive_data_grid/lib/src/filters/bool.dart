part of responsive_data_grid;

class BoolFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridBoolColumnFilter<TItem>, bool> {
  final String title;
  BoolFilterRules({
    String? title,
    FilterCriteria<bool>? criteria,
  })  : this.title = title ?? LocalizedMessages.state,
        super(
          criteria: criteria,
        );

  @override
  DataGridBoolColumnFilter<TItem> showFilter(GridColumn<TItem, bool> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridBoolColumnFilter(definition, grid);
}

class DataGridBoolColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, bool> {
  DataGridBoolColumnFilter(
      GridColumn<TItem, bool> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() => DataGridBoolColumnFilterState<TItem>();
}

class DataGridBoolColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem, bool> {
  bool? value;

  @override
  initState() {
    final criteria = widget.definition.filterRules.criteria;
    if (criteria != null)
      value = criteria.values.length > 0 ? criteria.values.first : null;

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
              onPressed: () => value == null
                  ? super.clear(context)
                  : super.filter(
                      context,
                      FilterCriteria(
                        fieldName: widget.definition.fieldName,
                        logicalOperator: Operators.equals,
                        op: Logic.and,
                        values: [value],
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
