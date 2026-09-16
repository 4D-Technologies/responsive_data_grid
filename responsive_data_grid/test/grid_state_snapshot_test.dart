import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;

  const _Person(this.id, this.name);
}

List<GridColumn<_Person, dynamic>> _columns() => [
  IntColumn<_Person>(
    fieldName: 'id',
    header: const ColumnHeader(text: 'Id', showOrderBy: true),
    value: (row) => row.id,
    xsCols: 4,
  ),
  StringColumn<_Person>(
    fieldName: 'name',
    header: const ColumnHeader(text: 'Name', showFilter: true),
    value: (row) => row.name,
    xsCols: 8,
  ),
];

Future<ResponsiveDataGridState<_Person>> _pump(
  WidgetTester tester, {
  GridStateSnapshot? initialState,
  void Function(GridStateSnapshot)? onStateChanged,
}) async {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final key = GlobalKey<ResponsiveDataGridState<_Person>>();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 900,
          height: 600,
          child: ResponsiveDataGrid<_Person>.clientSide(
            key: key,
            height: 500,
            pagingMode: PagingMode.pager,
            pageSize: 10,
            initialState: initialState,
            onStateChanged: onStateChanged,
            items: const [_Person(2, 'Zoe'), _Person(1, 'Ada')],
            columns: _columns(),
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
  test('snapshot JSON round-trips column and page fields', () {
    final snapshot = GridStateSnapshot(
      pageNumber: 2,
      pageSize: 25,
      criteria: LoadCriteria(take: 25, skip: 25),
      columns: const [
        GridColumnSnapshot(
          fieldName: 'name',
          visible: false,
          frozen: true,
          sticky: true,
          width: 120,
        ),
      ],
    );
    final restored = GridStateSnapshot.fromJson(snapshot.toJson());
    expect(restored.pageNumber, 2);
    expect(restored.pageSize, 25);
    expect(restored.columns.single.visible, isFalse);
    expect(restored.columns.single.frozen, isTrue);
    expect(restored.columns.single.sticky, isTrue);
    expect(restored.columns.single.width, 120);
  });

  testWidgets('restore hides a column and keeps it hidden', (tester) async {
    final state = await _pump(tester);
    state.setColumnVisible('id', false);
    await tester.pump();
    expect(find.text('Id'), findsNothing);

    final snapshot = state.captureState();
    await _pump(tester, initialState: snapshot);
    expect(find.text('Id'), findsNothing);
    expect(find.text('Name'), findsOneWidget);
  });

  testWidgets('restore reapplies sort', (tester) async {
    final state = await _pump(tester);
    state.setColumnSort(
      state.widget.columns.firstWhere((c) => c.fieldName == 'name'),
      OrderDirections.ascending,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final snapshot = state.captureState();
    await _pump(tester, initialState: snapshot);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final ada = tester.getTopLeft(find.text('Ada').first);
    final zoe = tester.getTopLeft(find.text('Zoe').first);
    expect(ada.dy, lessThan(zoe.dy));
  });
}
