import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/language_provider.dart';
import 'package:summer_camp/providers/volunteer_provider.dart';

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
  // New field
  String _gender = 'Male';
  String? _branchName;

  final List<String> _branches = [
    'Inderlok',
    'Tri Nagar',
    'Ashok Vihar',
    'Lawrence Road',
    'Nehru Nagar',
    'Azad Colony',
  ];

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _ageCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<VolunteerProvider>();
    final success = await provider.registerVolunteer(
      fullName: _fullNameCtrl.text.trim(),
      age: int.parse(_ageCtrl.text.trim()),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      gender: _gender,
      branchName: _branchName ?? '',
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<LanguageProvider>().t('reg_success')),
          backgroundColor: const Color(0xFF43A047),
        ),
      );
      Navigator.pop(context); // Go back to login screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ?? context.read<LanguageProvider>().t('reg_failed'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<VolunteerProvider>().isLoading;
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('volunteer_signup')),
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
                        lang.t('volunteer_header'),
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

              _SectionLabel(lang.t('personal_info')),
              const SizedBox(height: 12),

              _AppTextField(
                controller: _fullNameCtrl,
                label: lang.t('full_name'),
                hint: lang.t('full_name_hint'),
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? lang.t('required') : null,
              ),
              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _AppTextField(
                      controller: _ageCtrl,
                      label: lang.t('age'),
                      hint: lang.t('age_hint'),
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return lang.t('required');
                        }
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 16) {
                          return lang.t('age_16');
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
                      label: lang.t('email'),
                      hint: lang.t('email_hint'),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return lang.t('required');
                        }
                        if (!v.contains('@')) return lang.t('invalid_email');
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              _SectionLabel('Branch Name'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _branchName,
                decoration: InputDecoration(
                  labelText: 'Select Branch',
                  prefixIcon: const Icon(
                    Icons.business_outlined,
                    color: Color(0xFF43A047),
                    size: 20,
                  ),
                ),
                items: _branches
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) => setState(() => _branchName = v),
                validator: (v) => v == null ? lang.t('required') : null,
              ),
              const SizedBox(height: 18),

              _SectionLabel(lang.t('gender')),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'Male',
                      label: Text(lang.t('male')),
                      icon: const Icon(Icons.male),
                    ),
                    ButtonSegment(
                      value: 'Female',
                      label: Text(lang.t('female')),
                      icon: const Icon(Icons.female),
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
                label: lang.t('residential_address'),
                hint: lang.t('residential_hint'),
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? lang.t('required') : null,
              ),

              const SizedBox(height: 24),
              _SectionLabel(lang.t('phone_verification')),
              const SizedBox(height: 12),

              // ── Phone Number ──
              _AppTextField(
                controller: _phoneCtrl,
                label: lang.t('phone'),
                hint: lang.t('phone_hint'),
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return lang.t('required');
                  if (v.trim().length < 10) {
                    return lang.t('valid_phone');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
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
                    : Text(lang.t('signup_btn')),
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
