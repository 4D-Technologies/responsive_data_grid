part of responsive_data_grid;

class BoolColumn<TItem extends Object> extends GridColumn<TItem, bool> {
  BoolColumn({
    required String fieldName,
    ColumnHeader? header,
    Widget? Function(TItem row)? customFieldWidget,
    required bool? Function(TItem row) value,
    BoolFilterRules<TItem>? filterRules,
    OrderDirections sortDirection = OrderDirections.notSet,
    String trueText = "true",
    String falseText = "false",
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
          format: "$trueText|$falseText",
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
          filterRules: filterRules ?? BoolFilterRules<TItem>(),
          sortDirection: sortDirection,
        );

  @override
  List<AggregationChooser<TItem>> getAggregations({
    required Iterable<AggregateCriteria> selected,
    required void Function(AggregateCriteria aggregate, bool value) update,
  }) =>
      [
        AggregationChooser(
          column: this,
          aggregation: Aggregations.count,
          selected: selected,
          update: update,
        ),
      ];

  @override
  bool get hasAggregations => true;
}
