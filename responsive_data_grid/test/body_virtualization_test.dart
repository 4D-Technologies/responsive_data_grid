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
  testWidgets('large paged lists do not build every row', (tester) async {
    tester.view.physicalSize = const Size(900, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 360,
            child: ResponsiveDataGrid<_Person>.clientSide(
              height: 320,
              pagingMode: PagingMode.pager,
              pageSize: 400,
              items: [for (var i = 0; i < 400; i++) _Person(i, 'Row $i')],
              columns: [
                IntColumn<_Person>(
                  fieldName: 'id',
                  header: const ColumnHeader(text: 'Id'),
                  value: (row) => row.id,
                  xsCols: 4,
                ),
                StringColumn<_Person>(
                  fieldName: 'name',
                  header: const ColumnHeader(text: 'Name'),
                  value: (row) => row.name,
                  xsCols: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final built = find.byType(DataGridRowWidget<_Person>).evaluate().length;
    expect(built, greaterThan(0));
    expect(built, lessThan(80));
  });

  testWidgets('loading overlay keeps the header mounted', (tester) async {
    tester.view.physicalSize = const Size(900, 500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var completer = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 400,
            child: ResponsiveDataGrid<_Person>.serverSide(
              height: 360,
              pagingMode: PagingMode.pager,
              loadData: (criteria) async {
                if (!completer) {
                  await Future<void>.delayed(const Duration(milliseconds: 200));
                }
                return ListResponse<_Person>(
                  totalCount: 1,
                  items: const [_Person(1, 'Ada')],
                  groups: const [],
                  aggregates: const [],
                );
              },
              columns: [
                StringColumn<_Person>(
                  fieldName: 'name',
                  header: const ColumnHeader(text: 'Name'),
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
    expect(find.text('Name'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('Name'), findsOneWidget);
  });
}
