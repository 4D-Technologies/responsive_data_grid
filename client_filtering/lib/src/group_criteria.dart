part of client_filtering;

class GroupCriteria with IJsonable {
  final String fieldName;
  final OrderDirections direction;
  final List<AggregateCriteria> aggregates;

  const GroupCriteria({
    required this.fieldName,
    this.direction = OrderDirections.ascending,
    required this.aggregates,
  });

  factory GroupCriteria.fromJson(Map<String, dynamic> json) => GroupCriteria(
        fieldName: json['fieldName'].toString(),
        direction: OrderDirections.fromInt(json['directions'] as int),
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
        other.direction == direction &&
        other.aggregates == aggregates;
  }

  @override
  int get hashCode {
    return fieldName.hashCode ^ direction.hashCode ^ aggregates.hashCode;
  }

  GroupCriteria copyWith({
    String Function()? fieldName,
    OrderDirections Function()? directions,
    List<AggregateCriteria> Function()? aggregates,
  }) {
    return GroupCriteria(
      fieldName: fieldName == null ? this.fieldName : fieldName(),
      direction: directions == null ? this.direction : directions(),
      aggregates: aggregates == null ? this.aggregates : aggregates(),
    );
  }

  Map<String, dynamic> toJson() {
    // ignore: unnecessary_cast
    return {
      'fieldName': fieldName,
      'direction': direction.value,
      'aggregates': aggregates.map((x) => x.toJson()).toList(),
    } as Map<String, dynamic>;
  }
}
