import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final String name;

  const _Person(this.name);
}

void main() {
  testWidgets(
    'server load failure clears the spinner and shows retry',
    (tester) async {
      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Object? reported;
      var attempts = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 600,
              child: ResponsiveDataGrid<_Person>.serverSide(
                height: 600,
                pagingMode: PagingMode.pager,
                onLoadError: (error, _) => reported = error,
                loadData: (criteria) async {
                  attempts++;
                  if (attempts == 1) {
                    throw StateError('backend down');
                  }
                  return ListResponse<_Person>(
                    totalCount: 1,
                    items: const [_Person('Ada')],
                    groups: const [],
                    aggregates: const [],
                  );
                },
                columns: [
                  StringColumn<_Person>(
                    fieldName: 'name',
                    header: const ColumnHeader(text: 'Name'),
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

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text(LocalizedMessages.retry), findsOneWidget);
      expect(reported, isA<StateError>());

      await tester.tap(find.text(LocalizedMessages.retry));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text(LocalizedMessages.retry), findsNothing);
      expect(find.text('Ada'), findsWidgets);
    },
  );
}
