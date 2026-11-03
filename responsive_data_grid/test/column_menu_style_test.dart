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

    expect(find.text(GridLocalizations.en.hideColumn), findsOneWidget);
    expect(find.text(GridLocalizations.en.pinLeft), findsOneWidget);
    expect(find.text(GridLocalizations.en.autosizeColumn), findsOneWidget);
    final section = tester.getRect(find.text(GridLocalizations.en.columnMenu));
    final hide = tester.getRect(find.text(GridLocalizations.en.hideColumn));
    final autosize = tester.getRect(
      find.text(GridLocalizations.en.autosizeColumn),
    );
    final apply = tester.getRect(find.text(GridLocalizations.en.apply));
    expect(hide.top, greaterThan(section.bottom - 0.5));
    expect(autosize.top, greaterThan(hide.bottom - 0.5));
    expect(apply.top, greaterThan(autosize.bottom - 0.5));

    final any = find.text(GridLocalizations.en.any);
    expect(any, findsOneWidget);
    final anyField = find.ancestor(
      of: any,
      matching: find.byType(InputDecorator),
    );
    expect(anyField, findsOneWidget);
    final sortButton = find.ancestor(
      of: sort,
      matching: find.byType(TextButton),
    );
    final anyRect = tester.getRect(anyField);
    final sortRect = tester.getRect(sortButton);
    expect(anyRect.height, lessThanOrEqualTo(sortRect.height + 4));
    final anyStyle =
        tester.widget<Text>(any).style ??
        DefaultTextStyle.of(tester.element(any)).style;
    final sortTextStyle =
        text.style ?? DefaultTextStyle.of(tester.element(sort)).style;
    expect(
      anyStyle.fontSize ?? 14,
      lessThanOrEqualTo((sortTextStyle.fontSize ?? 14) + 1),
    );
    final decorator = tester.widget<InputDecorator>(anyField);
    expect(decorator.decoration.filled, isFalse);

    final autosizeButton = tester.getRect(
      find.ancestor(
        of: find.text(GridLocalizations.en.autosizeColumn),
        matching: find.byType(TextButton),
      ),
    );
    final clearButton = tester.getRect(
      find.ancestor(
        of: find.text(GridLocalizations.en.clear),
        matching: find.byType(TextButton),
      ),
    );
    expect(clearButton.top - autosizeButton.bottom, lessThan(16));
    expect(find.text(GridLocalizations.en.aggregates), findsNothing);
  });

  testWidgets(
    'aggregates section stays off unless the column header asks for it',
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
              height: 700,
              child: ResponsiveDataGrid<_Person>.clientSide(
                height: 500,
                pagingMode: PagingMode.pager,
                layoutMode: GridLayoutMode.table,
                filterable: FilterableMode.menu,
                sortable: SortableOptions.single,
                allowAggregations: true,
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

      expect(find.text(GridLocalizations.en.aggregates), findsNothing);
      expect(find.byType(Switch), findsNothing);
    },
  );

  testWidgets(
    'aggregates section shows choosers when the column header asks',
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
              height: 700,
              child: ResponsiveDataGrid<_Person>.clientSide(
                height: 500,
                pagingMode: PagingMode.pager,
                layoutMode: GridLayoutMode.table,
                filterable: FilterableMode.menu,
                sortable: SortableOptions.single,
                allowAggregations: true,
                items: const [_Person(1, 'Ada')],
                columns: [
                  StringColumn<_Person>(
                    fieldName: 'name',
                    header: const ColumnHeader(
                      text: 'Name',
                      showFilter: true,
                      showOrderBy: true,
                      showAggregations: true,
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

      expect(find.text(GridLocalizations.en.aggregates), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      final section = tester.getRect(
        find.text(GridLocalizations.en.aggregates),
      );
      final toggle = tester.getRect(find.byType(Switch));
      final apply = tester.getRect(find.text(GridLocalizations.en.apply));
      expect(toggle.top, greaterThan(section.bottom - 0.5));
      expect(toggle.bottom, lessThanOrEqualTo(apply.top + 0.5));
    },
  );

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

  testWidgets(
    'kitchen-sink chrome keeps Clear and Apply inside the window',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Responsive Data Grid')),
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: ResponsiveDataGrid<_Person>.clientSide(
                items: const [_Person(1, 'Ada')],
                pageSize: 20,
                pagingMode: PagingMode.pager,
                layoutMode: GridLayoutMode.table,
                filterable: FilterableMode.menu,
                sortable: SortableOptions.multiColumn,
                allowAggregations: true,
                allowGrouping: true,
                title: const TitleDefinition(title: 'Testing Title'),
                toolbar: const GridToolbar(search: true),
                columns: [
                  StringColumn<_Person>(
                    fieldName: 'name',
                    header: const ColumnHeader(
                      text: 'Name',
                      showFilter: true,
                      showOrderBy: true,
                      showAggregations: true,
                    ),
                    value: (row) => row.name,
                    xsCols: 12,
                    aggregations: [
                      AggregateCriteria(
                        fieldName: 'name',
                        aggregation: Aggregations.count,
                      ),
                    ],
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

      final apply = tester.getRect(find.text(GridLocalizations.en.apply));
      final clear = tester.getRect(find.text(GridLocalizations.en.clear));
      expect(apply.top, greaterThanOrEqualTo(0));
      expect(clear.top, greaterThanOrEqualTo(0));
      expect(apply.bottom, lessThanOrEqualTo(700));
      expect(clear.bottom, lessThanOrEqualTo(700));
    },
  );
}
