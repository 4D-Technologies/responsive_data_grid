import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;

  const _Person(this.id, this.name);
}

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 900,
          height: 700,
          child: ResponsiveDataGrid<_Person>.clientSide(
            height: 500,
            pagingMode: PagingMode.pager,
            layoutMode: GridLayoutMode.table,
            allowGrouping: true,
            allowAggregations: true,
            items: const [
              _Person(1, 'Ada'),
              _Person(2, 'Ada'),
              _Person(3, 'Grace'),
            ],
            columns: [
              IntColumn<_Person>(
                fieldName: 'id',
                header: const ColumnHeader(text: 'Id'),
                value: (row) => row.id,
                xsCols: 4,
              ),
              StringColumn<_Person>(
                fieldName: 'name',
                header: const ColumnHeader(
                  text: 'Name',
                  showOrderBy: true,
                  showAggregations: true,
                ),
                value: (row) => row.name,
                xsCols: 8,
                aggregations: const [
                  AggregateCriteria(
                    fieldName: 'name',
                    aggregation: Aggregations.count,
                  ),
                ],
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
  testWidgets('grouping from the column menu shows group headers and counts', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.byType(GridGroupHeader), findsNothing);

    await tester.tap(find.byKey(const ValueKey('rdg-header-menu-name')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Group column'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(GridGroupHeader),
        matching: find.text('Ada'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(GridGroupHeader),
        matching: find.text('Grace'),
      ),
      findsOneWidget,
    );

    final groupCounts = find.descendant(
      of: find.byType(GridGroupFooter<_Person>),
      matching: find.textContaining('Count:'),
    );
    expect(groupCounts, findsWidgets);
    expect(find.textContaining('Count: 2'), findsWidgets);
    expect(find.textContaining('Count: 1'), findsWidgets);
  });

  testWidgets('collapsing a group hides its rows', (tester) async {
    await _pump(tester);
    await tester.tap(find.byKey(const ValueKey('rdg-header-menu-name')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Group column'));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('rdg-group-toggle-name-Ada')));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsNothing);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('ungroup from the column menu restores a flat list', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.byKey(const ValueKey('rdg-header-menu-name')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Group column'));
    await tester.pumpAndSettle();
    expect(find.byType(GridGroupHeader), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('rdg-header-menu-name')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ungroup'));
    await tester.pumpAndSettle();

    expect(find.byType(GridGroupHeader), findsNothing);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });
}
