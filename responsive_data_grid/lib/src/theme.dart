part of '../responsive_data_grid.dart';

/// Grid-specific chrome. Defaults come from [ThemeData] / [DataTableThemeData]
/// / [DividerThemeData] or [cupertino.CupertinoThemeData]; set this as a
/// [ThemeExtension] to override any element.
class ResponsiveDataGridTheme extends ThemeExtension<ResponsiveDataGridTheme> {
  final Color headerBackground;
  final Color headerForeground;
  final Color rowBackground;
  final Color rowHoverColor;
  final Color groupHeaderBackground;
  final Color groupHeaderForeground;
  final Color groupFooterBackground;
  final Color groupFooterForeground;
  final Color footerBackground;
  final Color footerForeground;
  final Color chooserBackground;
  final Color chooserForeground;
  final Color chooserChipBackground;
  final Color chooserChipForeground;
  final TextStyle chooserTextStyle;
  final Color menuSectionBackground;
  final Color borderColor;
  final double borderWidth;
  final VisualDensity visualDensity;
  final TextStyle headerTextStyle;
  final TextStyle bodyTextStyle;
  final TextStyle groupHeaderTextStyle;
  final TextStyle footerTextStyle;
  final TextStyle titleTextStyle;
  final Color titleBackground;
  final Color titleForeground;
  final EdgeInsets headerCellPadding;
  final double headerActionGap;
  final double headerIconSize;
  final double headerActionExtent;
  final Color headerSortColor;
  final Color headerSortActiveColor;
  final Color headerMenuColor;
  final Color headerMenuActiveColor;
  final Color headerDividerColor;
  final double headerDividerWidth;
  final IconData sortAscendingIcon;
  final IconData sortDescendingIcon;
  final IconData sortUnsetIcon;
  final IconData menuIcon;
  final EdgeInsets footerPadding;
  final Color pagerIconColor;
  final Color pagerDisabledIconColor;
  final IconData pagerFirstIcon;
  final IconData pagerPreviousIcon;
  final IconData pagerNextIcon;
  final IconData pagerLastIcon;
  final double menuElevation;

  const ResponsiveDataGridTheme({
    required this.headerBackground,
    required this.headerForeground,
    required this.rowBackground,
    required this.rowHoverColor,
    required this.groupHeaderBackground,
    required this.groupHeaderForeground,
    required this.groupFooterBackground,
    required this.groupFooterForeground,
    required this.footerBackground,
    required this.footerForeground,
    required this.chooserBackground,
    required this.chooserForeground,
    required this.chooserChipBackground,
    required this.chooserChipForeground,
    required this.chooserTextStyle,
    required this.menuSectionBackground,
    required this.borderColor,
    required this.borderWidth,
    required this.visualDensity,
    required this.headerTextStyle,
    required this.bodyTextStyle,
    required this.groupHeaderTextStyle,
    required this.footerTextStyle,
    required this.titleTextStyle,
    required this.titleBackground,
    required this.titleForeground,
    required this.headerCellPadding,
    required this.headerActionGap,
    required this.headerIconSize,
    required this.headerActionExtent,
    required this.headerSortColor,
    required this.headerSortActiveColor,
    required this.headerMenuColor,
    required this.headerMenuActiveColor,
    required this.headerDividerColor,
    required this.headerDividerWidth,
    required this.sortAscendingIcon,
    required this.sortDescendingIcon,
    required this.sortUnsetIcon,
    required this.menuIcon,
    required this.footerPadding,
    required this.pagerIconColor,
    required this.pagerDisabledIconColor,
    required this.pagerFirstIcon,
    required this.pagerPreviousIcon,
    required this.pagerNextIcon,
    required this.pagerLastIcon,
    required this.menuElevation,
  });

