import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/child_provider.dart';
import 'package:summer_camp/providers/language_provider.dart';
import 'package:summer_camp/providers/volunteer_provider.dart';
import 'package:summer_camp/screens/entry_success_screen.dart';

class ChildVerificationScreen extends StatelessWidget {
  const ChildVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final child = context.watch<ChildProvider>().scannedChild;
    final lang = context.watch<LanguageProvider>();
    if (child == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final alreadyEntered = child.entryStatus;

    return Scaffold(
      appBar: AppBar(title: Text(lang.t('child_details')), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Status Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: alreadyEntered ? [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)] : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: alreadyEntered ? const Color(0xFF43A047).withOpacity(0.3) : const Color(0xFFf97b06).withOpacity(0.3)),
              boxShadow: [BoxShadow(color: (alreadyEntered ? const Color(0xFF43A047) : const Color(0xFFf97b06)).withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: (alreadyEntered ? const Color(0xFF43A047) : const Color(0xFFf97b06)).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(alreadyEntered ? '⚠️' : '✅', style: const TextStyle(fontSize: 22)))),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(alreadyEntered ? lang.t('already_entered') : lang.t('not_entered'), style: GoogleFonts.splineSans(fontSize: 16, fontWeight: FontWeight.w700, color: alreadyEntered ? const Color(0xFF2E7D32) : const Color(0xFFE65100))),
                if (alreadyEntered && child.entryTime != null)
                  Text('${lang.t('entered_at')} ${_formatTime(child.entryTime!)}', style: GoogleFonts.splineSans(fontSize: 12, color: const Color(0xFF888888))),
              ]),
            ]),
          ),

          const SizedBox(height: 24),

          // Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFEEE6DF)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
            child: Column(children: [
              _InfoTile(icon: '👦', label: lang.t('child_name_label'), value: child.childName),
              const Divider(height: 20, color: Color(0xFFF0EBE6)),
              _InfoTile(icon: '🎫', label: lang.t('workshop_id'), value: child.childId, valueColor: const Color(0xFFf97b06)),
              const Divider(height: 20, color: Color(0xFFF0EBE6)),
              _InfoTile(icon: '🎂', label: lang.t('age_label'), value: '${child.age} ${lang.t('years')}'),
              const Divider(height: 20, color: Color(0xFFF0EBE6)),
              _InfoTile(icon: child.gender == 'Female' ? '👧' : '👦', label: lang.t('gender_label'), value: lang.t(child.gender?.toLowerCase() ?? 'not_specified')),
              const Divider(height: 20, color: Color(0xFFF0EBE6)),
              _InfoTile(icon: '👨‍👩‍👦', label: lang.t('parent_info'), value: child.parentName),
              const Divider(height: 20, color: Color(0xFFF0EBE6)),
              _InfoTile(icon: '📱', label: lang.t('phone_label'), value: child.phone),
            ]),
          ),

          const Spacer(),

          if (alreadyEntered)
            Container(
              width: double.infinity, padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)]), borderRadius: BorderRadius.circular(14)),
              child: Text(lang.t('no_reentry'), style: GoogleFonts.splineSans(fontSize: 14, color: const Color(0xFFE65100), height: 1.5), textAlign: TextAlign.center))
          else
            Container(width: double.infinity, height: 54, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [Color(0xFFFF8C00), Color(0xFFf97b06)]), boxShadow: [BoxShadow(color: const Color(0xFFf97b06).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))]),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final provider = context.read<ChildProvider>();
                  final volunteerProvider = context.read<VolunteerProvider>();
                  final success = await provider.markEntry(
                    child.childId,
                    volunteerName: volunteerProvider.volunteerName ?? 'Unknown',
                    volunteerPhone: volunteerProvider.volunteerPhone ?? '',
                  );
                  if (!context.mounted) return;
                  if (success) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EntrySuccessScreen())); }
                  else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${provider.error}'), backgroundColor: Colors.red)); }
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text(lang.t('allow_entry'), style: GoogleFonts.splineSans(fontWeight: FontWeight.w600, color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),

          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}

class _InfoTile extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color valueColor;
  const _InfoTile({required this.icon, required this.label, required this.value, this.valueColor = const Color(0xFF1A1A1A)});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFF5F0EB), borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 16)))),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.splineSans(fontSize: 11, color: const Color(0xFF888888), letterSpacing: 0.3)),
        Text(value, style: GoogleFonts.splineSans(fontSize: 15, fontWeight: FontWeight.w600, color: valueColor)),
      ]),
    ]);
  }
}
