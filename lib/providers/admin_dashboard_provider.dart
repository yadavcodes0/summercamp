import 'package:flutter/material.dart';
import 'package:summer_camp/models/child_model.dart';
import 'package:summer_camp/services/admin_dashboard_service.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final _service = AdminDashboardService();

  bool _isLoading = false;
  String? _error;

  Map<String, int> _stats = {};
  List<ChildModel> _children = [];
  List<ChildModel> _recentEntries = [];
  List<Map<String, dynamic>> _volunteers = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, int> get stats => _stats;
  List<ChildModel> get children => _children;
  List<ChildModel> get recentEntries => _recentEntries;
  List<Map<String, dynamic>> get volunteers => _volunteers;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getDashboardStats(),
        _service.getRecentEntries(),
        _service.getAllChildren(),
        _service.getAllVolunteers(),
      ]);

      _stats = results[0] as Map<String, int>;
      _recentEntries = results[1] as List<ChildModel>;
      _children = results[2] as List<ChildModel>;
      _volunteers = results[3] as List<Map<String, dynamic>>;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
