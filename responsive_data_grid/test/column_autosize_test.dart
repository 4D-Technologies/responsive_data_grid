import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;

  const _Person(this.id, this.name);
}

Future<ResponsiveDataGridState<_Person>> _pump(
  WidgetTester tester, {
  List<_Person> items = const [
    _Person(1, 'A'),
    _Person(2, 'Supercalifragilisticexpialidocious'),
  ],
  List<GridColumn<_Person, dynamic>>? columns,
  bool autoSize = false,
  double width = 800,
}) async {
  tester.view.physicalSize = Size(width, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final key = GlobalKey<ResponsiveDataGridState<_Person>>();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: 700,
          child: ResponsiveDataGrid<_Person>.clientSide(
            key: key,
            height: 600,
            pagingMode: PagingMode.pager,
            layoutMode: GridLayoutMode.table,
            autoSize: autoSize,
            items: items,
            columns:
                columns ??
                [
                  IntColumn<_Person>(
                    fieldName: 'id',
                    header: const ColumnHeader(text: 'Id'),
                    value: (row) => row.id,
                    xsCols: 6,
                  ),
                  StringColumn<_Person>(
                    fieldName: 'name',
                    header: const ColumnHeader(text: 'Name'),
                    value: (row) => row.name,
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
  return key.currentState!;
}

double _headerWidth(WidgetTester tester, String field) {
  return tester.getSize(find.byKey(ValueKey('rdg-header-cell-$field'))).width;
}

void main() {
  test('fitWidthsToViewport grows columns to fill leftover space', () {
    final fitted = fitWidthsToViewport(
      widths: const [80.0, 80.0, 80.0],
      minWidths: const [null, null, null],
      maxWidths: const [null, null, null],
      viewport: 400,
    );
    expect(fitted.reduce((a, b) => a + b), closeTo(400, 0.001));
    expect(fitted[0], closeTo(fitted[1], 0.001));
  });

  test('fitWidthsToViewport shrinks overflow and honors minWidth', () {
    final fitted = fitWidthsToViewport(
      widths: const [300.0, 300.0, 300.0],
      minWidths: const [50.0, 50.0, 50.0],
      maxWidths: const [null, null, null],
      viewport: 400,
    );
    expect(fitted.reduce((a, b) => a + b), closeTo(400, 0.001));
    for (final width in fitted) {
      expect(width, greaterThanOrEqualTo(50));
    }
  });

  testWidgets('equal segments stay similar without autosize', (tester) async {
    await _pump(tester);
    expect(
      _headerWidth(tester, 'name'),
      closeTo(_headerWidth(tester, 'id'), 8),
    );
  });

  testWidgets('autosize uses the widest header or cell', (tester) async {
    final state = await _pump(tester);
    state.autosizeColumn('id');
    state.autosizeColumn('name');
    await tester.pump();

    expect(
      _headerWidth(tester, 'name'),
      greaterThan(_headerWidth(tester, 'id') + 20),
    );
  });

  testWidgets('autosize honors maxWidth', (tester) async {
    final state = await _pump(
      tester,
      columns: [
        StringColumn<_Person>(
          fieldName: 'name',
          header: const ColumnHeader(text: 'Name'),
          value: (row) => row.name,
          xsCols: 12,
          maxWidth: 90,
        ),
      ],
    );
    state.autosizeColumn('name');
    await tester.pump();
    expect(_headerWidth(tester, 'name'), closeTo(90, 1));
  });

  testWidgets('autoFitColumnsToGrid shrinks overflow to the viewport', (
    tester,
  ) async {
    final state = await _pump(
      tester,
      width: 400,
      columns: [
        StringColumn<_Person>(
          fieldName: 'id',
          header: const ColumnHeader(text: 'Id'),
          value: (row) => row.id.toString(),
          xsCols: 6,
          width: 300,
          minWidth: 50,
        ),
        StringColumn<_Person>(
          fieldName: 'name',
          header: const ColumnHeader(text: 'Name'),
          value: (row) => row.name,
          xsCols: 6,
          width: 300,
          minWidth: 50,
        ),
      ],
    );
    state.autoFitColumnsToGrid();
    await tester.pump();
    final sum = _headerWidth(tester, 'id') + _headerWidth(tester, 'name');
    expect(sum, lessThan(400));
    expect(_headerWidth(tester, 'id'), greaterThanOrEqualTo(50));
    expect(_headerWidth(tester, 'name'), greaterThanOrEqualTo(50));
  });

  testWidgets('autoFitColumnsToGrid fills leftover grid width', (tester) async {
    final state = await _pump(
      tester,
      columns: [
        StringColumn<_Person>(
          fieldName: 'id',
          header: const ColumnHeader(text: 'Id'),
          value: (row) => row.id.toString(),
          xsCols: 4,
          width: 80,
        ),
        StringColumn<_Person>(
          fieldName: 'name',
          header: const ColumnHeader(text: 'Name'),
          value: (row) => row.name,
          xsCols: 8,
          width: 80,
        ),
      ],
    );
    state.autoFitColumnsToGrid();
    await tester.pump();

    final sum = _headerWidth(tester, 'id') + _headerWidth(tester, 'name');
    expect(sum, greaterThan(200));
    expect(sum, closeTo(800, 24));
  });

  testWidgets('grid autoSize sizes a long cell wider than a short one', (
    tester,
  ) async {
    await _pump(tester, autoSize: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      _headerWidth(tester, 'name'),
      greaterThan(_headerWidth(tester, 'id') + 20),
    );
  });

  testWidgets('per-column autoSize only sizes that column', (tester) async {
    await _pump(
      tester,
      columns: [
        IntColumn<_Person>(
          fieldName: 'id',
          header: const ColumnHeader(text: 'Id'),
          value: (row) => row.id,
          xsCols: 6,
        ),
        StringColumn<_Person>(
          fieldName: 'name',
          header: const ColumnHeader(text: 'Name'),
          value: (row) => row.name,
          xsCols: 6,
          autoSize: true,
        ),
      ],
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      _headerWidth(tester, 'name'),
      greaterThan(_headerWidth(tester, 'id') + 20),
    );
  });
}
