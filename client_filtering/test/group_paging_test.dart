import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';

class _Person {
  final String dept;
  final String name;

  const _Person(this.dept, this.name);
}

void main() {
  final data = [
    for (final dept in ['A', 'B', 'C', 'D'])
      for (var i = 0; i < 2; i++) _Person(dept, '$dept$i'),
  ];

  LoadCriteria groupedCriteria({required int skip, required int take}) {
    return LoadCriteria(
      skip: skip,
      take: take,
      groupBy: const [
        GroupCriteria(fieldName: 'dept', aggregates: []),
      ],
    );
  }

  test('fromData groups the full filtered set then pages groups', () {
    final result = ListResponse.fromData(
      data: data,
      criteria: groupedCriteria(skip: 0, take: 2),
      getFieldValue: (field, item) => item.dept,
    );

    expect(result.totalCount, 4);
    expect(result.groups.map((g) => g.value), ['A', 'B']);
    expect(result.items.map((e) => e.dept).toSet(), {'A', 'B'});
    expect(result.items, hasLength(4));
  });

  test('fromData page 2 returns the next groups, not leftover rows of group A', () {
    final result = ListResponse.fromData(
      data: data,
      criteria: groupedCriteria(skip: 2, take: 2),
      getFieldValue: (field, item) => item.dept,
    );

    expect(result.totalCount, 4);
    expect(result.groups.map((g) => g.value), ['C', 'D']);
    expect(result.items.map((e) => e.dept).toSet(), {'C', 'D'});
  });
}