  factory ResponsiveDataGridTheme.fromTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    final table = theme.dataTableTheme;
    final divider = theme.dividerTheme;
    final headerBg =
        table.headingRowColor?.resolve(const {}) ?? scheme.surfaceContainerLow;
    final headerFg = _contrastingForeground(
      headerBg,
      scheme,
      table.headingTextStyle?.color ?? scheme.onSurface,
    );
    final headerStyle =
        (table.headingTextStyle ?? theme.textTheme.titleSmall)?.copyWith(
          color: headerFg,
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: headerFg);
    final bodyFg = table.dataTextStyle?.color ?? scheme.onSurface;
    final bodyStyle =
        (table.dataTextStyle ?? theme.textTheme.bodyMedium)?.copyWith(
          color: bodyFg,
        ) ??
        TextStyle(fontSize: 14, color: bodyFg);
    final border = divider.color ?? scheme.outlineVariant;
    final groupHeaderBg = scheme.surfaceContainerHigh;
    final groupFooterBg = scheme.surfaceContainer;
    final footerBg = scheme.surfaceContainerLow;
    final footerFg = _contrastingForeground(footerBg, scheme, scheme.onSurface);
    final titleBg = scheme.primary;
    final titleFg = _contrastingForeground(titleBg, scheme, scheme.onPrimary);
    final sortIdle = headerFg.withValues(alpha: 0.72);
    final menuIdle = headerFg.withValues(alpha: 0.72);

