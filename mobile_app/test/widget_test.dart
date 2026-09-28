import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('HomeHelpApp loads role selection screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HomeHelpApp());

    // Verify that the title text exists
    expect(find.text('HOMEHELP'), findsOneWidget);
    expect(find.text('CUSTOMER'), findsOneWidget);
  });
}
