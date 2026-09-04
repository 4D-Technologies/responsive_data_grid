part of '../../../responsive_data_grid.dart';

class TimeOfDayColumn<TItem extends Object>
    extends GridColumn<TItem, TimeOfDay> {
  TimeOfDayColumn({
    required super.fieldName,
    ColumnHeader? header,
    super.customFieldWidget,
    required super.value,
    TimeOfDayFilterRules<TItem>? filterRules,
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
    intl.DateFormat? format,
  }) : super(
         format: (value) => value == null
             ? null
             : (format ?? intl.DateFormat.jm()).format(
                 DateTime(1, 1, 1, value.hour, value.minute),
               ),
         header: header ?? ColumnHeader(),
         filterRules: filterRules ?? TimeOfDayFilterRules<TItem>(),
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
  ];

  @override
  bool get hasAggregations => true;
}
