part of '../../responsive_data_grid.dart';

class GroupMenu<TItem extends Object> extends DropDownViewWidget {
  final FutureOr<void> Function(GroupCriteria) removeGroup;
  final GroupCriteria group;
  final ResponsiveDataGridState<TItem> gridState;

  GroupMenu({
    required this.removeGroup,
    required super.theme,
    required this.group,
    required this.gridState,
    super.key,
  }) : super(
         dropDownWidth: 250,
         icon: Icon(
           Icons.menu,
           color: group.aggregates.isNotEmpty
               ? theme.colorScheme.secondary
               : theme.iconTheme.color,
           size: theme.iconTheme.size,
         ),
       );

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
                  padding: EdgeInsets.only(top: 3, bottom: 3),
                  child: TextButton.icon(
                    label: Text(
                      "Apply",
                      style: theme.gridLabelLarge,
                    ),
                    onPressed: () {
                      close(context);
                      gridState.updateGroup(group);
                    },
                    icon: Icon(Icons.save, color: theme.colorScheme.onPrimary),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 3, bottom: 3),
                  child: TextButton.icon(
                    label: Text(
                      "Clear All",
                      style: theme.gridLabelLarge,
                    ),
                    onPressed: () {
                      group.aggregates.clear();
                      close(context);
                      gridState.updateGroup(group);
                    },
                    icon: Icon(
                      Icons.clear_all,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                Divider(),
                TextButton.icon(
                  label: Text(
                    "Remove Group",
                    style: theme.gridLabelLarge,
                  ),
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
