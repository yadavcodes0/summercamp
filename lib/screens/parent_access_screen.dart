import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:summer_camp/screens/otp_verification_screen.dart';
import 'package:summer_camp/services/auth_service.dart';

class ParentAccessScreen extends StatefulWidget {
  const ParentAccessScreen({super.key});

  @override
  State<ParentAccessScreen> createState() => _ParentAccessScreenState();
}

class _ParentAccessScreenState extends State<ParentAccessScreen> {
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSendingOtp = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    if (!_formKey.currentState!.validate()) return;
    
    final phoneNum = _phoneCtrl.text.trim();
    final fullPhone = phoneNum.startsWith('+') ? phoneNum : '+91$phoneNum';
    
    setState(() => _isSendingOtp = true);
    debugPrint('📱 OTP: Starting verification for $fullPhone');
    
    final authService = AuthService();
    await authService.sendOTP(
      phoneNumber: fullPhone,
      onCodeSent: (verificationId) {
        debugPrint('✅ OTP: Code sent successfully!');
        if (!mounted) return;
        setState(() => _isSendingOtp = false);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              verificationId: verificationId,
              phoneNumber: fullPhone,
              authService: authService,
            ),
          ),
        );
      },
      onError: (errorMessage) {
        debugPrint('❌ OTP: Error: $errorMessage');
        if (!mounted) return;
        setState(() => _isSendingOtp = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP Error: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Child\'s QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFf97b06).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🔍', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Find Your Registration',
                style: GoogleFonts.splineSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the phone number you used when registering your child.',
                style: GoogleFonts.splineSans(
                  fontSize: 14,
                  color: const Color(0xFF888888),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g. 9876543210',
                  prefixIcon:
                      Icon(Icons.phone_outlined, color: Color(0xFFf97b06)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim().length < 10) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _isSendingOtp ? null : _find,
                child: _isSendingOtp
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
