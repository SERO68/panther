import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../API/dio.dart';
import '../models/employee.dart';

// States
abstract class EmployeeState extends Equatable {
  const EmployeeState();
  
  @override
  List<Object> get props => [];
}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class EmployeeLoaded extends EmployeeState {
  final List<Employee> employees;
  
  const EmployeeLoaded(this.employees);
  
  @override
  List<Object> get props => [employees];
}

class EmployeeCreated extends EmployeeState {
  final Employee employee;
  
  const EmployeeCreated(this.employee);
  
  @override
  List<Object> get props => [employee];
}

class EmployeeUpdated extends EmployeeState {
  final Employee employee;
  
  const EmployeeUpdated(this.employee);
  
  @override
  List<Object> get props => [employee];
}

class EmployeeDeleted extends EmployeeState {}

class EmployeeError extends EmployeeState {
  final String message;
  
  const EmployeeError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Cubit
class EmployeeCubit extends Cubit<EmployeeState> {
  final EmployeeApiService _apiService;
  
  EmployeeCubit(this._apiService) : super(EmployeeInitial());
  
  // Fetch all employees
  Future<void> fetchEmployees() async {
    try {
      emit(EmployeeLoading());
      final employees = await _apiService.getEmployees();
      emit(EmployeeLoaded(employees));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }
  
  // Create a new employee
  Future<void> createEmployee(Employee employee) async {
    try {
      emit(EmployeeLoading());
      final createdEmployee = await _apiService.createEmployee(employee);
      emit(EmployeeCreated(createdEmployee));
      // Refetch the list to update
      await fetchEmployees();
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }
  
  // Update an existing employee
  Future<void> updateEmployee(String id, Employee employee) async {
    try {
      emit(EmployeeLoading());
      final updatedEmployee = await _apiService.updateEmployee(id, employee);
      emit(EmployeeUpdated(updatedEmployee));
      // Refetch the list to update
      await fetchEmployees();
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }
  
  // Delete an employee
  Future<void> deleteEmployee(String id) async {
    try {
      emit(EmployeeLoading());
      await _apiService.deleteEmployee(id);
      emit(EmployeeDeleted());
      // Refetch the list to update
      await fetchEmployees();
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }
  
  // Record employee attendance
  Future<void> recordAttendance(String employeeId) async {
    try {
      emit(EmployeeLoading());
      await _apiService.recordAttendance(employeeId, DateTime.now());
      emit(EmployeeInitial());
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }
}