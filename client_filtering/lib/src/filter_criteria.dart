part of client_filtering;

class FilterCriteria<TValue extends dynamic> with IJsonable {
  final String fieldName;
  final Operators op;
  final Logic logicalOperator;
  final List<TValue> values;

  const FilterCriteria({
    required this.fieldName,
    required this.op,
    required this.values,
    required this.logicalOperator,
  });

  FilterCriteria.value({
    required this.fieldName,
    required this.op,
    required this.logicalOperator,
    required TValue value,
  }) : values = List<TValue>.from(<TValue>[value], growable: true);

  FilterCriteria.between({
    required this.fieldName,
    required this.op,
    required this.logicalOperator,
    required TValue value1,
    required TValue value2,
  }) : values = List<TValue>.from(<TValue>[value1, value2], growable: true);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FilterCriteria &&
        other.fieldName == fieldName &&
        other.op == op &&
        other.logicalOperator == logicalOperator &&
        other.values == values;
  }

  @override
  int get hashCode {
    return fieldName.hashCode ^
        op.hashCode ^
        logicalOperator.hashCode ^
        values.hashCode;
  }

  FilterCriteria<TValue> copyWith({
    String Function()? fieldName,
    Operators Function()? op,
    Logic Function()? logicalOperator,
    List<TValue> Function()? values,
  }) {
    return FilterCriteria<TValue>(
      fieldName: fieldName == null ? this.fieldName : fieldName(),
      op: op == null ? this.op : op(),
      logicalOperator:
          logicalOperator == null ? this.logicalOperator : logicalOperator(),
      values: values == null ? this.values : values(),
    );
  }

  @override
  String toString() {
    return 'FilterCriteria(fieldName: $fieldName, op: $op, logicalOperator: $logicalOperator, values: ${values.map((e) => _valueToString(e)).join("; ")}))';
  }

  Map<String, dynamic> toJson() {
    // ignore: unnecessary_cast
    return {
      'fieldName': fieldName,
      'op': serializeEnumString(op.toString()),
      'logicalOperator': serializeEnumString(logicalOperator.toString()),
      'values': values.map((e) => _valueToString(e)).toList(),
    } as Map<String, dynamic>;
  }

  static FilterCriteria<TValue> fromJson<TValue extends dynamic>(
      Map<String, dynamic> map) {
    return FilterCriteria(
      fieldName: map['fieldName'].toString(),
      op: Operators.fromInt(map['op'] as int),
      logicalOperator: Logic.fromInt(map['logicalOperator'] as int),
      values: (map['values'] as List<String>)
          .map((e) => _parseValue<TValue>(e))
          .toList(growable: true),
    );
  }

  static TValue _parseValue<TValue extends dynamic>(String value) {
    switch (TValue) {
      case double:
        return double.parse(value) as TValue;
      case DateTime:
        return DateTime.parse(value) as TValue;
      case int:
        return int.parse(value) as TValue;
      case num:
        return num.parse(value) as TValue;
      case String:
        return value as TValue;
      case bool:
        return value == "True" || value == "true" || value == "1"
            ? true as TValue
            : false as TValue;
      default:
        if (TValue == TimeOfDay)
          return TimeOfDay.fromDateTime(DateTime.parse(value)) as TValue;
        throw UnsupportedError(
            "The type ${TValue.toString()} is not supported for deserialization.");
    }
  }

  static String? _valueToString<TValue extends dynamic>(TValue value) {
    switch (TValue) {
      case DateTime:
        return (value as DateTime).toIso8601String();
      case TimeOfDay:
        final tod = (value as TimeOfDay);
        return DateTime(1, 1, 1, tod.hour, tod.minute).toIso8601String();
      default:
        if (value is Enum) return serializeEnumString(value.toString());
        return value.toString();
    }
  }
}
