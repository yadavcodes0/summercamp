import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:summer_camp/providers/child_provider.dart';
import 'package:summer_camp/providers/language_provider.dart';
import 'package:summer_camp/screens/home_screen.dart';
import 'package:summer_camp/services/file_saver.dart';

class RegistrationSuccessScreen extends StatefulWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  State<RegistrationSuccessScreen> createState() =>
      _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen>
    with SingleTickerProviderStateMixin {
  final _screenshotController = ScreenshotController();
  late AnimationController _anim;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _shareQr(String childId) async {
    final imageBytes = await _screenshotController.capture();
    if (imageBytes == null) return;

    if (kIsWeb) {
      try {
        final xFile = XFile.fromData(
          imageBytes,
          mimeType: 'image/png',
          name: 'KidsWorkshop_QR_$childId.png',
        );
        await Share.shareXFiles([xFile], text: 'My Kids Workshop 2026 QR Code - $childId');
      } catch (e) {
        await FileSaver.saveFileBytes('KidsWorkshop_QR_$childId.png', imageBytes);
      }
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/KidsWorkshop_QR_$childId.png');
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'My Kids Workshop 2026 QR Code - $childId');
  }

  Future<void> _saveToGallery(String childId) async {
    final Uint8List? imageBytes = await _screenshotController.capture();
    if (imageBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture QR code')),
        );
      }
      return;
    }

    if (kIsWeb) {
      await FileSaver.saveFileBytes('KidsWorkshop_QR_$childId.png', imageBytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR code downloaded!'),
            backgroundColor: Color(0xFF43A047),
          ),
        );
      }
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/KidsWorkshop_QR_$childId.png');
      await file.writeAsBytes(imageBytes);
      await Gal.putImage(file.path, album: 'KidsWorkshop');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR code saved to gallery!'),
            backgroundColor: Color(0xFF43A047),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save QR code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = context.watch<ChildProvider>().registeredChild;
    final lang = context.watch<LanguageProvider>();

    if (child == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(lang.t('reg_success_title')),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Success Banner
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF43A047).withOpacity(0.12),
                        const Color(0xFF66BB6A).withOpacity(0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF43A047).withOpacity(0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF43A047).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('✅', style: TextStyle(fontSize: 32)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        lang.t('reg_complete'),
                        style: GoogleFonts.splineSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lang.t('show_qr'),
                        style: GoogleFonts.splineSans(
                          fontSize: 13,
                          color: const Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Child Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEEE6DF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: lang.t('child_name_label'), value: child.childName),
                    const Divider(height: 20, color: Color(0xFFF0EBE6)),
                    _InfoRow(label: lang.t('workshop_id'), value: child.childId),
                    const Divider(height: 20, color: Color(0xFFF0EBE6)),
                    _InfoRow(label: lang.t('age_label'), value: '${child.age} ${lang.t('years')}'),
                    const Divider(height: 20, color: Color(0xFFF0EBE6)),
                    _InfoRow(label: lang.t('parent_label'), value: child.parentName),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // QR Code
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFEEE6DF)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFf97b06).withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: child.childId,
                        version: QrVersions.auto,
                        size: 220,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF1A1A1A),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFf97b06).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          child.childId,
                          style: GoogleFonts.splineSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFf97b06),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Download Button
              _PremiumButton(
                label: lang.t('save_gallery'),
                icon: Icons.download_rounded,
                color: const Color(0xFF43A047),
                onTap: () => _saveToGallery(child.childId),
              ),

              const SizedBox(height: 14),

              // Share Button
              _PremiumButton(
                label: lang.t('share_qr'),
                icon: Icons.share_rounded,
                color: const Color(0xFFf97b06),
                onTap: () => _shareQr(child.childId),
              ),

              const SizedBox(height: 14),

              // Home Button
              OutlinedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  side: const BorderSide(color: Color(0xFFf97b06)),
                  foregroundColor: const Color(0xFFf97b06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(lang.t('back_home')),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PremiumButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.85)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: GoogleFonts.splineSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.splineSans(
            fontSize: 13,
            color: const Color(0xFF888888),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.splineSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
