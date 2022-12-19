part of responsive_data_grid;

enum DateTimeFilterTypes {
  DateOnly,
  TimeOnly,
  DateTime,
  DateTimeSeparated,
}

class DateTimeFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridDateTimeColumnFilter<TItem>, DateTime> {
  final DateTimeFilterTypes filterType;
  final DateTime firstDate;
  final DateTime lastDate;

  DateTimeFilterRules({
    required this.filterType,
    FilterCriteria<DateTime>? criteria,
    DateTime? firstDate,
    DateTime? lastDate,
  })  : this.firstDate = firstDate ?? DateTime.parse("0001-01-01"),
        this.lastDate = lastDate ?? DateTime.parse("3000-01-01"),
        super(
          criteria: criteria,
        );

  @override
  DataGridDateTimeColumnFilter<TItem> showFilter(
          GridColumn<TItem, DateTime> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridDateTimeColumnFilter(definition, grid);
}

class DataGridDateTimeColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, DateTime> {
  DataGridDateTimeColumnFilter(GridColumn<TItem, DateTime> definition,
      ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridDateTimeColumnFilterState<TItem>();
}

class DataGridDateTimeColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem, DateTime> {
  DateTime? dtStart;
  DateTime? dtEnd;
  Logic? op;

  late DateTimeFilterRules<TItem> filterRules;

  @override
  initState() {
    filterRules = widget.definition.filterRules as DateTimeFilterRules<TItem>;

    final criteria = filterRules.criteria;
    if (criteria != null) {
      dtStart = criteria.values.length > 0 ? criteria.values.first : null;
      dtEnd = criteria.values.length > 1 ? criteria.values.last : null;
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
                child: Text(LocalizedMessages.any),
                value: null,
              ),
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
                  op == Logic.notEqual ||
                  op == Logic.lessThan ||
                  op == Logic.lessThanOrEqualTo),
          child: DateTimePicker(
            type: _mapType(filterRules.filterType),
            decoration: InputDecoration(hintText: op?.toString()),
            lastDate: dtEnd ?? filterRules.lastDate,
            initialValue: dtStart?.toIso8601String(),
            firstDate: filterRules.firstDate,
            onChanged: (value) {
              this.setState(() {
                dtStart = DateTime.parse(value);
              });
            },
          ),
        ),
        Visibility(
          visible: op != null && (op == Logic.between),
          child: DateTimePicker(
            type: _mapType(filterRules.filterType),
            decoration: InputDecoration(hintText: op?.toString()),
            firstDate: dtStart ?? filterRules.firstDate,
            lastDate: filterRules.lastDate,
            initialValue: dtEnd?.toIso8601String(),
            onChanged: (value) {
              this.setState(() {
                dtEnd = DateTime.parse(value);
              });
            },
          ),
        ),
      ],
    );
  }

  DateTimePickerType _mapType(DateTimeFilterTypes filterType) {
    switch (filterType) {
      case DateTimeFilterTypes.DateOnly:
        return DateTimePickerType.date;
      case DateTimeFilterTypes.TimeOnly:
        return DateTimePickerType.time;
      case DateTimeFilterTypes.DateTime:
        return DateTimePickerType.dateTime;
      case DateTimeFilterTypes.DateTimeSeparated:
        return DateTimePickerType.dateTimeSeparate;
    }
  }
}
