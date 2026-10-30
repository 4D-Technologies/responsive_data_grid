import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;
  final String team;

  const _Person(this.id, this.name, {this.team = 'A'});
}

List<GridColumn<_Person, dynamic>> _columns() {
  return [
    IntColumn<_Person>(
      fieldName: 'id',
      header: const ColumnHeader(text: 'Id'),
      value: (row) => row.id,
      xsCols: 3,
    ),
    StringColumn<_Person>(
      fieldName: 'name',
      header: const ColumnHeader(text: 'Name'),
      value: (row) => row.name,
      xsCols: 5,
    ),
    StringColumn<_Person>(
      fieldName: 'team',
      header: const ColumnHeader(text: 'Team'),
      value: (row) => row.team,
      xsCols: 4,
    ),
  ];
}

List<_Person> _people(int count) {
  return [
    for (var i = 1; i <= count; i++)
      _Person(i, 'Person $i', team: i.isEven ? 'A' : 'B'),
  ];
}

Finder _heightBox() => find.byKey(const ValueKey('rdg-height'));

double _gridHeight(WidgetTester tester) => tester.getSize(_heightBox()).height;

double _widgetHeight(WidgetTester tester) =>
    tester.getSize(find.byType(ResponsiveDataGrid<_Person>)).height;

Future<void> _pump(
  WidgetTester tester, {
  required Widget child,
  Size view = const Size(900, 800),
}) async {
  tester.view.physicalSize = view;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

ResponsiveDataGrid<_Person> _grid({
  GlobalKey<ResponsiveDataGridState<_Person>>? key,
  List<_Person>? items,
  int pageSize = 10,
  PagingMode pagingMode = PagingMode.pager,
  double? height,
  double? minHeight,
  double? maxHeight,
  GridSizing sizing = GridSizing.auto,
  bool grouping = false,
}) {
  return ResponsiveDataGrid<_Person>.clientSide(
    key: key,
    items: items ?? _people(40),
    columns: _columns(),
    pageSize: pageSize,
    pageSizeOptions: const [5, 10, 25, 50],
    pagingMode: pagingMode,
    height: height,
    minHeight: minHeight,
    maxHeight: maxHeight,
    sizing: sizing,
    allowGrouping: grouping,
    initialLoadCriteria: grouping
        ? LoadCriteria(
            groupBy: [
              GroupCriteria(
                fieldName: 'team',
                direction: OrderDirections.ascending,
                aggregates: const [],
              ),
            ],
          )
        : null,
  );
}

void main() {
  group('computeGridMinHeight', () {
    test('sums page rows plus chrome', () {
      expect(
        computeGridMinHeight(
          pageSize: 10,
          rowExtent: 20,
          headerExtent: 40,
          filterRowExtent: 48,
          pagerExtent: 36,
          paddingVertical: 10,
        ),
        10 * 20 + 40 + 48 + 36 + 10,
      );
    });

    test('explicit minHeight wins', () {
      expect(
        computeGridMinHeight(
          pageSize: 10,
          rowExtent: 20,
          headerExtent: 40,
          minHeight: 250,
        ),
        250,
      );
    });

    test('includes groups and separators', () {
      expect(
        computeGridMinHeight(
          pageSize: 4,
          rowExtent: 20,
          headerExtent: 40,
          groupHeaderExtent: 40,
          groupHeaderCount: 2,
          groupFooterExtent: 24,
          groupFooterCount: 2,
          separatorExtent: 1,
        ),
        4 * 20 + 3 * 1 + 40 + 40 * 2 + 24 * 2,
      );
    });

    test('countGroupNodes walks nested groups', () {
      const groups = [
        GroupResult(
          fieldName: 'team',
          value: 'A',
          aggregates: [],
          subGroups: [
            GroupResult(
              fieldName: 'name',
              value: 'Ada',
              aggregates: [],
              subGroups: [],
            ),
          ],
        ),
        GroupResult(
          fieldName: 'team',
          value: 'B',
          aggregates: [],
          subGroups: [],
        ),
      ];
      expect(countGroupNodes(groups), 3);
    });
  });

  group('resolveGridHostHeight', () {
    test('auto uses explicit height', () {
      expect(
        resolveGridHostHeight(
          sizing: GridSizing.auto,
          pagingMode: PagingMode.pager,
          explicitHeight: 400,
          parentMaxHeight: 800,
          minContent: 300,
          minHeight: null,
          maxHeight: null,
          resizable: false,
        ),
        400,
      );
    });

    test('auto fills a bounded parent when height is null', () {
      expect(
        resolveGridHostHeight(
          sizing: GridSizing.auto,
          pagingMode: PagingMode.pager,
          explicitHeight: null,
          parentMaxHeight: 800,
          minContent: 300,
          minHeight: null,
          maxHeight: null,
          resizable: false,
        ),
        800,
      );
    });

    test('auto shrink-wraps when parent is unbounded', () {
      expect(
        resolveGridHostHeight(
          sizing: GridSizing.auto,
          pagingMode: PagingMode.pager,
          explicitHeight: null,
          parentMaxHeight: null,
          minContent: 300,
          minHeight: null,
          maxHeight: null,
          resizable: false,
        ),
        isNull,
      );
    });

    test('fill uses max(parent, minContent)', () {
      expect(
        resolveGridHostHeight(
          sizing: GridSizing.fill,
          pagingMode: PagingMode.pager,
          explicitHeight: null,
          parentMaxHeight: 900,
          minContent: 400,
          minHeight: null,
          maxHeight: null,
          resizable: false,
        ),
        900,
      );
      expect(
        resolveGridHostHeight(
          sizing: GridSizing.fill,
          pagingMode: PagingMode.pager,
          explicitHeight: null,
          parentMaxHeight: 200,
          minContent: 400,
          minHeight: null,
          maxHeight: null,
          resizable: false,
        ),
        400,
      );
    });

    test('fill uses minContent when parent is unbounded', () {
      expect(
        resolveGridHostHeight(
          sizing: GridSizing.fill,
          pagingMode: PagingMode.pager,
          explicitHeight: null,
          parentMaxHeight: null,
          minContent: 400,
          minHeight: null,
          maxHeight: null,
          resizable: false,
        ),
        400,
      );
    });

    test('shrinkWrap always returns null', () {
      expect(
        resolveGridHostHeight(
          sizing: GridSizing.shrinkWrap,
          pagingMode: PagingMode.pager,
          explicitHeight: 400,
          parentMaxHeight: 800,
          minContent: 300,
          minHeight: null,
          maxHeight: null,
          resizable: false,
        ),
        isNull,
      );
    });

    test('infinite scroll clamps parent between min and max', () {
      expect(
        resolveGridHostHeight(
          sizing: GridSizing.auto,
          pagingMode: PagingMode.infiniteScroll,
          explicitHeight: null,
          parentMaxHeight: 300,
          minContent: 150,
          minHeight: 200,
          maxHeight: 400,
          resizable: false,
        ),
        300,
      );
      expect(
        resolveGridHostHeight(
          sizing: GridSizing.auto,
          pagingMode: PagingMode.infiniteScroll,
          explicitHeight: null,
          parentMaxHeight: 500,
          minContent: 150,
          minHeight: 200,
          maxHeight: 400,
          resizable: false,
        ),
        400,
      );
      expect(
        resolveGridHostHeight(
          sizing: GridSizing.auto,
          pagingMode: PagingMode.infiniteScroll,
          explicitHeight: null,
          parentMaxHeight: 100,
          minContent: 150,
          minHeight: 200,
          maxHeight: 400,
          resizable: false,
        ),
        200,
      );
    });

    test('infinite scroll in an unbounded parent uses minHeight', () {
      expect(
        resolveGridHostHeight(
          sizing: GridSizing.auto,
          pagingMode: PagingMode.infiniteScroll,
          explicitHeight: null,
          parentMaxHeight: null,
          minContent: 180,
          minHeight: 220,
          maxHeight: 400,
          resizable: false,
        ),
        220,
      );
    });
  });

  group('fill pager layout', () {
    testWidgets('fills a bounded parent taller than the minimum', (
      tester,
    ) async {
      final key = GlobalKey<ResponsiveDataGridState<_Person>>();
      await _pump(
        tester,
        child: SizedBox(
          width: 900,
          height: 760,
          child: _grid(key: key, sizing: GridSizing.fill, pageSize: 5),
        ),
        view: const Size(900, 800),
      );
      expect(_widgetHeight(tester), closeTo(760, 4));
      expect(
        _widgetHeight(tester),
        greaterThanOrEqualTo(key.currentState!.minimumHeight),
      );
      expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);
      expect(find.text('Person 1'), findsOneWidget);
      expect(find.text('Person 5'), findsOneWidget);
      final body = tester.widget<ScrollView>(
        find.byKey(const ValueKey('rdg-body-scroll')),
      );
      expect(body.shrinkWrap, isTrue);
      expect(body.physics, isA<NeverScrollableScrollPhysics>());
    });

    testWidgets('uses minHeight in an unbounded parent without throwing', (
      tester,
    ) async {
      final key = GlobalKey<ResponsiveDataGridState<_Person>>();
      await _pump(
        tester,
        child: ListView(
          children: [
            const SizedBox(height: 24, child: Text('Above')),
            _grid(key: key, sizing: GridSizing.fill, pageSize: 8),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        _widgetHeight(tester),
        closeTo(key.currentState!.minimumHeight, 4),
      );
      expect(find.text('Person 8'), findsOneWidget);
      expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);
    });

    testWidgets('short tab body scrolls around a full page of rows', (
      tester,
    ) async {
      await _pump(
        tester,
        view: const Size(900, 320),
        child: SizedBox(
          width: 900,
          height: 260,
          child: SingleChildScrollView(
            key: const ValueKey('host-scroll'),
            child: _grid(sizing: GridSizing.fill, pageSize: 10),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(_gridHeight(tester), greaterThan(260));
      expect(find.text('Person 1'), findsOneWidget);
      expect(find.text('Person 10'), findsOneWidget);
      expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);

      final host = tester.widget<SingleChildScrollView>(
        find.byKey(const ValueKey('host-scroll')),
      );
      expect(host.scrollDirection, Axis.vertical);
    });

    testWidgets('changing page size updates the minimum', (tester) async {
      final key = GlobalKey<ResponsiveDataGridState<_Person>>();
      await _pump(
        tester,
        child: ListView(
          children: [_grid(key: key, sizing: GridSizing.fill, pageSize: 5)],
        ),
      );
      final state = key.currentState!;
      final small = state.minimumHeight;
      await state.setPageSize(25);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(state.minimumHeight, greaterThan(small));
      expect(_widgetHeight(tester), closeTo(state.minimumHeight, 4));
    });

    testWidgets('includes group headers in the minimum', (tester) async {
      final groupedKey = GlobalKey<ResponsiveDataGridState<_Person>>();
      await _pump(
        tester,
        child: ListView(
          children: [
            _grid(
              key: groupedKey,
              sizing: GridSizing.fill,
              pageSize: 10,
              grouping: true,
            ),
          ],
        ),
      );
      final groupedHeight = groupedKey.currentState!.minimumHeight;

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      final plainKey = GlobalKey<ResponsiveDataGridState<_Person>>();
      await _pump(
        tester,
        child: ListView(
          children: [
            _grid(key: plainKey, sizing: GridSizing.fill, pageSize: 10),
          ],
        ),
      );
      expect(groupedHeight, greaterThan(plainKey.currentState!.minimumHeight));
    });
  });

  group('shrinkWrap pager layout', () {
    testWidgets('sizes to content inside a tall bounded parent', (
      tester,
    ) async {
      await _pump(
        tester,
        child: SizedBox(
          width: 900,
          height: 760,
          child: _grid(sizing: GridSizing.shrinkWrap, pageSize: 5),
        ),
      );
      expect(_gridHeight(tester), lessThan(760));
      expect(find.text('Person 5'), findsOneWidget);
      expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);
    });
  });

  group('fixed and auto behaviour', () {
    testWidgets('fixed height is unchanged', (tester) async {
      await _pump(
        tester,
        child: SizedBox(
          width: 900,
          height: 760,
          child: _grid(height: 420, pageSize: 10),
        ),
      );
      expect(_gridHeight(tester), closeTo(420, 2));
    });
  });

  group('infinite scroll bounds', () {
    testWidgets('stays within min and max in a bounded parent', (
      tester,
    ) async {
      await _pump(
        tester,
        child: SizedBox(
          width: 900,
          height: 500,
          child: _grid(
            pagingMode: PagingMode.infiniteScroll,
            minHeight: 200,
            maxHeight: 360,
          ),
        ),
      );
      expect(_gridHeight(tester), closeTo(360, 2));
      expect(find.byKey(const ValueKey('rdg-pager')), findsNothing);
      expect(find.text('Person 1'), findsOneWidget);
    });

    testWidgets('fills parent when it sits between min and max', (
      tester,
    ) async {
      await _pump(
        tester,
        child: SizedBox(
          width: 900,
          height: 320,
          child: _grid(
            pagingMode: PagingMode.infiniteScroll,
            minHeight: 200,
            maxHeight: 500,
          ),
        ),
      );
      expect(_widgetHeight(tester), closeTo(320, 4));
    });

    testWidgets('unbounded parent uses minHeight and does not throw', (
      tester,
    ) async {
      await _pump(
        tester,
        child: ListView(
          children: [
            const SizedBox(height: 24, child: Text('Above')),
            _grid(
              pagingMode: PagingMode.infiniteScroll,
              minHeight: 240,
              maxHeight: 400,
            ),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      expect(_gridHeight(tester), closeTo(240, 2));
      expect(find.byKey(const ValueKey('rdg-pager')), findsNothing);
      expect(find.text('Person 1'), findsOneWidget);
    });
  });

  group('serverSide fill', () {
    testWidgets('client and server fill share the same host height rule', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final people = _people(30);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                ResponsiveDataGrid<_Person>.serverSide(
                  pagingMode: PagingMode.pager,
                  sizing: GridSizing.fill,
                  pageSize: 8,
                  columns: _columns(),
                  loadData: (criteria) async {
                    final skip = criteria.skip ?? 0;
                    final take = criteria.take ?? 8;
                    return ListResponse<_Person>(
                      totalCount: people.length,
                      items: people.skip(skip).take(take).toList(),
                      aggregates: const [],
                      groups: const [],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      expect(find.text('Person 1'), findsOneWidget);
      expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);
      expect(_gridHeight(tester), greaterThan(200));
    });
  });
}
