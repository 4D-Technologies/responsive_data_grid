part of '../../../responsive_data_grid.dart';

class EnumColumn<TItem extends Object, TValue extends Enum>
    extends GridColumn<TItem, TValue> {
  final List<TValue> values;
  EnumColumn({
    required this.values,
    required super.fieldName,
    ColumnHeader? header,
    Widget? Function(TItem row)? customFieldWidget,
    required String Function(TValue e) valueText,
    required super.value,
    FilterCriteria<TValue>? filter,
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
         customFieldWidget:
             customFieldWidget ??
             (TItem row) {
               final val = value(row);
               if (val == null) return Container();

               return Text(valueText(val));
             },
         format: (value) => value == null ? null : valueText(value),
         header: header ?? ColumnHeader(),
         filterRules: ValueMapFilterRules(
           valueMap: Map<TValue, Widget>.fromEntries(
             values.map((e) => MapEntry(e, Text(valueText(e)))),
           ),
           criteria: filter,
         ),
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
