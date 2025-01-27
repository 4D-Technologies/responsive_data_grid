namespace ClientFiltering.Extensions;

using System;
using System.Reflection;
using ClientFiltering.Models;

public static class FilterCriteriaExtensions
{
    public static IQueryable<T> ApplyFilterCriteria<T>(
        this IQueryable<T> query,
        IEnumerable<FilterCriteria>? filterCriteria
    )
    {
        if (filterCriteria == null || !filterCriteria.Any())
        {
            return query;
        }

        var param = Expression.Parameter(typeof(T), "p");
        List<(LogicalOperators, Expression)> list = [];
        foreach (var item in filterCriteria!)
        {
            list.Add((item.Op, CreateFilterExpression<T>(item, param)));
        }

        query = query.ApplyFilterPredicates(list, param);
        return query;
    }

    private static IQueryable<T> ApplyFilterPredicates<T>(
        this IQueryable<T> source,
        List<(LogicalOperators Op, Expression Value)> predicates,
        ParameterExpression param
    )
    {
        if (source == null)
            throw new ArgumentNullException(nameof(source));
        if (predicates == null)
            throw new ArgumentNullException(nameof(predicates));

        if (!predicates.Any())
            return source;

        var body = predicates[0].Value;
        foreach (var (op, value) in predicates.Skip(1))
        {
            if (op == LogicalOperators.And)
            {
                body = Expression.AndAlso(body, value);
            }
            else
            {
                body = Expression.OrElse(body, value);
            }
        }

        var lambda = Expression.Lambda<Func<T, bool>>(body, param);
        return source.Where(lambda);
    }

    private static Expression CreateFilterExpression<T>(
        FilterCriteria criteria,
        ParameterExpression param
    )
    {
        var fields = criteria.FieldName.Split('.');

        var field =
            typeof(T)
                .GetProperties()
                .FirstOrDefault(p =>
                    string.Equals(p.Name, fields[0], StringComparison.OrdinalIgnoreCase)
                )
            ?? throw new InvalidOperationException(
                $"The field '{fields[0]}' does not exist in {typeof(T).Name}."
            );

        var property = Expression.Property(param, field.Name);

        if (fields.Length > 1)
        {
            foreach (var sField in fields.Skip(1))
            {
                field = field
                    ?.PropertyType.GetProperties()
                    .FirstOrDefault(p =>
                        string.Equals(p.Name, sField, StringComparison.OrdinalIgnoreCase)
                    );

                if (field == null)
                {
                    throw new InvalidOperationException(
                        $"The field '{criteria.FieldName}' does not exist in {typeof(T).Name}."
                    );
                }

                property = Expression.Property(property, field.Name);
            }
        }

        var values = criteria.Values.Select(v => Helpers.GetConstantValue(property, v)).ToArray();

        if (!values.Any())
        {
            throw new InvalidOperationException(
                "There must be at least a single value passed in a filter."
            );
        }

        var arrayConstant = Expression.Constant(values);

        var arrayContains = typeof(Enumerable)
            .GetMethods(BindingFlags.Static | BindingFlags.Public)
            .Single(x => x.Name == "Contains" && x.GetParameters().Length == 2)
            .MakeGenericMethod(typeof(int));

        Expression expression;

        //Used for creating the member function calls for EndsWith etc.
        switch (criteria.Relation)
        {
            case RelationalOperators.Equals:
                if (values.Length > 1)
                {
                    expression = Expression.Call(arrayContains, arrayConstant, property);
                }
                else
                {
                    expression = Expression.Equal(property, values[0]);
                }
                break;
            case RelationalOperators.NotEqual:
                if (values.Length > 1)
                {
                    expression = Expression.Not(
                        Expression.Call(arrayContains, arrayConstant, property)
                    );
                }
                else
                {
                    expression = Expression.NotEqual(property, values[0]);
                }
                break;
            case RelationalOperators.LessThan:
                expression = Expression.LessThan(property, values[0]);
                break;
            case RelationalOperators.GreaterThan:
                expression = Expression.GreaterThan(property, values[0]);
                break;
            case RelationalOperators.LessThanOrEqualTo:
                expression = Expression.LessThanOrEqual(property, values[0]);
                break;
            case RelationalOperators.GreaterThanOrEqualTo:
                expression = Expression.GreaterThanOrEqual(property, values[0]);
                break;
            case RelationalOperators.StartsWith:
            case RelationalOperators.NotStartsWith:
                var miStartsWith = typeof(string).GetMethod("StartsWith", [typeof(string)])!;
                expression = Expression.Call(
                    Expression.MakeMemberAccess(param, field),
                    miStartsWith,
                    values[0]
                );
                if (criteria.Relation == RelationalOperators.NotStartsWith)
                    expression = Expression.Not(expression);
                break;
            case RelationalOperators.Contains:
            case RelationalOperators.NotContains:
                var miContains = typeof(string).GetMethod("Contains", [typeof(string)])!;
                expression = Expression.Call(
                    Expression.MakeMemberAccess(param, field),
                    miContains,
                    values[0]
                );
                if (criteria.Relation == RelationalOperators.NotContains)
                    expression = Expression.Not(expression);
                break;
            case RelationalOperators.EndsWidth:
            case RelationalOperators.NotEndsWith:
                var miEndsWith = typeof(string).GetMethod("EndsWith", [typeof(string)])!;
                expression = Expression.Call(
                    Expression.MakeMemberAccess(param, field),
                    miEndsWith,
                    values[0]
                );
                if (criteria.Relation == RelationalOperators.NotEndsWith)
                    expression = Expression.Not(expression);
                break;
            default:
                throw new ArgumentOutOfRangeException(
                    nameof(criteria),
                    "The operator is not known."
                );
        }

        return expression;
    }
}
