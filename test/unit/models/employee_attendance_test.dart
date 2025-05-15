import 'package:flutter_test/flutter_test.dart';
import 'package:panther/Data/models/employeeAttendance.dart';

void main() {
  group('EmployeeAttendance Model Tests', () {
    test('should create an EmployeeAttendance instance with correct values', () {
      final checkIn = DateTime(2023, 5, 10, 9, 0);
      final checkOut = DateTime(2023, 5, 10, 17, 0);
      
      final attendance = EmployeeAttendance(
        id: 1,
        employeeId: 101,
        checkIn: checkIn,
        checkOut: checkOut,
        status: 'present',
      );

      expect(attendance.id, 1);
      expect(attendance.employeeId, 101);
      expect(attendance.checkIn, checkIn);
      expect(attendance.checkOut, checkOut);
      expect(attendance.status, 'present');
    });

    test('should convert from JSON correctly', () {
      final json = {
        'id': 2,
        'employeeId': 102,
        'checkIn': '2023-05-11T08:30:00.000Z',
        'checkOut': '2023-05-11T16:45:00.000Z',
        'status': 'present',
      };

      final attendance = EmployeeAttendance.fromJson(json);

      expect(attendance.id, 2);
      expect(attendance.employeeId, 102);
      expect(attendance.checkIn, DateTime.parse('2023-05-11T08:30:00.000Z'));
      expect(attendance.checkOut, DateTime.parse('2023-05-11T16:45:00.000Z'));
      expect(attendance.status, 'present');
    });

    test('should handle null dates in JSON correctly', () {
      final json = {
        'id': 3,
        'employeeId': 103,
        'checkIn': null,
        'checkOut': null,
        'status': 'absent',
      };

      final attendance = EmployeeAttendance.fromJson(json);

      expect(attendance.id, 3);
      expect(attendance.employeeId, 103);
      expect(attendance.checkIn, null);
      expect(attendance.checkOut, null);
      expect(attendance.status, 'absent');
    });

    test('should convert to JSON correctly', () {
      final checkIn = DateTime(2023, 5, 12, 9, 15);
      final checkOut = DateTime(2023, 5, 12, 17, 30);
      
      final attendance = EmployeeAttendance(
        id: 4,
        employeeId: 104,
        checkIn: checkIn,
        checkOut: checkOut,
        status: 'present',
      );

      
      final json = attendance.toJson();

      expect(json['id'], 4);
      expect(json['employeeId'], 104);
      expect(json['checkIn'], checkIn.toIso8601String());
      expect(json['checkOut'], checkOut.toIso8601String());
      expect(json['status'], 'present');
    });

    test('should compare equal attendances correctly', () {
      final checkIn = DateTime(2023, 5, 13, 9, 0);
      final checkOut = DateTime(2023, 5, 13, 17, 0);
      
      final attendance1 = EmployeeAttendance(
        id: 5,
        employeeId: 105,
        checkIn: checkIn,
        checkOut: checkOut,
        status: 'present',
      );

      final attendance2 = EmployeeAttendance(
        id: 5,
        employeeId: 105,
        checkIn: checkIn,
        checkOut: checkOut,
        status: 'present',
      );

      final attendance3 = EmployeeAttendance(
        id: 6,
        employeeId: 105,
        checkIn: checkIn,
        checkOut: checkOut,
        status: 'present',
      );

      expect(attendance1, equals(attendance2));
      expect(attendance1, isNot(equals(attendance3)));
    });
  });
}