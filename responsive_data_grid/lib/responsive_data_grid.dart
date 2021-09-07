library responsive_data_grid;

import 'dart:math' as math;
import 'package:client_filtering/client_filtering.dart';
import 'package:bootstrap_grid/bootstrap_grid.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

part './src/filters/column_filter.dart';
part './src/filters/bool.dart';
part './src/filters/datetime.dart';
part './src/filters/double.dart';
part './src/filters/int.dart';
part './src/filters/num.dart';
part './src/filters/string.dart';
part './src/filters/values.dart';
part './src/filters/timeofday.dart';

part './src/rules.dart';
part './src/loadresult.dart';

part './src/rows/row.dart';
part './src/rows/header_row.dart';
part './src/rows/title_row.dart';
//part './src/rows/header.dart';

part './src/grid.dart';
part './src/body.dart';

part './src/field.dart';

part './src/extensions.dart';

part './src/columns/header.dart';
part './src/columns/definition.dart';

class LocalizedMessages {
  static var applicationError = "Application Error";
  static var ok = "OK";
  static var between = "Between";
  static var apply = "Apply";
  static var cancel = "Cancel";
  static var state = "State";
  static var value = "Value";
  static var any = "(Any)";
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    String value = newValue.text;

    if (value.contains(".") &&
        value.substring(value.indexOf(".") + 1).length > decimalRange) {
      truncated = oldValue.text;
      newSelection = oldValue.selection;
    } else if (value == ".") {
      truncated = "0.";

      newSelection = newValue.selection.copyWith(
        baseOffset: math.min(truncated.length, truncated.length + 1),
        extentOffset: math.min(truncated.length, truncated.length + 1),
      );
    }

    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}
