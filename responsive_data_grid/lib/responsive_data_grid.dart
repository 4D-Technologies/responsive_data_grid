library responsive_data_grid;

import 'dart:async';
import 'dart:math' as math;
import 'package:client_filtering/client_filtering.dart';
import 'package:bootstrap_grid/bootstrap_grid.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

part './src/filters/column_filter.dart';
part './src/filters/bool.dart';
part './src/filters/datetime.dart';
part './src/filters/double.dart';
part './src/filters/int.dart';
part './src/filters/num.dart';
part './src/filters/string.dart';
part './src/filters/values.dart';
part './src/filters/timeofday.dart';
part './src/filters/duration.dart';

part './src/rules/filter.dart';

part './src/loadresult.dart';

//part './src/rows/header.dart';

part './src/grid.dart';
part './src/extensions.dart';

part './src/widgets/column_header.dart';
part './src/widgets/body.dart';
part './src/widgets/field.dart';
part './src/widgets/header_row.dart';
part './src/widgets/title_row.dart';
part './src/widgets/row.dart';
part './src/widgets/pager.dart';

part './src/definitions/column.dart';
part './src/definitions/column_header.dart';
part './src/definitions/title.dart';

part './src/definitions/columns/bool.dart';
part './src/definitions/columns/string.dart';
part './src/definitions/columns/enum.dart';
part './src/definitions/columns/datetime.dart';
part './src/definitions/columns/timeofday.dart';
part './src/definitions/columns/duration.dart';
part './src/definitions/columns/int.dart';
part './src/definitions/columns/double.dart';
part './src/definitions/columns/num.dart';

class LocalizedMessages {
  static var applicationError = "Application Error";
  static var ok = "OK";
  static var between = "Between";
  static var apply = "Apply";
  static var cancel = "Cancel";
  static var state = "State";
  static var value = "Value";
  static var any = "(Any)";
  static var doesNotInclude = "Does Not Include";
  static var clear = "Clear";
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

enum PagingMode {
  ///If In a scrollable control, will use a pager, if not, will use infinite scroll.
  auto,

  ///The controll will pull new records using the page size as needed as the user scrolls
  infiniteScroll,

  ///The controll will display up to the page size of records and display the paging control based on the totalCount and page size to navigate between pages of data, requesting the valid page as required
  pager,

  ///All results will always be loaded
  none,
}
