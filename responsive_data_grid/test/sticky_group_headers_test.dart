import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;
  final int id;

  const _Person(this.name, this.id);
}

Future<void> _pump(WidgetTester tester, {required List<_Person> items}) async {
  tester.view.physicalSize = const Size(900, 500);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 900,
          height: 400,
          child: ResponsiveDataGrid<_Person>.clientSide(
            height: 360,
            pagingMode: PagingMode.pager,
            pageSize: 50,
            allowGrouping: true,
            groupPanel: GroupPanelDisplay.hidden,
            initialLoadCriteria: LoadCriteria(
              groupBy: [
                GroupCriteria(
                  fieldName: 'name',
                  direction: OrderDirections.ascending,
                  aggregates: const [],
                ),
              ],
            ),
            items: items,
            columns: [
              StringColumn<_Person>(
                fieldName: 'name',
                header: const ColumnHeader(text: 'Name'),
                value: (row) => row.name,
                xsCols: 6,
              ),
              IntColumn<_Person>(
                fieldName: 'id',
                header: const ColumnHeader(text: 'Id'),
                value: (row) => row.id,
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
}

void main() {
  testWidgets('group header stays visible while its rows scroll', (
    tester,
  ) async {
    await _pump(
      tester,
      items: [for (var i = 0; i < 25; i++) _Person('Ada', i)],
    );

    final header = find.descendant(
      of: find.byType(GridGroupHeader),
      matching: find.text('Ada'),
    );
    expect(header, findsOneWidget);
    final yBefore = tester.getTopLeft(header).dy;

    await tester.drag(find.text('0'), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(header, findsOneWidget);
    expect(tester.getTopLeft(header).dy, closeTo(yBefore, 2));
  });

  testWidgets('next group header replaces the sticky one', (tester) async {
    await _pump(
      tester,
      items: [
        for (var i = 0; i < 20; i++) _Person('Ada', i),
        for (var i = 0; i < 5; i++) _Person('Grace', 100 + i),
      ],
    );

    final scrollable = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.byType(Scrollable),
    );
    await tester.drag(scrollable.first, const Offset(0, -2500));
    await tester.pumpAndSettle();

    final grace = find.descendant(
      of: find.byType(GridGroupHeader),
      matching: find.text('Grace'),
    );
    expect(grace, findsOneWidget);
  });
}
