import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

FilterCriteria<dynamic> _filter(
  Logic logic, {
  String field = 'Name',
  List<dynamic> values = const ['Ada'],
}) {
  return FilterCriteria<dynamic>(
    fieldName: field,
    op: Operators.and,
    logicalOperator: logic,
    values: values,
  );
}

String _odata(Logic logic, {String field = 'Name', List<dynamic>? values}) {
  return [_filter(logic, field: field, values: values ?? const ['Ada'])]
      .toOdata();
}

void main() {
  test('toOdata maps notEqual, notStartsWith, and notEndsWith', () {
    expect(_odata(Logic.notEqual), contains('ne'));
    expect(_odata(Logic.notEqual), contains('Name'));

    final notStarts = _odata(Logic.notStartsWith).toLowerCase();
    expect(notStarts, contains('not startswith('));
    expect(notStarts, contains('name'));

    final notEnds = _odata(Logic.notEndsWith).toLowerCase();
    expect(notEnds, contains('not endswith('));
    expect(notEnds, contains('name'));
  });

  test('toOdata emits OData endswith, not endsWidth', () {
    final text = _odata(Logic.endsWith).toLowerCase();
    expect(text, contains('endswith('));
    expect(text, isNot(contains('endswidth')));
  });

  test('toOdata emits OData startswith', () {
    expect(_odata(Logic.startsWith).toLowerCase(), contains('startswith('));
  });

  test('toOdata between includes the field on both comparisons', () {
    final text = _odata(
      Logic.between,
      field: 'Age',
      values: const [1, 10],
    );
    expect(text, contains('Age ge 1'));
    expect(text, contains('Age le 10'));
  });

  test('every Logic value produces OData without throwing', () {
    for (final logic in Logic.values) {
      final values = logic == Logic.between ? <dynamic>[1, 10] : <dynamic>['Ada'];
      expect(
        () => _odata(logic, values: values),
        returnsNormally,
        reason: '$logic should map to OData',
      );
      expect(_odata(logic, values: values), isNotEmpty);
    }
  });
}
