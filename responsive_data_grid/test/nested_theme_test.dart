import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

ThemeData _base() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  );
}

void main() {
  test('fromTheme nests chrome, header, and body', () {
    final grid = ResponsiveDataGridTheme.fromTheme(_base());
    expect(grid.chrome.borderWidth, greaterThan(0));
    expect(grid.body.separatorThickness, greaterThan(0));
    expect(grid.header.dividerWidth, greaterThan(0));
    expect(grid.body.oddBackground, isNull);
  });

  test('body separator is independent of chrome border', () {
    final grid = ResponsiveDataGridTheme.fromTheme(_base());
    final copied = grid.copyWith(
      body: grid.body.copyWith(separatorThickness: 0),
    );
    expect(copied.body.separatorThickness, 0);
    expect(copied.chrome.borderWidth, grid.chrome.borderWidth);
  });

  test('copyWith on nested header does not clobber body', () {
    final grid = ResponsiveDataGridTheme.fromTheme(_base());
    const divider = Color(0xFF123456);
    final copied = grid.copyWith(
      header: grid.header.copyWith(dividerColor: divider, dividerWidth: 0),
    );
    expect(copied.header.dividerColor, divider);
    expect(copied.header.dividerWidth, 0);
    expect(copied.body.background, grid.body.background);
  });

  testWidgets('of(context) returns nested theme from extensions', (tester) async {
    final base = _base();
    final grid = ResponsiveDataGridTheme.fromTheme(base).copyWith(
      body: ResponsiveDataGridTheme.fromTheme(base).body.copyWith(
        separatorThickness: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        oddBackground: const Color(0xFFE8EEF4),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: base.copyWith(extensions: <ThemeExtension<dynamic>>[grid]),
        home: Builder(
          builder: (context) {
            final resolved = ResponsiveDataGridTheme.of(context);
            expect(resolved.body.separatorThickness, 0);
            expect(
              resolved.body.contentPadding,
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            );
            expect(resolved.body.oddBackground, const Color(0xFFE8EEF4));
            expect(resolved.chrome.borderWidth, greaterThan(0));
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}
