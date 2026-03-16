import 'dart:async';
import 'package:flutter/material.dart';
import 'package:summer_camp/models/child_model.dart';
import 'package:summer_camp/services/admin_dashboard_service.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final _service = AdminDashboardService();

  bool _isLoading = true;
  String? _error;

  Map<String, int> _stats = {};
  List<ChildModel> _children = [];
  List<ChildModel> _recentEntries = [];
  List<Map<String, dynamic>> _volunteers = [];

  StreamSubscription<List<ChildModel>>? _childrenSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _volunteersSubscription;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, int> get stats => _stats;
  List<ChildModel> get children => _children;
  List<ChildModel> get recentEntries => _recentEntries;
  List<Map<String, dynamic>> get volunteers => _volunteers;

  void loadDashboard() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _childrenSubscription?.cancel();
    _childrenSubscription = _service.streamAllChildren().listen(
      (childrenData) {
        _children = childrenData;
        _updateDerivedData();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );

    _volunteersSubscription?.cancel();
    _volunteersSubscription = _service.streamAllVolunteers().listen(
      (volunteersData) {
        _volunteers = volunteersData;
        _updateDerivedData();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _updateDerivedData() {
    // We need both streams to have emitted at least once to hide loading state, 
    // but we can compute with what we have anyway.
    _isLoading = false;

    // Calc Stats
    final totalChildren = _children.length;
    final totalVolunteers = _volunteers.length;
    final enteredChildren = _children.where((c) => c.entryStatus == true).length;
    final remainingChildren = totalChildren - enteredChildren;

    _stats = {
      'totalRegistrations': totalChildren + totalVolunteers,
      'totalChildren': totalChildren,
      'totalVolunteers': totalVolunteers,
      'entriesCompleted': enteredChildren,
      'remaining': remainingChildren,
    };

    // Calc Recent Entries (Top 10 children with entryStatus == true)
    final enteredList = _children.where((c) => c.entryStatus == true).toList();
    // Sort descending by entryTime.
    // If entryTime is null, fallback to createdAt or just sort them to the end
    enteredList.sort((a, b) {
      if (a.entryTime != null && b.entryTime != null) {
        return b.entryTime!.compareTo(a.entryTime!);
      }
      if (a.entryTime != null) return -1;
      if (b.entryTime != null) return 1;
      
      return b.createdAt.compareTo(a.createdAt);
    });
    
    _recentEntries = enteredList.take(10).toList();

    notifyListeners();
  }

  @override
  void dispose() {
    _childrenSubscription?.cancel();
    _volunteersSubscription?.cancel();
    super.dispose();
  }
}
