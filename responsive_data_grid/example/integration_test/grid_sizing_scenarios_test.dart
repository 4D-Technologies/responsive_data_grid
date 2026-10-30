import 'package:example/demo_data.dart' as demo;
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> openDemo(WidgetTester tester, String id) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('demo-$id')));
    await tester.pumpAndSettle();
  }

  ScrollView bodyScroll(WidgetTester tester) {
    return tester.widget<ScrollView>(
      find.byKey(const ValueKey('rdg-body-scroll')),
    );
  }

  testWidgets('paged fill tab: host scrolls, grid body does not', (
    tester,
  ) async {
    await openDemo(tester, 'paged-fill-tab');

    expect(find.byKey(const ValueKey('host-scroll')), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);
    expect(
      find.byType(ResponsiveDataGrid<demo.ExampleData>),
      findsOneWidget,
    );
    expect(bodyScroll(tester).physics, isA<NeverScrollableScrollPhysics>());
    expect(bodyScroll(tester).shrinkWrap, isTrue);
    expect(
      find.text('Content below the grid in the same tab.'),
      findsOneWidget,
    );

    final hostScrollable = find
        .descendant(
          of: find.byKey(const ValueKey('host-scroll')),
          matching: find.byType(Scrollable),
        )
        .first;
    expect(
      tester.state<ScrollableState>(hostScrollable).position.maxScrollExtent,
      greaterThan(50),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('paged fill tall parent shows pager at the bottom', (
    tester,
  ) async {
    await openDemo(tester, 'paged-fill-tall');
    expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);
    expect(find.text('John Doe'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('paged fill in a ListView uses min height without throwing', (
    tester,
  ) async {
    await openDemo(tester, 'paged-fill-unbounded');
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('host-scroll')), findsOneWidget);
    expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);
    expect(bodyScroll(tester).physics, isA<NeverScrollableScrollPhysics>());
    expect(find.text('Host ListView below the grid.'), findsOneWidget);
  });

  testWidgets('paged fill with groups includes group chrome', (tester) async {
    await openDemo(tester, 'paged-fill-groups');
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('rdg-pager')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('rdg-group-toggle-team-Admin')),
      findsWidgets,
    );
    expect(bodyScroll(tester).physics, isA<NeverScrollableScrollPhysics>());
    expect(bodyScroll(tester).shrinkWrap, isTrue);
  });

  testWidgets('infinite scroll clamps height and has no pager', (tester) async {
    await openDemo(tester, 'infinite-bounds');
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('rdg-pager')), findsNothing);
    expect(find.byKey(const ValueKey('demo-parent-height')), findsOneWidget);
    expect(find.text('John Doe'), findsWidgets);

    final height = tester
        .getSize(find.byKey(const ValueKey('rdg-height')))
        .height;
    expect(height, greaterThanOrEqualTo(240));
    expect(height, lessThanOrEqualTo(420));
  });

  testWidgets('infinite scroll in a ListView uses minHeight without throwing', (
    tester,
  ) async {
    await openDemo(tester, 'infinite-unbounded');
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('rdg-pager')), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('rdg-height'))).height,
      closeTo(280, 2),
    );
    expect(find.text('Content below the grid.'), findsOneWidget);
  });
}
