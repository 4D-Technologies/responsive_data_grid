namespace ClientFiltering.Models;

public record AggregateCriteria
{
    [DataMember]
    public required string FieldName { get; init; }

    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public required Aggregations Aggregation { get; init; }
}
