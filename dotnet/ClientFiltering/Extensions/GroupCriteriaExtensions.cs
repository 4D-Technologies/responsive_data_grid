namespace ClientFiltering.Extensions;

using System.Linq.Dynamic.Core;
using System.Threading;
using System.Threading.Tasks;
using ClientFiltering.Models;
using GroupResult = Models.GroupResult;

public static class GroupCriteriaExtensions
{
    public static IQueryable<T> ApplyGroupByCriteria<T>(
        this IQueryable<T> query,
        GroupCriteria groupBy,
        bool isFirst
    )
    {
        if (groupBy.Direction == OrderDirections.NotSet)
            return query;

        var flag = groupBy.Direction == OrderDirections.Descending;
        var parameterExpression = Expression.Parameter(typeof(T), "p");
        var methodName = !isFirst
            ? flag
                ? "ThenByDescending"
                : "ThenBy"
            : flag
                ? "OrderByDescending"
                : "OrderBy";
        var propertyFromFieldName = Helpers.GetPropertyFromFieldName<T>(
            groupBy.FieldName,
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

    public static async Task<
        IReadOnlyCollection<GroupResult>
    > CreateGroupResultsFromAppliedCriteria<T>(
        this IQueryable<T> rawQuery,
        IQueryable<T> resultQuery,
        GroupCriteria group,
        CancellationToken cancellationToken = default
    )
    {
        var groupValues = resultQuery
            .GroupBy(group.FieldName)
            .Select("Key")
            .Distinct()
            .Cast<object?>()
            .ToArray();

        var results = await Task.WhenAll(
            groupValues.Select(async v =>
            {
                var aggregates = Enumerable.Empty<AggregateResult>();
                var subGroups = Enumerable.Empty<GroupResult>();

                var groupItemQuery = resultQuery.Where($"{group.FieldName} == \"{v}\"");

                return new GroupResult
                {
                    FieldName = group.FieldName,
                    Value = v?.ToString(),
                    Aggregates =
                        group.Aggregates == null
                            ? null
                            : await GetAggregates(
                                groupItemQuery,
                                group.Aggregates,
                                cancellationToken
                            ),
                    SubGroupResults = group.SubGroup is null
                        ? null
                        : await CreateGroupResultsFromAppliedCriteria(
                            rawQuery,
                            groupItemQuery,
                            group.SubGroup,
                            cancellationToken
                        ),
                };
            })
        );

        return results;
    }

    public static async Task<IReadOnlyCollection<AggregateResult>> GetAggregates<T>(
        IQueryable<T> query,
        IEnumerable<AggregateCriteria> aggregates,
        CancellationToken cancellationToken
    ) =>
        await Task.WhenAll(
            aggregates.Select(async a =>
            {
                //We must get all of the results and then do the aggregation in memory because
                //certain database providers do not support async versions or error if you try and do
                //sync aggregates.

                object result;
                if (a.Aggregation == Aggregations.Count)
                {
                    //Count doesn't require that the field be a numeric value so has to be handled specially.
                    result = (
                        await query
                            .Select(a.FieldName)
                            .Distinct()
                            .ToDynamicArrayAsync(cancellationToken)
                    ).Length;
                }
                else
                {
                    var results = (
                        await query.Select(a.FieldName).ToDynamicArrayAsync(cancellationToken)
                    ).Cast<decimal>();
                    result = a.Aggregation switch
                    {
                        Aggregations.Sum => results.Sum(),
                        Aggregations.Average => results.Average(),
                        Aggregations.Maximum => results.Max(),
                        Aggregations.Minimum => results.Min(),
                        Aggregations.Count => results.Count(),
                        _ => throw new NotImplementedException(
                            $"The aggregation type {a.Aggregation} is not implemented."
                        ),
                    };
                }

                return new AggregateResult
                {
                    FieldName = a.FieldName,
                    Result = result?.ToString(),
                    Aggregation = a.Aggregation,
                };
            })
        );
}
