import 'dart:async';

import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;

  const _Person(this.name);
}

List<GridColumn<_Person, dynamic>> _columns() {
  return [
    StringColumn<_Person>(
      fieldName: 'name',
      header: const ColumnHeader(text: 'Name'),
      value: (row) => row.name,
      xsCols: 12,
    ),
  ];
}

Future<void> _pump(WidgetTester tester, {required Widget grid}) async {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SizedBox(width: 900, height: 600, child: grid)),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('empty client-side grid shows the default no-records message', (
    tester,
  ) async {
    await _pump(
      tester,
      grid: ResponsiveDataGrid<_Person>.clientSide(
        items: const [],
        height: 500,
        pagingMode: PagingMode.pager,
        columns: _columns(),
      ),
    );

    expect(find.byType(GridNoRecords), findsOneWidget);
    expect(find.text(LocalizedMessages.noRecords), findsOneWidget);
  });

  testWidgets('empty server-side grid shows the default no-records message', (
    tester,
  ) async {
    await _pump(
      tester,
      grid: ResponsiveDataGrid<_Person>.serverSide(
        height: 500,
        pagingMode: PagingMode.pager,
        loadData: (_) async => ListResponse<_Person>(
          totalCount: 0,
          items: const [],
          groups: const [],
          aggregates: const [],
        ),
        columns: _columns(),
      ),
    );

    expect(find.byType(GridNoRecords), findsOneWidget);
    expect(find.text(LocalizedMessages.noRecords), findsOneWidget);
  });

  testWidgets('noResults replaces the default empty chrome', (tester) async {
    await _pump(
      tester,
      grid: ResponsiveDataGrid<_Person>.clientSide(
        items: const [],
        height: 500,
        pagingMode: PagingMode.pager,
        noResults: const Text('Nothing here'),
        columns: _columns(),
      ),
    );

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.byType(GridNoRecords), findsNothing);
    expect(find.text(LocalizedMessages.noRecords), findsNothing);
  });

  testWidgets('empty chrome is not shown while a load is in flight', (
    tester,
  ) async {
    final started = Completer<void>();
    final finish = Completer<ListResponse<_Person>>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 600,
            child: ResponsiveDataGrid<_Person>.serverSide(
              height: 500,
              pagingMode: PagingMode.pager,
              loadData: (_) {
                started.complete();
                return finish.future;
              },
              columns: _columns(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await started.future;
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(GridNoRecords), findsNothing);
    expect(find.text(LocalizedMessages.noRecords), findsNothing);

    finish.complete(
      ListResponse<_Person>(
        totalCount: 0,
        items: const [],
        groups: const [],
        aggregates: const [],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(GridNoRecords), findsOneWidget);
  });

  testWidgets('infinite-scroll empty grid uses the same no-records chrome', (
    tester,
  ) async {
    await _pump(
      tester,
      grid: ResponsiveDataGrid<_Person>.clientSide(
        items: const [],
        height: 500,
        pagingMode: PagingMode.infiniteScroll,
        columns: _columns(),
      ),
    );

    expect(find.byType(GridNoRecords), findsOneWidget);
    expect(find.text(LocalizedMessages.noRecords), findsOneWidget);
  });

  testWidgets('empty-state text uses body color, not header foreground', (
    tester,
  ) async {
    const headerFg = Color(0xFFFFFFF0);
    const bodyFg = Color(0xFF111111);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    );
    final gridTheme = ResponsiveDataGridTheme.fromTheme(base).copyWith(
      headerForeground: headerFg,
      bodyTextStyle: const TextStyle(color: bodyFg, fontSize: 14),
    );

    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: base.copyWith(extensions: <ThemeExtension<dynamic>>[gridTheme]),
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 600,
            child: ResponsiveDataGrid<_Person>.clientSide(
              items: const [],
              height: 500,
              pagingMode: PagingMode.pager,
              columns: _columns(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final text = tester.widget<Text>(find.text(LocalizedMessages.noRecords));
    expect(text.style?.color, isNot(headerFg.withValues(alpha: 0.72)));
    expect(text.style?.color, bodyFg.withValues(alpha: 0.72));
  });

  testWidgets(
    'empty-state falls back to inherited text color when body style has none',
    (tester) async {
      const headerFg = Color(0xFFFFFFF0);
      final base = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      );
      final gridTheme = ResponsiveDataGridTheme.fromTheme(base).copyWith(
        headerForeground: headerFg,
        bodyTextStyle: const TextStyle(fontSize: 14),
      );

      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: base.copyWith(
            extensions: <ThemeExtension<dynamic>>[gridTheme],
          ),
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 600,
              child: ResponsiveDataGrid<_Person>.clientSide(
                items: const [],
                height: 500,
                pagingMode: PagingMode.pager,
                columns: _columns(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final text = tester.widget<Text>(find.text(LocalizedMessages.noRecords));
      final inherited = DefaultTextStyle.of(
        tester.element(find.byType(GridNoRecords)),
      ).style.color;
      expect(text.style?.color, isNot(headerFg.withValues(alpha: 0.72)));
      expect(text.style?.color, inherited!.withValues(alpha: 0.72));
    },
  );
}
