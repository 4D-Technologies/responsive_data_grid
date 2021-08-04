library client_filtering;

import 'dart:convert';

import 'package:flutter/foundation.dart';

part './src/enums.dart';
part './src/filter_criteria.dart';
part './src/load_criteria.dart';
part './src/order_criteria.dart';
part './src/ijsonable.dart';

String serializeEnumString(String enumString) => enumString.split(".")[1];
T deseralizeEnumString<T>(String enumString, List<T> enumValues) =>
    enumValues.firstWhere((e) => e.toString().endsWith(".$enumString"));
