import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/child_provider.dart';
import 'package:summer_camp/screens/registration_success_screen.dart';

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

  // New field
  String _gender = 'Male';

  @override
  void initState() {
    super.initState();
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

              // ── Phone Number ──
              _AppTextField(
                controller: _phoneCtrl,
                label: 'Phone Number',
                hint: 'e.g. 9876543210',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim().length < 10) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
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
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf97b06),
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
