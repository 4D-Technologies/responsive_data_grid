import 'package:client_filtering/client_filtering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

import 'demo_data.dart';

class DemoEntry {
  final String id;
  final String section;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;

  const DemoEntry({
    required this.id,
    required this.section,
    required this.title,
    required this.subtitle,
    required this.builder,
  });
}

final demoEntries = <DemoEntry>[
  DemoEntry(
    id: 'kitchen-sink',
    section: 'Overview',
    title: 'Kitchen sink',
    subtitle: 'Pager, grouping, filters, multi-sort, light/dark theme',
    builder: (context) => const KitchenSinkScreen(),
  ),
  DemoEntry(
    id: 'server-side',
    section: 'Data',
    title: 'Server-side loadData',
    subtitle: 'Honors skip, take, and filterBy from LoadCriteria',
    builder: (context) => const ServerSideScreen(),
  ),
  DemoEntry(
    id: 'load-error',
    section: 'Data',
    title: 'loadData error',
    subtitle: 'Overlay retry after a failed fetch',
    builder: (context) => const LoadErrorScreen(),
  ),
  DemoEntry(
    id: 'empty',
    section: 'Data',
    title: 'Empty noResults',
    subtitle: 'Custom empty template when there are no rows',
    builder: (context) => const EmptyResultsScreen(),
  ),
  DemoEntry(
    id: 'paging-none',
    section: 'Paging',
    title: 'PagingMode.none',
    subtitle: 'Loads up to maximumRows; no pager',
    builder: (context) => const PagingNoneScreen(),
  ),
  DemoEntry(
    id: 'paging-auto',
    section: 'Paging',
    title: 'PagingMode.auto',
    subtitle: 'Bounded parent becomes infinite scroll',
    builder: (context) => const PagingAutoScreen(),
  ),
  DemoEntry(
    id: 'paged-fill-tab',
    section: 'Height',
    title: 'Paged fill in a tab',
    subtitle: 'Grid is one full page; the tab body scrolls',
    builder: (context) => const PagedFillTabScreen(),
  ),
  DemoEntry(
    id: 'paged-fill-tall',
    section: 'Height',
    title: 'Paged fill, tall parent',
    subtitle: 'Grid fills the viewport; pager sits at the bottom',
    builder: (context) => const PagedFillTallScreen(),
  ),
  DemoEntry(
    id: 'paged-fill-unbounded',
    section: 'Height',
    title: 'Paged fill in a ListView',
    subtitle: 'Unbounded parent uses min height; no layout exception',
    builder: (context) => const PagedFillUnboundedScreen(),
  ),
  DemoEntry(
    id: 'paged-fill-groups',
    section: 'Height',
    title: 'Paged fill with groups',
    subtitle: 'Minimum height includes group headers and footers',
    builder: (context) => const PagedFillGroupsScreen(),
  ),
  DemoEntry(
    id: 'infinite-bounds',
    section: 'Height',
    title: 'Infinite scroll min/max',
    subtitle: 'Entire grid clamps between min and max height',
    builder: (context) => const InfiniteBoundsScreen(),
  ),
  DemoEntry(
    id: 'infinite-unbounded',
    section: 'Height',
    title: 'Infinite scroll in a ListView',
    subtitle: 'Defined height inside an unbounded parent; no pager',
    builder: (context) => const InfiniteUnboundedScreen(),
  ),
  DemoEntry(
    id: 'shrink-wrap',
    section: 'Height',
    title: 'Shrink-wrap',
    subtitle: 'Grid sizes to the current page; the host scrolls',
    builder: (context) => const ShrinkWrapScreen(),
  ),
  DemoEntry(
    id: 'column-types',
    section: 'Columns',
    title: 'Double, num, Duration, TimeOfDay',
    subtitle: 'Typed columns with filters',
    builder: (context) => const ColumnTypesScreen(),
  ),
  DemoEntry(
    id: 'sort-none',
    section: 'Columns',
    title: 'SortableOptions.none',
    subtitle: 'Headers do not sort',
    builder: (context) => const SortNoneScreen(),
  ),
  DemoEntry(
    id: 'freeze-visibility',
    section: 'Columns',
    title: 'Freeze and visibility',
    subtitle: 'Frozen Id column and a hidden DOB restored from the chooser',
    builder: (context) => const FreezeVisibilityScreen(),
  ),
];

