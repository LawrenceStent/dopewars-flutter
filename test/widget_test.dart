import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dopewars_flutter/app.dart';
import 'package:dopewars_flutter/injection_container.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await initDependencies();
  });

  tearDownAll(() async {
    await resetDependencies();
  });

  testWidgets('App loads home page', (WidgetTester tester) async {
    await tester.pumpWidget(DopeWarsApp());
    await tester.pumpAndSettle();

    // Verify that the home page loads with the title
    expect(find.text('DOPEWARS'), findsOneWidget);
    expect(find.text('Flutter Edition'), findsOneWidget);
    expect(find.text('START GAME'), findsOneWidget);
  });
}
