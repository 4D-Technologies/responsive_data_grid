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
  Logic? op;

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
        DropdownButtonFormField<Logic>(
            items: [
              DropdownMenuItem(
                  child: Text(Logic.greaterThan.toString()),
                  value: Logic.greaterThan),
              DropdownMenuItem(
                  child: Text(Logic.greaterThanOrEqualTo.toString()),
                  value: Logic.greaterThanOrEqualTo),
              DropdownMenuItem(
                child: Text(Logic.equals.toString()),
                value: Logic.equals,
              ),
              DropdownMenuItem(
                child: Text(Logic.lessThan.toString()),
                value: Logic.lessThan,
              ),
              DropdownMenuItem(
                  child: Text(Logic.lessThanOrEqualTo.toString()),
                  value: Logic.lessThanOrEqualTo),
              DropdownMenuItem(
                child: Text(Logic.between.toString()),
                value: Logic.between,
              ),
              DropdownMenuItem(
                child: Text(Logic.equals.toString()),
                value: Logic.equals,
              ),
              DropdownMenuItem(
                child: Text(Logic.notEqual.toString()),
                value: Logic.notEqual,
              ),
            ],
            value: op,
            onChanged: (Logic? value) {
              this.setState(() {
                op = value;
              });
            }),
        Visibility(
          visible: op != null &&
              (op == Logic.greaterThan ||
                  op == Logic.greaterThanOrEqualTo ||
                  op == Logic.between ||
                  op == Logic.equals ||
                  op == Logic.notEqual),
          child: DateTimePicker(
            type: DateTimePickerType.time,
            decoration: InputDecoration(hintText: op?.toString()),
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
              (op == Logic.lessThan ||
                  op == Logic.lessThanOrEqualTo ||
                  op == Logic.between),
          child: DateTimePicker(
            type: DateTimePickerType.time,
            decoration: InputDecoration(hintText: op?.toString()),
            initialTime: tEnd,
            onChanged: (value) {
              this.setState(() {
                tEnd = TimeOfDay.fromDateTime(DateTime.parse(value));
              });
            },
          ),
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
              onPressed: () => op == null
                  ? super.clear(context)
                  : super.filter(
                      context,
                      FilterCriteria(
                        fieldName: widget.definition.fieldName,
                        logicalOperator: op!,
                        op: Operators.and,
                        values: [tStart, tEnd]
                            .where((e) => e != null)
                            .cast<TimeOfDay>()
                            .toList(),
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
