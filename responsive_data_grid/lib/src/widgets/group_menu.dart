part of '../../responsive_data_grid.dart';

class GroupMenu<TItem extends Object> extends DropDownViewWidget {
  final FutureOr<void> Function(GroupCriteria) removeGroup;
  final GroupCriteria group;
  final ResponsiveDataGridState<TItem> gridState;

  const GroupMenu({
    required this.removeGroup,
    required super.theme,
    required this.group,
    required this.gridState,
    super.iconColor,
    super.iconSize,
    super.key,
  }) : super(dropDownWidth: 250, icon: Icons.more_vert);

  @override
  Widget build(
    BuildContext context,
    void Function(BuildContext context) close,
  ) {
    return Column(
      children: [
        SizedBox(height: 5),
        Material(
          elevation: 20,
          type: MaterialType.card,
          child: Container(
            padding: EdgeInsets.all(4),
            width: dropDownWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridGroupAggregateChooser<TItem>(
                  gridState: gridState,
                  theme: theme,
                  criteria: group,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3, bottom: 3),
                  child: FilledButton.icon(
                    label: Text(GridLocalizations.of(context).apply),
                    onPressed: () {
                      close(context);
                      gridState.updateGroup(group);
                    },
                    icon: const Icon(Icons.check),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3, bottom: 3),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                      alignment: Alignment.centerLeft,
                    ),
                    label: Text(GridLocalizations.of(context).clearAll),
                    onPressed: () {
                      group.aggregates.clear();
                      close(context);
                      gridState.updateGroup(group);
                    },
                    icon: Icon(
                      Icons.clear_all,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Divider(),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    alignment: Alignment.centerLeft,
                  ),
                  label: Text(GridLocalizations.of(context).removeGroup),
                  onPressed: () => removeGroup(group),
                  icon: Icon(Icons.delete, color: theme.colorScheme.error),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
