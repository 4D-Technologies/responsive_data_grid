namespace ClientFiltering.Models;
[DataContract]
public readonly record struct GroupResult
{
    [DataMember]
    public string FieldName { get; init; }

    [DataMember]
    public String? Value { get; init; }

    [DataMember]
    public IEnumerable<AggregateResult> Aggregates { get; init; }

    [DataMember]
    public IEnumerable<GroupResult> SubGroups { get; init; }
}
