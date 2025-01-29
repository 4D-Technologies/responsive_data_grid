part of client_filtering;

class AggregateResult {
  final String fieldName;
  final Aggregations aggregation;
  final dynamic result;

  const AggregateResult({
    required this.fieldName,
    required this.aggregation,
    required this.result,
  });

  factory AggregateResult.fromJson(Map<String, dynamic> json) =>
      AggregateResult(
        fieldName: json["fieldName"].toString(),
        aggregation: Aggregations.fromInt(json["aggregation"] as int),
        result: json["result"] == null
            ? null
            : !(json["result"].runtimeType is String)
                ? json["result"]
                : DateTime.tryParse(json["result"]!.toString()) ??
                    json["result"],
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

  String? formatResult(String? format) {
    if (result == null) return "";

    switch (aggregation) {
      case Aggregations.sum:
      case Aggregations.average:
      case Aggregations.maximum:
      case Aggregations.minimum:
        if (result is int || result is BigInt) format ??= "#";

        if (result is num) {
          format ??= "#.0#";
          return intl.NumberFormat(format).format(
            result,
          );
        } else {
          return result.toString();
        }
      case Aggregations.count:
        return result.toString();
    }
  }
}
