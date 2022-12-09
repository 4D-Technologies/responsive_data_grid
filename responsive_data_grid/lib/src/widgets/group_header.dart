part of responsive_data_grid;

class GridGroupHeader extends StatelessWidget {
  final GroupResult group;
  final GroupValueResult value;
  final ThemeData theme;
  GridGroupHeader({
    required this.group,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Color.fromARGB(255, 48, 48, 48)),
      child: Padding(
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.arrow_drop_down),
            ),
            Text(
              value.value ?? LocalizedMessages.noEntry,
              style: theme.primaryTextTheme.headline6,
            ),
          ],
        ),
        padding: EdgeInsets.all(3),
      ),
    );
  }
}
