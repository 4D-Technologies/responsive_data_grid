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
        DropdownButtonFormField<Logic?>(
            items: [
              DropdownMenuItem<Logic?>(
                  child: Text(Logic.greaterThan.toString()),
                  value: Logic.greaterThan),
              DropdownMenuItem<Logic?>(
                  child: Text(Logic.greaterThanOrEqualTo.toString()),
                  value: Logic.greaterThanOrEqualTo),
              DropdownMenuItem<Logic?>(
                child: Text(Logic.lessThan.toString()),
                value: Logic.lessThan,
              ),
              DropdownMenuItem<Logic?>(
                  child: Text(Logic.lessThanOrEqualTo.toString()),
                  value: Logic.lessThanOrEqualTo),
              DropdownMenuItem<Logic?>(
                child: Text(Logic.between.toString()),
                value: Logic.between,
              ),
              DropdownMenuItem<Logic?>(
                child: Text(Logic.equals.toString()),
                value: Logic.equals,
              ),
              DropdownMenuItem<Logic?>(
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
          child: DateTimeField.time(
            decoration: InputDecoration(hintText: op?.toString()),
            initialPickerDateTime: tStart == null ? null : tStart!.toDateTime(),
            onChanged: (value) {
              this.setState(() {
                tStart = value == null ? null : TimeOfDay.fromDateTime(value);
              });
            },
          ),
        ),
        Visibility(
          visible: op != null &&
              (op == Logic.lessThan ||
                  op == Logic.lessThanOrEqualTo ||
                  op == Logic.between),
          child: DateTimeField.time(
            decoration: InputDecoration(hintText: op?.toString()),
            initialPickerDateTime: tEnd == null ? null : tEnd!.toDateTime(),
            onChanged: (value) {
              this.setState(() {
                tEnd = value == null ? null : TimeOfDay.fromDateTime(value);
              });
            },
          ),
        ),
      ],
    );
  }
}
