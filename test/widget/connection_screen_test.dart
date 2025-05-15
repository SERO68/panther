import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:panther/features/connection/screens/connectionscreen.dart';
import 'package:panther/data/services/socket/socket_service.dart';

class MockSocketService extends Mock implements SocketService {}

void main() {
  group('ConnectionScreen Widget Tests', () {
    testWidgets('should render connection form elements', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ConnectionScreen(),
      ));

      expect(find.text('Connect to Panther'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3)); 
      expect(find.byType(ElevatedButton), findsOneWidget); 
    });

    testWidgets('should show error message when fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ConnectionScreen(),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please fill all fields'), findsOneWidget);
    });

    testWidgets('should show password field and connect button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ConnectionScreen(),
      ));

      final passwordField = find.byType(TextField).at(2);
      expect(passwordField, findsOneWidget);

      final connectButton = find.byType(ElevatedButton);
      expect(connectButton, findsOneWidget);
    });

  });
}