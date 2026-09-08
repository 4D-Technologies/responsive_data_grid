import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;
  final int age;

  const _Person(this.name, this.age);
}

ResponsiveDataGrid<_Person> _actionGrid() {
  return ResponsiveDataGrid<_Person>.clientSide(
    items: const [_Person('Ada', 36), _Person('Alan', 42)],
    pageSize: 10,
    pagingMode: PagingMode.pager,
    height: 500,
    allowAggregations: true,
    columns: [
      StringColumn<_Person>(
        fieldName: 'name',
        header: const ColumnHeader(
          text: 'Name',
          showFilter: true,
          showOrderBy: true,
        ),
        value: (row) => row.name,
        xsCols: 6,
      ),
      IntColumn<_Person>(
        fieldName: 'age',
        header: const ColumnHeader(
          text: 'Age',
          showFilter: true,
          showOrderBy: true,
        ),
        value: (row) => row.age,
        xsCols: 6,
      ),
    ],
  );
}

Future<void> _pumpMaterial(
  WidgetTester tester, {
  required ThemeData theme,
  required Widget grid,
}) async {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(body: SizedBox(width: 900, height: 600, child: grid)),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> _pumpCupertino(
  WidgetTester tester, {
  required Brightness brightness,
  required Widget grid,
}) async {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    cupertino.CupertinoApp(
      theme: cupertino.CupertinoThemeData(brightness: brightness),
      home: cupertino.CupertinoPageScaffold(
        child: SizedBox(width: 900, height: 600, child: grid),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets(
    'sort/menu stay inside the column and do not collide with the next label',
    (tester) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      );
      await _pumpMaterial(tester, theme: theme, grid: _actionGrid());
      expect(tester.takeException(), isNull);

      final menu = tester.getRect(
        find.byKey(const ValueKey('rdg-header-menu-name')),
      );
      final age = tester.getRect(find.text('Age').first);
      expect(
        age.left,
        greaterThan(menu.right + 4),
        reason:
            'Age label should sit past the Name menu with divider padding, '
            'got menu.right=${menu.right} age.left=${age.left}',
      );

      final nameSort = tester.getRect(
        find.byKey(const ValueKey('rdg-header-sort-name')),
      );
      expect(
        nameSort.left,
        greaterThan(tester.getRect(find.text('Name').first).left),
      );
      expect(menu.left, greaterThan(nameSort.right - 1));
    },
  );

  testWidgets('header divider color is overridable', (tester) async {
    const divider = Color(0xFF123456);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    );
    await _pumpMaterial(
      tester,
      theme: base.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          ResponsiveDataGridTheme.fromTheme(
            base,
          ).copyWith(headerDividerColor: divider, headerDividerWidth: 2),
        ],
      ),
      grid: _actionGrid(),
    );

    final cell = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('rdg-header-cell-name')),
    );
    final border = (cell.decoration as BoxDecoration).border! as Border;
    expect(border.right.color, divider);
    expect(border.right.width, 2);
  });

  testWidgets('column header padding override is used', (tester) async {
    const padding = EdgeInsets.fromLTRB(20, 12, 16, 12);
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    );
    await _pumpMaterial(
      tester,
      theme: theme,
      grid: ResponsiveDataGrid<_Person>.clientSide(
        items: const [_Person('Ada', 36)],
        pageSize: 10,
        pagingMode: PagingMode.pager,
        height: 500,
        columns: [
          StringColumn<_Person>(
            fieldName: 'name',
            header: const ColumnHeader(text: 'Name', padding: padding),
            value: (row) => row.name,
            xsCols: 12,
          ),
        ],
      ),
    );

    final pad = tester.widget<Padding>(
      find
          .descendant(
            of: find.byKey(const ValueKey('rdg-header-cell-name')),
            matching: find.byType(Padding),
          )
          .first,
    );
    expect(pad.padding, padding);
  });

  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('grid renders in Cupertino $brightness with contrast', (
      tester,
    ) async {
      await _pumpCupertino(tester, brightness: brightness, grid: _actionGrid());
      expect(tester.takeException(), isNull);
      expect(find.text('Name'), findsWidgets);
      expect(find.text('Age'), findsWidgets);

      final headerElement = tester.element(
        find.byType(ResponsiveDataGridHeaderRowWidget<_Person>),
      );
      final gridTheme = ResponsiveDataGridTheme.of(headerElement);
      expect(
        gridContrastRatio(
          gridTheme.headerBackground,
          gridTheme.headerForeground,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        gridContrastRatio(
          gridTheme.footerBackground,
          gridTheme.footerForeground,
        ),
        greaterThanOrEqualTo(4.5),
      );

      final headerText = tester.widget<Text>(
        find
            .descendant(
              of: find.byType(ResponsiveDataGridHeaderRowWidget<_Person>),
              matching: find.text('Name'),
            )
            .first,
      );
      expect(headerText.style?.color, gridTheme.headerForeground);
    });
  }

  testWidgets('title uses overridable title colors', (tester) async {
    const titleBg = Color(0xFF112233);
    const titleFg = Color(0xFFEEEEEE);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    );
    await _pumpMaterial(
      tester,
      theme: base.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          ResponsiveDataGridTheme.fromTheme(
            base,
          ).copyWith(titleBackground: titleBg, titleForeground: titleFg),
        ],
      ),
      grid: ResponsiveDataGrid<_Person>.clientSide(
        title: const TitleDefinition(title: 'People'),
        items: const [_Person('Ada', 36)],
        pageSize: 10,
        pagingMode: PagingMode.pager,
        height: 500,
        columns: [
          StringColumn<_Person>(
            fieldName: 'name',
            header: const ColumnHeader(text: 'Name'),
            value: (row) => row.name,
            xsCols: 12,
          ),
        ],
      ),
    );

    final box = tester.widget<ColoredBox>(
      find
          .descendant(
            of: find.byType(TitleRowWidget),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(box.color, titleBg);
    final title = tester.widget<Text>(find.text('People'));
    expect(title.style?.color, titleFg);
  });
}
