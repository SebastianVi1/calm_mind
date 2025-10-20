import 'package:uuid/uuid.dart';

class Appointment {
  final String id;
  final String patientName;
  final String patientPhone;
  final DateTime dateTime;
  final String notes;
  final bool isDone;

  Appointment({
    String? id,
    required this.patientName,
    required this.patientPhone,
    required this.dateTime,
    this.notes = '',
    this.isDone = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientName': patientName,
    'patientPhone': patientPhone,
    'dateTime': dateTime.toIso8601String(),
    'notes': notes,
    'isDone': isDone,
  };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'] as String,
    patientName: json['patientName'] as String,
    patientPhone: json['patientPhone'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    notes: json['notes'] as String,
    isDone: json['isDone'] as bool,
  );
}
