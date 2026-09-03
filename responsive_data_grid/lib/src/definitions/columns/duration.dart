part of '../../../responsive_data_grid.dart';

class DurationColumn<TItem extends Object> extends GridColumn<TItem, Duration> {
  DurationColumn({
    required super.fieldName,
    ColumnHeader? header,
    super.customFieldWidget,
    required super.value,
    DurationFilterRules<TItem>? filterRules,
    super.sortDirection,
    super.aggregations,
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
         header: header ?? ColumnHeader(),
         format: (value) => value?.toString() ?? '',
         filterRules: filterRules ?? DurationFilterRules<TItem>(),
       );

  @override
  List<AggregationChooser<TItem>> getAggregations({
    required Iterable<AggregateCriteria> selected,
    required void Function(AggregateCriteria aggregate, bool value) update,
  }) => [
    AggregationChooser(
      column: this,
      aggregation: Aggregations.average,
      selected: selected,
      update: update,
    ),
    AggregationChooser(
      column: this,
      aggregation: Aggregations.maximum,
      selected: selected,
      update: update,
    ),
    AggregationChooser(
      column: this,
      aggregation: Aggregations.minimum,
      selected: selected,
      update: update,
    ),
    AggregationChooser(
      column: this,
      aggregation: Aggregations.sum,
      selected: selected,
      update: update,
    ),
  ];

  @override
  bool get hasAggregations => true;
}
