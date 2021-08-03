part of client_filtering;

class OrderCriteria {
  final String fieldName;
  final OrderDirections direction;

  const OrderCriteria(this.fieldName, this.direction);

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
      fieldName ?? this.fieldName,
      direction ?? this.direction,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fieldName': fieldName,
      'direction': direction.toString(),
    };
  }

  factory OrderCriteria.fromMap(Map<String, dynamic> map) {
    return OrderCriteria(
      map['fieldName'],
      OrderDirections.values.firstWhere((v) => v == map['direction']),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderCriteria.fromJson(String source) =>
      OrderCriteria.fromMap(json.decode(source));
}
