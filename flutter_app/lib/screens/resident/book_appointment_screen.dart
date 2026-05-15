import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../constants/app_colors.dart';
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary600,
              onPrimary: Colors.white,
              onSurface: AppColors.primary900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (picked.weekday == DateTime.saturday || picked.weekday == DateTime.sunday) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointments are only available on weekdays.')));
        return;
      }
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null;
      });
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
          const SnackBar(content: Text('Appointment booked successfully!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to book'), backgroundColor: AppColors.danger),
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
          message: 'PROCESSING BOOKING...',
          child: Scaffold(
            backgroundColor: AppColors.gray50,
            appBar: AppBar(
              title: const Text('BOOK APPOINTMENT'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('VISIT SCHEDULE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.gray500, letterSpacing: 1.2, fontFamily: 'Plus Jakarta Sans')),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.gray200, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _inputLabel('SELECT DATE'),
                        InkWell(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.gray300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(children: [
                              const Icon(Icons.calendar_month_rounded, color: AppColors.primary600, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate != null ? DateFormat('MMMM d, y (EEEE)').format(_selectedDate!) : 'Select a weekday',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _selectedDate != null ? AppColors.primary900 : AppColors.gray400),
                              ),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (_selectedDate != null) ...[
                          _inputLabel('AVAILABLE TIME SLOTS'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _timeSlots.map((slot) {
                              final isTaken = provider.takenSlots.contains(slot);
                              final isSelected = _selectedSlot == slot;
                              return ChoiceChip(
                                label: Text(slot, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isTaken ? AppColors.gray400 : (isSelected ? Colors.white : AppColors.primary900))),
                                selected: isSelected,
                                onSelected: isTaken ? null : (sel) => setState(() => _selectedSlot = sel ? slot : null),
                                selectedColor: AppColors.primary600,
                                backgroundColor: AppColors.gray50,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? AppColors.primary600 : AppColors.gray200)),
                                showCheckmark: false,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        _inputLabel('PURPOSE OF VISIT'),
                        TextField(
                          controller: _purposeController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Requesting Clearance, Certification',
                            prefixIcon: Icon(Icons.assignment_outlined, size: 20),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _inputLabel('ADDITIONAL NOTES (OPTIONAL)'),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Any other details the admin should know...',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: provider.isSubmitting ? null : _handleBook,
                    child: const Text('CONFIRM APPOINTMENT'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _inputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gray700, letterSpacing: 1)),
    );
  }
}
