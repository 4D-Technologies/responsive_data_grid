namespace ClientFiltering.Extensions;

using System;
using System.Text.RegularExpressions;

internal static partial class Helpers
{
    public static RelationalOperators ToRelationalOperator(
        this Expression expression,
        bool isParentNot = false
    )
    {
        switch (expression.NodeType)
        {
            case ExpressionType.Equal:
                return RelationalOperators.Equals;
            case ExpressionType.NotEqual:
                return RelationalOperators.NotEqual;
            case ExpressionType.LessThan:
                return RelationalOperators.LessThan;
            case ExpressionType.GreaterThan:
                return RelationalOperators.GreaterThan;
            case ExpressionType.LessThanOrEqual:
                return RelationalOperators.LessThanOrEqualTo;
            case ExpressionType.GreaterThanOrEqual:
                return RelationalOperators.GreaterThanOrEqualTo;
            case ExpressionType.Call:
            case ExpressionType.Not:
            {
                if (expression is UnaryExpression unaryExpression)
                    expression = unaryExpression.Operand;

                return (
                    (expression as MethodCallExpression)?.Method.Name.ToLower(
                        CultureInfo.InvariantCulture
                    )
                ) switch
                {
                    "contains" => isParentNot
                        ? RelationalOperators.NotContains
                        : RelationalOperators.Contains,
                    "startswith" => isParentNot
                        ? RelationalOperators.NotStartsWith
                        : RelationalOperators.StartsWith,
                    "endswith" => isParentNot
                        ? RelationalOperators.NotEndsWith
                        : RelationalOperators.EndsWidth,
                    _ => throw new NotSupportedException(),
                };
            }
            default:
                throw new NotSupportedException();
        }
    }

    public static ConstantExpression GetConstantValue(MemberExpression property, string? value)
    {
        if (value == null)
        {
            return Expression.Constant(null, property.Type);
        }
        else if (property.Type == typeof(bool) || property.Type == typeof(bool?))
        {
            return Expression.Constant(
                Convert.ToBoolean(value, CultureInfo.InvariantCulture),
                property.Type
            );
        }
        else if (property.Type == typeof(int) || property.Type == typeof(int?))
        {
            return Expression.Constant(
                Convert.ToInt32(value, CultureInfo.InvariantCulture),
                property.Type
            );
        }
        else if (property.Type == typeof(double) || property.Type == typeof(double?))
        {
            return Expression.Constant(
                Convert.ToDouble(value, CultureInfo.InvariantCulture),
                property.Type
            );
        }
        else if (property.Type == typeof(float) || property.Type == typeof(float?))
        {
            return Expression.Constant(
                Convert.ToSingle(value, CultureInfo.InvariantCulture),
                property.Type
            );
        }
        else if (property.Type == typeof(decimal) || property.Type == typeof(decimal?))
        {
            return Expression.Constant(
                Convert.ToDecimal(value, CultureInfo.InvariantCulture),
                property.Type
            );
        }
        else if (property.Type == typeof(long) || property.Type == typeof(long?))
        {
            return Expression.Constant(
                Convert.ToInt64(value, CultureInfo.InvariantCulture),
                property.Type
            );
        }
        else if (
            property.Type == typeof(DateTimeOffset)
            || property.Type == typeof(DateTimeOffset?)
        )
        {
            DateTimeOffset dt;
            if (regExDateTime().IsMatch(value))
            {
                dt = DateTimeOffset.FromUnixTimeMilliseconds(
                    Convert.ToInt64(value, CultureInfo.InvariantCulture)
                );
            }
            else
            {
                dt = DateTimeOffset.Parse(
                    value,
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.AssumeUniversal | DateTimeStyles.RoundtripKind
                );
            }

            return Expression.Constant(dt, property.Type);
        }
        else if (property.Type == typeof(DateTime) || property.Type == typeof(DateTime?))
        {
            DateTime dt;
            if (RegExDigitsOnly().IsMatch(value))
            {
                dt = DateTimeOffset
                    .FromUnixTimeMilliseconds(Convert.ToInt64(value, CultureInfo.InvariantCulture))
                    .DateTime;
            }
            else
            {
                dt = DateTime.Parse(
                    value,
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.AssumeUniversal | DateTimeStyles.RoundtripKind
                );
            }

            return Expression.Constant(dt, property.Type);
        }
        else if (property.Type.IsEnum)
        {
            var enumValue = Enum.Parse(property.Type, value);
            return Expression.Constant(enumValue, property.Type);
        }
        else
        {
            return Expression.Constant(value, property.Type);
        }
    }

    public static MemberExpression GetPropertyFromFieldName<T>(
        string fieldName,
        ParameterExpression parameter
    )
    {
        var fields = fieldName.Split('.');
        var propertyInfo =
            typeof(T)!
                .GetProperties()
                .FirstOrDefault(
                    (p) => string.Equals(p.Name, fields[0], StringComparison.OrdinalIgnoreCase)
                ) ?? throw new InvalidOperationException();

        var memberExpression = Expression.Property(parameter, propertyInfo.Name);
        if (fields.Length > 1)
        {
            foreach (var sField in fields.Skip(1))
            {
                propertyInfo = propertyInfo
                    ?.PropertyType.GetProperties()
                    .FirstOrDefault(
                        (p) => string.Equals(p.Name, sField, StringComparison.OrdinalIgnoreCase)
                    );
                if (propertyInfo == null)
                    throw new InvalidOperationException();

                memberExpression = Expression.Property(memberExpression, propertyInfo.Name);
            }

            return memberExpression;
        }

        return memberExpression;
    }

    [GeneratedRegex("^\\d*$", RegexOptions.IgnoreCase | RegexOptions.Singleline, "en-US")]
    private static partial Regex regExDateTime();

    [GeneratedRegex("^\\d*$", RegexOptions.IgnoreCase | RegexOptions.Singleline, "en-US")]
    private static partial Regex RegExDigitsOnly();
}
