import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;
  final String extra;

  const _Person(this.id, this.name, this.extra);
}

List<GridColumn<_Person, dynamic>> _wideColumns() {
  return [
    IntColumn<_Person>(
      fieldName: 'id',
      header: const ColumnHeader(text: 'Id'),
      value: (row) => row.id,
      xsCols: 2,
    ),
    StringColumn<_Person>(
      fieldName: 'name',
      header: const ColumnHeader(text: 'Name', showAggregations: true),
      value: (row) => row.name,
      xsCols: 5,
      aggregations: const [
        AggregateCriteria(
          fieldName: 'name',
          aggregation: Aggregations.count,
        ),
      ],
    ),
    StringColumn<_Person>(
      fieldName: 'dob',
      header: const ColumnHeader(text: 'Date of Birth'),
      value: (row) => row.extra,
      xsCols: 4,
    ),
    StringColumn<_Person>(
      fieldName: 'accepted',
      header: const ColumnHeader(text: 'Accepted'),
      value: (row) => row.extra,
      xsCols: 3,
    ),
    StringColumn<_Person>(
      fieldName: 'enum',
      header: const ColumnHeader(text: 'Enum'),
      value: (row) => row.extra,
      xsCols: 4,
    ),
  ];
}

Future<void> _pumpGrid(
  WidgetTester tester, {
  required Size size,
  required List<_Person> items,
  GridLayoutMode layoutMode = GridLayoutMode.table,
  double? height,
  bool aggregates = false,
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
            height: height ?? size.height - 24,
            pagingMode: PagingMode.pager,
            pageSize: 50,
            layoutMode: layoutMode,
            allowAggregations: aggregates,
            initialLoadCriteria: aggregates
                ? LoadCriteria(
                    aggregates: const [
                      AggregateCriteria(
                        fieldName: 'name',
                        aggregation: Aggregations.count,
                      ),
                    ],
                  )
                : null,
            items: items,
            columns: _wideColumns(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

Finder _horizontalScroll() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is SingleChildScrollView &&
        widget.scrollDirection == Axis.horizontal,
  );
}

void main() {
  testWidgets('table mode keeps header cells aligned with body cells', (
    tester,
  ) async {
    await _pumpGrid(
      tester,
      size: const Size(400, 700),
      items: const [_Person(1, 'Ada', 'Yes')],
    );

    final header = tester.getRect(find.byKey(const ValueKey('rdg-header-cell-id')));
    final body = tester.getRect(find.text('1').first);

    expect(body.left, greaterThanOrEqualTo(header.left - 1));
    expect(body.right, lessThanOrEqualTo(header.right + 1));
  });

  testWidgets('table mode keeps the header stuck while the body scrolls', (
    tester,
  ) async {
    final items = [
      for (var i = 0; i < 30; i++)
        _Person(i, 'Person ${i.toString().padLeft(2, '0')}', 'Yes'),
    ];

    await _pumpGrid(
      tester,
      size: const Size(800, 360),
      height: 320,
      items: items,
    );

    expect(find.text('Person 00'), findsOneWidget);
    final headerY = tester.getTopLeft(find.text('Id').first).dy;

    final bodyScrollable = find.descendant(
      of: find.byType(ResponsiveDataGridPagedBodyWidget<_Person>),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Person 29'),
      80,
      scrollable: bodyScrollable,
    );
    await tester.pumpAndSettle();

    expect(find.text('Id'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Id').first).dy,
      closeTo(headerY, 1),
      reason: 'header scrolled away with the body',
    );
    expect(
      find.text('Person 00'),
      findsNothing,
      reason: 'first row should leave the body viewport',
    );
    expect(find.text('Person 29'), findsOneWidget);
  });

  testWidgets(
    'table mode horizontal scroll keeps header, body, and footer columns aligned',
    (tester) async {
      await _pumpGrid(
        tester,
        size: const Size(400, 700),
        items: const [_Person(1, 'Ada', 'Yes')],
        aggregates: true,
      );

      await tester.drag(_horizontalScroll(), const Offset(-40, 0));
      await tester.pumpAndSettle();

      final header = tester.getRect(
        find.byKey(const ValueKey('rdg-header-cell-id')),
      );
      final body = tester.getRect(find.text('1').first);
      final nameHeader = tester.getRect(
        find.byKey(const ValueKey('rdg-header-cell-name')),
      );
      final footer = tester.getRect(find.textContaining('Count:').first);

      expect(body.left, greaterThanOrEqualTo(header.left - 1));
      expect(body.right, lessThanOrEqualTo(header.right + 1));
      expect(footer.left, greaterThanOrEqualTo(nameHeader.left - 2));
      expect(footer.right, lessThanOrEqualTo(nameHeader.right + 24));
    },
  );

  testWidgets('reflow mode wraps columns that exceed 12 segments', (
    tester,
  ) async {
    await _pumpGrid(
      tester,
      size: const Size(390, 844),
      items: const [_Person(1, 'Ada', 'Yes')],
      layoutMode: GridLayoutMode.reflow,
    );

    final id = tester.getTopLeft(find.text('Id').first);
    final enumHeader = tester.getTopLeft(find.text('Enum').first);

    expect(
      enumHeader.dy,
      isNot(closeTo(id.dy, 2)),
      reason: 'reflow should wrap Enum onto a second header row',
    );
  });

  test(
    'gridTableMetrics uses viewport width in reflow and expands in table',
    () {
      final columns = _wideColumns();
      const viewport = 400.0;

      final table = gridTableMetrics<_Person>(
        columns: columns,
        viewportWidth: viewport,
        reactiveSegments: 12,
        screenWidth: viewport,
        layoutMode: GridLayoutMode.table,
      );
      expect(table.totalSegments, 18);
      expect(table.contentWidth, closeTo(viewport * 18 / 12, 0.001));

      final reflow = gridTableMetrics<_Person>(
        columns: columns,
        viewportWidth: viewport,
        reactiveSegments: 12,
        screenWidth: viewport,
        layoutMode: GridLayoutMode.reflow,
      );
      expect(reflow.totalSegments, 12);
      expect(reflow.contentWidth, viewport);
    },
  );
}
