using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using System.Runtime.Serialization;

using ClientFiltering.Enums;

namespace ClientFiltering.Models
{
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


        public static LoadCriteria FromExpressions<TSource>(Expression<Func<TSource, bool>>? filterBy = null, int? skip = null, int? take = null, params OrderCriteria[] orderBy)
            where TSource : class
        {
            var filters = new List<FilterCriteria>();

            if (filterBy != null)
                ParseFilter(filterBy, ref filters);


            return new LoadCriteria
            {
                FilterBy = filters,
                OrderBy = orderBy,
                Skip = skip,
                Take = take
            };
        }

        private static void ParseFilter(Expression filterBy, ref List<FilterCriteria> filters, Operators op = Operators.And)
        {


            if (filterBy is LambdaExpression expression)
            {
                ParseFilter(expression.Body, ref filters, op);
                return;
            }

                
            if (filterBy is BinaryExpression be)
            {
                if (be.NodeType == ExpressionType.AndAlso || be.NodeType == ExpressionType.And)
                {
                    ParseFilter(be.Left, ref filters, Operators.And);
                    ParseFilter(be.Right, ref filters, Operators.And);
                    return;
                } 
                else if (be.NodeType == ExpressionType.OrElse || be.NodeType == ExpressionType.Or)
                {
                    ParseFilter(be.Left, ref filters, Operators.Or);
                    ParseFilter(be.Right, ref filters, Operators.Or);
                    return;
                }


                var left = (be.Left as MemberExpression)!;

                object? value = null;
                if (be.Right is ConstantExpression ce)
                {
                    value = ce.Value;
                } else if (be.Right is MemberExpression me)
                {
                    value = Expression.Lambda(me).Compile().DynamicInvoke();
                }

                var logic = be.ToLogic();


                filters.Add(new FilterCriteria
                {
                    FieldName = left.Member.Name,
                    LogicalOperator = logic,
                    Values = new[] { value == null ? null : Convert.ToString(value, System.Globalization.CultureInfo.InvariantCulture) },
                    Op = op
                });

                return;
            }

            bool isParentNot = false;
            if (filterBy.NodeType == ExpressionType.Not)
            {
                filterBy = ((UnaryExpression)filterBy).Operand;
                isParentNot = true;
            }

            if (filterBy is MethodCallExpression mce)
            {                
                var logic = mce.ToLogic(isParentNot);

                switch(mce.Method.Name.ToLower())
                {
                    case "endswith":
                    case "startswith":
                        var value = ((ConstantExpression)mce.Arguments.First()).Value;
                        filters.Add(new FilterCriteria
                        {
                            FieldName = ((MemberExpression) mce.Object!).Member.Name,
                            LogicalOperator = logic,
                            Op = op,
                            Values = new[] { value == null ? null : Convert.ToString(value, System.Globalization.CultureInfo.InvariantCulture) }
                        });
                        break;
                    case "contains":
                        var valueExpression = mce.Arguments.FirstOrDefault(a => a.NodeType == ExpressionType.MemberAccess &&
                                                            a is MemberExpression ce &&
                                                            ce.Expression is ConstantExpression);

                        object? values = null;
                        if (valueExpression != null)
                            values = Expression.Lambda(valueExpression).Compile().DynamicInvoke();

                        filters.Add(new FilterCriteria
                        {
                            FieldName = mce.Arguments.Where(a => a.NodeType == ExpressionType.MemberAccess &&
                                                            a is MemberExpression me &&
                                                            me.Expression is ParameterExpression).Cast<MemberExpression>().First().Member.Name,
                            LogicalOperator = logic,
                            Values = values == null ? Array.Empty<string?>() : values is IEnumerable<object?> ve ? ve?.Select(v => v == null ? null : Convert.ToString(v, System.Globalization.CultureInfo.InvariantCulture)) ?? Array.Empty<string?>() : new[] { values.ToString() },
                            Op = op
                        });
                        break;
                }

            }
            

        }
    }
}