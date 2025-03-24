part of responsive_data_grid;

enum FilterResults {
  success,
  cancel,
  clear,
}

class FilterResult<TValue extends dynamic> {
  final FilterCriteria<TValue>? criteria;
  final FilterResults result;

  const FilterResult({required this.result, this.criteria});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FilterResult &&
        other.criteria == criteria &&
        other.result == result;
  }

  @override
  int get hashCode => criteria.hashCode ^ result.hashCode;

  @override
  String toString() => 'FilterResult(criteria: $criteria, result: $result)';
}
