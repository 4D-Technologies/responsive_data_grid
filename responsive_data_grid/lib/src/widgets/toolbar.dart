part of '../../responsive_data_grid.dart';

class GridToolbarRow<TItem extends Object> extends StatelessWidget {
  final ResponsiveDataGridState<TItem> grid;
  final GridToolbar toolbar;

  const GridToolbarRow({
    super.key,
    required this.grid,
    required this.toolbar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final gridTheme = ResponsiveDataGridTheme.of(context);
    final l10n = GridLocalizations.of(context);
    final iconColor = scheme.onSurfaceVariant;
    final toolbarColor =
        theme.dataTableTheme.headingRowColor?.resolve(const {}) ??
        gridTheme.headerBackground;
    return DecoratedBox(
      key: const ValueKey('rdg-toolbar'),
      decoration: BoxDecoration(
        color: toolbarColor,
        border: Border(
          bottom: BorderSide(
            color: gridTheme.borderColor,
            width: gridTheme.borderWidth,
          ),
        ),
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: iconColor),
        child: Padding(
          padding: gridTheme.resolvePadding(
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Row(
            children: [
              if (toolbar.search)
                Expanded(
                  child: TextField(
                    key: const ValueKey('rdg-toolbar-search'),
                    style: theme.textTheme.bodyMedium,
                    cursorColor: scheme.primary,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: l10n.search,
                      hintStyle: theme.inputDecorationTheme.hintStyle ??
                          theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: scheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    onChanged: grid.setSearch,
                  ),
                )
              else
                const Spacer(),
              if (toolbar.columnChooser)
                PopupMenuButton<String>(
                  key: const ValueKey('rdg-toolbar-columns'),
                  tooltip: l10n.columns,
                  onSelected: (field) {
                    final column = grid.widget.columns.firstWhere(
                      (c) => c.fieldName == field,
                    );
                    grid.setColumnVisible(field, !column.visible);
                  },
                  itemBuilder: (context) => [
                    for (final column in grid.widget.columns)
                      CheckedPopupMenuItem<String>(
                        value: column.fieldName,
                        checked: column.visible,
                        child: Text(column.header.text ?? column.fieldName),
                      ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.view_column_outlined,
                      color: iconColor,
                    ),
                  ),
                ),
              if (toolbar.refresh && grid.widget.controller != null)
                GridChromeIconButton(
                  key: const ValueKey('rdg-toolbar-refresh'),
                  tooltip: l10n.refresh,
                  icon: const Icon(Icons.refresh),
                  color: iconColor,
                  size: 20,
                  extent: 32,
                  onPressed: () {
                    grid.widget.controller!.refresh();
                  },
                ),
              if (toolbar.density)
                GridChromeIconButton(
                  key: const ValueKey('rdg-toolbar-density'),
                  tooltip: l10n.density,
                  icon: const Icon(Icons.density_medium),
                  color: iconColor,
                  size: 20,
                  extent: 32,
                  onPressed: grid.cycleDensity,
                ),
              if (toolbar.onExport != null)
                GridChromeIconButton(
                  key: const ValueKey('rdg-toolbar-export'),
                  tooltip: l10n.export,
                  icon: const Icon(Icons.download_outlined),
                  color: iconColor,
                  size: 20,
                  extent: 32,
                  onPressed: toolbar.onExport,
                ),
              if (toolbar.actions != null) toolbar.actions!,
            ],
          ),
        ),
      ),
    );
  }
}
