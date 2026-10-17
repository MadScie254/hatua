import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatua_app/src/models/opportunity.dart';
import 'package:hatua_app/src/screens/home_screen.dart';

void main() {
  testWidgets('home offers opportunity and support pathways', (tester) async {
    int? navigatedTo;
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: HomeScreen(onNavigate: (index) => navigatedTo = index),
    )));
    expect(find.text('Find opportunities'), findsOneWidget);
    expect(find.text('Find support'), findsOneWidget);
    await tester.tap(find.text('Find opportunities'));
    expect(navigatedTo, 1);
  });

  test('Opportunity parses optional deadline', () {
    final opportunity = Opportunity.fromJson({
      'id': '123', 'title': 'Training', 'organisation': 'Example',
      'summary': '', 'category': 'training', 'county': 'Nairobi',
      'deadline': null,
    });
    expect(opportunity.deadline, isNull);
    expect(opportunity.county, 'Nairobi');
  });
}
