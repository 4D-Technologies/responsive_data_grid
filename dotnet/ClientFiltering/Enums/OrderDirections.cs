namespace ClientFiltering.Enums;

[DataContract]
public enum OrderDirections
{
    [EnumMember]
    NotSet = 0,

    [EnumMember]
    Ascending = 1,

    [EnumMember]
    Descending = 2,
}
