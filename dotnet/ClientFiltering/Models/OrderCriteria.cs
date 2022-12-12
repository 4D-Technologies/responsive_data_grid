namespace ClientFiltering.Models;

/// <summary>
/// How Order by shall be executed
/// </summary>
[DataContract]
public readonly record struct OrderCriteria
{
    /// <summary>
    /// The Field to be ordered
    /// </summary>
    [DataMember]
    public string FieldName { get; init; }
    /// <summary>
    /// The direction to order it
    /// </summary>
    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public OrderDirections Direction { get; init; }
}