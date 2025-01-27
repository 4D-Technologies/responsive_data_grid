namespace ClientFiltering.Models;

[DataContract]
public record AggregateResult
{
    [DataMember]
    public required string FieldName { get; init; }

    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public required Aggregations Aggregation { get; init; }

    [DataMember]
    public string? Result { get; init; }
}
