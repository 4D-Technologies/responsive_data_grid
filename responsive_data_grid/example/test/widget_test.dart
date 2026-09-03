import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

void main() {
  testWidgets('example grid renders title and sample rows', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Testing Title'), findsOneWidget);
    expect(find.byType(ResponsiveDataGrid<ExampleData>), findsOneWidget);
    expect(find.text('Name'), findsWidgets);
    expect(find.text('Id'), findsWidgets);
    expect(find.textContaining('Doe'), findsWidgets);
  });

  testWidgets('example grid still renders at a phone breakpoint', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Testing Title'), findsOneWidget);
    expect(find.byType(ResponsiveDataGrid<ExampleData>), findsOneWidget);
    expect(find.text('Name'), findsWidgets);
  });
}
