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
  String toString() => '$id';
}

Future<ResponsiveDataGridState<_Person>> _pump(
  WidgetTester tester, {
  GridDetailExpandMode expandMode = GridDetailExpandMode.multiple,
  bool Function(_Person item)? isRowExpandable,
  PagingMode pagingMode = PagingMode.pager,
  Set<_Person>? expandedItems,
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
            height: 500,
            pagingMode: pagingMode,
            layoutMode: GridLayoutMode.table,
            detailExpandMode: expandMode,
            isRowExpandable: isRowExpandable,
            expandedItems: expandedItems,
            detailBuilder: (context, item) => Text('Detail ${item.name}'),
            items: const [
              _Person(1, 'Ada'),
              _Person(2, 'Grace'),
              _Person(3, 'Alan'),
            ],
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

void main() {
  testWidgets('expanding a row shows its detail template', (tester) async {
    await _pump(tester);
    expect(find.text('Detail Ada'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('rdg-detail-toggle-1')));
    await tester.pumpAndSettle();

    expect(find.text('Detail Ada'), findsOneWidget);
    expect(find.text('Id'), findsOneWidget);
  });

  testWidgets('single expand mode collapses the previous row', (tester) async {
    await _pump(tester, expandMode: GridDetailExpandMode.single);

    await tester.tap(find.byKey(const ValueKey('rdg-detail-toggle-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('rdg-detail-toggle-2')));
    await tester.pumpAndSettle();

    expect(find.text('Detail Ada'), findsNothing);
    expect(find.text('Detail Grace'), findsOneWidget);
  });

  testWidgets('isRowExpandable hides the toggle', (tester) async {
    await _pump(tester, isRowExpandable: (item) => item.id == 1);
    expect(find.byKey(const ValueKey('rdg-detail-toggle-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-detail-toggle-2')), findsNothing);
  });

  testWidgets('expand toggle exposes a tooltip for keyboard users', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.byTooltip('Expand row'), findsWidgets);
    await tester.tap(find.byTooltip('Expand row').first);
    await tester.pumpAndSettle();
    expect(find.text('Detail Ada'), findsOneWidget);
    expect(find.byTooltip('Collapse row'), findsWidgets);
  });

  testWidgets('multiple expand mode keeps both rows open', (tester) async {
    await _pump(tester);
    await tester.tap(find.byKey(const ValueKey('rdg-detail-toggle-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('rdg-detail-toggle-2')));
    await tester.pumpAndSettle();
    expect(find.text('Detail Ada'), findsOneWidget);
    expect(find.text('Detail Grace'), findsOneWidget);
  });

  testWidgets('expanding a row does not move the Id header', (tester) async {
    await _pump(tester);
    final before = tester.getTopLeft(find.text('Id').first);
    await tester.tap(find.byKey(const ValueKey('rdg-detail-toggle-1')));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Id').first).dx, closeTo(before.dx, 1));
  });

  testWidgets('detail works in infinite scroll', (tester) async {
    await _pump(tester, pagingMode: PagingMode.infiniteScroll);
    await tester.tap(find.byKey(const ValueKey('rdg-detail-toggle-1')));
    await tester.pumpAndSettle();
    expect(find.text('Detail Ada'), findsOneWidget);
  });
}
