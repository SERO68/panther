import 'package:equatable/equatable.dart';

class EmployeeAttendance extends Equatable {
  final int? id;
  final int? employeeId;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String? status;
  // Add other relevant fields based on your API response

  const EmployeeAttendance({
    this.id,
    this.employeeId,
    this.checkIn,
    this.checkOut,
    this.status,
  });

  factory EmployeeAttendance.fromJson(Map<String, dynamic> json) {
    return EmployeeAttendance(
      id: json['id'],
      employeeId: json['employeeId'],
      checkIn: json['checkIn'] != null ? DateTime.parse(json['checkIn']) : null,
      checkOut: json['checkOut'] != null ? DateTime.parse(json['checkOut']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'status': status,
    };
  }

  @override
  List<Object?> get props => [id, employeeId, checkIn, checkOut, status];
}