using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace ClientFiltering.Models;

public record struct GroupValueResult
{
    [DataMember]
    public string? Value { get; init; }

    [DataMember]
    public IEnumerable<AggregateResult> Aggregates { get; init; }
}
