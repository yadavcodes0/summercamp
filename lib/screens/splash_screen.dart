import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/volunteer_provider.dart';
import 'package:summer_camp/screens/admin_dashboard_screen.dart';
import 'package:summer_camp/screens/language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _fadeOutController;
  late Animation<double> _exitOverlayOpacity;

  // Staggered animations
  late Animation<double> _iconScale;
  late Animation<double> _iconFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _yearSlide;
  late Animation<double> _yearFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _loaderFade;
  late Animation<double> _bgCirclesFade;

  // Pulse glow
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // ── Main stagger controller (1.8s) ──
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // ── Pulse glow loop ──
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Shimmer loader ──
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // ── Background circles fade ──
    _bgCirclesFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // ── Icon: scale + fade (0% → 40%) ──
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );
    _iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // ── Title: slide-up + fade (25% → 55%) ──
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
          ),
        );
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.50, curve: Curves.easeIn),
      ),
    );

    // ── Year badge: slide-up + fade (40% → 65%) ──
    _yearSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.40, 0.65, curve: Curves.easeOutCubic),
          ),
        );
    _yearFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.40, 0.60, curve: Curves.easeIn),
      ),
    );

    // ── Subtitle: slide-up + fade (55% → 80%) ──
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.55, 0.80, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.75, curve: Curves.easeIn),
      ),
    );

    // ── Loader bar: fade (70% → 90%) ──
    _loaderFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.70, 0.90, curve: Curves.easeIn),
      ),
    );

    // ── Fade-out exit overlay ──
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _exitOverlayOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
    );

    _mainController.forward();

    // ── Navigation ──
    final provider = context.read<VolunteerProvider>();
    Future.wait([
      Future.delayed(const Duration(seconds: 4)),
      provider.initializationDone,
    ]).then((_) {
      if (mounted) {
        Widget destination;
        if (provider.isLoggedIn) {
          destination = const AdminDashboardScreen();
        } else {
          destination = const LanguageSelectionScreen();
        }
        // Fade out splash first, then navigate
        _fadeOutController.forward().then((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => destination,
                transitionDuration: Duration.zero,
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF8C00),
                  Color(0xFFf97b06),
                  Color(0xFFE85D04),
                  Color(0xFFD14600),
                ],
                stops: [0.0, 0.35, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                _buildBackgroundCircles(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildGlowingIcon(),
                        const SizedBox(height: 36),
                        SlideTransition(
                          position: _titleSlide,
                          child: FadeTransition(
                            opacity: _titleFade,
                            child: Text(
                              'Kids Workshop',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.splineSans(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                height: 1.1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SlideTransition(
                          position: _yearSlide,
                          child: FadeTransition(
                            opacity: _yearFade,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                              ),
                              child: Text(
                                '✦  2 0 2 6  ✦',
                                style: GoogleFonts.splineSans(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SlideTransition(
                          position: _subtitleSlide,
                          child: FadeTransition(
                            opacity: _subtitleFade,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on_rounded, size: 14, color: Colors.white.withOpacity(0.7)),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Sant Nirankari Satsang Bhawan, Inderlok',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.splineSans(fontSize: 12, color: Colors.white.withOpacity(0.7), letterSpacing: 0.5, fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        FadeTransition(
                          opacity: _loaderFade,
                          child: _buildShimmerLoader(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Exit overlay: fades to cream before navigating ──
          AnimatedBuilder(
            animation: _fadeOutController,
            builder: (context, _) {
              if (_exitOverlayOpacity.value == 0) return const SizedBox.shrink();
              return Opacity(
                opacity: _exitOverlayOpacity.value,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFFF8F2), Color(0xFFFFEBD6), Color(0xFFFFF8F2)],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Glowing animated icon ──
  Widget _buildGlowingIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _pulseController]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _iconFade,
          child: ScaleTransition(
            scale: _iconScale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulsing glow
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(_pulseAnim.value * 0.3),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
                // Outer ring
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 2,
                    ),
                  ),
                ),
                // Inner ring
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                ),
                // Main icon circle
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🎨', style: TextStyle(fontSize: 44)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Decorative floating circles ──
  Widget _buildBackgroundCircles() {
    return FadeTransition(
      opacity: _bgCirclesFade,
      child: Stack(
        children: [
          Positioned(top: -60, right: -40, child: _circle(180, 0.06)),
          Positioned(bottom: -80, left: -50, child: _circle(220, 0.05)),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: -30,
            child: _circle(80, 0.08),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.25,
            right: -20,
            child: _circle(60, 0.07),
          ),
          Positioned(
            top: 100,
            left: MediaQuery.of(context).size.width * 0.6,
            child: _circle(40, 0.1),
          ),
          // INVISIBLE TEXT TO PRELOAD FONTS FOR WEB
          Positioned(
            top: -100,
            left: -100,
            child: Opacity(
              opacity: 0.01,
              child: Text(
                '🎨 अ हिन्दी भाषा चुनें हिंदी में जारी रखें',
                style: GoogleFonts.splineSans(fontSize: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  // ── Shimmer loading bar ──
  Widget _buildShimmerLoader() {
    return SizedBox(
      width: 160,
      height: 4,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, _) {
          return CustomPaint(
            painter: _ShimmerBarPainter(progress: _shimmerController.value),
          );
        },
      ),
    );
  }
}

class _ShimmerBarPainter extends CustomPainter {
  final double progress;
  _ShimmerBarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(4),
    );
    canvas.drawRRect(rRect, bgPaint);

    // Shimmer highlight
    final shimmerWidth = size.width * 0.4;
    final shimmerX = (progress * (size.width + shimmerWidth)) - shimmerWidth;

    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(shimmerX, 0, shimmerWidth, size.height));

    canvas.save();
    canvas.clipRRect(rRect);
    canvas.drawRect(
      Rect.fromLTWH(shimmerX, 0, shimmerWidth, size.height),
      shimmerPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShimmerBarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
