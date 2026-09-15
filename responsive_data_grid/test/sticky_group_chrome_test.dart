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

Future<void> _pumpNarrowGroupedGrid(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 700,
          child: ResponsiveDataGrid<_Person>.clientSide(
            height: 600,
            pagingMode: PagingMode.pager,
            allowGrouping: true,
            allowAggregations: true,
            initialLoadCriteria: LoadCriteria(
              groupBy: [
                GroupCriteria(
                  fieldName: 'name',
                  direction: OrderDirections.ascending,
                  aggregates: const [
                    AggregateCriteria(
                      fieldName: 'name',
                      aggregation: Aggregations.count,
                    ),
                  ],
                ),
              ],
              aggregates: const [
                AggregateCriteria(
                  fieldName: 'name',
                  aggregation: Aggregations.count,
                ),
              ],
            ),
            items: const [
              _Person(1, 'Ada', 'Yes'),
              _Person(2, 'Ada', 'No'),
              _Person(3, 'Grace', 'Yes'),
            ],
            columns: [
              IntColumn<_Person>(
                fieldName: 'id',
                header: const ColumnHeader(text: 'Id'),
                value: (row) => row.id,
                xsCols: 2,
              ),
              StringColumn<_Person>(
                fieldName: 'name',
                header: const ColumnHeader(
                  text: 'Name',
                  showAggregations: true,
                ),
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
            ],
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
  testWidgets(
    'group title stays in the viewport and Count footer tracks its column',
    (tester) async {
      await _pumpNarrowGroupedGrid(tester);

      final groupTitle = find.descendant(
        of: find.byType(GridGroupHeader),
        matching: find.text('Ada'),
      );
      final countFooter = find.descendant(
        of: find.byType(GridFooter<_Person>),
        matching: find.textContaining('Count:'),
      );
      expect(groupTitle, findsOneWidget);
      expect(countFooter, findsWidgets);

      expect(tester.getTopLeft(groupTitle).dx, greaterThanOrEqualTo(0));

      await tester.drag(_horizontalScroll(), const Offset(-40, 0));
      await tester.pumpAndSettle();

      final groupAfter = tester.getTopLeft(groupTitle);
      expect(
        groupAfter.dx,
        greaterThanOrEqualTo(-1),
        reason: 'group title scrolled off the left edge',
      );
      expect(groupAfter.dx, lessThan(400));

      final nameHeader = tester.getRect(
        find.byKey(const ValueKey('rdg-header-cell-name')),
      );
      final countAfter = tester.getRect(countFooter.first);
      expect(
        countAfter.left,
        greaterThanOrEqualTo(nameHeader.left - 2),
        reason: 'Count footer should travel with the Name column',
      );
      expect(
        countAfter.right,
        lessThanOrEqualTo(nameHeader.right + 24),
        reason: 'Count footer should travel with the Name column',
      );
    },
  );
}
