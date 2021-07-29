part of responsive_data_grid;

class DataGridFieldWidget<TItem extends dynamic> extends StatelessWidget {
  final ColumnDefinition<TItem> definition;
  final TItem item;
  DataGridFieldWidget(this.definition, this.item) {
    assert(TItem != dynamic);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? child;
    if (definition.customFieldWidget != null &&
        definition.customFieldWidget!(item) == null) {
      child = Container();
    } else if (definition.customFieldWidget != null &&
        definition.customFieldWidget!(item) != null) {
      child = definition.customFieldWidget!(item)!;
    } else {
      child = Text(
        definition.value!(item)?.toString() ?? '',
        style: theme.textTheme.bodyText1,
      );
    }

    return Align(
      alignment: definition.alignment ?? Alignment.centerLeft,
      child: child,
    );
  }
}
