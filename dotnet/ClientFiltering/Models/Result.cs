namespace ClientFiltering.Models;

using System.ComponentModel;

[Description(
    "The result of a query that has paging, grouping, filtering, order by, group by with any aggregates and total aggregates."
)]
[DataContract]
public record Result<TItems>
{
    [Description(
        "All items reguardless of paging, grouping or filtering. Used to get the total count of records in your code."
    )]
    [DataMember]
    public required IQueryable<TItems> AllItems { get; init; }

    [Description(
        "The final items that have all load criteria applied. Should be used in your code as the result set to return."
    )]
    [DataMember]
    public required IQueryable<TItems> FinalItems { get; init; }

    [Description("The group aggregates that you requested if any.")]
    [DataMember]
    public IReadOnlyCollection<GroupResult>? GroupResults { get; init; }

    [Description("The overall aggregates that you requested if any.")]
    [DataMember]
    public IReadOnlyCollection<AggregateResult>? Aggregates { get; init; }
}
