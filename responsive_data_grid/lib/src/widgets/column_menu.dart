part of '../../responsive_data_grid.dart';

class ColumnMenu<T extends Object> extends DropDownViewWidget {
  final GridColumn<T, dynamic> column;
  final ResponsiveDataGridState<T> gridState;

  const ColumnMenu({
    super.key,
    required this.column,
    required super.theme,
    required this.gridState,
    required super.icon,
    super.iconColor,
    super.iconSize,
  });

  void updateAggregations(AggregateCriteria aggregation, bool selected) {
    if (selected) {
      if (column.aggregations.any((a) => a == aggregation)) return;

      column.aggregations.add(aggregation);
    } else {
      column.aggregations.removeWhere((a) => a == aggregation);
    }
  }

  @override
  Widget build(
    BuildContext context,
    void Function(BuildContext context) close, {
    double? maxHeight,
  }) {
    final l10n = GridLocalizations.of(context);
    final gridTheme = ResponsiveDataGridTheme.of(context);
    final aggregates =
        gridState.widget.allowAggregations && column.header.showAggregations
        ? column.getAggregations(
            selected: column.aggregations,
            update: updateAggregations,
          )
        : <AggregationChooser<T>>[];
    final grouped =
        gridState.widget.allowGrouping &&
        (gridState.criteria.groupBy?.any(
              (g) => g.fieldName == column.fieldName,
            ) ??
            false);
    final sortable =
        column.header.showOrderBy &&
        gridState.widget.sortable != SortableOptions.none;
    final canHide = gridState.layoutColumns.length > 1;

    final menu = gridTheme.menu;
    Widget section(String title) {
      return DecoratedBox(
        decoration: BoxDecoration(color: menu.sectionBackground),
        child: Padding(
          padding: menu.sectionPadding,
          child: Text(title, style: menu.sectionTextStyle),
        ),
      );
    }

    final itemStyle = TextButton.styleFrom(
      foregroundColor: menu.itemForeground,
      alignment: Alignment.centerLeft,
      padding: menu.itemPadding,
      minimumSize: Size(double.infinity, menu.itemMinHeight),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    Widget action({
      required String label,
      required IconData icon,
      required VoidCallback? onPressed,
    }) {
      return TextButton.icon(
        style: itemStyle,
        onPressed: onPressed,
        icon: Icon(icon, color: menu.itemIconColor),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(label, overflow: TextOverflow.ellipsis),
        ),
      );
    }

    final actions = <Widget>[
      if (column.header.showFilter && gridState.widget.filterable.usesMenu) ...[
        section(l10n.filter),
        Padding(
          padding: menu.filterInset,
          child: column.filterRules.showFilter(column, gridState),
        ),
      ],
      if (sortable) ...[
        section(l10n.sort),
        action(
          label: l10n.sortAscending,
          icon: gridTheme.header.sortAscendingIcon,
          onPressed: () {
            close(context);
            gridState.setColumnSort(column, OrderDirections.ascending);
          },
        ),
        action(
          label: l10n.sortDescending,
          icon: gridTheme.header.sortDescendingIcon,
          onPressed: () {
            close(context);
            gridState.setColumnSort(column, OrderDirections.descending);
          },
        ),
        action(
          label: l10n.clearSort,
          icon: gridTheme.header.sortUnsetIcon,
          onPressed: () {
            close(context);
            gridState.setColumnSort(column, OrderDirections.notSet);
          },
        ),
      ],
      if (gridState.widget.allowGrouping && column.participatesInGrouping) ...[
        section(l10n.groupBy),
        action(
          label: grouped ? l10n.ungroup : l10n.groupColumn,
          icon: grouped ? Icons.link_off : Icons.account_tree,
          onPressed: () {
            close(context);
            if (grouped) {
              final current = gridState.criteria.groupBy!.firstWhere(
                (g) => g.fieldName == column.fieldName,
              );
              gridState.removeGroup(current);
            } else {
              gridState.addGroup(
                GroupCriteria(
                  fieldName: column.fieldName,
                  aggregates: [...column.aggregations],
                  direction: OrderDirections.ascending,
                ),
              );
            }
          },
        ),
      ],
      section(l10n.columnMenu),
      action(
        label: column.frozen ? l10n.unpin : l10n.pinLeft,
        icon: Icons.push_pin_outlined,
        onPressed: () {
          close(context);
          gridState.setColumnFrozen(column.fieldName, !column.frozen);
        },
      ),
      action(
        label: l10n.hideColumn,
        icon: Icons.visibility_off_outlined,
        onPressed: canHide
            ? () {
                close(context);
                gridState.setColumnVisible(column.fieldName, false);
              }
            : null,
      ),
      action(
        label: l10n.autosizeColumn,
        icon: Icons.width_normal_outlined,
        onPressed: () {
          close(context);
          gridState.autosizeColumn(
            column.fieldName,
            style: gridTheme.body.textStyle,
          );
        },
      ),
      if (aggregates.isNotEmpty) ...[section(l10n.aggregates), ...aggregates],
    ];

    final cap = math.min(
      maxHeight ?? menu.maxHeight,
      MediaQuery.sizeOf(context).height * 0.75,
    );
    final panelColor = Theme.of(context).colorScheme.surface;
    final footer = ColoredBox(
      color: panelColor,
      child: Padding(
        padding: menu.footerPadding,
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                style: itemStyle,
                onPressed: () {
                  column.aggregations.clear();
                  column.filterRules.criteria = null;
                  close(context);
                  gridState.refreshData();
                },
                icon: Icon(
                  Icons.clear_all,
                  color: menu.itemIconColor,
                ),
                label: Text(l10n.clear, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  close(context);
                  gridState.refreshData();
                },
                icon: const Icon(Icons.check),
                label: Text(l10n.apply, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );

    return Material(
      color: panelColor,
      elevation: menu.elevation,
      type: MaterialType.card,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: cap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Align(
                alignment: Alignment.topLeft,
                heightFactor: 1,
                child: SingleChildScrollView(
                  primary: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: actions,
                  ),
                ),
              ),
            ),
            Divider(height: menu.dividerHeight, color: menu.dividerColor),
            footer,
          ],
        ),
      ),
    );
  }
}
