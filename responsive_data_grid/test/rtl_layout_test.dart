import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;

  const _Person(this.id, this.name);
}

Future<void> _pump(
  WidgetTester tester, {
  required TextDirection direction,
  bool freezeName = false,
}) async {
  tester.view.physicalSize = const Size(800, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: SizedBox(
            width: 800,
            height: 500,
            child: ResponsiveDataGrid<_Person>.clientSide(
              height: 400,
              pagingMode: PagingMode.pager,
              items: const [_Person(1, 'Ada')],
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
                  frozen: freezeName,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('RTL places the first column on the right', (tester) async {
    await _pump(tester, direction: TextDirection.rtl);

    final id = tester.getTopLeft(find.text('Id').first);
    final name = tester.getTopLeft(find.text('Name').first);
    expect(id.dx, greaterThan(name.dx));
  });

  testWidgets('RTL pins frozen columns to the visual start', (tester) async {
    await _pump(tester, direction: TextDirection.rtl, freezeName: true);

    final name = tester.getRect(find.text('Name').first);
    expect(name.right, closeTo(800, 40));
  });

  testWidgets('numeric cells default to end alignment', (tester) async {
    await _pump(tester, direction: TextDirection.ltr);
    final idCell = tester.getRect(find.text('1').first);
    final header = tester.getRect(
      find.byKey(const ValueKey('rdg-header-cell-id')),
    );
    expect(idCell.right, greaterThan(header.center.dx));
  });
}
