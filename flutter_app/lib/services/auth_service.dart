import '../models/auth_response_model.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../constants/api_constants.dart';
import 'dart:convert';

// AuthService handles all authentication operations
// It's like the manager of the restaurant who handles all the paperwork

class AuthService {
  // Register a new user
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String dob,
    required String zone,
    required String govIdType,
    required String govIdNumber,
    required String password,
    required List<String> documentPaths,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConstants.register,
        {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'address': address,
          'dob': dob,
          'zone': zone,
          'gov_id_type': govIdType,
          'gov_id_number': govIdNumber,
          'password': password,
          if (documentPaths.isNotEmpty) 'documents': documentPaths,
        },
        isFormData: true,
      );

      if (response['success']) {
        return {
          'success': true,
          'message': response['data']['message'] ?? 'Registration successful',
          'requiresOtp': response['data']['requiresOTP'] ?? true,
          'email': email,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Verify OTP code sent to email
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConstants.verifyOtp,
        {
          'email': email,
          'otp': otpCode,
        },
      );

      if (response['success']) {
        return {
          'success': true,
          'message': response['data']['message'] ?? 'Email verified',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'OTP verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Resend OTP code to email
  static Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConstants.resendOtp,
        {
          'email': email,
        },
      );

      if (response['success']) {
        return {
          'success': true,
          'message': response['data']['message'] ?? 'OTP sent',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Login with email and password
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConstants.login,
        {
          'email': email,
          'password': password,
        },
      );

      if (response['success']) {
        final authResponse = AuthResponse.fromJson(response['data']);

        // Save token to local storage
        if (authResponse.token != null) {
          await StorageService.saveToken(authResponse.token!);
        }

        // Save user info
        if (authResponse.user != null) {
          await StorageService.saveUserInfo(jsonEncode(authResponse.user!.toJson()));
          await StorageService.saveUserRole(authResponse.user!.role);
        }

        return {
          'success': true,
          'message': 'Login successful',
          'user': authResponse.user,
          'token': authResponse.token,
        };
      } else {
        final statusCode = response['statusCode'];
        final errorData = response['data'];

        // Handle specific error cases
        if (statusCode == 403) {
          final status = errorData['status'];
          if (status == 'pending') {
            return {
              'success': false,
              'message': 'Your account is pending verification by the barangay administrator',
              'status': 'pending',
            };
          } else if (status == 'rejected') {
            return {
              'success': false,
              'message': 'Your account has been rejected',
              'status': 'rejected',
            };
          } else if (status == 'suspended') {
            return {
              'success': false,
              'message': 'Your account has been suspended',
              'status': 'suspended',
            };
          } else if (errorData['requiresOTP'] == true) {
            return {
              'success': false,
              'message': 'Please verify your email first',
              'requiresOtp': true,
              'email': email,
            };
          }
        }

        return {
          'success': false,
          'message': response['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Start password reset process
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConstants.forgotPassword,
        {
          'email': email,
        },
      );

      if (response['success']) {
        return {
          'success': true,
          'message': response['data']['message'] ?? 'Reset code sent to email',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to process request',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Reset password with OTP/token
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConstants.resetPassword,
        {
          'email': email,
          'otp': otpCode,
          'newPassword': newPassword,
          'confirmPassword': newPassword,
        },
      );

      if (response['success']) {
        return {
          'success': true,
          'message': response['data']['message'] ?? 'Password reset successful',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Password reset failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Request account reactivation (suspended users)
  static Future<Map<String, dynamic>> requestReactivation({
    required String email,
    required String reason,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConstants.reactivate,
        {
          'email': email,
          'reason': reason,
        },
      );

      if (response['success']) {
        return {
          'success': true,
          'message': response['data']['message'] ?? 'Request submitted',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to submit request',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Logout (clear stored data)
  static Future<void> logout() async {
    await StorageService.clearAll();
  }

  // Update FCM Token for push notifications
  static Future<Map<String, dynamic>> updateFcmToken(String token) async {
    try {
      final response = await ApiService.post(
        '${ApiConstants.baseUrl}/auth/update-fcm-token',
        {'fcm_token': token},
      );
      return response;
    } catch (e) {
      print('AuthService Error updating FCM token: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
