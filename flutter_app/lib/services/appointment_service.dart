import 'api_service.dart';
import '../constants/api_constants.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  // Get all appointments for the logged-in resident
  static Future<Map<String, dynamic>> getAppointments() async {
    try {
      final response = await ApiService.get(ApiConstants.appointments);
      if (response['success']) {
        final data = response['data'];
        List<Appointment> appointments = [];

        if (data is List) {
          appointments = data.map((a) => Appointment.fromJson(a)).toList();
        } else if (data is Map && data['appointments'] != null) {
          appointments = (data['appointments'] as List)
              .map((a) => Appointment.fromJson(a))
              .toList();
        }

        return {'success': true, 'appointments': appointments};
      } else {
        return {'success': false, 'message': response['message'] ?? 'Failed to fetch appointments'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Book a new appointment
  static Future<Map<String, dynamic>> bookAppointment({
    required String appointmentDate,
    required String timeSlot,
    required String purpose,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'appointment_date': appointmentDate,
        'time_slot': timeSlot,
        'purpose': purpose,
      };

      if (notes != null && notes.isNotEmpty) {
        body['notes'] = notes;
      }

      final response = await ApiService.post(ApiConstants.appointmentBook, body);

      if (response['success']) {
        return {
          'success': true,
          'message': response['data']['message'] ?? 'Appointment booked successfully',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to book appointment',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get taken time slots for a specific date
  static Future<Map<String, dynamic>> getTakenSlots(String date) async {
    try {
      final response = await ApiService.get(
        '${ApiConstants.appointmentSlots}?date=$date',
      );

      if (response['success']) {
        final data = response['data'];
        List<String> takenSlots = [];

        if (data is List) {
          takenSlots = data.map((s) => s.toString()).toList();
        } else if (data is Map && data['taken_slots'] != null) {
          takenSlots = (data['taken_slots'] as List).map((s) => s.toString()).toList();
        }

        return {'success': true, 'takenSlots': takenSlots};
      } else {
        return {'success': false, 'message': response['message'] ?? 'Failed to fetch slots'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
