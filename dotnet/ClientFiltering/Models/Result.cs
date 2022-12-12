namespace ClientFiltering.Models;
public readonly record struct Result<TItems>
{
    public IQueryable<TItems> Items { get; init; }

    public IEnumerable<GroupResult> Groups { get; init; }

    public IEnumerable<AggregateResult> Aggregates { get; init; }
}