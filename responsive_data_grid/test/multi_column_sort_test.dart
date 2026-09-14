import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;
  final int age;

  const _Person(this.name, this.age);
}

List<GridColumn<_Person, dynamic>> _columns({bool showOrderBy = true}) {
  return [
    StringColumn<_Person>(
      fieldName: 'name',
      header: ColumnHeader(text: 'Name', showOrderBy: showOrderBy),
      value: (row) => row.name,
      xsCols: 6,
    ),
    IntColumn<_Person>(
      fieldName: 'age',
      header: ColumnHeader(text: 'Age', showOrderBy: showOrderBy),
      value: (row) => row.age,
      xsCols: 6,
    ),
  ];
}

Future<void> _pump(WidgetTester tester, {required Widget grid}) async {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SizedBox(width: 900, height: 600, child: grid)),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

ListResponse<_Person> _response(List<_Person> items) {
  return ListResponse<_Person>(
    totalCount: items.length,
    items: items,
    groups: const [],
    aggregates: const [],
  );
}

void main() {
  testWidgets(
    'multiColumn preserves click order, not column definition order',
    (tester) async {
      final calls = <LoadCriteria>[];

      await _pump(
        tester,
        grid: ResponsiveDataGrid<_Person>.serverSide(
          height: 500,
          pagingMode: PagingMode.pager,
          sortable: SortableOptions.multiColumn,
          loadData: (criteria) async {
            calls.add(criteria);
            return _response(const [_Person('Ada', 2)]);
          },
          columns: _columns(),
        ),
      );

      expect(calls, hasLength(1));
      expect(calls.first.orderBy, isEmpty);

      await tester.tap(find.byKey(const ValueKey('rdg-header-sort-age')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.byKey(const ValueKey('rdg-header-sort-name')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(calls.length, greaterThanOrEqualTo(3));
      final orderBy = calls.last.orderBy;
      expect(orderBy, hasLength(2));
      expect(orderBy[0].fieldName, 'age');
      expect(orderBy[0].direction, OrderDirections.ascending);
      expect(orderBy[1].fieldName, 'name');
      expect(orderBy[1].direction, OrderDirections.ascending);
    },
  );

  testWidgets('single mode replaces the previous sort', (tester) async {
    final calls = <LoadCriteria>[];

    await _pump(
      tester,
      grid: ResponsiveDataGrid<_Person>.serverSide(
        height: 500,
        pagingMode: PagingMode.pager,
        sortable: SortableOptions.single,
        loadData: (criteria) async {
          calls.add(criteria);
          return _response(const [_Person('Ada', 2)]);
        },
        columns: _columns(),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('rdg-header-sort-age')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byKey(const ValueKey('rdg-header-sort-name')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(calls.last.orderBy, hasLength(1));
    expect(calls.last.orderBy.single.fieldName, 'name');
  });

  testWidgets('unsetting the first of two sorts leaves the other first', (
    tester,
  ) async {
    final calls = <LoadCriteria>[];

    await _pump(
      tester,
      grid: ResponsiveDataGrid<_Person>.serverSide(
        height: 500,
        pagingMode: PagingMode.pager,
        sortable: SortableOptions.multiColumn,
        loadData: (criteria) async {
          calls.add(criteria);
          return _response(const [_Person('Ada', 2)]);
        },
        columns: _columns(),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('rdg-header-sort-age')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const ValueKey('rdg-header-sort-name')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    // age: asc -> desc
    await tester.tap(find.byKey(const ValueKey('rdg-header-sort-age')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    // age: desc -> unset
    await tester.tap(find.byKey(const ValueKey('rdg-header-sort-age')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(calls.last.orderBy, hasLength(1));
    expect(calls.last.orderBy.single.fieldName, 'name');
  });

  testWidgets('client-side rows follow thenBy click order', (tester) async {
    await _pump(
      tester,
      grid: ResponsiveDataGrid<_Person>.clientSide(
        items: const [_Person('Ada', 2), _Person('Bob', 1), _Person('Ada', 1)],
        height: 500,
        pagingMode: PagingMode.pager,
        sortable: SortableOptions.multiColumn,
        columns: _columns(),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('rdg-header-sort-name')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const ValueKey('rdg-header-sort-age')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final ages = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(DataGridRowWidget<_Person>),
            matching: find.byType(Text),
          ),
        )
        .map((t) => t.data)
        .whereType<String>()
        .toList();
    // Rows are Name, Age. Order should be Ada/1, Ada/2, Bob/1.
    expect(ages, ['Ada', '1', 'Ada', '2', 'Bob', '1']);
  });

  testWidgets('sort index appears only when two or more columns are sorted', (
    tester,
  ) async {
    await _pump(
      tester,
      grid: ResponsiveDataGrid<_Person>.clientSide(
        items: const [_Person('Ada', 2), _Person('Bob', 1)],
        height: 500,
        pagingMode: PagingMode.pager,
        sortable: SortableOptions.multiColumn,
        columns: _columns(),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('rdg-header-sort-age')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.byKey(const ValueKey('rdg-header-sort-index-age')),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('rdg-header-sort-name')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.byKey(const ValueKey('rdg-header-sort-index-age')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('rdg-header-sort-index-name')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('rdg-header-sort-index-age')))
          .data,
      '1',
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('rdg-header-sort-index-name')),
          )
          .data,
      '2',
    );
  });

  testWidgets('initialLoadCriteria.orderBy is sent on first load', (
    tester,
  ) async {
    final calls = <LoadCriteria>[];

    await _pump(
      tester,
      grid: ResponsiveDataGrid<_Person>.serverSide(
        height: 500,
        pagingMode: PagingMode.pager,
        sortable: SortableOptions.multiColumn,
        initialLoadCriteria: LoadCriteria(
          orderBy: const [
            OrderCriteria(
              fieldName: 'age',
              direction: OrderDirections.descending,
            ),
            OrderCriteria(
              fieldName: 'name',
              direction: OrderDirections.ascending,
            ),
          ],
        ),
        loadData: (criteria) async {
          calls.add(criteria);
          return _response(const [_Person('Ada', 2)]);
        },
        columns: _columns(),
      ),
    );

    expect(calls, hasLength(1));
    expect(calls.first.orderBy, hasLength(2));
    expect(calls.first.orderBy[0].fieldName, 'age');
    expect(calls.first.orderBy[0].direction, OrderDirections.descending);
    expect(calls.first.orderBy[1].fieldName, 'name');
    expect(calls.first.orderBy[1].direction, OrderDirections.ascending);
  });

  testWidgets(
    'replacing initialLoadCriteria.orderBy drops stale column sorts',
    (tester) async {
      final calls = <LoadCriteria>[];
      final columns = _columns();
      var orderBy = const [
        OrderCriteria(fieldName: 'name', direction: OrderDirections.ascending),
      ];

      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 600,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            orderBy = const [
                              OrderCriteria(
                                fieldName: 'age',
                                direction: OrderDirections.ascending,
                              ),
                            ];
                          });
                        },
                        child: const Text('switch-sort'),
                      ),
                      Expanded(
                        child: ResponsiveDataGrid<_Person>.serverSide(
                          height: 500,
                          pagingMode: PagingMode.pager,
                          sortable: SortableOptions.multiColumn,
                          initialLoadCriteria: LoadCriteria(orderBy: orderBy),
                          loadData: (criteria) async {
                            calls.add(criteria);
                            return _response(const [_Person('Ada', 2)]);
                          },
                          columns: columns,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(calls, isNotEmpty);
      expect(calls.last.orderBy, hasLength(1));
      expect(calls.last.orderBy.single.fieldName, 'name');

      await tester.tap(find.text('switch-sort'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(calls.last.orderBy, hasLength(1));
      expect(calls.last.orderBy.single.fieldName, 'age');
    },
  );
}
