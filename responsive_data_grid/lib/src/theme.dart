part of '../responsive_data_grid.dart';

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

/// Outer shell: border, density, elevation, loading, resize, frozen overlay.
class GridChromeTheme {
  final Color borderColor;
  final double borderWidth;
  final VisualDensity visualDensity;
  final double elevation;
  final EdgeInsets padding;
  final double columnSpacing;
  final double rowSpacing;
  final Color loadingScrim;
  final double loadingBarWidth;
  final double loadingBarHeight;
  final double resizeHandleHeight;
  final double resizeHandleBarWidth;
  final double resizeHandleBarHeight;
  final Color frozenOverlay;

  const GridChromeTheme({
    required this.borderColor,
    required this.borderWidth,
    required this.visualDensity,
    required this.elevation,
    required this.padding,
    required this.columnSpacing,
    required this.rowSpacing,
    required this.loadingScrim,
    required this.loadingBarWidth,
    required this.loadingBarHeight,
    required this.resizeHandleHeight,
    required this.resizeHandleBarWidth,
    required this.resizeHandleBarHeight,
    required this.frozenOverlay,
  });

  GridChromeTheme copyWith({
    Color? borderColor,
    double? borderWidth,
    VisualDensity? visualDensity,
    double? elevation,
    EdgeInsets? padding,
    double? columnSpacing,
    double? rowSpacing,
    Color? loadingScrim,
    double? loadingBarWidth,
    double? loadingBarHeight,
    double? resizeHandleHeight,
    double? resizeHandleBarWidth,
    double? resizeHandleBarHeight,
    Color? frozenOverlay,
  }) {
    return GridChromeTheme(
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      visualDensity: visualDensity ?? this.visualDensity,
      elevation: elevation ?? this.elevation,
      padding: padding ?? this.padding,
      columnSpacing: columnSpacing ?? this.columnSpacing,
      rowSpacing: rowSpacing ?? this.rowSpacing,
      loadingScrim: loadingScrim ?? this.loadingScrim,
      loadingBarWidth: loadingBarWidth ?? this.loadingBarWidth,
      loadingBarHeight: loadingBarHeight ?? this.loadingBarHeight,
      resizeHandleHeight: resizeHandleHeight ?? this.resizeHandleHeight,
      resizeHandleBarWidth: resizeHandleBarWidth ?? this.resizeHandleBarWidth,
      resizeHandleBarHeight:
          resizeHandleBarHeight ?? this.resizeHandleBarHeight,
      frozenOverlay: frozenOverlay ?? this.frozenOverlay,
    );
  }

  static GridChromeTheme lerp(GridChromeTheme a, GridChromeTheme b, double t) {
    return GridChromeTheme(
      borderColor: Color.lerp(a.borderColor, b.borderColor, t)!,
      borderWidth: _lerpDouble(a.borderWidth, b.borderWidth, t),
      visualDensity: t < 0.5 ? a.visualDensity : b.visualDensity,
      elevation: _lerpDouble(a.elevation, b.elevation, t),
      padding: EdgeInsets.lerp(a.padding, b.padding, t)!,
      columnSpacing: _lerpDouble(a.columnSpacing, b.columnSpacing, t),
      rowSpacing: _lerpDouble(a.rowSpacing, b.rowSpacing, t),
      loadingScrim: Color.lerp(a.loadingScrim, b.loadingScrim, t)!,
      loadingBarWidth: _lerpDouble(a.loadingBarWidth, b.loadingBarWidth, t),
      loadingBarHeight: _lerpDouble(a.loadingBarHeight, b.loadingBarHeight, t),
      resizeHandleHeight: _lerpDouble(
        a.resizeHandleHeight,
        b.resizeHandleHeight,
        t,
      ),
      resizeHandleBarWidth: _lerpDouble(
        a.resizeHandleBarWidth,
        b.resizeHandleBarWidth,
        t,
      ),
      resizeHandleBarHeight: _lerpDouble(
        a.resizeHandleBarHeight,
        b.resizeHandleBarHeight,
        t,
      ),
      frozenOverlay: Color.lerp(a.frozenOverlay, b.frozenOverlay, t)!,
    );
  }
}

/// Header row chrome, sort/menu actions, and vertical column rules.
class GridHeaderTheme {
  final Color background;
  final Color foreground;
  final TextStyle textStyle;
  final EdgeInsets cellPadding;
  final double actionGap;
  final double iconSize;
  final double actionExtent;
  final Color sortColor;
  final Color sortActiveColor;
  final Color menuColor;
  final Color menuActiveColor;
  final Color dividerColor;
  final double dividerWidth;
  final IconData sortAscendingIcon;
  final IconData sortDescendingIcon;
  final IconData sortUnsetIcon;
  final IconData menuIcon;

  const GridHeaderTheme({
    required this.background,
    required this.foreground,
    required this.textStyle,
    required this.cellPadding,
    required this.actionGap,
    required this.iconSize,
    required this.actionExtent,
    required this.sortColor,
    required this.sortActiveColor,
    required this.menuColor,
    required this.menuActiveColor,
    required this.dividerColor,
    required this.dividerWidth,
    required this.sortAscendingIcon,
    required this.sortDescendingIcon,
    required this.sortUnsetIcon,
    required this.menuIcon,
  });

