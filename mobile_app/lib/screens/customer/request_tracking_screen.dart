import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RequestTrackingScreen extends StatefulWidget {
  final String serviceName;
  final String urgency;
  final String problemDescription;

  const RequestTrackingScreen({
    super.key,
    required this.serviceName,
    required this.urgency,
    required this.problemDescription,
  });

  @override
  State<RequestTrackingScreen> createState() => _RequestTrackingScreenState();
}

class _RequestTrackingScreenState extends State<RequestTrackingScreen> {
  int _currentStepIndex = 1; // 0: Pending, 1: Matching, 2: Accepted, 3: On The Way, 4: In Progress, 5: Completed

  final List<String> _statuses = [
    'PENDING',
    'MATCHING NEAREST FUNDI',
    'ACCEPTED BY PROVIDER',
    'PROVIDER ON THE WAY',
    'SERVICE IN PROGRESS',
    'COMPLETED'
  ];

  @override
  void initState() {
    super.initState();
    _simulateStatusUpdates();
  }

  void _simulateStatusUpdates() {
    // Demo progression through request lifecycle
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _currentStepIndex = 2);
    });
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) setState(() => _currentStepIndex = 3);
    });
    Future.delayed(const Duration(seconds: 9), () {
      if (mounted) setState(() => _currentStepIndex = 4);
    });
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted) setState(() => _currentStepIndex = 5);
    });
  }

  void _showRatingModal() {
    int rating = 5;
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Rate Service Provider', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How satisfied were you with Fundi Hassan?'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(
                      i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColors.primaryYellow,
                      size: 36,
                    ),
                    onPressed: () => setModalState(() => rating = i + 1),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentCtrl,
                decoration: const InputDecoration(
                  hintText: 'Leave a comment...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.pureWhite,
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you! Review submitted successfully.')),
                );
                Navigator.pop(context); // Return home
              },
              child: const Text('SUBMIT REVIEW'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Track Service Request'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Urgent alert banner if emergency
              if (widget.urgency == 'emergency')
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.pitchBlack),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'EMERGENCY DISPATCH ACTIVE: High Priority Matching',
                          style: TextStyle(color: AppColors.pitchBlack, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Status Banner
              Card(
                color: AppColors.primaryBlue,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(Icons.radar_rounded, color: AppColors.primaryYellow, size: 48),
                      const SizedBox(height: 10),
                      Text(
                        _statuses[_currentStepIndex],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Service: ${widget.serviceName}',
                        style: const TextStyle(color: AppColors.lightBlue, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Provider Assigned Card (Unlocked after Acceptance)
              if (_currentStepIndex >= 2) ...[
                const Text('Assigned Provider:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryYellow,
                      child: Icon(Icons.person, color: AppColors.pitchBlack),
                    ),
                    title: const Text('Fundi Hassan (Verified Electrician)', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('⭐ 4.9 (42 jobs) • 0.8 KM away'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.phone, color: AppColors.primaryBlue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble, color: AppColors.primaryBlue),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Lifecycle Step Timeline
              Expanded(
                child: ListView.builder(
                  itemCount: _statuses.length,
                  itemBuilder: (context, index) {
                    final bool isDone = index <= _currentStepIndex;
                    final bool isCurrent = index == _currentStepIndex;

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: isDone ? AppColors.primaryBlue : Colors.grey.shade300,
                        child: Icon(
                          isDone ? Icons.check : Icons.circle,
                          size: 14,
                          color: AppColors.pureWhite,
                        ),
                      ),
                      title: Text(
                        _statuses[index],
                        style: TextStyle(
                          color: isCurrent ? AppColors.darkBlue : (isDone ? AppColors.pitchBlack : Colors.grey),
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (_currentStepIndex == 5)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.pitchBlack,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _showRatingModal,
                  child: const Text('RATE PROVIDER & COMPLETE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
