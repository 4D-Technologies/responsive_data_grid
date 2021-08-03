part of client_filtering;

mixin IJsonable {
  String toJsonString() => jsonEncode(toJson());
  Map<String, dynamic> toJson();
}
