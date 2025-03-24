namespace ClientFiltering.Models;

using ClientFiltering.Extensions;

/// <summary>
/// Load Crtieria for api calls that return lists
/// </summary>
[DataContract]
public record LoadCriteria
{
    /// <summary>
    /// How far to skip into the records? (for paging)
    /// </summary>
    [DataMember]
    public int? Skip { get; init; }

    /// <summary>
    /// How many records to take (for paging)
    /// </summary>
    [DataMember]
    public int? Take { get; init; }

    /// <summary>
    /// Any filter criteria to apply to the results
    /// </summary>
    [DataMember]
    public IEnumerable<FilterCriteria>? FilterBy { get; init; }

    /// <summary>
    /// Any ordering criteria to apply to the results
    /// </summary>
    [DataMember]
    public IEnumerable<OrderCriteria>? OrderBy { get; init; }

    /// <summary>
    /// Any Groups requested
    /// </summary>
    /// <value></value>
    [DataMember]
    public GroupCriteria? GroupBy { get; init; }

    /// <summary>
    /// Any Aggregate results
    /// </summary>
    /// <value></value>
    [DataMember]
    public IEnumerable<AggregateCriteria>? Aggregates { get; init; }

    public static LoadCriteria FromExpressions<TSource>(
        Expression<Func<TSource, bool>>? filterBy = null,
        int? skip = null,
        int? take = null,
        IEnumerable<OrderCriteria>? orderBy = null,
        GroupCriteria? groupBy = null,
        IEnumerable<AggregateCriteria>? aggregateBy = null
    )
    {
        var filters = new List<FilterCriteria>();

        if (filterBy != null)
            ParseFilter(filterBy, ref filters);

        return new LoadCriteria
        {
            FilterBy = [.. filters],
            OrderBy = orderBy?.ToImmutableArray(),
            Skip = skip,
            Take = take,
            GroupBy = groupBy,
            Aggregates = aggregateBy?.ToImmutableArray(),
        };
    }

    private static void ParseFilter(
        Expression filterBy,
        ref List<FilterCriteria> filters,
        LogicalOperators op = LogicalOperators.And
    )
    {
        if (filterBy is LambdaExpression expression)
        {
            ParseFilter(expression.Body, ref filters, op);
            return;
        }

        if (filterBy is BinaryExpression be)
        {
            if (be.NodeType is ExpressionType.AndAlso or ExpressionType.And)
            {
                ParseFilter(be.Left, ref filters, LogicalOperators.And);
                ParseFilter(be.Right, ref filters, LogicalOperators.And);
                return;
            }
            else if (be.NodeType is ExpressionType.OrElse or ExpressionType.Or)
            {
                ParseFilter(be.Left, ref filters, LogicalOperators.Or);
                ParseFilter(be.Right, ref filters, LogicalOperators.Or);
                return;
            }

            var left = (be.Left as MemberExpression)!;

            object? value = null;
            if (be.Right is ConstantExpression ce)
            {
                value = ce.Value;
            }
            else if (be.Right is MemberExpression me)
            {
                value = Expression.Lambda(me).Compile().DynamicInvoke();
            }

            var logic = be.ToRelationalOperator();

            filters.Add(
                new FilterCriteria
                {
                    FieldName = left.Member.Name,
                    Relation = logic,
                    Values = [GetValue(value)],
                    Op = op,
                }
            );

            return;
        }

        var isParentNot = false;
        if (filterBy.NodeType == ExpressionType.Not)
        {
            filterBy = ((UnaryExpression)filterBy).Operand;
            isParentNot = true;
        }

        if (filterBy is MethodCallExpression mce)
        {
            var logic = mce.ToRelationalOperator(isParentNot);

            switch (mce.Method.Name.ToLower(CultureInfo.InvariantCulture))
            {
                case "endswith":
                case "startswith":
                    var value = ((ConstantExpression)mce.Arguments.First()).Value;
                    filters.Add(
                        new FilterCriteria
                        {
                            FieldName = ((MemberExpression)mce.Object!).Member.Name,
                            Relation = logic,
                            Op = op,
                            Values = [GetValue(value)],
                        }
                    );
                    break;
                case "contains":
                    var valueExpression = mce.Arguments.FirstOrDefault(a =>
                        a.NodeType == ExpressionType.MemberAccess
                        && a is MemberExpression ce
                        && ce.Expression is ConstantExpression
                    );

                    object? values = null;
                    if (valueExpression != null)
                        values = Expression.Lambda(valueExpression).Compile().DynamicInvoke();

                    filters.Add(
                        new FilterCriteria
                        {
                            FieldName = mce
                                .Arguments.Where(a =>
                                    a.NodeType == ExpressionType.MemberAccess
                                    && a is MemberExpression me
                                    && me.Expression is ParameterExpression
                                )
                                .Cast<MemberExpression>()
                                .First()
                                .Member.Name,
                            Relation = logic,
                            Values =
                                values == null ? ImmutableArray.Create<string?>()
                                : values is IEnumerable<object?> ve
                                    ? ve?.Select(GetValue)?.ToImmutableArray()
                                        ?? ImmutableArray.Create<string?>()
                                : new[] { GetValue(values) }.ToImmutableArray(),
                            Op = op,
                        }
                    );
                    break;
            }
        }
    }

    private static string? GetValue(object? value) =>
        value switch
        {
            null => null,
            DateTimeOffset dt => dt.ToString("o", CultureInfo.InvariantCulture),
            DateTime dt => dt.ToString("o", CultureInfo.InvariantCulture),
            _ => Convert.ToString(value, CultureInfo.InvariantCulture),
        };
}
