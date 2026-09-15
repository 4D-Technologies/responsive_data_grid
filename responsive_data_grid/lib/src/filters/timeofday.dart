part of '../../responsive_data_grid.dart';

class TimeOfDayFilterRules<TItem extends Object>
    extends
        FilterRules<TItem, DataGridTimeOfDayColumnFilter<TItem>, TimeOfDay> {
  TimeOfDayFilterRules({super.criteria});

  @override
  DataGridTimeOfDayColumnFilter<TItem> showFilter(
    GridColumn<TItem, TimeOfDay> definition,
    ResponsiveDataGridState<TItem> grid,
  ) => DataGridTimeOfDayColumnFilter(definition, grid);
}

class DataGridTimeOfDayColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, TimeOfDay> {
  DataGridTimeOfDayColumnFilter(super.definition, super.grid, {super.key}) {
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
  void initState() {
    filterRules = widget.definition.filterRules as TimeOfDayFilterRules;

    final criteria = filterRules.criteria;
    if (criteria != null) {
      tStart = criteria.values.isNotEmpty ? criteria.values.first : null;
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
          isExpanded: true,
          items: gridFilterLogicItems(context, gridComparableFilterLogics),
          initialValue: op,
          onChanged: (Logic? value) {
            setState(() {
              op = value;
              writeCriteria(op, [
                ?tStart,
                ?tEnd,
              ]);
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
                  op == Logic.notEqual),
          child: DateTimeField.time(
            decoration: InputDecoration(hintText: op?.toString()),
            value: tStart?.toDateTime(),
            initialPickerDateTime: tStart?.toDateTime(),
            onChanged: (DateTime? value) {
              setState(() {
                tStart = value == null ? null : TimeOfDay.fromDateTime(value);
                writeCriteria(op, [
                  ?tStart,
                  ?tEnd,
                ]);
              });
            },
          ),
        ),
        Visibility(
          visible:
              op != null &&
              (op == Logic.lessThan ||
                  op == Logic.lessThanOrEqualTo ||
                  op == Logic.between),
          child: DateTimeField.time(
            decoration: InputDecoration(hintText: op?.toString()),
            value: tEnd?.toDateTime(),
            initialPickerDateTime: tEnd?.toDateTime(),
            onChanged: (DateTime? value) {
              setState(() {
                tEnd = value == null ? null : TimeOfDay.fromDateTime(value);
                writeCriteria(op, [
                  ?tStart,
                  ?tEnd,
                ]);
              });
            },
          ),
        ),
      ],
    );
  }
}
