import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;
  final int age;

  const _Person(this.name, this.age);
}

ResponsiveDataGrid<_Person> _grid() {
  return ResponsiveDataGrid<_Person>.clientSide(
    items: const [_Person('Ada', 36), _Person('Ada', 30)],
    pageSize: 10,
    pagingMode: PagingMode.pager,
    height: 500,
    allowGrouping: true,
    initialLoadCriteria: LoadCriteria(
      groupBy: [
        GroupCriteria(
          fieldName: 'name',
          direction: OrderDirections.ascending,
          aggregates: const [],
        ),
      ],
    ),
    columns: [
      StringColumn<_Person>(
        fieldName: 'name',
        header: const ColumnHeader(text: 'Name'),
        value: (row) => row.name,
        xsCols: 6,
      ),
      IntColumn<_Person>(
        fieldName: 'age',
        header: const ColumnHeader(text: 'Age'),
        value: (row) => row.age,
        xsCols: 6,
      ),
    ],
  );
}

Future<void> _pump(WidgetTester tester, {required ThemeData theme}) async {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(body: SizedBox(width: 900, height: 600, child: _grid())),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

Color? _groupHeaderColor(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(GridGroupHeader),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return (box.decoration as BoxDecoration).color;
}

void main() {
  testWidgets('group header is not the hardcoded dark grey', (tester) async {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
      ),
    );
    await _pump(tester, theme: theme);
    expect(tester.takeException(), isNull);
    expect(
      _groupHeaderColor(tester),
      isNot(const Color.fromARGB(255, 48, 48, 48)),
    );
  });

  testWidgets('ResponsiveDataGridTheme override is used for group headers', (
    tester,
  ) async {
    const override = Color(0xFF112233);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    );
    await _pump(
      tester,
      theme: base.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          ResponsiveDataGridTheme.fromTheme(
            base,
          ).copyWith(groupHeaderBackground: override),
        ],
      ),
    );
    expect(_groupHeaderColor(tester), override);
  });

  testWidgets('fromTheme uses DataTableTheme heading row color', (
    tester,
  ) async {
    const heading = Color(0xFF445566);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(heading),
      ),
    );
    await _pump(
      tester,
      theme: base.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          ResponsiveDataGridTheme.fromTheme(base),
        ],
      ),
    );

    final headerBox = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(ResponsiveDataGridHeaderRowWidget<_Person>),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect((headerBox.decoration as BoxDecoration).color, heading);
  });

  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('header and footer text contrast in $brightness mode', (
      tester,
    ) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: brightness,
        ),
      );
      await _pump(tester, theme: theme);

      final gridTheme = ResponsiveDataGridTheme.fromTheme(theme);
      expect(
        contrastRatio(gridTheme.headerBackground, gridTheme.headerForeground),
        greaterThanOrEqualTo(4.5),
        reason: 'header $brightness',
      );
      expect(
        contrastRatio(gridTheme.footerBackground, gridTheme.footerForeground),
        greaterThanOrEqualTo(4.5),
        reason: 'footer $brightness',
      );
      expect(
        contrastRatio(
          gridTheme.groupHeaderBackground,
          gridTheme.groupHeaderForeground,
        ),
        greaterThanOrEqualTo(4.5),
        reason: 'group header $brightness',
      );
      expect(
        contrastRatio(
          gridTheme.groupFooterBackground,
          gridTheme.groupFooterForeground,
        ),
        greaterThanOrEqualTo(4.5),
        reason: 'group footer $brightness',
      );

      final headerText = tester.widget<Text>(
        find
            .descendant(
              of: find.byType(ResponsiveDataGridHeaderRowWidget<_Person>),
              matching: find.text('Name'),
            )
            .first,
      );
      expect(
        headerText.style?.color,
        gridTheme.headerForeground,
        reason: 'column header text should use grid theme, not onPrimary',
      );
      expect(
        contrastRatio(gridTheme.headerBackground, headerText.style!.color!),
        greaterThanOrEqualTo(4.5),
      );
    });
  }
}

double contrastRatio(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}
