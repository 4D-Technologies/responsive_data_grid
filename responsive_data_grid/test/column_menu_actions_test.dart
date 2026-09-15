import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;

  const _Person(this.id, this.name);
}

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 900,
          height: 600,
          child: ResponsiveDataGrid<_Person>.clientSide(
            height: 500,
            pagingMode: PagingMode.pager,
            sortable: SortableOptions.single,
            items: const [
              _Person(2, 'Zoe'),
              _Person(1, 'Ada'),
              _Person(3, 'Mia'),
            ],
            columns: [
              IntColumn<_Person>(
                fieldName: 'id',
                header: const ColumnHeader(text: 'Id', showFilter: true),
                value: (row) => row.id,
                xsCols: 4,
              ),
              StringColumn<_Person>(
                fieldName: 'name',
                header: const ColumnHeader(
                  text: 'Name',
                  showFilter: true,
                  showOrderBy: true,
                ),
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
}

Future<void> _openNameMenu(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('rdg-header-menu-name')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('column menu exposes sort, pin, hide, and autosize', (
    tester,
  ) async {
    await _pump(tester);
    await _openNameMenu(tester);

    expect(find.text(GridLocalizations.en.sortAscending), findsOneWidget);
    expect(find.text(GridLocalizations.en.sortDescending), findsOneWidget);
    expect(find.text(GridLocalizations.en.pinLeft), findsOneWidget);
    expect(find.text(GridLocalizations.en.hideColumn), findsOneWidget);
    expect(find.text(GridLocalizations.en.autosizeColumn), findsOneWidget);
    expect(find.text(GridLocalizations.en.apply), findsOneWidget);
  });

  testWidgets('sort ascending from the menu orders rows', (tester) async {
    await _pump(tester);
    await _openNameMenu(tester);
    await tester.tap(find.text(GridLocalizations.en.sortAscending));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final ada = tester.getTopLeft(find.text('Ada').first);
    final zoe = tester.getTopLeft(find.text('Zoe').first);
    expect(ada.dy, lessThan(zoe.dy));
  });

  testWidgets('hide column from the menu removes the header', (tester) async {
    await _pump(tester);
    await _openNameMenu(tester);
    await tester.ensureVisible(find.text(GridLocalizations.en.hideColumn));
    await tester.pump();
    await tester.tap(find.text(GridLocalizations.en.hideColumn));
    await tester.pump();

    expect(find.text('Name'), findsNothing);
    expect(find.text('Id'), findsOneWidget);
  });

  testWidgets('pin left from the menu freezes the column', (tester) async {
    await _pump(tester);
    await _openNameMenu(tester);
    await tester.ensureVisible(find.text(GridLocalizations.en.pinLeft));
    await tester.pump();
    await tester.tap(find.text(GridLocalizations.en.pinLeft));
    await tester.pump();

    expect(
      tester.getTopLeft(find.text('Name').first).dx,
      lessThan(tester.getTopLeft(find.text('Id').first).dx),
    );
  });
}
