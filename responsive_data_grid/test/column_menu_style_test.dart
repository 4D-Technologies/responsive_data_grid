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
  testWidgets('column menu actions are on-surface and left-aligned', (
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
            height: 700,
            child: ResponsiveDataGrid<_Person>.clientSide(
              height: 500,
              pagingMode: PagingMode.pager,
              layoutMode: GridLayoutMode.table,
              filterable: FilterableMode.menu,
              sortable: SortableOptions.single,
              items: const [_Person(1, 'Ada')],
              columns: [
                StringColumn<_Person>(
                  fieldName: 'name',
                  header: const ColumnHeader(
                    text: 'Name',
                    showFilter: true,
                    showOrderBy: true,
                  ),
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

    await tester.tap(find.byKey(const ValueKey('rdg-header-menu-name')));
    await tester.pumpAndSettle();

    final sort = find.text('Sort ascending');
    expect(sort, findsOneWidget);

    final scheme = ColorScheme.of(
      tester.element(find.byType(MaterialApp)),
    );
    final text = tester.widget<Text>(sort);
    final color = text.style?.color ??
        DefaultTextStyle.of(tester.element(sort)).style.color;
    expect(color, isNot(scheme.primary));

    final menu = tester.getRect(find.text('Sort'));
    final label = tester.getTopLeft(sort);
    expect(label.dx, lessThan(menu.left + 80));
  });

  testWidgets('search filters rows', (tester) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 700,
            child: ResponsiveDataGrid<_Person>.clientSide(
              height: 500,
              pagingMode: PagingMode.pager,
              toolbar: const GridToolbar(search: true),
              items: const [_Person(1, 'Ada'), _Person(2, 'Grace')],
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
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Grace'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('rdg-toolbar-search')), 'Ada');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Ada'), findsWidgets);
    expect(find.text('Grace'), findsNothing);
  });
}
