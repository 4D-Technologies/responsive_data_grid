import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;

  const _Person(this.id, this.name);
}

List<GridColumn<_Person, dynamic>> _columns({bool showAggregations = false}) {
  return [
    IntColumn<_Person>(
      fieldName: 'id',
      header: ColumnHeader(
        text: 'Id',
        showFilter: true,
        showAggregations: showAggregations,
      ),
      value: (row) => row.id,
      xsCols: 12,
    ),
  ];
}

void main() {
  testWidgets('PagingMode.none loads up to maximumRows, not pageSize', (
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
              pagingMode: PagingMode.none,
              pageSize: 10,
              maximumRows: 123,
              loadData: (criteria) async {
                seen = criteria;
                return ListResponse<_Person>(
                  totalCount: 1,
                  items: const [_Person(1, 'Ada')],
                  groups: const [],
                  aggregates: const [],
                );
              },
              columns: _columns(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(seen, isNotNull);
    expect(seen!.take, 123);
    expect(seen!.skip, 0);
    expect(find.byType(PagerWidget), findsNothing);
  });

  testWidgets('aggregations stay hidden when allowAggregations is false', (
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
              allowAggregations: false,
              items: const [_Person(1, 'Ada')],
              columns: _columns(showAggregations: true),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byIcon(Icons.menu).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Aggregates'), findsNothing);
  });

  testWidgets('aggregations appear when allowAggregations is true', (
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
              items: const [_Person(1, 'Ada')],
              columns: _columns(showAggregations: true),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byIcon(Icons.menu).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Aggregates'), findsOneWidget);
  });
}
