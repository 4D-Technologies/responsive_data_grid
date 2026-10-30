import 'package:client_filtering/client_filtering.dart';
import 'package:example/demo_data.dart' as demo;
import 'package:example/demo_screens.dart';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

void main() {
  testWidgets('demo home lists scenario screens', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('demo-home')), findsOneWidget);
    expect(find.byKey(const ValueKey('demo-server-side')), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('demo-paged-fill-tab')),
      200,
    );
    expect(find.text('Paged fill in a tab'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('demo-infinite-bounds')),
      200,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('demo-column-types')),
      200,
    );
  });

  testWidgets('kitchen sink still renders from the catalog', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('demo-kitchen-sink')));
    await tester.pumpAndSettle();

    expect(find.text('Testing Title'), findsOneWidget);
    expect(find.byType(ResponsiveDataGrid<ExampleData>), findsOneWidget);
    expect(find.text('Name'), findsWidgets);
    expect(find.text('Id'), findsWidgets);
    expect(find.textContaining('Doe'), findsWidgets);
  });

  testWidgets('paged fill tab hosts a full page and a host scroller', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          GridLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: const PagedFillTabScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('host-scroll')), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);
    expect(
      find.byType(ResponsiveDataGrid<demo.ExampleData>),
      findsOneWidget,
    );
    final body = tester.widget<ScrollView>(
      find.byKey(const ValueKey('rdg-body-scroll')),
    );
    expect(body.physics, isA<NeverScrollableScrollPhysics>());
  });

  Future<void> pumpDemo(WidgetTester tester, Widget home, {Size? view}) async {
    tester.view.physicalSize = view ?? const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          GridLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: home,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('paged fill with groups shrink-wraps the grouped body', (
    tester,
  ) async {
    await pumpDemo(tester, const PagedFillGroupsScreen());
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('rdg-group-toggle-team-Admin')),
      findsWidgets,
    );
    final body = tester.widget<ScrollView>(
      find.byKey(const ValueKey('rdg-body-scroll')),
    );
    expect(body.physics, isA<NeverScrollableScrollPhysics>());
    expect(body.shrinkWrap, isTrue);
  });

  testWidgets('paged fill ListView uses min height without throwing', (
    tester,
  ) async {
    await pumpDemo(tester, const PagedFillUnboundedScreen());
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('host-scroll')), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);
    expect(
      tester
          .widget<ScrollView>(find.byKey(const ValueKey('rdg-body-scroll')))
          .physics,
      isA<NeverScrollableScrollPhysics>(),
    );
  });

  testWidgets('infinite scroll ListView uses minHeight and has no pager', (
    tester,
  ) async {
    await pumpDemo(tester, const InfiniteUnboundedScreen());
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('rdg-pager')), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('rdg-height'))).height,
      closeTo(280, 2),
    );
  });

  testWidgets('infinite bounds screen clamps between min and max', (
    tester,
  ) async {
    await pumpDemo(
      tester,
      const InfiniteBoundsScreen(),
      view: const Size(390, 900),
    );
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('rdg-pager')), findsNothing);
    final height = tester
        .getSize(find.byKey(const ValueKey('rdg-height')))
        .height;
    expect(height, greaterThanOrEqualTo(240));
    expect(height, lessThanOrEqualTo(420));
  });

  testWidgets('server-side screen sends skip and take', (tester) async {
    await pumpDemo(tester, const ServerSideScreen(), view: const Size(900, 800));
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('demo-criteria')), findsOneWidget);
    expect(find.textContaining('skip'), findsOneWidget);
    expect(find.textContaining('take'), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);
    expect(find.textContaining('Jane Doe'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('rdg-header-menu-name')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byType(DropdownButtonFormField<Logic?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Logic.contains.toString()).last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Ada');
    await tester.pump();
    await tester.tap(find.text(LocalizedMessages.apply));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.textContaining('filters 1'), findsOneWidget);
    expect(find.textContaining('Ada Lovelace'), findsWidgets);
    expect(find.textContaining('Jane Doe'), findsNothing);
  });

  testWidgets('empty screen shows noResults', (tester) async {
    await pumpDemo(tester, const EmptyResultsScreen());
    expect(find.byKey(const ValueKey('demo-no-results')), findsOneWidget);
    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('load error screen shows retry then rows', (tester) async {
    await pumpDemo(tester, const LoadErrorScreen(), view: const Size(900, 800));
    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Retry'), findsNothing);
    expect(find.textContaining('Doe'), findsWidgets);
  });

  testWidgets('paging none has no pager', (tester) async {
    await pumpDemo(tester, const PagingNoneScreen(), view: const Size(900, 800));
    expect(find.byKey(const ValueKey('rdg-pager')), findsNothing);
    expect(find.text('Person 1'), findsNothing);
    expect(find.textContaining('Doe'), findsWidgets);
  });

  testWidgets('paging auto with height has no pager', (tester) async {
    await pumpDemo(tester, const PagingAutoScreen(), view: const Size(900, 800));
    expect(find.byKey(const ValueKey('rdg-pager')), findsNothing);
    expect(
      find.byType(ResponsiveGridInfiniteScrollBodyWidget<demo.ExampleData>),
      findsOneWidget,
    );
  });

  testWidgets('typed columns render score and duration headers', (tester) async {
    await pumpDemo(
      tester,
      const ColumnTypesScreen(),
      view: const Size(1100, 800),
    );
    expect(find.text('Score'), findsOneWidget);
    expect(find.text('Hours'), findsOneWidget);
    expect(find.text('Shift'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('shrink-wrap uses host scroll and a pager', (tester) async {
    await pumpDemo(tester, const ShrinkWrapScreen());
    expect(find.byKey(const ValueKey('host-scroll')), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);
    expect(
      tester
          .widget<ScrollView>(find.byKey(const ValueKey('rdg-body-scroll')))
          .physics,
      isA<NeverScrollableScrollPhysics>(),
    );
  });

  testWidgets('sort none screen renders without applying sort', (tester) async {
    await pumpDemo(tester, const SortNoneScreen(), view: const Size(900, 800));
    expect(tester.takeException(), isNull);
    expect(find.text('Name'), findsWidgets);
    expect(
      find.byKey(const ValueKey('rdg-header-sort-name')),
      findsNothing,
    );
    await tester.tap(find.text('Name').first);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('rdg-header-sort-name')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('rdg-header-sort-index-name')),
      findsNothing,
    );
  });

  testWidgets('freeze-visibility shows chooser and hides DOB', (tester) async {
    await pumpDemo(
      tester,
      const FreezeVisibilityScreen(),
      view: const Size(900, 800),
    );
    expect(find.text('Id'), findsWidgets);
    expect(find.text('Name'), findsWidgets);
    expect(find.text('Date of Birth'), findsNothing);
    expect(find.byKey(const ValueKey('rdg-header-cell-dob')), findsNothing);
    expect(find.byTooltip('Columns'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('rdg-toolbar-columns')));
    await tester.pumpAndSettle();
    final dobItem = find.widgetWithText(
      CheckedPopupMenuItem<String>,
      'Date of Birth',
    );
    await tester.ensureVisible(dobItem);
    await tester.tap(dobItem);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('rdg-header-cell-dob')), findsOneWidget);
  });
}
