import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;

  const _Person(this.id, this.name);
}

Future<ResponsiveDataGridState<_Person>> _pump(
  WidgetTester tester, {
  bool resizable = true,
  double height = 400,
  double? minHeight,
  double? maxHeight,
  PagingMode pagingMode = PagingMode.pager,
  GridStateSnapshot? initialState,
}) async {
  tester.view.physicalSize = const Size(800, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final key = GlobalKey<ResponsiveDataGridState<_Person>>();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 900,
          child: ResponsiveDataGrid<_Person>.clientSide(
            key: key,
            height: height,
            resizable: resizable,
            minHeight: minHeight,
            maxHeight: maxHeight,
            pagingMode: pagingMode,
            initialState: initialState,
            items: const [
              _Person(1, 'Ada'),
              _Person(2, 'Grace'),
              _Person(3, 'Alan'),
            ],
            columns: [
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
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return key.currentState!;
}

void main() {
  test('clampGridHeight honors min and max', () {
    expect(clampGridHeight(50, minHeight: 100, maxHeight: 400), 100);
    expect(clampGridHeight(500, minHeight: 100, maxHeight: 400), 400);
    expect(clampGridHeight(200, minHeight: 100, maxHeight: 400), 200);
    expect(clampGridHeight(10, minHeight: 50, maxHeight: 400), 50);
    expect(clampGridHeight(10, maxHeight: 60), 60);
  });

  testWidgets('resize handle is omitted when resizable is false', (
    tester,
  ) async {
    await _pump(tester, resizable: false);
    expect(find.byKey(const ValueKey('rdg-resize-handle')), findsNothing);
  });

  testWidgets('dragging the handle changes grid height', (tester) async {
    await _pump(tester, height: 400);
    final before = tester.getSize(find.byKey(const ValueKey('rdg-height')));

    final handle = find.byKey(const ValueKey('rdg-resize-handle'));
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await gesture.moveBy(const Offset(0, 80));
    await gesture.up();
    await tester.pump();

    final after = tester.getSize(find.byKey(const ValueKey('rdg-height')));
    expect(after.height, closeTo(before.height + 80, 4));
    expect(find.text('Ada'), findsOneWidget);
  });

  testWidgets('resize honors maxHeight', (tester) async {
    await _pump(tester, height: 400, maxHeight: 430);
    final before = tester.getSize(find.byKey(const ValueKey('rdg-height')));

    await tester.drag(
      find.byKey(const ValueKey('rdg-resize-handle')),
      const Offset(0, 200),
    );
    await tester.pump();

    final after = tester.getSize(find.byKey(const ValueKey('rdg-height')));
    expect(after.height, closeTo(430, 4));
    expect(after.height, greaterThan(before.height));
  });

  testWidgets('resize honors minHeight', (tester) async {
    await _pump(tester, height: 400, minHeight: 360);
    await tester.drag(
      find.byKey(const ValueKey('rdg-resize-handle')),
      const Offset(0, -200),
    );
    await tester.pump();
    expect(
      tester.getSize(find.byKey(const ValueKey('rdg-height'))).height,
      closeTo(360, 4),
    );
  });

  testWidgets('resized pager grid still shows the pager', (tester) async {
    await _pump(tester, height: 400, pagingMode: PagingMode.pager);
    await tester.drag(
      find.byKey(const ValueKey('rdg-resize-handle')),
      const Offset(0, 60),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
  });

  testWidgets('resized infinite-scroll grid still shows rows', (tester) async {
    await _pump(tester, height: 400, pagingMode: PagingMode.infiniteScroll);
    await tester.drag(
      find.byKey(const ValueKey('rdg-resize-handle')),
      const Offset(0, 60),
    );
    await tester.pump();
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Grace'), findsOneWidget);
  });

  testWidgets('initialState restores height', (tester) async {
    await _pump(
      tester,
      height: 400,
      initialState: GridStateSnapshot(
        pageNumber: 1,
        pageSize: 50,
        criteria: LoadCriteria(),
        columns: const [],
        height: 320,
      ),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('rdg-height'))).height,
      closeTo(320, 4),
    );
  });

  test('snapshot JSON round-trips height', () {
    final snapshot = GridStateSnapshot(
      pageNumber: 1,
      pageSize: 50,
      criteria: LoadCriteria(),
      columns: [],
      height: 360,
    );
    expect(GridStateSnapshot.fromJson(snapshot.toJson()).height, 360);
  });
}
