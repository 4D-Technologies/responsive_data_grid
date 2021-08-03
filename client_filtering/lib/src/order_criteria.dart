part of client_filtering;

class OrderCriteria with IJsonable {
  final String fieldName;
  final OrderDirections direction;

  const OrderCriteria({
    required this.fieldName,
    this.direction = OrderDirections.ascending,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderCriteria &&
        other.fieldName == fieldName &&
        other.direction == direction;
  }

  @override
  int get hashCode => fieldName.hashCode ^ direction.hashCode;

  OrderCriteria copyWith({
    String? fieldName,
    OrderDirections? direction,
  }) {
    return OrderCriteria(
      fieldName: fieldName ?? this.fieldName,
      direction: direction ?? this.direction,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'direction': direction.toString(),
    };
  }

  factory OrderCriteria.fromJson(Map<String, dynamic> map) {
    return OrderCriteria(
      fieldName: map['fieldName'],
      direction: OrderDirections.values.firstWhere(
        (v) => v == map['direction'],
      ),
    );
  }
}
