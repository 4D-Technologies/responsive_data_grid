import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String street;
  final String city;

  const _Person(this.id, this.street, this.city);
}

Future<void> _pump(
  WidgetTester tester, {
  void Function(_Person item)? onAction,
  GridLayoutMode layoutMode = GridLayoutMode.table,
}) async {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 900,
          height: 700,
          child: ResponsiveDataGrid<_Person>.clientSide(
            height: 400,
            pagingMode: PagingMode.pager,
            layoutMode: layoutMode,
            headerGroups: const [
              GridHeaderGroup(
                title: 'Address',
                fieldNames: ['street', 'city'],
              ),
            ],
            items: const [_Person(1, 'Main', 'Boston')],
            columns: [
              IntColumn<_Person>(
                fieldName: 'id',
                header: const ColumnHeader(text: 'Id'),
                value: (row) => row.id,
                xsCols: 2,
                width: 80,
              ),
              StringColumn<_Person>(
                fieldName: 'street',
                header: const ColumnHeader(text: 'Street'),
                value: (row) => row.street,
                xsCols: 4,
                width: 160,
              ),
              StringColumn<_Person>(
                fieldName: 'city',
                header: const ColumnHeader(text: 'City'),
                value: (row) => row.city,
                xsCols: 4,
                width: 140,
              ),
              CommandColumn<_Person>(
                fieldName: 'actions',
                header: const ColumnHeader(text: 'Actions'),
                width: 80,
                xsCols: 2,
                builder: (context, item) => IconButton(
                  key: ValueKey('rdg-command-${item.id}'),
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => onAction?.call(item),
                ),
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

void main() {
  testWidgets('stacked header shows the group title in table mode', (
    tester,
  ) async {
    await _pump(tester);
    expect(
      find.byKey(const ValueKey('rdg-header-group-Address-street')),
      findsOneWidget,
    );
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Street'), findsOneWidget);
    expect(find.text('City'), findsOneWidget);

    final group = tester.getSize(
      find.byKey(const ValueKey('rdg-header-group-Address-street')),
    );
    final street = tester.getSize(
      find.byKey(const ValueKey('rdg-header-cell-street')),
    );
    final city = tester.getSize(
      find.byKey(const ValueKey('rdg-header-cell-city')),
    );
    expect(group.width, closeTo(street.width + city.width, 2));
  });

  testWidgets('command column runs a row action', (tester) async {
    _Person? tapped;
    await _pump(tester, onAction: (item) => tapped = item);
    await tester.tap(find.byKey(const ValueKey('rdg-command-1')));
    await tester.pump();
    expect(tapped?.street, 'Main');
  });

  testWidgets('reflow layout shows leaf headers without the group row', (
    tester,
  ) async {
    await _pump(tester, layoutMode: GridLayoutMode.reflow);
    expect(find.byKey(const ValueKey('rdg-header-group-Address')), findsNothing);
    expect(find.text('Street'), findsOneWidget);
  });
}
