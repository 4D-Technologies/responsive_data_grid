import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;
  const _Person(this.id, this.name);
}

void main() {
  testWidgets(
    'filter refresh replaces page 1 and drops stale later pages (#135)',
    (tester) async {
      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final loads = <LoadCriteria>[];
      final all = [
        for (var i = 1; i <= 3; i++) _Person(i, 'P$i'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 600,
              child: ResponsiveDataGrid<_Person>.serverSide(
                height: 500,
                pagingMode: PagingMode.pager,
                pageSize: 1,
                filterable: FilterableMode.row,
                loadData: (criteria) async {
                  loads.add(criteria);
                  final filtered = criteria.filterBy.isEmpty
                      ? all
                      : all.where((p) => p.name == 'P1').toList();
                  final skip = criteria.skip ?? 0;
                  final take = criteria.take ?? 1;
                  final page = filtered.skip(skip).take(take).toList();
                  return ListResponse<_Person>(
                    totalCount: filtered.length,
                    items: page,
                    groups: const [],
                    aggregates: const [],
                  );
                },
                columns: [
                  StringColumn<_Person>(
                    fieldName: 'name',
                    header: const ColumnHeader(text: 'Name', showFilter: true),
                    value: (row) => row.name,
                    xsCols: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('P1'), findsWidgets);

      // Page 2 while unfiltered.
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pumpAndSettle();
      expect(find.text('P2'), findsWidgets);
      expect(loads.last.skip, 1);

      // Filter to P1 only — refresh must not leave P2 cached for page 2.
      final state = tester.state<ResponsiveDataGridState<_Person>>(
        find.byType(ResponsiveDataGrid<_Person>),
      );
      state.widget.columns.first.filterRules.criteria = FilterCriteria<String>(
        fieldName: 'name',
        op: Operators.and,
        logicalOperator: Logic.equals,
        values: ['P1'],
      );
      await state.refreshData();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      // Body cell for P2 must be gone; filter field may still show typed text.
      expect(find.text('P2'), findsNothing);
      expect(
        loads.last.filterBy.single.values.single,
        'P1',
      );
      expect(loads.last.skip ?? 0, 0);
    },
  );
}
