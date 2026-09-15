import 'package:client_filtering/client_filtering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;

  const _Person(this.id, this.name);
}

Future<void> _pump(
  WidgetTester tester, {
  void Function(_Person)? onTap,
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
          height: 600,
          child: ResponsiveDataGrid<_Person>.clientSide(
            height: 500,
            pagingMode: PagingMode.pager,
            pageSize: 10,
            sortable: SortableOptions.single,
            itemTapped: onTap,
            items: const [_Person(1, 'Ada'), _Person(2, 'Grace')],
            columns: [
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
  testWidgets('pager buttons expose semantic labels', (tester) async {
    await _pump(tester);
    expect(find.bySemanticsLabel('Next page'), findsOneWidget);
  });

  testWidgets('column headers expose header semantics', (tester) async {
    await _pump(tester);
    expect(find.bySemanticsLabel(RegExp(r'^Id')), findsWidgets);
  });

  testWidgets('cells expose their values to semantics', (tester) async {
    await _pump(tester);
    final semantics = tester.getSemantics(find.text('Ada'));
    expect(semantics.label, contains('Ada'));
  });

  testWidgets('Enter on a focused row invokes itemTapped', (tester) async {
    _Person? tapped;
    await _pump(tester, onTap: (p) => tapped = p);

    final row = find.text('Ada');
    await tester.tap(row);
    await tester.pump();
    tapped = null;

    final focus = Focus.of(tester.element(row));
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(tapped?.name, 'Ada');
  });
}
