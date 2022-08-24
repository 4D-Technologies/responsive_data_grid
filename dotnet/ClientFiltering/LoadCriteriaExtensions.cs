using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using ClientFiltering.Enums;
using ClientFiltering.Models;

namespace ClientFiltering;

public static class LoadCriteriaExtensions
{
    public static Logic ToLogic(this Expression expression, bool isParentNot = false)
    {
        switch (expression.NodeType)
        {
            case ExpressionType.Equal:
                return Logic.Equals;
            case ExpressionType.NotEqual:
                return Logic.NotEqual;
            case ExpressionType.LessThan:
                return Logic.LessThan;
            case ExpressionType.GreaterThan:
                return Logic.GreaterThan;
            case ExpressionType.LessThanOrEqual:
                return Logic.LessThanOrEqualTo;
            case ExpressionType.GreaterThanOrEqual:
                return Logic.GreaterThanOrEqualTo;
            case ExpressionType.AndAlso:
                //Likely Between
                var aa = (expression as BinaryExpression)!;
                if (aa.Left.NodeType == ExpressionType.LessThanOrEqual && aa.Right.NodeType == ExpressionType.GreaterThanOrEqual)
                    return Logic.Between;

                throw new NotSupportedException($"The two part expression with left type of {aa.Left.NodeType} && right type of {aa.Right.NodeType} is not supported.");
            case ExpressionType.Not:
            case ExpressionType.Call:
                MethodCallExpression mce;
                if (expression is UnaryExpression ue)
                    expression = ue.Operand;

                mce = (expression as MethodCallExpression)!;
                return mce.Method.Name.ToLower() switch
                {
                    "contains" => isParentNot ? Logic.NotContains : Logic.Contains,
                    "startswith" => isParentNot ? Logic.NotStartsWith : Logic.StartsWith,
                    "endswith" => isParentNot ? Logic.NotEndsWith : Logic.EndsWidth,
                    _ => throw new NotSupportedException($"Expression type of {expression.NodeType} is not supported."),
                };
            default:
                throw new NotSupportedException($"Expression type of {expression.NodeType} is not supported.");
        }
    }


    public static IQueryable<T> ApplyLoadCriteria<T>(this IQueryable<T> query, LoadCriteria? criteria)
    {
        if (criteria == null)
            return query;

        if (criteria.Value.FilterBy != null && criteria.Value.FilterBy.Any())
        {
            var param = Expression.Parameter(typeof(T), "p");
            var predicates = new List<(Operators, Expression)>();
            foreach (var filterBy in criteria.Value.FilterBy)
                predicates.Add((filterBy.Op, CreateFilterExpression<T>(filterBy, param)));

            query = query.ApplyFilterPredicates(predicates, param);
        }

        if (criteria.Value.OrderBy != null && criteria.Value.OrderBy.Any())
        {
            for (var pos = 0; pos < criteria.Value.OrderBy.Count(); pos++)
                query = query.ApplyOrderByCriteria(criteria.Value.OrderBy.ElementAt(pos), pos == 0);
        }

        if (criteria.Value.Skip != null)
            query = query.Skip(criteria.Value.Skip.Value);

        if (criteria.Value.Take != null)
            query = query.Take(criteria.Value.Take.Value);

        return query;
    }

    public static IQueryable<T> ApplyOrderByCriteria<T>(this IQueryable<T> query, OrderCriteria orderBy, bool isFirst)
    {
        if (orderBy.Direction == OrderDirections.NotSet)
            return query;

        var descending = orderBy.Direction == OrderDirections.Descending;

        // Dynamically creates a call like this: query.OrderBy(p =&gt; p.SortColumn)
        var parameter = Expression.Parameter(typeof(T), "p");

        var command = isFirst ? descending ? "OrderByDescending" : "OrderBy" : descending ? "ThenByDescending" : "ThenBy";

        var property = typeof(T).GetProperty(orderBy.FieldName) ?? throw new ArgumentOutOfRangeException(orderBy.FieldName, "The property could not be found.");
        // this is the part p.SortColumn
        var propertyAccess = Expression.MakeMemberAccess(parameter, property);
        // this is the part p =&gt; p.SortColumn
        var orderByExpression = Expression.Lambda(propertyAccess, parameter);

        var resultExpression = Expression.Call(
            typeof(Queryable),
            command,
            new Type[] { typeof(T), property.PropertyType },
            query.Expression,
            Expression.Quote(orderByExpression));

        query = query.Provider.CreateQuery<T>(resultExpression);

        return query;
    }

    private static IQueryable<T> ApplyFilterPredicates<T>(this IQueryable<T> source, List<(Operators Op, Expression Value)> predicates, ParameterExpression param)
    {
        if (source == null) throw new ArgumentNullException(nameof(source));
        if (predicates == null) throw new ArgumentNullException(nameof(predicates));

        if (!predicates.Any())
            return source;

        var body = predicates[0].Value;
        foreach (var (Op, Value) in predicates.Skip(1))
        {
            if (Op == Operators.And)
            {
                body = Expression.AndAlso(body, Value);
            }
            else
            {
                body = Expression.OrElse(body, Value);
            }
        }

        var lambda = Expression.Lambda<Func<T, bool>>(body, param);
        return source.Where(lambda);
    }

