import 'package:flutter/material.dart';
import 'package:summer_camp/services/volunteer_service.dart';

class VolunteerProvider extends ChangeNotifier {
  final _service = VolunteerService();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? get volunteerPhone => _service.volunteerPhone;
  String? get volunteerName => _service.volunteerName;

  late Future<void> initializationDone;

  VolunteerProvider() {
    initializationDone = _init();
  }

  Future<void> _init() async {
    await _service.init();
    _isLoggedIn = _service.isLoggedIn;
    notifyListeners();
  }

  Future<bool> registerVolunteer({
    required String fullName,
    required int age,
    required String email,
    required String phone,
    required String address,
    required String gender,
    required String branchName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _service.registerVolunteer(
      fullName: fullName,
      age: age,
      email: email,
      phone: phone,
      address: address,
      gender: gender,
      branchName: branchName,
    );

    if (!success) {
      _error = 'Registration failed. Phone number might already be in use.';
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _service.login(phone, password);
    _isLoggedIn = success;
    if (!success) {
      _error = 'Invalid phone number or password.';
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
