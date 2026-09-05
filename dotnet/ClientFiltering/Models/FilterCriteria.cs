namespace ClientFiltering.Models;

[DataContract]
[JsonConverter(typeof(FilterCriteriaJsonConverter))]
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
    [JsonConverter(typeof(FlexibleEnumConverter<LogicalOperators>))]
    public LogicalOperators Op { get; init; } = LogicalOperators.And;

    /// <summary>
    /// The comparison operator. Serialized as <c>logicalOperator</c>.
    /// </summary>
    [DataMember]
    [JsonPropertyName("logicalOperator")]
    [JsonConverter(typeof(FlexibleEnumConverter<RelationalOperators>))]
    public RelationalOperators Relation { get; init; }

    /// <summary>
    /// The values to use for comparison
    /// </summary>
    [DataMember]
    public required IReadOnlyCollection<string?> Values { get; init; } = [];
}