    return ResponsiveDataGridTheme(
      headerBackground: headerBg,
      headerForeground: headerFg,
      rowBackground: scheme.surface,
      rowHoverColor:
          table.dataRowColor?.resolve(const {WidgetState.hovered}) ??
          scheme.primary.withValues(alpha: 0.08),
      groupHeaderBackground: groupHeaderBg,
      groupHeaderForeground: _contrastingForeground(
        groupHeaderBg,
        scheme,
        scheme.onSurface,
      ),
      groupFooterBackground: groupFooterBg,
      groupFooterForeground: _contrastingForeground(
        groupFooterBg,
        scheme,
        scheme.onSurface,
      ),
      footerBackground: footerBg,
      footerForeground: footerFg,
      chooserBackground: scheme.surfaceContainer,
      chooserForeground: _contrastingForeground(
        scheme.surfaceContainer,
        scheme,
        scheme.onSurface,
      ),
      chooserChipBackground: scheme.surface,
      chooserChipForeground: _contrastingForeground(
        scheme.surface,
        scheme,
        scheme.onSurface,
      ),
      chooserTextStyle:
          theme.textTheme.labelLarge?.copyWith(
            color: _contrastingForeground(
              scheme.surfaceContainer,
              scheme,
              scheme.onSurface,
            ),
          ) ??
          bodyStyle.copyWith(
            fontSize: 13,
            color: _contrastingForeground(
              scheme.surfaceContainer,
              scheme,
              scheme.onSurface,
            ),
          ),
      menuSectionBackground: scheme.surfaceContainerHighest,
      borderColor: border,
      borderWidth: divider.thickness ?? 1,
      visualDensity: theme.visualDensity,
      headerTextStyle: headerStyle,
      bodyTextStyle: bodyStyle,
      groupHeaderTextStyle: headerStyle.copyWith(
        color: _contrastingForeground(groupHeaderBg, scheme, scheme.onSurface),
        fontWeight: FontWeight.w600,
      ),
      footerTextStyle:
          theme.textTheme.labelLarge?.copyWith(color: footerFg) ??
          bodyStyle.copyWith(fontSize: 12, color: footerFg),
      titleBackground: titleBg,
      titleForeground: titleFg,
      titleTextStyle:
          theme.textTheme.titleSmall?.copyWith(
            color: titleFg,
            fontWeight: FontWeight.w600,
          ) ??
          TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: titleFg),
      headerCellPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      headerActionGap: 4,
      headerIconSize: 16,
      headerActionExtent: 28,
      headerSortColor: sortIdle,
      headerSortActiveColor: scheme.primary,
      headerMenuColor: menuIdle,
      headerMenuActiveColor: scheme.primary,
      headerDividerColor: border,
      headerDividerWidth: 1,
      sortAscendingIcon: Icons.arrow_upward,
      sortDescendingIcon: Icons.arrow_downward,
      sortUnsetIcon: Icons.unfold_more,
      menuIcon: Icons.more_vert,
      footerPadding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      pagerIconColor: footerFg,
      pagerDisabledIconColor: footerFg.withValues(alpha: 0.38),
      pagerFirstIcon: Icons.first_page,
      pagerPreviousIcon: Icons.chevron_left,
      pagerNextIcon: Icons.chevron_right,
      pagerLastIcon: Icons.last_page,
      menuElevation: 4,
    );
  }

  factory ResponsiveDataGridTheme.fromCupertino(
    cupertino.CupertinoThemeData theme,
  ) {
    final brightness = theme.brightness ?? Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: theme.primaryColor,
      brightness: brightness,
    );
    final headerBg = _opaqueSurface(theme.barBackgroundColor, brightness);
    final rowBg = _opaqueSurface(theme.scaffoldBackgroundColor, brightness);
    final headerFg = _contrastingForeground(
      headerBg,
      scheme,
      theme.textTheme.textStyle.color ?? scheme.onSurface,
    );
    final bodyFg = _contrastingForeground(
      rowBg,
      scheme,
      theme.textTheme.textStyle.color ?? scheme.onSurface,
    );
    final groupHeaderBg = _opaqueSurface(
      brightness == Brightness.dark
          ? const Color(0xFF2C2C2E)
          : const Color(0xFFE5E5EA),
      brightness,
    );
    final groupFooterBg = _opaqueSurface(
      brightness == Brightness.dark
          ? const Color(0xFF1C1C1E)
          : const Color(0xFFF2F2F7),
      brightness,
    );
    final footerBg = headerBg;
    final footerFg = headerFg;
    final border = brightness == Brightness.dark
        ? const Color(0xFF38383A)
        : const Color(0xFFC6C6C8);
    final titleBg = theme.primaryColor;
    final titleFg = _contrastingForeground(
      titleBg,
      scheme,
      theme.primaryContrastingColor,
    );
    final headerStyle = (theme.textTheme.navTitleTextStyle).copyWith(
      color: headerFg,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );
    final bodyStyle = theme.textTheme.textStyle.copyWith(
      color: bodyFg,
      fontSize: 14,
    );

    return ResponsiveDataGridTheme(
      headerBackground: headerBg,
      headerForeground: headerFg,
      rowBackground: rowBg,
      rowHoverColor: theme.primaryColor.withValues(alpha: 0.08),
      groupHeaderBackground: groupHeaderBg,
      groupHeaderForeground: _contrastingForeground(
        groupHeaderBg,
        scheme,
        bodyFg,
      ),
      groupFooterBackground: groupFooterBg,
      groupFooterForeground: _contrastingForeground(
        groupFooterBg,
        scheme,
        bodyFg,
      ),
      footerBackground: footerBg,
      footerForeground: footerFg,
      chooserBackground: groupFooterBg,
      chooserForeground: _contrastingForeground(groupFooterBg, scheme, bodyFg),
      chooserChipBackground: headerBg,
      chooserChipForeground: headerFg,
      chooserTextStyle: bodyStyle.copyWith(fontSize: 13, color: footerFg),
      menuSectionBackground: groupHeaderBg,
      borderColor: border,
      borderWidth: 0.5,
      visualDensity: VisualDensity.compact,
      headerTextStyle: headerStyle,
      bodyTextStyle: bodyStyle,
      groupHeaderTextStyle: headerStyle.copyWith(
        color: _contrastingForeground(groupHeaderBg, scheme, bodyFg),
      ),
      footerTextStyle: bodyStyle.copyWith(fontSize: 12, color: footerFg),
      titleBackground: titleBg,
      titleForeground: titleFg,
      titleTextStyle: theme.textTheme.navTitleTextStyle.copyWith(
        color: titleFg,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      headerCellPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      headerActionGap: 4,
      headerIconSize: 16,
      headerActionExtent: 28,
      headerSortColor: headerFg.withValues(alpha: 0.72),
      headerSortActiveColor: theme.primaryColor,
      headerMenuColor: headerFg.withValues(alpha: 0.72),
      headerMenuActiveColor: theme.primaryColor,
      headerDividerColor: border,
      headerDividerWidth: 0.5,
      sortAscendingIcon: cupertino.CupertinoIcons.chevron_up,
      sortDescendingIcon: cupertino.CupertinoIcons.chevron_down,
      sortUnsetIcon: cupertino.CupertinoIcons.chevron_up_chevron_down,
      menuIcon: cupertino.CupertinoIcons.ellipsis_vertical,
      footerPadding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      pagerIconColor: footerFg,
      pagerDisabledIconColor: footerFg.withValues(alpha: 0.38),
      pagerFirstIcon: cupertino.CupertinoIcons.chevron_left_2,
      pagerPreviousIcon: cupertino.CupertinoIcons.chevron_left,
      pagerNextIcon: cupertino.CupertinoIcons.chevron_right,
      pagerLastIcon: cupertino.CupertinoIcons.chevron_right_2,
      menuElevation: 8,
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
    Color? groupFooterForeground,
    Color? footerBackground,
    Color? footerForeground,
    Color? chooserBackground,
    Color? chooserForeground,
    Color? chooserChipBackground,
    Color? chooserChipForeground,
    TextStyle? chooserTextStyle,
    Color? menuSectionBackground,
    Color? borderColor,
    double? borderWidth,
    VisualDensity? visualDensity,
    TextStyle? headerTextStyle,
    TextStyle? bodyTextStyle,
    TextStyle? groupHeaderTextStyle,
    TextStyle? footerTextStyle,
    TextStyle? titleTextStyle,
    Color? titleBackground,
    Color? titleForeground,
    EdgeInsets? headerCellPadding,
    double? headerActionGap,
    double? headerIconSize,
    double? headerActionExtent,
    Color? headerSortColor,
    Color? headerSortActiveColor,
    Color? headerMenuColor,
    Color? headerMenuActiveColor,
    Color? headerDividerColor,
    double? headerDividerWidth,
    IconData? sortAscendingIcon,
    IconData? sortDescendingIcon,
    IconData? sortUnsetIcon,
    IconData? menuIcon,
    EdgeInsets? footerPadding,
    Color? pagerIconColor,
    Color? pagerDisabledIconColor,
    IconData? pagerFirstIcon,
    IconData? pagerPreviousIcon,
    IconData? pagerNextIcon,
    IconData? pagerLastIcon,
    double? menuElevation,
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
      groupFooterForeground:
          groupFooterForeground ?? this.groupFooterForeground,
      footerBackground: footerBackground ?? this.footerBackground,
      footerForeground: footerForeground ?? this.footerForeground,
      chooserBackground: chooserBackground ?? this.chooserBackground,
      chooserForeground: chooserForeground ?? this.chooserForeground,
      chooserChipBackground:
          chooserChipBackground ?? this.chooserChipBackground,
      chooserChipForeground:
          chooserChipForeground ?? this.chooserChipForeground,
      chooserTextStyle: chooserTextStyle ?? this.chooserTextStyle,
      menuSectionBackground:
          menuSectionBackground ?? this.menuSectionBackground,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      visualDensity: visualDensity ?? this.visualDensity,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      bodyTextStyle: bodyTextStyle ?? this.bodyTextStyle,
      groupHeaderTextStyle: groupHeaderTextStyle ?? this.groupHeaderTextStyle,
      footerTextStyle: footerTextStyle ?? this.footerTextStyle,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      titleBackground: titleBackground ?? this.titleBackground,
      titleForeground: titleForeground ?? this.titleForeground,
      headerCellPadding: headerCellPadding ?? this.headerCellPadding,
      headerActionGap: headerActionGap ?? this.headerActionGap,
      headerIconSize: headerIconSize ?? this.headerIconSize,
      headerActionExtent: headerActionExtent ?? this.headerActionExtent,
      headerSortColor: headerSortColor ?? this.headerSortColor,
      headerSortActiveColor:
          headerSortActiveColor ?? this.headerSortActiveColor,
      headerMenuColor: headerMenuColor ?? this.headerMenuColor,
      headerMenuActiveColor:
          headerMenuActiveColor ?? this.headerMenuActiveColor,
      headerDividerColor: headerDividerColor ?? this.headerDividerColor,
      headerDividerWidth: headerDividerWidth ?? this.headerDividerWidth,
      sortAscendingIcon: sortAscendingIcon ?? this.sortAscendingIcon,
      sortDescendingIcon: sortDescendingIcon ?? this.sortDescendingIcon,
      sortUnsetIcon: sortUnsetIcon ?? this.sortUnsetIcon,
      menuIcon: menuIcon ?? this.menuIcon,
      footerPadding: footerPadding ?? this.footerPadding,
      pagerIconColor: pagerIconColor ?? this.pagerIconColor,
      pagerDisabledIconColor:
          pagerDisabledIconColor ?? this.pagerDisabledIconColor,
      pagerFirstIcon: pagerFirstIcon ?? this.pagerFirstIcon,
      pagerPreviousIcon: pagerPreviousIcon ?? this.pagerPreviousIcon,
      pagerNextIcon: pagerNextIcon ?? this.pagerNextIcon,
      pagerLastIcon: pagerLastIcon ?? this.pagerLastIcon,
      menuElevation: menuElevation ?? this.menuElevation,
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
      groupFooterForeground: Color.lerp(
        groupFooterForeground,
        other.groupFooterForeground,
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
      chooserForeground: Color.lerp(
        chooserForeground,
        other.chooserForeground,
        t,
      )!,
      chooserChipBackground: Color.lerp(
        chooserChipBackground,
        other.chooserChipBackground,
        t,
      )!,
      chooserChipForeground: Color.lerp(
        chooserChipForeground,
        other.chooserChipForeground,
        t,
      )!,
      chooserTextStyle: TextStyle.lerp(
        chooserTextStyle,
        other.chooserTextStyle,
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
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t)!,
      titleBackground: Color.lerp(titleBackground, other.titleBackground, t)!,
      titleForeground: Color.lerp(titleForeground, other.titleForeground, t)!,
      headerCellPadding: EdgeInsets.lerp(
        headerCellPadding,
        other.headerCellPadding,
        t,
      )!,
      headerActionGap:
          headerActionGap + (other.headerActionGap - headerActionGap) * t,
      headerIconSize:
          headerIconSize + (other.headerIconSize - headerIconSize) * t,
      headerActionExtent:
          headerActionExtent +
          (other.headerActionExtent - headerActionExtent) * t,
      headerSortColor: Color.lerp(headerSortColor, other.headerSortColor, t)!,
      headerSortActiveColor: Color.lerp(
        headerSortActiveColor,
        other.headerSortActiveColor,
        t,
      )!,
      headerMenuColor: Color.lerp(headerMenuColor, other.headerMenuColor, t)!,
      headerMenuActiveColor: Color.lerp(
        headerMenuActiveColor,
        other.headerMenuActiveColor,
        t,
      )!,
      headerDividerColor: Color.lerp(
        headerDividerColor,
        other.headerDividerColor,
        t,
      )!,
      headerDividerWidth:
          headerDividerWidth +
          (other.headerDividerWidth - headerDividerWidth) * t,
      sortAscendingIcon: t < 0.5 ? sortAscendingIcon : other.sortAscendingIcon,
      sortDescendingIcon: t < 0.5
          ? sortDescendingIcon
          : other.sortDescendingIcon,
      sortUnsetIcon: t < 0.5 ? sortUnsetIcon : other.sortUnsetIcon,
      menuIcon: t < 0.5 ? menuIcon : other.menuIcon,
      footerPadding: EdgeInsets.lerp(footerPadding, other.footerPadding, t)!,
      pagerIconColor: Color.lerp(pagerIconColor, other.pagerIconColor, t)!,
      pagerDisabledIconColor: Color.lerp(
        pagerDisabledIconColor,
        other.pagerDisabledIconColor,
        t,
      )!,
      pagerFirstIcon: t < 0.5 ? pagerFirstIcon : other.pagerFirstIcon,
      pagerPreviousIcon: t < 0.5 ? pagerPreviousIcon : other.pagerPreviousIcon,
      pagerNextIcon: t < 0.5 ? pagerNextIcon : other.pagerNextIcon,
      pagerLastIcon: t < 0.5 ? pagerLastIcon : other.pagerLastIcon,
      menuElevation: menuElevation + (other.menuElevation - menuElevation) * t,
    );
  }
}

