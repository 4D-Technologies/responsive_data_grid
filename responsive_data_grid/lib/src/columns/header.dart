part of responsive_data_grid;

class ColumnHeaderWidget<TItem extends Object> extends StatefulWidget {
  final ColumnDefinition<TItem> definition;
  final ResponsiveDataGridState<TItem> grid;

  ColumnHeaderWidget(this.grid, this.definition) {
    assert(TItem != dynamic);
  }

  @override
  State<StatefulWidget> createState() => ColumnHeaderState<TItem>(
        alignment: definition.header.alignment,
        textAlign: definition.header.textAlign,
        filterRules: definition.header.filterRules,
        orderRules: definition.header.orderRules,
        showMenu: definition.header.showMenu ?? false,
      );
}

class ColumnHeaderState<TItem extends Object>
    extends State<ColumnHeaderWidget<TItem>> {
  AlignmentGeometry? alignment;
  TextAlign? textAlign;
  FilterRules<TItem, DataGridColumnFilter<TItem>> filterRules;
  OrderRules orderRules;
  bool showMenu;

  ColumnHeaderState({
    required this.alignment,
    required this.textAlign,
    required this.filterRules,
    required this.orderRules,
    required this.showMenu,
  }) {
    assert(TItem != dynamic);
  }

  void toggleOrder() {
    switch (orderRules.direction) {
      case OrderDirections.notSet:
        setState(() => widget.definition.header.orderRules = widget
            .definition.header.orderRules
            .copyWith(direction: OrderDirections.ascending));

        orderRules = orderRules.copyWith(direction: OrderDirections.ascending);
        break;
      case OrderDirections.ascending:
        widget.definition.header.orderRules = widget
            .definition.header.orderRules
            .copyWith(direction: OrderDirections.descending);

        orderRules = orderRules.copyWith(direction: OrderDirections.descending);
        break;
      default:
        widget.definition.header.orderRules =
            OrderRules(direction: OrderDirections.notSet);
        orderRules = orderRules.copyWith(direction: OrderDirections.notSet);
        break;
    }

    widget.grid.updateColumnRules(widget.definition);
  }

  void toggleMenu(BuildContext context) {
    showDialog<AlertDialog>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(children: [
            Expanded(child: Text("Filter: ${widget.definition.header.text}")),
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop())
          ]),
          content: widget.definition.header.filterRules
              .filter(widget.definition, widget.grid),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grid = widget.grid;
    final header = widget.definition.header;

    final ColorScheme colorScheme = theme.colorScheme;

    final foregroundColor = widget.definition.foregroundColor ??
        theme.dataTableTheme.headingTextStyle?.color ??
        (colorScheme.brightness == Brightness.dark
            ? colorScheme.onSurface
            : colorScheme.onPrimary);

    final accentForegroundColor =
        widget.definition.accentColor ?? theme.accentColor;

    final iconTheme = theme.iconTheme.copyWith(color: foregroundColor);
    final accentIconTheme =
        theme.accentIconTheme.copyWith(color: accentForegroundColor);

    final textStyle = widget.definition.header.textStyle ??
        theme.dataTableTheme.headingTextStyle ??
        theme.textTheme.subtitle2!.copyWith(color: foregroundColor);

    final items = List<Widget>.empty(growable: true);

    if (widget.definition.header.text != null) {
      items.add(
        Expanded(
          child: Text(
            widget.definition.header.text!,
            textAlign: textAlign ?? TextAlign.start,
            style: textStyle,
          ),
        ),
      );
    }

    if ((orderRules.showSort == null &&
            grid.widget.sortable != SortableOptions.none) ||
        (orderRules.showSort ?? false)) {
      IconData icon;
      switch (orderRules.direction) {
        case OrderDirections.ascending:
          icon = Icons.arrow_upward;
          break;
        case OrderDirections.descending:
          icon = Icons.arrow_downward;
          break;
        default:
          icon = Icons.sort;
          break;
      }
      items.add(IconButton(
          icon: Icon(
            icon,
            color: orderRules.direction != OrderDirections.notSet
                ? accentIconTheme.color
                : iconTheme.color,
            size: iconTheme.size,
          ),
          onPressed: () => toggleOrder()));
    }

    if (((header.showMenu == null && grid.widget.filterable) ||
            (header.showMenu != null && header.showMenu!)) ||
        (header.filterRules.filterable)) {
      items.add(IconButton(
          icon: Icon(
            Icons.filter_list,
            color: header.filterRules.criteria != null
                ? accentIconTheme.color
                : iconTheme.color,
            size: iconTheme.size,
          ),
          onPressed: () => toggleMenu(context)));
    }

    return Container(
      color: widget.definition.backgroundColor,
      alignment: header.alignment ?? Alignment.centerLeft,
      child: Row(
        children: items,
      ),
    );
  }
}
