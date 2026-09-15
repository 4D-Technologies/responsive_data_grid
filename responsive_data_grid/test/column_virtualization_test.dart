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

    final headerKeys = find
        .byWidgetPredicate(
          (widget) =>
              widget.key is ValueKey<String> &&
              (widget.key as ValueKey<String>).value.startsWith(
                'rdg-header-cell-',
              ),
        )
        .evaluate()
        .length;
    expect(headerKeys, greaterThan(0));
    expect(headerKeys, lessThan(20));
    expect(find.text('C0'), findsOneWidget);
    expect(find.text('C19'), findsNothing);
  });
}
