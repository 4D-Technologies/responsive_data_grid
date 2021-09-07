using System.Globalization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using ClientFiltering.Enums;
using ClientFiltering.Models;

namespace ClientFiltering
{
    public static class LoadCriteriaExtensions
    {
        public static IQueryable<T> ApplyLoadCriteria<T>(this IQueryable<T> query, LoadCriteria? criteria)
            where T : class
        {
            if (criteria == null)
                return query;

            if (criteria.FilterBy != null && criteria.FilterBy.Any())
            {
                var predicates = new Dictionary<Operators, Expression<Func<T, bool>>>();
                foreach (var filterBy in criteria.FilterBy)
                    predicates.Add(filterBy.Op, CreateFilterExpression<T>(filterBy));

                query = ApplyFilterPredicates(query, predicates);
            }

            if (criteria.OrderBy != null && criteria.OrderBy.Any())
                for (int pos = 0; pos < criteria.OrderBy.Count(); pos++)
                    query = ApplyOrderByCriteria(query, criteria.OrderBy.ElementAt(pos), pos == 0);

            if (criteria.Skip != null)
                query = query.Skip(criteria.Skip.Value);

            if (criteria.Take != null)
                query = query.Take(criteria.Take.Value);

            return query;
        }

        public static IQueryable<T> ApplyOrderByCriteria<T>(this IQueryable<T> query, OrderCriteria orderBy, bool isFirst)
        {
            if (orderBy.Direction == OrderDirections.NotSet)
                return query;

            var descending = orderBy.Direction == OrderDirections.Descending;

            // Dynamically creates a call like this: query.OrderBy(p =&gt; p.SortColumn)
            var parameter = Expression.Parameter(typeof(T), "p");

            var command = isFirst ? (descending ? "OrderByDescending" : "OrderBy") : (descending ? "ThenByDescending" : "ThenBy");

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

        private static IQueryable<T> ApplyFilterPredicates<T>(this IQueryable<T> source, Dictionary<Operators, Expression<Func<T, bool>>> predicates)
        {
            if (source == null) throw new ArgumentNullException(nameof(source));
            if (predicates == null) throw new ArgumentNullException(nameof(predicates));
            if (predicates.Count == 1) return source.Where(predicates.ElementAt(0).Value); // simple

            var param = Expression.Parameter(typeof(T), "x");
            Expression body = Expression.Invoke(predicates.ElementAt(0).Value, param);
            for (int i = 1; i < predicates.Count; i++)
            {
                var predicate = predicates.ElementAt(i);
                if (predicate.Key == Operators.And)
                {
                    body = Expression.AndAlso(body, Expression.Invoke(predicate.Value, param));
                }
                else
                {
                    body = Expression.OrElse(body, Expression.Invoke(predicate.Value, param));
                }
            }
            var lambda = Expression.Lambda<Func<T, bool>>(body, param);
            return source.Where(lambda);
        }

        private static Expression<Func<T, bool>> CreateFilterExpression<T>(FilterCriteria criteria)
            where T : class
        {
            var param = Expression.Parameter(typeof(T), "p");

            var field = typeof(T).GetProperties().FirstOrDefault(p => string.Compare(p.Name, criteria.FieldName, StringComparison.OrdinalIgnoreCase) == 0);

            if (field == null)
                throw new InvalidOperationException($"The field '{criteria.FieldName}' does not exist in {typeof(T).Name}.");

            var property = Expression.Property(param, field.Name);

            Expression expression;
            var memberAccess = Expression.MakeMemberAccess(param, field);

            var constantValue = GetConstantValue(property, criteria.Value);


            switch (criteria.LogicalOperator)
            {
                case Logic.Equals:
                    expression = Expression.Equal(property, constantValue);
                    break;
                case Logic.NotEqual:
                    expression = Expression.NotEqual(property, constantValue);
                    break;
                case Logic.LessThan:
                    expression = Expression.LessThan(property, constantValue);
                    break;
                case Logic.GreaterThan:
                    expression = Expression.GreaterThan(property, constantValue);
                    break;
                case Logic.LessThanOrEqualTo:
                    expression = Expression.LessThanOrEqual(property, constantValue);
                    break;
                case Logic.GreaterThanOrEqualTo:
                    expression = Expression.LessThan(property, constantValue);
                    break;
                case Logic.StartsWith:
                case Logic.NotStartsWith:
                    var miStartsWith = typeof(string).GetMethod("StartsWith", new Type[] { typeof(string) })!;
                    expression = Expression.Call(memberAccess, miStartsWith, constantValue);
                    if (criteria.LogicalOperator == Logic.NotStartsWith)
                        expression = Expression.Not(expression);
                    break;
                case Logic.Contains:
                case Logic.NotContains:
                    var miContains = typeof(string).GetMethod("Contains", new Type[] { typeof(string) })!;
                    expression = Expression.Call(memberAccess, miContains, constantValue);
                    if (criteria.LogicalOperator == Logic.NotContains)
                        expression = Expression.Not(expression);
                    break;
                case Logic.EndsWidth:
                case Logic.NotEndsWith:
                    var miEndsWith = typeof(string).GetMethod("EndsWith", new Type[] { typeof(string) })!;
                    expression = Expression.Call(memberAccess, miEndsWith, constantValue);
                    if (criteria.LogicalOperator == Logic.NotEndsWith)
                        expression = Expression.Not(expression);
                    break;
                case Logic.Between:
                    var constantValue2 = GetConstantValue(property, criteria.Value2);
                    var expression1 = Expression.LessThanOrEqual(property, constantValue2);
                    var expression2 = Expression.GreaterThanOrEqual(property, constantValue);
                    expression = Expression.AndAlso(expression1, expression2);
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(criteria), "The operator is not known.");
            }

            var exp = Expression.Lambda<Func<T, bool>>(expression, param);

            return exp;
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

}
