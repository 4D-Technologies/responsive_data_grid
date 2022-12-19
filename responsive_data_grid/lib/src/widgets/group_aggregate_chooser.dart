part of responsive_data_grid;

class GridGroupAggregateChooser<TItem extends Object> extends StatefulWidget {
  final ResponsiveDataGridState<TItem> gridState;
  final ThemeData theme;
  final GroupCriteria criteria;

  GridGroupAggregateChooser({
    required this.gridState,
    required this.theme,
    required this.criteria,
  }) : super(key: ObjectKey(criteria));

  @override
  _GridGroupAggregateChooserState createState() =>
      _GridGroupAggregateChooserState<TItem>(criteria);
}

class _GridGroupAggregateChooserState<TItem extends Object>
    extends State<GridGroupAggregateChooser<TItem>> {
  late List<bool> expansionStates;
  late List<GridColumn<TItem, dynamic>> columns;

  final ObjectKey key;

  _GridGroupAggregateChooserState(GroupCriteria criteria)
      : key = ObjectKey(criteria);

  @override
  void initState() {
    print("initstate");
    columns = widget.gridState.widget.columns
        .where((c) => c.hasAggregations)
        .orderBy((c) => c.header.text ?? c.fieldName)
        .toList();
    expansionStates = columns
        .map((e) =>
            widget.criteria.aggregates.any((a) => a.fieldName == e.fieldName))
        .toList();

    print(expansionStates);

    super.initState();
  }

  void updateAggregations(AggregateCriteria aggregation, bool selected) async {
    if (selected) {
      if (widget.criteria.aggregates.any((a) => a == aggregation)) return;

      widget.criteria.aggregates.add(
        aggregation,
      );
    } else {
      widget.criteria.aggregates.removeWhere((a) => a == aggregation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      child: Column(
        children: [
          SizedBox(
            width: 250,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.black38),
              child: Padding(
                padding: EdgeInsets.all(3),
                child: Text("Aggregates"),
              ),
            ),
          ),
          ExpansionPanelList(
            key: key,
            expansionCallback: (panelIndex, isExpanded) {
              print(isExpanded);
              setState(() {
                expansionStates[panelIndex] = isExpanded ? false : true;
              });
            },
            children: columns.map<ExpansionPanel>(
              (e) {
                final state = expansionStates[columns.indexOf(e)];
                final aggViews = e.getAggregations(
                  selected: widget.criteria.aggregates,
                  update: updateAggregations,
                );

                return ExpansionPanel(
                  canTapOnHeader: false,
                  isExpanded: state,
                  headerBuilder: (context, isExpanded) => ListTile(
                    title: Text(e.header.text ?? e.fieldName),
                  ),
                  body: ListView.builder(
                    itemBuilder: (context, index) {
                      final aggView = aggViews[index];
                      return aggView;
                    },
                    itemCount: aggViews.length,
                    shrinkWrap: true,
                  ),
                );
              },
            ).toList(),
          ),
          Divider(color: widget.theme.dividerColor),
        ],
      ),
      visible: columns.isNotEmpty,
    );
  }
}
