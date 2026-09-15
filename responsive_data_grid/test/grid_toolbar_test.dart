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
  GridToolbar? toolbar,
  ResponsiveDataGridController<_Person>? controller,
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
            controller: controller,
            toolbar: toolbar,
            height: 500,
            pagingMode: PagingMode.pager,
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
  testWidgets('toolbar is omitted by default', (tester) async {
    await _pump(tester);
    expect(find.byKey(const ValueKey('rdg-toolbar')), findsNothing);
  });

  testWidgets('search filters string columns', (tester) async {
    await _pump(tester, toolbar: const GridToolbar(search: true));
    expect(find.byKey(const ValueKey('rdg-toolbar')), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('rdg-toolbar-search')), 'Ada');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Ada'), findsWidgets);
    expect(find.text('Grace'), findsNothing);
  });

  testWidgets('column chooser hides a column', (tester) async {
    await _pump(tester, toolbar: const GridToolbar(columnChooser: true));
    await tester.tap(find.byKey(const ValueKey('rdg-toolbar-columns')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(CheckedPopupMenuItem<String>).first);
    await tester.tap(find.byType(CheckedPopupMenuItem<String>).first);
    await tester.pump();
    expect(find.byKey(const ValueKey('rdg-header-cell-id')), findsNothing);
  });

  testWidgets('refresh is shown only with a controller', (tester) async {
    await _pump(tester, toolbar: const GridToolbar(refresh: true));
    expect(find.byKey(const ValueKey('rdg-toolbar-refresh')), findsNothing);

    final controller = ResponsiveDataGridController<_Person>();
    addTearDown(controller.dispose);
    await _pump(
      tester,
      toolbar: const GridToolbar(refresh: true),
      controller: controller,
    );
    expect(find.byKey(const ValueKey('rdg-toolbar-refresh')), findsOneWidget);
  });
}
