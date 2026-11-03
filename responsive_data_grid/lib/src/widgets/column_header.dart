part of '../../responsive_data_grid.dart';

class ColumnHeaderWidget<TItem extends Object, TValue extends dynamic>
    extends StatefulWidget {
  final GridColumn<TItem, TValue> definition;
  final ResponsiveDataGridState<TItem> gridState;

  ColumnHeaderWidget(this.gridState, this.definition, {super.key}) {
    assert(TItem != dynamic);
  }

  @override
  State<StatefulWidget> createState() => ColumnHeaderState<TItem, TValue>();
}

class ColumnHeaderState<TItem extends Object, TValue extends dynamic>
    extends State<ColumnHeaderWidget<TItem, TValue>> {
  ColumnHeaderState() {
    assert(TItem != dynamic);
  }

  void toggleOrder() async {
    switch (widget.definition.sortDirection) {
      case OrderDirections.notSet:
        widget.definition.sortDirection = OrderDirections.ascending;
        break;
      case OrderDirections.ascending:
        widget.definition.sortDirection = OrderDirections.descending;
        break;
      default:
        widget.definition.sortDirection = OrderDirections.notSet;
        break;
    }

    widget.gridState._updateOrderByCriteria(widget.definition);
  }

  @override
  Widget build(BuildContext context) {
    final gridTheme = ResponsiveDataGridTheme.of(context);
    final grid = widget.gridState;
    final header = widget.definition.header;

    final foregroundColor =
        header.foregroundColor ??
        widget.definition.foregroundColor ??
        gridTheme.header.foreground;

    final textStyle =
        header.textStyle?.copyWith(color: foregroundColor) ??
        gridTheme.header.textStyle.copyWith(color: foregroundColor);

    final padding = gridTheme.resolvePadding(
      header.padding ?? gridTheme.header.cellPadding,
    );
    final iconSize = header.iconSize ?? gridTheme.header.iconSize;
    final sorted = widget.definition.sortDirection != OrderDirections.notSet;
    final menuActive =
        widget.definition.aggregations.isNotEmpty ||
        widget.definition.filterRules.criteria != null;

    final showSort =
        widget.definition.header.showOrderBy &&
        grid.widget.sortable != SortableOptions.none;
    final showMenu = !header.empty;

    IconData sortIcon;
    switch (widget.definition.sortDirection) {
      case OrderDirections.ascending:
        sortIcon = gridTheme.header.sortAscendingIcon;
        break;
      case OrderDirections.descending:
        sortIcon = gridTheme.header.sortDescendingIcon;
        break;
      default:
        sortIcon = gridTheme.header.sortUnsetIcon;
        break;
    }

    final sortIndex = widget.gridState.sortIndexFor(
      widget.definition.fieldName,
    );
    final sortButton = GridChromeIconButton(
      key: ValueKey('rdg-header-sort-${widget.definition.fieldName}'),
      icon: Icon(sortIcon),
      color:
          header.sortColor ??
          (sorted
              ? gridTheme.header.sortActiveColor
              : gridTheme.header.sortColor),
      size: iconSize,
      extent: gridTheme.header.actionExtent,
      tooltip: GridLocalizations.of(context).sort,
      onPressed: toggleOrder,
    );
    final sortControl = sortIndex == null
        ? sortButton
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              sortButton,
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 1),
                child: Text(
                  '$sortIndex',
                  key: ValueKey(
                    'rdg-header-sort-index-${widget.definition.fieldName}',
                  ),
                  style: textStyle.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: header.sortColor ?? gridTheme.header.sortActiveColor,
                  ),
                ),
              ),
            ],
          );
    final menuButton = ColumnMenu(
      key: ValueKey('rdg-header-menu-${widget.definition.fieldName}'),
      column: widget.definition,
      theme: Theme.of(context),
      gridState: widget.gridState,
      icon: gridTheme.header.menuIcon,
      iconColor:
          header.menuColor ??
          (menuActive
              ? gridTheme.header.menuActiveColor
              : gridTheme.header.menuColor),
      iconSize: iconSize,
    );

    final title = Align(
      alignment: header.alignment,
      child: Text(
        header.text ?? '',
        textAlign: header.textAlign,
        style: textStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
      ),
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showSort) sortControl,
        if (showSort && showMenu) SizedBox(width: gridTheme.header.actionGap),
        if (showMenu) menuButton,
      ],
    );

    final l10n = GridLocalizations.of(context);
    final headerLabel = StringBuffer(header.text ?? widget.definition.fieldName);
    if (widget.definition.sortDirection == OrderDirections.ascending) {
      headerLabel.write(', ${l10n.sortAscending}');
    } else if (widget.definition.sortDirection == OrderDirections.descending) {
      headerLabel.write(', ${l10n.sortDescending}');
    }

    return Semantics(
      header: true,
      button: showSort,
      label: headerLabel.toString(),
      onTap: showSort ? toggleOrder : null,
      child: FocusableActionDetector(
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              if (showSort) toggleOrder();
              return null;
            },
          ),
        },
        child: ColoredBox(
      color:
          header.backgroundColor ??
          widget.definition.backgroundColor ??
          const Color(0x00000000),
      child: Padding(
        padding: padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!showSort && !showMenu) {
              return title;
            }
            final actionExtent =
                (showSort ? gridTheme.header.actionExtent : 0.0) +
                (showSort && sortIndex != null ? 10.0 : 0.0) +
                (showMenu ? gridTheme.header.actionExtent : 0.0) +
                (showSort && showMenu ? gridTheme.header.actionGap : 0.0);
            final maxActions = math.max(0.0, constraints.maxWidth * 0.65);
            final actionsWidth = math.min(actionExtent, maxActions);
            return Row(
              children: [
                Expanded(child: title),
                SizedBox(
                  width: actionsWidth,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: actions,
                  ),
                ),
              ],
            );
          },
        ),
      ),
        ),
      ),
    );
  }
}
