part of responsive_data_grid;

class ColumnDefinition<TItem extends Object> {
  final String fieldName;
  final Widget? Function(TItem row)? customFieldWidget;
  final dynamic Function(TItem row)? value;
  final ColumnHeaderDefinition<TItem> header;
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

  ColumnDefinition({
    required this.fieldName,
    ColumnHeaderDefinition<TItem>? header,
    this.customFieldWidget,
    this.value,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.xlCols,
    this.largeCols,
    this.mediumCols,
    this.smallCols,
    this.xsCols,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.accentColor,
    this.alignment = Alignment.centerLeft,
  }) : this.header = header ?? ColumnHeaderDefinition(empty: true) {
    assert(TItem != Object);
  }

  ColumnDefinition<TItem> copyWith({ColumnHeaderDefinition<TItem>? header}) =>
      ColumnDefinition<TItem>(
          fieldName: this.fieldName, header: header ?? this.header);
}

class ColumnHeaderDefinition<TItem extends Object> {
  final bool empty;
  final String? text;
  final AlignmentGeometry? alignment;
  final TextAlign textAlign;
  FilterRules<TItem, DataGridColumnFilter<TItem>> filterRules;
  OrderRules orderRules;
  final bool? showMenu;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  ColumnHeaderDefinition({
    this.empty = false,
    this.text,
    this.alignment = Alignment.centerLeft,
    FilterRules<TItem, DataGridColumnFilter<TItem>>? filterRules,
    OrderRules? orderRules,
    this.showMenu,
    this.textAlign = TextAlign.start,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  })  : this.orderRules = orderRules ?? const OrderRules.notSet(),
        this.filterRules = filterRules ??
            const NotSetFilterRules()
                as FilterRules<TItem, DataGridColumnFilter<TItem>>;
}
