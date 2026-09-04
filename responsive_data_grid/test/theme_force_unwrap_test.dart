import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;
  final int age;

  const _Person(this.name, this.age);
}

/// Material 3 theme with the fields the grid currently force-unwraps left null.
ThemeData _sparseTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    buttonTheme: const ButtonThemeData(),
    primaryTextTheme: const TextTheme(),
  );
}

Widget _harness({required Widget child}) {
  return MaterialApp(
    theme: _sparseTheme(),
    home: Scaffold(
      body: SizedBox(width: 900, height: 700, child: child),
    ),
  );
}

ResponsiveDataGrid<_Person> _grid({bool grouping = true}) {
  return ResponsiveDataGrid<_Person>.clientSide(
    items: const [
      _Person('Ada', 36),
      _Person('Grace', 41),
      _Person('Ada', 30),
    ],
    pageSize: 10,
    pagingMode: PagingMode.pager,
    height: 600,
    allowGrouping: grouping,
    initialLoadCriteria: grouping
        ? LoadCriteria(
            groupBy: [
              GroupCriteria(
                fieldName: 'name',
                direction: OrderDirections.ascending,
                aggregates: const [],
              ),
            ],
          )
        : null,
    columns: [
      StringColumn<_Person>(
        fieldName: 'name',
        header: const ColumnHeader(
          text: 'Name',
          showFilter: true,
          showOrderBy: true,
          showAggregations: true,
        ),
        value: (row) => row.name,
        xsCols: 6,
      ),
      IntColumn<_Person>(
        fieldName: 'age',
        header: const ColumnHeader(
          text: 'Age',
          showFilter: true,
          showOrderBy: true,
        ),
        value: (row) => row.age,
        xsCols: 6,
      ),
    ],
  );
}

void main() {
  testWidgets(
    'grid, group chooser, and headers render under a sparse Material 3 theme',
    (tester) async {
      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_harness(child: _grid()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('Name'), findsWidgets);
      expect(find.text('Age'), findsWidgets);
      expect(find.byIcon(Icons.account_tree), findsWidgets);
    },
  );

  testWidgets('column menu opens without crashing under a sparse theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_harness(child: _grid(grouping: false)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.menu).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    _expectNoThemeCrash(tester);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text(LocalizedMessages.apply), findsOneWidget);
  });

  testWidgets('column menu dismisses via Apply using the overlay context', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_harness(child: _grid(grouping: false)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byIcon(Icons.menu).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Filter'), findsOneWidget);

    await tester.tap(find.text(LocalizedMessages.apply));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    _expectNoThemeCrash(tester);
    expect(find.text('Filter'), findsNothing);
  });
}

/// Overflow in the 250px column menu is #41. This issue only forbids theme
/// force-unwrap / Navigator crashes.
void _expectNoThemeCrash(WidgetTester tester) {
  final error = tester.takeException();
  if (error == null) return;
  expect(
    error.toString(),
    contains('overflowed'),
    reason: 'Unexpected exception: $error',
  );
}
