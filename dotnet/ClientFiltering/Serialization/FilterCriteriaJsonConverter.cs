namespace ClientFiltering.Serialization;

using ClientFiltering.Models;

public sealed class FilterCriteriaJsonConverter : JsonConverter<FilterCriteria>
{
    public override FilterCriteria Read(
        ref Utf8JsonReader reader,
        Type typeToConvert,
        JsonSerializerOptions options
    )
    {
        using var doc = JsonDocument.ParseValue(ref reader);
        var root = doc.RootElement;
        var relation =
            Property(root, "logicalOperator")
            ?? Property(root, "relation")
            ?? throw new JsonException("logicalOperator is required");

        return new FilterCriteria
        {
            FieldName =
                Property(root, "fieldName")?.GetString()
                ?? throw new JsonException("fieldName is required"),
            Op = ReadEnum(Property(root, "op"), LogicalOperators.And, options),
            Relation = ReadEnum(relation, default(RelationalOperators), options),
            Values = Property(root, "values") is { } values
                ? values
                    .EnumerateArray()
                    .Select(v => v.ValueKind == JsonValueKind.Null ? null : v.ToString())
                    .ToImmutableArray()
                : ImmutableArray<string?>.Empty,
        };
    }

    public override void Write(
        Utf8JsonWriter writer,
        FilterCriteria value,
        JsonSerializerOptions options
    )
    {
        writer.WriteStartObject();
        writer.WriteString("fieldName", value.FieldName);
        writer.WriteNumber("op", (int)value.Op);
        writer.WriteNumber("logicalOperator", (int)value.Relation);
        writer.WritePropertyName("values");
        writer.WriteStartArray();
        foreach (var item in value.Values)
        {
            if (item is null)
            {
                writer.WriteNullValue();
            }
            else
            {
                writer.WriteStringValue(item);
            }
        }
        writer.WriteEndArray();
        writer.WriteEndObject();
    }

    private static JsonElement? Property(JsonElement root, string name)
    {
        foreach (var property in root.EnumerateObject())
        {
            if (string.Equals(property.Name, name, StringComparison.OrdinalIgnoreCase))
            {
                return property.Value;
            }
        }

        return null;
    }

    private static T ReadEnum<T>(
        JsonElement? element,
        T fallback,
        JsonSerializerOptions options
    )
        where T : struct, Enum
    {
        if (element is null)
        {
            return fallback;
        }

        var converter = new FlexibleEnumConverter<T>();
        var bytes = System.Text.Encoding.UTF8.GetBytes(element.Value.GetRawText());
        var reader = new Utf8JsonReader(bytes);
        reader.Read();
        return converter.Read(ref reader, typeof(T), options);
    }
}
