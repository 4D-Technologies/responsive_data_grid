namespace ClientFiltering.Extensions;

using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using ClientFiltering.Models;
using GroupResult = Models.GroupResult;

public static class LoadCriteriaExtensions
{
    public static async Task<Result<TEntity>> GetCriteriaResult<TEntity>(
        this IQueryable<TEntity> query,
        LoadCriteria? criteria,
        CancellationToken cancellationToken = default
    )
        where TEntity : class
    {
        var finalResults = query.ApplyLoadCriteria(criteria);

        IEnumerable<GroupResult> groupResults;
        if (criteria?.GroupBy is null)
        {
            groupResults = [];
        }
        else
        {
            groupResults = await query.CreateGroupResultsFromAppliedCriteria(
                finalResults,
                criteria.GroupBy,
                cancellationToken
            );
        }

        var aggregates = await query.CreateAggregatesFromAppliedCriteria(
            criteria?.Aggregates?.ToArray(),
            cancellationToken
        );

        var result = new Result<TEntity>
        {
            FinalItems = finalResults,
            GroupResults = [.. groupResults],
            Aggregates = [.. aggregates],
            AllItems = query.ApplyFilteredAndOrderedCriteria(criteria),
        };

        return result;
    }

    public static IQueryable<T> ApplyFilteredAndOrderedCriteria<T>(
        this IQueryable<T> query,
        LoadCriteria? criteria
    )
    {
        if (criteria is null)
            return query;

        query = query.ApplyFilterCriteria(criteria.FilterBy);

        if (criteria.OrderBy != null && criteria.OrderBy.Any())
        {
            for (var j = 0; j < criteria.OrderBy.Count(); j++)
            {
                query = query.ApplyOrderByCriteria(criteria.OrderBy.ElementAt(j), j == 0);
            }
        }

        return query;
    }

    public static IQueryable<T> ApplyLoadCriteria<T>(
        this IQueryable<T> query,
        LoadCriteria? criteria
    )
    {
        if (criteria is null)
            return query;

        query = query.ApplyFilteredAndOrderedCriteria(criteria);

        if (criteria.GroupBy is not null)
            query = query.ApplyGroupByCriteria(criteria.GroupBy, true);

        if (criteria.Skip is not null)
        {
            query = query.Skip(criteria.Skip.Value);
        }

        if (criteria.Take is not null)
        {
            query = query.Take(criteria.Take.Value);
        }

        return query;
    }
}
