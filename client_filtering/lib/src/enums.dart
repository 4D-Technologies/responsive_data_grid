part of client_filtering;

enum Logic { And, Or }

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
}

enum OrderDirections { notSet, ascending, descending }
enum SortableOptions { none, single, multiColumn }
