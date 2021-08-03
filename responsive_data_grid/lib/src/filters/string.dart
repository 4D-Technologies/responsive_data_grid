part of responsive_data_grid;

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
  late Operators? op;
  late String searchText;

  DataGridStringColumnFilterState();

  @override
  void initState() {
    op = Operators.startsWith;
    searchText =
        widget.definition.header.filterRules.criteria?.value?.toString() ?? '';
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
                  child: Text("Contains"), value: Operators.contains),
              DropdownMenuItem(
                  child: Text("Starts With"), value: Operators.startsWith),
              DropdownMenuItem(
                  child: Text("Ends With"), value: Operators.endsWidth),
              DropdownMenuItem(child: Text("Equals"), value: Operators.equals),
              DropdownMenuItem(
                  child: Text("Does Not Equal"), value: Operators.notEqual),
              DropdownMenuItem(
                child: Text("Does Not Contain"),
                value: Operators.notContains,
              ),
              DropdownMenuItem(
                child: Text("Does Not Start With"),
                value: Operators.notStartsWith,
              ),
              DropdownMenuItem(
                child: Text("Does Not End With"),
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
                    FilterCriteria(
                        fieldName: widget.definition.fieldName!,
                        logicalOperator: op!,
                        op: Logic.And,
                        value: searchText)),
                icon: Icon(Icons.save),
                label: Text("Save")))
      ],
    );
  }
}
