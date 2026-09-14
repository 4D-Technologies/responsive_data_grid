part of '../../responsive_data_grid.dart';

/// Default empty-body chrome when [ResponsiveDataGrid.noResults] is omitted.
class GridNoRecords extends StatelessWidget {
  const GridNoRecords({super.key});

  @override
  Widget build(BuildContext context) {
    final gridTheme = ResponsiveDataGridTheme.of(context);
    return Center(
      child: Padding(
        padding: gridTheme.resolvePadding(gridTheme.footerPadding),
        child: Text(
          LocalizedMessages.noRecords,
          textAlign: TextAlign.center,
          style: gridTheme.bodyTextStyle.copyWith(
            color: gridTheme.headerForeground.withValues(alpha: 0.72),
          ),
        ),
      ),
    );
  }
}

Widget gridNoRecordsBody<TItem extends Object>(
  ResponsiveDataGridState<TItem> gridState,
) {
  return gridState.widget.noResults ?? const GridNoRecords();
}