DemoEntry? demoEntryById(String id) {
  for (final entry in demoEntries) {
    if (entry.id == id) return entry;
  }
  return null;
}

class DemoHomeScreen extends StatelessWidget {
  final WidgetBuilder? kitchenSink;

  const DemoHomeScreen({super.key, this.kitchenSink});

  @override
  Widget build(BuildContext context) {
    final sections = <String, List<DemoEntry>>{};
    for (final entry in demoEntries) {
      (sections[entry.section] ??= []).add(entry);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Data Grid')),
      body: ListView(
        key: const ValueKey('demo-home'),
        children: [
          for (final section in sections.entries) ...[
            ListTile(
              title: Text(
                section.key,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            for (final entry in section.value)
              ListTile(
                key: ValueKey('demo-${entry.id}'),
                title: Text(entry.title),
                subtitle: Text(entry.subtitle),
                onTap: () {
                  final builder =
                      entry.id == 'kitchen-sink' && kitchenSink != null
                      ? kitchenSink!
                      : entry.builder;
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: builder,
                      settings: RouteSettings(name: entry.id),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}

class KitchenSinkScreen extends StatelessWidget {
  const KitchenSinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kitchen sink')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ResponsiveDataGrid<ExampleData>.clientSide(
          items: exampleRows(35),
          columns: exampleColumns(),
          pageSize: 20,
          pagingMode: PagingMode.pager,
          title: const TitleDefinition(title: 'Testing Title'),
        ),
      ),
    );
  }
}

class PagedFillTabScreen extends StatelessWidget {
  const PagedFillTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paged fill in a tab'),
          bottom: const TabBar(
            tabs: [
              Tab(key: ValueKey('demo-tab-grid'), text: 'Grid'),
              Tab(key: ValueKey('demo-tab-other'), text: 'Other'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PagedFillTabBody(),
            Center(
              key: ValueKey('demo-other-tab'),
              child: Text('Other tab content'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PagedFillTabBody extends StatelessWidget {
  const _PagedFillTabBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('host-scroll'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The tab body scrolls. The grid is one full page of rows plus '
              'header and pager, with no inner vertical scrollbar.',
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Record name'),
            ),
            const SizedBox(height: 12),
            ResponsiveDataGrid<ExampleData>.clientSide(
              items: exampleRows(80),
              columns: exampleColumns(),
              pageSize: 15,
              pageSizeOptions: const [10, 15, 25, 50],
              pagingMode: PagingMode.pager,
              sizing: GridSizing.fill,
            ),
            const SizedBox(height: 24),
            const Text('Content below the grid in the same tab.'),
          ],
        ),
      ),
    );
  }
}

class PagedFillTallScreen extends StatelessWidget {
  const PagedFillTallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paged fill, tall parent')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ResponsiveDataGrid<ExampleData>.clientSide(
          items: exampleRows(80),
          columns: exampleColumns(),
          pageSize: 10,
          pagingMode: PagingMode.pager,
          sizing: GridSizing.fill,
        ),
      ),
    );
  }
}

class PagedFillUnboundedScreen extends StatelessWidget {
  const PagedFillUnboundedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paged fill in a ListView')),
      body: ListView(
        key: const ValueKey('host-scroll'),
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Host ListView above the grid.'),
          const SizedBox(height: 12),
          ResponsiveDataGrid<ExampleData>.clientSide(
            items: exampleRows(80),
            columns: exampleColumns(),
            pageSize: 12,
            pagingMode: PagingMode.pager,
            sizing: GridSizing.fill,
          ),
          const SizedBox(height: 12),
          const Text('Host ListView below the grid.'),
        ],
      ),
    );
  }
}

