part of '../../responsive_data_grid.dart';

class DataGridFieldWidget<TItem extends Object, TValue extends dynamic>
    extends StatelessWidget {
  final GridColumn<TItem, TValue> definition;
  final TItem item;
  DataGridFieldWidget(this.definition, this.item, {super.key}) {
    assert(TItem != dynamic);
  }

  @override
  Widget build(BuildContext context) {
    final gridTheme = ResponsiveDataGridTheme.of(context);
    final effectiveDataTextStyle =
        definition.textStyle ?? gridTheme.body.textStyle;

    Widget? child;
    if (definition is CommandColumn<TItem>) {
      child = (definition as CommandColumn<TItem>).builder(context, item);
    } else if (definition.customFieldWidget != null) {
      child = DefaultTextStyle(
        style: effectiveDataTextStyle,
        child: definition.customFieldWidget!(item) ?? SizedBox(),
      );
    } else {
      final stringValue = definition.getFormattedValue(item);
      if (stringValue == null) {
        child = SizedBox();
      } else {
        child = Text(
          stringValue,
          style: effectiveDataTextStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }
    }

    final grid = context
        .findAncestorWidgetOfExactType<ResponsiveDataGrid<TItem>>();
    final cellDecoration = grid?.cellDecoration?.call(item, definition);
    Widget aligned = Align(
      alignment: definition.alignment ?? AlignmentDirectional.centerStart,
      child: child,
    );
    if (cellDecoration != null) {
      aligned = DecoratedBox(decoration: cellDecoration, child: aligned);
    }

    final cellPad =
        grid?.contentPaddingOf(gridTheme) ?? gridTheme.body.contentPadding;
    return Semantics(
      label: definition.getFormattedValue(item) ?? '',
      child: Padding(
        padding: gridTheme.resolvePadding(cellPad),
        child: ClipRect(child: aligned),
      ),
    );
  }
}
