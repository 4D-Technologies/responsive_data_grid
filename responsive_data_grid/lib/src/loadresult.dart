part of responsive_data_grid;

class LoadResult<TItem extends Object> {
  final int totalCount;
  final List<TItem> items;

  const LoadResult({
    required this.totalCount,
    required this.items,
  });
}

FutureOr<LoadResult<TItem>?> _getData<TItem extends Object>(
    ResponsiveDataGridState<TItem> gridState, int skip) {
  final pageSize = gridState.pagingMode == PagingMode.none
      ? gridState.widget.maximumRows
      : gridState.widget.pageSize;

  if (gridState.widget.loadData == null) {
    var items = List<TItem>.from(gridState.widget.items!);
    //Filter
    gridState.columns.where((c) => c.filterRules.criteria != null).forEach((c) {
      final criteria = c.filterRules.criteria!;

      if (criteria.op == Logic.or)
        throw UnsupportedError("Or is not supported in Dart.");

      switch (criteria.logicalOperator) {
        case Operators.equals:
          items = items.where((e) {
            final value = c.value(e);

            return criteria.values.contains(value);
          }).toList();
          break;
        case Operators.lessThan:
          items = items.where((e) {
            final value = c.value(e);
            final cValue =
                criteria.values.isEmpty ? null : criteria.values.first;
            if (value == null || cValue == null) return false;

            if (value is DateTime && cValue is DateTime)
              return value.compareTo(cValue) < 0;

            return value < cValue;
          }).toList();
          break;
        case Operators.greaterThan:
          items = items.where((e) {
            final value = c.value(e);
            final cValue =
                criteria.values.isEmpty ? null : criteria.values.first;
            if (value == null || cValue == null) return false;

            if (value is DateTime && cValue is DateTime)
              return value.compareTo(cValue) > 0;

            return value > cValue;
          }).toList();

          break;
        case Operators.lessThanOrEqualTo:
          items = items.where((e) {
            final value = c.value(e);
            final cValue =
                criteria.values.isEmpty ? null : criteria.values.first;
            if (value == null || cValue == null) return false;

            if (value is DateTime && cValue is DateTime)
              return value.compareTo(cValue) <= 0;

            return value <= cValue;
          }).toList();

          break;
        case Operators.greaterThanOrEqualTo:
          items = items.where((e) {
            final value = c.value(e);
            final cValue =
                criteria.values.isEmpty ? null : criteria.values.first;
            if (value == null || cValue == null) return false;

            if (value is DateTime && cValue is DateTime)
              return value.compareTo(cValue) >= 0;

            return value >= cValue;
          }).toList();

          break;
        case Operators.contains:
          items = items.where((e) {
            final value = c.value(e);
            final cValue =
                criteria.values.isEmpty ? null : criteria.values.first;

            if (value == null ||
                cValue == null ||
                !(value is String) ||
                !(cValue is String)) return false;

            return value.contains(cValue);
          }).toList();
          break;
        case Operators.notContains:
          items = items.where((e) {
            final value = c.value(e);
            final cValue =
                criteria.values.isEmpty ? null : criteria.values.first;

            if (value == null ||
                cValue == null ||
                !(value is String) ||
                !(cValue is String)) return false;

            return !value.contains(cValue);
          }).toList();
          break;
        case Operators.endsWidth:
          items = items.where((e) {
            final value = c.value(e);
            final cValue =
                criteria.values.isEmpty ? null : criteria.values.first;

            if (value == null ||
                cValue == null ||
                !(value is String) ||
                !(cValue is String)) return false;

            return value.endsWith(cValue);
          }).toList();
          break;
        case Operators.startsWith:
          items = items.where((e) {
            final value = c.value(e);
            final cValue =
                criteria.values.isEmpty ? null : criteria.values.first;

            if (value == null ||
                cValue == null ||
                !(value is String) ||
                !(cValue is String)) return false;

            return value.startsWith(cValue);
          }).toList();
          break;
        case Operators.notEqual:
          items = items.where((e) {
            final value = c.value(e);
            return !criteria.values.contains(value);
          }).toList();
          break;
        case Operators.notEndsWith:
          items = items.where((e) {
            final value = c.value(e);
            final cValue =
                criteria.values.isEmpty ? null : criteria.values.first;
            if (value == null ||
                cValue == null ||
                !(value is String) ||
                !(cValue is String)) return false;

            return !value.endsWith(cValue);
          }).toList();
          break;
        case Operators.notStartsWith:
          items = items.where((e) {
            final value = c.value(e);
            final cValue =
                criteria.values.isEmpty ? null : criteria.values.first;
            if (value == null ||
                cValue == null ||
                !(value is String) ||
                !(cValue is String)) return false;

            return !value.startsWith(cValue);
          }).toList();
          break;
        case Operators.between:
          items = items.where((e) {
            final value = c.value(e);
            final cValue1 =
                criteria.values.isEmpty ? null : criteria.values.first;
            final cValue2 =
                criteria.values.length > 1 ? criteria.values.last : null;
            if (value == null || cValue1 == null || cValue2 == null)
              return false;

            return value >= cValue1 && value <= cValue2;
          }).toList();
          break;
      }
    });

    //Order By
    final sortColumns = gridState.columns.where((c) =>
        gridState.widget.sortable != SortableOptions.none ||
        c.sortDirection != OrderDirections.notSet);

    if (sortColumns.isNotEmpty) {
      items.sort((a, b) {
        for (int colNum = 0; colNum < sortColumns.length; colNum++) {
          final c = sortColumns.elementAt(colNum);

          final value1 = c.value(a);
          final value2 = c.value(b);

          if (value1 == null && value2 != null) return -1;
          if (value2 == null && value1 != null) return 1;

          if (value1.runtimeType != value2.runtimeType) return 0;

          late int result;

          if (value1 is String && value2 is String)
            result = value1.compareTo(value2);
          else if (value1 is DateTime && value2 is DateTime)
            result = value1.compareTo(value2);
          else if (value1 is bool && value2 is bool)
            result = value1 == true && value2 == false
                ? 1
                : value1 == false && value2 == true
                    ? -1
                    : 0;
          else if (value1 is Comparable && value2 is Comparable)
            result = value1.compareTo(value2);
          else
            result = value1.toString().compareTo(value2.toString());

          if (c.sortDirection == OrderDirections.descending)
            result = result * -1;
          if (result != 0) return result;
        }

        return 0;
      });
    }

    final totalCount = items.length;

    if (skip > items.length)
      return LoadResult(items: List<TItem>.empty(), totalCount: totalCount);

    //skip/take
    items = items.sublist(
      skip,
      math.min(skip + pageSize, items.length),
    );

    return LoadResult(
      totalCount: totalCount,
      items: items,
    );
  } else {
    return gridState.widget.loadData!(
      LoadCriteria(
        skip: skip,
        take: pageSize,
        orderBy: gridState.orderBy,
        filterBy: gridState.filterBy,
      ),
    );
  }
}
