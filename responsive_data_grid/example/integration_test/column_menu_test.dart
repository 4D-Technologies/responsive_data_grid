import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('column filter menu opens, fits, and apply dismisses it', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('demo-kitchen-sink')));
    await tester.pumpAndSettle();

    expect(find.text('Testing Title'), findsWidgets);

    final nameMenu = find.byKey(const ValueKey('rdg-header-menu-name'));
    expect(nameMenu, findsOneWidget);
    await tester.ensureVisible(nameMenu);
    await tester.tap(nameMenu);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text(LocalizedMessages.apply), findsOneWidget);

    await tester.tap(find.text(LocalizedMessages.apply));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(LocalizedMessages.apply), findsNothing);
  });
}
