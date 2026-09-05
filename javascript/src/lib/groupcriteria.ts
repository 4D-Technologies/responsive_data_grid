import { OrderDirections } from "./enums";
import { AggregateCriteria } from "./aggregatecriteria";

export class GroupCriteria {
  public FieldName: string;
  public Direction = OrderDirections.Ascending;
  public Aggregates: AggregateCriteria[] = [];

  constructor(fieldName = "") {
    this.FieldName = fieldName;
  }
}
