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
  String? _selectedPurpose;

  final List<String> _purposeOptions = [
    'Complaint Follow-up',
    'Barangay Clearance',
    'Certificate Request',
    'Mediation',
    'Community Concern',
    'Appointment with Barangay Official',
    'Other'
  ];

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
    if (_selectedDate == null || _selectedSlot == null || _selectedPurpose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date, time slot, and purpose')),
      );
      return;
    }

    final finalPurpose = _selectedPurpose == 'Other' ? _purposeController.text : _selectedPurpose;
    if (finalPurpose == null || finalPurpose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify your purpose')),
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final result = await context.read<AppointmentProvider>().bookAppointment(
      appointmentDate: dateStr,
      timeSlot: _selectedSlot!,
      purpose: finalPurpose,
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

  void _showPurposePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('PURPOSE OF VISIT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AppColors.gray500)),
            const SizedBox(height: 10),
            const Divider(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _purposeOptions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final purpose = _purposeOptions[index];
                  final isSelected = _selectedPurpose == purpose;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedPurpose = purpose);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary50 : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.circle_outlined, 
                            size: 20, 
                            color: isSelected ? AppColors.primary600 : AppColors.gray300
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              purpose,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? AppColors.primary900 : AppColors.gray700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dynamic Header Banner
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary900, AppColors.primary700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Schedule a Visit',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.white, fontFamily: 'Plus Jakarta Sans'),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Book an appointment for barangay services, clearances, or consultations.',
                          style: TextStyle(fontSize: 14, color: AppColors.primary100, fontFamily: 'DM Sans', height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  // Overlapping Form Card
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _inputLabel('SELECT DATE'),
                          InkWell(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.gray50,
                                borderRadius: BorderRadius.circular(12),
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? AppColors.primary600 : Colors.transparent)),
                                  showCheckmark: false,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],

                           _inputLabel('PURPOSE OF VISIT'),
                           InkWell(
                             onTap: () => _showPurposePicker(context),
                             borderRadius: BorderRadius.circular(12),
                             child: Container(
                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                               decoration: BoxDecoration(
                                 color: AppColors.gray50,
                                 borderRadius: BorderRadius.circular(12),
                               ),
                               child: Row(
                                 children: [
                                   const Icon(Icons.assignment_outlined, size: 20, color: AppColors.primary600),
                                   const SizedBox(width: 12),
                                   Expanded(
                                     child: Text(
                                       _selectedPurpose ?? 'Select purpose',
                                       style: TextStyle(
                                         fontSize: 15,
                                         fontWeight: _selectedPurpose == null ? FontWeight.w500 : FontWeight.w700,
                                         color: _selectedPurpose == null ? AppColors.gray400 : AppColors.primary900,
                                         fontFamily: 'DM Sans',
                                       ),
                                     ),
                                   ),
                                   const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gray400),
                                 ],
                               ),
                             ),
                           ),
                           if (_selectedPurpose == 'Other') ...[
                             const SizedBox(height: 16),
                             TextField(
                               controller: _purposeController,
                               decoration: InputDecoration(
                                 hintText: 'Specify your purpose...',
                                 filled: true,
                                 fillColor: AppColors.gray50,
                                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                               ),
                             ),
                           ],
                           const SizedBox(height: 20),

                          _inputLabel('ADDITIONAL NOTES (OPTIONAL)'),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Any other details...',
                              alignLabelWithHint: true,
                              filled: true,
                              fillColor: AppColors.gray50,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          ElevatedButton(
                            onPressed: provider.isSubmitting ? null : _handleBook,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: AppColors.primary600,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                            ),
                            child: const Text('CONFIRM APPOINTMENT', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
                          ),
                          const SizedBox(height: 24),

                          // Note
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.primary700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text('NOTE:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary800, letterSpacing: 0.5)),
                                      SizedBox(height: 4),
                                      Text(
                                        'Your request will be reviewed by the staff. Check history for updates.',
                                        style: TextStyle(fontSize: 13, color: AppColors.primary700, height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Office Hours
                          _infoCard(
                            title: 'OFFICE HOURS',
                            icon: Icons.access_time_rounded,
                            children: [
                              _infoRow('Monday – Friday', '8:00 AM – 5:00 PM'),
                              _infoRow('Saturday & Sunday', 'Closed'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // What to Bring
                          _infoCard(
                            title: 'WHAT TO BRING',
                            icon: Icons.assignment_turned_in_outlined,
                            children: [
                              _infoCheckItem('Valid government ID'),
                              _infoCheckItem('Proof of residency'),
                              _infoCheckItem('Supporting documents'),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary600),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary900, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.gray600, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 13, color: AppColors.gray900, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _infoCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.gray600, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gray700, letterSpacing: 1)),
    );
  }
}
