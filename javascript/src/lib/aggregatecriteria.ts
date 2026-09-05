export class AggregateCriteria {
  public FieldName: string;
  public Aggregation: number;

  constructor(fieldName = "", aggregation = 0) {
    this.FieldName = fieldName;
    this.Aggregation = aggregation;
  }
}
