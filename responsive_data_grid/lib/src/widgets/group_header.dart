part of responsive_data_grid;

class GridGroupHeader extends StatelessWidget {
  final GroupResult group;
  final ThemeData theme;
  GridGroupHeader({
    required this.group,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Color.fromARGB(255, 48, 48, 48)),
      child: Padding(
        child: Row(
          children: [
            // IconButton(
            //   onPressed: () {},
            //   icon: Icon(Icons.arrow_drop_down),
            // ),
            Text(
              group.value ?? LocalizedMessages.noEntry,
              style: theme.primaryTextTheme.titleSmall,
            ),
          ],
        ),
        padding: EdgeInsets.all(3),
      ),
    );
  }
}
