import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_interview_prep/main.dart';
import 'package:flutter_interview_prep/screens/home_screen.dart';

void main() {
  testWidgets('app boots to the interview prep shell', (tester) async {
    await tester.pumpWidget(const FlutterInterviewPrepApp());
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Interview Prep Tracks'), findsOneWidget);
  });
}
