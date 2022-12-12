namespace ClientFiltering.Models;
[DataContract]
public readonly record struct GroupCriteria
{
    [DataMember]
    public string FieldName { get; init; }

    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public OrderDirections Direction { get; init; }

    [DataMember]
    public IEnumerable<AggregateCriteria> Aggregates { get; init; }
}