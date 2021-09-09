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
          format: null,
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
            valueMap: Map<TValue, Widget>.fromIterable(
              values,
              key: (k) => k,
              value: (v) => Text(
                valueText(v),
              ),
            ),
            criteria: filter,
          ),
          sortDirection: sortDirection,
        );
}
