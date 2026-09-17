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
  }) : super(dropDownWidth: 250);

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
    void Function(BuildContext context) close,
  ) {
    final l10n = GridLocalizations.of(context);
    final gridTheme = ResponsiveDataGridTheme.of(context);
    final aggregates = gridState.widget.allowAggregations
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

    Widget section(String title) {
      return DecoratedBox(
        decoration: BoxDecoration(color: gridTheme.menuSectionBackground),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(title, style: theme.textTheme.labelLarge),
        ),
      );
    }

    Widget action({
      required String label,
      required IconData icon,
      required VoidCallback? onPressed,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label, overflow: TextOverflow.ellipsis),
        ),
      );
    }

    final actions = <Widget>[
              if (column.header.showFilter &&
                  gridState.widget.filterable.usesMenu) ...[
                section(l10n.filter),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: column.filterRules.showFilter(column, gridState),
                ),
              ],
              if (sortable) ...[
                section(l10n.sort),
                action(
                  label: l10n.sortAscending,
                  icon: gridTheme.sortAscendingIcon,
                  onPressed: () {
                    close(context);
                    gridState.setColumnSort(
                      column,
                      OrderDirections.ascending,
                    );
                  },
                ),
                action(
                  label: l10n.sortDescending,
                  icon: gridTheme.sortDescendingIcon,
                  onPressed: () {
                    close(context);
                    gridState.setColumnSort(
                      column,
                      OrderDirections.descending,
                    );
                  },
                ),
                action(
                  label: l10n.clearSort,
                  icon: gridTheme.sortUnsetIcon,
                  onPressed: () {
                    close(context);
                    gridState.setColumnSort(column, OrderDirections.notSet);
                  },
                ),
              ],
              if (gridState.widget.allowGrouping &&
                  column.participatesInGrouping) ...[
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
                          aggregates: [],
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
                    style: gridTheme.bodyTextStyle,
                  );
                },
              ),
              if (aggregates.isNotEmpty) ...[
                section(l10n.aggregates),
                ...aggregates,
              ],
    ];

    return Material(
      elevation: gridTheme.menuElevation,
      type: MaterialType.card,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: math.min(360, MediaQuery.sizeOf(context).height * 0.6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                primary: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: actions,
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        column.aggregations.clear();
                        column.filterRules.criteria = null;
                        close(context);
                        gridState.refreshData();
                      },
                      icon: const Icon(Icons.clear_all),
                      label: Text(
                        l10n.clear,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        close(context);
                        gridState.refreshData();
                      },
                      icon: const Icon(Icons.save),
                      label: Text(
                        l10n.apply,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