  GridHeaderTheme copyWith({
    Color? background,
    Color? foreground,
    TextStyle? textStyle,
    EdgeInsets? cellPadding,
    double? actionGap,
    double? iconSize,
    double? actionExtent,
    Color? sortColor,
    Color? sortActiveColor,
    Color? menuColor,
    Color? menuActiveColor,
    Color? dividerColor,
    double? dividerWidth,
    IconData? sortAscendingIcon,
    IconData? sortDescendingIcon,
    IconData? sortUnsetIcon,
    IconData? menuIcon,
  }) {
    return GridHeaderTheme(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      textStyle: textStyle ?? this.textStyle,
      cellPadding: cellPadding ?? this.cellPadding,
      actionGap: actionGap ?? this.actionGap,
      iconSize: iconSize ?? this.iconSize,
      actionExtent: actionExtent ?? this.actionExtent,
      sortColor: sortColor ?? this.sortColor,
      sortActiveColor: sortActiveColor ?? this.sortActiveColor,
      menuColor: menuColor ?? this.menuColor,
      menuActiveColor: menuActiveColor ?? this.menuActiveColor,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerWidth: dividerWidth ?? this.dividerWidth,
      sortAscendingIcon: sortAscendingIcon ?? this.sortAscendingIcon,
      sortDescendingIcon: sortDescendingIcon ?? this.sortDescendingIcon,
      sortUnsetIcon: sortUnsetIcon ?? this.sortUnsetIcon,
      menuIcon: menuIcon ?? this.menuIcon,
    );
  }

  static GridHeaderTheme lerp(GridHeaderTheme a, GridHeaderTheme b, double t) {
    return GridHeaderTheme(
      background: Color.lerp(a.background, b.background, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t)!,
      cellPadding: EdgeInsets.lerp(a.cellPadding, b.cellPadding, t)!,
      actionGap: _lerpDouble(a.actionGap, b.actionGap, t),
      iconSize: _lerpDouble(a.iconSize, b.iconSize, t),
      actionExtent: _lerpDouble(a.actionExtent, b.actionExtent, t),
      sortColor: Color.lerp(a.sortColor, b.sortColor, t)!,
      sortActiveColor: Color.lerp(a.sortActiveColor, b.sortActiveColor, t)!,
      menuColor: Color.lerp(a.menuColor, b.menuColor, t)!,
      menuActiveColor: Color.lerp(a.menuActiveColor, b.menuActiveColor, t)!,
      dividerColor: Color.lerp(a.dividerColor, b.dividerColor, t)!,
      dividerWidth: _lerpDouble(a.dividerWidth, b.dividerWidth, t),
      sortAscendingIcon: t < 0.5 ? a.sortAscendingIcon : b.sortAscendingIcon,
      sortDescendingIcon: t < 0.5 ? a.sortDescendingIcon : b.sortDescendingIcon,
      sortUnsetIcon: t < 0.5 ? a.sortUnsetIcon : b.sortUnsetIcon,
      menuIcon: t < 0.5 ? a.menuIcon : b.menuIcon,
    );
  }
}

/// Body rows: fill, odd/even, separators, cell padding, hover/focus.
class GridBodyTheme {
  final Color background;
  final Color? oddBackground;
  final Color hoverColor;
  final Color focusColor;
  final TextStyle textStyle;
  final EdgeInsets contentPadding;
  final double separatorThickness;
  final double dragHandleWidth;
  final double dragHandleHeight;
  final double dragIconSize;
  final double expandExtent;
  final double expandIconSize;
  final EdgeInsetsGeometry detailPadding;
  final Duration expandAnimationDuration;

  const GridBodyTheme({
    required this.background,
    this.oddBackground,
    required this.hoverColor,
    required this.focusColor,
    required this.textStyle,
    required this.contentPadding,
    required this.separatorThickness,
    required this.dragHandleWidth,
    required this.dragHandleHeight,
    required this.dragIconSize,
    required this.expandExtent,
    required this.expandIconSize,
    required this.detailPadding,
    required this.expandAnimationDuration,
  });

  Color fillForIndex(int? rowIndex) {
    final odd = oddBackground;
    if (rowIndex == null || odd == null || rowIndex.isEven) {
      return background;
    }
    return odd;
  }

  GridBodyTheme copyWith({
    Color? background,
    Color? oddBackground,
    Color? hoverColor,
    Color? focusColor,
    TextStyle? textStyle,
    EdgeInsets? contentPadding,
    double? separatorThickness,
    double? dragHandleWidth,
    double? dragHandleHeight,
    double? dragIconSize,
    double? expandExtent,
    double? expandIconSize,
    EdgeInsetsGeometry? detailPadding,
    Duration? expandAnimationDuration,
  }) {
    return GridBodyTheme(
      background: background ?? this.background,
      oddBackground: oddBackground ?? this.oddBackground,
      hoverColor: hoverColor ?? this.hoverColor,
      focusColor: focusColor ?? this.focusColor,
      textStyle: textStyle ?? this.textStyle,
      contentPadding: contentPadding ?? this.contentPadding,
      separatorThickness: separatorThickness ?? this.separatorThickness,
      dragHandleWidth: dragHandleWidth ?? this.dragHandleWidth,
      dragHandleHeight: dragHandleHeight ?? this.dragHandleHeight,
      dragIconSize: dragIconSize ?? this.dragIconSize,
      expandExtent: expandExtent ?? this.expandExtent,
      expandIconSize: expandIconSize ?? this.expandIconSize,
      detailPadding: detailPadding ?? this.detailPadding,
      expandAnimationDuration:
          expandAnimationDuration ?? this.expandAnimationDuration,
    );
  }

