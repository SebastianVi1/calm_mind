import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a patient in the professional module
/// Contains patient information and professional notes
class ProfessionalPatientModel {
  /// Unique identifier for the patient
  final String id;
  
  /// Patient's user ID from the main system
  final String userId;
  
  /// Patient's name
  final String name;
  
  /// Patient's email
  final String? email;
  
  /// Patient's phone number
  final String? phone;
  
  /// Professional notes about the patient
  final String? professionalNotes;
  
  /// Date when patient was added to professional care
  final DateTime addedDate;
  
  /// Last consultation date
  final DateTime? lastConsultation;
  
  /// Patient's status (active, inactive, discharged)
  final PatientStatus status;
  
  /// Professional who is managing this patient
  final String professionalId;
  
  /// Patient's age
  final int? age;
  
  /// Patient's gender
  final String? gender;
  
  /// Emergency contact information
  final String? emergencyContact;
  
  /// Medical history notes
  final String? medicalHistory;

  const ProfessionalPatientModel({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    this.professionalNotes,
    required this.addedDate,
    this.lastConsultation,
    this.status = PatientStatus.active,
    required this.professionalId,
    this.age,
    this.gender,
    this.emergencyContact,
    this.medicalHistory,
  });

  /// Creates a copy of this model with updated values
  ProfessionalPatientModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? professionalNotes,
    DateTime? addedDate,
    DateTime? lastConsultation,
    PatientStatus? status,
    String? professionalId,
    int? age,
    String? gender,
    String? emergencyContact,
    String? medicalHistory,
  }) {
    return ProfessionalPatientModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      professionalNotes: professionalNotes ?? this.professionalNotes,
      addedDate: addedDate ?? this.addedDate,
      lastConsultation: lastConsultation ?? this.lastConsultation,
      status: status ?? this.status,
      professionalId: professionalId ?? this.professionalId,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalHistory: medicalHistory ?? this.medicalHistory,
    );
  }

  /// Converts the model to a Map for Firebase storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'professionalNotes': professionalNotes,
      'addedDate': Timestamp.fromDate(addedDate),
      'lastConsultation': lastConsultation != null ? Timestamp.fromDate(lastConsultation!) : null,
      'status': status.name,
      'professionalId': professionalId,
      'age': age,
      'gender': gender,
      'emergencyContact': emergencyContact,
      'medicalHistory': medicalHistory,
    };
  }

  /// Creates the model from a Map (e.g., from Firebase)
  factory ProfessionalPatientModel.fromMap(Map<String, dynamic> map) {
    return ProfessionalPatientModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      professionalNotes: map['professionalNotes'],
      addedDate: (map['addedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastConsultation: (map['lastConsultation'] as Timestamp?)?.toDate(),
      status: PatientStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PatientStatus.active,
      ),
      professionalId: map['professionalId'] ?? '',
      age: map['age'],
      gender: map['gender'],
      emergencyContact: map['emergencyContact'],
      medicalHistory: map['medicalHistory'],
    );
  }

  /// Converts the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'professionalNotes': professionalNotes,
      'addedDate': addedDate.toIso8601String(),
      'lastConsultation': lastConsultation?.toIso8601String(),
      'status': status.name,
      'professionalId': professionalId,
      'age': age,
      'gender': gender,
      'emergencyContact': emergencyContact,
      'medicalHistory': medicalHistory,
    };
  }

  /// Creates the model from JSON
  factory ProfessionalPatientModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalPatientModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      professionalNotes: json['professionalNotes'],
      addedDate: DateTime.parse(json['addedDate'] ?? DateTime.now().toIso8601String()),
      lastConsultation: json['lastConsultation'] != null 
          ? DateTime.parse(json['lastConsultation'])
          : null,
      status: PatientStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PatientStatus.active,
      ),
      professionalId: json['professionalId'] ?? '',
      age: json['age'],
      gender: json['gender'],
      emergencyContact: json['emergencyContact'],
      medicalHistory: json['medicalHistory'],
    );
  }

  @override
  String toString() {
    return 'ProfessionalPatientModel(id: $id, name: $name, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfessionalPatientModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum for patient status
enum PatientStatus {
  active('Activo'),
  inactive('Inactivo'),
  discharged('Dado de alta');

  const PatientStatus(this.displayName);
  final String displayName;
}

