part of '../../../responsive_data_grid.dart';

/// A non-data column for row actions. It does not sort, filter, group, or
/// aggregate. Prefer [sticky] at the trailing edge to keep it in view.
class CommandColumn<TItem extends Object> extends GridColumn<TItem, void> {
  final Widget Function(BuildContext context, TItem item) builder;

  CommandColumn({
    required super.fieldName,
    required this.builder,
    ColumnHeader? header,
    super.width,
    super.minWidth,
    super.maxWidth,
    super.visible,
    super.frozen,
    super.sticky,
    super.autoSize,
    super.xlCols,
    super.largeCols,
    super.mediumCols,
    super.smallCols,
    super.xsCols,
    super.textStyle,
    super.backgroundColor,
    super.foregroundColor,
    super.accentColor,
    AlignmentGeometry super.alignment = AlignmentDirectional.center,
  }) : super(
         value: (item) {},
         customFieldWidget: (item) => null,
         format: (value) => null,
         header: header ?? CommandColumnHeader(),
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

  @override
  bool get participatesInGrouping => false;
}

class CommandColumnHeader extends ColumnHeader {
  CommandColumnHeader({
    super.empty,
    super.text,
    super.alignment,
    super.textAlign,
    super.textStyle,
    super.backgroundColor,
    super.foregroundColor,
  }) : super(showFilter: false, showOrderBy: false, showAggregations: false);
}
