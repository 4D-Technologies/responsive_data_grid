part of client_filtering;

class FilterCriteria with IJsonable {
  final String fieldName;
  final Logic op;
  final Operators logicalOperator;
  final String? value;
  final String? value2;

  const FilterCriteria({
    required this.fieldName,
    required this.op,
    required this.value,
    this.value2,
    required this.logicalOperator,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FilterCriteria &&
        other.fieldName == fieldName &&
        other.op == op &&
        other.logicalOperator == logicalOperator &&
        other.value == value &&
        other.value2 == value2;
  }

  @override
  int get hashCode {
    return fieldName.hashCode ^
        op.hashCode ^
        logicalOperator.hashCode ^
        value.hashCode ^
        value2.hashCode;
  }

  FilterCriteria copyWith({
    String Function()? fieldName,
    Logic Function()? op,
    Operators Function()? logicalOperator,
    String? Function()? value,
    String? Function()? value2,
  }) {
    return FilterCriteria(
      fieldName: fieldName == null ? this.fieldName : fieldName(),
      op: op == null ? this.op : op(),
      logicalOperator:
          logicalOperator == null ? this.logicalOperator : logicalOperator(),
      value: value == null ? this.value : value(),
      value2: value2 == null ? this.value2 : value2(),
    );
  }

  @override
  String toString() {
    return 'FilterCriteria(fieldName: $fieldName, op: $op, logicalOperator: $logicalOperator, value: $value), value2: $value2)';
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'op': serializeEnumString(op.toString()),
      'logicalOperator': serializeEnumString(logicalOperator.toString()),
      'value':
          value is DateTime ? (value as DateTime).toIso8601String() : value,
      'value2':
          value2 is DateTime ? (value2 as DateTime).toIso8601String() : value2,
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
      value2: map['value2'],
    );
  }
}
