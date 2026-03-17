import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VolunteerService {
  final _client = Supabase.instance.client;
  static const String _keyIsLoggedIn = 'volunteer_is_logged_in';
  static const String _keyVolunteerPhone = 'volunteer_phone';
  static const String _keyVolunteerName = 'volunteer_name';

  bool _isLoggedIn = false;
  String? _volunteerPhone;
  String? _volunteerName;

  bool get isLoggedIn => _isLoggedIn;
  String? get volunteerPhone => _volunteerPhone;
  String? get volunteerName => _volunteerName;

  /// Call this when the app starts to load saved login state
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    _volunteerPhone = prefs.getString(_keyVolunteerPhone);
    _volunteerName = prefs.getString(_keyVolunteerName);
  }

  Future<bool> registerVolunteer({
    required String fullName,
    required int age,
    required String email,
    required String phone,
    required String address,
    required String gender,
  }) async {
    try {
      // 1. Check if phone is already registered
      final existing = await _client
          .from('volunteers')
          .select('id')
          .eq('phone_number', phone)
          .maybeSingle();

      if (existing != null) {
        throw Exception('Phone number is already registered.');
      }

      // 2. Insert new volunteer
      await _client.from('volunteers').insert({
        'full_name': fullName,
        'age': age,
        'email_address': email,
        'phone_number': phone,
        'address': address,
        'gender': gender,
      });
      return true;
    } catch (e) {
      // Return false but could also throw to let Provider handle custom error message
      return false;
    }
  }

  Future<bool> login(String phone, String password) async {
    // Check common password
    if (password != 'Camp@2026') {
      return false;
    }

    try {
      // Verify phone number exists in volunteers table
      final volunteer = await _client
          .from('volunteers')
          .select('id, phone_number, full_name')
          .eq('phone_number', phone)
          .maybeSingle();

      if (volunteer != null) {
        // Successful login
        final name = volunteer['full_name'] as String?;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyVolunteerPhone, phone);
        if (name != null) await prefs.setString(_keyVolunteerName, name);
        
        _isLoggedIn = true;
        _volunteerPhone = phone;
        _volunteerName = name;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyVolunteerPhone);
    await prefs.remove(_keyVolunteerName);
    _isLoggedIn = false;
    _volunteerPhone = null;
    _volunteerName = null;
  }
}
