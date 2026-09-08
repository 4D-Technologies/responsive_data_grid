part of '../responsive_data_grid.dart';

/// Grid-specific chrome. Defaults come from [ThemeData] / [DataTableThemeData]
/// / [DividerThemeData]; set this as a [ThemeExtension] to override.
class ResponsiveDataGridTheme extends ThemeExtension<ResponsiveDataGridTheme> {
  final Color headerBackground;
  final Color headerForeground;
  final Color rowBackground;
  final Color rowHoverColor;
  final Color groupHeaderBackground;
  final Color groupHeaderForeground;
  final Color groupFooterBackground;
  final Color footerBackground;
  final Color footerForeground;
  final Color chooserBackground;
  final Color menuSectionBackground;
  final Color borderColor;
  final double borderWidth;
  final VisualDensity visualDensity;
  final TextStyle headerTextStyle;
  final TextStyle bodyTextStyle;
  final TextStyle groupHeaderTextStyle;
  final TextStyle footerTextStyle;

  const ResponsiveDataGridTheme({
    required this.headerBackground,
    required this.headerForeground,
    required this.rowBackground,
    required this.rowHoverColor,
    required this.groupHeaderBackground,
    required this.groupHeaderForeground,
    required this.groupFooterBackground,
    required this.footerBackground,
    required this.footerForeground,
    required this.chooserBackground,
    required this.menuSectionBackground,
    required this.borderColor,
    required this.borderWidth,
    required this.visualDensity,
    required this.headerTextStyle,
    required this.bodyTextStyle,
    required this.groupHeaderTextStyle,
    required this.footerTextStyle,
  });

