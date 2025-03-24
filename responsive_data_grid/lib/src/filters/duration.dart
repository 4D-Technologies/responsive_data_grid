part of responsive_data_grid;

enum DurationFilterTypes {
  all,
  noMilliseconds,
}

class DurationFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridDurationColumnFilter<TItem>, Duration> {
  final DurationFilterTypes filterType;
  final DateTime firstDate;
  final DateTime lastDate;

  DurationFilterRules({
    this.filterType = DurationFilterTypes.all,
    FilterCriteria<Duration>? criteria,
    DateTime? firstDate,
    DateTime? lastDate,
  })  : this.firstDate = firstDate ?? DateTime.parse("0001-01-01"),
        this.lastDate = lastDate ?? DateTime.parse("3000-01-01"),
        super(
          criteria: criteria,
        );

  @override
  DataGridDurationColumnFilter<TItem> showFilter(
          GridColumn<TItem, Duration> definition,
          ResponsiveDataGridState<TItem> grid) =>
      DataGridDurationColumnFilter<TItem>(definition, grid);
}

class DataGridDurationColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, Duration> {
  DataGridDurationColumnFilter(GridColumn<TItem, Duration> definition,
      ResponsiveDataGridState<TItem> grid)
      : super(definition, grid) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridDateTimeColumnFilterState<TItem>();
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
      dValue1 = criteria.values.length > 0 ? criteria.values.first : null;
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
        DropdownButtonFormField<Logic>(
            items: [
              DropdownMenuItem(
                child: Text(LocalizedMessages.any),
                value: null,
              ),
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
                  op == Logic.notEqual ||
                  op == Logic.lessThan ||
                  op == Logic.lessThanOrEqualTo),
          child: Row(
            children: [],
          ),
        ),
        Visibility(
          visible: op != null && (op == Logic.between),
          child: Row(
            children: [],
          ),
        ),
      ],
    );
  }
}
