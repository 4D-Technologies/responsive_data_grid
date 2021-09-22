// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';

enum TestEnum {
  test,
  test2,
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Encoding Tests", () {
    test('Verify Encoding of LoadCriteria empty values', () {
      final criteria = LoadCriteria(
        filterBy: [
          FilterCriteria<String>(
              fieldName: "test",
              logicalOperator: Operators.equals,
              op: Logic.and,
              values: []),
        ],
      );

      final map = criteria.toJson();

      final result = json.encode(map);

      expect(result, startsWith("{"));
    });

    test('Verify Encoding of LoadCriteria in 2 values', () {
      final criteria = LoadCriteria(
        filterBy: [
          FilterCriteria<String>(
              fieldName: "test",
              logicalOperator: Operators.equals,
              op: Logic.and,
              values: ["Test", "Testing2"]),
        ],
      );

      final map = criteria.toJson();

      final result = json.encode(map);

      expect(result, startsWith("{"));
    });

    test('Verify Encoding of LoadCriteria of enum values without namespace',
        () {
      final criteria = LoadCriteria(
        filterBy: [
          FilterCriteria<TestEnum>(
              fieldName: "test",
              logicalOperator: Operators.equals,
              op: Logic.and,
              values: [TestEnum.test, TestEnum.test2]),
        ],
      );

      final map = criteria.toJson();

      final result = json.encode(map);

      expect(result, isNot(contains("TestEnum")));
    });
  });
}
