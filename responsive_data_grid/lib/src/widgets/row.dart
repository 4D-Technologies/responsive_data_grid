part of '../../responsive_data_grid.dart';

class DataGridRowWidget<TItem extends Object> extends StatelessWidget {
  final TItem item;
  final List<GridColumn<TItem, dynamic>> columns;
  final void Function(TItem item)? itemTapped;
  final ThemeData theme;
  final EdgeInsets padding;

  DataGridRowWidget({
    super.key,
    required this.item,
    required this.columns,
    required this.itemTapped,
    required this.theme,
    required this.padding,
  }) {
    assert(TItem != Object);
  }

  @override
  Widget build(BuildContext context) {
    final grid = context
        .findAncestorWidgetOfExactType<ResponsiveDataGrid<TItem>>();
    final gridTheme = ResponsiveDataGridTheme.of(context);
    final custom = grid?.rowDecoration?.call(item);
    final themeFill = gridTheme.rowBackground;

    void activate() {
      itemTapped?.call(item);
    }

    Widget row = InkWell(
      onTap: itemTapped == null ? null : activate,
      enableFeedback: true,
      excludeFromSemantics: false,
      hoverColor: gridTheme.rowHoverColor,
      focusColor: gridTheme.headerSortActiveColor.withValues(alpha: 0.25),
      mouseCursor: itemTapped != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: DefaultTextStyle(
        style: gridTheme.bodyTextStyle,
        child: Padding(
          padding: _tablePadding(context, gridTheme, padding),
          child: _rowCells(context, grid!, item, themeFill, custom),
        ),
      ),
    );
    if (custom != null) {
      row = DecoratedBox(decoration: custom, child: row);
    }
    row = DecoratedBox(
      decoration: BoxDecoration(color: themeFill),
      child: row,
    );

    return Semantics(
      button: itemTapped != null,
      onTap: itemTapped == null ? null : activate,
      child: FocusableActionDetector(
        onShowFocusHighlight: (_) {},
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              activate();
              return null;
            },
          ),
        },
        child: row,
      ),
    );
  }

  EdgeInsets _tablePadding(
    BuildContext context,
    ResponsiveDataGridTheme gridTheme,
    EdgeInsets padding,
  ) {
    final resolved = gridTheme.resolvePadding(padding);
    final layout = GridTableLayout.maybeOf(context);
    if (layout != null && layout.layoutMode == GridLayoutMode.table) {
      return EdgeInsets.only(top: resolved.top, bottom: resolved.bottom);
    }
    return resolved;
  }

  Widget _rowCells(
    BuildContext context,
    ResponsiveDataGrid<TItem> grid,
    TItem item,
    Color themeFill,
    BoxDecoration? custom,
  ) {
    final layout = GridTableLayout.maybeOf(context);
    if (layout != null && layout.layoutMode == GridLayoutMode.table) {
      return GridTableRow(
        cellCount: columns.length,
        cellBuilder: (i) =>
            DataGridFieldWidget<TItem, dynamic>(columns[i], item),
        widths: layout.columnWidths,
        frozenCount: layout.frozenCount,
        frozenBackground: themeFill,
        frozenDecoration: custom,
      );
    }
    return BootstrapRow(
      textDirection: Directionality.of(context),
      alignment: WrapAlignment.start,
      runSpacing: grid.rowSpacing,
      crossAxisAlignment:
          grid.rowCrossAxisAlignment == CrossAxisAlignment.start ||
              grid.rowCrossAxisAlignment == CrossAxisAlignment.stretch
          ? WrapCrossAlignment.start
          : grid.rowCrossAxisAlignment == CrossAxisAlignment.center
          ? WrapCrossAlignment.center
          : WrapCrossAlignment.end,
      children: getColumns(context, grid, item),
      totalSegments: layout?.totalSegments ?? grid.reactiveSegments,
    );
  }

  List<BootstrapCol> getColumns(
    BuildContext context,
    ResponsiveDataGrid<TItem> grid,
    TItem item,
  ) {
    return columns.map((c) {
      return BootstrapCol(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: columns.indexOf(c) == 0 ? 0 : grid.columnSpacing,
          ),
          child: DataGridFieldWidget<TItem, dynamic>(c, item),
        ),
        lg: c.largeCols ?? c.mediumCols ?? c.smallCols ?? c.xsCols ?? 12,
        md: c.mediumCols ?? c.smallCols ?? c.xsCols ?? 12,
        sm: c.smallCols ?? c.xsCols ?? 12,
        xl:
            c.xlCols ??
            c.largeCols ??
            c.mediumCols ??
            c.smallCols ??
            c.xsCols ??
            12,
        xs: c.xsCols ?? 12,
      );
    }).toList();
  }
}
