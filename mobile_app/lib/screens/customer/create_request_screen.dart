import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../theme/app_theme.dart';
import 'request_tracking_screen.dart';

class CreateRequestScreen extends StatefulWidget {
  final ServiceModel service;

  const CreateRequestScreen({super.key, required this.service});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController(text: 'Kinondoni, Dar es Salaam, Tanzania');
  String _urgency = 'normal';
  bool _isSubmitting = false;

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RequestTrackingScreen(
              serviceName: widget.service.name,
              urgency: _urgency,
              problemDescription: _descriptionController.text,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text('Request ${widget.service.name}'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Service Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primaryBlue,
                        child: Icon(Icons.build_rounded, color: AppColors.pureWhite),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.service.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.pitchBlack,
                              ),
                            ),
                            Text(
                              'Base Estimate: TZS ${widget.service.basePrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.darkBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Urgency Level Selection
                const Text(
                  'Select Urgency:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.pitchBlack),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _UrgencyChip(
                      label: 'Normal',
                      value: 'normal',
                      groupValue: _urgency,
                      activeColor: AppColors.primaryBlue,
                      onChanged: (val) => setState(() => _urgency = val),
                    ),
                    const SizedBox(width: 8),
                    _UrgencyChip(
                      label: 'Urgent',
                      value: 'urgent',
                      groupValue: _urgency,
                      activeColor: AppColors.darkYellow,
                      onChanged: (val) => setState(() => _urgency = val),
                    ),
                    const SizedBox(width: 8),
                    _UrgencyChip(
                      label: '🚨 Emergency',
                      value: 'emergency',
                      groupValue: _urgency,
                      activeColor: Colors.redAccent,
                      onChanged: (val) => setState(() => _urgency = val),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Problem Description Input
                const Text(
                  'Describe Problem / Requirement:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.pitchBlack),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'e.g. Main circuit breaker keeps tripping when turning on AC...',
                    filled: true,
                    fillColor: AppColors.pureWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderWhite),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter a brief description' : null,
                ),
                const SizedBox(height: 20),

                // 3. Google Maps Location Section
                const Text(
                  'Service GPS Location:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.pitchBlack),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.primaryBlue),
                    filled: true,
                    fillColor: AppColors.pureWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Google Map Embedded Location Card
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4), width: 1.5),
                    color: AppColors.lightBlue,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            color: const Color(0xFFE5E3DF), // Map background color
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.map_rounded, size: 48, color: AppColors.primaryBlue),
                                const SizedBox(height: 6),
                                const Text(
                                  'Dar es Salaam, Tanzania',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.pitchBlack),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'https://www.google.com/maps?q=Dar%20es%20Salaam%2C%20Tanzania&output=embed',
                                  style: TextStyle(fontSize: 10, color: AppColors.darkBlue.withOpacity(0.8)),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.pin_drop, size: 14, color: AppColors.pitchBlack),
                                SizedBox(width: 4),
                                Text(
                                  'GPS Set: Dar es Salaam',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.pitchBlack),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _urgency == 'emergency' ? AppColors.primaryYellow : AppColors.primaryBlue,
                    foregroundColor: _urgency == 'emergency' ? AppColors.pitchBlack : AppColors.pureWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: AppColors.pureWhite)
                      : Text(
                          _urgency == 'emergency' ? '🚨 REQUEST EMERGENCY PROVIDER' : 'FIND NEAREST PROVIDER',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
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

class _UrgencyChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final Color activeColor;
  final ValueChanged<String> onChanged;

  const _UrgencyChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: activeColor,
      backgroundColor: AppColors.pureWhite,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.pureWhite : AppColors.pitchBlack,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) => onChanged(value),
    );
  }
}
