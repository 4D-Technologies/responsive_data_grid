import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;
  final bool active;
  final DateTime dob;

  const _Person(
    this.id,
    this.name, {
    this.active = true,
    required this.dob,
  });
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
            items: [
              _Person(1, 'Ada', active: true, dob: DateTime(1990, 1, 1)),
              _Person(2, 'Grace', active: false, dob: DateTime(1991, 2, 2)),
              _Person(3, 'Alan', active: true, dob: DateTime(1992, 3, 3)),
            ],
            columns: [
              IntColumn<_Person>(
                fieldName: 'id',
                header: ColumnHeader(text: 'Id', showFilter: idFilter),
                value: (row) => row.id,
                xsCols: 3,
              ),
              StringColumn<_Person>(
                fieldName: 'name',
                header: ColumnHeader(text: 'Name', showFilter: nameFilter),
                value: (row) => row.name,
                xsCols: 3,
              ),
              BoolColumn<_Person>(
                fieldName: 'active',
                header: const ColumnHeader(text: 'Active', showFilter: true),
                value: (row) => row.active,
                trueText: 'Yes',
                falseText: 'No',
                xsCols: 3,
              ),
              DateTimeColumn<_Person>(
                fieldName: 'dob',
                header: const ColumnHeader(text: 'DOB', showFilter: true),
                value: (row) => row.dob,
                xsCols: 3,
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
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Ada'), findsWidgets);
    expect(find.text('Grace'), findsNothing);
    expect(find.text('Alan'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('rdg-filter-row-name')),
      '',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

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
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Grace'), findsOneWidget);
    expect(find.text('Ada'), findsNothing);

    await tester.enterText(find.byKey(const ValueKey('rdg-filter-row-id')), '');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Ada'), findsWidgets);
    expect(find.text('Grace'), findsOneWidget);
  });

  testWidgets('row mode still shows filters in the column menu', (
    tester,
  ) async {
    await _pump(tester, filterable: FilterableMode.row);
    await tester.tap(find.byKey(const ValueKey('rdg-header-menu-name')));
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<Logic?>), findsOneWidget);
  });

  testWidgets('row mode paints bool and date editors', (tester) async {
    await _pump(tester, filterable: FilterableMode.row);
    expect(find.byKey(const ValueKey('rdg-filter-row-active')), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-filter-row-dob')), findsOneWidget);
  });

  testWidgets('last column header, filter, and body stay in view', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('DOB'), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-header-cell-dob')), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-header-menu-dob')), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-filter-row-dob')), findsOneWidget);
    final header = tester.getRect(
      find.byKey(const ValueKey('rdg-header-cell-dob')),
    );
    expect(header.width, greaterThan(80));
    expect(header.left, lessThan(800));
  });

  testWidgets('typed score column keeps header text and values', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: ResponsiveDataGrid<_Person>.clientSide(
              items: [
                _Person(1, 'Ada', active: true, dob: DateTime(1990, 1, 1)),
                _Person(2, 'Grace', active: false, dob: DateTime(1991, 2, 2)),
              ],
              columns: [
                StringColumn<_Person>(
                  xsCols: 3,
                  fieldName: 'name',
                  header: const ColumnHeader(
                    text: 'Name',
                    showFilter: true,
                    showOrderBy: true,
                  ),
                  value: (row) => row.name,
                ),
                BoolColumn<_Person>(
                  xsCols: 2,
                  fieldName: 'active',
                  header: const ColumnHeader(
                    text: 'Accepted',
                    showFilter: true,
                    showOrderBy: true,
                  ),
                  value: (row) => row.active,
                  trueText: 'Yes',
                  falseText: 'No',
                ),
                DateTimeColumn<_Person>(
                  xsCols: 4,
                  fieldName: 'dob',
                  header: const ColumnHeader(
                    text: 'Date of Birth',
                    showFilter: true,
                    showOrderBy: true,
                  ),
                  value: (row) => row.dob,
                ),
                IntColumn<_Person>(
                  xsCols: 3,
                  fieldName: 'id',
                  header: const ColumnHeader(
                    text: 'Score',
                    showFilter: true,
                    showOrderBy: true,
                  ),
                  value: (row) => row.id,
                ),
              ],
              pageSize: 10,
              pagingMode: PagingMode.pager,
              sizing: GridSizing.fill,
              filterable: FilterableMode.row,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Score'), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-header-cell-id')), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-header-menu-id')), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-filter-row-id')), findsOneWidget);
    final scoreHeader = tester.getRect(
      find.byKey(const ValueKey('rdg-header-cell-id')),
    );
    expect(scoreHeader.width, greaterThan(120));
    expect(find.text('1'), findsWidgets);
    expect(find.text('2'), findsWidgets);
  });

  testWidgets('double column body values paint in the last column', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: ResponsiveDataGrid<_Person>.clientSide(
              items: [
                _Person(1, 'Ada', active: true, dob: DateTime(1990, 1, 1)),
                _Person(2, 'Grace', active: false, dob: DateTime(1991, 2, 2)),
              ],
              columns: [
                StringColumn<_Person>(
                  xsCols: 3,
                  fieldName: 'name',
                  header: const ColumnHeader(text: 'Name', showFilter: true),
                  value: (row) => row.name,
                ),
                BoolColumn<_Person>(
                  xsCols: 2,
                  fieldName: 'active',
                  header: const ColumnHeader(text: 'Accepted', showFilter: true),
                  value: (row) => row.active,
                  trueText: 'Yes',
                  falseText: 'No',
                ),
                DateTimeColumn<_Person>(
                  xsCols: 4,
                  fieldName: 'dob',
                  header: const ColumnHeader(
                    text: 'Date of Birth',
                    showFilter: true,
                  ),
                  value: (row) => row.dob,
                ),
                DoubleColumn<_Person>(
                  xsCols: 3,
                  fieldName: 'score',
                  header: const ColumnHeader(
                    text: 'Score',
                    showFilter: true,
                    showOrderBy: true,
                  ),
                  value: (row) => row.id + 0.5,
                ),
              ],
              pageSize: 10,
              pagingMode: PagingMode.pager,
              sizing: GridSizing.fill,
              filterable: FilterableMode.row,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Score'), findsOneWidget);
    expect(find.text('1.5'), findsOneWidget);
    expect(find.text('2.5'), findsOneWidget);
    final score = tester.getRect(
      find.byKey(const ValueKey('rdg-header-cell-score')),
    );
    expect(score.width, greaterThan(120));
  });

  testWidgets('menu mode has no filter row and opens typed editors', (
    tester,
  ) async {
    await _pump(tester, filterable: FilterableMode.menu);
    expect(find.byKey(const ValueKey('rdg-filter-row')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('rdg-header-menu-active')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsOneWidget);
  });

  testWidgets('bool row editor apply and clear', (tester) async {
    await _pump(tester);
    await tester.tap(find.byKey(const ValueKey('rdg-filter-row-active')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes').last);
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsWidgets);
    expect(find.text('Alan'), findsWidgets);
    expect(find.text('Grace'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('rdg-filter-row-active')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filter').last);
    await tester.pumpAndSettle();
    expect(find.text('Grace'), findsOneWidget);
  });

  testWidgets('date-only row editor opens a date picker', (tester) async {
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
              filterable: FilterableMode.row,
              items: [
                _Person(1, 'Ada', active: true, dob: DateTime(1990, 1, 1)),
                _Person(2, 'Grace', active: false, dob: DateTime(1991, 2, 2)),
              ],
              columns: [
                StringColumn<_Person>(
                  fieldName: 'name',
                  header: const ColumnHeader(text: 'Name', showFilter: true),
                  value: (row) => row.name,
                  xsCols: 6,
                ),
                DateTimeColumn<_Person>(
                  fieldName: 'dob',
                  header: const ColumnHeader(text: 'DOB', showFilter: true),
                  value: (row) => row.dob,
                  xsCols: 6,
                  filterRules: DateTimeFilterRules(
                    filterType: DateTimeFilterTypes.DateOnly,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const ValueKey('rdg-filter-row-dob')));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(find.byType(TimePickerDialog), findsNothing);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsNothing);
    expect(find.text('Ada'), findsNothing);
    expect(find.text('Grace'), findsNothing);
  });

  testWidgets('date-time row editor opens date then time pickers', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.byKey(const ValueKey('rdg-filter-row-dob')));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
  });

  testWidgets('time-only datetime row editor opens a time picker', (
    tester,
  ) async {
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
              filterable: FilterableMode.row,
              items: [
                _Person(1, 'Ada', active: true, dob: DateTime(1990, 1, 1)),
              ],
              columns: [
                DateTimeColumn<_Person>(
                  fieldName: 'dob',
                  header: const ColumnHeader(text: 'DOB', showFilter: true),
                  value: (row) => row.dob,
                  xsCols: 12,
                  filterRules: DateTimeFilterRules(
                    filterType: DateTimeFilterTypes.TimeOnly,
                    firstDate: DateTime(1980),
                    lastDate: DateTime(2000),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const ValueKey('rdg-filter-row-dob')));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    expect(find.byType(DatePickerDialog), findsNothing);
  });

  testWidgets('duration and enum row editors apply and clear', (tester) async {
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1100,
            height: 600,
            child: ResponsiveDataGrid<_Shift>.clientSide(
              height: 500,
              pagingMode: PagingMode.pager,
              filterable: FilterableMode.row,
              items: const [
                _Shift('Ada', Duration(minutes: 480), _Team.red),
                _Shift('Grace', Duration(minutes: 240), _Team.blue),
              ],
              columns: [
                StringColumn<_Shift>(
                  fieldName: 'name',
                  header: const ColumnHeader(text: 'Name', showFilter: true),
                  value: (row) => row.name,
                  xsCols: 4,
                ),
                DurationColumn<_Shift>(
                  fieldName: 'shift',
                  header: const ColumnHeader(text: 'Shift', showFilter: true),
                  value: (row) => row.shift,
                  xsCols: 4,
                ),
                EnumColumn<_Shift, _Team>(
                  fieldName: 'team',
                  header: const ColumnHeader(text: 'Team', showFilter: true),
                  values: _Team.values,
                  valueText: (e) => e.name,
                  value: (row) => row.team,
                  xsCols: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final shiftField = tester.widget<TextField>(
      find.byKey(const ValueKey('rdg-filter-row-shift')),
    );
    expect(shiftField.keyboardType, TextInputType.number);

    await tester.enterText(
      find.byKey(const ValueKey('rdg-filter-row-shift')),
      '480',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Ada'), findsWidgets);
    expect(find.text('Grace'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('rdg-filter-row-shift')),
      '',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Grace'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('rdg-filter-row-team')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('red').last);
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsWidgets);
    expect(find.text('Grace'), findsNothing);
  });
}

enum _Team { red, blue }

class _Shift {
  final String name;
  final Duration shift;
  final _Team team;

  const _Shift(this.name, this.shift, this.team);
}
