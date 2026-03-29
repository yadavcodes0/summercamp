import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/language_provider.dart';
import 'package:summer_camp/providers/volunteer_provider.dart';
import 'package:summer_camp/screens/admin_dashboard_screen.dart';
import 'package:summer_camp/screens/volunteer_signup_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _anim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() { _anim.dispose(); _phoneCtrl.dispose(); _passwordCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<VolunteerProvider>();
    final success = await provider.login(_phoneCtrl.text.trim(), _passwordCtrl.text.trim());
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? context.read<LanguageProvider>().t('login_failed')), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<VolunteerProvider>().isLoading;
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(lang.t('vol_login')), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context))),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Stack(alignment: Alignment.center, children: [
                  Container(width: 110, height: 110, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF43A047).withOpacity(0.1), width: 2))),
                  Container(width: 90, height: 90, decoration: BoxDecoration(gradient: RadialGradient(colors: [const Color(0xFF43A047).withOpacity(0.15), const Color(0xFF43A047).withOpacity(0.05)]), shape: BoxShape.circle), child: const Center(child: Text('🔐', style: TextStyle(fontSize: 40)))),
                ])),
                const SizedBox(height: 24),
                Center(child: Text(lang.t('vol_login'), style: GoogleFonts.splineSans(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)))),
                const SizedBox(height: 8),
                Center(child: Text(lang.t('vol_login_desc'), style: GoogleFonts.splineSans(fontSize: 13, color: const Color(0xFF888888), height: 1.5), textAlign: TextAlign.center)),
                const SizedBox(height: 36),
                TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: lang.t('phone'), hintText: lang.t('phone_hint'), prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF43A047))), validator: (v) { if (v == null || v.trim().isEmpty) return lang.t('required'); if (v.trim().length < 10) return lang.t('valid_phone'); return null; }),
                const SizedBox(height: 14),
                TextFormField(controller: _passwordCtrl, obscureText: _obscurePassword, decoration: InputDecoration(labelText: lang.t('workshop_password'), hintText: '••••••••', prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF43A047)), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF888888)), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))), validator: (v) => v == null || v.trim().isEmpty ? lang.t('required') : null),
                const SizedBox(height: 32),
                Container(width: double.infinity, height: 54, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF66BB6A)]), boxShadow: [BoxShadow(color: const Color(0xFF43A047).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))]),
                  child: ElevatedButton(onPressed: isLoading ? null : _login, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: isLoading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : Text(lang.t('login'), style: GoogleFonts.splineSans(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)))),
                const SizedBox(height: 24),
                Center(child: TextButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const VolunteerSignupScreen())); }, child: RichText(text: TextSpan(text: '${lang.t('no_account')} ', style: GoogleFonts.splineSans(color: const Color(0xFF888888), fontSize: 14), children: [TextSpan(text: lang.t('vol_signup'), style: GoogleFonts.splineSans(color: const Color(0xFF43A047), fontWeight: FontWeight.w600))])))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
