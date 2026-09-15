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
  FilterableMode filterable = FilterableMode.row,
  bool nameFilter = true,
  bool idFilter = true,
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
            filterable: filterable,
            items: const [
              _Person(1, 'Ada'),
              _Person(2, 'Grace'),
              _Person(3, 'Alan'),
            ],
            columns: [
              IntColumn<_Person>(
                fieldName: 'id',
                header: ColumnHeader(text: 'Id', showFilter: idFilter),
                value: (row) => row.id,
                xsCols: 4,
              ),
              StringColumn<_Person>(
                fieldName: 'name',
                header: ColumnHeader(text: 'Name', showFilter: nameFilter),
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
  testWidgets('menu mode does not show the filter row', (tester) async {
    await _pump(tester, filterable: FilterableMode.menu);
    expect(find.byKey(const ValueKey('rdg-filter-row-name')), findsNothing);
  });

  testWidgets('row mode shows editors under headers', (tester) async {
    await _pump(tester);
    expect(find.byKey(const ValueKey('rdg-filter-row-name')), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-filter-row-id')), findsOneWidget);
  });

  testWidgets('per-column showFilter false omits the row editor', (
    tester,
  ) async {
    await _pump(tester, nameFilter: false);
    expect(find.byKey(const ValueKey('rdg-filter-row-name')), findsNothing);
    expect(find.byKey(const ValueKey('rdg-filter-row-id')), findsOneWidget);
  });

  testWidgets('string row filter apply and clear', (tester) async {
    await _pump(tester);

    await tester.enterText(
      find.byKey(const ValueKey('rdg-filter-row-name')),
      'Ada',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('Ada'), findsWidgets);
    expect(find.text('Grace'), findsNothing);
    expect(find.text('Alan'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('rdg-filter-row-name')),
      '',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('Grace'), findsOneWidget);
    expect(find.text('Alan'), findsOneWidget);
  });

  testWidgets('numeric row filter apply and clear', (tester) async {
    await _pump(tester);

    await tester.enterText(
      find.byKey(const ValueKey('rdg-filter-row-id')),
      '2',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('Grace'), findsOneWidget);
    expect(find.text('Ada'), findsNothing);

    await tester.enterText(find.byKey(const ValueKey('rdg-filter-row-id')), '');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('Ada'), findsWidgets);
    expect(find.text('Grace'), findsOneWidget);
  });

  testWidgets('row mode does not put filters in the column menu', (
    tester,
  ) async {
    await _pump(tester, filterable: FilterableMode.row);
    await tester.tap(find.byKey(const ValueKey('rdg-header-menu-name')));
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<Logic?>), findsNothing);
  });
}
