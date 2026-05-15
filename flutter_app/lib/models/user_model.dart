// User model represents a user from the database
// When the backend sends: {"id": 1, "first_name": "John", ...}
// We convert it to: User(id: 1, firstName: "John", ...)

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String role; // 'resident' or 'admin'
  final String status; // 'pending', 'approved', 'rejected', 'suspended'
  final bool emailVerified;
  final int? residentId; // Only for residents

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.status,
    required this.emailVerified,
    this.residentId,
  });

  // Create a User from JSON (what the backend sends)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? 'resident',
      status: json['status'] ?? 'pending',
      emailVerified: json['email_verified'] ?? false,
      residentId: json['resident_id'],
    );
  }

  // Convert User to JSON (for sending to backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'status': status,
      'email_verified': emailVerified,
      'resident_id': residentId,
    };
  }

  // Get full name
  String get fullName => '$firstName $lastName';
}
