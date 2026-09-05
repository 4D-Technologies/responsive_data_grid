import 'dart:convert';

import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Canonical V2 wire format: camelCase, int enums, groupBy as an array,
/// filter relation field named `logicalOperator`.
const canonicalJson = '''
{
  "skip": 10,
  "take": 25,
  "filterBy": [
    {
      "fieldName": "name",
      "op": 1,
      "logicalOperator": 1,
      "values": ["Ada"]
    },
    {
      "fieldName": "id",
      "op": 2,
      "logicalOperator": 10,
      "values": ["2"]
    }
  ],
  "orderBy": [
    {
      "fieldName": "name",
      "direction": 1
    }
  ],
  "groupBy": [
    {
      "fieldName": "name",
      "direction": 2,
      "aggregates": [
        { "fieldName": "id", "aggregation": 5 }
      ]
    },
    {
      "fieldName": "accepted",
      "direction": 1,
      "aggregates": []
    }
  ],
  "aggregates": [
    { "fieldName": "id", "aggregation": 5 }
  ]
}
''';

/// Legacy .NET System.Text.Json shape (PascalCase, string enums, Relation,
/// single nested GroupBy).
const dotnetLegacyJson = '''
{
  "Skip": 10,
  "Take": 25,
  "FilterBy": [
    {
      "FieldName": "name",
      "Op": "And",
      "Relation": "Equals",
      "Values": ["Ada"]
    },
    {
      "FieldName": "id",
      "Op": "Or",
      "Relation": "NotEqual",
      "Values": ["2"]
    }
  ],
  "OrderBy": [
    { "FieldName": "name", "Direction": "Ascending" }
  ],
  "GroupBy": {
    "FieldName": "name",
    "Direction": "Descending",
    "Aggregates": [
      { "FieldName": "id", "Aggregation": "Count" }
    ],
    "SubGroup": {
      "FieldName": "accepted",
      "Direction": "Ascending",
      "Aggregates": []
    }
  },
  "Aggregates": [
    { "FieldName": "id", "Aggregation": "Count" }
  ]
}
''';

void _expectCanonical(LoadCriteria c) {
  expect(c.skip, 10);
  expect(c.take, 25);
  expect(c.filterBy, hasLength(2));
  expect(c.filterBy[0].fieldName, 'name');
  expect(c.filterBy[0].op, Operators.and);
  expect(c.filterBy[0].logicalOperator, Logic.equals);
  expect(c.filterBy[0].values, ['Ada']);
  expect(c.filterBy[1].fieldName, 'id');
  expect(c.filterBy[1].op, Operators.or);
  expect(c.filterBy[1].logicalOperator, Logic.notEqual);
  expect(c.orderBy.single.fieldName, 'name');
  expect(c.orderBy.single.direction, OrderDirections.ascending);
  expect(c.groupBy, hasLength(2));
  expect(c.groupBy![0].fieldName, 'name');
  expect(c.groupBy![0].direction, OrderDirections.descending);
  expect(c.groupBy![0].aggregates.single.aggregation, Aggregations.count);
  expect(c.groupBy![1].fieldName, 'accepted');
  expect(c.aggregates!.single.aggregation, Aggregations.count);
}

void main() {
  test('parses canonical V2 JSON', () {
    final c = LoadCriteria.fromJson(
      jsonDecode(canonicalJson) as Map<String, dynamic>,
    );
    _expectCanonical(c);
  });

  test(
    'parses legacy .NET JSON (PascalCase, string enums, nested GroupBy)',
    () {
      final c = LoadCriteria.fromJson(
        jsonDecode(dotnetLegacyJson) as Map<String, dynamic>,
      );
      _expectCanonical(c);
    },
  );

  test('toJson emits canonical keys and int enums', () {
    final c = LoadCriteria.fromJson(
      jsonDecode(canonicalJson) as Map<String, dynamic>,
    );
    final json = c.toJson();
    expect(
      json.keys,
      containsAll([
        'skip',
        'take',
        'filterBy',
        'orderBy',
        'groupBy',
        'aggregates',
      ]),
    );
    expect(json['filterBy'][0]['logicalOperator'], 1);
    expect(json['filterBy'][0]['op'], 1);
    expect(json['groupBy'], isA<List<dynamic>>());
    expect((json['groupBy'] as List<dynamic>), hasLength(2));
    expect(json['orderBy'][0]['direction'], 1);
    expect(json.containsKey('GroupBy'), isFalse);
  });

  test('round-trips canonical JSON', () {
    final original = LoadCriteria.fromJson(
      jsonDecode(canonicalJson) as Map<String, dynamic>,
    );
    final restored = LoadCriteria.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
    );
    expect(restored, original);
  });

  test('missing filterBy and orderBy default to empty', () {
    final c = LoadCriteria.fromJson({'skip': 0, 'take': 5});
    expect(c.filterBy, isEmpty);
    expect(c.orderBy, isEmpty);
    expect(c.groupBy, isNull);
    expect(c.aggregates, isNull);
  });

  test('Logic.fromJson accepts EndsWidth alias and Between', () {
    expect(Logic.fromJson(8), Logic.endsWith);
    expect(Logic.fromJson('EndsWidth'), Logic.endsWith);
    expect(Logic.fromJson('endsWith'), Logic.endsWith);
    expect(Logic.fromJson(13), Logic.between);
    expect(Logic.fromJson('Between'), Logic.between);
  });
}
