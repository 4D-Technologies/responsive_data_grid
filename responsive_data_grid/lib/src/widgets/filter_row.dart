part of '../../responsive_data_grid.dart';

class GridFilterRow<TItem extends Object> extends StatelessWidget {
  final ResponsiveDataGridState<TItem> grid;
  final List<GridColumn<TItem, dynamic>> columns;

  const GridFilterRow({
    super.key,
    required this.grid,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    final gridTheme = ResponsiveDataGridTheme.of(context);
    final layout = GridTableLayout.maybeOf(context);
    final cells = [
      for (final column in columns)
        GridFilterRowCell<TItem>(
          key: ValueKey('rdg-filter-row-cell-${column.fieldName}'),
          column: column,
          grid: grid,
        ),
    ];
    final row = layout != null && layout.layoutMode == GridLayoutMode.table
        ? GridTableRow(
            cells: cells,
            widths: layout.columnWidths,
            frozenCount: layout.frozenCount,
            frozenBackground: gridTheme.headerBackground,
          )
        : BootstrapRow(
            children: [
              for (final column in columns)
                BootstrapCol(
                  xs: column.xsCols ?? 12,
                  sm: column.smallCols ?? column.xsCols ?? 12,
                  md:
                      column.mediumCols ??
                      column.smallCols ??
                      column.xsCols ??
                      12,
                  child: GridFilterRowCell<TItem>(
                    column: column,
                    grid: grid,
                  ),
                ),
            ],
            totalSegments:
                layout?.totalSegments ?? grid.widget.reactiveSegments,
          );

    return DecoratedBox(
      key: const ValueKey('rdg-filter-row'),
      decoration: BoxDecoration(
        color: gridTheme.headerBackground,
        border: Border(
          bottom: BorderSide(
            color: gridTheme.borderColor,
            width: gridTheme.borderWidth,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: row,
      ),
    );
  }
}

class GridFilterRowCell<TItem extends Object> extends StatefulWidget {
  final GridColumn<TItem, dynamic> column;
  final ResponsiveDataGridState<TItem> grid;

  const GridFilterRowCell({
    super.key,
    required this.column,
    required this.grid,
  });

  @override
  State<GridFilterRowCell<TItem>> createState() =>
      _GridFilterRowCellState<TItem>();
}

class _GridFilterRowCellState<TItem extends Object>
    extends State<GridFilterRowCell<TItem>> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _textFromCriteria());
  }

  @override
  void didUpdateWidget(covariant GridFilterRowCell<TItem> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _textFromCriteria();
    if (_controller.text != next) {
      _controller.text = next;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _textFromCriteria() {
    final criteria = widget.column.filterRules.criteria;
    if (criteria == null || criteria.values.isEmpty) return '';
    return criteria.values.first.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.column.header.showFilter || !_supportsRowEditor) {
      return const SizedBox.shrink();
    }
    final l10n = GridLocalizations.of(context);
    return TextField(
      key: ValueKey('rdg-filter-row-${widget.column.fieldName}'),
      controller: _controller,
      style: ResponsiveDataGridTheme.of(context).bodyTextStyle,
      decoration: InputDecoration(
        isDense: true,
        hintText: l10n.filter,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: l10n.clear,
                icon: const Icon(Icons.clear, size: 16),
                onPressed: () => _apply(''),
              ),
      ),
      keyboardType: _isNumeric ? TextInputType.number : TextInputType.text,
      onChanged: (value) {
        setState(() {});
        _scheduleCommit(value);
      },
    );
  }

  bool get _isNumeric =>
      widget.column is IntColumn<TItem> ||
      widget.column is DoubleColumn<TItem> ||
      widget.column is NumColumn<TItem>;

  bool get _supportsRowEditor =>
      widget.column is StringColumn<TItem> || _isNumeric;

  void _apply(String raw) {
    _debounce?.cancel();
    if (_controller.text != raw) {
      _controller.text = raw;
    }
    setState(() {});
    _commit(raw);
  }

  void _scheduleCommit(String raw) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _commit(raw);
    });
  }

  void _commit(String raw) {
    final column = widget.column;
    if (raw.isEmpty) {
      if (column.filterRules.criteria != null) {
        column.filterRules.criteria = null;
        widget.grid.refreshData();
      }
      return;
    }
    if (column is IntColumn<TItem>) {
      final parsed = int.tryParse(raw);
      if (parsed == null) return;
      column.filterRules.criteria = FilterCriteria<int>(
        fieldName: column.fieldName,
        op: Operators.and,
        logicalOperator: Logic.equals,
        values: [parsed],
      );
    } else if (column is DoubleColumn<TItem> || column is NumColumn<TItem>) {
      final parsed = num.tryParse(raw);
      if (parsed == null) return;
      column.filterRules.criteria = FilterCriteria<num>(
        fieldName: column.fieldName,
        op: Operators.and,
        logicalOperator: Logic.equals,
        values: [parsed],
      );
    } else if (column is StringColumn<TItem>) {
      column.filterRules.criteria = FilterCriteria<String>(
        fieldName: column.fieldName,
        op: Operators.and,
        logicalOperator: Logic.contains,
        values: [raw],
      );
    } else {
      return;
    }
    widget.grid.refreshData();
  }
}
