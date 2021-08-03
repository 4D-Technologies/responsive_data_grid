using System.Runtime.Serialization;
using ClientFiltering.Enums;

namespace ClientFiltering.Models
{
    [DataContract]
    public record FilterCriteria
    {
        /// <summary>
        /// The field to operate on
        /// </summary>
        [DataMember]
        public string FieldName { get; init; } = null!;
        /// <summary>
        /// The operator
        /// </summary>
        [DataMember]
        public Operators Op { get; init; } = Operators.And;
        /// <summary>
        /// The logical operator for the function
        /// </summary>
        [DataMember]
        public Logic LogicalOperator { get; init; } = Logic.Equals;
        /// <summary>
        /// The value to use for comparison
        /// </summary>
        [DataMember]
        public string? Value { get; init; }

    }
}