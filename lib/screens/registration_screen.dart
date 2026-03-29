import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/child_provider.dart';
import 'package:summer_camp/providers/language_provider.dart';
import 'package:summer_camp/screens/registration_success_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _childNameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _parentNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _gender = 'Male';
  String? _branchName;

  final List<String> _branches = [
    'Inderlok',
    'Tri Nagar',
    'Ashok Vihar',
    'Lawrence Road',
    'Nehru Nagar',
    'Azad Colony'
  ];

  late AnimationController _anim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _childNameCtrl.dispose();
    _ageCtrl.dispose();
    _parentNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ChildProvider>();
    final success = await provider.registerChild(
      childName: _childNameCtrl.text.trim(),
      age: int.parse(_ageCtrl.text.trim()),
      parentName: _parentNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      gender: _gender,
      branchName: _branchName ?? '',
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
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('register_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFf97b06).withOpacity(0.12),
                          const Color(0xFFf97b06).withOpacity(0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFf97b06).withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFf97b06).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('📝', style: TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            lang.t('register_header'),
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

                  _SectionLabel(lang.t('child_info')),
                  const SizedBox(height: 12),

                  _AppTextField(
                    controller: _childNameCtrl,
                    label: lang.t('child_name'),
                    hint: lang.t('child_name_hint'),
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? lang.t('required') : null,
                  ),
                  const SizedBox(height: 14),

                  _AppTextField(
                    controller: _ageCtrl,
                    label: lang.t('age'),
                    hint: lang.t('age_hint'),
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return lang.t('required');
                      final n = int.tryParse(v.trim());
                      if (n == null || n < 5 || n > 25) {
                        return lang.t('valid_age');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      lang.t('age_limit_note'),
                      style: GoogleFonts.splineSans(
                        fontSize: 12,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  _SectionLabel('Branch Name'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _branchName,
                    decoration: InputDecoration(
                      labelText: 'Select Branch',
                      prefixIcon: const Icon(Icons.business_outlined, color: Color(0xFFf97b06), size: 20),
                    ),
                    items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (v) => setState(() => _branchName = v),
                    validator: (v) => v == null ? lang.t('required') : null,
                  ),
                  const SizedBox(height: 24),

                  _SectionLabel(lang.t('gender')),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'Male',
                          label: Text(lang.t('male')),
                          icon: Icon(Icons.male),
                        ),
                        ButtonSegment(
                          value: 'Female',
                          label: Text(lang.t('female')),
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
                  _SectionLabel(lang.t('parent_guardian')),
                  const SizedBox(height: 12),

                  _AppTextField(
                    controller: _parentNameCtrl,
                    label: lang.t('parent_name'),
                    hint: lang.t('parent_name_hint'),
                    icon: Icons.supervisor_account_outlined,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? lang.t('required') : null,
                  ),
                  const SizedBox(height: 14),

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

                  _AppTextField(
                    controller: _addressCtrl,
                    label: lang.t('address'),
                    hint: lang.t('address_hint'),
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? lang.t('required') : null,
                  ),

                  const SizedBox(height: 32),

                  // Premium button
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8C00), Color(0xFFf97b06)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFf97b06).withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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
                          : Text(
                              lang.t('register_btn'),
                              style: GoogleFonts.splineSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
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
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFf97b06),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.splineSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF333333),
          ),
        ),
      ],
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
