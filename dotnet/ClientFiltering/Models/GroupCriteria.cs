namespace ClientFiltering.Models;

[DataContract]
public record GroupCriteria
{
    [DataMember]
    public required string FieldName { get; init; }

    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public required OrderDirections Direction { get; init; }

    [DataMember]
    public IReadOnlyCollection<AggregateCriteria>? Aggregates { get; init; }

    [DataMember]
    public GroupCriteria? SubGroup { get; init; }
}
