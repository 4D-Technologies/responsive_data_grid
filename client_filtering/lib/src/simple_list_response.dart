part of client_filtering;

class SimpleListResponse<T> {
  final int totalCount;
  final List<T> items;

  const SimpleListResponse({
    required this.totalCount,
    required this.items,
  });

  factory SimpleListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) objectMapper,
  ) =>
      SimpleListResponse(
        totalCount: json["TotalCount"] as int,
        items: List<T>.from((json["Items"] as List<Map<String, dynamic>>)
            .map<T>((model) => objectMapper(model))),
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
