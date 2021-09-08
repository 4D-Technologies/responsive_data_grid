part of responsive_data_grid;

class ColumnDefinition<TItem extends Object, TValue extends dynamic> {
  final String fieldName;
  final Widget? Function(TItem row)? customFieldWidget;
  final TValue? Function(TItem row) value;
  final ColumnHeaderDefinition<TItem, TValue> header;
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

  ColumnDefinition._({
    required this.fieldName,
    ColumnHeaderDefinition<TItem, TValue>? header,
    this.customFieldWidget,
    required this.value,
    this.format,
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
  }) : this.header =
            header ?? ColumnHeaderDefinition<TItem, TValue>(empty: true) {
    assert(TItem != Object);
  }

  static ColumnDefinition<TItem, TValue>
      enumColumn<TItem extends Object, TValue extends dynamic>({
    required List<TValue> values,
    required String fieldName,
    bool filterable = false,
    FilterCriteria<TValue>? filter,
    bool sortable = false,
    OrderDirections order = OrderDirections.notSet,
    required String Function(TValue e) text,
    required TValue? Function(TItem row) value,
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
    Alignment alignment = Alignment.centerLeft,
    Alignment? headerAlignment,
    String? headerText,
    Color? headerBackgroundColor,
    Color? headerForegroundColor,
  }) =>
          ColumnDefinition<TItem, TValue>._(
            fieldName: fieldName,
            value: value,
            accentColor: accentColor,
            alignment: alignment,
            backgroundColor: backgroundColor,
            customFieldWidget: (TItem row) {
              final val = value(row);
              if (val == null) return Container();

              return Text(text(val));
            },
            foregroundColor: foregroundColor,
            largeCols: largeCols,
            maxWidth: maxWidth,
            mediumCols: mediumCols,
            minWidth: minWidth,
            smallCols: smallCols,
            textStyle: textStyle,
            width: width,
            xlCols: xlCols,
            xsCols: xsCols,
            header: ColumnHeaderDefinition(
              filterRules: ValueMapFilterRules(
                filterable: filterable,
                valueMap: Map<TValue, Widget>.fromIterable(
                  values,
                  key: (k) => k,
                  value: (v) => Text(
                    text(v),
                  ),
                ),
                criteria: filter,
              ),
              alignment: headerAlignment,
              empty: headerText == null,
              text: headerText ?? '',
              orderRules: OrderRules(
                showSort: sortable,
                direction: order,
              ),
              backgroundColor: headerBackgroundColor,
              foregroundColor: headerForegroundColor,
            ),
          );

  static ColumnDefinition<TItem, bool> boolColumn<TItem extends Object>({
    required String fieldName,
    ColumnHeaderDefinition<TItem, bool>? header,
    Widget? Function(TItem row)? customFieldWidget,
    required bool? Function(TItem row) value,
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
  }) =>
      ColumnDefinition<TItem, bool>._(
        fieldName: fieldName,
        value: value,
        accentColor: accentColor,
        alignment: alignment,
        backgroundColor: backgroundColor,
        customFieldWidget: customFieldWidget,
        foregroundColor: foregroundColor,
        format: "$trueText|$falseText",
        header: header,
        largeCols: largeCols,
        maxWidth: maxWidth,
        mediumCols: mediumCols,
        minWidth: minWidth,
        smallCols: smallCols,
        textStyle: textStyle,
        width: width,
        xlCols: xlCols,
        xsCols: xsCols,
      );

  static ColumnDefinition<TItem, String> stringColumn<TItem extends Object>({
    required String fieldName,
    ColumnHeaderDefinition<TItem, String>? header,
    Widget? Function(TItem row)? customFieldWidget,
    required String? Function(TItem row) value,
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
  }) =>
      ColumnDefinition<TItem, String>._(
        fieldName: fieldName,
        value: value,
        accentColor: accentColor,
        alignment: alignment,
        backgroundColor: backgroundColor,
        customFieldWidget: customFieldWidget,
        foregroundColor: foregroundColor,
        header: header,
        largeCols: largeCols,
        maxWidth: maxWidth,
        mediumCols: mediumCols,
        minWidth: minWidth,
        smallCols: smallCols,
        textStyle: textStyle,
        width: width,
        xlCols: xlCols,
        xsCols: xsCols,
      );

  static ColumnDefinition<TItem, DateTime>
      dateTimeColumn<TItem extends Object>({
    required String fieldName,
    ColumnHeaderDefinition<TItem, DateTime>? header,
    Widget? Function(TItem row)? customFieldWidget,
    required DateTime? Function(TItem row) value,
    String? format,
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
  }) =>
          ColumnDefinition<TItem, DateTime>._(
            fieldName: fieldName,
            value: value,
            accentColor: accentColor,
            alignment: alignment,
            backgroundColor: backgroundColor,
            customFieldWidget: customFieldWidget,
            foregroundColor: foregroundColor,
            format: format,
            header: header,
            largeCols: largeCols,
            maxWidth: maxWidth,
            mediumCols: mediumCols,
            minWidth: minWidth,
            smallCols: smallCols,
            textStyle: textStyle,
            width: width,
            xlCols: xlCols,
            xsCols: xsCols,
          );

