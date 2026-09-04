import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

void main() {
  test('copyWith showOrderBy does not copy showFilter', () {
    const header = ColumnHeader(showFilter: true, showOrderBy: false);

    final copied = header.copyWith();

    expect(copied.showFilter, isTrue);
    expect(copied.showOrderBy, isFalse);
  });

  test('equality and hashCode include showAggregations', () {
    const withAgg = ColumnHeader(text: 'Id', showAggregations: true);
    const withoutAgg = ColumnHeader(text: 'Id', showAggregations: false);

    expect(withAgg == withoutAgg, isFalse);
    expect(withAgg.hashCode, isNot(withoutAgg.hashCode));
    expect(withAgg, const ColumnHeader(text: 'Id', showAggregations: true));
  });

  test('toString includes filter, order, and aggregations flags', () {
    const header = ColumnHeader(
      text: 'Name',
      showFilter: true,
      showOrderBy: true,
      showAggregations: true,
    );

    final text = header.toString();
    expect(text, contains('showFilter: true'));
    expect(text, contains('showOrderBy: true'));
    expect(text, contains('showAggregations: true'));
    expect(text, isNot(contains('showMenu')));
  });
}
