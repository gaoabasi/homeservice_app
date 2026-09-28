import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'customer/customer_home_screen.dart';
import 'provider/provider_dashboard_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // App Brand Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home_repair_service_rounded,
                    size: 48,
                    color: AppColors.primaryYellow,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'HOMEHELP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.pitchBlack,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Home Service & Assistance Platform',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mutedBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Role to Proceed:',
                style: TextStyle(
                  color: AppColors.charBlack,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // 1. Customer Button Card
              _RoleCard(
                title: 'CUSTOMER',
                subtitle: 'Request nearby verified services',
                icon: Icons.person_pin_circle_rounded,
                accentColor: AppColors.primaryBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              // 2. Service Provider Button Card
              _RoleCard(
                title: 'SERVICE PROVIDER',
                subtitle: 'Accept jobs & serve customers',
                icon: Icons.handyman_rounded,
                accentColor: AppColors.primaryYellow,
                textColor: AppColors.pitchBlack,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProviderDashboardScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              // 3. Admin Dashboard Button Card
              _RoleCard(
                title: 'ADMIN PORTAL',
                subtitle: 'Manage verification & analytics',
                icon: Icons.admin_panel_settings_rounded,
                accentColor: AppColors.pitchBlack,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Powered by Location-Based Matching Engine',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accentColor.withOpacity(0.4), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor == AppColors.primaryYellow ? AppColors.pitchBlack : accentColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.pitchBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.mutedBlack,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.mutedBlack, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
