import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;
  const _Person(this.name);
}

void main() {
  test('English and Spanish packs differ for user-facing copy', () {
    expect(GridLocalizations.en.noRecords, 'No records available.');
    expect(GridLocalizations.es.noRecords, isNot(GridLocalizations.en.noRecords));
    expect(GridLocalizations.es.apply, 'Aplicar');
    expect(GridLocalizations.es.groupBy, 'Agrupar por');
    expect(
      GridLocalizations.es.pagerRange(start: 1, end: 10, total: 95),
      '1–10 de 95',
    );
  });

  testWidgets('Spanish locale shows localized empty state and group panel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        supportedLocales: GridLocalizations.supportedLocales,
        localizationsDelegates: [
          GridLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 600,
            child: ResponsiveDataGrid<_Person>.clientSide(
              height: 600,
              pagingMode: PagingMode.pager,
              allowGrouping: true,
              groupPanel: GroupPanelDisplay.always,
              items: const [],
              columns: [
                StringColumn<_Person>(
                  fieldName: 'name',
                  header: const ColumnHeader(text: 'Name', showFilter: true),
                  value: (row) => row.name,
                  xsCols: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(GridLocalizations.es.noRecords), findsOneWidget);
    expect(find.text(GridLocalizations.en.noRecords), findsNothing);
    expect(find.text(GridLocalizations.es.groupBy), findsWidgets);
  });
}
