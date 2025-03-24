part of responsive_data_grid;

abstract class GridColumn<TItem extends Object, TValue extends dynamic> {
  final String fieldName;
  final Widget? Function(TItem row)? customFieldWidget;
  final TValue? Function(TItem row) value;
  final ColumnHeader header;
  FilterRules<TItem, DataGridColumnFilter<TItem, TValue>, TValue> filterRules;
  OrderDirections sortDirection;
  List<AggregateCriteria> aggregations;
  final double? width;
  final double? minWidth;
  final double? maxWidth;
  final int? xlCols;
  final int? largeCols;
  final int? mediumCols;
  final int? smallCols;
  final int? xsCols;
  final AlignmentGeometry? alignment;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? accentColor;
  final String? Function(TValue? value) format;

  GridColumn({
    required this.fieldName,
    required this.header,
    required this.customFieldWidget,
    required this.value,
    required this.filterRules,
    this.sortDirection = OrderDirections.notSet,
    required this.format,
    required this.width,
    required this.minWidth,
    required this.maxWidth,
    required this.xlCols,
    required this.largeCols,
    required this.mediumCols,
    required this.smallCols,
    required this.xsCols,
    required this.textStyle,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.accentColor,
    required this.alignment,
    List<AggregateCriteria>? aggregations,
  }) : this.aggregations =
            aggregations ?? List<AggregateCriteria>.empty(growable: true) {
    assert(TItem != Object);
  }

  Widget getHeader(ResponsiveDataGridState<TItem> grid) {
    if (this.header.empty) return SizedBox();

    return ColumnHeaderWidget<TItem, TValue>(grid, this);
  }

  List<AggregationChooser<TItem>> getAggregations({
    required Iterable<AggregateCriteria> selected,
    required void Function(AggregateCriteria aggregate, bool value) update,
  });

  bool get hasAggregations;

  String? getFormattedValue(TItem item) {
    return format(value(item));
  }
}
