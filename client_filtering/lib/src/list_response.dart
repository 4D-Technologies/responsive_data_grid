part of client_filtering;

class ListResponse<T> extends SimpleListResponse<T> {
  final List<GroupResult> groups;
  final List<AggregateResult> aggregates;

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

  factory ListResponse.fromData({
    required List<T> data,
    required LoadCriteria criteria,
    required dynamic Function(String fieldName, T item) getFieldValue,
  }) {
    var items = criteria.filterItems(data: data, getFieldValue: getFieldValue);
    items = criteria.orderItems(items: items, getFieldValue: getFieldValue);

    final totalCount = items.length;

    //Overall aggregates must be done on the filtered and ordered values that aren't paged.
    List<AggregateResult> aggregates;
    if (criteria.aggregates == null || criteria.aggregates!.isEmpty) {
      aggregates = List<AggregateResult>.empty();
    } else {
      aggregates = criteria.aggregates!
          .map((e) => criteria.createAggregation(
              items: items, getFieldValue: getFieldValue, criteria: e))
          .toList();
    }

    if (criteria.skip != null) items = items.skip(criteria.skip!).toList();
    if (criteria.take != null) items = items.take(criteria.take!).toList();

    //Grouping must be done on the paging of the items so that only the paged items show up in the groups
    List<GroupResult> groupResults;
    if (criteria.groupBy == null || criteria.groupBy!.isEmpty) {
      groupResults = List<GroupResult>.empty();
    } else {
      groupResults = criteria.groupItems(
          criteria: criteria.groupBy!.first,
          items: items,
          getFieldValue: getFieldValue);
    }

    return ListResponse<T>(
      totalCount: totalCount,
      items: items.toList(),
      groups: groupResults,
      aggregates: aggregates,
    );
  }

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
