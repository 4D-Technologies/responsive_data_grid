import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;
  final String extra;

  const _Person(this.id, this.name, this.extra);
}

void main() {
  testWidgets('phone-width header keeps all columns on one row', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResponsiveDataGrid<_Person>.clientSide(
            height: 600,
            pagingMode: PagingMode.pager,
            items: const [_Person(1, 'Ada', 'Yes')],
            columns: [
              IntColumn<_Person>(
                fieldName: 'id',
                header: const ColumnHeader(text: 'Id'),
                value: (row) => row.id,
                xsCols: 2,
              ),
              StringColumn<_Person>(
                fieldName: 'name',
                header: const ColumnHeader(text: 'Name'),
                value: (row) => row.name,
                xsCols: 5,
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
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final id = tester.getTopLeft(find.text('Id').first);
    final name = tester.getTopLeft(find.text('Name').first);
    final dob = tester.getTopLeft(find.text('Date of Birth').first);
    final accepted = tester.getTopLeft(find.text('Accepted').first);
    final enumHeader = tester.getTopLeft(find.text('Enum').first);

    expect(name.dy, closeTo(id.dy, 2));
    expect(dob.dy, closeTo(id.dy, 2));
    expect(accepted.dy, closeTo(id.dy, 2));
    expect(enumHeader.dy, closeTo(id.dy, 2));
    expect(enumHeader.dx, greaterThan(accepted.dx));
  });
}
