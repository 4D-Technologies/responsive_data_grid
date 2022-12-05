part of client_filtering;

class GroupValueResult {
  final String? value;
  final List<AggregateResult> aggregates;

  const GroupValueResult({
    required this.value,
    required this.aggregates,
  });

  factory GroupValueResult.fromJson(Map<String, dynamic> json) {
    return GroupValueResult(
      value: json["value"]?.toString(),
      aggregates: (json["aggregates"] as List)
          .map<AggregateResult>((dynamic model) =>
              AggregateResult.fromJson(model as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GroupValueResult &&
        other.value == value &&
        other.aggregates == aggregates;
  }

  @override
  int get hashCode {
    return value.hashCode ^ aggregates.hashCode;
  }
}
