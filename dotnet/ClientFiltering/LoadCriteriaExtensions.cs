using System.Linq.Dynamic.Core;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using ClientFiltering.Models;
using GroupResult = ClientFiltering.Models.GroupResult;

namespace ClientFiltering;

public static class LoadCriteriaExtensions
{
    public static async Task<Result<TEntity>> GetCriteriaResult<TEntity>(this IQueryable<TEntity> query, LoadCriteria? criteria, CancellationToken cancellationToken = default) where TEntity : class
    {
        IQueryable<TEntity> filteredAndOrderedResult = query.ApplyLoadCriteria(criteria);

        IEnumerable<GroupResult> groupResults;
        if (criteria?.GroupBy is null)
        {
            groupResults = Array.Empty<GroupResult>();
        }
        else
        {
            groupResults = await query.CreateGroupResultsFromAppliedCriteria(filteredAndOrderedResult, criteria.GroupBy, cancellationToken);
        }

        var aggregates = await query.CreateAggregatesFromAppliedCriteria(criteria?.Aggregates?.ToArray(), cancellationToken);

        var result = new Result<TEntity>
        {
            Items = filteredAndOrderedResult,
            GroupResults = groupResults.ToImmutableArray(),
            Aggregates = aggregates.ToImmutableArray(),
        };

        return result;
    }

