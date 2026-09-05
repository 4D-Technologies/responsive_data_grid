part of '../client_filtering.dart';

class LoadCriteria with IJsonable {
  final int? skip;
  final int? take;
  final List<FilterCriteria<dynamic>> filterBy;
  final List<OrderCriteria> orderBy;
  final List<GroupCriteria>? groupBy;
  final List<AggregateCriteria>? aggregates;

  LoadCriteria({
    this.skip,
    this.take,
    this.groupBy,
    this.aggregates,
    List<FilterCriteria<dynamic>>? filterBy,
    List<OrderCriteria>? orderBy,
  }) : filterBy =
           filterBy ?? List<FilterCriteria<dynamic>>.empty(growable: true),
       orderBy = orderBy ?? List<OrderCriteria>.empty(growable: true);

  factory LoadCriteria.fromJson(Map<String, dynamic> json) => LoadCriteria(
    skip: (jsonValue(json, 'skip') as num?)?.toInt(),
    take: (jsonValue(json, 'take') as num?)?.toInt(),
    filterBy: jsonList(jsonValue(json, 'filterBy'))
        .map<FilterCriteria<dynamic>>(
          (dynamic model) => FilterCriteria.fromJson<dynamic>(jsonMap(model)),
        )
        .toList(),
    orderBy: jsonList(jsonValue(json, 'orderBy'))
        .map<OrderCriteria>(
          (dynamic model) => OrderCriteria.fromJson(jsonMap(model)),
        )
        .toList(),
    groupBy: groupByFromJson(jsonValue(json, 'groupBy')),
    aggregates: jsonValue(json, 'aggregates') == null
        ? null
        : jsonList(jsonValue(json, 'aggregates'))
              .map<AggregateCriteria>(
                (dynamic model) => AggregateCriteria.fromJson(jsonMap(model)),
              )
              .toList(),
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoadCriteria &&
        other.skip == skip &&
        other.take == take &&
        listEquals(other.filterBy, filterBy) &&
        listEquals(other.orderBy, orderBy) &&
        listEquals(other.groupBy ?? const [], groupBy ?? const []) &&
        listEquals(other.aggregates ?? const [], aggregates ?? const []);
  }

  @override
  int get hashCode {
    return Object.hash(
      skip,
      take,
      Object.hashAll(filterBy),
      Object.hashAll(orderBy),
      Object.hashAll(groupBy ?? const []),
      Object.hashAll(aggregates ?? const []),
    );
  }

