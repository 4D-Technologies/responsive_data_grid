part of responsive_data_grid;

class LoadResult<TItem extends dynamic> {
  final int totalCount;
  final Iterable<TItem> items;

  LoadResult(this.totalCount, this.items) {
    assert(TItem != dynamic);
  }
}
