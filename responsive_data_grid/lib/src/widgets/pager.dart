part of '../../responsive_data_grid.dart';

class PagerWidget extends StatelessWidget {
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final FutureOr<void> Function(int pageNumber) setPage;
  final ThemeData theme;

  const PagerWidget({
    super.key,
    required this.pageNumber,
    required this.totalCount,
    required this.pageSize,
    required this.setPage,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final int pageCount = math.max(
      1,
      (totalCount.toDouble() / pageSize.toDouble()).ceil(),
    );

    final gridTheme = ResponsiveDataGridTheme.of(context);
    return IconTheme(
      data: IconThemeData(
        color: gridTheme.pagerIconColor,
        size: gridTheme.headerIconSize + 4,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gridTheme.footerBackground,
          border: Border(
            top: BorderSide(
              color: gridTheme.borderColor,
              width: gridTheme.borderWidth,
            ),
          ),
        ),
        child: Padding(
          padding: gridTheme.resolvePadding(gridTheme.footerPadding),
          child: Row(
            children: [
              GridChromeIconButton(
                tooltip: 'First page',
                onPressed: pageNumber == 1 ? null : () => setPage(1),
                icon: Icon(gridTheme.pagerFirstIcon),
                color: gridTheme.pagerIconColor,
                disabledColor: gridTheme.pagerDisabledIconColor,
                size: gridTheme.headerIconSize + 4,
                extent: 36,
              ),
              GridChromeIconButton(
                tooltip: 'Previous page',
                onPressed: pageNumber == 1
                    ? null
                    : () => setPage(math.max(1, pageNumber - 1)),
                icon: Icon(gridTheme.pagerPreviousIcon),
                color: gridTheme.pagerIconColor,
                disabledColor: gridTheme.pagerDisabledIconColor,
                size: gridTheme.headerIconSize + 4,
                extent: 36,
              ),
              Expanded(
                child: Text(
                  '$pageNumber / $pageCount',
                  textAlign: TextAlign.center,
                  style: gridTheme.footerTextStyle.copyWith(
                    color: gridTheme.footerForeground,
                  ),
                ),
              ),
              GridChromeIconButton(
                tooltip: 'Next page',
                onPressed: pageNumber == pageCount
                    ? null
                    : () => setPage(math.min(pageCount, pageNumber + 1)),
                icon: Icon(gridTheme.pagerNextIcon),
                color: gridTheme.pagerIconColor,
                disabledColor: gridTheme.pagerDisabledIconColor,
                size: gridTheme.headerIconSize + 4,
                extent: 36,
              ),
              GridChromeIconButton(
                tooltip: 'Last page',
                onPressed: pageNumber == pageCount
                    ? null
                    : () => setPage(pageCount),
                icon: Icon(gridTheme.pagerLastIcon),
                color: gridTheme.pagerIconColor,
                disabledColor: gridTheme.pagerDisabledIconColor,
                size: gridTheme.headerIconSize + 4,
                extent: 36,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
