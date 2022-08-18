export enum Logic {
  Equals = 1,
  LessThan = 2,
  GreaterThan = 3,
  LessThanOrEqualTo = 4,
  GreaterThanOrEqualTo = 5,
  Contains = 6,
  NotContains = 7,
  EndsWidth = 8,
  StartsWith = 9,
  NotEqual = 10,
  NotStartsWith = 11,
  NotEndsWith = 12,
  Between = 13,
}

export enum Operators {
  And = 1,
  Or = 2,
}

export enum OrderDirections {
  NotSet = 0,
  Ascending = 1,
  Descending = 2,
}
