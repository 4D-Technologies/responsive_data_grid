part of responsive_data_grid;

class TimeOfDayFilterRules<TItem extends Object> extends FilterRules<TItem,
    DataGridTimeOfDayColumnFilter<TItem>, TimeOfDay> {
  TimeOfDayFilterRules({
    FilterCriteria<TimeOfDay>? criteria,
  }) : super(
          criteria: criteria,
        );

  @override
  DataGridTimeOfDayColumnFilter<TItem> showFilter(
          GridColumn<TItem, TimeOfDay> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridTimeOfDayColumnFilter(definition, grid);

}

class DataGridTimeOfDayColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, TimeOfDay> {
  DataGridTimeOfDayColumnFilter(GridColumn<TItem, TimeOfDay> definition,
      ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridTimeOfDayColumnFilterState<TItem>();
}

class DataGridTimeOfDayColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem, TimeOfDay> {
  TimeOfDay? tStart;
  TimeOfDay? tEnd;
  Operators? op;

  late TimeOfDayFilterRules filterRules;

  @override
  initState() {
    filterRules = widget.definition.filterRules as TimeOfDayFilterRules;

    final criteria = filterRules.criteria;
    if (criteria != null) {
      tStart = criteria.values.length > 0 ? criteria.values.first : null;
      tEnd = criteria.values.length > 1 ? criteria.values.last : null;
      op = criteria.logicalOperator;
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
                  child: Text(Operators.greaterThan.description),
                  value: Operators.greaterThan),
              DropdownMenuItem(
                  child: Text(Operators.greaterThanOrEqualTo.description),
                  value: Operators.greaterThanOrEqualTo),
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
                  value: Operators.lessThanOrEqualTo),
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
          child: DateTimePicker(
            type: DateTimePickerType.time,
            decoration: InputDecoration(hintText: op?.description),
            initialTime: tStart,
            onChanged: (value) {
              this.setState(() {
                tStart = TimeOfDay.fromDateTime(DateTime.parse(value));
              });
            },
          ),
        ),
        Visibility(
          visible: op != null &&
              (op == Operators.lessThan ||
                  op == Operators.lessThanOrEqualTo ||
                  op == Operators.between),
          child: DateTimePicker(
            type: DateTimePickerType.time,
            decoration: InputDecoration(hintText: op?.description),
            initialTime: tEnd,
            onChanged: (value) {
              this.setState(() {
                tEnd = TimeOfDay.fromDateTime(DateTime.parse(value));
              });
            },
          ),
        ),
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
                      values: [tStart, tEnd].where((e) => e != null).toList(),
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
