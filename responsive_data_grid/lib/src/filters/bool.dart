part of '../../responsive_data_grid.dart';

class BoolFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridBoolColumnFilter<TItem>, bool> {
  final String title;
  BoolFilterRules({String? title, super.criteria})
    : title = title ?? LocalizedMessages.state;

  @override
  DataGridBoolColumnFilter<TItem> showFilter(
    GridColumn<TItem, bool> definition,
    ResponsiveDataGridState<TItem> grid,
  ) => DataGridBoolColumnFilter(definition, grid);
}

class DataGridBoolColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, bool> {
  DataGridBoolColumnFilter(super.definition, super.grid, {super.key}) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() => DataGridBoolColumnFilterState<TItem>();
}

class DataGridBoolColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem, bool> {
  bool? value;

  @override
  initState() {
    final criteria = widget.definition.filterRules.criteria;
    if (criteria != null) {
      value = criteria.values.isNotEmpty ? criteria.values.first : null;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile(
          title: Text(LocalizedMessages.state),
          value: value,
          onChanged: (value) {
            setState(() {
              this.value = value;
              writeCriteria(
                value == null ? null : Logic.equals,
                value == null ? const [] : [value],
              );
            });
          },
          tristate: true,
        ),
      ],
    );
  }
}
