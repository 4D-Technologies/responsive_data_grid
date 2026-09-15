part of '../responsive_data_grid.dart';

/// Locale-aware copy for grid chrome. Hosts register [delegate] on
/// `MaterialApp` / `CupertinoApp`. Widgets fall back to [en] when no
/// delegate is present.
class GridLocalizations {
  final String languageCode;
  final String apply;
  final String cancel;
  final String clear;
  final String ok;
  final String any;
  final String value;
  final String state;
  final String doesNotInclude;
  final String noEntry;
  final String retry;
  final String loadFailed;
  final String noRecords;
  final String groupBy;
  final String groupPanelHint;
  final String addGrouping;
  final String ungroup;
  final String groupColumn;
  final String aggregates;
  final String filter;
  final String sort;
  final String columnMenu;
  final String showGroupPanel;
  final String hideGroupPanel;
  final String sortGroup;
  final String clearAll;
  final String removeGroup;
  final String minutes;
  final String sortAscending;
  final String sortDescending;
  final String clearSort;
  final String pinLeft;
  final String unpin;
  final String hideColumn;
  final String autosizeColumn;
  final String firstPage;
  final String previousPage;
  final String nextPage;
  final String lastPage;
  final String pageSize;
  final String applicationError;
  final String Function(String column) filterTitle;
  final String Function({
    required int start,
    required int end,
    required int total,
  })
  pagerRange;
  final String Function(int page) pageLabel;

  const GridLocalizations({
    required this.languageCode,
    required this.apply,
    required this.cancel,
    required this.clear,
    required this.ok,
    required this.any,
    required this.value,
    required this.state,
    required this.doesNotInclude,
    required this.noEntry,
    required this.retry,
    required this.loadFailed,
    required this.noRecords,
    required this.groupBy,
    required this.groupPanelHint,
    required this.addGrouping,
    required this.ungroup,
    required this.groupColumn,
    required this.aggregates,
    required this.filter,
    required this.sort,
    required this.columnMenu,
    required this.showGroupPanel,
    required this.hideGroupPanel,
    required this.sortGroup,
    required this.clearAll,
    required this.removeGroup,
    required this.minutes,
    required this.sortAscending,
    required this.sortDescending,
    required this.clearSort,
    required this.pinLeft,
    required this.unpin,
    required this.hideColumn,
    required this.autosizeColumn,
    required this.firstPage,
    required this.previousPage,
    required this.nextPage,
    required this.lastPage,
    required this.pageSize,
    required this.applicationError,
    required this.filterTitle,
    required this.pagerRange,
    required this.pageLabel,
  });

  static const GridLocalizations en = GridLocalizations(
    languageCode: 'en',
    apply: 'Apply',
    cancel: 'Cancel',
    clear: 'Clear',
    ok: 'OK',
    any: '(Any)',
    value: 'Value',
    state: 'State',
    doesNotInclude: 'Does Not Include',
    noEntry: 'No Entry',
    retry: 'Retry',
    loadFailed: 'Unable to load data.',
    noRecords: 'No records available.',
    groupBy: 'Group by',
    groupPanelHint: 'Select a column to group by',
    addGrouping: 'Add grouping',
    ungroup: 'Ungroup',
    groupColumn: 'Group column',
    aggregates: 'Aggregates',
    filter: 'Filter',
    sort: 'Sort',
    columnMenu: 'Column menu',
    showGroupPanel: 'Show group panel',
    hideGroupPanel: 'Hide group panel',
    sortGroup: 'Sort group',
    clearAll: 'Clear All',
    removeGroup: 'Remove Group',
    minutes: 'minutes',
    sortAscending: 'Sort ascending',
    sortDescending: 'Sort descending',
    clearSort: 'Clear sort',
    pinLeft: 'Pin left',
    unpin: 'Unpin',
    hideColumn: 'Hide column',
    autosizeColumn: 'Autosize',
    firstPage: 'First page',
    previousPage: 'Previous page',
    nextPage: 'Next page',
    lastPage: 'Last page',
    pageSize: 'Page size',
    applicationError: 'Application Error',
    filterTitle: _enFilterTitle,
    pagerRange: _enPagerRange,
    pageLabel: _enPageLabel,
  );

