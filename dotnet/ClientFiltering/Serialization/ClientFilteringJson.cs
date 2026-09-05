namespace ClientFiltering.Serialization;

/// <summary>
/// Serializer options for the V2 LoadCriteria wire contract: camelCase,
/// integer enums, <c>logicalOperator</c>, and <c>groupBy</c> as an array.
/// </summary>
public static class ClientFilteringJson
{
    public static JsonSerializerOptions Options { get; } = CreateOptions();

    public static JsonSerializerOptions CreateOptions()
    {
        var options = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            PropertyNameCaseInsensitive = true,
            DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
        };
        options.Converters.Add(new FlexibleEnumConverterFactory());
        return options;
    }
}
