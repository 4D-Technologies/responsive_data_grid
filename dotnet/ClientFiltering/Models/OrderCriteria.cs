namespace ClientFiltering.Models;

/// <summary>
/// How Order by shall be executed
/// </summary>
[DataContract]
public record OrderCriteria
{
    /// <summary>
    /// The Field to be ordered
    /// </summary>
    [DataMember]
    public required string FieldName { get; init; }

    /// <summary>
    /// The direction to order it
    /// </summary>
    [DataMember]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public required OrderDirections Direction { get; init; }
}
