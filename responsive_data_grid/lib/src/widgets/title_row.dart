part of '../../responsive_data_grid.dart';

class TitleRowWidget extends StatelessWidget {
  final TitleDefinition definition;
  final VoidCallback? onRefresh;

  const TitleRowWidget(this.definition, {super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final gridTheme = ResponsiveDataGridTheme.of(context);

    final backgroundColor =
        definition.backgroundColor ?? gridTheme.titleBackground;
    final foregroundColor =
        definition.foregroundColor ?? gridTheme.titleForeground;
    final titleTextStyle =
        definition.textStyle?.copyWith(color: foregroundColor) ??
        gridTheme.titleTextStyle.copyWith(color: foregroundColor);

    return ColoredBox(
      color: backgroundColor,
      child: Padding(
        padding: gridTheme.resolvePadding(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          children: [
            if (definition.icon != null) ...[
              IconTheme(
                data: IconThemeData(color: foregroundColor, size: 20),
                child: definition.icon!,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                definition.title,
                style: titleTextStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (onRefresh != null)
              GridChromeIconButton(
                tooltip: GridLocalizations.of(context).refresh,
                icon: const Icon(Icons.refresh),
                color: foregroundColor,
                size: 20,
                extent: 32,
                onPressed: onRefresh,
              ),
          ],
        ),
      ),
    );
  }
}
