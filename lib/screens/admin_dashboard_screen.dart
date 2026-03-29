import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/language_provider.dart';
import 'package:summer_camp/providers/volunteer_provider.dart';
import 'package:summer_camp/screens/home_screen.dart';
import 'package:summer_camp/screens/qr_scanner_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with TickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  // Background animation controller
  late AnimationController _bgAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    
    _bgAnim = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _bgAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFfaf9f6),
        body: Stack(
          children: [
            // Animated Mesh Gradient Background
            AnimatedBuilder(
              animation: _bgAnim,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: -100 + (_bgAnim.value * 50),
                      left: -50,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF81C784).withValues(alpha: 0.6)),
                      ),
                    ),
                    Positioned(
                      top: 50 - (_bgAnim.value * 30),
                      right: -100,
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFA5D6A7).withValues(alpha: 0.6)),
                      ),
                    ),
                    Positioned(
                      top: 250,
                      left: 50 + (_bgAnim.value * 60),
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF66BB6A).withValues(alpha: 0.45)),
                      ),
                    ),
                  ],
                );
              },
            ),
            
            // Blur overlay for mesh effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // App Bar Area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang.t('volunteer_dashboard'),
                          style: GoogleFonts.splineSans(
                            color: const Color(0xFF1E293B),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        // Language Toggle inline
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final current = lang.locale;
                              context.read<LanguageProvider>().setLanguage(current == 'en' ? 'hi' : 'en');
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Text(
                                lang.locale.toUpperCase(),
                                style: GoogleFonts.splineSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Greeting Glass Card
                              Consumer<VolunteerProvider>(
                                builder: (context, provider, _) {
                                  final name = provider.volunteerName ?? 'Volunteer';
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(32),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(28),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 10)),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(lang.t('welcome_back'), style: GoogleFonts.splineSans(fontSize: 15, color: const Color(0xFF475569))),
                                            const SizedBox(height: 6),
                                            Text(
                                              name,
                                              style: GoogleFonts.splineSans(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.5),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 40),

                              // Actions Header
                              Text("Quick Actions", style: GoogleFonts.splineSans(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                              const SizedBox(height: 16),

                              // Actions
                              _AdminActionCard(
                                icon: Icons.qr_code_scanner_rounded,
                                title: lang.t('scan_qr_title'),
                                subtitle: lang.t('scan_qr_subtitle'),
                                color: const Color(0xFF2E7D32),
                                gradientColors: const [Color(0xFF81C784), Color(0xFFC8E6C9)],
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen())),
                              ),
                              const SizedBox(height: 16),
                              _AdminActionCard(
                                icon: Icons.logout_rounded,
                                title: lang.t('logout'),
                                subtitle: lang.t('logout_subtitle'),
                                color: const Color(0xFFEF4444),
                                gradientColors: const [Color(0xFFfacaca), Color(0xFFfcdbdb)],
                                onTap: () async {
                                  await context.read<VolunteerProvider>().logout();
                                  if (!context.mounted) return;
                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  
  const _AdminActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_AdminActionCard> createState() => _AdminActionCardState();
}

class _AdminActionCardState extends State<_AdminActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _pressed ? widget.color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.9),
                  width: _pressed ? 2.0 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(color: _pressed ? widget.color.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04), blurRadius: _pressed ? 20 : 16, offset: const Offset(0, 8))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: widget.gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: widget.gradientColors[0].withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Center(child: Icon(widget.icon, color: Colors.white, size: 30)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: GoogleFonts.splineSans(fontSize: 19, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        const SizedBox(height: 6),
                        Text(widget.subtitle, style: GoogleFonts.splineSans(fontSize: 14, color: const Color(0xFF64748B), height: 1.4)),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]),
                    child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: widget.color),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