  static ColumnDefinition<TItem, int> intColumn<TItem extends Object>({
    required String fieldName,
    ColumnHeaderDefinition<TItem, int>? header,
    Widget? Function(TItem row)? customFieldWidget,
    required int? Function(TItem row) value,
    String? format,
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
  }) =>
      ColumnDefinition<TItem, int>._(
        fieldName: fieldName,
        value: value,
        accentColor: accentColor,
        alignment: alignment,
        backgroundColor: backgroundColor,
        customFieldWidget: customFieldWidget,
        foregroundColor: foregroundColor,
        format: format,
        header: header,
        largeCols: largeCols,
        maxWidth: maxWidth,
        mediumCols: mediumCols,
        minWidth: minWidth,
        smallCols: smallCols,
        textStyle: textStyle,
        width: width,
        xlCols: xlCols,
        xsCols: xsCols,
      );

  static ColumnDefinition<TItem, double> doubleColumn<TItem extends Object>({
    required String fieldName,
    ColumnHeaderDefinition<TItem, double>? header,
    Widget? Function(TItem row)? customFieldWidget,
    required double? Function(TItem row) value,
    String? format,
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
  }) =>
      ColumnDefinition<TItem, double>._(
        fieldName: fieldName,
        value: value,
        accentColor: accentColor,
        alignment: alignment,
        backgroundColor: backgroundColor,
        customFieldWidget: customFieldWidget,
        foregroundColor: foregroundColor,
        format: format,
        header: header,
        largeCols: largeCols,
        maxWidth: maxWidth,
        mediumCols: mediumCols,
        minWidth: minWidth,
        smallCols: smallCols,
        textStyle: textStyle,
        width: width,
        xlCols: xlCols,
        xsCols: xsCols,
      );

  static ColumnDefinition<TItem, num> numColumn<TItem extends Object>({
    required String fieldName,
    ColumnHeaderDefinition<TItem, num>? header,
    Widget? Function(TItem row)? customFieldWidget,
    required num? Function(TItem row) value,
    String? format,
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
  }) =>
      ColumnDefinition<TItem, num>._(
        fieldName: fieldName,
        value: value,
        accentColor: accentColor,
        alignment: alignment,
        backgroundColor: backgroundColor,
        customFieldWidget: customFieldWidget,
        foregroundColor: foregroundColor,
        format: format,
        header: header,
        largeCols: largeCols,
        maxWidth: maxWidth,
        mediumCols: mediumCols,
        minWidth: minWidth,
        smallCols: smallCols,
        textStyle: textStyle,
        width: width,
        xlCols: xlCols,
        xsCols: xsCols,
      );

  static ColumnDefinition<TItem, TimeOfDay>
      timeOfDayColumn<TItem extends Object>({
    required String fieldName,
    ColumnHeaderDefinition<TItem, TimeOfDay>? header,
    Widget? Function(TItem row)? customFieldWidget,
    required TimeOfDay? Function(TItem row) value,
    String? format,
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
  }) =>
          ColumnDefinition<TItem, TimeOfDay>._(
            fieldName: fieldName,
            value: value,
            accentColor: accentColor,
            alignment: alignment,
            backgroundColor: backgroundColor,
            customFieldWidget: customFieldWidget,
            foregroundColor: foregroundColor,
            format: format,
            header: header,
            largeCols: largeCols,
            maxWidth: maxWidth,
            mediumCols: mediumCols,
            minWidth: minWidth,
            smallCols: smallCols,
            textStyle: textStyle,
            width: width,
            xlCols: xlCols,
            xsCols: xsCols,
          );

  ColumnDefinition<TItem, TValue> copyWith(
          {ColumnHeaderDefinition<TItem, TValue>? header}) =>
      ColumnDefinition<TItem, TValue>._(
        fieldName: this.fieldName,
        header: header ?? this.header,
        value: this.value,
      );

  Widget getHeader(ResponsiveDataGridState<TItem> grid) {
    if (this.header.empty) return Container();

    return ColumnHeaderWidget<TItem, TValue>(grid, this);
  }
}

class ColumnHeaderDefinition<TItem extends Object, TValue extends dynamic> {
  final bool empty;
  final String? text;
  final AlignmentGeometry? alignment;
  final TextAlign textAlign;
  FilterRules<TItem, DataGridColumnFilter<TItem, TValue>, TValue> filterRules;
  OrderRules orderRules;
  final bool? showMenu;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  ColumnHeaderDefinition({
    this.empty = false,
    this.text,
    this.alignment = Alignment.centerLeft,
    FilterRules<TItem, DataGridColumnFilter<TItem, TValue>, TValue>?
        filterRules,
    OrderRules? orderRules,
    this.showMenu,
    this.textAlign = TextAlign.start,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  })  : this.orderRules = orderRules ?? const OrderRules(),
        this.filterRules = filterRules ?? NotSetFilterRules<TItem, TValue>();
}
