part of responsive_data_grid;

class ColumnDefinition<TItem extends Object> {
  final String? fieldName;
  final Type? fieldType;
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

  ColumnDefinition({
    this.fieldName,
    this.fieldType,
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
    this.alignment = Alignment.centerLeft,
  }) : this.header = header ?? ColumnHeaderDefinition(empty: true) {
    assert(TItem != Object);

    if (fieldName == null) {
      if (this.header.orderRules.direction != OrderDirections.notSet ||
          this.header.orderRules.showSort != null) {
        throw ArgumentError(
            "If Order rules are set, then a field name is required.");
      }

      if (this.header.filterRules.filterable) {
        throw ArgumentError(
            "If filter rules are set, then field name is required.");
      }
    }
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
  FilterRules<TItem> filterRules;
  OrderRules orderRules;
  final bool? showMenu;

  ColumnHeaderDefinition({
    this.empty = false,
    this.text,
    this.alignment = Alignment.centerLeft,
    FilterRules<TItem>? filterRules,
    OrderRules? orderRules,
    this.showMenu,
    this.textAlign = TextAlign.start,
  })  : this.orderRules = orderRules ?? const OrderRules.notSet(),
        this.filterRules = filterRules ?? const FilterRules.notSet();
}
