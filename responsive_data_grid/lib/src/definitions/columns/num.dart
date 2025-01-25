part of responsive_data_grid;

class NumColumn<TItem extends Object> extends GridColumn<TItem, num> {
  NumColumn({
    required String fieldName,
    ColumnHeader? header,
    Widget? Function(TItem row)? customFieldWidget,
    required num? Function(TItem row) value,
    NumFilterRules<TItem>? filterRules,
    OrderDirections sortDirection = OrderDirections.notSet,
    List<AggregateCriteria>? aggregations,
    intl.NumberFormat? format,
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
          format: (value) =>
              format?.format(value) ?? intl.NumberFormat().format(value),
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
          filterRules: filterRules ?? NumFilterRules<TItem>(),
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
          aggregation: Aggregations.maxium,
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
