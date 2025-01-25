part of responsive_data_grid;

class EnumColumn<TItem extends Object, TValue extends Enum>
    extends GridColumn<TItem, TValue> {
  final List<TValue> values;
  EnumColumn({
    required this.values,
    required String fieldName,
    ColumnHeader? header,
    Widget? Function(TItem row)? customFieldWidget,
    required String Function(TValue e) valueText,
    required TValue? Function(TItem row) value,
    FilterCriteria<TValue>? filter,
    OrderDirections sortDirection = OrderDirections.notSet,
    List<AggregateCriteria>? aggregations,
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
          customFieldWidget: customFieldWidget ??
              (TItem row) {
                final val = value(row);
                if (val == null) return Container();

                return Text(valueText(val));
              },
          foregroundColor: foregroundColor,
          format: (value) => value == null ? null : valueText(value),
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
          filterRules: ValueMapFilterRules(
            valueMap: Map<TValue, Widget>.fromEntries(
              values.map(
                (e) => MapEntry(
                  e,
                  Text(
                    valueText(e),
                  ),
                ),
              ),
            ),
            criteria: filter,
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
          aggregation: Aggregations.count,
          selected: selected,
          update: update,
        ),
      ];

  @override
  bool get hasAggregations => true;
}
