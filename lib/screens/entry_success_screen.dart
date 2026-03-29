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
    _iconCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut));
    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _contentFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));
    _iconCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () { if (mounted) _contentCtrl.forward(); });
  }

  @override
  void dispose() { _iconCtrl.dispose(); _contentCtrl.dispose(); super.dispose(); }

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
    final time = child?.entryTime != null ? _formatTime(child!.entryTime!) : _formatTime(DateTime.now());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFA5D6A7)]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Stack(alignment: Alignment.center, children: [
                    Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF43A047).withOpacity(0.1), width: 2))),
                    Container(width: 130, height: 130, decoration: BoxDecoration(color: const Color(0xFF43A047).withOpacity(0.12), shape: BoxShape.circle)),
                    Container(width: 100, height: 100, decoration: BoxDecoration(color: const Color(0xFF43A047).withOpacity(0.2), shape: BoxShape.circle),
                      child: const Center(child: Text('✅', style: TextStyle(fontSize: 50)))),
                  ]),
                ),
                const SizedBox(height: 36),
                FadeTransition(opacity: _contentFade, child: SlideTransition(position: _contentSlide, child: Column(children: [
                  Text(lang.t('entry_success'), style: GoogleFonts.splineSans(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF2E7D32))),
                  const SizedBox(height: 12),
                  Text('$name ${lang.t('entered_workshop')}', style: GoogleFonts.splineSans(fontSize: 16, color: const Color(0xFF555555)), textAlign: TextAlign.center),
                  const SizedBox(height: 14),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFF43A047).withOpacity(0.2))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.access_time, size: 16, color: Color(0xFF43A047)),
                      const SizedBox(width: 6),
                      Text(time, style: GoogleFonts.splineSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF43A047))),
                    ])),
                  const SizedBox(height: 60),
                  Container(width: double.infinity, height: 54, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF66BB6A)]), boxShadow: [BoxShadow(color: const Color(0xFF43A047).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))]),
                    child: ElevatedButton.icon(onPressed: () { context.read<ChildProvider>().reset(); Navigator.pop(context); }, icon: const Icon(Icons.qr_code_scanner, color: Colors.white), style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      label: Text(lang.t('scan_next'), style: GoogleFonts.splineSans(fontWeight: FontWeight.w600, color: Colors.white)))),
                ]))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