  LoadCriteria copyWith({
    int? Function()? skip,
    int? Function()? take,
    List<FilterCriteria<dynamic>>? Function()? filterBy,
    List<OrderCriteria>? Function()? orderBy,
    List<GroupCriteria>? Function()? groupBy,
    List<AggregateCriteria>? Function()? aggregates,
  }) {
    return LoadCriteria(
      skip: skip == null ? this.skip : skip(),
      take: take == null ? this.take : take(),
      filterBy: filterBy == null ? this.filterBy : filterBy(),
      orderBy: orderBy == null ? this.orderBy : orderBy(),
      groupBy: groupBy == null ? this.groupBy : groupBy(),
      aggregates: aggregates == null ? this.aggregates : aggregates(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // ignore: unnecessary_cast
    return {
          'skip': skip,
          'take': take,
          'filterBy': filterBy.map((x) => x.toJson()).toList(),
          'orderBy': orderBy.map((x) => x.toJson()).toList(),
          'groupBy': groupBy?.map((x) => x.toJson()).toList(),
          'aggregates': aggregates?.map((x) => x.toJson()).toList(),
        }
        as Map<String, dynamic>;
  }

  Iterable<T> filterItems<T>({
    required Iterable<T> data,
    required dynamic Function(String fieldName, T item) getFieldValue,
  }) {
    if (filterBy.isEmpty) {
      return List<T>.from(data);
    }

    // Match .NET ApplyFilterPredicates: first clause is the seed, each
    // following clause joins with that clause's Operators (AND/OR).
    return data.where((item) {
      var result = _matches(filterBy.first, item, getFieldValue);
      for (final criteria in filterBy.skip(1)) {
        final matched = _matches(criteria, item, getFieldValue);
        result = criteria.op == Operators.or
            ? result || matched
            : result && matched;
      }
      return result;
    });
  }

  bool _matches<T>(
    FilterCriteria<dynamic> criteria,
    T item,
    dynamic Function(String fieldName, T item) getFieldValue,
  ) {
    final dynamic value = getFieldValue(criteria.fieldName, item);
    final values = criteria.values;
    final dynamic first = values.isEmpty ? null : values.first;
    final dynamic last = values.length > 1 ? values.last : null;

    switch (criteria.logicalOperator) {
      case Logic.equals:
        return values.contains(value);
      case Logic.notEqual:
        return !values.contains(value);
      case Logic.lessThan:
        final lt = _compare(value, first);
        return lt != null && lt < 0;
      case Logic.lessThanOrEqualTo:
        final lte = _compare(value, first);
        return lte != null && lte <= 0;
      case Logic.greaterThan:
        final gt = _compare(value, first);
        return gt != null && gt > 0;
      case Logic.greaterThanOrEqualTo:
        final gte = _compare(value, first);
        return gte != null && gte >= 0;
      case Logic.between:
        final lo = _compare(value, first);
        final hi = _compare(value, last);
        return lo != null && hi != null && lo >= 0 && hi <= 0;
      case Logic.contains:
        return value is String && first is String && value.contains(first);
      case Logic.notContains:
        return value is String && first is String && !value.contains(first);
      case Logic.startsWith:
        return value is String && first is String && value.startsWith(first);
      case Logic.notStartsWith:
        return value is String && first is String && !value.startsWith(first);
      case Logic.endsWith:
        return value is String && first is String && value.endsWith(first);
      case Logic.notEndsWith:
        return value is String && first is String && !value.endsWith(first);
    }
  }

  int? _compare(dynamic left, dynamic right) {
    if (left == null || right == null) {
      return null;
    }
    if (left is DateTime && right is DateTime) {
      return left.compareTo(right);
    }
    if (left is TimeOfDay && right is TimeOfDay) {
      return (left.hour * 60 + left.minute).compareTo(
        right.hour * 60 + right.minute,
      );
    }
    if (left is Comparable && right is Comparable) {
      try {
        return left.compareTo(right);
      } on TypeError {
        return null;
      }
    }
    return null;
  }

  Iterable<T> orderItems<T>({
    required Iterable<T> items,
    required dynamic Function(String fieldName, T item) getFieldValue,
  }) {
    final orderInfo = List<OrderCriteria>.from(orderBy, growable: true);

    if (groupBy != null) {
      for (int j = groupBy!.length - 1; j >= 0; j--) {
        final g = groupBy![j];

        orderInfo.removeWhere((c) => c.fieldName == g.fieldName);

        orderInfo.insert(
          0,
          OrderCriteria(fieldName: g.fieldName, direction: g.direction),
        );
      }
    }

    if (orderInfo.isEmpty) return items;

    for (int j = 0; j < orderInfo.length; j++) {
      final orderBy = orderInfo[j];

      final comparer = EqualityComparer<T>(
        comparer: (left, right) => left == right,
        hasher: (value) => value.hashCode,
        sorter: (left, right) {
          final dynamic leftValue = getFieldValue(orderBy.fieldName, left);
          final dynamic rightValue = getFieldValue(orderBy.fieldName, right);

          if (leftValue == null && rightValue == null) return 0;
          if (leftValue == null && rightValue != null) return -1;
          if (leftValue != null && rightValue == null) return 1;

          if (leftValue is Comparable) return leftValue.compareTo(rightValue);

          return 0;
        },
      );

      if (j == 0) {
        if (orderBy.direction == OrderDirections.ascending) {
          items = items.orderBy((c) => c, keyComparer: comparer);
        } else {
          items = items.orderByDescending((c) => c, keyComparer: comparer);
        }
      } else {
        if (orderBy.direction == OrderDirections.ascending) {
          items = items.thenBy((c) => c, keyComparer: comparer);
        } else {
          items = items.thenByDescending((c) => c, keyComparer: comparer);
        }
      }
    }

    return items;
  }

  List<GroupResult> groupItems<T>({
    required GroupCriteria criteria,
    required Iterable<T> items,
    required Iterable<T> allItems,
    required dynamic Function(String fieldName, T item) getFieldValue,
  }) {
    //Get all of the values for the given column
    final values = items
        .map((e) => getFieldValue(criteria.fieldName, e)?.toString())
        .toSet()
        .where(
          (e) => items.any(
            (i) => getFieldValue(criteria.fieldName, i)?.toString() == e,
          ),
        );

    final nextGroupCriteria = groupBy!.last == criteria
        ? null
        : groupBy![groupBy!.indexOf(criteria) + 1];

    return values.map((e) {
      //Get Items based on the value here.
      final valueItems = items
          .where((i) => getFieldValue(criteria.fieldName, i)?.toString() == e)
          .toList();

      final allValueItems = allItems
          .where((i) => getFieldValue(criteria.fieldName, i)?.toString() == e)
          .toList();

      //Get group aggregates here
      final aggregates = criteria.aggregates
          .map(
            (e) => createAggregation(
              items: allValueItems,
              getFieldValue: getFieldValue,
              criteria: e,
            ),
          )
          .toList();

      return GroupResult(
        fieldName: criteria.fieldName,
        value: e,
        aggregates: aggregates,
        subGroups: nextGroupCriteria == null
            ? List<GroupResult>.empty()
            : groupItems(
                criteria: nextGroupCriteria,
                items: valueItems,
                allItems: allItems,
                getFieldValue: getFieldValue,
              ),
      );
    }).toList();
  }

  AggregateResult createAggregation<T>({
    required Iterable<T> items,
    required dynamic Function(String fieldName, T item) getFieldValue,
    required AggregateCriteria criteria,
  }) {
    dynamic result;
    final nonNullItems = items.where(
      (e) => getFieldValue(criteria.fieldName, e) != null,
    );
    switch (criteria.aggregation) {
      case Aggregations.sum:
        result = nonNullItems
            .map(
              (e) =>
                  num.parse(getFieldValue(criteria.fieldName, e)!.toString()),
            )
            .sum;
        break;
      case Aggregations.average:
        result = nonNullItems
            .map(
              (e) =>
                  num.parse(getFieldValue(criteria.fieldName, e)!.toString()),
            )
            .average;
        break;
      case Aggregations.maximum:
        result = nonNullItems
            .map(
              (e) =>
                  num.parse(getFieldValue(criteria.fieldName, e)!.toString()),
            )
            .maxOrNull;
        break;
      case Aggregations.minimum:
        result = nonNullItems
            .map(
              (e) =>
                  num.parse(getFieldValue(criteria.fieldName, e)!.toString()),
            )
            .minOrNull;
        break;
      case Aggregations.count:
        result = items.length;
        break;
    }

    return AggregateResult(
      fieldName: criteria.fieldName,
      aggregation: criteria.aggregation,
      result: result,
    );
  }
}
