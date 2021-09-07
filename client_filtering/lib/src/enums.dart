part of client_filtering;

enum Logic {
  and,
  or,
}

enum Operators {
  equals,
  lessThan,
  greaterThan,
  lessThanOrEqualTo,
  greaterThanOrEqualTo,
  contains,
  notContains,
  endsWidth,
  startsWith,
  notEqual,
  notEndsWith,
  notStartsWith,
  between,
}

enum OrderDirections { notSet, ascending, descending }

enum SortableOptions { none, single, multiColumn }

extension LogicExtensions on Logic {
  String get description {
    switch (this) {
      case Logic.and:
        return ClientFilteringLocalizedMessages.and;
      case Logic.or:
        return ClientFilteringLocalizedMessages.or;
    }
  }
}

extension OperatorExtensions on Operators {
  String get description {
    switch (this) {
      case Operators.between:
        return ClientFilteringLocalizedMessages.between;
      case Operators.equals:
        return ClientFilteringLocalizedMessages.equals;
      case Operators.lessThan:
        return ClientFilteringLocalizedMessages.lessThan;
      case Operators.greaterThan:
        return ClientFilteringLocalizedMessages.greaterThan;
      case Operators.lessThanOrEqualTo:
        return ClientFilteringLocalizedMessages.lessThenOrEqualTo;
      case Operators.greaterThanOrEqualTo:
        return ClientFilteringLocalizedMessages.greaterThanOrEqualTo;
      case Operators.contains:
        return ClientFilteringLocalizedMessages.contains;
      case Operators.notContains:
        return ClientFilteringLocalizedMessages.notContains;
      case Operators.endsWidth:
        return ClientFilteringLocalizedMessages.endsWith;
      case Operators.startsWith:
        return ClientFilteringLocalizedMessages.startsWith;
      case Operators.notEqual:
        return ClientFilteringLocalizedMessages.notEqual;
      case Operators.notEndsWith:
        return ClientFilteringLocalizedMessages.notEndsWith;
      case Operators.notStartsWith:
        return ClientFilteringLocalizedMessages.notStartsWith;
    }
  }
}

extension OrderExtensions on OrderDirections {
  String get description {
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

extension SortOptionExtensions on SortableOptions {
  String get description {
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
