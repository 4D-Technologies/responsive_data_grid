import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

class _Person {
  const _Person();
}

void main() {
  test('WidgetColumn keeps a stable fieldName and has no aggregations', () {
    final col = WidgetColumn<_Person>(
      fieldName: 'selected',
      widget: (_) => const SizedBox(),
    );

    expect(col.fieldName, 'selected');
    expect(col.hasAggregations, isFalse);
    expect(
      col.getAggregations(selected: const [], update: (_, _) {}),
      isEmpty,
    );
  });
}
