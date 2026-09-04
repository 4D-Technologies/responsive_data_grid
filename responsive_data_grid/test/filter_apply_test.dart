import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;
  final bool accepted;

  const _Person(this.name, this.accepted);
}

void main() {
  testWidgets('string column filter apply actually filters rows', (
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
              items: const [
                _Person('Ada', true),
                _Person('Grace', false),
              ],
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

    expect(find.text('Ada'), findsWidgets);
    expect(find.text('Grace'), findsWidgets);

    await tester.tap(find.byIcon(Icons.menu).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(DropdownButtonFormField<Logic?>));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text(Logic.contains.toString()).last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextFormField), 'Ada');
    await tester.pump();

    await tester.tap(find.text(LocalizedMessages.apply));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    expect(find.text('Ada'), findsWidgets);
    expect(find.text('Grace'), findsNothing);
  });
}
