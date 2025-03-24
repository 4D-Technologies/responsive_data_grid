part of responsive_data_grid;

class StringFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridStringColumnFilter<TItem>, String> {
  final String hintText;
  StringFilterRules({
    String? hintText,
    FilterCriteria<String>? criteria,
  })  : this.hintText = hintText ?? LocalizedMessages.value,
        super(
          criteria: criteria,
        );

  @override
  DataGridStringColumnFilter<TItem> showFilter(
          GridColumn<TItem, String> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridStringColumnFilter(definition, grid);
}

class DataGridStringColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, String> {
  DataGridStringColumnFilter(
      GridColumn<TItem, String> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != dynamic);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridStringColumnFilterState<TItem>();
}

class DataGridStringColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem, String> {
  Logic? op;
  String? searchText;

  DataGridStringColumnFilterState();

  @override
  void initState() {
    final criteria = widget.definition.filterRules.criteria;
    if (criteria != null) {
      op = criteria.logicalOperator;
      searchText =
          criteria.values.length > 0 ? criteria.values.first.toString() : null;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<Logic?>(
            elevation: 30,
            items: [
              DropdownMenuItem(
                child: Text(LocalizedMessages.any),
                value: null,
              ),
              DropdownMenuItem(
                  child: Text(Logic.contains.toString()),
                  value: Logic.contains),
              DropdownMenuItem(
                  child: Text(Logic.startsWith.toString()),
                  value: Logic.startsWith),
              DropdownMenuItem(
                  child: Text(Logic.endsWidth.toString()),
                  value: Logic.endsWidth),
              DropdownMenuItem(
                  child: Text(Logic.equals.toString()), value: Logic.equals),
              DropdownMenuItem(
                  child: Text(Logic.notEqual.toString()),
                  value: Logic.notEqual),
              DropdownMenuItem(
                child: Text(Logic.notContains.toString()),
                value: Logic.notContains,
              ),
              DropdownMenuItem(
                child: Text(Logic.notStartsWith.toString()),
                value: Logic.notStartsWith,
              ),
              DropdownMenuItem(
                child: Text(Logic.notEndsWith.toString()),
                value: Logic.notEndsWith,
              ),
            ],
            value: op,
            onChanged: (Logic? value) {
              this.setState(() {
                op = value;
              });
            }),
        Visibility(
          visible: op != null,
          child: TextFormField(
            initialValue: searchText,
            decoration: InputDecoration(labelText: "value"),
            onChanged: (value) => this.setState(
              () {
                searchText = value;
              },
            ),
          ),
        ),
      ],
    );
  }
}
