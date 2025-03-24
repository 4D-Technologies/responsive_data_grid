part of responsive_data_grid;

class DateTimeColumn<TItem extends Object> extends GridColumn<TItem, DateTime> {
  DateTimeColumn({
    required String fieldName,
    ColumnHeader? header,
    Widget? Function(TItem row)? customFieldWidget,
    required DateTime? Function(TItem row) value,
    DateTimeFilterRules<TItem>? filterRules,
    OrderDirections sortDirection = OrderDirections.notSet,
    List<AggregateCriteria>? aggregations,
    intl.DateFormat? format,
    double? width,
    double? minWidth,
    double? maxWidth,
    int? xlCols,
    int? largeCols,
    int? mediumCols,
    int? smallCols,
    int? xsCols,
    TextStyle? textStyle,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? accentColor,
    AlignmentGeometry alignment = Alignment.centerLeft,
  }) : super(
          fieldName: fieldName,
          value: value,
          accentColor: accentColor,
          alignment: alignment,
          backgroundColor: backgroundColor,
          customFieldWidget: customFieldWidget,
          foregroundColor: foregroundColor,
          format: (value) => value == null
              ? null
              : format?.format(value) ?? intl.DateFormat().format(value),
          header: header ?? ColumnHeader(),
          largeCols: largeCols,
          maxWidth: maxWidth,
          mediumCols: mediumCols,
          minWidth: minWidth,
          smallCols: smallCols,
          textStyle: textStyle,
          width: width,
          xlCols: xlCols,
          xsCols: xsCols,
          filterRules: filterRules ??
              DateTimeFilterRules<TItem>(
                filterType: DateTimeFilterTypes.DateTime,
              ),
          sortDirection: sortDirection,
          aggregations: aggregations,
        );

  @override
  List<AggregationChooser<TItem>> getAggregations({
    required Iterable<AggregateCriteria> selected,
    required void Function(AggregateCriteria aggregate, bool value) update,
  }) =>
      [
        AggregationChooser(
          column: this,
          aggregation: Aggregations.average,
          selected: selected,
          update: update,
        ),
        AggregationChooser(
          column: this,
          aggregation: Aggregations.maximum,
          selected: selected,
          update: update,
        ),
        AggregationChooser(
          column: this,
          aggregation: Aggregations.minimum,
          selected: selected,
          update: update,
        ),
        AggregationChooser(
          column: this,
          aggregation: Aggregations.sum,
          selected: selected,
          update: update,
        ),
      ];

  @override
  bool get hasAggregations => true;
}