  static GridBodyTheme lerp(GridBodyTheme a, GridBodyTheme b, double t) {
    return GridBodyTheme(
      background: Color.lerp(a.background, b.background, t)!,
      oddBackground: Color.lerp(a.oddBackground, b.oddBackground, t),
      hoverColor: Color.lerp(a.hoverColor, b.hoverColor, t)!,
      focusColor: Color.lerp(a.focusColor, b.focusColor, t)!,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t)!,
      contentPadding: EdgeInsets.lerp(a.contentPadding, b.contentPadding, t)!,
      separatorThickness: _lerpDouble(
        a.separatorThickness,
        b.separatorThickness,
        t,
      ),
      dragHandleWidth: _lerpDouble(a.dragHandleWidth, b.dragHandleWidth, t),
      dragHandleHeight: _lerpDouble(a.dragHandleHeight, b.dragHandleHeight, t),
      dragIconSize: _lerpDouble(a.dragIconSize, b.dragIconSize, t),
      expandExtent: _lerpDouble(a.expandExtent, b.expandExtent, t),
      expandIconSize: _lerpDouble(a.expandIconSize, b.expandIconSize, t),
      detailPadding: EdgeInsetsGeometry.lerp(a.detailPadding, b.detailPadding, t)!,
      expandAnimationDuration: Duration(
        milliseconds:
            (a.expandAnimationDuration.inMilliseconds +
                    (b.expandAnimationDuration.inMilliseconds -
                            a.expandAnimationDuration.inMilliseconds) *
                        t)
                .round(),
      ),
    );
  }
}

/// Always-visible filter row under the header.
class GridFilterRowTheme {
  final Color background;
  final EdgeInsets padding;
  final EdgeInsets editorPadding;
  final double operatorIconSize;
  final double editorHeight;

  const GridFilterRowTheme({
    required this.background,
    required this.padding,
    required this.editorPadding,
    required this.operatorIconSize,
    required this.editorHeight,
  });

  GridFilterRowTheme copyWith({
    Color? background,
    EdgeInsets? padding,
    EdgeInsets? editorPadding,
    double? operatorIconSize,
    double? editorHeight,
  }) {
    return GridFilterRowTheme(
      background: background ?? this.background,
      padding: padding ?? this.padding,
      editorPadding: editorPadding ?? this.editorPadding,
      operatorIconSize: operatorIconSize ?? this.operatorIconSize,
      editorHeight: editorHeight ?? this.editorHeight,
    );
  }

  static GridFilterRowTheme lerp(
    GridFilterRowTheme a,
    GridFilterRowTheme b,
    double t,
  ) {
    return GridFilterRowTheme(
      background: Color.lerp(a.background, b.background, t)!,
      padding: EdgeInsets.lerp(a.padding, b.padding, t)!,
      editorPadding: EdgeInsets.lerp(a.editorPadding, b.editorPadding, t)!,
      operatorIconSize: _lerpDouble(a.operatorIconSize, b.operatorIconSize, t),
      editorHeight: _lerpDouble(a.editorHeight, b.editorHeight, t),
    );
  }
}

class GridToolbarTheme {
  final Color background;
  final EdgeInsets padding;
  final double searchHeight;
  final double iconExtent;
  final double searchRadius;
  final Color iconColor;

  const GridToolbarTheme({
    required this.background,
    required this.padding,
    required this.searchHeight,
    required this.iconExtent,
    required this.searchRadius,
    required this.iconColor,
  });

  GridToolbarTheme copyWith({
    Color? background,
    EdgeInsets? padding,
    double? searchHeight,
    double? iconExtent,
    double? searchRadius,
    Color? iconColor,
  }) {
    return GridToolbarTheme(
      background: background ?? this.background,
      padding: padding ?? this.padding,
      searchHeight: searchHeight ?? this.searchHeight,
      iconExtent: iconExtent ?? this.iconExtent,
      searchRadius: searchRadius ?? this.searchRadius,
      iconColor: iconColor ?? this.iconColor,
    );
  }

  static GridToolbarTheme lerp(
    GridToolbarTheme a,
    GridToolbarTheme b,
    double t,
  ) {
    return GridToolbarTheme(
      background: Color.lerp(a.background, b.background, t)!,
      padding: EdgeInsets.lerp(a.padding, b.padding, t)!,
      searchHeight: _lerpDouble(a.searchHeight, b.searchHeight, t),
      iconExtent: _lerpDouble(a.iconExtent, b.iconExtent, t),
      searchRadius: _lerpDouble(a.searchRadius, b.searchRadius, t),
      iconColor: Color.lerp(a.iconColor, b.iconColor, t)!,
    );
  }
}

class GridTitleTheme {
  final Color background;
  final Color foreground;
  final TextStyle textStyle;
  final EdgeInsets padding;
  final double iconSize;
  final double actionExtent;

  const GridTitleTheme({
    required this.background,
    required this.foreground,
    required this.textStyle,
    required this.padding,
    required this.iconSize,
    required this.actionExtent,
  });

  GridTitleTheme copyWith({
    Color? background,
    Color? foreground,
    TextStyle? textStyle,
    EdgeInsets? padding,
    double? iconSize,
    double? actionExtent,
  }) {
    return GridTitleTheme(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      iconSize: iconSize ?? this.iconSize,
      actionExtent: actionExtent ?? this.actionExtent,
    );
  }

