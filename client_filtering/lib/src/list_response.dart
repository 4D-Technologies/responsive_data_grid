part of client_filtering;

class ListResponse<T> extends SimpleListResponse<T> {
  final Iterable<GroupResult> groups;
  final Iterable<AggregateResult> aggregates;

  const ListResponse({
    required int totalCount,
    required List<T> items,
    required this.groups,
    required this.aggregates,
  }) : super(items: items, totalCount: totalCount);

  factory ListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) objectMapper,
  ) =>
      ListResponse(
        totalCount: json["totalCount"] as int,
        items: List<T>.from(
          (json["items"] as List).map<T>(
            (dynamic model) => objectMapper(model as Map<String, dynamic>),
          ),
        ),
        groups: List<GroupResult>.from(
          (json["groups"] as List).map<GroupResult>(
            (dynamic model) =>
                GroupResult.fromJson(model as Map<String, dynamic>),
          ),
        ),
        aggregates: List<AggregateResult>.from(
          (json["aggregates"] as List).map<AggregateResult>(
            (dynamic model) =>
                AggregateResult.fromJson(model as Map<String, dynamic>),
          ),
        ),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ListResponse<T> &&
        other.totalCount == this.totalCount &&
        other.items == items &&
        other.groups == groups &&
        other.aggregates == aggregates;
  }

  @override
  int get hashCode =>
      this.totalCount.hashCode ^
      this.items.hashCode ^
      this.groups.hashCode ^
      this.aggregates.hashCode;
}
