import 'user_model.dart';

// AuthResponse model represents the response from login/register
class AuthResponse {
  final String? token;
  final User? user;
  final String? message;
  final bool? requiresOtp;
  final String? email;

  AuthResponse({
    this.token,
    this.user,
    this.message,
    this.requiresOtp,
    this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: json['message'],
      requiresOtp: json['requiresOTP'] ?? json['requiresOtp'],
      email: json['email'],
    );
  }
}

// Category model for complaint categories
class ComplaintCategory {
  final int id;
  final String name;
  final String? description;

  ComplaintCategory({
    required this.id,
    required this.name,
    this.description,
  });

  factory ComplaintCategory.fromJson(Map<String, dynamic> json) {
    return ComplaintCategory(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}
