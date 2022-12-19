part of responsive_data_grid;

class AggregationChooser<TItem extends Object> extends StatefulWidget {
  final GridColumn<TItem, dynamic> column;
  final Aggregations aggregation;
  final Iterable<AggregateCriteria> selected;
  final void Function(AggregateCriteria aggregation, bool selected) update;

  AggregationChooser({
    required this.column,
    required this.aggregation,
    required this.selected,
    required this.update,
  });

  @override
  State<AggregationChooser<TItem>> createState() =>
      _AggregationChooserState<TItem>();
}

class _AggregationChooserState<TItem extends Object>
    extends State<AggregationChooser<TItem>> {
  late bool value;

  @override
  void initState() {
    value = widget.selected.firstWhereOrDefault(
            (value) => value.aggregation == widget.aggregation,
            defaultValue: null) !=
        null;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          widget.aggregation.toString(),
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: (value) {
          setState(() {
            this.value = value;
            widget.update(
              AggregateCriteria(
                fieldName: widget.column.fieldName,
                aggregation: widget.aggregation,
              ),
              value,
            );
          });
        },
      ),
    );
  }
}