    public static async Task<IEnumerable<AggregateResult>> CreateAggregatesFromAppliedCriteria<T>(this IQueryable<T> rawQuery, AggregateCriteria[]? criteria, CancellationToken cancellationToken = default)
    {
        if (criteria == null || !criteria.Any())
        {
            return Enumerable.Empty<AggregateResult>();
        }

        StringBuilder sb = new("new {");
        for (int i = 0; i < criteria!.Length; i++)
        {
            AggregateCriteria aggregateCriteria = criteria[i];
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

        object[] array = await (from g in rawQuery
                                group g by true).Select(sb.ToString()).ToDynamicArrayAsync(cancellationToken);
        List<AggregateResult> list = new List<AggregateResult>();
        for (int j = 0; j < criteria!.Length; j++)
        {
            AggregateCriteria aggregateCriteria2 = criteria[j];
            object? value = array.GetType().GetProperties()[j].GetValue(array);
            list.Add(new AggregateResult
            {
                Aggregation = aggregateCriteria2.Aggregation,
                FieldName = aggregateCriteria2.FieldName,
                Result = (value == null) ? null : ((value.GetType() == typeof(DateTimeOffset)) ? ((DateTimeOffset)value).ToString("o") : ((value.GetType() == typeof(DateTime)) ? ((DateTime)value).ToString("o") : value.ToString()))
            });
        }

        return list;
    }

    public static async Task<IEnumerable<AggregateResult>> GetAggregates<T>(IQueryable<T> query, IEnumerable<AggregateCriteria> aggregates, CancellationToken cancellationToken)
    {
        return await Task.WhenAll(aggregates.Select(async a =>
        {
            //We must get all of the results and then do the aggregation in memory because
            //certain database providers do not support async versions or error if you try and do 
            //sync aggregates.

            object result;
            if (a.Aggregation == Aggregations.Count)
            {
                //Count doesn't require that the field be a numeric value so has to be handled specially.
                result = (await query.Select(a.FieldName).Distinct().ToDynamicArrayAsync(cancellationToken)).Count();
            }
            else
            {
                var results = (await query.Select(a.FieldName).ToDynamicArrayAsync(cancellationToken)).Cast<Decimal>();
                switch (a.Aggregation)
                {
                    case Aggregations.Sum:
                        result = results.Sum();
                        break;
                    case Aggregations.Average:
                        result = results.Average();
                        break;
                    case Aggregations.Maximum:
                        result = results.Max();
                        break;
                    case Aggregations.Minimum:
                        result = results.Min();
                        break;
                    default:
                        throw new NotImplementedException($"The aggregation type {a.Aggregation} is not implemented.");
                }
            }

            return new AggregateResult
            {
                FieldName = a.FieldName,
                Result = result?.ToString(),
                Aggregation = a.Aggregation,
            };
        }));
    }

    public static async Task<IEnumerable<GroupResult>> CreateGroupResultsFromAppliedCriteria<T>(this IQueryable<T> rawQuery, IQueryable<T> resultQuery, GroupCriteria group, CancellationToken cancellationToken = default)
    {
        var groupValues = resultQuery
                                .GroupBy(group.FieldName)
                                .Select("Key")
                                .Distinct()
                                .Cast<object?>()
                                .ToArray();

        var results = await Task.WhenAll(groupValues.Select(async v =>
        {
            var aggregates = Enumerable.Empty<AggregateResult>();
            var subGroups = Enumerable.Empty<GroupResult>();

            var groupItemQuery = resultQuery.Where($"{group.FieldName} == \"{v}\"");

            return new GroupResult
            {
                FieldName = group.FieldName,
                Value = v?.ToString(),
                Aggregates = group.Aggregates == null ? null : await GetAggregates(groupItemQuery, group.Aggregates, cancellationToken),
                SubGroupResults = group.SubGroup is null ? null : await CreateGroupResultsFromAppliedCriteria(rawQuery, groupItemQuery, group.SubGroup, cancellationToken)
            };
        }));

        return results;
    }

    public static RelationalOperators ToRelationalOperator(this Expression expression, bool isParentNot = false)
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

                    return ((expression as MethodCallExpression)?.Method.Name.ToLower()) switch
                    {
                        "contains" => isParentNot ? RelationalOperators.NotContains : RelationalOperators.Contains,
                        "startswith" => isParentNot ? RelationalOperators.NotStartsWith : RelationalOperators.StartsWith,
                        "endswith" => isParentNot ? RelationalOperators.NotEndsWith : RelationalOperators.EndsWidth,
                        _ => throw new NotSupportedException(),
                    };
                }
            default:
                throw new NotSupportedException();
        }
    }

    public static IQueryable<T> ApplyLoadCriteria<T>(this IQueryable<T> query, LoadCriteria? criteria)
    {
        if (criteria is null)
            return query;

        query = query.ApplyFilterCriteria(criteria.FilterBy);
        if (criteria.GroupBy is not null)
            query = query.ApplyGroupByCriteria(criteria.GroupBy, true);

        if (criteria.OrderBy != null && criteria.OrderBy.Any())
        {
            for (int j = 0; j < criteria.OrderBy.Count(); j++)
            {
                query = query.ApplyOrderByCriteria(criteria.OrderBy.ElementAt(j), j == 0);
            }
        }

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

    public static IQueryable<T> ApplyFilterCriteria<T>(this IQueryable<T> query, IEnumerable<FilterCriteria>? filterCriteria)
    {
        if (filterCriteria == null || !filterCriteria.Any())
        {
            return query;
        }

        var param = Expression.Parameter(typeof(T), "p");
        List<(LogicalOperators, Expression)> list = new();
        foreach (FilterCriteria item in filterCriteria!)
        {
            list.Add((item.Op, CreateFilterExpression<T>(item, param)));
        }

        query = query.ApplyFilterPredicates(list, param);
        return query;
    }

    public static IQueryable<T> ApplyGroupByCriteria<T>(this IQueryable<T> query, GroupCriteria groupBy, bool isFirst)
    {
        if (groupBy.Direction == OrderDirections.NotSet)
            return query;

        var flag = groupBy.Direction == OrderDirections.Descending;
        var parameterExpression = Expression.Parameter(typeof(T), "p");
        var methodName = (!isFirst) ? (flag ? "ThenByDescending" : "ThenBy") : (flag ? "OrderByDescending" : "OrderBy");
        var propertyFromFieldName = GetPropertyFromFieldName<T>(groupBy.FieldName, parameterExpression);
        var expression = Expression.Lambda(propertyFromFieldName, parameterExpression);
        var expression2 = Expression.Call(typeof(Queryable), methodName, new Type[2]
        {
                typeof(T),
                propertyFromFieldName.Type
        }, query.Expression, Expression.Quote(expression));
        query = query.Provider.CreateQuery<T>(expression2);
        return query;
    }

    public static IQueryable<T> ApplyOrderByCriteria<T>(this IQueryable<T> query, OrderCriteria orderBy, bool isFirst)
    {
        if (orderBy.Direction == OrderDirections.NotSet)
        {
            return query;
        }

        var flag = orderBy.Direction == OrderDirections.Descending;
        var parameterExpression = Expression.Parameter(typeof(T), "p");
        var methodName = (!isFirst) ? (flag ? "ThenByDescending" : "ThenBy") : (flag ? "OrderByDescending" : "OrderBy");
        var propertyFromFieldName = GetPropertyFromFieldName<T>(orderBy.FieldName, parameterExpression);
        var expression = Expression.Lambda(propertyFromFieldName, parameterExpression);
        var expression2 = Expression.Call(typeof(Queryable), methodName, new Type[2]
        {
                typeof(T),
                propertyFromFieldName.Type
        }, query.Expression, Expression.Quote(expression));
        query = query.Provider.CreateQuery<T>(expression2);
        return query;
    }

    private static IQueryable<T> ApplyFilterPredicates<T>(this IQueryable<T> source, List<(LogicalOperators Op, Expression Value)> predicates, ParameterExpression param)
    {
        if (source == null) throw new ArgumentNullException(nameof(source));
        if (predicates == null) throw new ArgumentNullException(nameof(predicates));

        if (!predicates.Any())
            return source;

        var body = predicates[0].Value;
        foreach (var (Op, Value) in predicates.Skip(1))
        {
            if (Op == LogicalOperators.And)
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
                    expression = Expression.Not(Expression.Call(arrayContains, arrayConstant, property));
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
                var miStartsWith = typeof(string).GetMethod("StartsWith", new Type[] { typeof(string) })!;
                expression = Expression.Call(Expression.MakeMemberAccess(param, field), miStartsWith, values[0]);
                if (criteria.Relation == RelationalOperators.NotStartsWith)
                    expression = Expression.Not(expression);
                break;
            case RelationalOperators.Contains:
            case RelationalOperators.NotContains:
                var miContains = typeof(string).GetMethod("Contains", new Type[] { typeof(string) })!;
                expression = Expression.Call(Expression.MakeMemberAccess(param, field), miContains, values[0]);
                if (criteria.Relation == RelationalOperators.NotContains)
                    expression = Expression.Not(expression);
                break;
            case RelationalOperators.EndsWidth:
            case RelationalOperators.NotEndsWith:
                var miEndsWith = typeof(string).GetMethod("EndsWith", new Type[] { typeof(string) })!;
                expression = Expression.Call(Expression.MakeMemberAccess(param, field), miEndsWith, values[0]);
                if (criteria.Relation == RelationalOperators.NotEndsWith)
                    expression = Expression.Not(expression);
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
        else if (property.Type == typeof(bool) || property.Type == typeof(Nullable<bool>))
        {
            return Expression.Constant(Convert.ToBoolean(value), property.Type);
        }
        else if (property.Type == typeof(int) || property.Type == typeof(Nullable<int>))
        {
            return Expression.Constant(Convert.ToInt32(value), property.Type);
        }
        else if (property.Type == typeof(double) || property.Type == typeof(Nullable<double>))
        {
            return Expression.Constant(Convert.ToDouble(value), property.Type);
        }
        else if (property.Type == typeof(float) || property.Type == typeof(Nullable<float>))
        {
            return Expression.Constant(Convert.ToSingle(value), property.Type);
        }
        else if (property.Type == typeof(decimal) || property.Type == typeof(Nullable<decimal>))
        {
            return Expression.Constant(Convert.ToDecimal(value), property.Type);
        }
        else if (property.Type == typeof(long) || property.Type == typeof(Nullable<long>))
        {
            return Expression.Constant(Convert.ToInt64(value), property.Type);
        }
        else if (property.Type == typeof(DateTimeOffset) || property.Type == typeof(Nullable<DateTimeOffset>))
        {
            DateTimeOffset dt;
            if (Regex.IsMatch(value, @"^\d*$", RegexOptions.IgnoreCase | RegexOptions.Singleline))
            {
                dt = DateTimeOffset.FromUnixTimeMilliseconds(Convert.ToInt64(value));
            }
            else
            {
                dt = DateTimeOffset.Parse(value, CultureInfo.InvariantCulture, DateTimeStyles.AssumeUniversal | DateTimeStyles.RoundtripKind);
            }

            return Expression.Constant(dt, property.Type);
        }
        else if (property.Type == typeof(DateTime) || property.Type == typeof(Nullable<DateTime>))
        {
            DateTime dt;
            if (Regex.IsMatch(value, @"^\d*$", RegexOptions.IgnoreCase | RegexOptions.Singleline))
            {
                dt = DateTimeOffset.FromUnixTimeMilliseconds(Convert.ToInt64(value)).DateTime;
            }
            else
            {
                dt = DateTime.Parse(value, CultureInfo.InvariantCulture, DateTimeStyles.AssumeUniversal | DateTimeStyles.RoundtripKind);
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

    private static MemberExpression GetPropertyFromFieldName<T>(string fieldName, ParameterExpression parameter)
    {
        string[] fields = fieldName.Split('.');
        var propertyInfo = typeof(T)!.GetProperties().FirstOrDefault((PropertyInfo p) => string.Equals(p.Name, fields[0], StringComparison.OrdinalIgnoreCase));
        if (propertyInfo == null)
            throw new InvalidOperationException();

        MemberExpression memberExpression = Expression.Property(parameter, propertyInfo.Name);
        if (fields.Length > 1)
        {
            foreach (string sField in fields.Skip(1))
            {
                propertyInfo = propertyInfo?.PropertyType.GetProperties().FirstOrDefault((PropertyInfo p) => string.Equals(p.Name, sField, StringComparison.OrdinalIgnoreCase));
                if (propertyInfo == null)
                    throw new InvalidOperationException();

                memberExpression = Expression.Property(memberExpression, propertyInfo.Name);
            }

            return memberExpression;
        }

        return memberExpression;
    }
}