double gridContrastRatio(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

Color _contrastingForeground(
  Color background,
  ColorScheme scheme, [
  Color? preferred,
]) {
  final candidates = <Color>[
    ?preferred,
    scheme.onSurface,
    scheme.onSurfaceVariant,
    scheme.surface,
    scheme.inverseSurface,
  ];
  for (final color in candidates) {
    if (gridContrastRatio(background, color) >= 4.5) {
      return color;
    }
  }
  return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF000000);
}

Color _opaqueSurface(Color color, Brightness brightness) {
  if (color.a >= 0.99) return color;
  final under = brightness == Brightness.dark
      ? const Color(0xFF000000)
      : const Color(0xFFFFFFFF);
  return Color.alphaBlend(color, under);
}

ThemeData materialThemeFromCupertino(
  cupertino.CupertinoThemeData cupertinoTheme,
) {
  final brightness = cupertinoTheme.brightness ?? Brightness.light;
  final surface = _opaqueSurface(
    cupertinoTheme.scaffoldBackgroundColor,
    brightness,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    platform: TargetPlatform.iOS,
    splashFactory: NoSplash.splashFactory,
    colorScheme: ColorScheme.fromSeed(
      seedColor: cupertinoTheme.primaryColor,
      brightness: brightness,
    ).copyWith(surface: surface, primary: cupertinoTheme.primaryColor),
  );
  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      ResponsiveDataGridTheme.fromCupertino(cupertinoTheme),
    ],
  );
}

