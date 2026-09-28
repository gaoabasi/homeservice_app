import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  bool _isOnline = true;
  bool _isVerified = true;
  bool _hasActiveJob = false;
  String _jobStatus = 'ACCEPTED';

  void _showIncomingOfferModal() {
    int countdown = 30;
    Timer? timer;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (countdown > 0) {
                setModalState(() => countdown--);
              } else {
                t.cancel();
                Navigator.pop(context); // Timeout dismiss
              }
            });

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('⚡ NEW REQUEST OFFER', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.pitchBlack)),
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.pitchBlack,
                        child: Text('$countdown', style: const TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Electrical Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.pitchBlack)),
                  const SizedBox(height: 6),
                  const Text('Approximate Area: Kinondoni (0.8 KM away)', style: TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('Problem: Circuit breaker tripping continuously.', style: TextStyle(color: AppColors.mutedBlack)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            timer?.cancel();
                            Navigator.pop(context);
                          },
                          child: const Text('REJECT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            timer?.cancel();
                            Navigator.pop(context);
                            setState(() {
                              _hasActiveJob = true;
                              _jobStatus = 'ACCEPTED';
                            });
                          },
                          child: const Text('ACCEPT JOB', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Provider Console'),
        backgroundColor: AppColors.pitchBlack,
        actions: [
          Row(
            children: [
              Text(_isOnline ? 'ONLINE' : 'OFFLINE', style: TextStyle(fontWeight: FontWeight.bold, color: _isOnline ? AppColors.primaryYellow : Colors.grey)),
              Switch(
                value: _isOnline,
                activeColor: AppColors.primaryYellow,
                onChanged: (val) {
                  setState(() => _isOnline = val);
                },
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Verification Status Card
              Card(
                color: _isVerified ? AppColors.lightBlue : AppColors.lightYellow,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _isVerified ? Icons.verified_user_rounded : Icons.pending_rounded,
                        color: _isVerified ? AppColors.primaryBlue : AppColors.darkYellow,
                        size: 36,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isVerified ? 'VERIFIED PROVIDER' : 'VERIFICATION PENDING',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.pitchBlack),
                            ),
                            const Text('Service: Electrical Services', style: TextStyle(fontSize: 13, color: AppColors.mutedBlack)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Earnings Summary Card
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: const [
                            Text('TODAY EARNINGS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedBlack)),
                            SizedBox(height: 6),
                            Text('TZS 70,000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.darkBlue)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: const [
                            Text('COMPLETED JOBS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedBlack)),
                            SizedBox(height: 6),
                            Text('42 Jobs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.pitchBlack)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (!_hasActiveJob) ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.flash_on, color: AppColors.pitchBlack),
                  label: const Text('SIMULATE INCOMING JOB DISPATCH', style: TextStyle(color: AppColors.pitchBlack)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _showIncomingOfferModal,
                ),
                const Spacer(),
                const Center(
                  child: Text(
                    'You are Online and ready to receive nearby jobs.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ] else ...[
                const Text('ACTIVE ACCEPTED JOB:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Customer: Juma Jux (+255712345678)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text('Exact Location: Kinondoni Plot 45, Street 2', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text('Current Status: $_jobStatus', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.pitchBlack)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                                onPressed: () => setState(() => _jobStatus = 'PROVIDER ON THE WAY'),
                                child: const Text('ON THE WAY', style: TextStyle(fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkBlue),
                                onPressed: () => setState(() => _jobStatus = 'ARRIVED'),
                                child: const Text('ARRIVED', style: TextStyle(fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow, foregroundColor: AppColors.pitchBlack),
                                onPressed: () => setState(() => _jobStatus = 'IN PROGRESS'),
                                child: const Text('IN PROGRESS', style: TextStyle(fontSize: 11)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          onPressed: () {
                            setState(() {
                              _hasActiveJob = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Job marked completed! Earnings updated.')),
                            );
                          },
                          child: const Text('COMPLETE SERVICE & COLLECT PAYMENT', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
