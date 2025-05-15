import 'package:flutter_test/flutter_test.dart';
import 'package:panther/Data/models/employee.dart';

void main() {
  group('Employee Model Tests', () {
    test('should create an Employee instance with correct values', () {
      // Arrange
      const employee = Employee(
        id: '1',
        name: 'John Doe',
        pricePerHour: 25.5,
      );

      // Assert
      expect(employee.id, '1');
      expect(employee.name, 'John Doe');
      expect(employee.pricePerHour, 25.5);
    });

    test('should convert from JSON correctly', () {
      // Arrange
      final json = {
        'id': '2',
        'name': 'Jane Smith',
        'pricePerHour': 30.0,
      };

      // Act
      final employee = Employee.fromJson(json);

      // Assert
      expect(employee.id, '2');
      expect(employee.name, 'Jane Smith');
      expect(employee.pricePerHour, 30.0);
    });

    test('should convert to JSON correctly', () {
      // Arrange
      const employee = Employee(
        id: '3',
        name: 'Bob Johnson',
        pricePerHour: 22.75,
      );

      // Act
      final json = employee.toJson();

      // Assert
      expect(json, {
        'id': '3',
        'name': 'Bob Johnson',
        'pricePerHour': 22.75,
      });
    });

    test('should compare equal employees correctly', () {
      // Arrange
      const employee1 = Employee(
        id: '4',
        name: 'Alice Brown',
        pricePerHour: 28.0,
      );

      const employee2 = Employee(
        id: '4',
        name: 'Alice Brown',
        pricePerHour: 28.0,
      );

      const employee3 = Employee(
        id: '5',
        name: 'Different Person',
        pricePerHour: 28.0,
      );

      // Assert
      expect(employee1, equals(employee2));
      expect(employee1, isNot(equals(employee3)));
    });
  });
}