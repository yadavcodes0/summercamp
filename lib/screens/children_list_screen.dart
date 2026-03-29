import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:summer_camp/models/child_model.dart';
import 'package:summer_camp/providers/child_provider.dart';
import 'package:summer_camp/providers/language_provider.dart';

class ChildrenListScreen extends StatelessWidget {
  const ChildrenListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final children = context.watch<ChildProvider>().childrenList;
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(lang.t('my_children')), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context))),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFf97b06).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(Icons.info_outline, size: 16, color: const Color(0xFFf97b06).withOpacity(0.7)),
              const SizedBox(width: 8),
              Text(lang.t('tap_child'), style: GoogleFonts.splineSans(fontSize: 13, color: const Color(0xFF888888))),
            ]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: children.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _ChildCard(child: children[index]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ChildCard extends StatefulWidget {
  final ChildModel child;
  const _ChildCard({required this.child});
  @override
  State<_ChildCard> createState() => _ChildCardState();
}

class _ChildCardState extends State<_ChildCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); _showQrModal(context); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _pressed ? const Color(0xFFf97b06).withOpacity(0.3) : const Color(0xFFEEE6DF)),
            boxShadow: [BoxShadow(color: _pressed ? const Color(0xFFf97b06).withOpacity(0.1) : Colors.black.withOpacity(0.04), blurRadius: _pressed ? 16 : 10, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFFf97b06).withOpacity(0.15), const Color(0xFFf97b06).withOpacity(0.08)]), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFf97b06).withOpacity(0.1))),
              child: Center(child: Text(widget.child.gender == 'Female' ? '👧' : '👦', style: const TextStyle(fontSize: 24)))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.child.childName, style: GoogleFonts.splineSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A))),
              const SizedBox(height: 4),
              Text('${widget.child.childId}  •  ${lang.t('age_label')} ${widget.child.age}', style: GoogleFonts.splineSans(fontSize: 13, color: const Color(0xFF888888))),
            ])),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFf97b06).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.qr_code_2_rounded, color: Color(0xFFf97b06), size: 22)),
          ]),
        ),
      ),
    );
  }

  void _showQrModal(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => _QrBottomSheet(child: widget.child));
  }
}

class _QrBottomSheet extends StatelessWidget {
  final ChildModel child;
  const _QrBottomSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -4))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2))),
        Text(child.childName, style: GoogleFonts.splineSans(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A))),
        const SizedBox(height: 6),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFf97b06).withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
          child: Text(child.childId, style: GoogleFonts.splineSans(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFf97b06), letterSpacing: 1.5))),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEEE6DF)), boxShadow: [BoxShadow(color: const Color(0xFFf97b06).withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))]),
          child: QrImageView(data: child.childId, version: QrVersions.auto, size: 220, eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF1A1A1A)), dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF1A1A1A))),
        ),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: child.entryStatus ? const Color(0xFF43A047).withOpacity(0.1) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20)),
          child: Text(child.entryStatus ? '✅ ${lang.t('already_entered')}' : '⏳ ${lang.t('not_entered')}', style: GoogleFonts.splineSans(fontSize: 13, fontWeight: FontWeight.w600, color: child.entryStatus ? const Color(0xFF43A047) : const Color(0xFF888888)))),
        const SizedBox(height: 24),
      ]),
    );
  }
}
