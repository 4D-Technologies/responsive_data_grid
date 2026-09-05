part of '../client_filtering.dart';

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
    fieldName: jsonValue(json, 'fieldName').toString(),
    direction: OrderDirections.fromJson(
      jsonValue(json, 'direction', ['directions']) ?? 1,
    ),
    aggregates: jsonList(jsonValue(json, 'aggregates'))
        .map<AggregateCriteria>(
          (dynamic model) => AggregateCriteria.fromJson(jsonMap(model)),
        )
        .toList(),
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GroupCriteria &&
        other.fieldName == fieldName &&
        other.direction == direction &&
        listEquals(other.aggregates, aggregates);
  }

  @override
  int get hashCode {
    return Object.hash(fieldName, direction, Object.hashAll(aggregates));
  }

  GroupCriteria copyWith({
    String Function()? fieldName,
    OrderDirections Function()? directions,
    List<AggregateCriteria> Function()? aggregates,
  }) {
    return GroupCriteria(
      fieldName: fieldName == null ? this.fieldName : fieldName(),
      direction: directions == null ? direction : directions(),
      aggregates: aggregates == null ? this.aggregates : aggregates(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // ignore: unnecessary_cast
    return {
          'fieldName': fieldName,
          'direction': direction.value,
          'aggregates': aggregates.map((x) => x.toJson()).toList(),
        }
        as Map<String, dynamic>;
  }
}
