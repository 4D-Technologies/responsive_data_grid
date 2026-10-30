part of '../../responsive_data_grid.dart';

class GridBody<TItem extends Object> extends StatelessWidget {
  final ResponsiveDataGridState<TItem> gridState;
  final BoxConstraints constraints;
  final PagingMode pagingMode;
  final ThemeData gridTheme;

  GridBody({
    super.key,
    required this.gridState,
    required this.constraints,
    required this.pagingMode,
    required this.gridTheme,
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
      return ResponsiveDataGridPagedBodyWidget<TItem>(
        gridState: gridState,
        theme: gridTheme,
        shrinkWrap: wrapContent,
      );
    } else {
      return ResponsiveGridInfiniteScrollBodyWidget<TItem>(
        gridState: gridState,
        theme: gridTheme,
      );
    }
  }
}
