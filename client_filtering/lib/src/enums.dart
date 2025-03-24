part of client_filtering;

abstract class IEnum {
  final int value = 0;
}

enum Aggregations implements IEnum {
  sum(1),
  average(2),
  maximum(3),
  minimum(4),
  count(5);

  final int value;

  const Aggregations(this.value);

  factory Aggregations.fromInt(num i) =>
      Aggregations.values.firstWhere((x) => x.value == i);

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

  final int value;

  const Operators(this.value);

  factory Operators.fromInt(num i) =>
      Operators.values.firstWhere((x) => x.value == i);

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
  endsWidth(8),
  startsWith(9),
  notEqual(10),
  notEndsWith(12),
  notStartsWith(11),
  between(13);

  final int value;
  const Logic(this.value);

  factory Logic.fromInt(num i) => Logic.values.firstWhere((x) => x.value == i);

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
      case Logic.endsWidth:
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

  final int value;

  const OrderDirections(this.value);

  factory OrderDirections.fromInt(num i) =>
      OrderDirections.values.firstWhere((x) => x.value == i);

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
