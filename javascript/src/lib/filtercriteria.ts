import { Operators, Logic } from "./enums";
export class FilterCriteria {
  /// <summary>
  /// The field to operate on
  /// </summary>
  public FieldName: string;
  /// <summary>
  /// The operator
  /// </summary>
  public Op = Operators.And;
  /// <summary>
  /// The logical operator for the function
  /// </summary>
  public LogicalOperator = Logic.Equals;
  /// <summary>
  /// The values to use for comparison
  /// </summary>
  public Values = Array.from<string | null>([]);
}
