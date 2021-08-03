using System.Linq;
using System.Collections.Generic;
using System.Runtime.Serialization;

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
        public IEnumerable<FilterCriteria> FilterBy { get; init; } = Enumerable.Empty<FilterCriteria>();
        /// <summary>
        /// Any ordering criteria to apply to the results
        /// </summary>
        [DataMember]
        public IEnumerable<OrderCriteria>? OrderBy { get; init; } = Enumerable.Empty<OrderCriteria>();
    }

}