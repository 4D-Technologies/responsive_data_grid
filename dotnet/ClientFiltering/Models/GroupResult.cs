namespace ClientFiltering.Models;
[DataContract]
public readonly record struct GroupResult
{
    [DataMember]
    public string FieldName { get; init; }

    [DataMember]
    public IEnumerable<GroupValueResult> Values { get; init; }

}
