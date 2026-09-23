// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:charted/main.dart';

void main() {
  testWidgets('renders the Charted scanner home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ChartedApp());
    await tester.pump();

    expect(find.text('charted'), findsOneWidget);
    expect(find.text('Ready when you are'), findsOneWidget);
    expect(find.text('Open camera'), findsOneWidget);
    expect(find.text('Choose a file'), findsOneWidget);
  });
}
