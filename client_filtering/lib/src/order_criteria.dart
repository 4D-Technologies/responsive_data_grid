part of client_filtering;

class OrderCriteria with IJsonable {
  final String fieldName;
  final OrderDirections direction;

  const OrderCriteria({
    required this.fieldName,
    this.direction = OrderDirections.ascending,
  });

  factory OrderCriteria.fromJson(Map<String, dynamic> json) => OrderCriteria(
        fieldName: json['fieldName'].toString(),
        direction: OrderDirections.fromInt(json['direction'] as int),
      );

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
    String Function()? fieldName,
    OrderDirections Function()? direction,
  }) {
    return OrderCriteria(
      fieldName: fieldName == null ? this.fieldName : fieldName(),
      direction: direction == null ? this.direction : direction(),
    );
  }

  Map<String, dynamic> toJson() {
    // ignore: unnecessary_cast
    return {
      'fieldName': fieldName,
      'direction': direction.value,
    } as Map<String, dynamic>;
  }
}
