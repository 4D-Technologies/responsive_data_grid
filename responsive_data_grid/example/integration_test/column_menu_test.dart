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

    expect(find.text('Testing Title'), findsWidgets);
    expect(find.byType(MenuAnchor), findsWidgets);

    await tester.tap(find.byIcon(Icons.menu).first);
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
