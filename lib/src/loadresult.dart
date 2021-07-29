part of responsive_data_grid;

class LoadResult<TItem extends Object> {
  final int totalCount;
  final Iterable<TItem> items;

  LoadResult({
    required this.totalCount,
    required this.items,
  }) {
    assert(TItem != Object);
  }
}
