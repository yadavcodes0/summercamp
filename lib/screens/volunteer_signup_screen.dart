import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/volunteer_provider.dart';
import 'package:summer_camp/services/auth_service.dart';

class VolunteerSignupScreen extends StatefulWidget {
  const VolunteerSignupScreen({super.key});

  @override
  State<VolunteerSignupScreen> createState() => _VolunteerSignupScreenState();
}

class _VolunteerSignupScreenState extends State<VolunteerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  // New field
  String _gender = 'Male';

  // OTP State
  bool _isSendingOtp = false;
  bool _isOtpSent = false;
  bool _isPhoneVerified = false;
  String? _verificationId;
  AuthService? _authService;

  @override
  void initState() {
    super.initState();
    _otpCtrl.addListener(_onOtpChanged);
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _ageCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _onOtpChanged() {
    if (_otpCtrl.text.trim().length == 6 && !_isPhoneVerified) {
      _verifyOtp();
    }
  }

  bool _isPhoneValid() {
    final phone = _phoneCtrl.text.trim();
    return phone.length >= 10;
  }

  Future<void> _sendOtp() async {
    // 1. Validate other fields first
    if (!_formKey.currentState!.validate()) return;
    
    if (!_isPhoneValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid 10-digit phone number first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final phoneNum = _phoneCtrl.text.trim();
    final fullPhone = phoneNum.startsWith('+') ? phoneNum : '+91$phoneNum';

    setState(() => _isSendingOtp = true);

    _authService = AuthService();
    await _authService!.sendOTP(
      phoneNumber: fullPhone,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() {
          _isSendingOtp = false;
          _isOtpSent = true;
          _verificationId = verificationId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully! ✅'),
            backgroundColor: Color(0xFF43A047),
          ),
        );
      },
      onError: (errorMessage) {
        if (!mounted) return;
        setState(() => _isSendingOtp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_authService == null || _verificationId == null) return;

    try {
      await _authService!.verifyOTP(
        verificationId: _verificationId!,
        smsCode: _otpCtrl.text.trim(),
      );

      if (!mounted) return;
      
      setState(() => _isPhoneVerified = true);
      
      // Auto-submit form since everything is ready and verified
      _submit();
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_isPhoneVerified) return;

    final provider = context.read<VolunteerProvider>();
    final success = await provider.registerVolunteer(
      fullName: _fullNameCtrl.text.trim(),
      age: int.parse(_ageCtrl.text.trim()),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      gender: _gender,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! You can now log in.'),
          backgroundColor: Color(0xFF43A047),
        ),
      );
      Navigator.pop(context); // Go back to login screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Registration failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<VolunteerProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Signup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text('🤝', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Join our team! Fill in your details to register as a camp volunteer. Note that password will be generated automatically.',
                        style: GoogleFonts.splineSans(
                          fontSize: 13,
                          color: const Color(0xFF555555),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              _SectionLabel('Personal Information'),
              const SizedBox(height: 12),

              _AppTextField(
                controller: _fullNameCtrl,
                label: 'Full Name',
                hint: 'e.g. Rahul Sharma',
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _AppTextField(
                      controller: _ageCtrl,
                      label: 'Age',
                      hint: 'e.g. 25',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 16) {
                          return 'Must be 16+';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: _AppTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'e.g. rahul@email.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              _SectionLabel('Gender'),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'Male',
                      label: Text('Male'),
                      icon: Icon(Icons.male),
                    ),
                    ButtonSegment(
                      value: 'Female',
                      label: Text('Female'),
                      icon: Icon(Icons.female),
                    ),
                  ],
                  selected: {_gender},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _gender = newSelection.first;
                    });
                  },
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: const Color(0xFF43A047),
                    selectedForegroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE8F5E9)),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              _AppTextField(
                controller: _addressCtrl,
                label: 'Residential Address',
                hint: 'e.g. Block A, Rohini, Delhi',
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 24),
              _SectionLabel('Phone Verification'),
              const SizedBox(height: 12),

              // ── Phone Number with Verify Button ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      enabled: !_isPhoneVerified,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'e.g. 9876543210',
                        prefixIcon: const Icon(Icons.phone_outlined,
                            color: Color(0xFF43A047), size: 20),
                        suffixIcon: _isPhoneVerified
                            ? const Icon(Icons.check_circle,
                                color: Color(0xFF43A047), size: 24)
                            : null,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (v.trim().length < 10) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                      onChanged: (_) {
                        if (_isOtpSent || _isPhoneVerified) {
                          setState(() {
                            _isOtpSent = false;
                            _isPhoneVerified = false;
                            _otpCtrl.clear();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _isPhoneVerified
                        ? Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF43A047).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Verified ✅',
                                style: GoogleFonts.splineSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF43A047),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSendingOtp ? null : _sendOtp,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: const Color(0xFF43A047),
                              ),
                              child: _isSendingOtp
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _isOtpSent ? 'Resend' : 'Verify',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                            ),
                          ),
                  ),
                ],
              ),

              // ── OTP Input Field (shown after OTP is sent) ──
              if (_isOtpSent && !_isPhoneVerified) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Enter 6-digit OTP',
                    hintText: '123456',
                    counterText: '',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF43A047), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF43A047), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF43A047), width: 2),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: (isLoading || !_isPhoneVerified) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPhoneVerified
                      ? const Color(0xFF43A047)
                      : Colors.grey.shade400,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Sign Up'),
              ),

              if (!_isPhoneVerified)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Verify your phone number first',
                    style: GoogleFonts.splineSans(
                      fontSize: 12,
                      color: const Color(0xFF888888),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.splineSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF333333),
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _AppTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF43A047), size: 20),
      ),
    );
  }
}
