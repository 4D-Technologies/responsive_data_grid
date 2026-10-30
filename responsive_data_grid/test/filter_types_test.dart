import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;
  final bool accepted;
  final double score;
  final num rank;
  final DateTime born;
  final Duration shift;
  final TimeOfDay start;

  _Person(
    this.name, {
    required this.accepted,
    required this.score,
    required this.rank,
    required this.born,
    required this.shift,
    required this.start,
  });
}

final _ada = _Person(
  'Ada',
  accepted: true,
  score: 9.5,
  rank: 1,
  born: DateTime(2020, 1, 15),
  shift: const Duration(hours: 8),
  start: const TimeOfDay(hour: 9, minute: 0),
);

final _grace = _Person(
  'Grace',
  accepted: false,
  score: 4.0,
  rank: 2,
  born: DateTime(2021, 6, 1),
  shift: const Duration(hours: 4),
  start: const TimeOfDay(hour: 17, minute: 0),
);

List<GridColumn<_Person, dynamic>> _columns() {
  return [
    StringColumn<_Person>(
      fieldName: 'name',
      header: const ColumnHeader(text: 'Name'),
      value: (row) => row.name,
      xsCols: 4,
    ),
    BoolColumn<_Person>(
      fieldName: 'accepted',
      header: const ColumnHeader(text: 'Accepted', showFilter: true),
      value: (row) => row.accepted,
      xsCols: 4,
    ),
    DoubleColumn<_Person>(
      fieldName: 'score',
      header: const ColumnHeader(text: 'Score', showFilter: true),
      value: (row) => row.score,
      xsCols: 4,
    ),
    NumColumn<_Person>(
      fieldName: 'rank',
      header: const ColumnHeader(text: 'Rank', showFilter: true),
      value: (row) => row.rank,
      xsCols: 4,
    ),
    DateTimeColumn<_Person>(
      fieldName: 'born',
      header: const ColumnHeader(text: 'Born', showFilter: true),
      value: (row) => row.born,
      xsCols: 4,
    ),
    DurationColumn<_Person>(
      fieldName: 'shift',
      header: const ColumnHeader(text: 'Shift', showFilter: true),
      value: (row) => row.shift,
      xsCols: 4,
    ),
    TimeOfDayColumn<_Person>(
      fieldName: 'start',
      header: const ColumnHeader(text: 'Start', showFilter: true),
      value: (row) => row.start,
      xsCols: 4,
    ),
  ];
}

Future<GlobalKey<ResponsiveDataGridState<_Person>>> _pump(
  WidgetTester tester,
) async {
  tester.view.physicalSize = const Size(1100, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final key = GlobalKey<ResponsiveDataGridState<_Person>>();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 1100,
          height: 700,
          child: ResponsiveDataGrid<_Person>.clientSide(
            key: key,
            height: 600,
            pagingMode: PagingMode.pager,
            items: [_ada, _grace],
            columns: _columns(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return key;
}

Future<void> _apply(
  WidgetTester tester,
  GlobalKey<ResponsiveDataGridState<_Person>> key,
  FilterCriteria<dynamic> filter,
) async {
  await key.currentState!.updateFilterCriteria([filter]);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> _clear(
  WidgetTester tester,
  GlobalKey<ResponsiveDataGridState<_Person>> key,
) async {
  for (final column in key.currentState!.widget.columns) {
    column.filterRules.criteria = null;
  }
  await key.currentState!.refreshData();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void _expectOnlyAda(WidgetTester tester) {
  expect(find.text('Ada'), findsWidgets);
  expect(find.text('Grace'), findsNothing);
}

void _expectBoth(WidgetTester tester) {
  expect(find.text('Ada'), findsWidgets);
  expect(find.text('Grace'), findsWidgets);
}

void main() {
  group('every column filter type applies and clears', () {
    testWidgets('bool', (tester) async {
      final key = await _pump(tester);
      _expectBoth(tester);
      await _apply(
        tester,
        key,
        const FilterCriteria<bool>(
          fieldName: 'accepted',
          op: Operators.and,
          logicalOperator: Logic.equals,
          values: [true],
        ),
      );
      _expectOnlyAda(tester);
      await _clear(tester, key);
      _expectBoth(tester);
    });

    testWidgets('double', (tester) async {
      final key = await _pump(tester);
      await _apply(
        tester,
        key,
        const FilterCriteria<double>(
          fieldName: 'score',
          op: Operators.and,
          logicalOperator: Logic.equals,
          values: [9.5],
        ),
      );
      _expectOnlyAda(tester);
      await _clear(tester, key);
      _expectBoth(tester);
    });

    testWidgets('num', (tester) async {
      final key = await _pump(tester);
      await _apply(
        tester,
        key,
        const FilterCriteria<num>(
          fieldName: 'rank',
          op: Operators.and,
          logicalOperator: Logic.equals,
          values: [1],
        ),
      );
      _expectOnlyAda(tester);
      await _clear(tester, key);
      _expectBoth(tester);
    });

    testWidgets('datetime', (tester) async {
      final key = await _pump(tester);
      await _apply(
        tester,
        key,
        FilterCriteria<DateTime>(
          fieldName: 'born',
          op: Operators.and,
          logicalOperator: Logic.equals,
          values: [_ada.born],
        ),
      );
      _expectOnlyAda(tester);
      await _clear(tester, key);
      _expectBoth(tester);
    });

    testWidgets('duration', (tester) async {
      final key = await _pump(tester);
      await _apply(
        tester,
        key,
        const FilterCriteria<Duration>(
          fieldName: 'shift',
          op: Operators.and,
          logicalOperator: Logic.equals,
          values: [Duration(hours: 8)],
        ),
      );
      _expectOnlyAda(tester);
      await _clear(tester, key);
      _expectBoth(tester);
    });

    testWidgets('timeofday', (tester) async {
      final key = await _pump(tester);
      await _apply(
        tester,
        key,
        const FilterCriteria<TimeOfDay>(
          fieldName: 'start',
          op: Operators.and,
          logicalOperator: Logic.equals,
          values: [TimeOfDay(hour: 9, minute: 0)],
        ),
      );
      _expectOnlyAda(tester);
      await _clear(tester, key);
      _expectBoth(tester);
    });
  });
}
