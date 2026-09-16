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
    final theme = Theme.of(context);
    final effectiveDataTextStyle =
        definition.textStyle ??
        theme.dataTableTheme.dataTextStyle ??
        theme.gridBodyMedium;

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

    final gridTheme = ResponsiveDataGridTheme.of(context);
    return Semantics(
      label: definition.getFormattedValue(item) ?? '',
      child: Padding(
        padding: gridTheme.resolvePadding(
          const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: ClipRect(child: aligned),
      ),
    );
  }
}
