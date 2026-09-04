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
  testWidgets('server loadData receives column aggregates in LoadCriteria', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    LoadCriteria? seen;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 600,
            child: ResponsiveDataGrid<_Person>.serverSide(
              height: 600,
              pagingMode: PagingMode.pager,
              pageSize: 25,
              allowAggregations: true,
              loadData: (criteria) async {
                seen = criteria;
                return ListResponse<_Person>(
                  totalCount: 1,
                  items: const [_Person(1, 'Ada')],
                  groups: const [],
                  aggregates: const [],
                );
              },
              columns: [
                IntColumn<_Person>(
                  fieldName: 'id',
                  header: const ColumnHeader(
                    text: 'Id',
                    showAggregations: true,
                  ),
                  value: (row) => row.id,
                  xsCols: 6,
                  aggregations: const [
                    AggregateCriteria(
                      fieldName: 'id',
                      aggregation: Aggregations.sum,
                    ),
                  ],
                ),
                StringColumn<_Person>(
                  fieldName: 'name',
                  header: const ColumnHeader(text: 'Name'),
                  value: (row) => row.name,
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

    expect(seen, isNotNull);
    expect(seen!.aggregates, isNotNull);
    expect(seen!.aggregates, isNotEmpty);
    expect(seen!.aggregates!.first.fieldName, 'id');
    expect(seen!.aggregates!.first.aggregation, Aggregations.sum);
    expect(seen!.take, 25);
    expect(seen!.skip, 0);
  });
}
