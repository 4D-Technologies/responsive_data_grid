import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;

  const _Person(this.id, this.name);
}

List<GridColumn<_Person, dynamic>> _columns() {
  return [
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
  ];
}

Future<void> _pumpPagerGrid(
  WidgetTester tester, {
  required List<_Person> items,
  int pageSize = 10,
  List<int> pageSizeOptions = const [10, 25, 50, 100],
  Size size = const Size(900, 700),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: ResponsiveDataGrid<_Person>.clientSide(
            height: size.height - 24,
            pagingMode: PagingMode.pager,
            pageSize: pageSize,
            pageSizeOptions: pageSizeOptions,
            items: items,
            columns: _columns(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

List<_Person> _people(int count) {
  return [for (var i = 1; i <= count; i++) _Person(i, 'Person $i')];
}

int _pageButtonCount(WidgetTester tester) {
  return find
      .byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key as ValueKey<String>).value.startsWith('rdg-pager-page-'),
      )
      .evaluate()
      .length;
}

void main() {
  group('compactPagerPages', () {
    test('returns an empty list when there are no pages', () {
      expect(
        compactPagerPages(pageCount: 0, currentPage: 1, maxSlots: 7),
        isEmpty,
      );
    });

    test('returns every page when they fit', () {
      expect(
        compactPagerPages(pageCount: 5, currentPage: 3, maxSlots: 7),
        [1, 2, 3, 4, 5],
      );
    });

    test('keeps a window around the current page with ellipses', () {
      expect(
        compactPagerPages(pageCount: 20, currentPage: 10, maxSlots: 7),
        [1, null, 9, 10, 11, null, 20],
      );
    });

    test('does not ellipsize the start when current is near page 1', () {
      expect(
        compactPagerPages(pageCount: 20, currentPage: 1, maxSlots: 7),
        [1, 2, 3, 4, 5, null, 20],
      );
    });

    test('does not ellipsize the end when current is near the last page', () {
      expect(
        compactPagerPages(pageCount: 20, currentPage: 20, maxSlots: 7),
        [1, null, 16, 17, 18, 19, 20],
      );
    });

    test('never returns more items than maxSlots', () {
      expect(
        compactPagerPages(pageCount: 20, currentPage: 10, maxSlots: 1),
        [10],
      );
      expect(
        compactPagerPages(pageCount: 20, currentPage: 10, maxSlots: 3).length,
        lessThanOrEqualTo(3),
      );
      expect(
        compactPagerPages(pageCount: 20, currentPage: 10, maxSlots: 3),
        contains(10),
      );
    });
  });

  group('pagerRangeLabel', () {
    test('describes an empty dataset without using page 0', () {
      expect(
        pagerRangeLabel(pageNumber: 1, pageSize: 50, totalCount: 0),
        '0–0 of 0',
      );
    });

    test('describes the current slice', () {
      expect(
        pagerRangeLabel(pageNumber: 1, pageSize: 50, totalCount: 1234),
        '1–50 of 1234',
      );
      expect(
        pagerRangeLabel(pageNumber: 25, pageSize: 50, totalCount: 1234),
        '1201–1234 of 1234',
      );
    });
  });

  testWidgets('shows range text and numbered pages', (tester) async {
    await _pumpPagerGrid(tester, items: _people(95), pageSize: 10);

    expect(find.text('1–10 of 95'), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-pager-page-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-pager-page-2')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('rdg-pager-page-2')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('11–20 of 95'), findsOneWidget);
    expect(find.text('Person 11'), findsOneWidget);
    expect(find.text('Person 1'), findsNothing);
  });

  testWidgets('disables first/prev on page 1 and next/last on the last page', (
    tester,
  ) async {
    await _pumpPagerGrid(tester, items: _people(15), pageSize: 10);

    await tester.tap(find.byTooltip('First page'));
    await tester.pump();
    expect(find.text('1–10 of 15'), findsOneWidget);

    await tester.tap(find.byTooltip('Last page'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('11–15 of 15'), findsOneWidget);

    await tester.tap(find.byTooltip('Last page'));
    await tester.pump();
    expect(find.text('11–15 of 15'), findsOneWidget);
  });

  testWidgets('empty dataset does not navigate to page 0', (tester) async {
    await _pumpPagerGrid(tester, items: const []);

    expect(find.text('0–0 of 0'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Last page'));
    await tester.pump();
    await tester.tap(find.byTooltip('Next page'));
    await tester.pump();

    expect(find.text('0–0 of 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.text('0 / 0'), findsNothing);
  });

  testWidgets('page-size selector reloads the first page', (tester) async {
    await _pumpPagerGrid(tester, items: _people(95), pageSize: 10);

    await tester.tap(find.byKey(const ValueKey('rdg-pager-page-size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('1–25 of 95'), findsOneWidget);
    expect(find.text('Person 1'), findsOneWidget);
    expect(find.text('Person 11'), findsOneWidget);
  });

  testWidgets('narrow width shows fewer page number buttons', (tester) async {
    await _pumpPagerGrid(
      tester,
      items: _people(200),
      pageSize: 10,
      size: const Size(900, 700),
    );
    final wideCount = _pageButtonCount(tester);

    await _pumpPagerGrid(
      tester,
      items: _people(200),
      pageSize: 10,
      size: const Size(360, 700),
    );
    final narrowCount = _pageButtonCount(tester);

    expect(wideCount, greaterThan(narrowCount));
    expect(narrowCount, greaterThan(0));
  });

  testWidgets('arrow keys move the page when the pager is focused', (
    tester,
  ) async {
    await _pumpPagerGrid(tester, items: _people(30), pageSize: 10);

    final pagerChild = tester.element(
      find.descendant(
        of: find.byKey(const ValueKey('rdg-pager')),
        matching: find.byType(Row),
      ).first,
    );
    Focus.of(pagerChild).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('11–20 of 30'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('1–10 of 30'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('21–30 of 30'), findsOneWidget);
  });
}
