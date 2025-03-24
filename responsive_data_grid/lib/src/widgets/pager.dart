part of responsive_data_grid;

class PagerWidget extends StatelessWidget {
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final FutureOr<void> Function(int pageNumber) setPage;
  final ThemeData theme;

  PagerWidget({
    required this.pageNumber,
    required this.totalCount,
    required this.pageSize,
    required this.setPage,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final int pageCount = (totalCount.toDouble() / pageSize.toDouble()).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => setPage(1),
          icon: Icon(
            Icons.first_page,
          ),
        ),
        IconButton(
          onPressed: pageNumber == 1
              ? null
              : () => setPage(
                    math.max(1, pageNumber - 1),
                  ),
          icon: Icon(
            Icons.fast_rewind,
          ),
        ),
        Spacer(),
        Spacer(),
        IconButton(
          onPressed: pageNumber == pageCount
              ? null
              : () => setPage(math.min(pageCount, pageNumber + 1)),
          icon: Icon(
            Icons.fast_forward,
          ),
        ),
        IconButton(
          onPressed: () => setPage(pageCount),
          icon: Icon(
            Icons.last_page,
          ),
        ),
      ],
    );
  }
}
