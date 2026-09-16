part of '../../responsive_data_grid.dart';

abstract class GridColumn<TItem extends Object, TValue extends dynamic> {
  final String fieldName;
  final Widget? Function(TItem row)? customFieldWidget;
  final TValue? Function(TItem row) value;
  final ColumnHeader header;
  FilterRules<TItem, DataGridColumnFilter<TItem, TValue>, TValue> filterRules;
  OrderDirections sortDirection;
  List<AggregateCriteria> aggregations;
  double? width;
  final double? minWidth;
  final double? maxWidth;
  bool visible;
  bool frozen;

  /// Stays visible while the table scrolls horizontally without locking to
  /// the leading edge. Unlike [frozen], the column keeps its place in the
  /// order and only pins to the start or end of the viewport as it would
  /// otherwise leave view.
  bool sticky;

  /// When true, the column's initial width is the widest header or formatted
  /// cell. Custom widget cells are not measured.
  final bool autoSize;

  /// Hide consecutive equal formatted values in this column on the ungrouped
  /// pager body (not a stretched HTML rowspan).
  final bool rowspan;
  final int Function(TItem item, int rowIndex)? rowspanFor;

  /// Occupies this many adjacent body cells in table layout (headers stay 1:1).
  final int Function(TItem item)? colspan;
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
    this.visible = true,
    this.frozen = false,
    this.sticky = false,
    this.autoSize = false,
    this.rowspan = false,
    this.rowspanFor,
    this.colspan,
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
  }) : aggregations =
           aggregations ?? List<AggregateCriteria>.empty(growable: true) {
    assert(TItem != Object);
  }

  Widget getHeader(ResponsiveDataGridState<TItem> grid) {
    if (header.empty) return SizedBox();

    return ColumnHeaderWidget<TItem, TValue>(grid, this);
  }

  List<AggregationChooser<TItem>> getAggregations({
    required Iterable<AggregateCriteria> selected,
    required void Function(AggregateCriteria aggregate, bool value) update,
  });

  bool get hasAggregations;

  bool get participatesInGrouping => true;

  String? getFormattedValue(TItem item) {
    return format(value(item));
  }
}
