import 'package:client_filtering/client_filtering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

import 'demo_data.dart';

class DemoEntry {
  final String id;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;

  const DemoEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.builder,
  });
}

final demoEntries = <DemoEntry>[
  DemoEntry(
    id: 'kitchen-sink',
    title: 'Kitchen sink',
    subtitle: 'Full-featured pager grid',
    builder: (context) => const KitchenSinkScreen(),
  ),
  DemoEntry(
    id: 'paged-fill-tab',
    title: 'Paged fill in a tab',
    subtitle: 'Grid is one full page; the tab body scrolls',
    builder: (context) => const PagedFillTabScreen(),
  ),
  DemoEntry(
    id: 'paged-fill-tall',
    title: 'Paged fill, tall parent',
    subtitle: 'Grid fills the viewport; pager sits at the bottom',
    builder: (context) => const PagedFillTallScreen(),
  ),
  DemoEntry(
    id: 'paged-fill-unbounded',
    title: 'Paged fill in a ListView',
    subtitle: 'Unbounded parent uses min height; no layout exception',
    builder: (context) => const PagedFillUnboundedScreen(),
  ),
  DemoEntry(
    id: 'paged-fill-groups',
    title: 'Paged fill with groups',
    subtitle: 'Minimum height includes group headers and footers',
    builder: (context) => const PagedFillGroupsScreen(),
  ),
  DemoEntry(
    id: 'infinite-bounds',
    title: 'Infinite scroll min/max',
    subtitle: 'Entire grid clamps between min and max height',
    builder: (context) => const InfiniteBoundsScreen(),
  ),
  DemoEntry(
    id: 'infinite-unbounded',
    title: 'Infinite scroll in a ListView',
    subtitle: 'Defined height inside an unbounded parent; no pager',
    builder: (context) => const InfiniteUnboundedScreen(),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Data Grid')),
      body: ListView(
        key: const ValueKey('demo-home'),
        children: [
          for (final entry in demoEntries)
            ListTile(
              key: ValueKey('demo-${entry.id}'),
              title: Text(entry.title),
              subtitle: Text(entry.subtitle),
              onTap: () {
                final builder = entry.id == 'kitchen-sink' && kitchenSink != null
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
