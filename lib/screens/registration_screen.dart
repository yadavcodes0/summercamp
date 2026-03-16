import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/child_provider.dart';
import 'package:summer_camp/screens/registration_success_screen.dart';
import 'package:summer_camp/services/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _childNameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _parentNameCtrl = TextEditingController();
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
    _childNameCtrl.dispose();
    _ageCtrl.dispose();
    _parentNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  /// Auto-verify when 6 digits entered
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number verified! ✅'),
          backgroundColor: Color(0xFF43A047),
        ),
      );
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
    if (!_formKey.currentState!.validate()) return;

    if (!_isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your phone number first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = context.read<ChildProvider>();
    final success = await provider.registerChild(
      childName: _childNameCtrl.text.trim(),
      age: int.parse(_ageCtrl.text.trim()),
      parentName: _parentNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      gender: _gender,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RegistrationSuccessScreen(),
        ),
      );
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
    final isLoading =
        context.watch<ChildProvider>().state == ChildProviderState.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Child'),
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
                  color: const Color(0xFFf97b06).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text('📝', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Fill in your child\'s details to get a unique QR code for camp entry.',
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

              _SectionLabel('Child Information'),
              const SizedBox(height: 12),

              _AppTextField(
                controller: _childNameCtrl,
                label: 'Child\'s Full Name',
                hint: 'e.g. Rahul Sharma',
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              _AppTextField(
                controller: _ageCtrl,
                label: 'Age',
                hint: 'e.g. 10',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 1 || n > 18) {
                    return 'Enter a valid age (1–18)';
                  }
                  return null;
                },
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
                    selectedBackgroundColor: const Color(0xFFf97b06),
                    selectedForegroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFEEE6DF)),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _SectionLabel('Parent / Guardian'),
              const SizedBox(height: 12),

              _AppTextField(
                controller: _parentNameCtrl,
                label: 'Parent\'s Name',
                hint: 'e.g. Amit Kumar',
                icon: Icons.supervisor_account_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

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
                            color: Color(0xFFf97b06), size: 20),
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
                        // Reset OTP state if phone number changes
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
                        color: Color(0xFFf97b06), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFf97b06), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFf97b06), width: 2),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 14),

              _AppTextField(
                controller: _addressCtrl,
                label: 'Address',
                hint: 'e.g. Delhi',
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: (isLoading || !_isPhoneVerified) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPhoneVerified
                      ? const Color(0xFFf97b06)
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
                    : const Text('Register Child'),
              ),

              if (!_isPhoneVerified)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Verify your phone number to enable registration',
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
        prefixIcon: Icon(icon, color: const Color(0xFFf97b06), size: 20),
      ),
    );
  }
}
