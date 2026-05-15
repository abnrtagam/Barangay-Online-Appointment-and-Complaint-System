class ApiConstants {
  // ============================================================
  // Backend API Base URL
  // ============================================================
  // IMPORTANT: Change this based on how you're testing:
  //
  // 1. Android Emulator:  'http://10.0.2.2:5000/api'
  //    (10.0.2.2 is the emulator's alias for your PC's localhost)
  //
  // 2. Physical Phone (USB or WiFi):  'http://YOUR_PC_IP:5000/api'
  //    Find your IP: open CMD → type 'ipconfig' → look for IPv4 Address
  //    Example: 'http://192.168.1.100:5000/api'
  //
  // 3. Chrome/Web testing:  'http://localhost:5000/api'
  //
  // Make sure your phone and PC are on the same WiFi network.
  // ============================================================
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Authentication Endpoints
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String resendOtp = '$baseUrl/auth/resend-otp';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword = '$baseUrl/auth/reset-password';

  // Resident Endpoints
  static const String dashboardStats = '$baseUrl/residents/dashboard-stats';
  static const String complaints = '$baseUrl/residents/complaints';
  static const String appointments = '$baseUrl/residents/appointments';
  static const String complaintSubmit = '$baseUrl/complaints';
  static const String appointmentBook = '$baseUrl/appointments';
  static const String appointmentSlots = '$baseUrl/appointments/taken-slots';
  static const String complaintCategories = '$baseUrl/complaints/categories';

  // Announcements
  static const String announcements = '$baseUrl/announcements';

  // Health Check
  static const String health = '$baseUrl/health';

  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
