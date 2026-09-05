import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  final int id;
  final String name;
  final DateTime? dob;
  final bool accepted;

  const _Row(this.id, this.name, this.dob, this.accepted);
}

dynamic _field(String name, _Row row) {
  switch (name) {
    case 'id':
      return row.id;
    case 'name':
      return row.name;
    case 'dob':
      return row.dob;
    case 'accepted':
      return row.accepted;
    default:
      throw ArgumentError.value(name, 'name');
  }
}

FilterCriteria<T> _filter<T>({
  required String field,
  required Logic logic,
  required List<T> values,
  Operators op = Operators.and,
}) {
  return FilterCriteria<T>(
    fieldName: field,
    op: op,
    logicalOperator: logic,
    values: values,
  );
}

List<_Row> _apply(LoadCriteria criteria, List<_Row> data) {
  return criteria
      .filterItems(data: data, getFieldValue: _field)
      .toList(growable: false);
}

void main() {
  final ada = _Row(1, 'Ada', DateTime.utc(1977, 6, 17), true);
  final grace = _Row(2, 'Grace', DateTime.utc(1985, 1, 2), false);
  final alan = _Row(3, 'Alan', null, true);
  final rows = [ada, grace, alan];

  group('Operators.or', () {
    test('unions two field predicates instead of throwing', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'name', logic: Logic.equals, values: ['Ada']),
          _filter(
            field: 'name',
            logic: Logic.equals,
            values: ['Alan'],
            op: Operators.or,
          ),
        ],
      );

      expect(_apply(criteria, rows).map((r) => r.name), ['Ada', 'Alan']);
    });

    test('joins left-associatively with AND then OR', () {
      // (id == 1 AND name == Ada) OR name == Grace
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'id', logic: Logic.equals, values: [1]),
          _filter(
            field: 'name',
            logic: Logic.equals,
            values: ['Ada'],
            op: Operators.and,
          ),
          _filter(
            field: 'name',
            logic: Logic.equals,
            values: ['Grace'],
            op: Operators.or,
          ),
        ],
      );

      expect(_apply(criteria, rows).map((r) => r.name), ['Ada', 'Grace']);
    });
  });

  group('Logic matrix — strings', () {
    test('equals', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'name', logic: Logic.equals, values: ['Ada']),
        ],
      );
      expect(_apply(criteria, rows), [ada]);
    });

    test('notEqual', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'name', logic: Logic.notEqual, values: ['Ada']),
        ],
      );
      expect(_apply(criteria, rows).map((r) => r.name), ['Grace', 'Alan']);
    });

    test('contains', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'name', logic: Logic.contains, values: ['ra']),
        ],
      );
      expect(_apply(criteria, rows), [grace]);
    });

    test('notContains', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'name', logic: Logic.notContains, values: ['ce']),
        ],
      );
      expect(_apply(criteria, rows).map((r) => r.name), ['Ada', 'Alan']);
    });

    test('startsWith', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'name', logic: Logic.startsWith, values: ['A']),
        ],
      );
      expect(_apply(criteria, rows).map((r) => r.name), ['Ada', 'Alan']);
    });

    test('notStartsWith', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'name', logic: Logic.notStartsWith, values: ['A']),
        ],
      );
      expect(_apply(criteria, rows), [grace]);
    });

    test('endsWith', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'name', logic: Logic.endsWith, values: ['n']),
        ],
      );
      expect(_apply(criteria, rows), [alan]);
    });

    test('notEndsWith', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'name', logic: Logic.notEndsWith, values: ['n']),
        ],
      );
      expect(_apply(criteria, rows).map((r) => r.name), ['Ada', 'Grace']);
    });
  });

  group('Logic matrix — ints', () {
    test('lessThan', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'id', logic: Logic.lessThan, values: [2]),
        ],
      );
      expect(_apply(criteria, rows), [ada]);
    });

    test('lessThanOrEqualTo', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'id', logic: Logic.lessThanOrEqualTo, values: [2]),
        ],
      );
      expect(_apply(criteria, rows).map((r) => r.id), [1, 2]);
    });

    test('greaterThan', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'id', logic: Logic.greaterThan, values: [2]),
        ],
      );
      expect(_apply(criteria, rows), [alan]);
    });

    test('greaterThanOrEqualTo', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'id', logic: Logic.greaterThanOrEqualTo, values: [2]),
        ],
      );
      expect(_apply(criteria, rows).map((r) => r.id), [2, 3]);
    });

    test('between is inclusive', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'id', logic: Logic.between, values: [1, 2]),
        ],
      );
      expect(_apply(criteria, rows).map((r) => r.id), [1, 2]);
    });
  });

  group('Logic matrix — DateTime', () {
    test('between includes endpoints and skips nulls', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(
            field: 'dob',
            logic: Logic.between,
            values: [DateTime.utc(1977, 6, 17), DateTime.utc(1980, 1, 1)],
          ),
        ],
      );
      expect(_apply(criteria, rows), [ada]);
    });

    test('greaterThan compares DateTimes', () {
      final criteria = LoadCriteria(
        filterBy: [
          _filter(
            field: 'dob',
            logic: Logic.greaterThan,
            values: [DateTime.utc(1980, 1, 1)],
          ),
        ],
      );
      expect(_apply(criteria, rows), [grace]);
    });
  });

  group('null handling', () {
    test('string operators drop null field values', () {
      final withNullName = [ada, const _Row(4, '', null, false)];
      final criteria = LoadCriteria(
        filterBy: [
          _filter(field: 'name', logic: Logic.contains, values: ['A']),
        ],
      );
      expect(_apply(criteria, withNullName), [ada]);
    });
  });
}
