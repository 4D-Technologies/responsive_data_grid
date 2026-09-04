import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final DateTime when;
  final TimeOfDay time;

  const _Person(this.id, this.when, this.time);
}

void main() {
  test('DateTimeColumn does not offer sum', () {
    final column = DateTimeColumn<_Person>(
      fieldName: 'when',
      value: (row) => row.when,
    );

    final offered = column
        .getAggregations(selected: const [], update: (_, _) {})
        .map((chooser) => chooser.aggregation)
        .toList();

    expect(offered, isNot(contains(Aggregations.sum)));
    expect(offered, containsAll([
      Aggregations.minimum,
      Aggregations.maximum,
    ]));
  });

  test('TimeOfDayColumn does not offer sum', () {
    final column = TimeOfDayColumn<_Person>(
      fieldName: 'time',
      value: (row) => row.time,
    );

    final offered = column
        .getAggregations(selected: const [], update: (_, _) {})
        .map((chooser) => chooser.aggregation)
        .toList();

    expect(offered, isNot(contains(Aggregations.sum)));
  });

  testWidgets('grid footer shows the formatted aggregate result', (
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
              height: 600,
              pagingMode: PagingMode.pager,
              allowAggregations: true,
              items: [
                _Person(1, DateTime(2024, 1, 1), const TimeOfDay(hour: 8, minute: 0)),
                _Person(2, DateTime(2024, 1, 2), const TimeOfDay(hour: 9, minute: 0)),
                _Person(3, DateTime(2024, 1, 3), const TimeOfDay(hour: 10, minute: 0)),
              ],
              columns: [
                IntColumn<_Person>(
                  fieldName: 'id',
                  header: const ColumnHeader(
                    text: 'Id',
                    showAggregations: true,
                  ),
                  value: (row) => row.id,
                  xsCols: 12,
                  aggregations: const [
                    AggregateCriteria(
                      fieldName: 'id',
                      aggregation: Aggregations.sum,
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

    expect(find.byType(GridFooter<_Person>), findsOneWidget);
    expect(find.textContaining('6'), findsWidgets);
  });
}
