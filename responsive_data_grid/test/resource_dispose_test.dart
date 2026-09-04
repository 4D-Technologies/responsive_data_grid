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
    'disposing an infinite-scroll grid does not throw after cache clear',
    (tester) async {
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
                pagingMode: PagingMode.infiniteScroll,
                items: const [
                  _Person(1, 'Ada'),
                  _Person(2, 'Grace'),
                ],
                columns: [
                  IntColumn<_Person>(
                    fieldName: 'id',
                    header: const ColumnHeader(
                      text: 'Id',
                      showFilter: true,
                    ),
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

      expect(find.text('Ada'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('disposing an int filter menu does not throw', (tester) async {
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
              items: const [_Person(1, 'Ada')],
              columns: [
                IntColumn<_Person>(
                  fieldName: 'id',
                  header: const ColumnHeader(text: 'Id', showFilter: true),
                  value: (row) => row.id,
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

    await tester.tap(find.byIcon(Icons.menu).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