  static GridTitleTheme lerp(GridTitleTheme a, GridTitleTheme b, double t) {
    return GridTitleTheme(
      background: Color.lerp(a.background, b.background, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t)!,
      padding: EdgeInsets.lerp(a.padding, b.padding, t)!,
      iconSize: _lerpDouble(a.iconSize, b.iconSize, t),
      actionExtent: _lerpDouble(a.actionExtent, b.actionExtent, t),
    );
  }
}

class GridPagerTheme {
  final Color background;
  final Color foreground;
  final TextStyle textStyle;
  final EdgeInsets padding;
  final Color iconColor;
  final Color disabledIconColor;
  final double iconSize;
  final double buttonExtent;
  final IconData firstIcon;
  final IconData previousIcon;
  final IconData nextIcon;
  final IconData lastIcon;

  const GridPagerTheme({
    required this.background,
    required this.foreground,
    required this.textStyle,
    required this.padding,
    required this.iconColor,
    required this.disabledIconColor,
    required this.iconSize,
    required this.buttonExtent,
    required this.firstIcon,
    required this.previousIcon,
    required this.nextIcon,
    required this.lastIcon,
  });

  GridPagerTheme copyWith({
    Color? background,
    Color? foreground,
    TextStyle? textStyle,
    EdgeInsets? padding,
    Color? iconColor,
    Color? disabledIconColor,
    double? iconSize,
    double? buttonExtent,
    IconData? firstIcon,
    IconData? previousIcon,
    IconData? nextIcon,
    IconData? lastIcon,
  }) {
    return GridPagerTheme(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      iconColor: iconColor ?? this.iconColor,
      disabledIconColor: disabledIconColor ?? this.disabledIconColor,
      iconSize: iconSize ?? this.iconSize,
      buttonExtent: buttonExtent ?? this.buttonExtent,
      firstIcon: firstIcon ?? this.firstIcon,
      previousIcon: previousIcon ?? this.previousIcon,
      nextIcon: nextIcon ?? this.nextIcon,
      lastIcon: lastIcon ?? this.lastIcon,
    );
  }

  static GridPagerTheme lerp(GridPagerTheme a, GridPagerTheme b, double t) {
    return GridPagerTheme(
      background: Color.lerp(a.background, b.background, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t)!,
      padding: EdgeInsets.lerp(a.padding, b.padding, t)!,
      iconColor: Color.lerp(a.iconColor, b.iconColor, t)!,
      disabledIconColor: Color.lerp(
        a.disabledIconColor,
        b.disabledIconColor,
        t,
      )!,
      iconSize: _lerpDouble(a.iconSize, b.iconSize, t),
      buttonExtent: _lerpDouble(a.buttonExtent, b.buttonExtent, t),
      firstIcon: t < 0.5 ? a.firstIcon : b.firstIcon,
      previousIcon: t < 0.5 ? a.previousIcon : b.previousIcon,
      nextIcon: t < 0.5 ? a.nextIcon : b.nextIcon,
      lastIcon: t < 0.5 ? a.lastIcon : b.lastIcon,
    );
  }
}

class GridGroupHeaderTheme {
  final Color background;
  final Color foreground;
  final TextStyle textStyle;
  final EdgeInsets padding;
  final double iconSize;
  final double iconExtent;

  const GridGroupHeaderTheme({
    required this.background,
    required this.foreground,
    required this.textStyle,
    required this.padding,
    required this.iconSize,
    required this.iconExtent,
  });

  GridGroupHeaderTheme copyWith({
    Color? background,
    Color? foreground,
    TextStyle? textStyle,
    EdgeInsets? padding,
    double? iconSize,
    double? iconExtent,
  }) {
    return GridGroupHeaderTheme(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      iconSize: iconSize ?? this.iconSize,
      iconExtent: iconExtent ?? this.iconExtent,
    );
  }

  static GridGroupHeaderTheme lerp(
    GridGroupHeaderTheme a,
    GridGroupHeaderTheme b,
    double t,
  ) {
    return GridGroupHeaderTheme(
      background: Color.lerp(a.background, b.background, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t)!,
      padding: EdgeInsets.lerp(a.padding, b.padding, t)!,
      iconSize: _lerpDouble(a.iconSize, b.iconSize, t),
      iconExtent: _lerpDouble(a.iconExtent, b.iconExtent, t),
    );
  }
}

class GridGroupFooterTheme {
  final Color background;
  final Color foreground;
  final TextStyle textStyle;
  final EdgeInsets padding;

  const GridGroupFooterTheme({
    required this.background,
    required this.foreground,
    required this.textStyle,
    required this.padding,
  });

  GridGroupFooterTheme copyWith({
    Color? background,
    Color? foreground,
    TextStyle? textStyle,
    EdgeInsets? padding,
  }) {
    return GridGroupFooterTheme(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
    );
  }

  static GridGroupFooterTheme lerp(
    GridGroupFooterTheme a,
    GridGroupFooterTheme b,
    double t,
  ) {
    return GridGroupFooterTheme(
      background: Color.lerp(a.background, b.background, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t)!,
      padding: EdgeInsets.lerp(a.padding, b.padding, t)!,
    );
  }
}

class GridGroupPanelTheme {
  final Color background;
  final Color foreground;
  final Color chipBackground;
  final Color chipForeground;
  final TextStyle textStyle;
  final EdgeInsets padding;
  final double iconSize;

  const GridGroupPanelTheme({
    required this.background,
    required this.foreground,
    required this.chipBackground,
    required this.chipForeground,
    required this.textStyle,
    required this.padding,
    required this.iconSize,
  });

