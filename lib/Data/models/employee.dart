import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final String? id;
  final String name;
  final double pricePerHour;

  const Employee({
    this.id,
    required this.name,
    required this.pricePerHour,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pricePerHour': pricePerHour,
    };
  }

  @override
  List<Object?> get props => [id, name, pricePerHour];
}