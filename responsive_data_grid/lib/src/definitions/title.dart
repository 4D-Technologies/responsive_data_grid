part of responsive_data_grid;

class TitleDefinition {
  final Icon? icon;
  final String title;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const TitleDefinition({
    required this.title,
    this.icon,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
  });
}
