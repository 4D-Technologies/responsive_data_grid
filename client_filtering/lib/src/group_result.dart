part of client_filtering;

class GroupResult {
  final String fieldName;
  final String? value;
  final List<AggregateResult> aggregates;
  final List<GroupResult> subGroups;

  const GroupResult({
    required this.fieldName,
    required this.value,
    required this.aggregates,
    required this.subGroups,
  });

  factory GroupResult.fromJson(Map<String, dynamic> json) {
    return GroupResult(
      fieldName: json['fieldName'].toString(),
      value: json['value']?.toString(),
      aggregates: (json["aggregates"] as List)
          .map<AggregateResult>((dynamic model) =>
              AggregateResult.fromJson(model as Map<String, dynamic>))
          .toList(),
      subGroups: (json["subGroups"] as List)
          .map<GroupResult>((dynamic model) =>
              GroupResult.fromJson(model as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GroupResult &&
        other.fieldName == fieldName &&
        other.value == value &&
        other.aggregates == aggregates &&
        other.subGroups == subGroups;
  }

  @override
  int get hashCode {
    return fieldName.hashCode ^
        value.hashCode ^
        aggregates.hashCode ^
        subGroups.hashCode;
  }
}
