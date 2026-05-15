import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/loading_overlay.dart';
import 'package:intl/intl.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _purposeController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedSlot;

  final List<String> _timeSlots = [
    '8:00 AM - 9:00 AM',
    '9:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '1:00 PM - 2:00 PM',
    '2:00 PM - 3:00 PM',
    '3:00 PM - 4:00 PM',
    '4:00 PM - 5:00 PM',
  ];

  @override
  void dispose() {
    _purposeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null; // Reset slot when date changes
      });
      // Fetch taken slots for this date
      final dateStr = DateFormat('yyyy-MM-dd').format(picked);
      if (mounted) {
        context.read<AppointmentProvider>().fetchTakenSlots(dateStr);
      }
    }
  }

  void _handleBook() async {
    if (_selectedDate == null || _selectedSlot == null || _purposeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in date, time slot, and purpose')),
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final result = await context.read<AppointmentProvider>().bookAppointment(
      appointmentDate: dateStr,
      timeSlot: _selectedSlot!,
      purpose: _purposeController.text,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully!'), backgroundColor: Color(0xFF10B981)),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to book')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, _) {
        return LoadingOverlay(
          isLoading: provider.isSubmitting,
          message: 'Booking appointment...',
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: AppBar(
              title: const Text('Book Appointment'),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2D3748),
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Schedule an Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D3748))),
                    const SizedBox(height: 4),
                    Text('Select a date and time slot for your visit.', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                    const SizedBox(height: 24),

                    // Date picker
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          Icon(Icons.calendar_today_rounded, color: Colors.grey[500], size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null ? DateFormat('MMMM d, y (EEEE)').format(_selectedDate!) : 'Select Date',
                            style: TextStyle(fontSize: 14, color: _selectedDate != null ? const Color(0xFF2D3748) : Colors.grey[400]),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time slots
                    if (_selectedDate != null) ...[
                      const Text('Available Time Slots', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D3748))),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _timeSlots.map((slot) {
                          final isTaken = provider.takenSlots.contains(slot);
                          final isSelected = _selectedSlot == slot;
                          return ChoiceChip(
                            label: Text(slot, style: TextStyle(fontSize: 12, color: isTaken ? Colors.grey[400] : (isSelected ? Colors.white : const Color(0xFF2D3748)))),
                            selected: isSelected,
                            onSelected: isTaken ? null : (sel) => setState(() => _selectedSlot = sel ? slot : null),
                            selectedColor: const Color(0xFF8B5CF6),
                            disabledColor: Colors.grey[100],
                            backgroundColor: Colors.grey[50],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Purpose
                    TextField(
                      controller: _purposeController,
                      decoration: InputDecoration(
                        labelText: 'Purpose',
                        prefixIcon: const Icon(Icons.assignment_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Additional Notes (optional)',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: provider.isSubmitting ? null : _handleBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Book Appointment', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