class PagedFillGroupsScreen extends StatelessWidget {
  const PagedFillGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paged fill with groups')),
      body: ListView(
        key: const ValueKey('host-scroll'),
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Grouped page includes group headers in the minimum height.'),
          const SizedBox(height: 12),
          ResponsiveDataGrid<ExampleData>.clientSide(
            items: exampleRows(80),
            columns: exampleColumns(),
            pageSize: 10,
            pagingMode: PagingMode.pager,
            sizing: GridSizing.fill,
            allowGrouping: true,
            initialLoadCriteria: LoadCriteria(
              groupBy: [
                GroupCriteria(
                  fieldName: 'team',
                  direction: OrderDirections.ascending,
                  aggregates: const [],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfiniteBoundsScreen extends StatefulWidget {
  const InfiniteBoundsScreen({super.key});

  @override
  State<InfiniteBoundsScreen> createState() => _InfiniteBoundsScreenState();
}

class _InfiniteBoundsScreenState extends State<InfiniteBoundsScreen> {
  double _parentHeight = 360;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Infinite scroll min/max')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parent height ${_parentHeight.round()}px. Grid min 240, max 420.',
            ),
            Slider(
              key: const ValueKey('demo-parent-height'),
              min: 160,
              max: 560,
              value: _parentHeight,
              onChanged: (value) => setState(() => _parentHeight = value),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final height = _parentHeight.clamp(
                    160.0,
                    constraints.maxHeight,
                  );
                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: height,
                      width: double.infinity,
                      child: ResponsiveDataGrid<ExampleData>.clientSide(
                        items: exampleRows(80),
                        columns: exampleColumns(),
                        pageSize: 20,
                        pagingMode: PagingMode.infiniteScroll,
                        minHeight: 240,
                        maxHeight: 420,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfiniteUnboundedScreen extends StatelessWidget {
  const InfiniteUnboundedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Infinite scroll in a ListView')),
      body: ListView(
        key: const ValueKey('host-scroll'),
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Unbounded parent. Grid uses minHeight 280 (max 400).'),
          const SizedBox(height: 12),
          ResponsiveDataGrid<ExampleData>.clientSide(
            items: exampleRows(80),
            columns: exampleColumns(),
            pageSize: 20,
            pagingMode: PagingMode.infiniteScroll,
            minHeight: 280,
            maxHeight: 400,
          ),
          const SizedBox(height: 12),
          const Text('Content below the grid.'),
        ],
      ),
    );
  }
}

class ServerSideScreen extends StatefulWidget {
  const ServerSideScreen({super.key});

  @override
  State<ServerSideScreen> createState() => _ServerSideScreenState();
}

dynamic _exampleField(String fieldName, ExampleData item) {
  switch (fieldName) {
    case 'id':
      return item.id;
    case 'name':
      return item.name;
    case 'team':
      return item.team;
    case 'dob':
      return item.dob;
    default:
      return null;
  }
}

class _ServerSideScreenState extends State<ServerSideScreen> {
  LoadCriteria? _last;

  Future<ListResponse<ExampleData>?> _load(LoadCriteria criteria) async {
    _last = criteria;
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (mounted) setState(() {});
    return ListResponse.fromData(
      data: exampleRows(80),
      criteria: criteria,
      getFieldValue: _exampleField,
    );
  }

  @override
  Widget build(BuildContext context) {
    final last = _last;
    return Scaffold(
      appBar: AppBar(title: const Text('Server-side loadData')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key: const ValueKey('demo-criteria'),
              last == null
                  ? 'Waiting for LoadCriteria…'
                  : 'skip ${last.skip} take ${last.take} filters ${last.filterBy.length}',
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ResponsiveDataGrid<ExampleData>.serverSide(
                loadData: _load,
                columns: exampleColumns(),
                pageSize: 15,
                pagingMode: PagingMode.pager,
                sizing: GridSizing.fill,
                filterable: FilterableMode.menu,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadErrorScreen extends StatefulWidget {
  const LoadErrorScreen({super.key});

  @override
  State<LoadErrorScreen> createState() => _LoadErrorScreenState();
}

class _LoadErrorScreenState extends State<LoadErrorScreen> {
  var _attempts = 0;

  Future<ListResponse<ExampleData>?> _load(LoadCriteria criteria) async {
    _attempts++;
    if (_attempts == 1) {
      throw StateError('backend down');
    }
    final all = exampleRows(20);
    final skip = criteria.skip ?? 0;
    final take = criteria.take ?? 10;
    return ListResponse<ExampleData>(
      totalCount: all.length,
      items: all.skip(skip).take(take).toList(),
      groups: const [],
      aggregates: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('loadData error')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ResponsiveDataGrid<ExampleData>.serverSide(
          loadData: _load,
          columns: exampleColumns(),
          pageSize: 10,
          pagingMode: PagingMode.pager,
          height: 500,
        ),
      ),
    );
  }
}

class EmptyResultsScreen extends StatelessWidget {
  const EmptyResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Empty noResults')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ResponsiveDataGrid<ExampleData>.clientSide(
          items: const [],
          columns: exampleColumns(),
          pageSize: 10,
          pagingMode: PagingMode.pager,
          height: 400,
          noResults: const Center(
            key: ValueKey('demo-no-results'),
            child: Text('Nothing here'),
          ),
        ),
      ),
    );
  }
}

class PagingNoneScreen extends StatelessWidget {
  const PagingNoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PagingMode.none')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ResponsiveDataGrid<ExampleData>.clientSide(
          items: exampleRows(40),
          columns: exampleColumns(),
          pagingMode: PagingMode.none,
          maximumRows: 40,
          sizing: GridSizing.fill,
        ),
      ),
    );
  }
}

class PagingAutoScreen extends StatelessWidget {
  const PagingAutoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PagingMode.auto')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ResponsiveDataGrid<ExampleData>.clientSide(
          items: exampleRows(80),
          columns: exampleColumns(),
          pagingMode: PagingMode.auto,
          pageSize: 20,
          height: 480,
        ),
      ),
    );
  }
}

