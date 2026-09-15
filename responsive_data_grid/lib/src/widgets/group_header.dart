part of '../../responsive_data_grid.dart';

class GridGroupHeader extends StatelessWidget {
  final GroupResult group;
  final ThemeData theme;
  const GridGroupHeader({super.key, required this.group, required this.theme});

  @override
  Widget build(BuildContext context) {
    final gridTheme = ResponsiveDataGridTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: gridTheme.groupHeaderBackground),
      child: Padding(
        padding: gridTheme.resolvePadding(const EdgeInsets.all(3)),
        child: Row(
          children: [
            PinToHorizontalViewport(
              child: Text(
                group.value ?? GridLocalizations.of(context).noEntry,
                style: gridTheme.groupHeaderTextStyle.copyWith(
                  color: gridTheme.groupHeaderForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
