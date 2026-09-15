part of '../../responsive_data_grid.dart';

class StringFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridStringColumnFilter<TItem>, String> {
  final String hintText;
  StringFilterRules({String? hintText, super.criteria})
    : hintText = hintText ?? LocalizedMessages.value;

  @override
  DataGridStringColumnFilter<TItem> showFilter(
    GridColumn<TItem, String> definition,
    ResponsiveDataGridState<TItem> grid,
  ) => DataGridStringColumnFilter(definition, grid);
}

class DataGridStringColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, String> {
  DataGridStringColumnFilter(super.definition, super.grid, {super.key}) {
    assert(TItem != dynamic);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridStringColumnFilterState<TItem>();
}

class DataGridStringColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem, String> {
  Logic? op;
  String? searchText;

  DataGridStringColumnFilterState();

  @override
  void initState() {
    final criteria = widget.definition.filterRules.criteria;
    if (criteria != null) {
      op = criteria.logicalOperator;
      searchText = criteria.values.isNotEmpty
          ? criteria.values.first.toString()
          : null;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<Logic?>(
          isExpanded: true,
          elevation: 30,
          items: gridFilterLogicItems(context, gridStringFilterLogics),
          initialValue: op,
          onChanged: (Logic? value) {
            setState(() {
              op = value;
              writeCriteria(
                op,
                searchText == null || searchText!.isEmpty ? [] : [searchText!],
              );
            });
          },
        ),
        Visibility(
          visible: op != null && gridLogicRequiresValue(op!),
          child: TextFormField(
            initialValue: searchText,
            decoration: InputDecoration(
              labelText: GridLocalizations.of(context).value,
            ),
            onChanged: (value) => setState(() {
              searchText = value;
              writeCriteria(
                op,
                searchText == null || searchText!.isEmpty ? [] : [searchText!],
              );
            }),
          ),
        ),
      ],
    );
  }
}
