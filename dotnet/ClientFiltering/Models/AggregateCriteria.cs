namespace ClientFiltering.Models;

public record AggregateCriteria
{
    [DataMember]
    public required string FieldName { get; init; }

    [DataMember]
    [JsonConverter(typeof(FlexibleEnumConverter<Aggregations>))]
    public required Aggregations Aggregation { get; init; }
}
