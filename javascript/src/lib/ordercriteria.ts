import { OrderDirections } from "./enums";

export class OrderCriteria {
  /// <summary>
  /// The Field to be ordered
  /// </summary>
  public FieldName: string;
  /// <summary>
  /// The direction to order it
  /// </summary>
  public Direction = OrderDirections.Ascending;
}
