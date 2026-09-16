import 'package:client_filtering/client_filtering.dart';
import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

void main() {
  runApp(const MyApp());
}

enum DemoPalette { light, dark, branded }

enum DemoDesign { material, cupertino }

String _paletteLabel(DemoPalette palette) {
  switch (palette) {
    case DemoPalette.light:
      return 'Light';
    case DemoPalette.dark:
      return 'Dark';
    case DemoPalette.branded:
      return 'Branded';
  }
}

ThemeData _demoTheme(DemoPalette palette) {
  final brightness = palette == DemoPalette.dark
      ? Brightness.dark
      : Brightness.light;
  final seed = palette == DemoPalette.branded
      ? const Color(0xFF0F766E)
      : const Color(0xFF3949AB);
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
  );
  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      ResponsiveDataGridTheme.fromTheme(base),
    ],
  );
}

cupertino.CupertinoThemeData _demoCupertinoTheme(DemoPalette palette) {
  final brightness = palette == DemoPalette.dark
      ? Brightness.dark
      : Brightness.light;
  final primary = palette == DemoPalette.branded
      ? const Color(0xFF0F766E)
      : cupertino.CupertinoColors.systemBlue;
  return cupertino.CupertinoThemeData(
    brightness: brightness,
    primaryColor: primary,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DemoPalette _palette = DemoPalette.light;
  DemoDesign _design = DemoDesign.material;
  Locale _locale = const Locale('en');

  void _setLocale(Locale locale) {
    Intl.defaultLocale = locale.toLanguageTag();
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    final home = MyHomePage(
      title: 'Responsive Data Grid',
      palette: _palette,
      design: _design,
      locale: _locale,
      onPalette: (value) => setState(() => _palette = value),
      onDesign: (value) => setState(() => _design = value),
      onLocale: _setLocale,
    );
    if (_design == DemoDesign.cupertino) {
      return cupertino.CupertinoApp(
        title: 'Responsive Data Grid',
        theme: _demoCupertinoTheme(_palette),
        locale: _locale,
        supportedLocales: GridLocalizations.supportedLocales,
        localizationsDelegates: [
          GridLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: home,
      );
    }
    return MaterialApp(
      title: 'Responsive Data Grid',
      theme: _demoTheme(_palette),
      locale: _locale,
      supportedLocales: GridLocalizations.supportedLocales,
      localizationsDelegates: [
        GridLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: home,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final exampleData = List<ExampleData>.from(<ExampleData>[
    ExampleData(1, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(2, "Jane Doe", DateTime(1977, 6, 17), false, ExampleEnum.two),
    ExampleData(3, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(4, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(5, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(6, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(7, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(8, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(9, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(10, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(11, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(12, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(13, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(14, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(15, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(16, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(17, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(18, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(19, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(20, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(21, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(22, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(23, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(24, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(25, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(26, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(27, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(28, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(29, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(30, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(31, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(32, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(33, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(34, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(35, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
  ]);

  MyHomePage({
    super.key,
    required this.title,
    required this.palette,
    required this.design,
    required this.locale,
    required this.onPalette,
    required this.onDesign,
    required this.onLocale,
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final DemoPalette palette;
  final DemoDesign design;
  final Locale locale;
  final ValueChanged<DemoPalette> onPalette;
  final ValueChanged<DemoDesign> onDesign;
  final ValueChanged<Locale> onLocale;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _gridController = ResponsiveDataGridController<ExampleData>();

  @override
  void dispose() {
    _gridController.dispose();
    super.dispose();
  }

  void _cycleDesign() {
    widget.onDesign(
      widget.design == DemoDesign.material
          ? DemoDesign.cupertino
          : DemoDesign.material,
    );
  }

  void _cyclePalette() {
    const values = DemoPalette.values;
    widget.onPalette(values[(widget.palette.index + 1) % values.length]);
  }

  void _cycleLocale() {
    widget.onLocale(
      widget.locale.languageCode == 'en'
          ? const Locale('es')
          : const Locale('en'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.design == DemoDesign.cupertino) {
      return cupertino.CupertinoPageScaffold(
        navigationBar: cupertino.CupertinoNavigationBar(
          middle: Text(widget.title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              cupertino.CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                onPressed: _cycleDesign,
                child: const Text('Cupertino'),
              ),
              cupertino.CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                onPressed: _cyclePalette,
                child: Text(_paletteLabel(widget.palette)),
              ),
              cupertino.CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                onPressed: _cycleLocale,
                child: Text(widget.locale.languageCode.toUpperCase()),
              ),
            ],
          ),
        ),
        child: SafeArea(child: _grid()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actionsPadding: const EdgeInsets.only(right: 56),
        actions: [
          TextButton(onPressed: _cycleDesign, child: const Text('Material')),
          TextButton(
            onPressed: _cycleLocale,
            child: Text(widget.locale.languageCode.toUpperCase()),
          ),
          PopupMenuButton<DemoPalette>(
            tooltip: 'Theme',
            initialValue: widget.palette,
            onSelected: widget.onPalette,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const Icon(Icons.palette_outlined),
                  const SizedBox(width: 4),
                  Text(_paletteLabel(widget.palette)),
                ],
              ),
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(value: DemoPalette.light, child: Text('Light')),
              PopupMenuItem(value: DemoPalette.dark, child: Text('Dark')),
              PopupMenuItem(value: DemoPalette.branded, child: Text('Branded')),
            ],
          ),
        ],
      ),
      body: _grid(),
    );
  }

  Widget _grid() {
    return ResponsiveDataGrid<ExampleData>.clientSide(
      controller: _gridController,
      title: TitleDefinition(title: "Testing Title", icon: Icon(Icons.help)),
      toolbar: const GridToolbar(
        search: true,
        columnChooser: true,
        refresh: true,
        density: true,
      ),
      items: widget.exampleData,
      itemTapped: (row) {},
      detailBuilder: (context, item) => Text(
        '${item.name}: ${DateFormat.yMMMd().format(item.dob)}'
        ' — ${item.accepted ? "accepted" : "not accepted"}',
      ),
      pageSize: 20,
      pagingMode: PagingMode.pager,
      height: 520,
      resizable: true,
      minHeight: 280,
      filterable: FilterableMode.menuAndRow,
      sortable: SortableOptions.multiColumn,
      allowAggregations: true,
      allowGrouping: true,
      autoSize: true,
      rowDecoration: (item) => item.id.isEven
          ? BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.45),
            )
          : null,
      cellDecoration: (item, column) =>
          column.fieldName == 'accepted' && !item.accepted
          ? BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.errorContainer.withValues(alpha: 0.7),
            )
          : null,
      initialLoadCriteria: LoadCriteria(
        groupBy: [
          GroupCriteria(
            fieldName: "name",
            direction: OrderDirections.ascending,
            aggregates: [
              AggregateCriteria(
                fieldName: "name",
                aggregation: Aggregations.count,
              ),
            ],
          ),
        ],
      ),
      columns: [
        WidgetColumn(
          widget: (item) => Icon(Icons.check, color: Colors.green),
          xsCols: 1,
          fieldName: "Selected",
        ),
        IntColumn(
          xsCols: 2,
          fieldName: "id",
          header: ColumnHeader(
            text: "Id",
            showFilter: true,
            showOrderBy: true,
            showAggregations: true,
          ),
          value: (row) => row.id,
        ),
        StringColumn(
          xsCols: 5,
          mediumCols: 2,
          fieldName: "name",
          sticky: true,
          sortDirection: OrderDirections.ascending,
          filterRules: StringFilterRules(hintText: "Name"),
          header: ColumnHeader(
            text: "Name",
            showFilter: true,
            showOrderBy: true,
          ),
          value: (row) => row.name,
          aggregations: [
            AggregateCriteria(
              fieldName: "name",
              aggregation: Aggregations.count,
            ),
          ],
        ),
        DateTimeColumn(
          xsCols: 4,
          mediumCols: 3,
          fieldName: "dob",
          filterRules: DateTimeFilterRules(
            filterType: DateTimeFilterTypes.DateOnly,
          ),
          header: ColumnHeader(
            text: "Date of Birth",
            showFilter: true,
            showOrderBy: true,
          ),
          value: (row) => row.dob,
          format: DateFormat.yMd(),
        ),
        BoolColumn(
          xsCols: 3,
          mediumCols: 2,
          fieldName: "accepted",
          header: ColumnHeader(
            text: "Accepted",
            showFilter: true,
            showOrderBy: true,
            showAggregations: true,
          ),
          value: (row) => row.accepted,
          trueText: "Yes",
          falseText: "No",
        ),
        EnumColumn<ExampleData, ExampleEnum>(
          values: ExampleEnum.values,
          fieldName: "exampleEnum",
          valueText: (value) => value == ExampleEnum.one
              ? "one"
              : value == ExampleEnum.two
              ? "two"
              : "three",
          value: (row) => row.exampleEnum,
          header: ColumnHeader(
            showFilter: true,
            showOrderBy: true,
            text: "Enum",
          ),
          xsCols: 4,
          mediumCols: 2,
        ),
      ],
    );
  }
}

class ExampleData {
  final int id;
  final String name;
  final DateTime dob;
  final bool accepted;
  final ExampleEnum exampleEnum;

  const ExampleData(
    this.id,
    this.name,
    this.dob,
    this.accepted,
    this.exampleEnum,
  );
}

enum ExampleEnum { one, two, three }
