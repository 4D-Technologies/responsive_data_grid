part of '../../../responsive_data_grid.dart';

class DoubleColumn<TItem extends Object> extends GridColumn<TItem, double> {
  DoubleColumn({
    required super.fieldName,
    ColumnHeader? header,
    super.customFieldWidget,
    required super.value,
    DoubleFilterRules<TItem>? filterRules,
    super.sortDirection,
    super.aggregations,
    intl.NumberFormat? format,
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
         format: (value) =>
             format?.format(value) ?? intl.NumberFormat().format(value),
         header: header ?? ColumnHeader(),
         filterRules: filterRules ?? DoubleFilterRules<TItem>(),
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
