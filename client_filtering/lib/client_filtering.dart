library client_filtering;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part './src/enums.dart';
part './src/filter_criteria.dart';
part './src/load_criteria.dart';
part './src/order_criteria.dart';
part './src/ijsonable.dart';

String serializeEnumString(String enumString) => enumString.split(".")[1];
T deseralizeEnumString<T>(String enumString, List<T> enumValues) =>
    enumValues.firstWhere((e) => e.toString().endsWith(".$enumString"));

class ClientFilteringLocalizedMessages {
  static var between = "Between";
  static var equals = "Equals";
  static var lessThan = "Less Than";
  static var lessThenOrEqualTo = "Less Than Or Equal To";
  static var greaterThan = "Greater Than";
  static var greaterThanOrEqualTo = "Greater Than Or Equal To";
  static var contains = "Contains";
  static var notContains = "Does Not Contain";
  static var startsWith = "Starts With";
  static var endsWith = "Ends With";
  static var notEqual = "Does Not Equal";
  static var notStartsWith = "Does Not Start With";
  static var notEndsWith = "Does Not End With";

  static var notSet = "Not Set";
  static var ascending = "Ascending";
  static var descending = "Descending";

  static var none = "None";
  static var single = "Single";
  static var multiColumn = "Multi-Column";

  static var and = "And";
  static var or = "Or";
}
