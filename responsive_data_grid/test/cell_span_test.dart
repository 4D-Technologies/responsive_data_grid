import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String city;
  final String extra;

  const _Person(this.id, this.city, this.extra);

  @override
  String toString() => '$id';
}

Future<void> _pump(
  WidgetTester tester, {
  bool rowspan = false,
  int Function(_Person item, int rowIndex)? rowspanFor,
  int Function(_Person item)? colspan,
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
          height: 700,
          child: ResponsiveDataGrid<_Person>.clientSide(
            height: 400,
            pagingMode: PagingMode.pager,
            layoutMode: GridLayoutMode.table,
            items: const [
              _Person(1, 'Boston', 'A'),
              _Person(2, 'Boston', 'B'),
              _Person(3, 'Chicago', 'C'),
            ],
            columns: [
              IntColumn<_Person>(
                fieldName: 'id',
                header: const ColumnHeader(text: 'Id'),
                value: (row) => row.id,
                xsCols: 3,
                width: 80,
              ),
              StringColumn<_Person>(
                fieldName: 'city',
                header: const ColumnHeader(text: 'City'),
                value: (row) => row.city,
                xsCols: 5,
                width: 140,
                rowspan: rowspan,
                rowspanFor: rowspanFor,
                colspan: colspan,
              ),
              StringColumn<_Person>(
                fieldName: 'extra',
                header: const ColumnHeader(text: 'Extra'),
                value: (row) => row.extra,
                xsCols: 4,
                width: 120,
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
  test('computeRowspans merges consecutive equal values', () {
    const items = [
      _Person(1, 'Boston', 'A'),
      _Person(2, 'Boston', 'B'),
      _Person(3, 'Chicago', 'C'),
    ];
    final column = StringColumn<_Person>(
      fieldName: 'city',
      value: (row) => row.city,
      rowspan: true,
    );
    expect(computeRowspans(column, items), [2, 0, 1]);
  });

  testWidgets('rowspan hides the duplicate adjacent cell', (tester) async {
    await _pump(tester, rowspan: true);
    expect(find.text('Boston'), findsOneWidget);
    expect(find.text('Chicago'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('rowspanFor can override the span length', (tester) async {
    await _pump(tester, rowspanFor: (item, index) => index == 0 ? 2 : 0);
    expect(find.text('Boston'), findsOneWidget);
  });

  testWidgets('colspan occupies two adjacent columns', (tester) async {
    await _pump(tester, colspan: (item) => item.id == 1 ? 2 : 1);
    final cityHeader = tester.getSize(
      find.byKey(const ValueKey('rdg-header-cell-city')),
    );
    final extraHeader = tester.getSize(
      find.byKey(const ValueKey('rdg-header-cell-extra')),
    );
    final cityCell = tester.getSize(
      find.byKey(const ValueKey('rdg-cell-city-1')),
    );
    expect(cityCell.width, closeTo(cityHeader.width + extraHeader.width, 2));
    expect(find.text('A'), findsNothing);
  });
}
