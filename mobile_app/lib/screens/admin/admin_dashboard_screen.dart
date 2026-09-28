import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _pendingProviders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingProviders();
  }

  Future<void> _loadPendingProviders() async {
    setState(() {
      _isLoading = true;
    });
    final providers = await _apiService.fetchPendingProviders();
    if (mounted) {
      setState(() {
        _pendingProviders = providers;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVerify(int providerId, String name, String status) async {
    final actionName = status == 'verified' ? 'verified' : 'rejected';
    final success = await _apiService.verifyProvider(providerId, status);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Provider "$name" has been $actionName successfully!')),
        );
      }
      _loadPendingProviders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('HOMEHELP Admin Dashboard'),
        backgroundColor: AppColors.pitchBlack,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryYellow),
            onPressed: _loadPendingProviders,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Analytics KPI Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  const _KpiCard(title: 'TOTAL CUSTOMERS', value: '1,240', color: AppColors.primaryBlue),
                  const _KpiCard(title: 'TOTAL PROVIDERS', value: '380', color: AppColors.pitchBlack),
                  _KpiCard(title: 'VERIFIED PROVIDERS', value: '342', color: Colors.green),
                  _KpiCard(title: 'PENDING INSPECTION', value: '${_pendingProviders.length}', color: Colors.orange),
                ],
              ),
              const SizedBox(height: 24),

              // Pending Provider Verifications Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pending Verifications Queue:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.pitchBlack),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_pendingProviders.length} Pending',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.pitchBlack),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _isLoading
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: AppColors.pitchBlack),
                    ))
                  : _pendingProviders.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
                                  SizedBox(height: 8),
                                  Text(
                                    'No pending provider applications for inspection.',
                                    style: TextStyle(color: AppColors.mutedBlack, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _pendingProviders.length,
                          itemBuilder: (context, index) {
                            final provider = _pendingProviders[index];
                            final providerId = provider['id'];
                            final name = provider['name'] ?? 'Candidate';
                            final email = provider['email'] ?? '';
                            final phone = provider['phone'] ?? '';
                            final service = provider['service'] ?? 'Home Services';
                            final nationalId = provider['national_id'] ?? 'N/A';
                            final expYears = provider['experience_years'] ?? 0;
                            final bio = provider['bio'] ?? '';
                            final docs = (provider['documents'] as List?)?.cast<String>() ?? [];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: AppColors.borderWhite),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: AppColors.pitchBlack,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'PENDING INSPECTION',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Services: $service',
                                      style: const TextStyle(
                                        color: AppColors.darkBlue,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'NIDA: $nationalId • Experience: $expYears Year(s)',
                                      style: const TextStyle(color: AppColors.mutedBlack, fontSize: 13),
                                    ),
                                    if (email.isNotEmpty || phone.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Contact: $email $phone',
                                        style: const TextStyle(color: AppColors.mutedBlack, fontSize: 12),
                                      ),
                                    ],
                                    if (bio.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.offWhite,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Bio: "$bio"',
                                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.charBlack),
                                        ),
                                      ),
                                    ],
                                    if (docs.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      const Text('Submitted Inspection Documents:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        children: docs
                                            .map((doc) => Chip(
                                                  avatar: const Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
                                                  label: Text(doc, style: const TextStyle(fontSize: 11)),
                                                  backgroundColor: AppColors.pureWhite,
                                                  side: const BorderSide(color: AppColors.borderWhite),
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                    const SizedBox(height: 14),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            side: const BorderSide(color: Colors.red),
                                          ),
                                          onPressed: () => _handleVerify(providerId, name, 'rejected'),
                                          child: const Text('REJECT'),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                          label: const Text('VERIFY PROVIDER'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primaryBlue,
                                          ),
                                          onPressed: () => _handleVerify(providerId, name, 'verified'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _KpiCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.mutedBlack),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
