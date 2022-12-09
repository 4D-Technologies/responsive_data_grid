part of responsive_data_grid;

ListResponse<TItem> applyCriteria<TItem extends Object>(
    ResponsiveDataGridState<TItem> gridState) {
  var items = List<TItem>.from(gridState.widget.items!);

  gridState.criteria.filterBy.forEach((criteria) {
    if (criteria.op == Operators.or)
      throw UnsupportedError("Or is not supported in Dart.");

    final col = gridState.widget.columns
        .where((c) => c.fieldName == criteria.fieldName)
        .firstOrDefault();
    if (col == null)
      throw UnsupportedError("The criteria must map to a column.");

    switch (criteria.logicalOperator) {
      case Logic.equals:
        items = items.where((e) {
          final dynamic value = col.value(e);

          return criteria.values.contains(value);
        }).toList();
        break;
      case Logic.lessThan:
        items = items.where((e) {
          final dynamic value = col.value(e);
          final dynamic cValue =
              criteria.values.isEmpty ? null : criteria.values.first;
          if (value == null || cValue == null) return false;

          if (value is DateTime && cValue is DateTime)
            return value.compareTo(cValue) < 0;

          return (value < cValue) as bool;
        }).toList();
        break;
      case Logic.greaterThan:
        items = items.where((e) {
          final dynamic value = col.value(e);
          final dynamic cValue =
              criteria.values.isEmpty ? null : criteria.values.first;
          if (value == null || cValue == null) return false;

          if (value is DateTime && cValue is DateTime)
            return value.compareTo(cValue) > 0;

          return (value > cValue) as bool;
        }).toList();

        break;
      case Logic.lessThanOrEqualTo:
        items = items.where((e) {
          final dynamic value = col.value(e);
          final dynamic cValue =
              criteria.values.isEmpty ? null : criteria.values.first;
          if (value == null || cValue == null) return false;

          if (value is DateTime && cValue is DateTime)
            return value.compareTo(cValue) <= 0;

          return (value <= cValue) as bool;
        }).toList();

        break;
      case Logic.greaterThanOrEqualTo:
        items = items.where((e) {
          final dynamic value = col.value(e);
          final dynamic cValue =
              criteria.values.isEmpty ? null : criteria.values.first;
          if (value == null || cValue == null) return false;

          if (value is DateTime && cValue is DateTime)
            return value.compareTo(cValue) >= 0;

          return (value >= cValue) as bool;
        }).toList();

        break;
      case Logic.contains:
        items = items.where((e) {
          final dynamic value = col.value(e);
          final dynamic cValue =
              criteria.values.isEmpty ? null : criteria.values.first;

          if (value == null ||
              cValue == null ||
              !(value is String) ||
              !(cValue is String)) return false;

          return value.contains(cValue);
        }).toList();
        break;
      case Logic.notContains:
        items = items.where((e) {
          final dynamic value = col.value(e);
          final dynamic cValue =
              criteria.values.isEmpty ? null : criteria.values.first;

          if (value == null ||
              cValue == null ||
              !(value is String) ||
              !(cValue is String)) return false;

          return !value.contains(cValue);
        }).toList();
        break;
      case Logic.endsWidth:
        items = items.where((e) {
          final dynamic value = col.value(e);
          final dynamic cValue =
              criteria.values.isEmpty ? null : criteria.values.first;

          if (value == null ||
              cValue == null ||
              !(value is String) ||
              !(cValue is String)) return false;

          return value.endsWith(cValue);
        }).toList();
        break;
      case Logic.startsWith:
        items = items.where((e) {
          final dynamic value = col.value(e);
          final dynamic cValue =
              criteria.values.isEmpty ? null : criteria.values.first;

          if (value == null ||
              cValue == null ||
              !(value is String) ||
              !(cValue is String)) return false;

          return value.startsWith(cValue);
        }).toList();
        break;
      case Logic.notEqual:
        items = items.where((e) {
          final dynamic value = col.value(e);
          return !criteria.values.contains(value);
        }).toList();
        break;
      case Logic.notEndsWith:
        items = items.where((e) {
          final dynamic value = col.value(e);
          final dynamic cValue =
              criteria.values.isEmpty ? null : criteria.values.first;
          if (value == null ||
              cValue == null ||
              !(value is String) ||
              !(cValue is String)) return false;

          return !value.endsWith(cValue);
        }).toList();
        break;
      case Logic.notStartsWith:
        items = items.where((e) {
          final dynamic value = col.value(e);
          final dynamic cValue =
              criteria.values.isEmpty ? null : criteria.values.first;
          if (value == null ||
              cValue == null ||
              !(value is String) ||
              !(cValue is String)) return false;

          return !value.startsWith(cValue);
        }).toList();
        break;
      case Logic.between:
        items = items.where((e) {
          final dynamic value = col.value(e);
          final dynamic cValue1 =
              criteria.values.isEmpty ? null : criteria.values.first;
          final dynamic cValue2 =
              criteria.values.length > 1 ? criteria.values.last : null;
          if (value == null || cValue1 == null || cValue2 == null) return false;

          return (value >= cValue1) as bool && (value <= cValue2) as bool;
        }).toList();
        break;
    }
  });

  //Order By
  final sortColumns = gridState.widget.columns
      .where((c) => c.sortDirection != OrderDirections.notSet)
      .toList(growable: gridState.widget.groups != null);

  //We add the groups to the front as columns because that's most important for the grid to disply
  if (gridState.widget.groups != null) {
    for (int j = gridState.widget.groups!.length - 1; j >= 0; j--) {
      final g = gridState.widget.groups![0];
      final col = gridState.widget.columns
          .where((c) => c.fieldName == g.fieldName)
          .firstOrDefault();
      if (col == null) continue;

      if (!sortColumns.any((c) => c == col)) sortColumns.insert(0, col);
    }
  }

  if (sortColumns.isNotEmpty) {
    Iterable<TItem> sortedItems = items;
    for (int j = 0; j < sortColumns.length; j++) {
      final col = sortColumns[j];

      final comparer = EqualityComparer<TItem>(
        comparer: (left, right) => left == right,
        hasher: (value) => value.hashCode,
        sorter: (left, right) {
          final dynamic leftValue = col.value(left);
          final dynamic rightValue = col.value(right);

          if (leftValue == null && rightValue == null) return 0;
          if (leftValue == null && rightValue != null) return -1;
          if (leftValue != null && rightValue == null) return 1;

          if (leftValue is Comparable) return leftValue.compareTo(rightValue);

          return 0;
        },
      );

      if (j == 0) {
        sortedItems = sortedItems.orderBy((c) => c, keyComparer: comparer);
      } else {
        sortedItems = sortedItems.thenBy((c) => c, keyComparer: comparer);
      }
    }
    items = sortedItems.toList();
  }

  if (gridState.criteria.skip != null)
    items = items.skip(gridState.criteria.skip!).toList();
  if (gridState.criteria.take != null)
    items = items.take(gridState.criteria.take!).toList();

  Map<String, List<GroupValueResult>> groupValuesMap = {};
  if (gridState.criteria.groupBy != null &&
      gridState.criteria.groupBy!.isNotEmpty) {
    for (int j = gridState.widget.groups!.length - 1; j >= 0; j--) {
      final g = gridState.widget.groups![0];
      final col = gridState.widget.columns
          .where((c) => c.fieldName == g.fieldName)
          .firstOrDefault();
      if (col == null) continue;

      final values =
          items.map((e) => col.value(e)?.toString()).toSet().toList();

      //Get the aggregates and values here.
      groupValuesMap.addAll({
        g.fieldName: values.map((v) {
          final groupItems =
              items.where((i) => col.value(i)?.toString() == v).toList();

          return GroupValueResult(
            value: v,
            aggregates: g.aggregates.map((a) {
              //TODO - Filter items here based on the group

              return _createAggregation(
                groupItems,
                gridState.widget.columns,
                a,
              );
            }).toList(),
          );
        }).toList(),
      });
    }
  }

  final aggregates = List<AggregateResult>.empty(growable: true);
  if (gridState.criteria.aggregates != null &&
      gridState.criteria.aggregates!.isNotEmpty) {
    gridState.criteria.aggregates!.forEach(
      (a) => aggregates.add(
        _createAggregation(
          items,
          gridState.widget.columns,
          a,
        ),
      ),
    );
  }

  return ListResponse<TItem>(
    totalCount: gridState.widget.items!.length,
    items: items,
    groups: gridState.widget.groups
            ?.where(
              (g) => groupValuesMap.containsKey(g.fieldName),
            )
            .map((g) => GroupResult(
                  fieldName: g.fieldName,
                  values: groupValuesMap[g.fieldName]!,
                ))
            .toList() ??
        [],
    aggregates: aggregates,
  );
}