  factory ResponsiveDataGridTheme.fromTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    final table = theme.dataTableTheme;
    final divider = theme.dividerTheme;
    final headerBg =
        table.headingRowColor?.resolve(const {}) ??
        scheme.surfaceContainerHighest;
    final headerFg = table.headingTextStyle?.color ?? scheme.onSurface;
    final headerStyle =
        table.headingTextStyle ??
        theme.textTheme.titleSmall?.copyWith(
          color: headerFg,
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: headerFg);
    final bodyStyle =
        table.dataTextStyle ??
        theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurface) ??
        TextStyle(fontSize: 14, color: scheme.onSurface);
    final border = divider.color ?? scheme.outlineVariant;

    return ResponsiveDataGridTheme(
      headerBackground: headerBg,
      headerForeground: headerFg,
      rowBackground: scheme.surface,
      rowHoverColor:
          table.dataRowColor?.resolve(const {WidgetState.hovered}) ??
          scheme.primary.withValues(alpha: 0.08),
      groupHeaderBackground: scheme.surfaceContainerHigh,
      groupHeaderForeground: scheme.onSurface,
      groupFooterBackground: scheme.surfaceContainer,
      footerBackground: scheme.surfaceContainerHighest,
      footerForeground: scheme.onSurface,
      chooserBackground: scheme.surfaceContainer,
      menuSectionBackground: scheme.surfaceContainerHighest,
      borderColor: border,
      borderWidth: divider.thickness ?? 1,
      visualDensity: theme.visualDensity,
      headerTextStyle: headerStyle,
      bodyTextStyle: bodyStyle,
      groupHeaderTextStyle: headerStyle.copyWith(fontWeight: FontWeight.w600),
      footerTextStyle:
          theme.textTheme.labelLarge?.copyWith(color: scheme.onSurface) ??
          bodyStyle.copyWith(fontSize: 12),
    );
  }

  static ResponsiveDataGridTheme of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<ResponsiveDataGridTheme>() ??
        ResponsiveDataGridTheme.fromTheme(theme);
  }

  EdgeInsets resolvePadding(EdgeInsets base) {
    return EdgeInsets.only(
      left: math.max(0, base.left + visualDensity.horizontal * 2),
      right: math.max(0, base.right + visualDensity.horizontal * 2),
      top: math.max(0, base.top + visualDensity.vertical * 2),
      bottom: math.max(0, base.bottom + visualDensity.vertical * 2),
    );
  }

  @override
  ResponsiveDataGridTheme copyWith({
    Color? headerBackground,
    Color? headerForeground,
    Color? rowBackground,
    Color? rowHoverColor,
    Color? groupHeaderBackground,
    Color? groupHeaderForeground,
    Color? groupFooterBackground,
    Color? footerBackground,
    Color? footerForeground,
    Color? chooserBackground,
    Color? menuSectionBackground,
    Color? borderColor,
    double? borderWidth,
    VisualDensity? visualDensity,
    TextStyle? headerTextStyle,
    TextStyle? bodyTextStyle,
    TextStyle? groupHeaderTextStyle,
    TextStyle? footerTextStyle,
  }) {
    return ResponsiveDataGridTheme(
      headerBackground: headerBackground ?? this.headerBackground,
      headerForeground: headerForeground ?? this.headerForeground,
      rowBackground: rowBackground ?? this.rowBackground,
      rowHoverColor: rowHoverColor ?? this.rowHoverColor,
      groupHeaderBackground:
          groupHeaderBackground ?? this.groupHeaderBackground,
      groupHeaderForeground:
          groupHeaderForeground ?? this.groupHeaderForeground,
      groupFooterBackground:
          groupFooterBackground ?? this.groupFooterBackground,
      footerBackground: footerBackground ?? this.footerBackground,
      footerForeground: footerForeground ?? this.footerForeground,
      chooserBackground: chooserBackground ?? this.chooserBackground,
      menuSectionBackground:
          menuSectionBackground ?? this.menuSectionBackground,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      visualDensity: visualDensity ?? this.visualDensity,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      bodyTextStyle: bodyTextStyle ?? this.bodyTextStyle,
      groupHeaderTextStyle: groupHeaderTextStyle ?? this.groupHeaderTextStyle,
      footerTextStyle: footerTextStyle ?? this.footerTextStyle,
    );
  }

  @override
  ResponsiveDataGridTheme lerp(
    ThemeExtension<ResponsiveDataGridTheme>? other,
    double t,
  ) {
    if (other is! ResponsiveDataGridTheme) return this;
    return ResponsiveDataGridTheme(
      headerBackground: Color.lerp(
        headerBackground,
        other.headerBackground,
        t,
      )!,
      headerForeground: Color.lerp(
        headerForeground,
        other.headerForeground,
        t,
      )!,
      rowBackground: Color.lerp(rowBackground, other.rowBackground, t)!,
      rowHoverColor: Color.lerp(rowHoverColor, other.rowHoverColor, t)!,
      groupHeaderBackground: Color.lerp(
        groupHeaderBackground,
        other.groupHeaderBackground,
        t,
      )!,
      groupHeaderForeground: Color.lerp(
        groupHeaderForeground,
        other.groupHeaderForeground,
        t,
      )!,
      groupFooterBackground: Color.lerp(
        groupFooterBackground,
        other.groupFooterBackground,
        t,
      )!,
      footerBackground: Color.lerp(
        footerBackground,
        other.footerBackground,
        t,
      )!,
      footerForeground: Color.lerp(
        footerForeground,
        other.footerForeground,
        t,
      )!,
      chooserBackground: Color.lerp(
        chooserBackground,
        other.chooserBackground,
        t,
      )!,
      menuSectionBackground: Color.lerp(
        menuSectionBackground,
        other.menuSectionBackground,
        t,
      )!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
      visualDensity: t < 0.5 ? visualDensity : other.visualDensity,
      headerTextStyle: TextStyle.lerp(
        headerTextStyle,
        other.headerTextStyle,
        t,
      )!,
      bodyTextStyle: TextStyle.lerp(bodyTextStyle, other.bodyTextStyle, t)!,
      groupHeaderTextStyle: TextStyle.lerp(
        groupHeaderTextStyle,
        other.groupHeaderTextStyle,
        t,
      )!,
      footerTextStyle: TextStyle.lerp(
        footerTextStyle,
        other.footerTextStyle,
        t,
      )!,
    );
  }
}

Widget gridRowSeparator(BuildContext context, double? thicknessOverride) {
  final gridTheme = ResponsiveDataGridTheme.of(context);
  final thickness = thicknessOverride ?? gridTheme.borderWidth;
  if (thickness <= 0) {
    return const SizedBox.shrink();
  }
  return Divider(
    height: thickness,
    thickness: thickness,
    color: gridTheme.borderColor,
  );
}
