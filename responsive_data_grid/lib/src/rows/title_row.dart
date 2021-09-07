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

class TitleRow extends StatelessWidget {
  final TitleDefinition definition;

  TitleRow(this.definition);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bannerTheme = MaterialBannerTheme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final backgroundColor = definition.backgroundColor ??
        bannerTheme.backgroundColor ??
        (colorScheme.brightness == Brightness.dark
            ? colorScheme.surface
            : colorScheme.primary);

    final foregroundColor = definition.foregroundColor ??
        (colorScheme.brightness == Brightness.dark
            ? colorScheme.onSurface
            : colorScheme.onPrimary);

    final titleTextStyle = bannerTheme.contentTextStyle ??
        theme.textTheme.headline6?.copyWith(color: foregroundColor);

    final overallIconTheme = theme.iconTheme.copyWith(color: foregroundColor);

    return ListTile(
      title: Text(
        definition.title,
        style: titleTextStyle,
      ),
      leading: definition.icon == null
          ? null
          : IconTheme(data: overallIconTheme, child: definition.icon!),
      visualDensity: VisualDensity.compact,
      tileColor: backgroundColor,
    );
  }
}
