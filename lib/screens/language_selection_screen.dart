import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/language_provider.dart';
import 'package:summer_camp/screens/home_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  String _selected = 'en';
  late AnimationController _anim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8F2), Color(0xFFFFEBD6), Color(0xFFFFF8F2)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Globe Icon
                    Stack(alignment: Alignment.center, children: [
                      Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFf97b06).withOpacity(0.08), width: 2))),
                      Container(width: 105, height: 105, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFf97b06).withOpacity(0.08))),
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [const Color(0xFFf97b06).withOpacity(0.2), const Color(0xFFFF8C00).withOpacity(0.1)]),
                        ),
                        child: const Center(child: Text('🌐', style: TextStyle(fontSize: 40))),
                      ),
                    ]),

                    const SizedBox(height: 32),

                    Text('Choose Language', style: GoogleFonts.splineSans(fontSize: 26, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A))),
                    const SizedBox(height: 6),
                    Text('भाषा चुनें', style: GoogleFonts.splineSans(fontSize: 18, fontWeight: FontWeight.w500, color: const Color(0xFF888888))),
                    const SizedBox(height: 8),
                    Text('Select your preferred language', style: GoogleFonts.splineSans(fontSize: 13, color: const Color(0xFFAAAAAA))),

                    const SizedBox(height: 40),

                    // English Card
                    _LanguageCard(
                      flag: '🇬🇧',
                      title: 'English',
                      subtitle: 'Continue in English',
                      isSelected: _selected == 'en',
                      onTap: () => setState(() => _selected = 'en'),
                    ),

                    const SizedBox(height: 14),

                    // Hindi Card
                    _LanguageCard(
                      flag: '🇮🇳',
                      title: 'हिन्दी',
                      subtitle: 'हिंदी में जारी रखें',
                      isSelected: _selected == 'hi',
                      onTap: () => setState(() => _selected = 'hi'),
                    ),

                    const Spacer(flex: 2),

                    // Continue Button
                    Container(
                      width: double.infinity, height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(colors: [Color(0xFFFF8C00), Color(0xFFf97b06)]),
                        boxShadow: [BoxShadow(color: const Color(0xFFf97b06).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          await context.read<LanguageProvider>().setLanguage(_selected);
                          if (!context.mounted) return;
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(_selected == 'hi' ? 'जारी रखें' : 'Continue', style: GoogleFonts.splineSans(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({required this.flag, required this.title, required this.subtitle, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFf97b06).withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFFf97b06) : const Color(0xFFEEE6DF), width: isSelected ? 2 : 1),
          boxShadow: [
            if (isSelected) BoxShadow(color: const Color(0xFFf97b06).withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4)),
            if (!isSelected) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: isSelected ? const Color(0xFFf97b06).withOpacity(0.1) : const Color(0xFFF5F0EB), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(flag, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.splineSans(fontSize: 18, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFFf97b06) : const Color(0xFF1A1A1A))),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.splineSans(fontSize: 13, color: const Color(0xFF888888))),
          ])),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24, height: 24,
            decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? const Color(0xFFf97b06) : Colors.transparent, border: Border.all(color: isSelected ? const Color(0xFFf97b06) : const Color(0xFFCCCCCC), width: 2)),
            child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
        ]),
      ),
    );
  }
}
