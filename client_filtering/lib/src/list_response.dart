part of '../client_filtering.dart';

class ListResponse<T> extends SimpleListResponse<T> {
  final List<GroupResult> groups;
  final List<AggregateResult> aggregates;

  const ListResponse({
    required super.totalCount,
    required super.items,
    required this.groups,
    required this.aggregates,
  });

  factory ListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) objectMapper,
  ) => ListResponse(
    totalCount: json["totalCount"] as int,
    items: List<T>.from(
      (json["items"] as List).map<T>(
        (dynamic model) => objectMapper(model as Map<String, dynamic>),
      ),
    ),
    groups: List<GroupResult>.from(
      (json["groups"] as List).map<GroupResult>(
        (dynamic model) => GroupResult.fromJson(model as Map<String, dynamic>),
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

    //Create Groups from the full filtered set, then page groups (not rows)
    // so a group is not split across pages.
    List<T> pageItems;
    List<GroupResult> groupResults;
    int totalCount;
    if (criteria.groupBy == null || criteria.groupBy!.isEmpty) {
      groupResults = List<GroupResult>.empty();
      if (criteria.skip != null && criteria.take != null) {
        pageItems = items.skip(criteria.skip!).take(criteria.take!).toList();
      } else if (criteria.skip != null) {
        pageItems = items.skip(criteria.skip!).toList();
      } else if (criteria.take != null) {
        pageItems = items.take(criteria.take!).toList();
      } else {
        pageItems = List<T>.from(items);
      }
      totalCount = items.length;
    } else {
      final allGroups = criteria.groupItems(
        criteria: criteria.groupBy!.first,
        items: items,
        allItems: items,
        getFieldValue: getFieldValue,
      );
      totalCount = allGroups.length;
      if (criteria.skip != null && criteria.take != null) {
        groupResults = allGroups
            .skip(criteria.skip!)
            .take(criteria.take!)
            .toList();
      } else if (criteria.skip != null) {
        groupResults = allGroups.skip(criteria.skip!).toList();
      } else if (criteria.take != null) {
        groupResults = allGroups.take(criteria.take!).toList();
      } else {
        groupResults = allGroups;
      }
      final groupValues = groupResults.map((g) => g.value).toSet();
      final groupField = criteria.groupBy!.first.fieldName;
      pageItems = items
          .where(
            (e) => groupValues.contains(
              getFieldValue(groupField, e)?.toString(),
            ),
          )
          .toList();
    }

    //Create overall aggregates
    List<AggregateResult> aggregates;
    if (criteria.aggregates == null || criteria.aggregates!.isEmpty) {
      aggregates = List<AggregateResult>.empty();
    } else {
      aggregates = criteria.aggregates!
          .map(
            (e) => criteria.createAggregation(
              items: items,
              getFieldValue: getFieldValue,
              criteria: e,
            ),
          )
          .toList();
    }

    return ListResponse<T>(
      totalCount: totalCount,
      items: pageItems,
      groups: groupResults,
      aggregates: aggregates,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ListResponse<T> &&
        other.totalCount == totalCount &&
        other.items == items &&
        other.groups == groups &&
        other.aggregates == aggregates;
  }

  @override
  int get hashCode =>
      totalCount.hashCode ^
      items.hashCode ^
      groups.hashCode ^
      aggregates.hashCode;
}
