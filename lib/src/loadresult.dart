part of responsive_data_grid;

class LoadResult<TItem extends Object> {
  final int totalCount;
  final List<TItem> items;

  const LoadResult({
    required this.totalCount,
    required this.items,
  });
}
