part of '../client_filtering.dart';

dynamic jsonValue(
  Map<dynamic, dynamic> json,
  String camel, [
  List<String> aliases = const [],
]) {
  bool matches(Object? key, String name) =>
      key is String && key.toLowerCase() == name.toLowerCase();

  for (final name in [camel, ...aliases]) {
    for (final entry in json.entries) {
      if (matches(entry.key, name)) {
        return entry.value;
      }
    }
  }
  return null;
}

List<dynamic> jsonList(dynamic raw) => raw is List ? raw : const <dynamic>[];

Map<String, dynamic> jsonMap(dynamic raw) =>
    Map<String, dynamic>.from(raw as Map);

T parseWireEnum<T extends IEnum>({
  required dynamic value,
  required T Function(num) fromInt,
  required Map<String, T> names,
  required String typeName,
}) {
  if (value == null) {
    throw FormatException('Missing $typeName');
  }
  if (value is num) {
    return fromInt(value);
  }
  if (value is String) {
    final asInt = int.tryParse(value);
    if (asInt != null) {
      return fromInt(asInt);
    }
    final key = value.toLowerCase().replaceAll(RegExp(r'[_\s]'), '');
    final match = names[key];
    if (match != null) {
      return match;
    }
  }
  throw FormatException('Cannot parse $typeName from $value');
}

List<GroupCriteria>? groupByFromJson(dynamic raw) {
  if (raw == null) {
    return null;
  }
  final groups = <GroupCriteria>[];

  void add(dynamic node) {
    if (node == null) {
      return;
    }
    if (node is List) {
      for (final child in node) {
        add(child);
      }
      return;
    }
    if (node is Map) {
      final map = jsonMap(node);
      groups.add(GroupCriteria.fromJson(map));
      add(jsonValue(map, 'subGroup'));
    }
  }

  add(raw);
  return groups;
}
