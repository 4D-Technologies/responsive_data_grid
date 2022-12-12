namespace ClientFiltering.Models;

[DataContract]
public readonly record struct AggregateResult
{
    [DataMember]
    public string FieldName { get; init; }

    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public Aggregations Aggregation { get; init; }

    [DataMember]
    public string? Result { get; init; }
}