namespace ClientFiltering.Serialization;

public sealed class FlexibleEnumConverter<T> : JsonConverter<T>
    where T : struct, Enum
{
    public override T Read(
        ref Utf8JsonReader reader,
        Type typeToConvert,
        JsonSerializerOptions options
    )
    {
        if (reader.TokenType == JsonTokenType.Number)
        {
            return (T)Enum.ToObject(typeof(T), reader.GetInt32());
        }

        if (reader.TokenType == JsonTokenType.String)
        {
            var text = reader.GetString() ?? throw new JsonException($"Missing {typeof(T).Name}");
            if (int.TryParse(text, out var numeric))
            {
                return (T)Enum.ToObject(typeof(T), numeric);
            }

            if (Enum.TryParse(text, ignoreCase: true, out T parsed))
            {
                return parsed;
            }

            if (
                typeof(T) == typeof(RelationalOperators)
                && text.Equals("EndsWith", StringComparison.OrdinalIgnoreCase)
            )
            {
                return (T)(object)RelationalOperators.EndsWidth;
            }

            throw new JsonException($"Cannot parse {typeof(T).Name} from '{text}'");
        }

        throw new JsonException($"Unexpected token {reader.TokenType} for {typeof(T).Name}");
    }

    public override void Write(Utf8JsonWriter writer, T value, JsonSerializerOptions options) =>
        writer.WriteNumberValue((int)(object)value);
}

public sealed class FlexibleEnumConverterFactory : JsonConverterFactory
{
    public override bool CanConvert(Type typeToConvert) => typeToConvert.IsEnum;

    public override JsonConverter CreateConverter(Type typeToConvert, JsonSerializerOptions options)
    {
        var converterType = typeof(FlexibleEnumConverter<>).MakeGenericType(typeToConvert);
        return (JsonConverter)Activator.CreateInstance(converterType)!;
    }
}
