part of client_filtering;

class SimpleListResponse<T> {
  final int totalCount;
  final List<T> items;

  const SimpleListResponse({
    required this.totalCount,
    required this.items,
  });

  factory SimpleListResponse.fromData({
    required List<T> data,
    required LoadCriteria criteria,
    required dynamic Function(String fieldName, T item) getFieldValue,
  }) {
    var items = criteria.filterItems(data: data, getFieldValue: getFieldValue);
    items = criteria.orderItems(items: items, getFieldValue: getFieldValue);

    final totalCount = items.length;

    if (criteria.skip != null) items = items.skip(criteria.skip!).toList();
    if (criteria.take != null) items = items.take(criteria.take!).toList();

    return SimpleListResponse<T>(
      totalCount: totalCount,
      items: items.toList(),
    );
  }

  factory SimpleListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) objectMapper,
  ) =>
      SimpleListResponse(
        totalCount: json["totalCount"] as int,
        items: List<T>.from(
          (json["items"] as List).map<T>(
            (dynamic model) => objectMapper(model as Map<String, dynamic>),
          ),
        ),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SimpleListResponse<T> &&
        other.totalCount == this.totalCount &&
        other.items == items;
  }

  @override
  int get hashCode => this.totalCount.hashCode ^ this.items.hashCode;
}