ThemeData resolveHostThemeData(BuildContext context) {
  // material_ui's Theme.of synthesizes ThemeData from CupertinoTheme when no
  // Material [Theme] widget is present. Detect the real host so Cupertino apps
  // get [ResponsiveDataGridTheme.fromCupertino] chrome.
  final hasMaterialTheme =
      context.findAncestorWidgetOfExactType<Theme>() != null;
  if (hasMaterialTheme) {
    final existing = Theme.of(context);
    if (existing.extension<ResponsiveDataGridTheme>() != null) {
      return existing;
    }
    final extensions = List<ThemeExtension<dynamic>>.from(
      existing.extensions.values,
    )..add(ResponsiveDataGridTheme.fromTheme(existing));
    return existing.copyWith(extensions: extensions);
  }
  return materialThemeFromCupertino(cupertino.CupertinoTheme.of(context));
}

/// Ensures Material [Theme] and [MaterialLocalizations] exist so the grid can
/// run inside [cupertino.CupertinoApp] as well as [MaterialApp].
Widget wrapGridHost({required BuildContext context, required Widget child}) {
  final hostTheme = resolveHostThemeData(context);
  Widget result = Theme(data: hostTheme, child: child);
  if (Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) ==
      null) {
    result = Localizations.override(
      context: context,
      delegates: const [DefaultMaterialLocalizations.delegate],
      child: result,
    );
  }
  return result;
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
