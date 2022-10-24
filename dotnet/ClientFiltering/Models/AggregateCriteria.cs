using System;
using System.Runtime.Serialization;
using System.Text.Json.Serialization;
using ClientFiltering.Enums;

namespace ClientFiltering.Models;

public record struct AggregateCriteria
{
    [DataMember]
    public string FieldName { get; init; }

    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public Aggregations Aggregation { get; init; }
}