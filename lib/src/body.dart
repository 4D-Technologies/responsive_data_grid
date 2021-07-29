part of responsive_data_grid;

class DataGridBodyWidget<TItem extends dynamic> extends StatelessWidget {
  final DataGridState<TItem> grid;
  final ThemeData theme;

  DataGridBodyWidget(
    this.grid,
    this.theme,
  );

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (grid.isLoading ||
              scrollInfo.metrics.pixels != scrollInfo.metrics.maxScrollExtent ||
              scrollInfo.metrics.maxScrollExtent == 0.0) {
            return true;
          }

          grid.load();
          return true;
        },
        child: !grid.isInitialized
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(
                height: grid.widget.height,
                child: ListView.builder(
                  itemCount: grid.items.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        if (grid.widget.itemTapped != null) {
                          grid.widget.itemTapped!(grid.items[index]);
                        }
                      },
                      enableFeedback: true,
                      excludeFromSemantics: false,
                      hoverColor: theme.colorScheme.secondary,
                      mouseCursor: grid.widget.itemTapped != null
                          ? SystemMouseCursors.click
                          : SystemMouseCursors.basic,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: DataGridRowWidget<TItem>(
                          grid.items[index],
                          grid.columns,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
