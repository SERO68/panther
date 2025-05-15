import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panther/main.dart';
import 'package:panther/core/routes/approutes.dart';

void main() {
  group('MyApp Widget Tests', () {
    testWidgets('should have correct initial configuration', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      
      expect(materialApp.title, 'Panther');
      expect(materialApp.debugShowCheckedModeBanner, false);
      
      expect(materialApp.theme, isA<ThemeData>());
      expect(materialApp.theme!.colorScheme, isA<ColorScheme>());
      expect(materialApp.theme!.useMaterial3, true);
      
      expect(materialApp.initialRoute, Approutename.connecttion);
      expect(materialApp.onGenerateRoute, isNotNull);
    });
    
    testWidgets('should use deep purple as seed color', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      final ColorScheme colorScheme = materialApp.theme!.colorScheme;
    
      expect(colorScheme.primary.red < colorScheme.primary.blue, true);
    });
  });
}