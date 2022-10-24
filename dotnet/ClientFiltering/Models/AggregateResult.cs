using System.Runtime.Serialization;
using System.Text.Json.Serialization;
using ClientFiltering.Enums;

namespace ClientFiltering.Models;

[DataContract]
public record struct AggregateResult
{
    [DataMember]
    public string FieldName { get; init; }

    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public Aggregations Aggregation { get; init; }

    [DataMember]
    public string? Result { get; init; }
}