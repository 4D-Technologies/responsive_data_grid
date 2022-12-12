namespace ClientFiltering.Models;

public readonly record struct AggregateCriteria
{
    [DataMember]
    public string FieldName { get; init; }

    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public Aggregations Aggregation { get; init; }
}