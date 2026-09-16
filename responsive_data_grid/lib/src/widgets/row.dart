part of '../../responsive_data_grid.dart';

class DataGridRowWidget<TItem extends Object> extends StatelessWidget {
  final TItem item;
  final List<GridColumn<TItem, dynamic>> columns;
  final void Function(TItem item)? itemTapped;
  final ThemeData theme;
  final EdgeInsets padding;
  final ResponsiveDataGridState<TItem>? gridState;
  final int? rowIndex;
  final List<int>? cellRowspans;

  DataGridRowWidget({
    super.key,
    required this.item,
    required this.columns,
    required this.itemTapped,
    required this.theme,
    required this.padding,
    this.gridState,
    this.rowIndex,
    this.cellRowspans,
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

    final expandable =
        grid?.detailBuilder != null &&
        (grid!.isRowExpandable?.call(item) ?? true);
    final expanded = gridState?.isRowExpanded(item) ?? false;

    void activate() {
      if (expandable) {
        gridState!.toggleRowExpanded(item);
        return;
      }
      itemTapped?.call(item);
    }

    Widget row = InkWell(
      onTap: itemTapped == null ? null : () => itemTapped?.call(item),
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
          child: _rowCells(
            context,
            grid!,
            item,
            themeFill,
            custom,
            expandable: expandable,
            expanded: expanded,
          ),
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

    Widget body = Semantics(
      button: itemTapped != null || expandable,
      expanded: expandable ? expanded : null,
      onTap: itemTapped == null && !expandable ? null : activate,
      child: FocusableActionDetector(
        onShowFocusHighlight: (_) {},
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
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

    if (grid.detailBuilder == null) return body;
    final detail = expanded
        ? Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(32, 8, 12, 12),
            child: grid.detailBuilder!(context, item),
          )
        : const SizedBox(width: double.infinity, height: 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        body,
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: detail,
        ),
      ],
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
    BoxDecoration? custom, {
    required bool expandable,
    required bool expanded,
  }) {
    final l10n = GridLocalizations.of(context);
    final leadingChildren = <Widget>[];
    final canReorder = gridState?.canReorderRows ?? false;
    if (canReorder && rowIndex != null) {
      leadingChildren.add(
        ReorderableDragStartListener(
          key: ValueKey('rdg-row-drag-$rowIndex'),
          index: rowIndex!,
          child: Tooltip(
            message: l10n.reorderRow,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: SizedBox(
                width: 28,
                height: 32,
                child: Icon(
                  Icons.drag_indicator,
                  size: 20,
                  semanticLabel: l10n.reorderRow,
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (expandable) {
      leadingChildren.add(
        Align(
          child: IconButton(
            key: ValueKey('rdg-detail-toggle-$item'),
            tooltip: expanded ? l10n.collapseRow : l10n.expandRow,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            icon: Icon(
              expanded ? Icons.expand_more : Icons.chevron_right,
              size: 20,
            ),
            onPressed: () => gridState!.toggleRowExpanded(item),
          ),
        ),
      );
    }
    final leading = leadingChildren.isEmpty
        ? null
        : leadingChildren.length == 1
        ? leadingChildren.first
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: leadingChildren,
          );
    final layout = GridTableLayout.maybeOf(context);
    if (layout != null && layout.layoutMode == GridLayoutMode.table) {
      return GridTableRow(
        cellCount: columns.length,
        cellBuilder: (i) {
          final span =
              cellRowspans != null && i < cellRowspans!.length
              ? cellRowspans![i]
              : 1;
          if (span == 0) return const SizedBox.shrink();
          return DataGridFieldWidget<TItem, dynamic>(
            columns[i],
            item,
            key: ValueKey('rdg-cell-${columns[i].fieldName}-$item'),
          );
        },
        widths: layout.columnWidths,
        frozenCount: layout.frozenCount,
        frozenBackground: themeFill,
        frozenDecoration: custom,
        leading: leading,
        cellColspan: (i) => columns[i].colspan?.call(item) ?? 1,
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
