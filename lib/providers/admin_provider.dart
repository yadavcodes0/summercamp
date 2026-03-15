import 'package:flutter/material.dart';
import 'package:summer_camp/services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final _service = AdminService();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  AdminProvider() {
    _isLoggedIn = _service.isLoggedIn;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _service.login(email, password);
    _isLoggedIn = success;
    if (!success) {
      _error = 'Invalid credentials. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _service.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
