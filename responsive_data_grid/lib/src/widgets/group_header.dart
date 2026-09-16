part of '../../responsive_data_grid.dart';

class GridGroupHeader extends StatelessWidget {
  final GroupResult group;
  final ThemeData theme;
  final int depth;
  final int indent;
  final bool collapsed;
  final VoidCallback? onToggle;

  const GridGroupHeader({
    super.key,
    required this.group,
    required this.theme,
    this.depth = 0,
    this.indent = 15,
    this.collapsed = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final gridTheme = ResponsiveDataGridTheme.of(context);
    final l10n = GridLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: gridTheme.groupHeaderBackground),
      child: Padding(
        padding: gridTheme.resolvePadding(const EdgeInsets.all(3)).copyWith(
          left: Directionality.of(context) == TextDirection.rtl
              ? 3
              : 3 + depth * indent.toDouble(),
          right: Directionality.of(context) == TextDirection.rtl
              ? 3 + depth * indent.toDouble()
              : 3,
        ),
        child: Row(
          children: [
            FocusableActionDetector(
              actions: {
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    onToggle?.call();
                    return null;
                  },
                ),
              },
              child: GridChromeIconButton(
                key: ValueKey(
                  'rdg-group-toggle-${group.fieldName}-${group.value}',
                ),
                tooltip: collapsed ? l10n.expandGroup : l10n.collapseGroup,
                icon: Icon(
                  collapsed ? Icons.chevron_right : Icons.expand_more,
                ),
                color: gridTheme.groupHeaderForeground,
                size: 20,
                extent: 28,
                onPressed: onToggle,
              ),
            ),
            PinToHorizontalViewport(
              child: Text(
                group.value ?? l10n.noEntry,
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
