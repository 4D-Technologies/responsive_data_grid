part of '../../responsive_data_grid.dart';

enum DateTimeFilterTypes { DateOnly, TimeOnly, DateTime }

class DateTimeFilterRules<TItem extends Object>
    extends FilterRules<TItem, DataGridDateTimeColumnFilter<TItem>, DateTime> {
  final DateTimeFilterTypes filterType;
  final DateTime firstDate;
  final DateTime lastDate;

  DateTimeFilterRules({
    required this.filterType,
    super.criteria,
    DateTime? firstDate,
    DateTime? lastDate,
  }) : firstDate = firstDate ?? DateTime.parse("0001-01-01"),
       lastDate = lastDate ?? DateTime.parse("3000-01-01");

  @override
  DataGridDateTimeColumnFilter<TItem> showFilter(
    GridColumn<TItem, DateTime> definition,
    ResponsiveDataGridState<TItem> grid,
  ) => DataGridDateTimeColumnFilter(definition, grid);
}

class DataGridDateTimeColumnFilter<TItem extends Object>
    extends DataGridColumnFilter<TItem, DateTime> {
  DataGridDateTimeColumnFilter(super.definition, super.grid, {super.key}) {
    assert(TItem != Object);
  }

  @override
  State<StatefulWidget> createState() =>
      DataGridDateTimeColumnFilterState<TItem>();
}

class DataGridDateTimeColumnFilterState<TItem extends Object>
    extends DataGridColumnFilterState<TItem, DateTime> {
  DateTime? dtStart;
  DateTime? dtEnd;
  Logic? op;

  late DateTimeFilterRules<TItem> filterRules;

  @override
  initState() {
    filterRules = widget.definition.filterRules as DateTimeFilterRules<TItem>;

    final criteria = filterRules.criteria;
    if (criteria != null) {
      dtStart = criteria.values.isNotEmpty ? criteria.values.first : null;
      dtEnd = criteria.values.length > 1 ? criteria.values.last : null;
      op = criteria.logicalOperator;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GridLocalizations.of(context);
    final showStart =
        op != null &&
        (op == Logic.greaterThan ||
            op == Logic.greaterThanOrEqualTo ||
            op == Logic.between ||
            op == Logic.equals ||
            op == Logic.notEqual ||
            op == Logic.lessThan ||
            op == Logic.lessThanOrEqualTo);
    final showEnd = op == Logic.between;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<Logic?>(
          isExpanded: true,
          isDense: true,
          style: gridMenuFilterTextStyle(context),
          decoration: gridMenuFilterDecoration(context),
          items: gridFilterLogicItems(context, gridComparableFilterLogics),
          initialValue: op,
          onChanged: (Logic? value) {
            setState(() {
              op = value;
              writeCriteria(op, [?dtStart, ?dtEnd]);
            });
          },
        ),
        if (showStart) ...[
          const SizedBox(height: 8),
          _menuDateField(
            context: context,
            key: const ValueKey('rdg-menu-filter-from'),
            value: dtStart,
            firstDate: filterRules.firstDate,
            lastDate: dtEnd ?? filterRules.lastDate,
            hint: showEnd ? l10n.filterFrom : (op?.toString() ?? l10n.filter),
            onChanged: (DateTime? value) {
              setState(() {
                dtStart = value;
                writeCriteria(op, [?dtStart, ?dtEnd]);
              });
            },
          ),
        ],
        if (showEnd) ...[
          const SizedBox(height: 8),
          _menuDateField(
            context: context,
            key: const ValueKey('rdg-menu-filter-to'),
            value: dtEnd,
            firstDate: dtStart ?? filterRules.firstDate,
            lastDate: filterRules.lastDate,
            hint: l10n.filterTo,
            onChanged: (DateTime? value) {
              setState(() {
                dtEnd = value;
                writeCriteria(op, [?dtStart, ?dtEnd]);
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _menuDateField({
    required BuildContext context,
    Key? key,
    required DateTime? value,
    required DateTime firstDate,
    required DateTime lastDate,
    required String hint,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return SizedBox(
      width: double.infinity,
      child: DateTimeField(
        key: key,
        hideDefaultSuffixIcon: true,
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          suffixIcon: Icon(
            filterRules.filterType == DateTimeFilterTypes.TimeOnly
                ? Icons.schedule
                : Icons.calendar_today,
            size: 16,
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 28,
            minHeight: 28,
            maxHeight: 28,
          ),
        ),
        value: value,
        firstDate: firstDate,
        lastDate: lastDate,
        initialPickerDateTime: value,
        mode: _mapType(filterRules.filterType),
        dateFormat: _format(filterRules.filterType),
        pickerPlatform: DateTimeFieldPickerPlatform.material,
        style: gridMenuFilterTextStyle(context),
        onChanged: onChanged,
      ),
    );
  }

  intl.DateFormat _format(DateTimeFilterTypes filterType) {
    switch (filterType) {
      case DateTimeFilterTypes.DateOnly:
        return intl.DateFormat.yMd();
      case DateTimeFilterTypes.TimeOnly:
        return intl.DateFormat.jm();
      case DateTimeFilterTypes.DateTime:
        return intl.DateFormat.yMd().add_jm();
    }
  }

  DateTimeFieldPickerMode _mapType(DateTimeFilterTypes filterType) {
    switch (filterType) {
      case DateTimeFilterTypes.DateOnly:
        return DateTimeFieldPickerMode.date;
      case DateTimeFilterTypes.TimeOnly:
        return DateTimeFieldPickerMode.time;
      case DateTimeFilterTypes.DateTime:
        return DateTimeFieldPickerMode.dateAndTime;
    }
  }
}
