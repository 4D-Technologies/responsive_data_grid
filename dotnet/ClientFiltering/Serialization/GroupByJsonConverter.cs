namespace ClientFiltering.Serialization;

using ClientFiltering.Models;

/// <summary>
/// Wire format is a <c>groupBy</c> array. Nested <see cref="GroupCriteria.SubGroup"/>
/// is still accepted when deserializing a single object.
/// </summary>
public sealed class GroupByJsonConverter : JsonConverter<GroupCriteria?>
{
    public override GroupCriteria? Read(
        ref Utf8JsonReader reader,
        Type typeToConvert,
        JsonSerializerOptions options
    )
    {
        if (reader.TokenType == JsonTokenType.Null)
        {
            return null;
        }

        if (reader.TokenType == JsonTokenType.StartArray)
        {
            var items =
                JsonSerializer.Deserialize<List<GroupCriteria>>(ref reader, options) ?? [];
            return Chain(items);
        }

        if (reader.TokenType == JsonTokenType.StartObject)
        {
            return JsonSerializer.Deserialize<GroupCriteria>(ref reader, options);
        }

        throw new JsonException($"Unexpected token {reader.TokenType} for groupBy");
    }

    public override void Write(
        Utf8JsonWriter writer,
        GroupCriteria? value,
        JsonSerializerOptions options
    )
    {
        if (value is null)
        {
            writer.WriteNullValue();
            return;
        }

        writer.WriteStartArray();
        for (var group = value; group is not null; group = group.SubGroup)
        {
            var item = group with { SubGroup = null };
            JsonSerializer.Serialize(writer, item, options);
        }
        writer.WriteEndArray();
    }

    private static GroupCriteria? Chain(IReadOnlyList<GroupCriteria> items)
    {
        GroupCriteria? next = null;
        for (var i = items.Count - 1; i >= 0; i--)
        {
            next = items[i] with { SubGroup = next };
        }

        return next;
    }
}
