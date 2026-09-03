part of '../../responsive_data_grid.dart';

enum DateTimeFilterTypes { DateOnly, TimeOnly, DateTime }

class DateTimeFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridDateTimeColumnFilter<TItem>, DateTime> {
  final DateTimeFilterTypes filterType;
  final DateTime firstDate;
  final DateTime lastDate;

  DateTimeFilterRules({
    required this.filterType,
    super.criteria,
    DateTime? firstDate,
    DateTime? lastDate,
  }) : firstDate = firstDate ?? DateTime.parse("0001-01-01"),
       lastDate = lastDate ?? DateTime.parse("3000-01-01");

  @override
  DataGridDateTimeColumnFilter<TItem> showFilter(
    GridColumn<TItem, DateTime> definition,
    ResponsiveDataGridState<TItem> grid,
  ) => DataGridDateTimeColumnFilter(definition, grid);
}

class DataGridDateTimeColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, DateTime> {
  DataGridDateTimeColumnFilter(super.definition, super.grid, {super.key}) {
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
      dtStart = criteria.values.isNotEmpty ? criteria.values.first : null;
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
              value: null,
              child: Text(LocalizedMessages.any),
            ),
            DropdownMenuItem<Logic?>(
              value: Logic.greaterThan,
              child: Text(Logic.greaterThan.toString()),
            ),
            DropdownMenuItem<Logic?>(
              value: Logic.greaterThanOrEqualTo,
              child: Text(Logic.greaterThanOrEqualTo.toString()),
            ),
            DropdownMenuItem<Logic?>(
              value: Logic.lessThan,
              child: Text(Logic.lessThan.toString()),
            ),
            DropdownMenuItem<Logic?>(
              value: Logic.lessThanOrEqualTo,
              child: Text(Logic.lessThanOrEqualTo.toString()),
            ),
            DropdownMenuItem<Logic?>(
              value: Logic.between,
              child: Text(Logic.between.toString()),
            ),
            DropdownMenuItem<Logic?>(
              value: Logic.equals,
              child: Text(Logic.equals.toString()),
            ),
            DropdownMenuItem<Logic?>(
              value: Logic.notEqual,
              child: Text(Logic.notEqual.toString()),
            ),
          ],
          initialValue: op,
          onChanged: (Logic? value) {
            setState(() {
              op = value;
            });
          },
        ),
        Visibility(
          visible:
              op != null &&
              (op == Logic.greaterThan ||
                  op == Logic.greaterThanOrEqualTo ||
                  op == Logic.between ||
                  op == Logic.equals ||
                  op == Logic.notEqual ||
                  op == Logic.lessThan ||
                  op == Logic.lessThanOrEqualTo),
          child: DateTimeField(
            decoration: InputDecoration(hintText: op?.toString()),
            value: dtStart,
            lastDate: dtEnd ?? filterRules.lastDate,
            initialPickerDateTime: dtStart,
            firstDate: filterRules.firstDate,
            mode: _mapType(filterRules.filterType),
            onChanged: (DateTime? value) {
              setState(() {
                dtStart = value;
              });
            },
          ),
        ),
        Visibility(
          visible: op != null && (op == Logic.between),
          child: DateTimeField(
            decoration: InputDecoration(hintText: op?.toString()),
            value: dtEnd,
            firstDate: dtStart ?? filterRules.firstDate,
            lastDate: filterRules.lastDate,
            initialPickerDateTime: dtEnd,
            mode: _mapType(filterRules.filterType),
            onChanged: (DateTime? value) {
              setState(() {
                dtEnd = value;
              });
            },
          ),
        ),
      ],
    );
  }

  DateTimeFieldPickerMode _mapType(DateTimeFilterTypes filterType) {
    switch (filterType) {
      case DateTimeFilterTypes.DateOnly:
        return DateTimeFieldPickerMode.date;
      case DateTimeFilterTypes.TimeOnly:
        return DateTimeFieldPickerMode.time;
      case DateTimeFilterTypes.DateTime:
        return DateTimeFieldPickerMode.dateAndTime;
    }
  }
}
