import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;

  const _Person(this.id, this.name);
}

void main() {
  testWidgets('rowDecoration tints matching rows', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const highlight = Color(0xFFFFCCCC);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 500,
            child: ResponsiveDataGrid<_Person>.clientSide(
              height: 400,
              pagingMode: PagingMode.pager,
              rowDecoration: (item) => item.id == 1
                  ? const BoxDecoration(color: highlight)
                  : null,
              items: const [_Person(1, 'Ada'), _Person(2, 'Grace')],
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

    final decorations = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .where((decoration) => decoration.color == highlight);
    expect(decorations, isNotEmpty);
  });

  testWidgets('cellDecoration tints a single column', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const highlight = Color(0xFFCCFFCC);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 500,
            child: ResponsiveDataGrid<_Person>.clientSide(
              height: 400,
              pagingMode: PagingMode.pager,
              cellDecoration: (item, column) =>
                  column.fieldName == 'name' && item.id == 2
                  ? const BoxDecoration(color: highlight)
                  : null,
              items: const [_Person(1, 'Ada'), _Person(2, 'Grace')],
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

    final decorations = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .where((decoration) => decoration.color == highlight);
    expect(decorations, isNotEmpty);
  });
}
