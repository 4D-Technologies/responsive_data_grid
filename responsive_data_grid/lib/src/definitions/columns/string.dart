part of '../../../responsive_data_grid.dart';

class StringColumn<TItem extends Object> extends GridColumn<TItem, String> {
  StringColumn({
    required super.fieldName,
    ColumnHeader? header,
    super.customFieldWidget,
    required super.value,
    StringFilterRules<TItem>? filterRules,
    super.aggregations,
    super.sortDirection,
    super.width,
    super.minWidth,
    super.maxWidth,
    super.xlCols,
    super.largeCols,
    super.mediumCols,
    super.smallCols,
    super.xsCols,
    super.textStyle,
    super.backgroundColor,
    super.foregroundColor,
    super.accentColor,
    AlignmentGeometry super.alignment = Alignment.centerLeft,
  }) : super(
         format: (value) => value,
         header: header ?? ColumnHeader(),
         filterRules: filterRules ?? StringFilterRules<TItem>(),
       );

  @override
  List<AggregationChooser<TItem>> getAggregations({
    required Iterable<AggregateCriteria> selected,
    required void Function(AggregateCriteria aggregate, bool value) update,
  }) => [
    AggregationChooser(
      column: this,
      aggregation: Aggregations.count,
      selected: selected,
      update: update,
    ),
  ];

  @override
  bool get hasAggregations => true;
}
