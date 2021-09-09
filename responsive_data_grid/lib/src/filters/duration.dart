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
  Operators? op;

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
        DropdownButtonFormField<Operators>(
            items: [
              DropdownMenuItem(
                child: Text(LocalizedMessages.any),
                value: null,
              ),
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
                  op == Operators.notEqual ||
                  op == Operators.lessThan ||
                  op == Operators.lessThanOrEqualTo),
          child: Row(
            children: [],
          ),
        ),
        Visibility(
          visible: op != null && (op == Operators.between),
          child: Row(
            children: [],
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
                      values:
                          [dValue1, dValue2].where((e) => e != null).toList(),
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
