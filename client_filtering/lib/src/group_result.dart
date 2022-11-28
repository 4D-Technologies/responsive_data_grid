part of client_filtering;

class GroupResult {
  final String fieldName;
  final List<GroupValueResult> values;

  const GroupResult({
    required this.fieldName,
    required this.values,
  });

  factory GroupResult.fromJson(Map<String, dynamic> json) {
    return GroupResult(
      fieldName: json['FieldName'].toString(),
      values: (json["Values"] as List<Map<String, dynamic>>)
          .map((Map<String, dynamic> model) => GroupValueResult.fromJson(model))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GroupResult &&
        other.fieldName == fieldName &&
        other.values == values;
  }

  @override
  int get hashCode {
    return fieldName.hashCode ^ values.hashCode;
  }
}
