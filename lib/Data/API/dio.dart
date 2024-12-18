import 'package:dio/dio.dart';

import '../models/employee.dart';

class EmployeeApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://panther.runasp.net/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Create a new employee
  Future<Employee> createEmployee(Employee employee) async {
    try {
      final response = await _dio.post(
        'Employees',
        data: employee.toJson(),
      );
      return Employee.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Get all employees
  Future<List<Employee>> getEmployees() async {
    try {
      final response = await _dio.get('Employees');
      return (response.data as List)
          .map((json) => Employee.fromJson(json))
          .toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Get employee by ID
  Future<Employee> getEmployeeById(String id) async {
    try {
      final response = await _dio.get('Employees/$id');
      return Employee.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Update employee
  Future<Employee> updateEmployee(String id, Employee employee) async {
    try {
      final response = await _dio.put(
        'Employees/$id',
        data: employee.toJson(),
      );
      return Employee.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Delete employee
  Future<void> deleteEmployee(String id) async {
    try {
      await _dio.delete('Employees/$id');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Record employee attendance
  Future<void> recordAttendance(String employeeId, DateTime attendanceTime) async {
    try {
      await _dio.post(
        'EmployeeAttendances/$employeeId',
        data: attendanceTime.toIso8601String(),
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Get employee salary
  Future<double> getEmployeeSalary(String employeeId) async {
    try {
      final response = await _dio.get('EmployeeAttendances/$employeeId/salary');
      return (response.data as num).toDouble();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Error handler
  void _handleError(DioException error) {
    String errorMessage = 'An unknown error occurred';
    
    if (error.response != null) {
      switch (error.response!.statusCode) {
        case 400:
          errorMessage = 'Bad Request: ${error.response!.data}';
          break;
        case 401:
          errorMessage = 'Unauthorized: Authentication is required';
          break;
        case 403:
          errorMessage = 'Forbidden: You do not have permission';
          break;
        case 404:
          errorMessage = 'Not Found: The requested resource does not exist';
          break;
        case 500:
          errorMessage = 'Server Error: Something went wrong on the server';
          break;
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Connection Timeout';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Receive Timeout';
    }

    throw Exception(errorMessage);
  }
}