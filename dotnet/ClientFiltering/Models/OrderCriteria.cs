using System;
using System.Runtime.CompilerServices;
using System.Runtime.Serialization;
using System.Text.Json.Serialization;
using ClientFiltering.Enums;

namespace ClientFiltering.Models
{
    /// <summary>
    /// How Order by shall be executed
    /// </summary>
    [DataContract]
    public record struct OrderCriteria
    {
        /// <summary>
        /// The Field to be ordered
        /// </summary>
        [DataMember]
        public string FieldName { get; init; }
        /// <summary>
        /// The direction to order it
        /// </summary>
        [DataMember]
        [JsonConverter(typeof(JsonStringEnumConverter))]
        public OrderDirections Direction { get; init; }
    }
}