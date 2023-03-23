namespace ClientFiltering.Models;

[DataContract]
public record Result<TItems>
{
    [DataMember]
    public required IQueryable<TItems> Items { get; init; }

    [DataMember]
    public IEnumerable<GroupResult>? GroupResults { get; init; }

    [DataMember]
    public IEnumerable<AggregateResult>? Aggregates { get; init; }
}