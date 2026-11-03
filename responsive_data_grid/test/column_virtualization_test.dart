import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final Map<String, String> values;
  const _Person(this.values);
}

void main() {
  testWidgets('off-screen columns are not built in table mode', (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final columns = <GridColumn<_Person, dynamic>>[
      for (var i = 0; i < 20; i++)
        StringColumn<_Person>(
          fieldName: 'c$i',
          header: ColumnHeader(text: 'C$i'),
          value: (row) => row.values['c$i'],
          xsCols: 4,
          width: 120,
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 500,
            child: ResponsiveDataGrid<_Person>.clientSide(
              height: 400,
              pagingMode: PagingMode.pager,
              layoutMode: GridLayoutMode.table,
              items: [
                _Person({for (var i = 0; i < 20; i++) 'c$i': 'v$i'}),
              ],
              columns: columns,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    int cellKeys(String field) => find
        .byWidgetPredicate((widget) {
          final key = widget.key;
          return key is ValueKey<String> &&
              key.value.startsWith('rdg-cell-$field-');
        })
        .evaluate()
        .length;

    expect(cellKeys('c0'), greaterThan(0));
    expect(cellKeys('c19'), 0);
    expect(find.text('v0'), findsOneWidget);
    expect(find.text('v19'), findsNothing);

    await tester.drag(
      find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.horizontal,
      ),
      const Offset(-2000, 0),
    );
    await tester.pumpAndSettle();
    expect(cellKeys('c19'), greaterThan(0));
    expect(find.text('v19'), findsOneWidget);
  });
}
