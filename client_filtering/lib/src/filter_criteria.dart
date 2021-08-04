part of client_filtering;

class FilterCriteria with IJsonable {
  final String fieldName;
  final Logic op;
  final Operators logicalOperator;
  final String? value;

  const FilterCriteria({
    required this.fieldName,
    required this.op,
    required this.value,
    required this.logicalOperator,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FilterCriteria &&
        other.fieldName == fieldName &&
        other.op == op &&
        other.logicalOperator == logicalOperator &&
        other.value == value;
  }

  @override
  int get hashCode {
    return fieldName.hashCode ^
        op.hashCode ^
        logicalOperator.hashCode ^
        value.hashCode;
  }

  FilterCriteria copyWith({
    String? fieldName,
    Logic? op,
    Operators? logicalOperator,
    dynamic value,
  }) {
    return FilterCriteria(
      fieldName: fieldName ?? this.fieldName,
      op: op ?? this.op,
      logicalOperator: logicalOperator ?? this.logicalOperator,
      value: value ?? this.value,
    );
  }

  @override
  String toString() {
    return 'FilterCriteria(fieldName: $fieldName, op: $op, logicalOperator: $logicalOperator, value: $value)';
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'op': serializeEnumString(op.toString()),
      'logicalOperator': serializeEnumString(logicalOperator.toString()),
      'value': value,
    };
  }

  factory FilterCriteria.fromJson(Map<String, dynamic> map) {
    return FilterCriteria(
      fieldName: map['fieldName'],
      op: deseralizeEnumString(map['op'], Logic.values),
      logicalOperator: deseralizeEnumString(
        map['logicalOperator'],
        Operators.values,
      ),
      value: map['value'],
    );
  }
}
