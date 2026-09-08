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
    return DecoratedBox(
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
        padding: gridTheme.resolvePadding(
          const EdgeInsets.symmetric(horizontal: 4),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => setPage(1),
              icon: const Icon(Icons.first_page),
            ),
            IconButton(
              onPressed: pageNumber == 1
                  ? null
                  : () => setPage(math.max(1, pageNumber - 1)),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                '$pageNumber / $pageCount',
                textAlign: TextAlign.center,
                style: gridTheme.footerTextStyle,
              ),
            ),
            IconButton(
              onPressed: pageNumber == pageCount
                  ? null
                  : () => setPage(math.min(pageCount, pageNumber + 1)),
              icon: const Icon(Icons.chevron_right),
            ),
            IconButton(
              onPressed: () => setPage(pageCount),
              icon: const Icon(Icons.last_page),
            ),
          ],
        ),
      ),
    );
  }
}
