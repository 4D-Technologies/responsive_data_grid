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
        totalCount: json["TotalCount"] as int,
        items: List<T>.from((json["Items"] as List<Map<String, dynamic>>)
            .map<T>((model) => objectMapper(model))),
        groups: List<GroupResult>.from(
            (json["Groups"] as List<Map<String, dynamic>>)
                .map<GroupResult>((model) => GroupResult.fromJson(model))),
        aggregates: List<AggregateResult>.from((json["Aggregates"]
                as List<Map<String, dynamic>>)
            .map<AggregateResult>((model) => AggregateResult.fromJson(model))),
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