    private static Expression CreateFilterExpression<T>(FilterCriteria criteria, ParameterExpression param)
    {

        var fields = criteria.FieldName.Split('.');

        var field = typeof(T).GetProperties()
                            .FirstOrDefault(p => string.Equals(p.Name, fields[0], StringComparison.OrdinalIgnoreCase));

        if (field == null)
            throw new InvalidOperationException($"The field '{fields[0]}' does not exist in {typeof(T).Name}.");



        var property = Expression.Property(param, field.Name);

        if (fields.Length > 1)
        {
            foreach (var sField in fields.Skip(1))
            {
                field = field?.PropertyType.GetProperties()
                            .FirstOrDefault(p => string.Equals(p.Name, sField, StringComparison.OrdinalIgnoreCase));

                if (field == null)
                    throw new InvalidOperationException($"The field '{criteria.FieldName}' does not exist in {typeof(T).Name}.");

                property = Expression.Property(property, field.Name);
            }
        }


        var values = criteria.Values.Select(v => GetConstantValue(property, v)).ToArray();

        if (!values.Any())
            throw new InvalidOperationException("There must be at least a single value passed in a filter.");

        var arrayConstant = Expression.Constant(values);

        var arrayContains = typeof(Enumerable).GetMethods(BindingFlags.Static | BindingFlags.Public)
            .Single(x => x.Name == "Contains" && x.GetParameters().Length == 2)
            .MakeGenericMethod(typeof(int));

        Expression expression;

        //Used for creating the member function calls for EndsWith etc.
        switch (criteria.LogicalOperator)
        {
            case Logic.Equals:
                if (values.Length > 1)
                {
                    expression = Expression.Call(arrayContains, arrayConstant, property);
                }
                else
                {

                    expression = Expression.Equal(property, values[0]);
                }
                break;
            case Logic.NotEqual:
                if (values.Length > 1)
                {
                    expression = Expression.Not(Expression.Call(arrayContains, arrayConstant, property));
                }
                else
                {
                    expression = Expression.NotEqual(property, values[0]);
                }
                break;
            case Logic.LessThan:
                expression = Expression.LessThan(property, values[0]);
                break;
            case Logic.GreaterThan:
                expression = Expression.GreaterThan(property, values[0]);
                break;
            case Logic.LessThanOrEqualTo:
                expression = Expression.LessThanOrEqual(property, values[0]);
                break;
            case Logic.GreaterThanOrEqualTo:
                expression = Expression.GreaterThanOrEqual(property, values[0]);
                break;
            case Logic.StartsWith:
            case Logic.NotStartsWith:
                var miStartsWith = typeof(string).GetMethod("StartsWith", new Type[] { typeof(string) })!;
                expression = Expression.Call(Expression.MakeMemberAccess(param, field), miStartsWith, values[0]);
                if (criteria.LogicalOperator == Logic.NotStartsWith)
                    expression = Expression.Not(expression);
                break;
            case Logic.Contains:
            case Logic.NotContains:
                var miContains = typeof(string).GetMethod("Contains", new Type[] { typeof(string) })!;
                expression = Expression.Call(Expression.MakeMemberAccess(param, field), miContains, values[0]);
                if (criteria.LogicalOperator == Logic.NotContains)
                    expression = Expression.Not(expression);
                break;
            case Logic.EndsWidth:
            case Logic.NotEndsWith:
                var miEndsWith = typeof(string).GetMethod("EndsWith", new Type[] { typeof(string) })!;
                expression = Expression.Call(Expression.MakeMemberAccess(param, field), miEndsWith, values[0]);
                if (criteria.LogicalOperator == Logic.NotEndsWith)
                    expression = Expression.Not(expression);
                break;
            case Logic.Between:
                if (values.Length < 2)
                    throw new InvalidOperationException($"Logical Operator Between requires 2 values to be passed but received: {criteria.Values}");

                var expression1 = Expression.LessThanOrEqual(property, values[1]);
                var expression2 = Expression.GreaterThanOrEqual(property, values[0]);
                expression = Expression.AndAlso(expression1, expression2);
                break;
            default:
                throw new ArgumentOutOfRangeException(nameof(criteria), "The operator is not known.");
        }

        return expression;
    }

    private static ConstantExpression GetConstantValue(MemberExpression property, string? value)
    {
        if (value == null)
        {
            return Expression.Constant(null, property.Type);
        }
        else if (property.Type == typeof(bool))
        {
            return Expression.Constant(Convert.ToBoolean(value), property.Type);
        }
        else if (property.Type == typeof(int))
        {
            return Expression.Constant(Convert.ToInt32(value), property.Type);
        }
        else if (property.Type == typeof(double))
        {
            return Expression.Constant(Convert.ToDouble(value), property.Type);
        }
        else if (property.Type == typeof(float))
        {
            return Expression.Constant(Convert.ToSingle(value), property.Type);
        }
        else if (property.Type == typeof(decimal))
        {
            return Expression.Constant(Convert.ToDecimal(value), property.Type);
        }
        else if (property.Type == typeof(long))
        {
            return Expression.Constant(Convert.ToInt64(value), property.Type);
        }
        else if (property.Type == typeof(DateTimeOffset))
        {
            return Expression.Constant(DateTimeOffset.ParseExact(value, "o", CultureInfo.InvariantCulture, DateTimeStyles.AssumeUniversal | DateTimeStyles.RoundtripKind), property.Type);
        }
        else if (property.Type == typeof(DateTime))
        {
            return Expression.Constant(DateTime.ParseExact(value, "o", CultureInfo.InvariantCulture, DateTimeStyles.AssumeUniversal | DateTimeStyles.RoundtripKind), property.Type);
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
}

