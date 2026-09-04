import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  final int id;
  final String name;
  final String extra;

  const _Person(this.id, this.name, this.extra);
}

List<GridColumn<_Person, dynamic>> _columns() {
  return [
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
      mediumCols: 2,
    ),
    StringColumn<_Person>(
      fieldName: 'dob',
      header: const ColumnHeader(text: 'Date of Birth'),
      value: (row) => row.extra,
      xsCols: 4,
      mediumCols: 3,
    ),
    StringColumn<_Person>(
      fieldName: 'accepted',
      header: const ColumnHeader(text: 'Accepted'),
      value: (row) => row.extra,
      xsCols: 3,
      mediumCols: 2,
    ),
    StringColumn<_Person>(
      fieldName: 'enum',
      header: const ColumnHeader(text: 'Enum'),
      value: (row) => row.extra,
      xsCols: 4,
      mediumCols: 2,
    ),
  ];
}

Future<void> _pumpAt(WidgetTester tester, Size size) async {
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
            height: size.height - 24,
            pagingMode: PagingMode.pager,
            items: const [_Person(1, 'Ada', 'Yes')],
            columns: _columns(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void _expectSingleHeaderRow(WidgetTester tester) {
  expect(tester.takeException(), isNull);
  final id = tester.getTopLeft(find.text('Id').first);
  for (final label in ['Name', 'Date of Birth', 'Accepted', 'Enum']) {
    final pos = tester.getTopLeft(find.text(label).first);
    expect(
      pos.dy,
      closeTo(id.dy, 2),
      reason: '$label wrapped off the header row',
    );
  }
  expect(
    tester.getTopLeft(find.text('Enum').first).dx,
    greaterThan(tester.getTopLeft(find.text('Id').first).dx),
  );
}

void main() {
  // Bootstrap cutovers: xs<576, sm>=576, md>=768, lg>=992, xl>=1200, xxl>=1600.
  const sizes = <String, Size>{
    'xs 400': Size(400, 700),
    'sm 600': Size(600, 700),
    'md 800': Size(800, 700),
    'lg 1000': Size(1000, 700),
    'xl 1300': Size(1300, 800),
    'xxl 1700': Size(1700, 900),
  };

  for (final entry in sizes.entries) {
    testWidgets('${entry.key}: header stays one row', (tester) async {
      await _pumpAt(tester, entry.value);
      _expectSingleHeaderRow(tester);
    });
  }
}
