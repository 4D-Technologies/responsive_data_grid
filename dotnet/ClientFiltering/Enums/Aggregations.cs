using System.Runtime.Serialization;

namespace ClientFiltering.Enums;
[DataContract]
public enum Aggregations
{
    [EnumMember]
    Sum = 1,
    [EnumMember]
    Average,
    [EnumMember]
    Maximum,
    [EnumMember]
    Minimum,
    [EnumMember]
    Count
}