  GridGroupPanelTheme copyWith({
    Color? background,
    Color? foreground,
    Color? chipBackground,
    Color? chipForeground,
    TextStyle? textStyle,
    EdgeInsets? padding,
    double? iconSize,
  }) {
    return GridGroupPanelTheme(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      chipBackground: chipBackground ?? this.chipBackground,
      chipForeground: chipForeground ?? this.chipForeground,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      iconSize: iconSize ?? this.iconSize,
    );
  }

  static GridGroupPanelTheme lerp(
    GridGroupPanelTheme a,
    GridGroupPanelTheme b,
    double t,
  ) {
    return GridGroupPanelTheme(
      background: Color.lerp(a.background, b.background, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      chipBackground: Color.lerp(a.chipBackground, b.chipBackground, t)!,
      chipForeground: Color.lerp(a.chipForeground, b.chipForeground, t)!,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t)!,
      padding: EdgeInsets.lerp(a.padding, b.padding, t)!,
      iconSize: _lerpDouble(a.iconSize, b.iconSize, t),
    );
  }
}

/// Column menu, group menu, aggregate chooser, and dropdown overlay.
class GridMenuTheme {
  final Color sectionBackground;
  final EdgeInsets sectionPadding;
  final TextStyle sectionTextStyle;
  final EdgeInsets itemPadding;
  final double itemMinHeight;
  final Color itemForeground;
  final Color itemIconColor;
  final Color destructiveForeground;
  final double elevation;
  final double width;
  final double maxHeight;
  final Color dividerColor;
  final double dividerHeight;
  final EdgeInsets footerPadding;
  final EdgeInsets filterInset;
  final Offset alignmentOffset;

  const GridMenuTheme({
    required this.sectionBackground,
    required this.sectionPadding,
    required this.sectionTextStyle,
    required this.itemPadding,
    required this.itemMinHeight,
    required this.itemForeground,
    required this.itemIconColor,
    required this.destructiveForeground,
    required this.elevation,
    required this.width,
    required this.maxHeight,
    required this.dividerColor,
    required this.dividerHeight,
    required this.footerPadding,
    required this.filterInset,
    required this.alignmentOffset,
  });

  GridMenuTheme copyWith({
    Color? sectionBackground,
    EdgeInsets? sectionPadding,
    TextStyle? sectionTextStyle,
    EdgeInsets? itemPadding,
    double? itemMinHeight,
    Color? itemForeground,
    Color? itemIconColor,
    Color? destructiveForeground,
    double? elevation,
    double? width,
    double? maxHeight,
    Color? dividerColor,
    double? dividerHeight,
    EdgeInsets? footerPadding,
    EdgeInsets? filterInset,
    Offset? alignmentOffset,
  }) {
    return GridMenuTheme(
      sectionBackground: sectionBackground ?? this.sectionBackground,
      sectionPadding: sectionPadding ?? this.sectionPadding,
      sectionTextStyle: sectionTextStyle ?? this.sectionTextStyle,
      itemPadding: itemPadding ?? this.itemPadding,
      itemMinHeight: itemMinHeight ?? this.itemMinHeight,
      itemForeground: itemForeground ?? this.itemForeground,
      itemIconColor: itemIconColor ?? this.itemIconColor,
      destructiveForeground:
          destructiveForeground ?? this.destructiveForeground,
      elevation: elevation ?? this.elevation,
      width: width ?? this.width,
      maxHeight: maxHeight ?? this.maxHeight,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerHeight: dividerHeight ?? this.dividerHeight,
      footerPadding: footerPadding ?? this.footerPadding,
      filterInset: filterInset ?? this.filterInset,
      alignmentOffset: alignmentOffset ?? this.alignmentOffset,
    );
  }

  static GridMenuTheme lerp(GridMenuTheme a, GridMenuTheme b, double t) {
    return GridMenuTheme(
      sectionBackground: Color.lerp(
        a.sectionBackground,
        b.sectionBackground,
        t,
      )!,
      sectionPadding: EdgeInsets.lerp(a.sectionPadding, b.sectionPadding, t)!,
      sectionTextStyle: TextStyle.lerp(
        a.sectionTextStyle,
        b.sectionTextStyle,
        t,
      )!,
      itemPadding: EdgeInsets.lerp(a.itemPadding, b.itemPadding, t)!,
      itemMinHeight: _lerpDouble(a.itemMinHeight, b.itemMinHeight, t),
      itemForeground: Color.lerp(a.itemForeground, b.itemForeground, t)!,
      itemIconColor: Color.lerp(a.itemIconColor, b.itemIconColor, t)!,
      destructiveForeground: Color.lerp(
        a.destructiveForeground,
        b.destructiveForeground,
        t,
      )!,
      elevation: _lerpDouble(a.elevation, b.elevation, t),
      width: _lerpDouble(a.width, b.width, t),
      maxHeight: _lerpDouble(a.maxHeight, b.maxHeight, t),
      dividerColor: Color.lerp(a.dividerColor, b.dividerColor, t)!,
      dividerHeight: _lerpDouble(a.dividerHeight, b.dividerHeight, t),
      footerPadding: EdgeInsets.lerp(a.footerPadding, b.footerPadding, t)!,
      filterInset: EdgeInsets.lerp(a.filterInset, b.filterInset, t)!,
      alignmentOffset: Offset.lerp(a.alignmentOffset, b.alignmentOffset, t)!,
    );
  }
}

