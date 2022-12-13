using System.Linq.Dynamic.Core;
using System.Reflection;
using System.Text;
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
        if (criteria?.GroupBy == null)
        {
            groupResults = Array.Empty<GroupResult>();
        }
        else
        {
            groupResults = await query.CreateGroupResultsFromAppliedCriteria(filteredAndOrderedResult, criteria.Value.GroupBy.GetEnumerator(), cancellationToken);
        }

        var aggregates = await query.CreateAggregatesFromAppliedCriteria(criteria?.Aggregates?.ToArray(), cancellationToken);

        var result = new Result<TEntity>
        {
            Items = filteredAndOrderedResult,
            Groups = groupResults,
            Aggregates = aggregates,
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

    public static IEnumerable<AggregateResult> GetAggregates<T>(IQueryable<T> query, IEnumerable<AggregateCriteria> aggregates)
    {
        return aggregates.Select(a =>
        {
            object result;
            switch (a.Aggregation)
            {
                case Aggregations.Sum:
                    result = query.Sum(a.FieldName);
                    break;
                case Aggregations.Average:
                    result = query.Average(a.FieldName);
                    break;
                case Aggregations.Count:
                    result = query.Count();
                    break;
                case Aggregations.Maximum:
                    result = query.Max(a.FieldName);
                    break;
                case Aggregations.Minimum:
                    result = query.Min(a.FieldName);
                    break;
                default:
                    throw new NotImplementedException($"The aggregation type {a.Aggregation} is not implemented.");
            }

            return new AggregateResult
            {
                FieldName = a.FieldName,
                Result = result?.ToString(),
                Aggregation = a.Aggregation,
            };
        });
    }

    public static async Task<IEnumerable<GroupResult>> CreateGroupResultsFromAppliedCriteria<T>(this IQueryable<T> rawQuery, IQueryable<T> resultQuery, IEnumerator<GroupCriteria> enumerator, CancellationToken cancellationToken = default)
    {
        var currentGroup = enumerator.Current;

        IEnumerable<string?> groupValues = ((IQueryable<IGrouping<object, T>>)resultQuery
                                                .GroupBy(currentGroup.FieldName))
                                                .Select((IGrouping<object, T> r) => r.Key == null ? null : r.Key.ToString())
                                                .Distinct()
                                                .ToArray();

        return await Task.WhenAll(groupValues.Select(async v =>
        {
            var aggregates = Enumerable.Empty<AggregateResult>();
            var subGroups = Enumerable.Empty<GroupResult>();

            var groupItemQuery = resultQuery.Where($"{currentGroup.FieldName} == \"{v}\"");

            var hasAdditionalGroup = enumerator.MoveNext();

            return new GroupResult
            {
                FieldName = currentGroup.FieldName,
                Value = v,
                Aggregates = GetAggregates(groupItemQuery, currentGroup.Aggregates),
                SubGroups = !hasAdditionalGroup ? Enumerable.Empty<GroupResult>() :
                                await CreateGroupResultsFromAppliedCriteria(rawQuery, groupItemQuery, enumerator, cancellationToken)
            };
        }));
    }

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
                {
                    var binaryExpression = expression as BinaryExpression;
                    if (binaryExpression?.Left.NodeType == ExpressionType.LessThanOrEqual && binaryExpression.Right.NodeType == ExpressionType.GreaterThanOrEqual)
                        return Logic.Between;

                    throw new InvalidOperationException();
                }

            case ExpressionType.Call:
            case ExpressionType.Not:
                {
                    if (expression is UnaryExpression unaryExpression)
                        expression = unaryExpression.Operand;

                    return ((expression as MethodCallExpression)?.Method.Name.ToLower()) switch
                    {
                        "contains" => isParentNot ? Logic.NotContains : Logic.Contains,
                        "startswith" => isParentNot ? Logic.NotStartsWith : Logic.StartsWith,
                        "endswith" => isParentNot ? Logic.NotEndsWith : Logic.EndsWidth,
                        _ => throw new NotSupportedException(),
                    };
                }
            default:
                throw new NotSupportedException();
        }
    }

    public static IQueryable<T> ApplyLoadCriteria<T>(this IQueryable<T> query, LoadCriteria? criteria)
    {
        if (!criteria.HasValue)
        {
            return query;
        }

        query = query.ApplyFilterCriteria(criteria.Value.FilterBy);
        if (criteria.Value.GroupBy != null && criteria.Value.GroupBy.Any())
        {
            for (int i = 0; i < criteria.Value.GroupBy.Count(); i++)
            {
                query = query.ApplyGroupByCriteria(criteria.Value.GroupBy.ElementAt(i), i == 0);
            }
        }

        if (criteria.Value.OrderBy != null && criteria.Value.OrderBy.Any())
        {
            for (int j = 0; j < criteria.Value.OrderBy.Count(); j++)
            {
                query = query.ApplyOrderByCriteria(criteria.Value.OrderBy.ElementAt(j), j == 0);
            }
        }

        if (criteria.Value.Skip.HasValue)
        {
            query = query.Skip(criteria.Value.Skip.Value);
        }

        if (criteria.Value.Take.HasValue)
        {
            query = query.Take(criteria.Value.Take.Value);
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
        List<(Operators, Expression)> list = new();
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
            return Expression.Constant(DateTimeOffset.ParseExact(value, "o", CultureInfo.InvariantCulture, DateTimeStyles.AssumeUniversal | DateTimeStyles.RoundtripKind), property.Type);
        }
        else if (property.Type == typeof(DateTime) || property.Type == typeof(Nullable<DateTime>))
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

