part of responsive_data_grid;

class WidgetColumn<TItem extends Object> extends GridColumn<TItem, void> {
  WidgetColumn({
    String? fieldName,
    required Widget Function(TItem item) widget,
    List<AggregateCriteria>? aggregations,
    WidgetColumnHeader? header,
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
          fieldName: fieldName ?? math.Random().nextDouble().toString(),
          value: (item) => null,
          accentColor: accentColor,
          alignment: alignment,
          backgroundColor: backgroundColor,
          customFieldWidget: widget,
          foregroundColor: foregroundColor,
          format: (value) => null,
          header: header ?? WidgetColumnHeader(),
          largeCols: largeCols,
          maxWidth: maxWidth,
          mediumCols: mediumCols,
          minWidth: minWidth,
          smallCols: smallCols,
          textStyle: textStyle,
          width: width,
          xlCols: xlCols,
          xsCols: xsCols,
          filterRules: NoFilterRules(),
          sortDirection: OrderDirections.notSet,
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
          aggregation: Aggregations.count,
          selected: selected,
          update: update,
        ),
      ];

  @override
  bool get hasAggregations => true;
}

class WidgetColumnHeader extends ColumnHeader {
  WidgetColumnHeader({
    bool empty = false,
    String? text,
    AlignmentGeometry alignment = Alignment.centerLeft,
    TextAlign textAlign = TextAlign.start,
    TextStyle? textStyle,
    Color? backgroundColor,
    Color? foregroundColor,
  }) : super(
          text: text,
          alignment: alignment,
          backgroundColor: backgroundColor,
          empty: empty,
          foregroundColor: foregroundColor,
          showFilter: false,
          showOrderBy: false,
          textAlign: textAlign,
          textStyle: textStyle,
        );
}