/// Grid-specific chrome. Nested like [ThemeData] sub-themes. Defaults come
/// from [ColorScheme] / [TextTheme] / [DividerThemeData] / [visualDensity]
/// (or [cupertino.CupertinoThemeData]). Set this as a [ThemeExtension] to
/// override any element. Widget constructor values override the theme.
class ResponsiveDataGridTheme extends ThemeExtension<ResponsiveDataGridTheme> {
  final GridChromeTheme chrome;
  final GridHeaderTheme header;
  final GridBodyTheme body;
  final GridFilterRowTheme filterRow;
  final GridToolbarTheme toolbar;
  final GridTitleTheme title;
  final GridPagerTheme pager;
  final GridGroupHeaderTheme groupHeader;
  final GridGroupFooterTheme groupFooter;
  final GridGroupPanelTheme groupPanel;
  final GridMenuTheme menu;

  const ResponsiveDataGridTheme({
    required this.chrome,
    required this.header,
    required this.body,
    required this.filterRow,
    required this.toolbar,
    required this.title,
    required this.pager,
    required this.groupHeader,
    required this.groupFooter,
    required this.groupPanel,
    required this.menu,
  });

  factory ResponsiveDataGridTheme.fromTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    final divider = theme.dividerTheme;
    final headerBg = scheme.surfaceContainerLow;
    final headerFg = _contrastingForeground(
      headerBg,
      scheme,
      scheme.onSurface,
    );
    final headerStyle =
        theme.textTheme.titleSmall?.copyWith(
          color: headerFg,
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: headerFg);
    final bodyFg = scheme.onSurface;
    final bodyStyle =
        theme.textTheme.bodyMedium?.copyWith(color: bodyFg) ??
        TextStyle(fontSize: 14, color: bodyFg);
    final border = divider.color ?? scheme.outlineVariant;
    final borderWidth = divider.thickness ?? 1;
    final groupHeaderBg = scheme.surfaceContainerHigh;
    final groupHeaderFg = _contrastingForeground(
      groupHeaderBg,
      scheme,
      scheme.onSurface,
    );
    final groupFooterBg = scheme.surfaceContainer;
    final groupFooterFg = _contrastingForeground(
      groupFooterBg,
      scheme,
      scheme.onSurface,
    );
    final footerBg = scheme.surfaceContainerLow;
    final footerFg = _contrastingForeground(footerBg, scheme, scheme.onSurface);
    final titleBg = scheme.primary;
    final titleFg = _contrastingForeground(titleBg, scheme, scheme.onPrimary);
    final sortIdle = headerFg.withValues(alpha: 0.72);
    final menuIdle = headerFg.withValues(alpha: 0.72);
    final chooserFg = _contrastingForeground(
      scheme.surfaceContainer,
      scheme,
      scheme.onSurface,
    );
    final chooserStyle =
        theme.textTheme.labelLarge?.copyWith(color: chooserFg) ??
        bodyStyle.copyWith(fontSize: 13, color: chooserFg);
    final footerStyle =
        theme.textTheme.labelLarge?.copyWith(color: footerFg) ??
        bodyStyle.copyWith(fontSize: 12, color: footerFg);
    final hover = scheme.primary.withValues(alpha: 0.08);
    final menuSection = scheme.surfaceContainerHighest;
    final sectionStyle =
        theme.textTheme.labelLarge?.copyWith(color: scheme.onSurface) ??
        bodyStyle.copyWith(fontSize: 12, color: scheme.onSurface);

