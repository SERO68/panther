import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panther/core/routes/approutes.dart';
import 'package:panther/core/routes/routefunc.dart';

void main() {
  group('Route Generation Tests', () {
    test('should return route for home route name', () {
      const settings = RouteSettings(name: Approutename.home);
      
      final route = onGenerateRoute(settings);
      
      expect(route, isA<MaterialPageRoute>());
    });
    
    test('should return route for control route name', () {
      const settings = RouteSettings(name: Approutename.control);
      
      final route = onGenerateRoute(settings);
      
      expect(route, isA<MaterialPageRoute>());
    });
    
    test('should return route for connection route name', () {
      const settings = RouteSettings(name: Approutename.connecttion);
      
      final route = onGenerateRoute(settings);
      
      expect(route, isA<MaterialPageRoute>());
    });
    
    test('should return null for unknown route', () {
      const settings = RouteSettings(name: '/unknown');
      
      final route = onGenerateRoute(settings);
      
      expect(route, isNull);
    });
  });
}