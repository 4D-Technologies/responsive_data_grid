namespace ClientFiltering.Models;

public readonly record struct GroupValueResult
{
    [DataMember]
    public string? Value { get; init; }

    [DataMember]
    public IEnumerable<AggregateResult> Aggregates { get; init; }
}
