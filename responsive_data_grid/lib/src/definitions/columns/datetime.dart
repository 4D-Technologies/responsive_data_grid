part of '../../../responsive_data_grid.dart';

class DateTimeColumn<TItem extends Object> extends GridColumn<TItem, DateTime> {
  DateTimeColumn({
    required super.fieldName,
    ColumnHeader? header,
    super.customFieldWidget,
    required super.value,
    DateTimeFilterRules<TItem>? filterRules,
    super.sortDirection,
    super.aggregations,
    intl.DateFormat? format,
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
         format: (value) => value == null
             ? null
             : format?.format(value) ?? intl.DateFormat().format(value),
         header: header ?? ColumnHeader(),
         filterRules:
             filterRules ??
             DateTimeFilterRules<TItem>(
               filterType: DateTimeFilterTypes.DateTime,
             ),
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
