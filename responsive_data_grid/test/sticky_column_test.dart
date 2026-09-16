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

bool _anyOnScreen(WidgetTester tester, Finder finder, {double maxDx = 400}) {
  return finder.evaluate().any((element) {
    final renderObject = element.renderObject;
    if (renderObject is! RenderBox || !renderObject.hasSize) return false;
    final dx = renderObject.localToGlobal(Offset.zero).dx;
    return dx >= -1 && dx < maxDx;
  });
}

void main() {
  test('sticky extras stack two start-pinned columns', () {
    final extras = stickyExtras(
      indexes: const [1, 2],
      widths: const [80, 140, 160, 200],
      pixels: 400,
      viewport: 400,
      frozenWidth: 80,
    );
    expect(extras.length, 2);
    expect(extras[0], closeTo(400, 0.001));
    expect(extras[1], closeTo(400, 0.001));
  });

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

    expect(_anyOnScreen(tester, find.text('Name')), isTrue);
    expect(_anyOnScreen(tester, find.text('Ada')), isTrue);
  });

  testWidgets('two sticky columns stack instead of overlapping', (
    tester,
  ) async {
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
              columns: [
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
                  sticky: true,
                ),
                StringColumn<_Person>(
                  fieldName: 'extra',
                  header: const ColumnHeader(text: 'Extra'),
                  value: (row) => row.extra,
                  xsCols: 6,
                  width: 160,
                  sticky: true,
                ),
                StringColumn<_Person>(
                  fieldName: 'more',
                  header: const ColumnHeader(text: 'More'),
                  value: (row) => row.more,
                  xsCols: 6,
                  width: 220,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.drag(_horizontalScroll(), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(_anyOnScreen(tester, find.text('Name')), isTrue);
    expect(_anyOnScreen(tester, find.text('Extra')), isTrue);
    final nameDx = find
        .text('Name')
        .evaluate()
        .map((el) {
          final box = el.renderObject as RenderBox;
          return box.localToGlobal(Offset.zero).dx;
        })
        .reduce((a, b) => a > b ? a : b);
    final extraDx = find
        .text('Extra')
        .evaluate()
        .map((el) {
          final box = el.renderObject as RenderBox;
          return box.localToGlobal(Offset.zero).dx;
        })
        .reduce((a, b) => a > b ? a : b);
    expect(extraDx, greaterThan(nameDx + 10));
  });
}
