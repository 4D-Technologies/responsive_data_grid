import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;
  final String extra;
  final String more;

  const _Person(this.id, this.name, this.extra, this.more);
}

List<GridColumn<_Person, dynamic>> _columns({bool stickyName = false}) {
  return [
    IntColumn<_Person>(
      fieldName: 'id',
      header: const ColumnHeader(text: 'Id'),
      value: (row) => row.id,
      xsCols: 2,
      width: 80,
    ),
    StringColumn<_Person>(
      fieldName: 'name',
      header: const ColumnHeader(text: 'Name'),
      value: (row) => row.name,
      xsCols: 4,
      width: 140,
      sticky: stickyName,
    ),
    StringColumn<_Person>(
      fieldName: 'extra',
      header: const ColumnHeader(text: 'Extra'),
      value: (row) => row.extra,
      xsCols: 6,
      width: 220,
    ),
    StringColumn<_Person>(
      fieldName: 'more',
      header: const ColumnHeader(text: 'More'),
      value: (row) => row.more,
      xsCols: 6,
      width: 220,
    ),
  ];
}

Future<void> _pump(WidgetTester tester, {bool stickyName = false}) async {
  tester.view.physicalSize = const Size(400, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 700,
          child: ResponsiveDataGrid<_Person>.clientSide(
            height: 600,
            pagingMode: PagingMode.pager,
            layoutMode: GridLayoutMode.table,
            items: const [_Person(1, 'Ada', 'Yes', 'More')],
            columns: _columns(stickyName: stickyName),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

Finder _horizontalScroll() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is SingleChildScrollView &&
        widget.scrollDirection == Axis.horizontal,
  );
}

void main() {
  testWidgets('sticky column is not locked to the leading edge', (
    tester,
  ) async {
    await _pump(tester, stickyName: true);

    final id = tester.getTopLeft(find.text('Id').first);
    final name = tester.getTopLeft(find.text('Name').first);
    expect(name.dx, greaterThan(id.dx + 10));
  });

  testWidgets('sticky column stays visible while others scroll away', (
    tester,
  ) async {
    await _pump(tester, stickyName: true);

    await tester.drag(_horizontalScroll(), const Offset(-400, 0));
    await tester.pumpAndSettle();

    final name = tester.getTopLeft(find.text('Name').first);
    expect(name.dx, greaterThanOrEqualTo(-1));
    expect(name.dx, lessThan(400));

    final extra = find.text('Extra');
    if (extra.evaluate().isNotEmpty) {
      expect(tester.getTopLeft(extra.first).dx, lessThan(-1));
    }
  });
}
