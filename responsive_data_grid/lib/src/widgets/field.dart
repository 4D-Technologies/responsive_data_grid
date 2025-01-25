part of responsive_data_grid;

class DataGridFieldWidget<TItem extends Object, TValue extends dynamic>
    extends StatelessWidget {
  final GridColumn<TItem, TValue> definition;
  final TItem item;
  DataGridFieldWidget(this.definition, this.item) {
    assert(TItem != dynamic);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveDataTextStyle = definition.textStyle ??
        theme.dataTableTheme.dataTextStyle ??
        theme.primaryTextTheme.bodyMedium!;

    Widget? child;
    if (definition.customFieldWidget != null) {
      child = DefaultTextStyle(
        style: effectiveDataTextStyle,
        child: definition.customFieldWidget!(item) ?? Container(),
      );
    } else {
      final stringValue = definition.getFormattedValue(item);
      if (stringValue == null) {
        child = Container();
      } else {
        child = Text(
          stringValue,
          style: effectiveDataTextStyle,
        );
      }
    }

    return Align(
      alignment: definition.alignment ?? Alignment.centerLeft,
      child: child,
    );
  }
}
