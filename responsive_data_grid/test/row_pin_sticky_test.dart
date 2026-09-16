import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;

  const _Person(this.id, this.name);

  @override
  bool operator ==(Object other) => other is _Person && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

List<_Person> _people() => [
  for (var i = 0; i < 20; i++) _Person(i, 'Row$i'),
];

Future<ResponsiveDataGridState<_Person>> _pump(
  WidgetTester tester, {
  GridRowPin Function(_Person item)? rowPin,
  bool Function(_Person item)? isRowSticky,
}) async {
  tester.view.physicalSize = const Size(800, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final key = GlobalKey<ResponsiveDataGridState<_Person>>();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 700,
          child: ResponsiveDataGrid<_Person>.clientSide(
            key: key,
            height: 320,
            pagingMode: PagingMode.pager,
            pageSize: 50,
            layoutMode: GridLayoutMode.table,
            rowPin: rowPin,
            isRowSticky: isRowSticky,
            items: _people(),
            columns: [
              IntColumn<_Person>(
                fieldName: 'id',
                header: const ColumnHeader(text: 'Id'),
                value: (row) => row.id,
                xsCols: 4,
              ),
              StringColumn<_Person>(
                fieldName: 'name',
                header: const ColumnHeader(text: 'Name'),
                value: (row) => row.name,
                xsCols: 8,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return key.currentState!;
}

Finder _verticalScroll() {
  return find.byKey(const ValueKey('rdg-body-scroll'));
}

void main() {
  testWidgets('pinned top row stays visible after scrolling', (tester) async {
    final state = await _pump(tester);
    state.pinRow(const _Person(0, 'Row0'), position: GridRowPin.top);
    await tester.pump();

    await tester.drag(_verticalScroll(), const Offset(0, -240));
    await tester.pumpAndSettle();

    expect(find.text('Row0'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Row0')).dy,
      lessThan(tester.getTopLeft(find.text('Id')).dy + 200),
    );
  });

  testWidgets('pinned bottom row stays visible after scrolling', (
    tester,
  ) async {
    final state = await _pump(tester);
    state.pinRow(const _Person(19, 'Row19'), position: GridRowPin.bottom);
    await tester.pump();

    expect(find.text('Row19'), findsOneWidget);
    final bottomY = tester.getTopLeft(find.text('Row19')).dy;
    expect(bottomY, greaterThan(200));

    await tester.drag(_verticalScroll(), const Offset(0, -240));
    await tester.pumpAndSettle();
    expect(find.text('Row19'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Row19')).dy,
      closeTo(bottomY, 8),
    );
  });

  testWidgets('sticky row stays visible after scrolling past it', (
    tester,
  ) async {
    await _pump(tester, isRowSticky: (item) => item.id == 2);
    expect(find.text('Row2'), findsOneWidget);

    await tester.drag(_verticalScroll(), const Offset(0, -240));
    await tester.pumpAndSettle();

    expect(find.text('Row2'), findsOneWidget);
    expect(find.text('Row0'), findsNothing);
  });

  testWidgets('rowPin selector pins without an API call', (tester) async {
    await _pump(
      tester,
      rowPin: (item) =>
          item.id == 0 ? GridRowPin.top : GridRowPin.none,
    );
    await tester.drag(_verticalScroll(), const Offset(0, -240));
    await tester.pumpAndSettle();
    expect(find.text('Row0'), findsOneWidget);
  });
}
