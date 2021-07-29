part of responsive_data_grid;

class DataGridStringColumnFilter<TItem> extends DataGridColumnFilter<TItem> {
  DataGridStringColumnFilter(
      ColumnDefinition<TItem> definition, DataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != dynamic);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridStringColumnFilterState<TItem>();
}

class DataGridStringColumnFilterState<TItem>
    extends DataGridColumnFilterState<TItem> {
  late LogicalOperators? op;
  late String searchText;

  DataGridStringColumnFilterState();

  @override
  void initState() {
    op = LogicalOperators.startsWith;
    searchText =
        widget.definition.header.filterRules.criteria?.value?.toString() ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField(
            items: [
              DropdownMenuItem(
                  child: Text("Contains"), value: LogicalOperators.contains),
              DropdownMenuItem(
                  child: Text("Starts With"),
                  value: LogicalOperators.startsWith),
              DropdownMenuItem(
                  child: Text("Ends With"), value: LogicalOperators.endsWidth),
              DropdownMenuItem(
                  child: Text("Equals"), value: LogicalOperators.equals),
            ],
            value: op,
            onChanged: (LogicalOperators? value) {
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
                        op: FilterOperators.And,
                        value: searchText)),
                icon: Icon(Icons.save),
                label: Text("Save")))
      ],
    );
  }
}
