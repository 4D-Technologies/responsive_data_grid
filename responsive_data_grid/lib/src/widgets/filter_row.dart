part of '../../responsive_data_grid.dart';

class GridFilterRow<TItem extends Object> extends StatelessWidget {
  final ResponsiveDataGridState<TItem> grid;
  final List<GridColumn<TItem, dynamic>> columns;

  const GridFilterRow({super.key, required this.grid, required this.columns});

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
            frozenBackground: gridTheme.filterRow.background,
          )
        : BootstrapRow(
            textDirection: Directionality.of(context),
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
                  child: GridFilterRowCell<TItem>(column: column, grid: grid),
                ),
            ],
            totalSegments:
                layout?.totalSegments ?? grid.widget.reactiveSegments,
          );

    return DecoratedBox(
      key: const ValueKey('rdg-filter-row'),
      decoration: BoxDecoration(
        color: gridTheme.filterRow.background,
        border: Border(
          bottom: BorderSide(
            color: gridTheme.chrome.borderColor,
            width: gridTheme.chrome.borderWidth,
          ),
        ),
      ),
      child: Padding(
        padding: gridTheme.resolvePadding(
          EdgeInsets.only(
            top: gridTheme.filterRow.padding.top,
            bottom: gridTheme.filterRow.padding.bottom,
          ),
        ),
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
    final value = criteria.values.first;
    if (value == null) return '';
    if (value is Duration) return value.inMinutes.toString();
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.column.header.showFilter) {
      return const SizedBox.shrink();
    }
    final column = widget.column;
    final Widget editor;
    if (column is BoolColumn<TItem>) {
      editor = _boolEditor(context, column);
    } else if (column is DateTimeColumn<TItem>) {
      editor = _dateEditor(context, column);
    } else if (column is TimeOfDayColumn<TItem>) {
      editor = _timeEditor(context, column);
    } else if (column.filterRules is ValueMapFilterRules) {
      editor = _valuesEditor(context);
    } else if (column is StringColumn<TItem> ||
        column is IntColumn<TItem> ||
        column is DoubleColumn<TItem> ||
        column is NumColumn<TItem> ||
        column is DurationColumn<TItem>) {
      editor = _textEditor(context);
    } else {
      return const SizedBox.shrink();
    }
    final pad = ResponsiveDataGridTheme.of(context).filterRow.padding;
    return Padding(
      padding: EdgeInsets.only(left: pad.left, right: pad.right),
      child: editor,
    );
  }

  InputDecoration _decoration(BuildContext context, {Widget? suffix}) {
    final l10n = GridLocalizations.of(context);
    final theme = ResponsiveDataGridTheme.of(context);
    return InputDecoration(
      isDense: true,
      hintText: l10n.filter,
      border: const OutlineInputBorder(),
      contentPadding: theme.filterRow.editorPadding,
      suffixIcon: suffix,
      suffixIconConstraints: suffix == null
          ? null
          : const BoxConstraints(minWidth: 28, minHeight: 28, maxHeight: 28),
    );
  }

  Widget _compactIconButton({
    Key? key,
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final theme = ResponsiveDataGridTheme.of(context);
    return IconButton(
      key: key,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      icon: Icon(icon, size: theme.filterRow.operatorIconSize),
      onPressed: onPressed,
    );
  }

  Widget _textEditor(BuildContext context) {
    final l10n = GridLocalizations.of(context);
    final theme = ResponsiveDataGridTheme.of(context);
    return SizedBox(
      width: double.infinity,
      height: theme.filterRow.editorHeight,
      child: TextField(
        key: ValueKey('rdg-filter-row-${widget.column.fieldName}'),
        controller: _controller,
        style: theme.body.textStyle,
        decoration: _decoration(
          context,
          suffix: _controller.text.isEmpty
              ? null
              : _compactIconButton(
                  context: context,
                  icon: Icons.clear,
                  tooltip: l10n.clear,
                  onPressed: () => _applyText(''),
                ),
        ),
        keyboardType: _isNumeric ? TextInputType.number : TextInputType.text,
        onChanged: (value) {
          setState(() {});
          _scheduleCommit(value);
        },
      ),
    );
  }

  Widget _boolEditor(BuildContext context, BoolColumn<TItem> column) {
    final theme = ResponsiveDataGridTheme.of(context);
    final criteria = column.filterRules.criteria;
    final bool? current = criteria == null || criteria.values.isEmpty
        ? null
        : criteria.values.first as bool?;
    final l10n = GridLocalizations.of(context);
    // Clear sits beside the dropdown (not InputDecoration.suffix) so taps
    // are not swallowed by DropdownButtonFormField (#137).
    return SizedBox(
      key: ValueKey('rdg-filter-row-${column.fieldName}'),
      width: double.infinity,
      height: theme.filterRow.editorHeight,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<bool?>(
              key: ValueKey('rdg-filter-row-value-${column.fieldName}-$current'),
              isDense: true,
              isExpanded: true,
              initialValue: current,
              decoration: _decoration(context),
              hint: Text(l10n.filter),
              items: [
                DropdownMenuItem<bool?>(
                  value: true,
                  child: Text(column.format(true) ?? 'true'),
                ),
                DropdownMenuItem<bool?>(
                  value: false,
                  child: Text(column.format(false) ?? 'false'),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  _clear();
                  return;
                }
                _commitEquals(value);
              },
            ),
          ),
          if (current != null)
            _compactIconButton(
              key: ValueKey('rdg-filter-row-clear-${column.fieldName}'),
              context: context,
              icon: Icons.clear,
              tooltip: l10n.clear,
              onPressed: _clear,
            ),
        ],
      ),
    );
  }

  Widget _dateEditor(BuildContext context, DateTimeColumn<TItem> column) {
    final theme = ResponsiveDataGridTheme.of(context);
    final l10n = GridLocalizations.of(context);
    final criteria = column.filterRules.criteria;
    final values = criteria?.values ?? const [];
    final logic = criteria?.logicalOperator;
    DateTime? start;
    DateTime? end;
    if (logic == Logic.between && values.length >= 2) {
      start = values.first as DateTime?;
      end = values.last as DateTime?;
    } else if (logic == Logic.greaterThanOrEqualTo ||
        logic == Logic.greaterThan) {
      start = values.isEmpty ? null : values.first as DateTime?;
    } else if (logic == Logic.lessThanOrEqualTo || logic == Logic.lessThan) {
      end = values.isEmpty ? null : values.first as DateTime?;
    } else if (values.isNotEmpty) {
      start = values.first as DateTime?;
      if (values.length > 1) end = values.last as DateTime?;
    }
    final type = _dateFilterType(column);
    final isTimeOnly = type == DateTimeFilterTypes.TimeOnly;
    final hasValue = start != null || end != null;
    final label = _dateRangeLabel(column, start, end, isTimeOnly);
    return SizedBox(
      width: double.infinity,
      height: theme.filterRow.editorHeight,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              key: ValueKey('rdg-filter-row-${column.fieldName}'),
              onTap: () async {
                if (isTimeOnly) {
                  final picked = await _pickDateTime(context, column, start);
                  if (!mounted || picked == null) return;
                  _commitEquals(picked);
                  return;
                }
                final choice = await _pickDateBounds(context, column, start, end);
                if (!mounted || choice == null) return;
                _commitDateBounds(choice.$1, choice.$2);
              },
              child: InputDecorator(
                isEmpty: !hasValue,
                decoration: _decoration(
                  context,
                  suffix: Icon(
                    Icons.calendar_today,
                    size: theme.filterRow.operatorIconSize,
                  ),
                ),
                child: Text(
                  label,
                  style: theme.body.textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (hasValue)
            _compactIconButton(
              key: ValueKey('rdg-filter-row-clear-${column.fieldName}'),
              context: context,
              icon: Icons.clear,
              tooltip: l10n.clear,
              onPressed: _clear,
            ),
        ],
      ),
    );
  }

  String _dateRangeLabel(
    DateTimeColumn<TItem> column,
    DateTime? start,
    DateTime? end,
    bool isTimeOnly,
  ) {
    if (start == null && end == null) return '';
    if (isTimeOnly && start != null) {
      return column.format(start) ?? start.toString();
    }
    final startText = start == null ? null : (column.format(start) ?? '$start');
    final endText = end == null ? null : (column.format(end) ?? '$end');
    if (startText != null && endText != null) {
      if (_isSameDay(start!, end!)) return startText;
      return '$startText – $endText';
    }
    if (startText != null) return startText;
    return endText ?? '';
  }

  Widget _timeEditor(BuildContext context, TimeOfDayColumn<TItem> column) {
    final theme = ResponsiveDataGridTheme.of(context);
    final l10n = GridLocalizations.of(context);
    final criteria = column.filterRules.criteria;
    final TimeOfDay? current = criteria == null || criteria.values.isEmpty
        ? null
        : criteria.values.first as TimeOfDay?;
    final label = current == null
        ? l10n.filter
        : (column.format(current) ?? current.format(context));
    return SizedBox(
      width: double.infinity,
      height: theme.filterRow.editorHeight,
      child: InkWell(
        key: ValueKey('rdg-filter-row-${column.fieldName}'),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: current ?? TimeOfDay.now(),
          );
          if (!mounted) return;
          if (picked == null) return;
          _commitEquals(picked);
        },
        child: InputDecorator(
          decoration: _decoration(
            context,
            suffix: current == null
                ? Icon(Icons.schedule, size: theme.filterRow.operatorIconSize)
                : _compactIconButton(
                    context: context,
                    icon: Icons.clear,
                    tooltip: l10n.clear,
                    onPressed: _clear,
                  ),
          ),
          child: Text(label, style: theme.body.textStyle, maxLines: 1),
        ),
      ),
    );
  }

  Widget _valuesEditor(BuildContext context) {
    final theme = ResponsiveDataGridTheme.of(context);
    final rules = widget.column.filterRules as ValueMapFilterRules;
    final criteria = widget.column.filterRules.criteria;
    final current = criteria == null || criteria.values.isEmpty
        ? null
        : criteria.values.first;
    return SizedBox(
      width: double.infinity,
      height: theme.filterRow.editorHeight,
      child: DropdownButtonFormField<Object?>(
        key: ValueKey('rdg-filter-row-${widget.column.fieldName}'),
        isDense: true,
        isExpanded: true,
        initialValue: current,
        decoration: _decoration(context),
        items: [
          DropdownMenuItem<Object?>(
            value: null,
            child: Text(GridLocalizations.of(context).filter),
          ),
          for (final entry in rules.valueMap.entries)
            DropdownMenuItem<Object?>(value: entry.key, child: entry.value),
        ],
        onChanged: (value) {
          if (value == null) {
            _clear();
            return;
          }
          _commitEquals(value);
        },
      ),
    );
  }

  bool get _isNumeric =>
      widget.column is IntColumn<TItem> ||
      widget.column is DoubleColumn<TItem> ||
      widget.column is NumColumn<TItem> ||
      widget.column is DurationColumn<TItem>;

  DateTime _clampDateTime(DateTime value, DateTime first, DateTime last) {
    if (value.isBefore(first)) return first;
    if (value.isAfter(last)) return last;
    return value;
  }

  DateTime _startOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DateTime _endOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day, 23, 59, 59, 999);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTimeFilterTypes _dateFilterType(DateTimeColumn<TItem> column) {
    final rules = column.filterRules;
    if (rules is DateTimeFilterRules<TItem>) return rules.filterType;
    return DateTimeFilterTypes.DateTime;
  }

  /// Compact From/To dialog (not fullscreen [showDateRangePicker]). Supports
  /// from-only, to-only, and both (#136).
  Future<(DateTime?, DateTime?)?> _pickDateBounds(
    BuildContext context,
    DateTimeColumn<TItem> column,
    DateTime? start,
    DateTime? end,
  ) async {
    final rules = column.filterRules;
    final typed = rules is DateTimeFilterRules<TItem> ? rules : null;
    final first = typed?.firstDate ?? DateTime(1900);
    final last = typed?.lastDate ?? DateTime(2100);
    final type = _dateFilterType(column);
    final l10n = GridLocalizations.of(context);
    var draftStart = start;
    var draftEnd = end;

    return showDialog<(DateTime?, DateTime?)>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.filter),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DateTimeField(
                      key: ValueKey(
                        'rdg-filter-row-from-${column.fieldName}',
                      ),
                      hideDefaultSuffixIcon: true,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: l10n.filterFrom,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          size: 16,
                        ),
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                          maxHeight: 28,
                        ),
                      ),
                      value: draftStart,
                      firstDate: first,
                      lastDate: draftEnd ?? last,
                      initialPickerDateTime: draftStart,
                      mode: _mapDateFilterType(type),
                      dateFormat: _dateFormatFor(type),
                      pickerPlatform: DateTimeFieldPickerPlatform.material,
                      onChanged: (value) {
                        setDialogState(() => draftStart = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DateTimeField(
                      key: ValueKey('rdg-filter-row-to-${column.fieldName}'),
                      hideDefaultSuffixIcon: true,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: l10n.filterTo,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          size: 16,
                        ),
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                          maxHeight: 28,
                        ),
                      ),
                      value: draftEnd,
                      firstDate: draftStart ?? first,
                      lastDate: last,
                      initialPickerDateTime: draftEnd,
                      mode: _mapDateFilterType(type),
                      dateFormat: _dateFormatFor(type),
                      pickerPlatform: DateTimeFieldPickerPlatform.material,
                      onChanged: (value) {
                        setDialogState(() => draftEnd = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop((draftStart, draftEnd));
                  },
                  child: Text(MaterialLocalizations.of(context).okButtonLabel),
                ),
              ],
            );
          },
        );
      },
    );
  }

  intl.DateFormat _dateFormatFor(DateTimeFilterTypes filterType) {
    switch (filterType) {
      case DateTimeFilterTypes.DateOnly:
        return intl.DateFormat.yMd();
      case DateTimeFilterTypes.TimeOnly:
        return intl.DateFormat.jm();
      case DateTimeFilterTypes.DateTime:
        return intl.DateFormat.yMd().add_jm();
    }
  }

  DateTimeFieldPickerMode _mapDateFilterType(DateTimeFilterTypes filterType) {
    switch (filterType) {
      case DateTimeFilterTypes.DateOnly:
        return DateTimeFieldPickerMode.date;
      case DateTimeFilterTypes.TimeOnly:
        return DateTimeFieldPickerMode.time;
      case DateTimeFilterTypes.DateTime:
        return DateTimeFieldPickerMode.dateAndTime;
    }
  }

  Future<DateTime?> _pickDateTime(
    BuildContext context,
    DateTimeColumn<TItem> column,
    DateTime? current,
  ) async {
    final rules = column.filterRules;
    final typed = rules is DateTimeFilterRules<TItem> ? rules : null;
    final first = typed?.firstDate ?? DateTime(1900);
    final last = typed?.lastDate ?? DateTime(2100);
    final initial = _clampDateTime(current ?? DateTime.now(), first, last);
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(
      initial.year,
      initial.month,
      initial.day,
      time.hour,
      time.minute,
    );
  }

  void _applyText(String raw) {
    _debounce?.cancel();
    if (_controller.text != raw) {
      _controller.text = raw;
    }
    setState(() {});
    _commitText(raw);
  }

  void _scheduleCommit(String raw) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _commitText(raw);
    });
  }

  void _clear() {
    _debounce?.cancel();
    widget.column.filterRules.criteria = null;
    _controller.clear();
    setState(() {});
    widget.grid.refreshData();
  }

  void _commitEquals(Object value) {
    final column = widget.column;
    if (column is BoolColumn<TItem>) {
      column.filterRules.applyEquals(column.fieldName, value as bool);
    } else if (column is DateTimeColumn<TItem>) {
      column.filterRules.applyEquals(column.fieldName, value as DateTime);
    } else if (column is TimeOfDayColumn<TItem>) {
      column.filterRules.applyEquals(column.fieldName, value as TimeOfDay);
    } else {
      column.filterRules.applyEquals(column.fieldName, value as dynamic);
    }
    setState(() {});
    widget.grid.refreshData();
  }

  void _commitBetween(DateTime start, DateTime end) {
    final column = widget.column;
    if (column is! DateTimeColumn<TItem>) return;
    column.filterRules.applyBetween(column.fieldName, start, end);
    setState(() {});
    widget.grid.refreshData();
  }

  void _commitDateBounds(DateTime? start, DateTime? end) {
    final column = widget.column;
    if (column is! DateTimeColumn<TItem>) return;
    final type = _dateFilterType(column);
    final normalizeStart = start == null
        ? null
        : (type == DateTimeFilterTypes.DateOnly ? _startOfDay(start) : start);
    final normalizeEnd = end == null
        ? null
        : (type == DateTimeFilterTypes.DateOnly ? _endOfDay(end) : end);

    if (normalizeStart == null && normalizeEnd == null) {
      _clear();
      return;
    }
    if (normalizeStart != null && normalizeEnd != null) {
      final lo = normalizeStart.isAfter(normalizeEnd)
          ? normalizeEnd
          : normalizeStart;
      final hi = normalizeStart.isAfter(normalizeEnd)
          ? normalizeStart
          : normalizeEnd;
      _commitBetween(lo, hi);
      return;
    }
    if (normalizeStart != null) {
      column.filterRules.applyGreaterThanOrEqualTo(
        column.fieldName,
        normalizeStart,
      );
    } else {
      column.filterRules.applyLessThanOrEqualTo(
        column.fieldName,
        normalizeEnd as DateTime,
      );
    }
    setState(() {});
    widget.grid.refreshData();
  }

  void _commitText(String raw) {
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
    } else if (column is DurationColumn<TItem>) {
      final minutes = int.tryParse(raw);
      if (minutes == null) return;
      column.filterRules.criteria = FilterCriteria<Duration>(
        fieldName: column.fieldName,
        op: Operators.and,
        logicalOperator: Logic.equals,
        values: [Duration(minutes: minutes)],
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
