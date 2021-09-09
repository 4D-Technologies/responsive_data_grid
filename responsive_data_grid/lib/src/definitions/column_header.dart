part of responsive_data_grid;

class ColumnHeader {
  final bool empty;
  final String? text;
  final AlignmentGeometry alignment;
  final TextAlign textAlign;
  final bool showFilter;
  final bool showOrderBy;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ColumnHeader({
    this.empty = false,
    this.text,
    this.alignment = Alignment.centerLeft,
    this.showFilter = false,
    this.showOrderBy = false,
    this.textAlign = TextAlign.start,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ColumnHeader &&
        other.empty == empty &&
        other.text == text &&
        other.alignment == alignment &&
        other.textAlign == textAlign &&
        other.showFilter == showFilter &&
        other.showOrderBy == showOrderBy &&
        other.textStyle == textStyle &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor;
  }

  @override
  int get hashCode {
    return empty.hashCode ^
        text.hashCode ^
        alignment.hashCode ^
        textAlign.hashCode ^
        showFilter.hashCode ^
        showOrderBy.hashCode ^
        textStyle.hashCode ^
        backgroundColor.hashCode ^
        foregroundColor.hashCode;
  }

  @override
  String toString() {
    return 'ColumnHeader(empty: $empty, text: $text, alignment: $alignment, textAlign: $textAlign, showMenu: $showMenu, textStyle: $textStyle, backgroundColor: $backgroundColor, foregroundColor: $foregroundColor)';
  }

  ColumnHeader copyWith({
    bool Function()? empty,
    String? Function()? text,
    AlignmentGeometry Function()? alignment,
    TextAlign Function()? textAlign,
    bool Function()? showFilter,
    bool Function()? showOrderBy,
    TextStyle? Function()? textStyle,
    Color? Function()? backgroundColor,
    Color? Function()? foregroundColor,
  }) {
    return ColumnHeader(
      empty: empty == null ? this.empty : empty(),
      text: text == null ? this.text : text(),
      alignment: alignment == null ? this.alignment : alignment(),
      textAlign: textAlign == null ? this.textAlign : textAlign(),
      showFilter: showFilter == null ? this.showFilter : showFilter(),
      showOrderBy: showOrderBy == null ? this.showFilter : showOrderBy(),
      textStyle: textStyle == null ? this.textStyle : textStyle(),
      backgroundColor:
          backgroundColor == null ? this.backgroundColor : backgroundColor(),
      foregroundColor:
          foregroundColor == null ? this.foregroundColor : foregroundColor(),
    );
  }
}
