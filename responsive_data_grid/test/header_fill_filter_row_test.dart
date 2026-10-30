import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Article {
  final String name;
  final String apps;
  final bool published;
  final DateTime lastUpdated;

  const _Article(this.name, this.apps, this.published, this.lastUpdated);
}

final _articles = [
  _Article('Alpha', 'Admin', true, DateTime(2026, 1, 2)),
  _Article('Beta', 'Scribe', false, DateTime(2026, 2, 3)),
  _Article('Gamma', 'Admin', true, DateTime(2026, 3, 4)),
];

Finder _headerCells() => find.byWidgetPredicate((widget) {
  final key = widget.key;
  return key is ValueKey<String> && key.value.startsWith('rdg-header-cell-');
});

Finder _headerSorts() => find.byWidgetPredicate((widget) {
  final key = widget.key;
  return key is ValueKey<String> && key.value.startsWith('rdg-header-sort-');
});

ThemeData _theme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  );
  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      ResponsiveDataGridTheme.fromTheme(base).copyWith(
        headerBackground: base.colorScheme.surfaceContainerLow,
        headerForeground: base.colorScheme.onSurface,
        headerTextStyle: base.textTheme.titleSmall!.copyWith(
          color: base.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    ],
  );
}

List<GridColumn<_Article, dynamic>> _columns() {
  return [
    StringColumn<_Article>(
      fieldName: 'name',
      value: (row) => row.name,
      width: 220,
      header: const ColumnHeader(
        text: 'Name',
        showFilter: true,
        showOrderBy: true,
      ),
    ),
    StringColumn<_Article>(
      fieldName: 'apps',
      value: (row) => row.apps,
      width: 140,
      header: const ColumnHeader(
        text: 'Apps',
        showFilter: true,
        showOrderBy: true,
      ),
    ),
    BoolColumn<_Article>(
      fieldName: 'published',
      value: (row) => row.published,
      width: 100,
      trueText: 'Yes',
      falseText: 'No',
      header: const ColumnHeader(
        text: 'Published',
        showFilter: true,
        showOrderBy: true,
      ),
    ),
    DateTimeColumn<_Article>(
      fieldName: 'lastUpdated',
      value: (row) => row.lastUpdated,
      width: 140,
      sortDirection: OrderDirections.descending,
      header: const ColumnHeader(
        text: 'Last Updated',
        showFilter: false,
        showOrderBy: true,
      ),
    ),
  ];
}

Future<void> _pump(
  WidgetTester tester, {
  GridSizing sizing = GridSizing.fill,
  double hostHeight = 723,
}) async {
  tester.view.physicalSize = const Size(1100, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: _theme(),
      localizationsDelegates: [
        GridLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: Scaffold(
        body: SizedBox(
          width: 1100,
          height: hostHeight,
          child: Column(
            children: [
              const SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('New article'),
                ),
              ),
              Expanded(
                child: ResponsiveDataGrid<_Article>.serverSide(
                  sizing: sizing,
                  filterable: FilterableMode.row,
                  sortable: SortableOptions.single,
                  pagingMode: PagingMode.pager,
                  pageSize: 20,
                  pageSizeOptions: const [10, 20, 50, 100, 500],
                  separatorThickness: 1,
                  padding: EdgeInsets.zero,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  columns: _columns(),
                  loadData: (criteria) async {
                    return ListResponse<_Article>(
                      totalCount: 20,
                      items: _articles,
                      aggregates: const [],
                      groups: const [],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets(
    'fill + filter row paints column labels above the filter editors',
    (tester) async {
      await _pump(tester);

      expect(find.byKey(const ValueKey('rdg-filter-row-name')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('rdg-header-cell-name')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('rdg-header-sort-name')),
        findsOneWidget,
      );
      expect(_headerCells(), findsNWidgets(4));
      expect(_headerSorts(), findsNWidgets(4));

      final host = tester.getRect(find.byKey(const ValueKey('rdg-height')));
      final nameHeader = tester.getRect(
        find
            .descendant(
              of: find.byKey(const ValueKey('rdg-header-cell-name')),
              matching: find.text('Name'),
            )
            .first,
      );
      final appsHeader = tester.getRect(
        find
            .descendant(
              of: find.byKey(const ValueKey('rdg-header-cell-apps')),
              matching: find.text('Apps'),
            )
            .first,
      );
      final publishedHeader = tester.getRect(
        find
            .descendant(
              of: find.byKey(const ValueKey('rdg-header-cell-published')),
              matching: find.text('Published'),
            )
            .first,
      );
      final lastUpdatedHeader = tester.getRect(
        find
            .descendant(
              of: find.byKey(const ValueKey('rdg-header-cell-lastUpdated')),
              matching: find.text('Last Updated'),
            )
            .first,
      );
      final nameCell = tester.getRect(
        find.byKey(const ValueKey('rdg-header-cell-name')),
      );
      final filter = tester.getRect(
        find.byKey(const ValueKey('rdg-filter-row-name')),
      );
      final pager = tester.getRect(find.byKey(const ValueKey('rdg-pager')));
      final firstBody = tester.getRect(find.text('Alpha'));

      expect(nameHeader.height, greaterThan(8));
      expect(
        nameCell.left,
        closeTo(host.left, 8),
        reason: 'header cells must start in the host, not centered off-screen',
      );
      expect(nameHeader.left, lessThan(host.right));
      expect(nameHeader.right, greaterThan(host.left));
      expect(appsHeader.left, lessThan(host.right));
      expect(publishedHeader.left, lessThan(host.right));
      expect(lastUpdatedHeader.left, lessThan(host.right));
      expect(nameHeader.bottom, lessThan(filter.top + 1));
      expect(appsHeader.bottom, lessThan(filter.top + 1));
      expect(publishedHeader.bottom, lessThan(filter.top + 1));
      expect(lastUpdatedHeader.bottom, lessThan(filter.top + 1));
      expect(filter.left, lessThan(host.right));
      expect(filter.bottom, lessThan(firstBody.top + 1));
      expect(firstBody.left, closeTo(nameHeader.left, 12));
      expect(pager.bottom, closeTo(host.bottom, 4));
    },
  );
}
