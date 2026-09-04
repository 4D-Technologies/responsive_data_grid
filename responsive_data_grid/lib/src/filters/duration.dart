part of '../../responsive_data_grid.dart';

enum DurationFilterTypes { all, noMilliseconds }

class DurationFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridDurationColumnFilter<TItem>, Duration> {
  final DurationFilterTypes filterType;
  final DateTime firstDate;
  final DateTime lastDate;

  DurationFilterRules({
    this.filterType = DurationFilterTypes.all,
    super.criteria,
    DateTime? firstDate,
    DateTime? lastDate,
  }) : firstDate = firstDate ?? DateTime.parse("0001-01-01"),
       lastDate = lastDate ?? DateTime.parse("3000-01-01");

  @override
  DataGridDurationColumnFilter<TItem> showFilter(
    GridColumn<TItem, Duration> definition,
    ResponsiveDataGridState<TItem> grid,
  ) => DataGridDurationColumnFilter<TItem>(definition, grid);
}

class DataGridDurationColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, Duration> {
  DataGridDurationColumnFilter(super.definition, super.grid, {super.key}) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridDurationColumnFilterState<TItem>();
}

class DataGridDurationColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem, Duration> {
  Duration? dValue1;
  Duration? dValue2;
  Logic? op;

  late DurationFilterRules<TItem> filterRules;

  @override
  initState() {
    filterRules = widget.definition.filterRules as DurationFilterRules<TItem>;

    final criteria = filterRules.criteria;
    if (criteria != null) {
      dValue1 = criteria.values.isNotEmpty ? criteria.values.first : null;
      dValue2 = criteria.values.length > 1 ? criteria.values.last : null;
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
          items: [
            DropdownMenuItem(value: null, child: Text(LocalizedMessages.any)),
            DropdownMenuItem(
              value: Logic.greaterThan,
              child: Text(Logic.greaterThan.toString()),
            ),
            DropdownMenuItem(
              value: Logic.greaterThanOrEqualTo,
              child: Text(Logic.greaterThanOrEqualTo.toString()),
            ),
            DropdownMenuItem(
              value: Logic.equals,
              child: Text(Logic.equals.toString()),
            ),
            DropdownMenuItem(
              value: Logic.lessThan,
              child: Text(Logic.lessThan.toString()),
            ),
            DropdownMenuItem(
              value: Logic.lessThanOrEqualTo,
              child: Text(Logic.lessThanOrEqualTo.toString()),
            ),
            DropdownMenuItem(
              value: Logic.between,
              child: Text(Logic.between.toString()),
            ),
            DropdownMenuItem(
              value: Logic.notEqual,
              child: Text(Logic.notEqual.toString()),
            ),
          ],
          initialValue: op,
          onChanged: (Logic? value) {
            setState(() {
              op = value;
              writeCriteria(op, [
                ?dValue1,
                ?dValue2,
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
                  op == Logic.notEqual ||
                  op == Logic.lessThan ||
                  op == Logic.lessThanOrEqualTo),
          child: TextField(
            decoration: const InputDecoration(hintText: 'minutes'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final minutes = int.tryParse(value);
              setState(() {
                dValue1 = minutes == null ? null : Duration(minutes: minutes);
                writeCriteria(op, [
                  ?dValue1,
                  ?dValue2,
                ]);
              });
            },
          ),
        ),
        Visibility(
          visible: op != null && (op == Logic.between),
          child: TextField(
            decoration: const InputDecoration(hintText: 'minutes'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final minutes = int.tryParse(value);
              setState(() {
                dValue2 = minutes == null ? null : Duration(minutes: minutes);
                writeCriteria(op, [
                  ?dValue1,
                  ?dValue2,
                ]);
              });
            },
          ),
        ),
      ],
    );
  }
}
