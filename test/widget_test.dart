import 'package:flutter_test/flutter_test.dart';
import 'package:speaker_cleaner_pro/main.dart';

void main() {
  testWidgets('Speaker Cleaner Pro app loads',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SpeakerCleanerApp());

    expect(find.text('Speaker Cleaner Pro'), findsOneWidget);
  });
}
