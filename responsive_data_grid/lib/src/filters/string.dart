part of responsive_data_grid;

class StringFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridStringColumnFilter<TItem>> {
  final String hintText;
  StringFilterRules({
    String? hintText,
    bool filterable = false,
    FilterCriteria? criteria,
  })  : this.hintText = hintText ?? LocalizedMessages.value,
        super(
          criteria: criteria,
          filterable: filterable,
        );

  @override
  DataGridStringColumnFilter<TItem> filter(ColumnDefinition<TItem> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridStringColumnFilter(definition, grid);

  @override
  FilterRules<TItem, DataGridStringColumnFilter<TItem>> updateCriteria(
          FilterCriteria? criteria) =>
      StringFilterRules<TItem>(
        criteria: criteria,
        filterable: filterable,
        hintText: hintText,
      );
}

class DataGridStringColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem> {
  DataGridStringColumnFilter(
      ColumnDefinition<TItem> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != dynamic);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridStringColumnFilterState<TItem>();
}

class DataGridStringColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem> {
  Operators? op;
  String? searchText;

  DataGridStringColumnFilterState();

  @override
  void initState() {
    final criteria = widget.definition.header.filterRules.criteria;
    if (criteria != null) {
      op = criteria.logicalOperator;
      searchText = criteria.value?.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<Operators>(
            items: [
              DropdownMenuItem(
                  child: Text(Operators.contains.description),
                  value: Operators.contains),
              DropdownMenuItem(
                  child: Text(Operators.startsWith.description),
                  value: Operators.startsWith),
              DropdownMenuItem(
                  child: Text(Operators.endsWidth.description),
                  value: Operators.endsWidth),
              DropdownMenuItem(
                  child: Text(Operators.equals.description),
                  value: Operators.equals),
              DropdownMenuItem(
                  child: Text(Operators.notEqual.description),
                  value: Operators.notEqual),
              DropdownMenuItem(
                child: Text(Operators.notContains.description),
                value: Operators.notContains,
              ),
              DropdownMenuItem(
                child: Text(Operators.notStartsWith.description),
                value: Operators.notStartsWith,
              ),
              DropdownMenuItem(
                child: Text(Operators.notEndsWith.description),
                value: Operators.notEndsWith,
              ),
            ],
            value: op,
            onChanged: (Operators? value) {
              this.setState(() {
                op = value;
              });
            }),
        TextFormField(
            initialValue: searchText,
            decoration: InputDecoration(labelText: "value"),
            onChanged: (value) => this.setState(() {
                  searchText = value;
                })),
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
                        value: searchText)),
            icon: Icon(Icons.save),
            label: Text(LocalizedMessages.apply),
          ),
        ),
      ],
    );
  }
}
