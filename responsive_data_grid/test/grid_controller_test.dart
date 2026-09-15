import 'package:client_filtering/client_filtering.dart';
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
  required ResponsiveDataGridController<_Person> controller,
  List<_Person> items = const [
    _Person(1, 'Ada'),
    _Person(2, 'Grace'),
    _Person(3, 'Alan'),
  ],
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
            height: 500,
            pagingMode: PagingMode.pager,
            pageSize: 2,
            items: items,
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
  testWidgets('controller pages without a GlobalKey', (tester) async {
    final controller = ResponsiveDataGridController<_Person>();
    addTearDown(controller.dispose);
    await _pump(tester, controller: controller);

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Alan'), findsNothing);

    await controller.setPage(2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Alan'), findsOneWidget);
    expect(controller.pageNumber, 2);
    expect(controller.criteria, isNotNull);
  });

  testWidgets('controller clearFilters removes a column filter', (
    tester,
  ) async {
    final controller = ResponsiveDataGridController<_Person>();
    addTearDown(controller.dispose);
    await _pump(tester, controller: controller);

    controller.setColumnVisible('id', true);
    final state = tester.state<ResponsiveDataGridState<_Person>>(
      find.byType(ResponsiveDataGrid<_Person>),
    );
    state.widget.columns
            .firstWhere((c) => c.fieldName == 'name')
            .filterRules
            .criteria =
        FilterCriteria<String>(
          fieldName: 'name',
          op: Operators.and,
          logicalOperator: Logic.contains,
          values: ['Ada'],
        );
    await state.refreshData();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Grace'), findsNothing);

    await controller.clearFilters();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Grace'), findsOneWidget);
  });

  testWidgets('controller detaches on dispose and does not throw', (
    tester,
  ) async {
    final controller = ResponsiveDataGridController<_Person>();
    await _pump(tester, controller: controller);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();
    expect(controller.isAttached, isFalse);
    await controller.refresh();
    controller.dispose();
  });
}
