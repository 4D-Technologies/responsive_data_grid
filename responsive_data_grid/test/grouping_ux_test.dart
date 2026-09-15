import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;
  final int age;

  const _Person(this.name, this.age);
}

Future<void> _pump(WidgetTester tester, {int groupIndent = 15}) async {
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
            allowGrouping: true,
            groupIndent: groupIndent,
            groupPanel: GroupPanelDisplay.always,
            initialLoadCriteria: LoadCriteria(
              groupBy: [
                GroupCriteria(
                  fieldName: 'name',
                  direction: OrderDirections.ascending,
                  aggregates: const [],
                ),
              ],
            ),
            items: const [
              _Person('Ada', 36),
              _Person('Ada', 40),
              _Person('Grace', 42),
            ],
            columns: [
              StringColumn<_Person>(
                fieldName: 'name',
                header: const ColumnHeader(text: 'Name', showOrderBy: true),
                value: (row) => row.name,
                xsCols: 6,
              ),
              IntColumn<_Person>(
                fieldName: 'age',
                header: const ColumnHeader(text: 'Age'),
                value: (row) => row.age,
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
}

void main() {
  test('gridMatchesGroupValue covers dates, enums, and nums', () {
    expect(gridMatchesGroupValue(1, '1'), isTrue);
    expect(gridMatchesGroupValue(1.0, '1'), isTrue);
    expect(
      gridMatchesGroupValue(DateTime.utc(2020, 1, 2), '2020-01-02T00:00:00.000Z'),
      isTrue,
    );
  });

  testWidgets('groups can collapse and expand', (tester) async {
    await _pump(tester);
    expect(find.text('36'), findsOneWidget);
    expect(find.text('40'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('rdg-group-toggle-name-Ada')));
    await tester.pump();

    expect(find.text('36'), findsNothing);
    expect(find.text('40'), findsNothing);
    expect(find.text('Ada'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('rdg-group-toggle-name-Ada')));
    await tester.pump();
    expect(find.text('36'), findsOneWidget);
  });

  testWidgets('nested group headers honor groupIndent', (tester) async {
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
              allowGrouping: true,
              groupIndent: 24,
              groupPanel: GroupPanelDisplay.always,
              initialLoadCriteria: LoadCriteria(
                groupBy: [
                  GroupCriteria(
                    fieldName: 'name',
                    direction: OrderDirections.ascending,
                    aggregates: const [],
                  ),
                  GroupCriteria(
                    fieldName: 'age',
                    direction: OrderDirections.ascending,
                    aggregates: const [],
                  ),
                ],
              ),
              items: const [_Person('Ada', 36), _Person('Ada', 40)],
              columns: [
                StringColumn<_Person>(
                  fieldName: 'name',
                  header: const ColumnHeader(text: 'Name'),
                  value: (row) => row.name,
                  xsCols: 6,
                ),
                IntColumn<_Person>(
                  fieldName: 'age',
                  header: const ColumnHeader(text: 'Age'),
                  value: (row) => row.age,
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

    final top = tester.getTopLeft(
      find.descendant(
        of: find.byType(GridGroupHeader),
        matching: find.text('Ada'),
      ),
    );
    final nested = tester.getTopLeft(
      find.descendant(
        of: find.byType(GridGroupHeader),
        matching: find.text('36'),
      ),
    );
    expect(nested.dx, closeTo(top.dx + 24, 2));
  });
}
