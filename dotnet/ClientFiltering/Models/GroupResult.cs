namespace ClientFiltering.Models;
[DataContract]
public record GroupResult
{
    [DataMember]
    public required string FieldName { get; init; }

    [DataMember]
    public required string? Value { get; init; }

    [DataMember]
    public IEnumerable<AggregateResult>? Aggregates { get; init; }

    [DataMember]
    public IEnumerable<GroupResult>? SubGroupResults { get; init; }
}
