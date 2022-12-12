namespace ClientFiltering.Models;

[DataContract]
public readonly record struct FilterCriteria
{
    /// <summary>
    /// The field to operate on
    /// </summary>
    [DataMember]
    public string FieldName { get; init; }
    /// <summary>
    /// The operator
    /// </summary>
    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public Operators Op { get; init; }
    /// <summary>
    /// The logical operator for the function
    /// </summary>
    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public Logic LogicalOperator { get; init; }
    /// <summary>
    /// The values to use for comparison
    /// </summary>
    [DataMember]
    public IEnumerable<string?> Values { get; init; }
}