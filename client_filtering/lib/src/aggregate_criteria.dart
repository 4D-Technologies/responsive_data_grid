part of client_filtering;

class AggregateCriteria with IJsonable {
  final String fieldName;
  final Aggregations aggregation;

  const AggregateCriteria({
    required this.fieldName,
    required this.aggregation,
  });

  factory AggregateCriteria.fromJson(Map<String, dynamic> json) =>
      AggregateCriteria(
        fieldName: json['fieldName'].toString(),
        aggregation: Aggregations.fromInt(json["aggregation"] as int),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AggregateCriteria &&
        other.fieldName == fieldName &&
        other.aggregation == aggregation;
  }

  @override
  int get hashCode {
    return fieldName.hashCode ^ aggregation.hashCode;
  }

  AggregateCriteria copyWith({
    String Function()? fieldName,
    Aggregations Function()? aggregation,
  }) {
    return AggregateCriteria(
      fieldName: fieldName == null ? this.fieldName : fieldName(),
      aggregation: aggregation == null ? this.aggregation : aggregation(),
    );
  }

  Map<String, dynamic> toJson() {
    // ignore: unnecessary_cast
    return {
      'fieldName': fieldName,
      'aggregation': aggregation.value,
    } as Map<String, dynamic>;
  }
}
