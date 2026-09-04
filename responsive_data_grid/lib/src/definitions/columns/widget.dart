part of '../../../responsive_data_grid.dart';

class WidgetColumn<TItem extends Object> extends GridColumn<TItem, void> {
  WidgetColumn({
    required super.fieldName,
    required Widget Function(TItem item) widget,
    super.aggregations,
    WidgetColumnHeader? header,
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
         value: (item) {},
         customFieldWidget: widget,
         format: (value) => null,
         header: header ?? WidgetColumnHeader(),
         filterRules: NoFilterRules(),
         sortDirection: OrderDirections.notSet,
       );

  @override
  List<AggregationChooser<TItem>> getAggregations({
    required Iterable<AggregateCriteria> selected,
    required void Function(AggregateCriteria aggregate, bool value) update,
  }) => const [];

  @override
  bool get hasAggregations => false;
}

class WidgetColumnHeader extends ColumnHeader {
  WidgetColumnHeader({
    super.empty,
    super.text,
    super.alignment,
    super.textAlign,
    super.textStyle,
    super.backgroundColor,
    super.foregroundColor,
  }) : super(showFilter: false, showOrderBy: false);
}
