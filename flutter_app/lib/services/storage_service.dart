import 'package:shared_preferences/shared_preferences.dart';

// This service handles storing and retrieving data from the phone's local storage
// Think of it like a small database on the phone where we save things like JWT tokens

class StorageService {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';
  static const String _roleKey = 'user_role';

  // Save JWT token to local storage
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Retrieve JWT token from local storage
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Check if token exists (user is logged in)
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Save user info (like name, email, id)
  static Future<void> saveUserInfo(String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userJson);
  }

  // Get user info
  static Future<String?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  // Save user role (resident or admin)
  static Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  // Get user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // Clear all stored data (used when logging out)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Save the timestamp when notifications were last viewed
  static Future<void> saveLastViewedNotification(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_viewed_notification', timestamp);
  }

  // Get the last viewed notification timestamp
  static Future<String?> getLastViewedNotification() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_viewed_notification');
  }
}
