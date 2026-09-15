import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;
  final String extra;

  const _Person(this.id, this.name, this.extra);
}

List<GridColumn<_Person, dynamic>> _columns({
  bool hideDob = false,
  bool freezeName = false,
}) {
  return [
    IntColumn<_Person>(
      fieldName: 'id',
      header: const ColumnHeader(text: 'Id'),
      value: (row) => row.id,
      xsCols: 2,
    ),
    StringColumn<_Person>(
      fieldName: 'name',
      header: const ColumnHeader(text: 'Name'),
      value: (row) => row.name,
      xsCols: 5,
      frozen: freezeName,
    ),
    StringColumn<_Person>(
      fieldName: 'dob',
      header: const ColumnHeader(text: 'Date of Birth'),
      value: (row) => row.extra,
      xsCols: 4,
      visible: !hideDob,
    ),
    StringColumn<_Person>(
      fieldName: 'enum',
      header: const ColumnHeader(text: 'Enum'),
      value: (row) => row.extra,
      xsCols: 4,
    ),
  ];
}

Future<ResponsiveDataGridState<_Person>> _pump(
  WidgetTester tester, {
  List<GridColumn<_Person, dynamic>>? columns,
  GridLayoutMode layoutMode = GridLayoutMode.table,
}) async {
  tester.view.physicalSize = const Size(400, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final key = GlobalKey<ResponsiveDataGridState<_Person>>();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 700,
          child: ResponsiveDataGrid<_Person>.clientSide(
            key: key,
            height: 600,
            pagingMode: PagingMode.pager,
            layoutMode: layoutMode,
            items: const [_Person(1, 'Ada', 'Yes')],
            columns: columns ?? _columns(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return key.currentState!;
}

Finder _horizontalScroll() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is SingleChildScrollView &&
        widget.scrollDirection == Axis.horizontal,
  );
}

void main() {
  testWidgets('hidden columns are omitted from the header', (tester) async {
    await _pump(tester, columns: _columns(hideDob: true));

    expect(find.text('Id'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Date of Birth'), findsNothing);
    expect(find.text('Enum'), findsOneWidget);
  });

  testWidgets('setColumnVisible hides and shows a column', (tester) async {
    final state = await _pump(tester);
    expect(find.text('Date of Birth'), findsOneWidget);

    state.setColumnVisible('dob', false);
    await tester.pump();
    expect(find.text('Date of Birth'), findsNothing);

    state.setColumnVisible('dob', true);
    await tester.pump();
    expect(find.text('Date of Birth'), findsOneWidget);
  });

  testWidgets('frozen columns stay in view while others scroll', (
    tester,
  ) async {
    await _pump(tester, columns: _columns(freezeName: true));

    final nameBefore = tester.getTopLeft(find.text('Name').first);
    await tester.drag(_horizontalScroll(), const Offset(-180, 0));
    await tester.pumpAndSettle();

    final nameAfter = tester.getTopLeft(find.text('Name').first);
    expect(nameAfter.dx, closeTo(nameBefore.dx, 2));
    expect(nameAfter.dx, greaterThanOrEqualTo(-1));
  });

  testWidgets('setColumnWidth is honored in table mode', (tester) async {
    final state = await _pump(tester);
    final before = tester.getSize(
      find.byKey(const ValueKey('rdg-header-cell-id')),
    );

    state.setColumnWidth('id', 120);
    await tester.pump();

    final after = tester.getSize(
      find.byKey(const ValueKey('rdg-header-cell-id')),
    );
    expect(after.width, closeTo(120, 1));
    expect(after.width, isNot(closeTo(before.width, 1)));
  });

  testWidgets('reorderColumn swaps header order', (tester) async {
    final state = await _pump(tester);
    expect(
      tester.getTopLeft(find.text('Id').first).dx,
      lessThan(tester.getTopLeft(find.text('Name').first).dx),
    );

    state.reorderColumn(0, 1);
    await tester.pump();

    expect(
      tester.getTopLeft(find.text('Name').first).dx,
      lessThan(tester.getTopLeft(find.text('Id').first).dx),
    );
  });

  testWidgets('reflow mode still wraps when columns exceed 12 segments', (
    tester,
  ) async {
    await _pump(tester, layoutMode: GridLayoutMode.reflow);

    final id = tester.getTopLeft(find.text('Id').first);
    final enumHeader = tester.getTopLeft(find.text('Enum').first);
    expect(enumHeader.dy, isNot(closeTo(id.dy, 2)));
  });
}
