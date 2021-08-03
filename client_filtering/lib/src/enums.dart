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

enum OrderDirections { NotSet, Ascending, Descending }
enum SortableOptions { None, Single, MultiColumn }
