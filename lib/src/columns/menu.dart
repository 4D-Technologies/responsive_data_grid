part of responsive_data_grid;

class DataGridColumnMenuWidget<TItem extends dynamic> extends StatelessWidget {
  final ColumnDefinition<TItem> definition;
  final DataGridState<TItem> grid;
  DataGridColumnMenuWidget(this.definition, this.grid) {
    assert(TItem != dynamic);
  }

  @override
  Widget build(BuildContext context) {
    if (definition.header.filterRules.customFilter != null) {
      return definition.header.filterRules.customFilter!;
    } else if (definition.header.filterRules.valueMap != null) {
      return DataGridValuesColumnFilter(definition, grid);
    } else if (definition.fieldType == String) {
      return DataGridStringColumnFilter(definition, grid);
    } else if (definition.fieldType == int) {
      return DataGridIntColumnFilter(definition, grid);
    } else if (definition.fieldType == double) {
      return DataGridDoubleColumnFilter(definition, grid);
    } else if (definition.fieldType == bool) {
      return DataGridBoolColumnFilter(definition, grid);
    } else if (definition.fieldType == DateTime) {
      return DataGridDateTimeColumnFilter(definition, grid);
    } else {
      throw UnsupportedError(
          "${definition.fieldType.toString()} does not have a built in filter");
    }
  }
}
