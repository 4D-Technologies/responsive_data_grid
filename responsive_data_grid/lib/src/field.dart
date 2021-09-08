part of responsive_data_grid;

class DataGridFieldWidget<TItem extends Object, TValue extends dynamic>
    extends StatelessWidget {
  final ColumnDefinition<TItem, TValue> definition;
  final TItem item;
  DataGridFieldWidget(this.definition, this.item) {
    assert(TItem != dynamic);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveDataTextStyle = definition.textStyle ??
        theme.dataTableTheme.dataTextStyle ??
        theme.textTheme.bodyText2!;

    Widget? child;
    if (definition.customFieldWidget != null) {
      child = DefaultTextStyle(
        style: effectiveDataTextStyle,
        child: definition.customFieldWidget!(item) ?? Container(),
      );
    } else {
      final value = definition.value(item);
      if (value == null) {
        child = Container();
      } else {
        late String stringValue;

        if (definition.format == null) {
          if (value is TimeOfDay)
            stringValue = value.format(context);
          else
            stringValue = value.toString();
        } else {
          if (value is DateTime)
            stringValue = DateFormat(definition.format).format(value);
          else if (value is num)
            stringValue = NumberFormat(definition.format).format(value);
          else if (value is bool) {
            final trueValue = definition.format!
                .substring(0, definition.format!.indexOf("|"));
            final falseValue = definition.format!
                .substring(definition.format!.indexOf("|") + 1);
            stringValue = value ? trueValue : falseValue;
          } else
            throw UnsupportedError(
                "The format is specified but the type ${TValue} cannot be formatted.");
        }

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
