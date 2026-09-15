part of '../../responsive_data_grid.dart';

class GridGroupChooser<TItem extends Object> extends StatefulWidget {
  final ResponsiveDataGridState<TItem> gridState;
  final ThemeData theme;
  final FutureOr<void> Function(GroupCriteria) addGroup;
  final FutureOr<void> Function(GroupCriteria) removeGroup;
  final FutureOr<void> Function(GroupCriteria) updateGroup;
  const GridGroupChooser({
    required this.gridState,
    required this.theme,
    required this.addGroup,
    required this.removeGroup,
    required this.updateGroup,
    super.key,
  });

  @override
  State<GridGroupChooser<TItem>> createState() =>
      _GridGroupChooserState<TItem>();
}

class _GridGroupChooserState<TItem extends Object>
    extends State<GridGroupChooser<TItem>> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.gridState.widget.groupPanel == GroupPanelDisplay.always;
  }

  @override
  void didUpdateWidget(covariant GridGroupChooser<TItem> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gridState.widget.groupPanel == GroupPanelDisplay.always) {
      _expanded = true;
    }
  }

  List<GroupCriteria> get _groups =>
      widget.gridState.criteria.groupBy ?? const <GroupCriteria>[];

  List<GridColumn<TItem, dynamic>> get _availableColumns {
    final grouped = _groups.map((g) => g.fieldName).toSet();
    return widget.gridState.widget.columns
        .where((c) => !grouped.contains(c.fieldName) && !c.header.empty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final gridTheme = ResponsiveDataGridTheme.of(context);
    final hint =
        widget.gridState.widget.groupPanelHint ??
        GridLocalizations.of(context).groupPanelHint;

    return DecoratedBox(
      key: const ValueKey('rdg-group-panel'),
      decoration: BoxDecoration(
        color: gridTheme.chooserBackground,
        border: Border(
          bottom: BorderSide(
            color: gridTheme.borderColor,
            width: gridTheme.borderWidth,
          ),
        ),
      ),
      child: Padding(
        padding: gridTheme.resolvePadding(
          const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        child: _expanded
            ? _expandedPanel(gridTheme, hint)
            : _collapsedBar(gridTheme, hint),
      ),
    );
  }

  Widget _collapsedBar(ResponsiveDataGridTheme gridTheme, String hint) {
    return Row(
      children: [
        Icon(Icons.account_tree, size: 18, color: gridTheme.chooserForeground),
        const SizedBox(width: 8),
        Text(
          GridLocalizations.of(context).groupBy,
          style: gridTheme.chooserTextStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: gridTheme.chooserForeground,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _groups.isEmpty
              ? Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: gridTheme.chooserTextStyle.copyWith(
                    color: gridTheme.chooserForeground.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w400,
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: _groups
                      .map((g) => _chip(gridTheme, g, compact: true))
                      .toList(),
                ),
        ),
        if (_availableColumns.isNotEmpty) _addMenu(gridTheme, compact: true),
        GridChromeIconButton(
          key: const ValueKey('rdg-group-panel-expand'),
          tooltip: GridLocalizations.of(context).showGroupPanel,
          icon: const Icon(Icons.expand_more),
          color: gridTheme.chooserForeground,
          size: 20,
          extent: 32,
          onPressed: () => setState(() => _expanded = true),
        ),
      ],
    );
  }

  Widget _expandedPanel(ResponsiveDataGridTheme gridTheme, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.account_tree,
              size: 18,
              color: gridTheme.chooserForeground,
            ),
            const SizedBox(width: 8),
            Text(
              GridLocalizations.of(context).groupBy,
              style: gridTheme.chooserTextStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: gridTheme.chooserForeground,
              ),
            ),
            const Spacer(),
            if (widget.gridState.widget.groupPanel ==
                GroupPanelDisplay.collapsed)
              GridChromeIconButton(
                key: const ValueKey('rdg-group-panel-collapse'),
                tooltip: GridLocalizations.of(context).hideGroupPanel,
                icon: const Icon(Icons.expand_less),
                color: gridTheme.chooserForeground,
                size: 20,
                extent: 32,
                onPressed: () => setState(() => _expanded = false),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (_groups.isEmpty)
              Text(
                hint,
                style: gridTheme.chooserTextStyle.copyWith(
                  color: gridTheme.chooserForeground.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ..._groups.map((g) => _chip(gridTheme, g, compact: false)),
            if (_availableColumns.isNotEmpty)
              _addMenu(gridTheme, compact: false),
          ],
        ),
      ],
    );
  }

  Widget _chip(
    ResponsiveDataGridTheme gridTheme,
    GroupCriteria group, {
    required bool compact,
  }) {
    final col = widget.gridState.widget.columns
        .where((c) => c.fieldName == group.fieldName)
        .firstOrDefault();
    if (col == null) {
      throw UnsupportedError(
        "The group fieldname must match that of a valid column.",
      );
    }

    IconData sortIcon;
    switch (group.direction) {
      case OrderDirections.descending:
        sortIcon = gridTheme.sortDescendingIcon;
        break;
      case OrderDirections.ascending:
        sortIcon = gridTheme.sortAscendingIcon;
        break;
      case OrderDirections.notSet:
        sortIcon = gridTheme.sortUnsetIcon;
    }

    return DecoratedBox(
      key: ValueKey('rdg-group-chip-${group.fieldName}'),
      decoration: BoxDecoration(
        color: gridTheme.chooserChipBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gridTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 4, top: 2, bottom: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_tree,
              size: 14,
              color: gridTheme.chooserChipForeground,
            ),
            const SizedBox(width: 6),
            Text(
              col.header.text ?? col.fieldName,
              style: gridTheme.chooserTextStyle.copyWith(
                color: gridTheme.chooserChipForeground,
              ),
            ),
            GridChromeIconButton(
              tooltip: GridLocalizations.of(context).sortGroup,
              icon: Icon(sortIcon),
              color: gridTheme.chooserChipForeground,
              size: 16,
              extent: 24,
              onPressed: () {
                final OrderDirections next;
                switch (group.direction) {
                  case OrderDirections.notSet:
                    next = OrderDirections.ascending;
                    break;
                  case OrderDirections.ascending:
                    next = OrderDirections.descending;
                    break;
                  case OrderDirections.descending:
                    next = OrderDirections.ascending;
                    break;
                }
                widget.updateGroup(
                  GroupCriteria(
                    fieldName: group.fieldName,
                    aggregates: group.aggregates,
                    direction: next,
                  ),
                );
              },
            ),
            if (!compact && widget.gridState.widget.allowAggregations)
              GroupMenu(
                group: group,
                removeGroup: widget.removeGroup,
                theme: widget.theme,
                gridState: widget.gridState,
                iconColor: gridTheme.chooserChipForeground,
                iconSize: 16,
              ),
            GridChromeIconButton(
              tooltip: GridLocalizations.of(context).ungroup,
              icon: const Icon(Icons.close),
              color: gridTheme.chooserChipForeground,
              size: 16,
              extent: 24,
              onPressed: () => widget.removeGroup(group),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addMenu(ResponsiveDataGridTheme gridTheme, {required bool compact}) {
    return MenuAnchor(
      key: const ValueKey('rdg-group-add'),
      alignmentOffset: const Offset(0, 4),
      builder: (context, controller, child) {
        void toggle() {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        }

        if (compact) {
          return GridChromeIconButton(
            tooltip: GridLocalizations.of(context).addGrouping,
            icon: const Icon(Icons.add),
            color: gridTheme.chooserForeground,
            size: 20,
            extent: 32,
            onPressed: toggle,
          );
        }
        return TextButton.icon(
          onPressed: toggle,
          icon: Icon(Icons.add, size: 18, color: gridTheme.chooserForeground),
          label: Text(
            GridLocalizations.of(context).addGrouping,
            style: gridTheme.chooserTextStyle.copyWith(
              color: gridTheme.chooserForeground,
            ),
          ),
        );
      },
      menuChildren: [
        for (final column in _availableColumns.orderBy(
          (e) => e.header.text ?? e.fieldName,
        ))
          MenuItemButton(
            onPressed: () {
              widget.addGroup(
                GroupCriteria(
                  fieldName: column.fieldName,
                  aggregates: [],
                  direction: OrderDirections.ascending,
                ),
              );
            },
            child: Text(column.header.text ?? column.fieldName),
          ),
      ],
    );
  }
}
