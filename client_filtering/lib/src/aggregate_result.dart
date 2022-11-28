part of client_filtering;

class AggregateResult {
  final String fieldName;
  final Aggregations aggregation;
  final String? result;

  const AggregateResult({
    required this.fieldName,
    required this.aggregation,
    required this.result,
  });

  factory AggregateResult.fromJson(Map<String, dynamic> json) =>
      AggregateResult(
        fieldName: json["FieldName"].toString(),
        aggregation: Aggregations.fromInt(json["Aggregation"] as int),
        result: json["Result"]?.toString(),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AggregateResult &&
        other.fieldName == fieldName &&
        other.aggregation == aggregation &&
        other.result == result;
  }

  @override
  int get hashCode {
    return fieldName.hashCode ^ aggregation.hashCode ^ result.hashCode;
  }
}
