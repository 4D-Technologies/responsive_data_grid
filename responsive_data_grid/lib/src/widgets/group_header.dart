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
    final pad = gridTheme.resolvePadding(gridTheme.groupHeader.padding);
    final extra = depth * indent.toDouble();
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return DecoratedBox(
      decoration: BoxDecoration(color: gridTheme.groupHeader.background),
      child: Padding(
        padding: pad.copyWith(
          left: rtl ? pad.left : pad.left + extra,
          right: rtl ? pad.right + extra : pad.right,
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
                color: gridTheme.groupHeader.foreground,
                size: gridTheme.groupHeader.iconSize,
                extent: gridTheme.groupHeader.iconExtent,
                onPressed: onToggle,
              ),
            ),
            PinToHorizontalViewport(
              child: Text(
                group.value ?? l10n.noEntry,
                style: gridTheme.groupHeader.textStyle.copyWith(
                  color: gridTheme.groupHeader.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
