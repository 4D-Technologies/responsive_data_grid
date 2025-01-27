namespace ClientFiltering.Extensions;

using System;
using ClientFiltering.Models;

public static class OrderByCriteriaExtensions
{
    public static IQueryable<T> ApplyOrderByCriteria<T>(
        this IQueryable<T> query,
        OrderCriteria orderBy,
        bool isFirst
    )
    {
        if (orderBy.Direction == OrderDirections.NotSet)
        {
            return query;
        }

        var flag = orderBy.Direction == OrderDirections.Descending;
        var parameterExpression = Expression.Parameter(typeof(T), "p");
        var methodName = !isFirst
            ? flag
                ? "ThenByDescending"
                : "ThenBy"
            : flag
                ? "OrderByDescending"
                : "OrderBy";
        var propertyFromFieldName = Helpers.GetPropertyFromFieldName<T>(
            orderBy.FieldName,
            parameterExpression
        );
        var expression = Expression.Lambda(propertyFromFieldName, parameterExpression);
        var expression2 = Expression.Call(
            typeof(Queryable),
            methodName,
            [typeof(T), propertyFromFieldName.Type],
            query.Expression,
            Expression.Quote(expression)
        );
        query = query.Provider.CreateQuery<T>(expression2);
        return query;
    }
}
