import 'package:client_filtering/client_filtering.dart';
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

Future<void> _pump(
  WidgetTester tester, {
  bool allowRowReorder = true,
  void Function(int from, int to, _Person item)? onRowReorder,
  LoadCriteria? criteria,
}) async {
  tester.view.physicalSize = const Size(800, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 700,
          child: ResponsiveDataGrid<_Person>.clientSide(
            height: 500,
            pagingMode: PagingMode.pager,
            layoutMode: GridLayoutMode.table,
            allowRowReorder: allowRowReorder,
            onRowReorder: onRowReorder,
            initialLoadCriteria: criteria,
            items: const [_Person(1, 'Ada'), _Person(2, 'Grace')],
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
}

void main() {
  testWidgets('reorder handle is omitted when allowRowReorder is false', (
    tester,
  ) async {
    await _pump(tester, allowRowReorder: false);
    expect(find.byKey(const ValueKey('rdg-row-drag-0')), findsNothing);
  });

  testWidgets('dragging a row handle reorders two rows', (tester) async {
    int? from;
    int? to;
    _Person? moved;
    await _pump(
      tester,
      onRowReorder: (f, t, item) {
        from = f;
        to = t;
        moved = item;
      },
    );

    expect(
      tester.getTopLeft(find.text('Ada')).dy,
      lessThan(tester.getTopLeft(find.text('Grace')).dy),
    );

    await tester.drag(
      find.byKey(const ValueKey('rdg-row-drag-0')),
      const Offset(0, 80),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Grace')).dy,
      lessThan(tester.getTopLeft(find.text('Ada')).dy),
    );
    expect(from, 0);
    expect(to, 1);
    expect(moved?.name, 'Ada');
  });

  testWidgets('reorder handle is omitted when the grid is sorted', (
    tester,
  ) async {
    await _pump(
      tester,
      criteria: LoadCriteria(
        orderBy: [OrderCriteria(fieldName: 'name')],
      ),
    );
    expect(find.byKey(const ValueKey('rdg-row-drag-0')), findsNothing);
  });
}
