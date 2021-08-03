using System.Runtime.Serialization;

namespace ClientFiltering.Enums
{
    [DataContract]
    public enum Operators
    {
        [EnumMember]
        And = 1,
        [EnumMember]
        Or = 2,
    }
}