  static const GridLocalizations es = GridLocalizations(
    languageCode: 'es',
    apply: 'Aplicar',
    cancel: 'Cancelar',
    clear: 'Borrar',
    ok: 'Aceptar',
    any: '(Cualquiera)',
    value: 'Valor',
    state: 'Estado',
    doesNotInclude: 'No incluye',
    noEntry: 'Sin valor',
    retry: 'Reintentar',
    loadFailed: 'No se pudieron cargar los datos.',
    noRecords: 'No hay registros.',
    groupBy: 'Agrupar por',
    groupPanelHint: 'Seleccione una columna para agrupar',
    addGrouping: 'Agregar agrupación',
    ungroup: 'Desagrupar',
    groupColumn: 'Agrupar columna',
    aggregates: 'Agregados',
    filter: 'Filtro',
    sort: 'Ordenar',
    columnMenu: 'Menú de columna',
    showGroupPanel: 'Mostrar panel de agrupación',
    hideGroupPanel: 'Ocultar panel de agrupación',
    sortGroup: 'Ordenar grupo',
    clearAll: 'Borrar todo',
    removeGroup: 'Quitar grupo',
    minutes: 'minutos',
    sortAscending: 'Ordenar ascendente',
    sortDescending: 'Ordenar descendente',
    clearSort: 'Quitar orden',
    pinLeft: 'Fijar a la izquierda',
    unpin: 'Desfijar',
    hideColumn: 'Ocultar columna',
    autosizeColumn: 'Ajustar ancho',
    firstPage: 'Primera página',
    previousPage: 'Página anterior',
    nextPage: 'Página siguiente',
    lastPage: 'Última página',
    pageSize: 'Tamaño de página',
    applicationError: 'Error de la aplicación',
    filterTitle: _esFilterTitle,
    pagerRange: _esPagerRange,
    pageLabel: _esPageLabel,
  );

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  static const LocalizationsDelegate<GridLocalizations> delegate =
      _GridLocalizationsDelegate();

  static GridLocalizations of(BuildContext context) {
    return Localizations.of<GridLocalizations>(context, GridLocalizations) ??
        fromLocale(Localizations.maybeLocaleOf(context) ?? const Locale('en'));
  }

  static GridLocalizations fromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return es;
      default:
        return en;
    }
  }

  void applyToClientFiltering() {
    final spanish = languageCode == 'es';
    ClientFilteringLocalizedMessages.between = spanish ? 'Entre' : 'Between';
    ClientFilteringLocalizedMessages.equals = spanish ? 'Igual a' : 'Equals';
    ClientFilteringLocalizedMessages.lessThan = spanish
        ? 'Menor que'
        : 'Less Than';
    ClientFilteringLocalizedMessages.lessThenOrEqualTo = spanish
        ? 'Menor o igual que'
        : 'Less Than Or Equal To';
    ClientFilteringLocalizedMessages.greaterThan = spanish
        ? 'Mayor que'
        : 'Greater Than';
    ClientFilteringLocalizedMessages.greaterThanOrEqualTo = spanish
        ? 'Mayor o igual que'
        : 'Greater Than Or Equal To';
    ClientFilteringLocalizedMessages.contains = spanish
        ? 'Contiene'
        : 'Contains';
    ClientFilteringLocalizedMessages.notContains = spanish
        ? 'No contiene'
        : 'Does Not Contain';
    ClientFilteringLocalizedMessages.startsWith = spanish
        ? 'Empieza por'
        : 'Starts With';
    ClientFilteringLocalizedMessages.endsWith = spanish
        ? 'Termina con'
        : 'Ends With';
    ClientFilteringLocalizedMessages.notEqual = spanish
        ? 'No es igual a'
        : 'Does Not Equal';
    ClientFilteringLocalizedMessages.notStartsWith = spanish
        ? 'No empieza por'
        : 'Does Not Start With';
    ClientFilteringLocalizedMessages.notEndsWith = spanish
        ? 'No termina con'
        : 'Does Not End With';
    ClientFilteringLocalizedMessages.isNull = spanish ? 'Es nulo' : 'Is Null';
    ClientFilteringLocalizedMessages.isNotNull = spanish
        ? 'No es nulo'
        : 'Is Not Null';
    ClientFilteringLocalizedMessages.isEmpty = spanish
        ? 'Está vacío'
        : 'Is Empty';
    ClientFilteringLocalizedMessages.isNotEmpty = spanish
        ? 'No está vacío'
        : 'Is Not Empty';
    ClientFilteringLocalizedMessages.and = spanish ? 'Y' : 'And';
    ClientFilteringLocalizedMessages.or = spanish ? 'O' : 'Or';
    ClientFilteringLocalizedMessages.sum = spanish ? 'Suma' : 'Sum';
    ClientFilteringLocalizedMessages.average = spanish
        ? 'Promedio'
        : 'Average';
    ClientFilteringLocalizedMessages.maximum = spanish ? 'Máximo' : 'Maximum';
    ClientFilteringLocalizedMessages.minimum = spanish ? 'Mínimo' : 'Minimum';
    ClientFilteringLocalizedMessages.count = spanish ? 'Recuento' : 'Count';
  }
}

String _enFilterTitle(String column) => 'Filter: $column';
String _esFilterTitle(String column) => 'Filtro: $column';
String _enPagerRange({required int start, required int end, required int total}) =>
    '$start–$end of $total';
String _esPagerRange({required int start, required int end, required int total}) =>
    '$start–$end de $total';
String _enPageLabel(int page) => 'Page $page';
String _esPageLabel(int page) => 'Página $page';

class _GridLocalizationsDelegate
    extends LocalizationsDelegate<GridLocalizations> {
  const _GridLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      GridLocalizations.supportedLocales.any(
        (supported) => supported.languageCode == locale.languageCode,
      );

  @override
  Future<GridLocalizations> load(Locale locale) {
    final loaded = GridLocalizations.fromLocale(locale);
    loaded.applyToClientFiltering();
    return SynchronousFuture<GridLocalizations>(loaded);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<GridLocalizations> old) =>
      false;
}
