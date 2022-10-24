using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Text.Json.Serialization;
using ClientFiltering.Enums;

namespace ClientFiltering.Models;
[DataContract]
public record struct GroupCriteria
{
    [DataMember]
    public string FieldName { get; init; }

    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public OrderDirections Direction { get; init; }

    [DataMember]
    public IEnumerable<AggregateCriteria> Aggregates { get; init; }
}