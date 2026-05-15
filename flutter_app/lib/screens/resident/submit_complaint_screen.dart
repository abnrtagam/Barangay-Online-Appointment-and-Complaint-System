import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/complaint_provider.dart';
import '../../models/auth_response_model.dart';
import '../../widgets/loading_overlay.dart';
import '../../constants/app_colors.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _subjectController = TextEditingController();
  final _detailsController = TextEditingController();
  ComplaintCategory? _selectedCategory;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<ComplaintProvider>().fetchCategories();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  void _handleSubmit() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (_subjectController.text.isEmpty || _detailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    final result = await context.read<ComplaintProvider>().submitComplaint(
      categoryId: _selectedCategory!.id,
      subject: _subjectController.text,
      details: _detailsController.text,
      attachmentPath: _selectedImage?.path,
    );

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to submit'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintProvider>(
      builder: (context, provider, _) {
        return LoadingOverlay(
          isLoading: provider.isSubmitting,
          message: 'SUBMITTING REPORT...',
          child: Scaffold(
            backgroundColor: AppColors.gray50,
            appBar: AppBar(
              title: const Text('SUBMIT COMPLAINT'),
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
                          'Report an Incident',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.white, fontFamily: 'Plus Jakarta Sans'),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Help us keep Barangay Bulua safe and clean. Please provide accurate details below.',
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
                          _inputLabel('COMPLAINT CATEGORY'),
                          InkWell(
                            onTap: () => _showCategoryPicker(context, provider.categories),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.gray50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getCategoryIcon(_selectedCategory?.name ?? ''), 
                                    size: 20, 
                                    color: AppColors.primary600
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedCategory?.name ?? 'Select category',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: _selectedCategory == null ? FontWeight.w500 : FontWeight.w700,
                                        color: _selectedCategory == null ? AppColors.gray400 : AppColors.primary900,
                                        fontFamily: 'DM Sans',
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gray400),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _inputLabel('SUBJECT / TITLE'),
                          TextField(
                            controller: _subjectController,
                            decoration: InputDecoration(
                              hintText: 'e.g. Noise complaint...',
                              prefixIcon: const Icon(Icons.title_rounded, size: 20, color: AppColors.primary600),
                              filled: true,
                              fillColor: AppColors.gray50,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _inputLabel('INCIDENT DETAILS'),
                          TextField(
                            controller: _detailsController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Describe what happened...',
                              alignLabelWithHint: true,
                              filled: true,
                              fillColor: AppColors.gray50,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 24),

                          _inputLabel('ATTACH PROOF / PHOTO (OPTIONAL)'),
                          const SizedBox(height: 8),
                          if (_selectedImage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.primary200),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.image_outlined, size: 20, color: AppColors.primary700),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(_selectedImage!.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary800), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.danger),
                                      onPressed: () => setState(() => _selectedImage = null),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                            label: const Text('SELECT INCIDENT PHOTO'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              side: const BorderSide(color: AppColors.primary400, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              foregroundColor: AppColors.primary700,
                              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          ElevatedButton(
                            onPressed: provider.isSubmitting ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: AppColors.primary600,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                            ),
                            child: const Text('SUBMIT OFFICIAL REPORT', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
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
                                        'Your report will be reviewed by officials. You will be notified of updates.',
                                        style: TextStyle(fontSize: 13, color: AppColors.primary700, height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Guidelines
                          _infoCard(
                            title: 'SUBMISSION GUIDELINES',
                            icon: Icons.lightbulb_outline_rounded,
                            children: [
                              _infoBulletItem('Provide accurate dates and times.'),
                              _infoBulletItem('Mention specific locations.'),
                              _infoBulletItem('Attach clear photos as evidence.'),
                              _infoBulletItem('State facts clearly and objectively.'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Privacy Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.gray100),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.privacy_tip_outlined, color: AppColors.warningText, size: 20),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('DATA PRIVACY', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary900)),
                                      SizedBox(height: 2),
                                      Text('Your information is kept confidential.', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

  IconData _getCategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'flooding': return Icons.water_drop_outlined;
      case 'garbage / sanitation': return Icons.delete_outline_rounded;
      case 'noise complaint': return Icons.volume_up_outlined;
      case 'illegal construction': return Icons.construction_rounded;
      case 'animal nuisance': return Icons.pets_rounded;
      case 'domestic dispute': return Icons.family_restroom_rounded;
      case 'public safety': return Icons.security_rounded;
      case 'street / road issues': return Icons.add_road_rounded;
      case 'business / vendor issue': return Icons.storefront_rounded;
      default: return Icons.category_outlined;
    }
  }

  void _showCategoryPicker(BuildContext context, List<ComplaintCategory> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('SELECT CATEGORY', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AppColors.gray500)),
            const SizedBox(height: 10),
            const Divider(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory?.id == cat.id;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
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
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.white : AppColors.gray50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getCategoryIcon(cat.name), 
                              size: 20, 
                              color: isSelected ? AppColors.primary600 : AppColors.gray600
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? AppColors.primary900 : AppColors.gray700,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: AppColors.primary600, size: 20),
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

  Widget _infoBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin: const EdgeInsets.only(top: 6), width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary400, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.gray600, height: 1.4))),
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
