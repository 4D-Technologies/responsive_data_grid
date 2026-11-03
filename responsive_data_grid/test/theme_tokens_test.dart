import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;
  final int age;

  const _Person(this.name, this.age);
}

List<GridColumn<_Person, dynamic>> _columns() {
  return [
    StringColumn<_Person>(
      fieldName: 'name',
      header: const ColumnHeader(text: 'Name', showFilter: true),
      value: (row) => row.name,
      xsCols: 6,
    ),
    IntColumn<_Person>(
      fieldName: 'age',
      header: const ColumnHeader(text: 'Age'),
      value: (row) => row.age,
      xsCols: 6,
    ),
  ];
}

ThemeData _themeWith(ResponsiveDataGridTheme grid) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  );
  return base.copyWith(extensions: <ThemeExtension<dynamic>>[grid]);
}

Future<void> _pump(
  WidgetTester tester, {
  required ThemeData theme,
  EdgeInsets? contentPadding,
  double? separatorThickness,
  GridSizing sizing = GridSizing.auto,
  double? height,
  List<_Person>? items,
}) async {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: SizedBox(
          width: 900,
          height: 600,
          child: ResponsiveDataGrid<_Person>.clientSide(
            items: items ?? const [_Person('Ada', 36), _Person('Grace', 30)],
            pageSize: 10,
            pagingMode: PagingMode.pager,
            height: height ?? 500,
            sizing: sizing,
            contentPadding: contentPadding,
            separatorThickness: separatorThickness,
            columns: _columns(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('body.separatorThickness 0 kills row rules, keeps outer border', (
    tester,
  ) async {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    );
    final grid = ResponsiveDataGridTheme.fromTheme(base).copyWith(
      chrome: ResponsiveDataGridTheme.fromTheme(
        base,
      ).chrome.copyWith(borderWidth: 2),
      body: ResponsiveDataGridTheme.fromTheme(
        base,
      ).body.copyWith(separatorThickness: 0),
    );
    await _pump(tester, theme: _themeWith(grid));

    expect(find.byType(Divider), findsNothing);
    final card = tester.widget<Card>(find.byType(Card));
    expect(card.elevation, grid.chrome.elevation);
  });

  testWidgets('widget separatorThickness overrides theme', (tester) async {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    );
    final grid = ResponsiveDataGridTheme.fromTheme(base).copyWith(
      body: ResponsiveDataGridTheme.fromTheme(
        base,
      ).body.copyWith(separatorThickness: 0),
    );
    await _pump(
      tester,
      theme: _themeWith(grid),
      separatorThickness: 3,
    );
    final divider = tester.widget<Divider>(find.byType(Divider).first);
    expect(divider.thickness, 3);
  });

  testWidgets('oddBackground paints odd rows including empty fill rows', (
    tester,
  ) async {
    const odd = Color(0xFFE8EEF4);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    );
    final fromBase = ResponsiveDataGridTheme.fromTheme(base);
    final grid = fromBase.copyWith(
      body: fromBase.body.copyWith(oddBackground: odd),
    );
    await _pump(
      tester,
      theme: _themeWith(grid),
      sizing: GridSizing.fill,
      height: null,
      items: const [_Person('Ada', 36)],
    );

    final empty = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey<String> && key.value == 'rdg-empty-row-0';
    });
    expect(empty, findsOneWidget);
    final box = tester.widget<ColoredBox>(
      find.descendant(of: empty, matching: find.byType(ColoredBox)).first,
    );
    expect(box.color, odd);
  });

  testWidgets('contentPadding widget override is used for cells', (
    tester,
  ) async {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    );
    const overridePad = EdgeInsets.fromLTRB(20, 12, 16, 12);
    await _pump(
      tester,
      theme: _themeWith(ResponsiveDataGridTheme.fromTheme(base)),
      contentPadding: overridePad,
    );

    final cell = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey<String> && key.value.startsWith('rdg-cell-name-');
    });
    expect(cell, findsWidgets);
    final pad = tester.widget<Padding>(
      find.descendant(of: cell.first, matching: find.byType(Padding)).first,
    );
    expect(pad.padding, overridePad);
  });
}
