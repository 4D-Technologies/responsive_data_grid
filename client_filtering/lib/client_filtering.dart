library client_filtering;

import 'dart:convert';

import 'package:darq/darq.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

part './src/enums.dart';
part './src/filter_criteria.dart';
part './src/load_criteria.dart';
part './src/order_criteria.dart';
part './src/ijsonable.dart';
part './src/group_criteria.dart';
part './src//group_result.dart';
part './src/aggregate_criteria.dart';
part './src/aggregate_result.dart';

part './src/simple_list_response.dart';
part './src/list_response.dart';

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

  static var sum = "Sum";
  static var average = "Average";
  static var maximum = "Maximum";
  static var minimum = "Minimum";
  static var count = "Count";
}
