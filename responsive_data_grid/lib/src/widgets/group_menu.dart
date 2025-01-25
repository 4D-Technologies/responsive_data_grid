part of responsive_data_grid;

class GroupMenu<TItem extends Object> extends DropDownViewWidget {
  final FutureOr<void> Function(GroupCriteria) removeGroup;
  final GroupCriteria group;
  final ResponsiveDataGridState<TItem> gridState;

  GroupMenu({
    required this.removeGroup,
    required ThemeData theme,
    required this.group,
    required this.gridState,
    Key? key,
  }) : super(
          dropDownWidth: 250,
          icon: Icon(
            Icons.menu,
            color: group.aggregates.isNotEmpty
                ? theme.colorScheme.secondary
                : theme.iconTheme.color,
            size: theme.iconTheme.size,
          ),
          theme: theme,
          key: key,
        );

  @override
  Widget build(
      BuildContext context, void Function(BuildContext context) close) {
    return Column(
      children: [
        SizedBox(height: 5),
        Material(
          elevation: 20,
          type: MaterialType.card,
          child: Container(
            padding: EdgeInsets.all(4),
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
                  child: TextButton.icon(
                    label: Text(
                      "Apply",
                      style: theme.primaryTextTheme.labelLarge,
                    ),
                    onPressed: () async {
                      await gridState.updateGroup(group);
                      close(context);
                    },
                    icon: Icon(
                      Icons.save,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  padding: EdgeInsets.only(top: 3, bottom: 3),
                ),
                Padding(
                  child: TextButton.icon(
                    label: Text(
                      "Clear All",
                      style: theme.primaryTextTheme.labelLarge,
                    ),
                    onPressed: () async {
                      group.aggregates.clear();
                      await gridState.updateGroup(group);
                      close(context);
                    },
                    icon: Icon(
                      Icons.clear_all,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  padding: EdgeInsets.only(top: 3, bottom: 3),
                ),
                Divider(),
                TextButton.icon(
                  label: Text(
                    "Remove Group",
                    style: theme.primaryTextTheme.labelLarge,
                  ),
                  onPressed: () => removeGroup(group),
                  icon: Icon(
                    Icons.delete,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            width: dropDownWidth,
          ),
        ),
      ],
    );
  }
}
