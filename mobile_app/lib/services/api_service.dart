import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Use localhost for Web/Desktop, 10.0.2.2 for Android emulator
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  String? _authToken;

  // In-memory application state for seamless offline/demo operation
  Map<String, dynamic> _currentUser = {
    'name': 'Juma Jux',
    'email': 'customer@homehelp.co.tz',
    'phone': '+255 712 345 678',
    'default_address': 'Kinondoni, Dar es Salaam',
    'role': 'customer',
    'provider_status': null, // null, 'pending', 'verified', 'rejected'
  };

  final List<Map<String, dynamic>> _inMemoryPendingProviders = [
    {
      'id': 1,
      'name': 'Fundi Daudi',
      'email': 'daudi@homehelp.co.tz',
      'phone': '+255 754 111 222',
      'service': 'AC Repair',
      'national_id': '19940505-12345-00003-30',
      'experience_years': 4,
      'bio': 'Experienced HVAC technician specializing in home and commercial AC units.',
      'documents': ['National_ID.pdf', 'VETA_Certificate.pdf'],
      'verification_status': 'pending',
    },
    {
      'id': 2,
      'name': 'Fundi Aisha',
      'email': 'aisha@homehelp.co.tz',
      'phone': '+255 789 333 444',
      'service': 'Cleaning Services',
      'national_id': '19980808-67890-00004-40',
      'experience_years': 3,
      'bio': 'Professional home deep cleaning specialist.',
      'documents': ['National_ID.pdf'],
      'verification_status': 'pending',
    },
  ];

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Map<String, dynamic> get currentUser => Map.unmodifiable(_currentUser);

  Future<List<ServiceModel>> fetchServices() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/services'), headers: _headers)
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['services'];
        return list.map((item) => ServiceModel.fromJson(item)).toList();
      }
    } catch (_) {}

    return [
      ServiceModel(id: 1, name: 'Electrical Services', slug: 'electrical', description: 'Wiring, socket & fixture repairs', iconName: 'flash_on', basePrice: 35000),
      ServiceModel(id: 2, name: 'Plumbing', slug: 'plumbing', description: 'Pipe leaks, taps & drainage', iconName: 'water_drop', basePrice: 30000),
      ServiceModel(id: 3, name: 'Cleaning Services', slug: 'cleaning', description: 'Home deep cleaning & sofa wash', iconName: 'cleaning_services', basePrice: 25000),
      ServiceModel(id: 4, name: 'Carpentry', slug: 'carpenter', description: 'Furniture & woodwork fixing', iconName: 'build', basePrice: 40000),
      ServiceModel(id: 5, name: 'Painting', slug: 'painting', description: 'Wall painting & touchups', iconName: 'format_paint', basePrice: 50000),
      ServiceModel(id: 6, name: 'AC Repair', slug: 'ac-repair', description: 'AC servicing & gas refilling', iconName: 'ac_unit', basePrice: 45000),
      ServiceModel(id: 7, name: 'Pest Control', slug: 'pest-control', description: 'Fumigation for termites & insects', iconName: 'bug_report', basePrice: 60000),
      ServiceModel(id: 8, name: 'Car Wash at Home', slug: 'car-wash', description: 'Doorstep mobile car pressure wash', iconName: 'directions_car', basePrice: 15000),
    ];
  }

  Future<Map<String, dynamic>> fetchCurrentUser() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/auth/me'), headers: _headers)
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];
        _currentUser['name'] = userData['name'] ?? _currentUser['name'];
        _currentUser['email'] = userData['email'] ?? _currentUser['email'];
        _currentUser['phone'] = userData['phone'] ?? _currentUser['phone'];
        if (userData['customer'] != null) {
          _currentUser['default_address'] = userData['customer']['default_address'] ?? _currentUser['default_address'];
        }
        if (userData['service_provider'] != null) {
          _currentUser['provider_status'] = userData['service_provider']['verification_status'];
        }
      }
    } catch (_) {}

    return _currentUser;
  }

  Future<bool> applyProvider({
    required String nationalId,
    required String bio,
    required int experienceYears,
    required List<int> serviceIds,
    List<String> selectedServiceNames = const [],
    String? documentName,
  }) async {
    _currentUser['provider_status'] = 'pending';

    // Attempt backend API call
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/customer/apply-provider'),
            headers: _headers,
            body: jsonEncode({
              'national_id': nationalId,
              'bio': bio,
              'experience_years': experienceYears,
              'service_ids': serviceIds,
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
    } catch (_) {}

    // Fallback sync for local state & admin queue
    final newApp = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': _currentUser['name'],
      'email': _currentUser['email'],
      'phone': _currentUser['phone'],
      'service': selectedServiceNames.isNotEmpty ? selectedServiceNames.join(', ') : 'Home Services',
      'national_id': nationalId,
      'experience_years': experienceYears,
      'bio': bio,
      'documents': [if (documentName != null) documentName else 'National_ID.pdf'],
      'verification_status': 'pending',
    };

    _inMemoryPendingProviders.removeWhere((p) => p['name'] == _currentUser['name']);
    _inMemoryPendingProviders.add(newApp);
    return true;
  }

  Future<List<Map<String, dynamic>>> fetchPendingProviders() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/admin/providers/pending'), headers: _headers)
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['pending_providers'] ?? [];
        return list.map<Map<String, dynamic>>((item) {
          final user = item['user'] ?? {};
          final servicesList = (item['services'] as List?)?.map((s) => s['name']).join(', ') ?? 'Services';
          final docsList = (item['documents'] as List?)?.map((d) => d['document_type'] ?? 'Document').cast<String>().toList() ?? ['National_ID.pdf'];
          return {
            'id': item['id'],
            'name': user['name'] ?? 'Provider Candidate',
            'email': user['email'] ?? '',
            'phone': user['phone'] ?? '',
            'service': servicesList,
            'national_id': item['national_id'] ?? 'N/A',
            'experience_years': item['experience_years'] ?? 0,
            'bio': item['bio'] ?? '',
            'documents': docsList.isEmpty ? ['National_ID.pdf'] : docsList,
            'verification_status': item['verification_status'] ?? 'pending',
          };
        }).toList();
      }
    } catch (_) {}

    return _inMemoryPendingProviders;
  }

  Future<bool> verifyProvider(int providerId, String status) async {
    // Update local queue state
    final index = _inMemoryPendingProviders.indexWhere((p) => p['id'] == providerId);
    if (index != -1) {
      if (status == 'verified' || status == 'rejected') {
        _inMemoryPendingProviders.removeAt(index);
      } else {
        _inMemoryPendingProviders[index]['verification_status'] = status;
      }
    }

    if (_currentUser['provider_status'] != null) {
      _currentUser['provider_status'] = status;
      if (status == 'verified') {
        _currentUser['role'] = 'provider';
      }
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/admin/providers/$providerId/verify'),
            headers: _headers,
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (_) {}

    return true;
  }

  Future<void> logout() async {
    try {
      await http
          .post(Uri.parse('$baseUrl/auth/logout'), headers: _headers)
          .timeout(const Duration(seconds: 3));
    } catch (_) {}

    _authToken = null;
    _currentUser['provider_status'] = null;
    _currentUser['role'] = 'customer';
  }
}
