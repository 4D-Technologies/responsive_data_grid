part of responsive_data_grid;

class ColumnHeaderWidget<TItem extends dynamic> extends StatefulWidget {
  final ColumnDefinition<TItem> definition;
  final DataGridState<TItem> grid;

  ColumnHeaderWidget(this.grid, this.definition) {
    assert(TItem != dynamic);
  }

  @override
  State<StatefulWidget> createState() => ColumnHeaderState<TItem>();
}

class ColumnHeaderState<TItem> extends State<ColumnHeaderWidget<TItem>> {
  AlignmentGeometry? alignment;
  TextAlign? textAlign;
  FilterRules<TItem>? filterRules;
  OrderRules? orderRules;
  bool showMenu = false;

  ColumnHeaderState() {
    assert(TItem != dynamic);
  }

  @override
  void initState() {
    super.initState();
    filterRules = widget.definition.header.filterRules;
    orderRules = widget.definition.header.orderRules;
    showMenu = widget.definition.header.showMenu ?? false;
  }

  void toggleOrder() {
    switch (orderRules?.direction) {
      case OrderDirections.NotSet:
        setState(() => widget.definition.header.orderRules = widget
            .definition.header.orderRules
            .copyWith(direction: OrderDirections.Ascending));
        break;
      case OrderDirections.Ascending:
        widget.definition.header.orderRules = widget
            .definition.header.orderRules
            .copyWith(direction: OrderDirections.Descending);
        break;
      default:
        widget.definition.header.orderRules =
            OrderRules(direction: OrderDirections.NotSet);
        break;
    }

    widget.grid.updateColumnRules(widget.definition);
  }

  void toggleMenu(BuildContext context) {
    showDialog<AlertDialog>(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Row(children: [
              Expanded(child: Text("Filter: ${widget.definition.header.text}")),
              IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop())
            ]),
            content: DataGridColumnMenuWidget(widget.definition, widget.grid));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grid = widget.grid;
    final header = widget.definition.header;

    final items = List<Widget>.empty(growable: true);

    if (widget.definition.header.text != null) {
      items.add(
        Expanded(
          child: Text(
            widget.definition.header.text!,
            textAlign: textAlign ?? TextAlign.start,
            style: theme.primaryTextTheme.headline6,
          ),
        ),
      );
    }

    if (orderRules != null &&
        ((orderRules!.showSort == null &&
                grid.widget.sortable != SortableOptions.None) ||
            (orderRules!.showSort ?? false))) {
      IconData icon;
      switch (orderRules!.direction) {
        case OrderDirections.Ascending:
          icon = Icons.arrow_upward;
          break;
        case OrderDirections.Descending:
          icon = Icons.arrow_downward;
          break;
        default:
          icon = Icons.sort;
          break;
      }
      items.add(IconButton(
          icon: Icon(
            icon,
            color: theme.primaryIconTheme.color,
          ),
          onPressed: () => toggleOrder()));
    }

    if (((header.showMenu == null && grid.widget.filterable) ||
            (header.showMenu != null && header.showMenu!)) ||
        (header.filterRules.filterable)) {
      items.add(IconButton(
          icon: Icon(
            Icons.filter_list,
            color: theme.primaryIconTheme.color,
          ),
          onPressed: () => toggleMenu(context)));
    }

    return Align(
      alignment: header.alignment ?? Alignment.centerLeft,
      child: Row(
        children: items,
      ),
    );
  }
}
