import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../role_selection_screen.dart';
import '../provider/provider_dashboard_screen.dart';
import 'become_provider_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = await _apiService.fetchCurrentUser();
    if (mounted) {
      setState(() {
        _userData = user;
        _isLoading = false;
      });
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              nav.pop(); // Close dialog
              await _apiService.logout();
              messenger.showSnackBar(
                const SnackBar(content: Text('Logged out successfully.')),
              );
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderStatusSection() {
    final providerStatus = _userData['provider_status'];

    if (providerStatus == 'pending') {
      return Card(
        color: AppColors.lightYellow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkYellow, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.primaryYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded, color: AppColors.pitchBlack, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supplier Application Pending',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.pitchBlack,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Submitted & queued for Admin approval and inspection.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (providerStatus == 'verified') {
      return Card(
        color: const Color(0xFFE8F5E9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.green, width: 1.5),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProviderDashboardScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified Service Provider',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.pitchBlack,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tap to open Provider Dashboard & manage jobs',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.green, size: 16),
              ],
            ),
          ),
        ),
      );
    }

    // Default: Customer hasn't applied yet or status is null/rejected
    return Card(
      color: AppColors.lightYellow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.primaryYellow, width: 1.5),
      ),
      child: InkWell(
        onTap: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BecomeProviderScreen()),
          );
          if (res == true || mounted) {
            _fetchProfile();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.primaryYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.handyman_rounded, color: AppColors.pitchBlack, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerStatus == 'rejected' ? 'Re-Apply to Become a Provider' : 'Become a Service Provider',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.pitchBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      providerStatus == 'rejected'
                          ? 'Previous application was rejected. Tap to update details.'
                          : 'Apply to offer services & earn money',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedBlack,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.pitchBlack, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _userData['name'] ?? 'Customer';
    final email = _userData['email'] ?? 'customer@homehelp.co.tz';
    final phone = _userData['phone'] ?? '+255 712 345 678';
    final address = _userData['default_address'] ?? 'Kinondoni, Dar es Salaam';

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('My Account Profile'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header Card displaying Customer Name & Email
                    Card(
                      color: AppColors.pureWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.borderWhite),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primaryBlue,
                              child: Icon(Icons.person, size: 50, color: AppColors.primaryYellow),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.pitchBlack,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.mutedBlack,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Phone: $phone',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.darkBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.lightBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                address,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Become Provider / Supplier Status Section
                    _buildProviderStatusSection(),

                    const SizedBox(height: 20),

                    // Logout Option Button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      label: const Text(
                        'LOGOUT OF ACCOUNT',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _handleLogout,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
