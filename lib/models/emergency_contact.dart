class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? relationship;
  final bool isPersonal;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relationship,
    this.isPersonal = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'relationship': relationship,
    'isPersonal': isPersonal,
  };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
    id: json['id'],
    name: json['name'],
    phoneNumber: json['phoneNumber'],
    relationship: json['relationship'],
    isPersonal: json['isPersonal'] ?? false,
  );
} 