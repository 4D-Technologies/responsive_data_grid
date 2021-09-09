part of responsive_data_grid;

class ColumnHeaderWidget<TItem extends Object, TValue extends dynamic>
    extends StatefulWidget {
  final GridColumn<TItem, TValue> definition;
  final ResponsiveDataGridState<TItem> grid;

  ColumnHeaderWidget(this.grid, this.definition) {
    assert(TItem != dynamic);
  }

  @override
  State<StatefulWidget> createState() => ColumnHeaderState<TItem, TValue>();
}

class ColumnHeaderState<TItem extends Object, TValue extends dynamic>
    extends State<ColumnHeaderWidget<TItem, TValue>> {
  ColumnHeaderState() {
    assert(TItem != dynamic);
  }

  Future<void> toggleOrder() async {
    switch (widget.definition.sortDirection) {
      case OrderDirections.notSet:
        widget.definition.sortDirection = OrderDirections.ascending;
        break;
      case OrderDirections.ascending:
        widget.definition.sortDirection = OrderDirections.descending;
        break;
      default:
        widget.definition.sortDirection = OrderDirections.notSet;
        break;
    }

    await widget.grid._updateOrderByCriteria(widget.definition);
  }

  Future<void> toggleMenu(BuildContext context) async {
    final result = await showDialog<FilterCriteria<TValue>?>(
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
          content: widget.definition.filterRules
              .showFilter(widget.definition, widget.grid),
        );
      },
    );

    widget.definition.filterRules.criteria = result;

    await widget.grid._load(clear: true);
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
        widget.definition.accentColor ?? theme.colorScheme.secondary;

    final iconTheme = theme.iconTheme.copyWith(color: foregroundColor);
    final accentIconTheme =
        theme.iconTheme.copyWith(color: accentForegroundColor);

    final textStyle = widget.definition.header.textStyle ??
        theme.dataTableTheme.headingTextStyle ??
        theme.textTheme.subtitle2!.copyWith(color: foregroundColor);

    final items = List<Widget>.empty(growable: true);

    if (widget.definition.header.text != null) {
      items.add(
        Expanded(
          child: Text(
            widget.definition.header.text!,
            textAlign: widget.definition.header.textAlign,
            style: textStyle,
          ),
        ),
      );
    }

    if (widget.definition.header.showOrderBy &&
        grid.widget.sortable != SortableOptions.none) {
      IconData icon;
      switch (widget.definition.sortDirection) {
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
            color: widget.definition.sortDirection != OrderDirections.notSet
                ? accentIconTheme.color
                : iconTheme.color,
            size: iconTheme.size,
          ),
          onPressed: () => toggleOrder()));
    }

    if (header.showFilter) {
      items.add(
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: widget.definition.filterRules.criteria != null
                ? accentIconTheme.color
                : iconTheme.color,
            size: iconTheme.size,
          ),
          onPressed: () => toggleMenu(context),
        ),
      );
    }

    return Container(
      color: widget.definition.backgroundColor,
      alignment: header.alignment,
      child: Row(
        children: items,
      ),
    );
  }
}
