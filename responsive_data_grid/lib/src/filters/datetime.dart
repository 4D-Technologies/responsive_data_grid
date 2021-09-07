part of responsive_data_grid;

enum DateTimeFilterTypes {
  DateOnly,
  TimeOnly,
  DateTime,
  DateTimeSeparated,
}

class DateTimeFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridDateTimeColumnFilter<TItem>> {
  final DateTimeFilterTypes filterType;
  final DateTime firstDate;
  final DateTime lastDate;

  DateTimeFilterRules({
    required this.filterType,
    bool filterable = false,
    FilterCriteria? criteria,
    DateTime? firstDate,
    DateTime? lastDate,
  })  : this.firstDate = firstDate ?? DateTime.parse("0001-01-01"),
        this.lastDate = lastDate ?? DateTime.parse("3000-01-01"),
        super(
          criteria: criteria,
          filterable: filterable,
        );

  @override
  DataGridDateTimeColumnFilter<TItem> filter(ColumnDefinition<TItem> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridDateTimeColumnFilter(definition, grid);

  @override
  FilterRules<TItem, DataGridDateTimeColumnFilter<TItem>> updateCriteria(
          FilterCriteria? criteria) =>
      DateTimeFilterRules<TItem>(
        filterType: filterType,
        criteria: criteria,
        filterable: filterable,
      );
}

class DataGridDateTimeColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem> {
  DataGridDateTimeColumnFilter(
      ColumnDefinition<TItem> definition, ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridDateTimeColumnFilterState<TItem>();
}

class DataGridDateTimeColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem> {
  DateTime? dtStart;
  DateTime? dtEnd;
  Operators? op;

  late DateTimeFilterRules filterRules;

  @override
  initState() {
    filterRules = widget.definition.header.filterRules as DateTimeFilterRules;

    final criteria = filterRules.criteria;
    if (criteria != null) {
      dtStart = criteria.value != null ? DateTime.parse(criteria.value!) : null;
      dtEnd = criteria.value2 != null ? DateTime.parse(criteria.value2!) : null;
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
            type: _mapType(filterRules.filterType),
            decoration: InputDecoration(hintText: op?.description),
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
          visible: op != null &&
              (op == Operators.lessThan ||
                  op == Operators.lessThanOrEqualTo ||
                  op == Operators.between),
          child: DateTimePicker(
            type: _mapType(filterRules.filterType),
            decoration: InputDecoration(hintText: op?.description),
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
                      value: dtStart?.toIso8601String(),
                      value2: dtEnd?.toIso8601String(),
                    ),
            ),
            icon: Icon(Icons.save),
            label: Text(LocalizedMessages.apply),
          ),
        )
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
