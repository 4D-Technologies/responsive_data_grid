part of responsive_data_grid;

enum FilterOperators { And, Or }

enum LogicalOperators {
  equals,
  lessThan,
  greaterThan,
  lessThanOrEqualTo,
  greaterThanOrEqualTo,
  contains,
  notContains,
  endsWidth,
  startsWith
}

enum OrderDirections { NotSet, Ascending, Descending }
enum SortableOptions { None, Single, MultiColumn }
