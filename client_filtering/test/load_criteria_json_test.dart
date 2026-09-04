import 'dart:convert';

import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LoadCriteria JSON round-trips groupBy and aggregates', () {
    final original = LoadCriteria(
      skip: 10,
      take: 25,
      orderBy: const [
        OrderCriteria(fieldName: 'name', direction: OrderDirections.ascending),
      ],
      groupBy: [
        const GroupCriteria(
          fieldName: 'name',
          direction: OrderDirections.descending,
          aggregates: [
            AggregateCriteria(fieldName: 'id', aggregation: Aggregations.sum),
          ],
        ),
      ],
      aggregates: const [
        AggregateCriteria(fieldName: 'id', aggregation: Aggregations.count),
      ],
    );

    final restored = LoadCriteria.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
    );

    expect(restored.skip, 10);
    expect(restored.take, 25);
    expect(restored.orderBy.single.fieldName, 'name');
    expect(restored.groupBy, isNotNull);
    expect(restored.groupBy!.single.fieldName, 'name');
    expect(restored.groupBy!.single.direction, OrderDirections.descending);
    expect(
      restored.groupBy!.single.aggregates.single.aggregation,
      Aggregations.sum,
    );
    expect(restored.aggregates, isNotNull);
    expect(restored.aggregates!.single.fieldName, 'id');
    expect(restored.aggregates!.single.aggregation, Aggregations.count);
  });

  test('LoadCriteria equality includes groupBy and aggregates', () {
    const group = GroupCriteria(
      fieldName: 'name',
      aggregates: [
        AggregateCriteria(fieldName: 'id', aggregation: Aggregations.sum),
      ],
    );
    const aggregate = AggregateCriteria(
      fieldName: 'id',
      aggregation: Aggregations.count,
    );

    final left = LoadCriteria(
      skip: 0,
      take: 10,
      groupBy: [group],
      aggregates: [aggregate],
    );
    final same = LoadCriteria(
      skip: 0,
      take: 10,
      groupBy: [
        const GroupCriteria(
          fieldName: 'name',
          aggregates: [
            AggregateCriteria(fieldName: 'id', aggregation: Aggregations.sum),
          ],
        ),
      ],
      aggregates: const [
        AggregateCriteria(fieldName: 'id', aggregation: Aggregations.count),
      ],
    );
    final differentGroup = LoadCriteria(
      skip: 0,
      take: 10,
      groupBy: [
        const GroupCriteria(fieldName: 'other', aggregates: []),
      ],
      aggregates: [aggregate],
    );
    final differentAggregates = LoadCriteria(
      skip: 0,
      take: 10,
      groupBy: [group],
      aggregates: const [
        AggregateCriteria(fieldName: 'id', aggregation: Aggregations.sum),
      ],
    );

    expect(left, same);
    expect(left, isNot(equals(differentGroup)));
    expect(left, isNot(equals(differentAggregates)));
  });
}
