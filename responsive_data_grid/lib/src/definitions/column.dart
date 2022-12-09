part of responsive_data_grid;

abstract class GridColumn<TItem extends Object, TValue extends dynamic> {
  final String fieldName;
  final Widget? Function(TItem row)? customFieldWidget;
  final TValue? Function(TItem row) value;
  final ColumnHeader header;
  FilterRules<TItem, DataGridColumnFilter<TItem, TValue>, TValue> filterRules;
  OrderDirections sortDirection;
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
  final String? format;

  GridColumn({
    required this.fieldName,
    required this.header,
    required this.customFieldWidget,
    required this.value,
    required this.filterRules,
    required this.sortDirection,
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
  }) {
    assert(TItem != Object);
  }

  Widget getHeader(ResponsiveDataGridState<TItem> grid) {
    if (this.header.empty) return Container();

    return ColumnHeaderWidget<TItem, TValue>(grid, this);
  }
}
