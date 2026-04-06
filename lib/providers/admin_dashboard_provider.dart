import 'dart:async';

import 'package:flutter/material.dart';
import 'package:summer_camp/models/child_model.dart';
import 'package:summer_camp/services/admin_dashboard_service.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final _service = AdminDashboardService();

  bool _isLoading = false;
  bool _isLive = false;
  String? _error;

  Map<String, int> _stats = {};
  List<ChildModel> _children = [];
  List<ChildModel> _recentEntries = [];
  List<Map<String, dynamic>> _volunteers = [];

  StreamSubscription<List<ChildModel>>? _childrenSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _volunteersSubscription;

  bool get isLoading => _isLoading;
  bool get isLive => _isLive;
  String? get error => _error;
  Map<String, int> get stats => _stats;
  List<ChildModel> get children => _children;
  List<ChildModel> get recentEntries => _recentEntries;
  List<Map<String, dynamic>> get volunteers => _volunteers;

  void loadDashboard() {
    _isLoading = true;
    _error = null;
    _isLive = true;
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

  void stopLive() {
    _childrenSubscription?.cancel();
    _volunteersSubscription?.cancel();
    _isLive = false;
    _isLoading = false;
    notifyListeners();
  }

  List<ChildModel> _enteredChildren = [];
  Map<String, int> _branchWiseEntries = {};

  List<ChildModel> get enteredChildren => _enteredChildren;
  Map<String, int> get branchWiseEntries => _branchWiseEntries;

  void _updateDerivedData() {
    _isLoading = false;

    // ── All-Time Stats ──
    final totalChildren = _children.length;
    final totalVolunteers = _volunteers.length;

    // ── Entered Children (all who have entry) ──
    final entered = _children
        .where((c) => c.entryStatus == true)
        .toList();
    final remainingChildren = totalChildren - entered.length;

    // ── Branch-wise entries ──
    final branchMap = <String, int>{};
    for (final c in entered) {
      final branch = c.branchName ?? 'Unknown';
      branchMap[branch] = (branchMap[branch] ?? 0) + 1;
    }
    _branchWiseEntries = branchMap;

    _stats = {
      'totalRegistrations': totalChildren,
      'totalChildren': totalChildren,
      'totalVolunteers': totalVolunteers,
      'entriesCompleted': entered.length,
      'remaining': remainingChildren,
    };

    // ── Entered Children list (sorted descending by entry time) ──
    entered.sort((a, b) {
      if (a.entryTime != null && b.entryTime != null) {
        return b.entryTime!.compareTo(a.entryTime!);
      }
      if (a.entryTime != null) return -1;
      if (b.entryTime != null) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    _enteredChildren = entered;

    // ── Recent Entries (top 10) ──
    _recentEntries = entered.take(10).toList();

    notifyListeners();
  }

  @override
  void dispose() {
    _childrenSubscription?.cancel();
    _volunteersSubscription?.cancel();
    super.dispose();
  }
}
