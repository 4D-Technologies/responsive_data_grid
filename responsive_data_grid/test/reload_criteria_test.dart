import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;

  const _Person(this.name);
}

List<GridColumn<_Person, dynamic>> _nameColumns({
  bool showOrderBy = false,
}) {
  return [
    StringColumn<_Person>(
      fieldName: 'name',
      header: ColumnHeader(text: 'Name', showOrderBy: showOrderBy),
      value: (row) => row.name,
      xsCols: 12,
    ),
  ];
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
    'toggling sort reloads with orderBy and keeps paging and groupBy',
    (tester) async {
      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final calls = <LoadCriteria>[];
      const group = GroupCriteria(fieldName: 'name', aggregates: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 600,
              child: ResponsiveDataGrid<_Person>.serverSide(
                height: 600,
                pagingMode: PagingMode.pager,
                pageSize: 25,
                initialLoadCriteria: LoadCriteria(
                  skip: 0,
                  take: 25,
                  groupBy: [group],
                ),
                loadData: (criteria) async {
                  calls.add(criteria);
                  return _response(const [_Person('Ada'), _Person('Grace')]);
                },
                columns: _nameColumns(showOrderBy: true),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(calls, hasLength(1));
      expect(calls.first.take, 25);
      expect(calls.first.skip, 0);
      expect(calls.first.groupBy, isNotNull);
      expect(calls.first.groupBy, isNotEmpty);
      expect(calls.first.orderBy, isEmpty);

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(calls, hasLength(2));
      final afterSort = calls.last;
      expect(afterSort.take, 25);
      expect(afterSort.skip, 0);
      expect(afterSort.groupBy, isNotNull);
      expect(afterSort.groupBy, isNotEmpty);
      expect(afterSort.orderBy, isNotEmpty);
      expect(afterSort.orderBy.first.fieldName, 'name');
      expect(afterSort.orderBy.first.direction, OrderDirections.ascending);
    },
  );

  testWidgets('updateFilterCriteria reloads with the new filters', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final key = GlobalKey<ResponsiveDataGridState<_Person>>();
    final calls = <LoadCriteria>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 600,
            child: ResponsiveDataGrid<_Person>.serverSide(
              key: key,
              height: 600,
              pagingMode: PagingMode.pager,
              pageSize: 25,
              loadData: (criteria) async {
                calls.add(criteria);
                return _response(const [_Person('Ada')]);
              },
              columns: _nameColumns(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(calls, hasLength(1));
    expect(calls.first.filterBy, isEmpty);

    await key.currentState!.updateFilterCriteria([
      const FilterCriteria<String>(
        fieldName: 'name',
        op: Operators.and,
        logicalOperator: Logic.equals,
        values: ['Ada'],
      ),
    ]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(calls, hasLength(2));
    expect(calls.last.filterBy, isNotEmpty);
    expect(calls.last.filterBy.first.fieldName, 'name');
    expect(calls.last.filterBy.first.values, ['Ada']);
    expect(calls.last.take, 25);
  });

  testWidgets('parent item changes reload the visible rows', (tester) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var items = const [_Person('Ada')];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        items = const [_Person('Grace')];
                      });
                    },
                    child: const Text('swap'),
                  ),
                  Expanded(
                    child: ResponsiveDataGrid<_Person>.clientSide(
                      height: 500,
                      pagingMode: PagingMode.pager,
                      items: items,
                      columns: _nameColumns(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Ada'), findsWidgets);
    expect(find.text('Grace'), findsNothing);

    await tester.tap(find.text('swap'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Grace'), findsWidgets);
    expect(find.text('Ada'), findsNothing);
  });

  testWidgets(
    'GridCriteriaChangeNotification from a descendant reloads data',
    (tester) async {
      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final calls = <LoadCriteria>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 600,
              child: ResponsiveDataGrid<_Person>.serverSide(
                height: 600,
                pagingMode: PagingMode.pager,
                loadData: (criteria) async {
                  calls.add(criteria);
                  return _response(const [_Person('Ada')]);
                },
                columns: _nameColumns(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(calls, hasLength(1));

      final descendant = tester.element(
        find.byType(ResponsiveDataGridHeaderRowWidget<_Person>),
      );
      GridCriteriaChangeNotification().dispatch(descendant);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(calls, hasLength(2));
    },
  );
}
