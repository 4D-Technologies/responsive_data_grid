using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace ClientFiltering.Models;
[DataContract]
public record struct GroupResult
{
    [DataMember]
    public string FieldName { get; init; }

    [DataMember]
    public IEnumerable<GroupValueResult> Values { get; init; }

}