class ShrinkWrapScreen extends StatelessWidget {
  const ShrinkWrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shrink-wrap')),
      body: ListView(
        key: const ValueKey('host-scroll'),
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Host ListView. Grid sizes to this page of rows.'),
          const SizedBox(height: 12),
          ResponsiveDataGrid<ExampleData>.clientSide(
            items: exampleRows(40),
            columns: exampleColumns(),
            pageSize: 5,
            pagingMode: PagingMode.pager,
            sizing: GridSizing.shrinkWrap,
          ),
          const SizedBox(height: 12),
          const Text('Content below the grid.'),
        ],
      ),
    );
  }
}

class ColumnTypesScreen extends StatelessWidget {
  const ColumnTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Typed columns')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ResponsiveDataGrid<ExampleData>.clientSide(
          items: exampleRows(40),
          columns: typedColumns(),
          pageSize: 10,
          pagingMode: PagingMode.pager,
          sizing: GridSizing.fill,
          filterable: FilterableMode.row,
        ),
      ),
    );
  }
}

class SortNoneScreen extends StatelessWidget {
  const SortNoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SortableOptions.none')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ResponsiveDataGrid<ExampleData>.clientSide(
          items: exampleRows(20),
          columns: exampleColumns(),
          pageSize: 10,
          pagingMode: PagingMode.pager,
          sortable: SortableOptions.none,
          height: 500,
        ),
      ),
    );
  }
}

class FreezeVisibilityScreen extends StatelessWidget {
  const FreezeVisibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Freeze and visibility')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ResponsiveDataGrid<ExampleData>.clientSide(
          items: exampleRows(40),
          columns: [
            IntColumn(
              xsCols: 2,
              fieldName: 'id',
              frozen: true,
              header: const ColumnHeader(text: 'Id', showOrderBy: true),
              value: (row) => row.id,
            ),
            StringColumn(
              xsCols: 4,
              fieldName: 'name',
              header: const ColumnHeader(text: 'Name', showOrderBy: true),
              value: (row) => row.name,
            ),
            StringColumn(
              xsCols: 3,
              fieldName: 'team',
              header: const ColumnHeader(text: 'Team', showOrderBy: true),
              value: (row) => row.team,
            ),
            DateTimeColumn(
              xsCols: 3,
              fieldName: 'dob',
              visible: false,
              header: const ColumnHeader(text: 'Date of Birth'),
              value: (row) => row.dob,
            ),
          ],
          pageSize: 10,
          pagingMode: PagingMode.pager,
          height: 500,
          toolbar: const GridToolbar(columnChooser: true),
        ),
      ),
    );
  }
}
