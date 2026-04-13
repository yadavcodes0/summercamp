import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/child_provider.dart';
import 'package:summer_camp/providers/language_provider.dart';

class EntrySuccessScreen extends StatefulWidget {
  const EntrySuccessScreen({super.key});

  @override
  State<EntrySuccessScreen> createState() => _EntrySuccessScreenState();
}

class _EntrySuccessScreenState extends State<EntrySuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut));
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _contentFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
        );
    _iconCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final child = context.watch<ChildProvider>().scannedChild;
    final lang = context.watch<LanguageProvider>();
    final name = child?.childName ?? '';
    final time = child?.entryTime != null
        ? _formatTime(child!.entryTime!)
        : _formatTime(DateTime.now());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF43A047).withOpacity(0.1),
                            width: 2,
                          ),
                        ),
                      ),
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color(0xFF43A047).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF43A047).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('✅', style: TextStyle(fontSize: 50)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: Column(
                      children: [
                        Text(
                          lang.t('entry_success'),
                          style: GoogleFonts.splineSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$name ${lang.t('entered_workshop')}',
                          style: GoogleFonts.splineSans(
                            fontSize: 16,
                            color: const Color(0xFF555555),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF43A047).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Color(0xFF43A047),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                time,
                                style: GoogleFonts.splineSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF43A047),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // ── Band Colour Indicator ──
                        _BandColourBadge(age: child?.age ?? 0),
                        const SizedBox(height: 48),
                        Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF43A047,
                                ).withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<ChildProvider>().reset();
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            label: Text(
                              lang.t('scan_next'),
                              style: GoogleFonts.splineSans(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BandColourBadge extends StatelessWidget {
  final int age;
  const _BandColourBadge({required this.age});

  static const _groups = [
    (min: 5, max: 7, color: Color(0xFFE91E8C), name: 'Pink', label: '5–7 yrs'),
    (min: 8, max: 10, color: Color(0xFFE53935), name: 'Red', label: '8–10 yrs'),
    (
      min: 11,
      max: 16,
      color: Color(0xFF43A047),
      name: 'Green',
      label: '11–16 yrs',
    ),
    (
      min: 17,
      max: 21,
      color: Color(0xFFFDD835),
      name: 'Yellow',
      label: '17–21 yrs',
    ),
    (
      min: 22,
      max: 25,
      color: Color(0xFF1E88E5),
      name: 'Blue',
      label: '22–25 yrs',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final group = _groups.firstWhere(
      (g) => age >= g.min && age <= g.max,
      orElse: () => (
        min: 0,
        max: 0,
        color: const Color(0xFF888888),
        name: 'N/A',
        label: '',
      ),
    );

    final bandColor = group.color;
    final bandName = group.name;
    final bandLabel = group.label;
    final textColor = bandName == 'Yellow'
        ? const Color(0xFF333333)
        : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bandColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: bandColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.palette_rounded, color: textColor, size: 26),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Give $bandName Band',
                style: GoogleFonts.splineSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              Text(
                'Age Group: $bandLabel',
                style: GoogleFonts.splineSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
