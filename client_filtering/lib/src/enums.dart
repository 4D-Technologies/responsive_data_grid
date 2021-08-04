part of client_filtering;

enum Logic { and, or }

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