    return ResponsiveDataGridTheme(
      chrome: GridChromeTheme(
        borderColor: border,
        borderWidth: borderWidth,
        visualDensity: theme.visualDensity,
        elevation: 0,
        padding: const EdgeInsets.all(5),
        columnSpacing: 3,
        rowSpacing: 0,
        loadingScrim: const Color(0x33000000),
        loadingBarWidth: 40,
        loadingBarHeight: 4,
        resizeHandleHeight: 12,
        resizeHandleBarWidth: 40,
        resizeHandleBarHeight: 4,
        frozenOverlay: const Color(0x00000000),
      ),
      header: GridHeaderTheme(
        background: headerBg,
        foreground: headerFg,
        textStyle: headerStyle,
        cellPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        actionGap: 4,
        iconSize: 16,
        actionExtent: 28,
        sortColor: sortIdle,
        sortActiveColor: scheme.primary,
        menuColor: menuIdle,
        menuActiveColor: scheme.primary,
        dividerColor: border,
        dividerWidth: 1,
        sortAscendingIcon: Icons.arrow_upward,
        sortDescendingIcon: Icons.arrow_downward,
        sortUnsetIcon: Icons.unfold_more,
        menuIcon: Icons.more_vert,
      ),
      body: GridBodyTheme(
        background: scheme.surface,
        hoverColor: hover,
        focusColor: scheme.primary.withValues(alpha: 0.25),
        textStyle: bodyStyle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        separatorThickness: borderWidth,
        dragHandleWidth: 28,
        dragHandleHeight: 32,
        dragIconSize: 20,
        expandExtent: 32,
        expandIconSize: 20,
        detailPadding: const EdgeInsetsDirectional.fromSTEB(32, 8, 12, 12),
        expandAnimationDuration: const Duration(milliseconds: 150),
      ),
      filterRow: GridFilterRowTheme(
        background: headerBg,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        editorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        operatorIconSize: 16,
        editorHeight: 36,
      ),
      toolbar: GridToolbarTheme(
        background: headerBg,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        searchHeight: 40,
        iconExtent: 40,
        searchRadius: 8,
        iconColor: scheme.onSurfaceVariant,
      ),
      title: GridTitleTheme(
        background: titleBg,
        foreground: titleFg,
        textStyle:
            theme.textTheme.titleSmall?.copyWith(
              color: titleFg,
              fontWeight: FontWeight.w600,
            ) ??
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: titleFg),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        iconSize: 20,
        actionExtent: 32,
      ),
      pager: GridPagerTheme(
        background: footerBg,
        foreground: footerFg,
        textStyle: footerStyle,
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        iconColor: footerFg,
        disabledIconColor: footerFg.withValues(alpha: 0.38),
        iconSize: 20,
        buttonExtent: 36,
        firstIcon: Icons.first_page,
        previousIcon: Icons.chevron_left,
        nextIcon: Icons.chevron_right,
        lastIcon: Icons.last_page,
      ),
      groupHeader: GridGroupHeaderTheme(
        background: groupHeaderBg,
        foreground: groupHeaderFg,
        textStyle: headerStyle.copyWith(
          color: groupHeaderFg,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.all(3),
        iconSize: 20,
        iconExtent: 28,
      ),
      groupFooter: GridGroupFooterTheme(
        background: groupFooterBg,
        foreground: groupFooterFg,
        textStyle: footerStyle.copyWith(color: groupFooterFg),
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      ),
      groupPanel: GridGroupPanelTheme(
        background: scheme.surfaceContainer,
        foreground: chooserFg,
        chipBackground: scheme.surface,
        chipForeground: _contrastingForeground(
          scheme.surface,
          scheme,
          scheme.onSurface,
        ),
        textStyle: chooserStyle,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        iconSize: 18,
      ),
      menu: GridMenuTheme(
        sectionBackground: menuSection,
        sectionPadding: const EdgeInsets.all(8),
        sectionTextStyle: sectionStyle,
        itemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemMinHeight: 40,
        itemForeground: scheme.onSurface,
        itemIconColor: scheme.onSurfaceVariant,
        destructiveForeground: scheme.error,
        elevation: 4,
        width: 250,
        maxHeight: 480,
        dividerColor: border,
        dividerHeight: 1,
        footerPadding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        filterInset: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        alignmentOffset: const Offset(0, 4),
      ),
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
    final border = brightness == Brightness.dark
        ? const Color(0xFF38383A)
        : const Color(0xFFC6C6C8);
    final titleBg = theme.primaryColor;
    final titleFg = _contrastingForeground(
      titleBg,
      scheme,
      theme.primaryContrastingColor,
    );
    final headerStyle = theme.textTheme.navTitleTextStyle.copyWith(
      color: headerFg,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );
    final bodyStyle = theme.textTheme.textStyle.copyWith(
      color: bodyFg,
      fontSize: 14,
    );
    final groupHeaderFg = _contrastingForeground(
      groupHeaderBg,
      scheme,
      bodyFg,
    );
    final groupFooterFg = _contrastingForeground(
      groupFooterBg,
      scheme,
      bodyFg,
    );
    final chooserFg = _contrastingForeground(groupFooterBg, scheme, bodyFg);
    final footerStyle = bodyStyle.copyWith(fontSize: 12, color: headerFg);

    return ResponsiveDataGridTheme(
      chrome: GridChromeTheme(
        borderColor: border,
        borderWidth: 0.5,
        visualDensity: VisualDensity.compact,
        elevation: 0,
        padding: const EdgeInsets.all(5),
        columnSpacing: 3,
        rowSpacing: 0,
        loadingScrim: const Color(0x33000000),
        loadingBarWidth: 40,
        loadingBarHeight: 4,
        resizeHandleHeight: 12,
        resizeHandleBarWidth: 40,
        resizeHandleBarHeight: 4,
        frozenOverlay: const Color(0x00000000),
      ),
      header: GridHeaderTheme(
        background: headerBg,
        foreground: headerFg,
        textStyle: headerStyle,
        cellPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        actionGap: 4,
        iconSize: 16,
        actionExtent: 28,
        sortColor: headerFg.withValues(alpha: 0.72),
        sortActiveColor: theme.primaryColor,
        menuColor: headerFg.withValues(alpha: 0.72),
        menuActiveColor: theme.primaryColor,
        dividerColor: border,
        dividerWidth: 0.5,
        sortAscendingIcon: cupertino.CupertinoIcons.chevron_up,
        sortDescendingIcon: cupertino.CupertinoIcons.chevron_down,
        sortUnsetIcon: cupertino.CupertinoIcons.chevron_up_chevron_down,
        menuIcon: cupertino.CupertinoIcons.ellipsis_vertical,
      ),
      body: GridBodyTheme(
        background: rowBg,
        hoverColor: theme.primaryColor.withValues(alpha: 0.08),
        focusColor: theme.primaryColor.withValues(alpha: 0.25),
        textStyle: bodyStyle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        separatorThickness: 0.5,
        dragHandleWidth: 28,
        dragHandleHeight: 32,
        dragIconSize: 20,
        expandExtent: 32,
        expandIconSize: 20,
        detailPadding: const EdgeInsetsDirectional.fromSTEB(32, 8, 12, 12),
        expandAnimationDuration: const Duration(milliseconds: 150),
      ),
      filterRow: GridFilterRowTheme(
        background: headerBg,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        editorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        operatorIconSize: 16,
        editorHeight: 36,
      ),
      toolbar: GridToolbarTheme(
        background: headerBg,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        searchHeight: 40,
        iconExtent: 40,
        searchRadius: 8,
        iconColor: headerFg.withValues(alpha: 0.72),
      ),
      title: GridTitleTheme(
        background: titleBg,
        foreground: titleFg,
        textStyle: theme.textTheme.navTitleTextStyle.copyWith(
          color: titleFg,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        iconSize: 20,
        actionExtent: 32,
      ),
      pager: GridPagerTheme(
        background: headerBg,
        foreground: headerFg,
        textStyle: footerStyle,
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        iconColor: headerFg,
        disabledIconColor: headerFg.withValues(alpha: 0.38),
        iconSize: 20,
        buttonExtent: 36,
        firstIcon: cupertino.CupertinoIcons.chevron_left_2,
        previousIcon: cupertino.CupertinoIcons.chevron_left,
        nextIcon: cupertino.CupertinoIcons.chevron_right,
        lastIcon: cupertino.CupertinoIcons.chevron_right_2,
      ),
      groupHeader: GridGroupHeaderTheme(
        background: groupHeaderBg,
        foreground: groupHeaderFg,
        textStyle: headerStyle.copyWith(color: groupHeaderFg),
        padding: const EdgeInsets.all(3),
        iconSize: 20,
        iconExtent: 28,
      ),
      groupFooter: GridGroupFooterTheme(
        background: groupFooterBg,
        foreground: groupFooterFg,
        textStyle: footerStyle.copyWith(color: groupFooterFg),
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      ),
      groupPanel: GridGroupPanelTheme(
        background: groupFooterBg,
        foreground: chooserFg,
        chipBackground: headerBg,
        chipForeground: headerFg,
        textStyle: bodyStyle.copyWith(fontSize: 13, color: headerFg),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        iconSize: 18,
      ),
      menu: GridMenuTheme(
        sectionBackground: groupHeaderBg,
        sectionPadding: const EdgeInsets.all(8),
        sectionTextStyle: bodyStyle.copyWith(fontSize: 12, color: bodyFg),
        itemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemMinHeight: 40,
        itemForeground: bodyFg,
        itemIconColor: bodyFg.withValues(alpha: 0.72),
        destructiveForeground: scheme.error,
        elevation: 8,
        width: 250,
        maxHeight: 480,
        dividerColor: border,
        dividerHeight: 1,
        footerPadding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        filterInset: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        alignmentOffset: const Offset(0, 4),
      ),
    );
  }

  static ResponsiveDataGridTheme of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<ResponsiveDataGridTheme>() ??
        ResponsiveDataGridTheme.fromTheme(theme);
  }

