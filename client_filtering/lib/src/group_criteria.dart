part of client_filtering;

class GroupCriteria with IJsonable {
  final String fieldName;
  final OrderDirections directions;
  final List<AggregateCriteria> aggregates;

  const GroupCriteria({
    required this.fieldName,
    required this.directions,
    required this.aggregates,
  });

  factory GroupCriteria.fromJson(Map<String, dynamic> json) => GroupCriteria(
        fieldName: json['fieldName'].toString(),
        directions: OrderDirections.fromInt(json['directions'] as int),
        aggregates: (json["aggregates"] as List)
            .map<AggregateCriteria>((dynamic model) =>
                AggregateCriteria.fromJson(model as Map<String, dynamic>))
            .toList(),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GroupCriteria &&
        other.fieldName == fieldName &&
        other.directions == directions &&
        other.aggregates == aggregates;
  }

  @override
  int get hashCode {
    return fieldName.hashCode ^ directions.hashCode ^ aggregates.hashCode;
  }

  GroupCriteria copyWith({
    String Function()? fieldName,
    OrderDirections Function()? directions,
    List<AggregateCriteria> Function()? aggregates,
  }) {
    return GroupCriteria(
      fieldName: fieldName == null ? this.fieldName : fieldName(),
      directions: directions == null ? this.directions : directions(),
      aggregates: aggregates == null ? this.aggregates : aggregates(),
    );
  }

  Map<String, dynamic> toJson() {
    // ignore: unnecessary_cast
    return {
      'fieldName': fieldName,
      'directions': directions.value,
      'aggregates': aggregates.map((x) => x.toJson()).toList(),
    } as Map<String, dynamic>;
  }
}
