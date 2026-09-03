part of '../client_filtering.dart';

mixin IJsonable {
  String toJsonString() => jsonEncode(toJson());
  Map<String, dynamic> toJson();
}