  EdgeInsets resolvePadding(EdgeInsets base) {
    final density = chrome.visualDensity;
    return EdgeInsets.only(
      left: math.max(0, base.left + density.horizontal * 2),
      right: math.max(0, base.right + density.horizontal * 2),
      top: math.max(0, base.top + density.vertical * 2),
      bottom: math.max(0, base.bottom + density.vertical * 2),
    );
  }

  @override
  ResponsiveDataGridTheme copyWith({
    GridChromeTheme? chrome,
    GridHeaderTheme? header,
    GridBodyTheme? body,
    GridFilterRowTheme? filterRow,
    GridToolbarTheme? toolbar,
    GridTitleTheme? title,
    GridPagerTheme? pager,
    GridGroupHeaderTheme? groupHeader,
    GridGroupFooterTheme? groupFooter,
    GridGroupPanelTheme? groupPanel,
    GridMenuTheme? menu,
  }) {
    return ResponsiveDataGridTheme(
      chrome: chrome ?? this.chrome,
      header: header ?? this.header,
      body: body ?? this.body,
      filterRow: filterRow ?? this.filterRow,
      toolbar: toolbar ?? this.toolbar,
      title: title ?? this.title,
      pager: pager ?? this.pager,
      groupHeader: groupHeader ?? this.groupHeader,
      groupFooter: groupFooter ?? this.groupFooter,
      groupPanel: groupPanel ?? this.groupPanel,
      menu: menu ?? this.menu,
    );
  }

  @override
  ResponsiveDataGridTheme lerp(
    ThemeExtension<ResponsiveDataGridTheme>? other,
    double t,
  ) {
    if (other is! ResponsiveDataGridTheme) return this;
    return ResponsiveDataGridTheme(
      chrome: GridChromeTheme.lerp(chrome, other.chrome, t),
      header: GridHeaderTheme.lerp(header, other.header, t),
      body: GridBodyTheme.lerp(body, other.body, t),
      filterRow: GridFilterRowTheme.lerp(filterRow, other.filterRow, t),
      toolbar: GridToolbarTheme.lerp(toolbar, other.toolbar, t),
      title: GridTitleTheme.lerp(title, other.title, t),
      pager: GridPagerTheme.lerp(pager, other.pager, t),
      groupHeader: GridGroupHeaderTheme.lerp(groupHeader, other.groupHeader, t),
      groupFooter: GridGroupFooterTheme.lerp(groupFooter, other.groupFooter, t),
      groupPanel: GridGroupPanelTheme.lerp(groupPanel, other.groupPanel, t),
      menu: GridMenuTheme.lerp(menu, other.menu, t),
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
  final thickness = thicknessOverride ?? gridTheme.body.separatorThickness;
  if (thickness <= 0) {
    return const SizedBox.shrink();
  }
  return Divider(
    height: thickness,
    thickness: thickness,
    color: gridTheme.chrome.borderColor,
  );
}
