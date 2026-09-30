import 'package:campus_loop/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('glass card widget renders content', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassCard(
              child: Text('CampusLoop'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('CampusLoop'), findsOneWidget);
  });
}
