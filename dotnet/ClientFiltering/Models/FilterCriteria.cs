using System.Runtime.Serialization;
using ClientFiltering.Enums;
using System.Text.Json.Serialization;
using System.Collections.Generic;
using System.Linq;

namespace ClientFiltering.Models
{

    [DataContract]
    public record FilterCriteria
    {
        public FilterCriteria() { }

        /// <summary>
        /// The field to operate on
        /// </summary>
        [DataMember]
        public string FieldName { get; init; } = null!;
        /// <summary>
        /// The operator
        /// </summary>
        [DataMember]
        [JsonConverter(typeof(JsonStringEnumConverter))]
        public Operators Op { get; init; } = Operators.And;
        /// <summary>
        /// The logical operator for the function
        /// </summary>
        [DataMember]
        [JsonConverter(typeof(JsonStringEnumConverter))]
        public Logic LogicalOperator { get; init; } = Logic.Equals;
        /// <summary>
        /// The values to use for comparison
        /// </summary>
        [DataMember]
        public IEnumerable<string?> Values { get; init; } = Enumerable.Empty<string?>();
    }
}