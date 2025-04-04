library responsive_data_grid;

import 'dart:async';
import 'dart:math' as math;
import 'package:bootstrap_grid/bootstrap_grid.dart';
import 'package:client_filtering/client_filtering.dart';
import 'package:darq/darq.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart' as intl;

import 'responsive_data_grid.dart';

part './src/widgets/aligned_dialog.dart';
part './src/response_cache.dart';

part './src/widgets//group_aggregate_chooser.dart';
part './src/widgets/aggregation_chooser.dart';

part 'src/widgets/dropdown_view_widget.dart';
part './src/widgets/column_menu.dart';
part './src/widgets/group_menu.dart';

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
part './src/filters/filter_result.dart';
part './src/filters/no_filter.dart';

part './src/rules/filter.dart';

//part './src/rows/header.dart';

part './src/grid.dart';
part './src/grid_state.dart';
part './src/extensions.dart';

part './src/widgets/column_header.dart';
part './src/widgets/paged_body.dart';
part './src/widgets/infinite_scroll_body.dart';
part './src/widgets/field.dart';
part './src/widgets/header_row.dart';
part './src/widgets/title_row.dart';
part './src/widgets/row.dart';
part './src/widgets/pager.dart';
part './src/widgets/grid_group_chooser.dart';

part './src/widgets/group_header.dart';
part './src/widgets/group_footer.dart';

part './src/widgets/grid_footer.dart';

part './src/widgets/body.dart';

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
part 'src/definitions/columns/widget.dart';

part 'src/notifications/criteriachange.dart';

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
  static var noEntry = "No Entry";
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
