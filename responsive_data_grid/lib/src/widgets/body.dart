part of '../../responsive_data_grid.dart';

class GridBody<TItem extends Object> extends StatelessWidget {
  final ResponsiveDataGridState<TItem> gridState;
  final BoxConstraints constraints;
  final PagingMode pagingMode;
  final ThemeData gridTheme;
  final bool pageFitsHost;

  GridBody({
    super.key,
    required this.gridState,
    required this.constraints,
    required this.pagingMode,
    required this.gridTheme,
    this.pageFitsHost = true,
  }) {
    assert(TItem != Object);
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  Widget getBody() {
    if (pagingMode == PagingMode.pager || pagingMode == PagingMode.none) {
      final wrapContent =
          !constraints.hasBoundedHeight ||
          gridState.widget.sizing == GridSizing.shrinkWrap ||
          gridState.widget.sizing == GridSizing.fill;
      final neverScroll =
          !constraints.hasBoundedHeight ||
          gridState.widget.sizing == GridSizing.shrinkWrap ||
          (gridState.widget.sizing == GridSizing.fill && pageFitsHost);
      return ResponsiveDataGridPagedBodyWidget<TItem>(
        gridState: gridState,
        theme: gridTheme,
        shrinkWrap: wrapContent,
        neverScroll: neverScroll,
      );
    } else {
      return ResponsiveGridInfiniteScrollBodyWidget<TItem>(
        gridState: gridState,
        theme: gridTheme,
      );
    }
  }
}
