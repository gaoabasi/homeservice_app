import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class BecomeProviderScreen extends StatefulWidget {
  const BecomeProviderScreen({super.key});

  @override
  State<BecomeProviderScreen> createState() => _BecomeProviderScreenState();
}

class _BecomeProviderScreenState extends State<BecomeProviderScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nidaController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController(text: '3');

  List<ServiceModel> _availableServices = [];
  final Set<int> _selectedServiceIds = {};
  final Set<String> _selectedServiceNames = {};

  bool _isLoadingServices = true;
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _attachedDocument = 'National_ID.pdf';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final services = await _apiService.fetchServices();
    setState(() {
      _availableServices = services;
      _isLoadingServices = false;
      // Pre-select first 2 services by default if available
      if (services.isNotEmpty) {
        _selectedServiceIds.add(services.first.id);
        _selectedServiceNames.add(services.first.name);
        if (services.length > 1) {
          _selectedServiceIds.add(services[1].id);
          _selectedServiceNames.add(services[1].name);
        }
      }
    });
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one service you can provide.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final expYears = int.tryParse(_experienceController.text.trim()) ?? 1;

    final success = await _apiService.applyProvider(
      nationalId: _nidaController.text.trim(),
      bio: _bioController.text.trim(),
      experienceYears: expYears,
      serviceIds: _selectedServiceIds.toList(),
      selectedServiceNames: _selectedServiceNames.toList(),
      documentName: _attachedDocument,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSubmitted = success;
      });
    }
  }

  @override
  void dispose() {
    _nidaController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Become a Service Provider'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: _isSubmitted
              ? Card(
                  color: AppColors.lightYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.darkYellow, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primaryYellow,
                          child: Icon(Icons.verified_user_rounded, color: AppColors.pitchBlack, size: 42),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'APPLICATION SUBMITTED!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.pitchBlack,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Your request to become a Service Provider has been submitted to the Admin for verification and inspection.\n\nOnce reviewed and approved by the Admin, your account profile will be activated!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.mutedBlack, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: const Text('BACK TO MY PROFILE'),
                        ),
                      ],
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: const [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryYellow,
                              child: Icon(Icons.handyman_rounded, color: AppColors.pitchBlack),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Join as a Service Provider',
                                    style: TextStyle(
                                      color: AppColors.pureWhite,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Submit your credentials for Admin inspection',
                                    style: TextStyle(
                                      color: AppColors.lightBlue,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 1. Select Services Offered
                      const Text(
                        'Select Services You Can Provide:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.pitchBlack),
                      ),
                      const SizedBox(height: 8),
                      _isLoadingServices
                          ? const Center(child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(color: AppColors.primaryBlue),
                            ))
                          : Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: _availableServices.map((service) {
                                final isSelected = _selectedServiceIds.contains(service.id);
                                return FilterChip(
                                  selected: isSelected,
                                  label: Text(service.name),
                                  selectedColor: AppColors.primaryYellow,
                                  checkmarkColor: AppColors.pitchBlack,
                                  labelStyle: TextStyle(
                                    color: isSelected ? AppColors.pitchBlack : AppColors.charBlack,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedServiceIds.add(service.id);
                                        _selectedServiceNames.add(service.name);
                                      } else {
                                        _selectedServiceIds.remove(service.id);
                                        _selectedServiceNames.remove(service.name);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                      const SizedBox(height: 18),

                      // 2. National ID (NIDA)
                      const Text(
                        'National ID Number (NIDA):',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.pitchBlack),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nidaController,
                        decoration: InputDecoration(
                          hintText: 'e.g. 19920101-12345-00001-10',
                          filled: true,
                          fillColor: AppColors.pureWhite,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your NIDA number' : null,
                      ),
                      const SizedBox(height: 16),

                      // 3. Experience Years
                      const Text(
                        'Experience (Years):',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.pitchBlack),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _experienceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.pureWhite,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter years of experience' : null,
                      ),
                      const SizedBox(height: 16),

                      // 4. Bio / Skills Summary
                      const Text(
                        'Bio / Skill Description:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.pitchBlack),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Describe your skills, qualifications & experience...',
                          filled: true,
                          fillColor: AppColors.pureWhite,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a brief skill description' : null,
                      ),
                      const SizedBox(height: 16),

                      // 5. Verification Document Upload Simulation
                      const Text(
                        'Verification Document (ID / Certificate):',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.pitchBlack),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.cloud_upload_rounded, color: AppColors.primaryBlue),
                        label: Text(
                          _attachedDocument != null ? 'ATTACHED: $_attachedDocument' : 'ATTACH NATIONAL ID / VETA CERTIFICATE (PDF/JPG)',
                          style: TextStyle(
                            color: _attachedDocument != null ? AppColors.darkBlue : AppColors.primaryBlue,
                            fontWeight: _attachedDocument != null ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          side: const BorderSide(color: AppColors.primaryBlue),
                        ),
                        onPressed: () {
                          setState(() {
                            _attachedDocument = 'National_ID_VETA_Cert.pdf';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Document National_ID_VETA_Cert.pdf attached successfully!')),
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: AppColors.pitchBlack,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _isSubmitting ? null : _submitApplication,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.pitchBlack),
                              )
                            : const Text(
                                'SUBMIT TO ADMIN FOR INSPECTION',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                              ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
