part of '../client_filtering.dart';

abstract class IEnum {
  final int value = 0;
}

enum Aggregations implements IEnum {
  sum(1),
  average(2),
  maximum(3),
  minimum(4),
  count(5);

  @override
  final int value;

  const Aggregations(this.value);

  factory Aggregations.fromInt(num i) =>
      Aggregations.values.firstWhere((x) => x.value == i);

  factory Aggregations.fromJson(dynamic value) => parseWireEnum(
    value: value,
    fromInt: Aggregations.fromInt,
    typeName: 'Aggregations',
    names: {
      'sum': Aggregations.sum,
      'average': Aggregations.average,
      'maximum': Aggregations.maximum,
      'minimum': Aggregations.minimum,
      'count': Aggregations.count,
    },
  );

  @override
  String toString() {
    switch (this) {
      case Aggregations.sum:
        return ClientFilteringLocalizedMessages.sum;
      case Aggregations.average:
        return ClientFilteringLocalizedMessages.average;
      case Aggregations.maximum:
        return ClientFilteringLocalizedMessages.maximum;
      case Aggregations.minimum:
        return ClientFilteringLocalizedMessages.minimum;
      case Aggregations.count:
        return ClientFilteringLocalizedMessages.count;
    }
  }
}

enum Operators implements IEnum {
  and(1),
  or(2);

  @override
  final int value;

  const Operators(this.value);

  factory Operators.fromInt(num i) =>
      Operators.values.firstWhere((x) => x.value == i);

  factory Operators.fromJson(dynamic value) => parseWireEnum(
    value: value,
    fromInt: Operators.fromInt,
    typeName: 'Operators',
    names: {'and': Operators.and, 'or': Operators.or},
  );

  @override
  String toString() {
    switch (this) {
      case Operators.and:
        return ClientFilteringLocalizedMessages.and;
      case Operators.or:
        return ClientFilteringLocalizedMessages.or;
    }
  }
}

enum Logic implements IEnum {
  equals(1),
  lessThan(2),
  greaterThan(3),
  lessThanOrEqualTo(4),
  greaterThanOrEqualTo(5),
  contains(6),
  notContains(7),
  endsWith(8),
  startsWith(9),
  notEqual(10),
  notEndsWith(12),
  notStartsWith(11),
  between(13);

  /// Typo kept as a public alias so existing call sites keep compiling.
  @Deprecated('Use Logic.endsWith')
  static const Logic endsWidth = Logic.endsWith;

  @override
  final int value;
  const Logic(this.value);

  factory Logic.fromInt(num i) => Logic.values.firstWhere((x) => x.value == i);

  factory Logic.fromJson(dynamic value) => parseWireEnum(
    value: value,
    fromInt: Logic.fromInt,
    typeName: 'Logic',
    names: {
      'equals': Logic.equals,
      'lessthan': Logic.lessThan,
      'greaterthan': Logic.greaterThan,
      'lessthanorequalto': Logic.lessThanOrEqualTo,
      'greaterthanorequalto': Logic.greaterThanOrEqualTo,
      'contains': Logic.contains,
      'notcontains': Logic.notContains,
      'endswith': Logic.endsWith,
      'endswidth': Logic.endsWith,
      'startswith': Logic.startsWith,
      'notequal': Logic.notEqual,
      'notstartswith': Logic.notStartsWith,
      'notendswith': Logic.notEndsWith,
      'between': Logic.between,
    },
  );

  @override
  String toString() {
    switch (this) {
      case Logic.between:
        return ClientFilteringLocalizedMessages.between;
      case Logic.equals:
        return ClientFilteringLocalizedMessages.equals;
      case Logic.lessThan:
        return ClientFilteringLocalizedMessages.lessThan;
      case Logic.greaterThan:
        return ClientFilteringLocalizedMessages.greaterThan;
      case Logic.lessThanOrEqualTo:
        return ClientFilteringLocalizedMessages.lessThenOrEqualTo;
      case Logic.greaterThanOrEqualTo:
        return ClientFilteringLocalizedMessages.greaterThanOrEqualTo;
      case Logic.contains:
        return ClientFilteringLocalizedMessages.contains;
      case Logic.notContains:
        return ClientFilteringLocalizedMessages.notContains;
      case Logic.endsWith:
        return ClientFilteringLocalizedMessages.endsWith;
      case Logic.startsWith:
        return ClientFilteringLocalizedMessages.startsWith;
      case Logic.notEqual:
        return ClientFilteringLocalizedMessages.notEqual;
      case Logic.notEndsWith:
        return ClientFilteringLocalizedMessages.notEndsWith;
      case Logic.notStartsWith:
        return ClientFilteringLocalizedMessages.notStartsWith;
    }
  }
}

enum OrderDirections implements IEnum {
  notSet(0),
  ascending(1),
  descending(2);

  @override
  final int value;

  const OrderDirections(this.value);

  factory OrderDirections.fromInt(num i) =>
      OrderDirections.values.firstWhere((x) => x.value == i);

  factory OrderDirections.fromJson(dynamic value) => parseWireEnum(
    value: value,
    fromInt: OrderDirections.fromInt,
    typeName: 'OrderDirections',
    names: {
      'notset': OrderDirections.notSet,
      'ascending': OrderDirections.ascending,
      'descending': OrderDirections.descending,
    },
  );

  @override
  String toString() {
    switch (this) {
      case OrderDirections.notSet:
        return ClientFilteringLocalizedMessages.notSet;
      case OrderDirections.ascending:
        return ClientFilteringLocalizedMessages.ascending;
      case OrderDirections.descending:
        return ClientFilteringLocalizedMessages.descending;
    }
  }
}

enum SortableOptions implements IEnum {
  none(0),
  single(1),
  multiColumn(2);

  @override
  final int value;
  const SortableOptions(this.value);

  factory SortableOptions.fromInt(num i) =>
      SortableOptions.values.firstWhere((x) => x.value == i);

  @override
  String toString() {
    switch (this) {
      case SortableOptions.none:
        return ClientFilteringLocalizedMessages.none;
      case SortableOptions.single:
        return ClientFilteringLocalizedMessages.single;
      case SortableOptions.multiColumn:
        return ClientFilteringLocalizedMessages.multiColumn;
    }
  }
}
