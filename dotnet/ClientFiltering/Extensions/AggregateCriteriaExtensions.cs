namespace ClientFiltering.Extensions;

using System.Linq.Dynamic.Core;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using ClientFiltering.Models;

public static class AggregateCriteriaExtensions
{
    public static async Task<IEnumerable<AggregateResult>> CreateAggregatesFromAppliedCriteria<T>(
        this IQueryable<T> rawQuery,
        AggregateCriteria[]? criteria,
        CancellationToken cancellationToken = default
    )
    {
        if (criteria == null || !criteria.Any())
        {
            return [];
        }

        StringBuilder sb = new("new {");
        for (var i = 0; i < criteria!.Length; i++)
        {
            var aggregateCriteria = criteria[i];
            switch (aggregateCriteria.Aggregation)
            {
                case Aggregations.Sum:
                {
                    sb.Append("\tSum(");
                    sb.Append(aggregateCriteria.FieldName);
                    sb.Append(") as V");
                    sb.Append(i);
                    sb.Append(',');
                    sb.AppendLine();
                    break;
                }
                case Aggregations.Average:
                {
                    sb.Append("\tAverage(");
                    sb.Append(aggregateCriteria.FieldName);
                    sb.Append(") as V");
                    sb.Append(i);
                    sb.Append(',');
                    sb.AppendLine();
                    break;
                }
                case Aggregations.Count:
                {
                    sb.Append("\tCount() as V");
                    sb.Append(i);
                    sb.Append(',');
                    sb.AppendLine();
                    break;
                }
                case Aggregations.Maximum:
                {
                    sb.Append("\tMax(");
                    sb.Append(aggregateCriteria.FieldName);
                    sb.Append(") as V");
                    sb.Append(i);
                    sb.Append(',');
                    sb.AppendLine();
                    break;
                }
                case Aggregations.Minimum:
                {
                    sb.Append("\tMin(");
                    sb.Append(aggregateCriteria.FieldName);
                    sb.Append(") as V");
                    sb.Append(i);
                    sb.Append(',');
                    sb.AppendLine();
                    break;
                }
            }

            sb.AppendLine("}");
        }

        object[] array = await (from g in rawQuery group g by true)
            .Select(sb.ToString())
            .ToDynamicArrayAsync(cancellationToken);
        var list = new List<AggregateResult>();
        for (var j = 0; j < criteria!.Length; j++)
        {
            var aggregateCriteria2 = criteria[j];
            var value = array.GetType().GetProperties()[j].GetValue(array);
            list.Add(
                new AggregateResult
                {
                    Aggregation = aggregateCriteria2.Aggregation,
                    FieldName = aggregateCriteria2.FieldName,
                    Result =
                        value == null ? null
                        : value.GetType() == typeof(DateTimeOffset)
                            ? ((DateTimeOffset)value).ToString("o")
                        : value.GetType() == typeof(DateTime) ? ((DateTime)value).ToString("o")
                        : value.ToString(),
                }
            );
        }

        return list;
    }
}
