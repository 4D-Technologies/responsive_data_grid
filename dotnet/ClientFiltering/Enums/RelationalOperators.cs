namespace ClientFiltering.Enums;

[DataContract]
public enum RelationalOperators
{
    [EnumMember]
    Equals = 1,

    [EnumMember]
    LessThan = 2,

    [EnumMember]
    GreaterThan = 3,

    [EnumMember]
    LessThanOrEqualTo = 4,

    [EnumMember]
    GreaterThanOrEqualTo = 5,

    [EnumMember]
    Contains = 6,

    [EnumMember]
    NotContains = 7,

    [EnumMember]
    EndsWidth = 8,

    [EnumMember]
    StartsWith = 9,

    [EnumMember]
    NotEqual = 10,

    [EnumMember]
    NotStartsWith = 11,

    [EnumMember]
    NotEndsWith = 12,
}
