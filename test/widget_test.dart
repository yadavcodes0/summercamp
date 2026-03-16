// Basic widget smoke test for the Summer Camp app.

import 'package:flutter_test/flutter_test.dart';
import 'package:summer_camp/main.dart';

void main() {
  testWidgets('MobileApp renders without crashing', (WidgetTester tester) async {
    // Build the MobileApp and trigger a frame.
    await tester.pumpWidget(const MobileApp());

    // Verify the app builds successfully (at minimum, a widget tree exists).
    expect(find.byType(MobileApp), findsOneWidget);
  });
}