AggregateResult _createAggregation<TItem extends Object>(List<TItem> items,
    List<GridColumn<TItem, dynamic>> columns, AggregateCriteria criteria) {
  final col =
      columns.where((e) => criteria.fieldName == e.fieldName).firstOrDefault();
  if (col == null)
    throw UnsupportedError(
        "There must be a column with the same name as the criteria.");

  String? result;
  final nonNullItems = items.where((e) => col.value(e) != null);
  switch (criteria.aggregation) {
    case Aggregations.sum:
      result = nonNullItems
          .map((e) => num.parse(col.value(e)!.toString()))
          .sum
          .toString();
      break;
    case Aggregations.average:
      result = nonNullItems
          .map((e) => num.parse(col.value(e)!.toString()))
          .average
          .toString();
      break;
    case Aggregations.maxium:
      result = nonNullItems
          .map((e) => num.parse(col.value(e)!.toString()))
          .maxOrNull
          .toString();
      break;
    case Aggregations.minimum:
      result = nonNullItems
          .map((e) => num.parse(col.value(e)!.toString()))
          .minOrNull
          .toString();
      break;
    case Aggregations.count:
      result = items.length.toString();
      break;
  }

  return AggregateResult(
      fieldName: criteria.fieldName,
      aggregation: criteria.aggregation,
      result: result);
}
