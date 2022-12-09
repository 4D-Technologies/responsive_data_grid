part of responsive_data_grid;

class GridBody<TItem extends Object> extends StatelessWidget {
  final ResponsiveDataGridState<TItem> gridState;
  final BoxConstraints constraints;
  final PagingMode pagingMode;
  final ThemeData gridTheme;

  GridBody({
    required this.gridState,
    required this.constraints,
    required this.pagingMode,
    required this.gridTheme,
  }) {
    assert(TItem != Object);
  }

  @override
  Widget build(BuildContext context) {
    if (constraints.hasBoundedHeight) {
      return Expanded(
        child: SingleChildScrollView(
          child: getBody(),
        ),
      );
    } else {
      return getBody();
    }
  }

  Widget getBody() {
    //It would be nice if these two could be integrated.
    //The issue is rendering the groups and rows is the same in both, but one handles loads the other is just stupid about it.
    if (pagingMode == PagingMode.pager || pagingMode == PagingMode.none) {
      return ResponsiveDataGridPagedBodyWidget<TItem>(
        gridState: gridState,
        theme: gridTheme,
      );
    } else {
      //This needs to keep the scroll context no matter what refreshes happen and show the in view rows, scroll until there is no more data, and then call for more data to be loaded
      return Container();
    }
  }
}
