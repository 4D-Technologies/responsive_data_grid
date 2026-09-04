part of '../responsive_data_grid.dart';

extension OrderCriteriaExtensions on List<OrderCriteria> {
  String toOdata() {
    if (isEmpty) return "";
    return map((e) {
      if (e.direction == OrderDirections.descending) {
        return "${e.fieldName} desc";
      } else {
        return e.fieldName;
      }
    }).join(", ");
  }
}

extension FilterCriteriaExtensions on List<FilterCriteria<dynamic>> {
  String toOdata() {
    if (isEmpty) return "";

    final buffer = StringBuffer();
    for (final e in this) {
      if (buffer.isNotEmpty) {
        buffer.write(e.op == Operators.or ? ' OR ' : ' AND ');
      }
      buffer.write(_odataClause(e));
    }
    return buffer.toString();
  }

  String _odataClause(FilterCriteria<dynamic> e) {
    final field = escapeFieldName(e.fieldName);
    final value = e.values.isEmpty ? '' : e.values.first;
    final quoted = "'$value'";

    switch (e.logicalOperator) {
      case Logic.equals:
        return '$field eq $value';
      case Logic.notEqual:
        return '$field ne $value';
      case Logic.greaterThan:
        return '$field gt $value';
      case Logic.greaterThanOrEqualTo:
        return '$field ge $value';
      case Logic.lessThan:
        return '$field lt $value';
      case Logic.lessThanOrEqualTo:
        return '$field le $value';
      case Logic.contains:
        return 'contains($field, $quoted)';
      case Logic.notContains:
        return 'not contains($field, $quoted)';
      case Logic.startsWith:
        return 'startswith($field, $quoted)';
      case Logic.endsWith:
        return 'endswith($field, $quoted)';
      case Logic.notStartsWith:
        return 'not startswith($field, $quoted)';
      case Logic.notEndsWith:
        return 'not endswith($field, $quoted)';
      case Logic.between:
        final last = e.values.length > 1 ? e.values.last : value;
        return '$field ge $value and $field le $last';
    }
  }

  String escapeFieldName(String fieldName) => fieldName.replaceAll("'", "''");
}

extension TimeOfDayExtensions on TimeOfDay {
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}

/// Safe color/text lookups so Material 3 themes without `ButtonTheme.colorScheme`
/// or empty `primaryTextTheme` do not crash grid chrome.
extension GridThemeFallbacks on ThemeData {
  Color get gridPrimaryColor =>
      buttonTheme.colorScheme?.primary ?? colorScheme.primary;

  Color get gridSurfaceColor =>
      buttonTheme.colorScheme?.surface ?? colorScheme.surface;

  TextStyle get gridTitleSmall =>
      dataTableTheme.headingTextStyle ??
      textTheme.titleSmall ??
      primaryTextTheme.titleSmall ??
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);

  TextStyle get gridBodyMedium =>
      dataTableTheme.dataTextStyle ??
      textTheme.bodyMedium ??
      primaryTextTheme.bodyMedium ??
      const TextStyle(fontSize: 14);

  TextStyle? get gridLabelLarge =>
      textTheme.labelLarge ?? primaryTextTheme.labelLarge;
}
