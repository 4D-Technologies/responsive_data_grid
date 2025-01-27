namespace ClientFiltering.Models;

[DataContract]
public record FilterCriteria
{
    /// <summary>
    /// The field to operate on
    /// </summary>
    [DataMember]
    public required string FieldName { get; init; }

    /// <summary>
    /// The operator
    /// </summary>
    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public LogicalOperators Op { get; init; } = LogicalOperators.And;

    /// <summary>
    /// The logical operator for the function
    /// </summary>
    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public RelationalOperators Relation { get; init; }

    /// <summary>
    /// The values to use for comparison
    /// </summary>
    [DataMember]
    public required IReadOnlyCollection<string?> Values { get; init; } = [];
}
