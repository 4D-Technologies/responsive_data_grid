import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;
  final int age;

  const _Person(this.name, this.age);
}

ResponsiveDataGrid<_Person> _grid({
  double? height,
  PagingMode pagingMode = PagingMode.pager,
}) {
  return ResponsiveDataGrid<_Person>.clientSide(
    items: const [
      _Person('Ada', 36),
      _Person('Grace', 41),
    ],
    pageSize: 10,
    pagingMode: pagingMode,
    height: height,
    columns: [
      StringColumn<_Person>(
        fieldName: 'name',
        header: const ColumnHeader(text: 'Name', showOrderBy: true),
        value: (row) => row.name,
        xsCols: 6,
      ),
      IntColumn<_Person>(
        fieldName: 'age',
        header: const ColumnHeader(text: 'Age'),
        value: (row) => row.age,
        xsCols: 6,
      ),
    ],
  );
}

void main() {
  testWidgets(
    'grid inside a parent ListView does not throw unbounded Expanded',
    (tester) async {
      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                _grid(height: null, pagingMode: PagingMode.pager),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('Name'), findsWidgets);
      expect(find.text('Ada'), findsWidgets);
    },
  );

  testWidgets('bounded-height grid still renders rows', (tester) async {
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
            child: _grid(height: 600, pagingMode: PagingMode.pager),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    expect(find.text('Ada'), findsWidgets);
    expect(find.byType(Expanded), findsWidgets);
  });

  testWidgets(
    'bounded-height nested groups do not throw unbounded nested ListViews',
    (tester) async {
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
              child: ResponsiveDataGrid<_Person>.clientSide(
                items: const [
                  _Person('Ada', 36),
                  _Person('Ada', 30),
                  _Person('Grace', 41),
                ],
                pageSize: 10,
                pagingMode: PagingMode.pager,
                height: 600,
                allowGrouping: true,
                initialLoadCriteria: LoadCriteria(
                  groupBy: [
                    GroupCriteria(
                      fieldName: 'name',
                      direction: OrderDirections.ascending,
                      aggregates: const [],
                    ),
                    GroupCriteria(
                      fieldName: 'age',
                      direction: OrderDirections.ascending,
                      aggregates: const [],
                    ),
                  ],
                ),
                columns: [
                  StringColumn<_Person>(
                    fieldName: 'name',
                    header: const ColumnHeader(text: 'Name'),
                    value: (row) => row.name,
                    xsCols: 6,
                  ),
                  IntColumn<_Person>(
                    fieldName: 'age',
                    header: const ColumnHeader(text: 'Age'),
                    value: (row) => row.age,
                    xsCols: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('Ada'), findsWidgets);
      expect(find.text('36'), findsWidgets);
    },
  );
}
