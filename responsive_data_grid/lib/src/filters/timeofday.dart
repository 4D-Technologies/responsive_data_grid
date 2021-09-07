part of responsive_data_grid;

class TimeOfDayFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridTimeOfDayColumnFilter<TItem>> {
  TimeOfDayFilterRules({
    bool filterable = false,
    FilterCriteria? criteria,
  }) : super(
          criteria: criteria,
          filterable: filterable,
        );

  @override
  DataGridTimeOfDayColumnFilter<TItem> filter(
          ColumnDefinition<TItem> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridTimeOfDayColumnFilter(definition, grid);

  @override
  FilterRules<TItem, DataGridTimeOfDayColumnFilter<TItem>> updateCriteria(
          FilterCriteria? criteria) =>
      TimeOfDayFilterRules<TItem>(
        criteria: criteria,
        filterable: filterable,
      );
}

class DataGridTimeOfDayColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem> {
  DataGridTimeOfDayColumnFilter(
      ColumnDefinition<TItem> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridTimeOfDayColumnFilterState<TItem>();
}

class DataGridTimeOfDayColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem> {
  TimeOfDay? tStart;
  TimeOfDay? tEnd;
  Operators? op;

  late DateTimeFilterRules filterRules;

  @override
  initState() {
    filterRules = widget.definition.header.filterRules as DateTimeFilterRules;

    final criteria = filterRules.criteria;
    if (criteria != null) {
      tStart = criteria.value != null
          ? TimeOfDay.fromDateTime(DateTime.parse(criteria.value!))
          : null;
      tEnd = criteria.value2 != null
          ? TimeOfDay.fromDateTime(DateTime.parse(criteria.value2!))
          : null;
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
            firstDate: filterRules.firstDate,
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
                      value: tStart == null
                          ? null
                          : DateTime(0, 1, 1, tStart!.hour, tStart!.minute)
                              .toIso8601String(),
                      value2: tEnd == null
                          ? null
                          : DateTime(0, 1, 1, tEnd!.hour, tEnd!.minute)
                              .toIso8601String(),
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
