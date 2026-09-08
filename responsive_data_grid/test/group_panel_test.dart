import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;
  final int age;

  const _Person(this.name, this.age);
}

ResponsiveDataGrid<_Person> _grid({
  GroupPanelDisplay groupPanel = GroupPanelDisplay.collapsed,
  bool allowGrouping = true,
  LoadCriteria? initial,
}) {
  return ResponsiveDataGrid<_Person>.clientSide(
    items: const [_Person('Ada', 36), _Person('Alan', 42)],
    pageSize: 10,
    pagingMode: PagingMode.pager,
    height: 500,
    allowGrouping: allowGrouping,
    groupPanel: groupPanel,
    initialLoadCriteria: initial,
    columns: [
      StringColumn<_Person>(
        fieldName: 'name',
        header: const ColumnHeader(
          text: 'Name',
          showFilter: true,
          showOrderBy: true,
        ),
        value: (row) => row.name,
        xsCols: 6,
      ),
      IntColumn<_Person>(
        fieldName: 'age',
        header: const ColumnHeader(text: 'Age', showFilter: true),
        value: (row) => row.age,
        xsCols: 6,
      ),
    ],
  );
}

Future<void> _pump(WidgetTester tester, {required Widget grid}) async {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SizedBox(width: 900, height: 600, child: grid)),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('collapsed group panel is labeled and compact', (tester) async {
    await _pump(tester, grid: _grid());
    expect(find.text('Group by'), findsOneWidget);
    expect(find.text('Select a column to group by'), findsOneWidget);
    expect(find.text('Add grouping'), findsNothing);
    expect(find.byKey(const ValueKey('rdg-group-panel')), findsOneWidget);
  });

  testWidgets('collapsed panel expands to the full labeled panel', (
    tester,
  ) async {
    await _pump(tester, grid: _grid());
    await tester.tap(find.byKey(const ValueKey('rdg-group-panel-expand')));
    await tester.pump();
    expect(find.text('Add grouping'), findsOneWidget);
    expect(find.text('Group by'), findsOneWidget);
  });

  testWidgets('hidden group panel is omitted', (tester) async {
    await _pump(tester, grid: _grid(groupPanel: GroupPanelDisplay.hidden));
    expect(find.byKey(const ValueKey('rdg-group-panel')), findsNothing);
    expect(find.text('Group by'), findsNothing);
  });

  testWidgets('always mode shows the full panel', (tester) async {
    await _pump(tester, grid: _grid(groupPanel: GroupPanelDisplay.always));
    expect(find.text('Group by'), findsOneWidget);
    expect(find.text('Add grouping'), findsOneWidget);
    expect(find.text('Select a column to group by'), findsOneWidget);
  });

  testWidgets('active group chips use contrasting chip colors', (tester) async {
    await _pump(
      tester,
      grid: _grid(
        groupPanel: GroupPanelDisplay.always,
        initial: LoadCriteria(
          groupBy: [
            GroupCriteria(
              fieldName: 'name',
              direction: OrderDirections.ascending,
              aggregates: const [],
            ),
          ],
        ),
      ),
    );

    expect(find.byKey(const ValueKey('rdg-group-chip-name')), findsOneWidget);
    final element = tester.element(
      find.byKey(const ValueKey('rdg-group-panel')),
    );
    final theme = ResponsiveDataGridTheme.of(element);
    expect(
      gridContrastRatio(theme.chooserBackground, theme.chooserForeground),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      gridContrastRatio(
        theme.chooserChipBackground,
        theme.chooserChipForeground,
      ),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('column menu can group when the panel is hidden', (tester) async {
    await _pump(tester, grid: _grid(groupPanel: GroupPanelDisplay.hidden));
    await tester.tap(find.byKey(const ValueKey('rdg-header-menu-name')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Group column'), findsOneWidget);

    await tester.tap(find.text('Group column'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
  });
}
