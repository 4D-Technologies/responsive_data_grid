import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;

  const _Person(this.name);
}

void main() {
  testWidgets('column menu fits a phone viewport without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 844,
            child: ResponsiveDataGrid<_Person>.clientSide(
              height: 400,
              pagingMode: PagingMode.pager,
              items: const [_Person('Ada'), _Person('Grace')],
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

    await tester.tap(find.byIcon(Icons.menu).first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(LocalizedMessages.apply), findsOneWidget);
    expect(find.text(LocalizedMessages.clear), findsOneWidget);
    expect(find.byType(MenuAnchor), findsWidgets);
  });

  testWidgets('tapping apply dismisses the column menu', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 844,
            child: ResponsiveDataGrid<_Person>.clientSide(
              height: 400,
              pagingMode: PagingMode.pager,
              items: const [_Person('Ada')],
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

    await tester.tap(find.byIcon(Icons.menu).first);
    await tester.pumpAndSettle();
    expect(find.text(LocalizedMessages.apply), findsOneWidget);

    await tester.tap(find.text(LocalizedMessages.apply));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(LocalizedMessages.apply), findsNothing);
  });
}
