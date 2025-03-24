part of client_filtering;

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
  })  : this.filterBy =
            filterBy ?? List<FilterCriteria<dynamic>>.empty(growable: true),
        this.orderBy = orderBy ?? List<OrderCriteria>.empty(growable: true);

  factory LoadCriteria.fromJson(Map<String, dynamic> json) => LoadCriteria(
        skip: json["skip"] as int?,
        take: json["take"] as int?,
        filterBy: (json["filterBy"] as List)
            .map<FilterCriteria<dynamic>>((dynamic model) =>
                FilterCriteria.fromJson<dynamic>(model as Map<String, dynamic>))
            .toList(),
        orderBy: (json["orderBy"] as List)
            .map<OrderCriteria>((dynamic model) =>
                OrderCriteria.fromJson(model as Map<String, dynamic>))
            .toList(),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoadCriteria &&
        other.skip == skip &&
        other.take == take &&
        listEquals(other.filterBy, filterBy) &&
        listEquals(other.orderBy, orderBy);
  }

  @override
  int get hashCode {
    return skip.hashCode ^ take.hashCode ^ filterBy.hashCode ^ orderBy.hashCode;
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

  Map<String, dynamic> toJson() {
    // ignore: unnecessary_cast
    return {
      'skip': skip,
      'take': take,
      'filterBy': filterBy.map((x) => x.toJson()).toList(),
      'orderBy': orderBy.map((x) => x.toJson()).toList(),
    } as Map<String, dynamic>;
  }

  Iterable<T> filterItems<T>({
    required Iterable<T> data,
    required dynamic Function(String fieldName, T item) getFieldValue,
  }) {
    Iterable<T> items = List<T>.from(data);

    this.filterBy.forEach((criteria) {
      if (criteria.op == Operators.or)
        throw UnsupportedError("Or is not supported in Dart.");

      switch (criteria.logicalOperator) {
        case Logic.equals:
          items = items.where((e) {
            final dynamic value = getFieldValue(criteria.fieldName, e);

            return criteria.values.contains(value);
          });
          break;
        case Logic.lessThan:
          items = items.where((e) {
            final dynamic value = getFieldValue(criteria.fieldName, e);
            final dynamic cValue =
                criteria.values.isEmpty ? null : criteria.values.first;
            if (value == null || cValue == null) return false;

            if (value is DateTime && cValue is DateTime)
              return value.compareTo(cValue) < 0;

            return (value < cValue) as bool;
          });
          break;
        case Logic.greaterThan:
          items = items.where((e) {
            final dynamic value = getFieldValue(criteria.fieldName, e);
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
            final dynamic value = getFieldValue(criteria.fieldName, e);
            final dynamic cValue =
                criteria.values.isEmpty ? null : criteria.values.first;
            if (value == null || cValue == null) return false;

            if (value is DateTime && cValue is DateTime)
              return value.compareTo(cValue) <= 0;

            return (value <= cValue) as bool;
          });
          break;
        case Logic.greaterThanOrEqualTo:
          items = items.where((e) {
            final dynamic value = getFieldValue(criteria.fieldName, e);
            final dynamic cValue =
                criteria.values.isEmpty ? null : criteria.values.first;
            if (value == null || cValue == null) return false;

            if (value is DateTime && cValue is DateTime)
              return value.compareTo(cValue) >= 0;

            return (value >= cValue) as bool;
          });
          break;
        case Logic.contains:
          items = items.where((e) {
            final dynamic value = getFieldValue(criteria.fieldName, e);
            final dynamic cValue =
                criteria.values.isEmpty ? null : criteria.values.first;

            if (value == null ||
                cValue == null ||
                !(value is String) ||
                !(cValue is String)) return false;

            return value.contains(cValue);
          });
          break;
        case Logic.notContains:
          items = items.where((e) {
            final dynamic value = getFieldValue(criteria.fieldName, e);
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
            final dynamic value = getFieldValue(criteria.fieldName, e);
            final dynamic cValue =
                criteria.values.isEmpty ? null : criteria.values.first;

            if (value == null ||
                cValue == null ||
                !(value is String) ||
                !(cValue is String)) return false;

            return value.endsWith(cValue);
          });
          break;
        case Logic.startsWith:
          items = items.where((e) {
            final dynamic value = getFieldValue(criteria.fieldName, e);
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
            final dynamic value = getFieldValue(criteria.fieldName, e);
            return !criteria.values.contains(value);
          });
          break;
        case Logic.notEndsWith:
          items = items.where((e) {
            final dynamic value = getFieldValue(criteria.fieldName, e);
            final dynamic cValue =
                criteria.values.isEmpty ? null : criteria.values.first;
            if (value == null ||
                cValue == null ||
                !(value is String) ||
                !(cValue is String)) return false;

            return !value.endsWith(cValue);
          });
          break;
        case Logic.notStartsWith:
          items = items.where((e) {
            final dynamic value = getFieldValue(criteria.fieldName, e);
            final dynamic cValue =
                criteria.values.isEmpty ? null : criteria.values.first;
            if (value == null ||
                cValue == null ||
                !(value is String) ||
                !(cValue is String)) return false;

            return !value.startsWith(cValue);
          });
          break;
        case Logic.between:
          items = items.where((e) {
            final dynamic value = getFieldValue(criteria.fieldName, e);
            final dynamic cValue1 =
                criteria.values.isEmpty ? null : criteria.values.first;
            final dynamic cValue2 =
                criteria.values.length > 1 ? criteria.values.last : null;
            if (value == null || cValue1 == null || cValue2 == null)
              return false;

            return (value >= cValue1) as bool && (value <= cValue2) as bool;
          });
          break;
      }
    });

    return items;
  }

  Iterable<T> orderItems<T>({
    required Iterable<T> items,
    required dynamic Function(String fieldName, T item) getFieldValue,
  }) {
    final orderInfo = List<OrderCriteria>.from(this.orderBy, growable: true);

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
              (i) => getFieldValue(criteria.fieldName, i)?.toString() == e),
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
          .map((e) => createAggregation(
                items: allValueItems,
                getFieldValue: getFieldValue,
                criteria: e,
              ))
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
    final nonNullItems =
        items.where((e) => getFieldValue(criteria.fieldName, e) != null);
    switch (criteria.aggregation) {
      case Aggregations.sum:
        result = nonNullItems
            .map((e) =>
                num.parse(getFieldValue(criteria.fieldName, e)!.toString()))
            .sum;
        break;
      case Aggregations.average:
        result = nonNullItems
            .map((e) =>
                num.parse(getFieldValue(criteria.fieldName, e)!.toString()))
            .average;
        break;
      case Aggregations.maximum:
        result = nonNullItems
            .map((e) =>
                num.parse(getFieldValue(criteria.fieldName, e)!.toString()))
            .maxOrNull;
        break;
      case Aggregations.minimum:
        result = nonNullItems
            .map((e) =>
                num.parse(getFieldValue(criteria.fieldName, e)!.toString()))
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
