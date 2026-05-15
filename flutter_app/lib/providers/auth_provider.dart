import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'dart:convert';

// AuthProvider is like a bulletin board that remembers who's logged in
// When the user logs in, the provider updates, and all screens immediately know
// This is state management - shared state that multiple screens can access

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters - other parts of the app read these
  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Check if user is admin
  bool get isAdmin => _user?.role == 'admin';
  bool get isResident => _user?.role == 'resident';

  // Initialize provider - restore login if token exists
  Future<void> initializeAuth() async {
    // 1. Defensive Check: If already logged in (from a recent login call), stop.
    if (_isLoggedIn) return;

    print('DEBUG: initializeAuth started. Current isLoggedIn: $_isLoggedIn');
    _isLoading = true;
    notifyListeners();

    try {
      // 2. Initialize Firebase (Async and non-blocking)
      try {
        await Firebase.initializeApp();
        await NotificationService.initialize();
      } catch (fbError) {
        print("Firebase Initialization Error (Non-fatal): $fbError");
      }

      // 3. Restore Session
      final token = await StorageService.getToken();
      final userJson = await StorageService.getUserInfo();

      if (_isLoggedIn) {
        print('DEBUG: initializeAuth exiting early - user already logged in.');
        return;
      }

      if (token != null && userJson != null && token.isNotEmpty) {
        print('DEBUG: initializeAuth found saved session. Logging in...');
        final userData = jsonDecode(userJson);
        final user = User.fromJson(userData);
        
        _token = token;
        _user = user;
        _isLoggedIn = true;
        
        // Register for notifications in background
        _registerFcmToken();
      } else {
        print('DEBUG: initializeAuth found no saved session.');
      }
    } catch (e) {
      print('Auth Initialization Error: $e');
      // If error occurs, only clear if we aren't already logged in
      if (!_isLoggedIn) {
        _token = null;
        _user = null;
        _isLoggedIn = false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    print('DEBUG: login started for $email');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.login(
        email: email,
        password: password,
      );

      if (result['success'] && result['user'] != null && result['token'] != null) {
        _user = result['user'];
        _token = result['token'];
        _isLoggedIn = true;
        _isLoading = false;
        
        // PERSIST SESSION
        await StorageService.saveToken(_token!);
        await StorageService.saveUserInfo(jsonEncode(_user!.toJson()));
        
        print('DEBUG: login success for ${_user?.email}. isLoggedIn: $_isLoggedIn');
        notifyListeners();
        
        // Register for notifications
        _registerFcmToken();
        
        return result;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        _isLoggedIn = false;
        _isLoading = false;
        notifyListeners();
        return result;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoggedIn = false;
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Register method
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String password,
    required List<String> documentPaths,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        address: address,
        password: password,
        documentPaths: documentPaths,
      );

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Registration error: $e',
      };
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({required String email, required String otpCode}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.verifyOtp(
        email: email,
        otpCode: otpCode,
      );

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.resendOtp(email: email);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Request password reset OTP
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.forgotPassword(email: email);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Reset password with OTP
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.resetPassword(
        email: email,
        otpCode: otpCode,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Request reactivation
  Future<Map<String, dynamic>> requestReactivation({required String email, required String reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.requestReactivation(email: email, reason: reason);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.logout();
      _user = null;
      _token = null;
      _isLoggedIn = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error logging out: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register FCM Token with backend
  Future<void> _registerFcmToken() async {
    if (!_isLoggedIn || _token == null) return;
    
    try {
      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null) {
        print('Registering FCM Token: $fcmToken');
        await AuthService.updateFcmToken(fcmToken);
      }
    } catch (e) {
      print('Failed to register FCM token: $e');
      // We don't fail the login if notification registration fails
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
