class UserDetail {
  final int id;
  final String firebaseId;
  final String name;
  final String lastname;
  final String contactNumber;
  final String emergencyContactNumber;
  final String gender;
  final String email;
  final String roleName;
  UserDetail({
    required this.id,
    required this.firebaseId,
    required this.name,
    required this.lastname,
    required this.contactNumber,
    required this.emergencyContactNumber,
    required this.gender,
    required this.email,
    required this.roleName,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
    id:json['id'],
    firebaseId: json['firebase_uid'] ?? '',           // 👈 era 'firebaseId'
    name: json['name'] ?? '',
    lastname: json['last_name'] ?? '',                // 👈 era 'lastname'
    contactNumber: json['contact_number'] ?? '',      // 👈 era 'contactNumber'
    emergencyContactNumber: json['emergency_contact_number'] ?? '', // 👈 corregido
    gender: json['gender'] ?? '',
    email: json['email'] ?? '',
    roleName: json['role_name'] ?? '', 
    );
    }
}