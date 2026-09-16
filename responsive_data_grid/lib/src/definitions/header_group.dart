part of '../../responsive_data_grid.dart';

/// A stacked header that spans one or more leaf columns in table layout.
class GridHeaderGroup {
  final String title;
  final List<String> fieldNames;

  const GridHeaderGroup({required this.title, required this.fieldNames});
}

class HeaderGroupSpan {
  final String title;
  final double width;

  const HeaderGroupSpan({required this.title, required this.width});
}

List<HeaderGroupSpan> headerGroupSpans({
  required List<GridColumn<dynamic, dynamic>> columns,
  required List<double> widths,
  required List<GridHeaderGroup> groups,
}) {
  final spans = <HeaderGroupSpan>[];
  var i = 0;
  while (i < columns.length) {
    final field = columns[i].fieldName;
    GridHeaderGroup? group;
    for (final candidate in groups) {
      if (candidate.fieldNames.contains(field)) {
        group = candidate;
        break;
      }
    }
    if (group == null) {
      spans.add(
        HeaderGroupSpan(
          title: '',
          width: i < widths.length ? widths[i] : 0,
        ),
      );
      i++;
      continue;
    }
    var width = 0.0;
    while (i < columns.length && group.fieldNames.contains(columns[i].fieldName)) {
      width += i < widths.length ? widths[i] : 0;
      i++;
    }
    spans.add(HeaderGroupSpan(title: group.title, width: width));
  }
  return spans;
}
