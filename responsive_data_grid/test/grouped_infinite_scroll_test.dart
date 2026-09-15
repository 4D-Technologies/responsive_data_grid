import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;
  final int age;

  const _Person(this.name, this.age);
}

Future<void> _pump(
  WidgetTester tester, {
  required PagingMode pagingMode,
  bool grouping = true,
  int pageSize = 20,
}) async {
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
            height: 500,
            pagingMode: pagingMode,
            pageSize: pageSize,
            allowGrouping: true,
            groupPanel: GroupPanelDisplay.always,
            initialLoadCriteria: grouping
                ? LoadCriteria(
                    groupBy: [
                      GroupCriteria(
                        fieldName: 'name',
                        direction: OrderDirections.ascending,
                        aggregates: const [],
                      ),
                    ],
                  )
                : null,
            items: const [
              _Person('Ada', 36),
              _Person('Ada', 40),
              _Person('Grace', 42),
              _Person('Alan', 50),
            ],
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
  await tester.pump(const Duration(milliseconds: 80));
}

void main() {
  testWidgets('grouped pager still shows group chrome', (tester) async {
    await _pump(tester, pagingMode: PagingMode.pager);
    expect(find.byType(GridGroupHeader), findsWidgets);
    expect(find.text('Ada'), findsWidgets);
    expect(find.text('36'), findsOneWidget);
  });

  testWidgets('grouped infinite scroll shows group headers and footers', (
    tester,
  ) async {
    await _pump(tester, pagingMode: PagingMode.infiniteScroll);
    expect(find.byType(GridGroupHeader), findsWidgets);
    expect(find.byType(GridGroupFooter<_Person>), findsWidgets);
    expect(find.text('Ada'), findsWidgets);
    expect(find.text('36'), findsOneWidget);
    expect(find.text('Grace'), findsWidgets);
  });

  testWidgets('ungrouped infinite scroll still renders flat rows', (
    tester,
  ) async {
    await _pump(tester, pagingMode: PagingMode.infiniteScroll, grouping: false);
    expect(find.byType(GridGroupHeader), findsNothing);
    expect(find.text('Ada'), findsWidgets);
    expect(find.text('Grace'), findsOneWidget);
  });
}
