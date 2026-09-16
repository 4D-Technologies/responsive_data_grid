import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;

  const _Person(this.id, this.name);
}

Finder _highlightBox(Color highlight) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is DecoratedBox &&
        widget.decoration is BoxDecoration &&
        (widget.decoration as BoxDecoration).color == highlight,
  );
}

List<GridColumn<_Person, dynamic>> _frozenColumns() {
  return [
    StringColumn<_Person>(
      fieldName: 'name',
      header: const ColumnHeader(text: 'Name'),
      value: (row) => row.name,
      xsCols: 4,
      frozen: true,
      width: 160,
    ),
    IntColumn<_Person>(
      fieldName: 'id',
      header: const ColumnHeader(text: 'Id'),
      value: (row) => row.id,
      xsCols: 4,
      width: 200,
    ),
    StringColumn<_Person>(
      fieldName: 'extra',
      header: const ColumnHeader(text: 'Extra'),
      value: (row) => 'extra-${row.id}',
      xsCols: 6,
      width: 240,
    ),
  ];
}

Finder _frozenOverlay(Finder of) {
  return find.ancestor(of: of, matching: find.byType(PinToHorizontalViewport));
}

Future<void> _pumpGrid(
  WidgetTester tester, {
  GridRowDecoration<_Person>? rowDecoration,
  GridCellDecoration<_Person>? cellDecoration,
  List<GridColumn<_Person, dynamic>>? columns,
}) async {
  tester.view.physicalSize = const Size(800, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 500,
          child: ResponsiveDataGrid<_Person>.clientSide(
            height: 400,
            pagingMode: PagingMode.pager,
            rowDecoration: rowDecoration,
            cellDecoration: cellDecoration,
            items: const [_Person(1, 'Ada'), _Person(2, 'Grace')],
            columns:
                columns ??
                [
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
  testWidgets('rowDecoration tints matching rows', (tester) async {
    const highlight = Color(0xFFFFCCCC);
    await _pumpGrid(
      tester,
      rowDecoration: (item) =>
          item.id == 1 ? const BoxDecoration(color: highlight) : null,
    );

    expect(_highlightBox(highlight), findsOneWidget);
    expect(
      find.ancestor(of: find.text('Ada'), matching: _highlightBox(highlight)),
      findsOneWidget,
    );
    expect(
      find.ancestor(of: find.text('Grace'), matching: _highlightBox(highlight)),
      findsNothing,
    );
  });

  testWidgets('cellDecoration tints a single column', (tester) async {
    const highlight = Color(0xFFCCFFCC);
    await _pumpGrid(
      tester,
      cellDecoration: (item, column) =>
          column.fieldName == 'name' && item.id == 2
          ? const BoxDecoration(color: highlight)
          : null,
    );

    expect(_highlightBox(highlight), findsOneWidget);
    expect(
      find.ancestor(of: find.text('Grace'), matching: _highlightBox(highlight)),
      findsOneWidget,
    );
    expect(
      find.ancestor(of: find.text('Ada'), matching: _highlightBox(highlight)),
      findsNothing,
    );
  });

  testWidgets('rowDecoration without color is left unchanged', (tester) async {
    const borderColor = Color(0xFFE11D48);
    await _pumpGrid(
      tester,
      rowDecoration: (item) => item.id == 1
          ? const BoxDecoration(
              border: Border(left: BorderSide(color: borderColor, width: 3)),
            )
          : null,
    );

    expect(tester.takeException(), isNull);
    final boxes = tester.widgetList<DecoratedBox>(
      find.ancestor(of: find.text('Ada'), matching: find.byType(DecoratedBox)),
    );
    expect(
      boxes.any((box) {
        final decoration = box.decoration;
        return decoration is BoxDecoration &&
            decoration.color == null &&
            decoration.border != null;
      }),
      isTrue,
    );
    expect(
      boxes.any((box) {
        final decoration = box.decoration;
        return decoration is BoxDecoration && decoration.color != null;
      }),
      isTrue,
    );
  });

  testWidgets('rowDecoration color reaches frozen cells', (tester) async {
    const highlight = Color(0xFFFFCCCC);
    await _pumpGrid(
      tester,
      rowDecoration: (item) =>
          item.id == 1 ? const BoxDecoration(color: highlight) : null,
      columns: _frozenColumns(),
    );

    expect(
      find.descendant(
        of: _frozenOverlay(find.text('Ada')),
        matching: _highlightBox(highlight),
      ),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: _frozenOverlay(find.text('Grace')),
        matching: _highlightBox(highlight),
      ),
      findsNothing,
    );
  });

  testWidgets('frozen overlay keeps theme fill for border-only rows', (
    tester,
  ) async {
    const borderColor = Color(0xFFE11D48);
    final borderDecoration = find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == null &&
          (widget.decoration as BoxDecoration).border != null,
    );
    await _pumpGrid(
      tester,
      rowDecoration: (item) => item.id == 1
          ? const BoxDecoration(
              border: Border(left: BorderSide(color: borderColor, width: 3)),
            )
          : null,
      columns: _frozenColumns(),
    );

    expect(
      find.descendant(
        of: _frozenOverlay(find.text('Ada')),
        matching: borderDecoration,
      ),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: _frozenOverlay(find.text('Grace')),
        matching: borderDecoration,
      ),
      findsNothing,
    );
  });
}
