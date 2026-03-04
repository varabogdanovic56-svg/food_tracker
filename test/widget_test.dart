import 'package:flutter_test/flutter_test.dart';

import 'package:food_tracker/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('Food Tracker'), findsOneWidget);
  });
}
