import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:summer_camp/providers/child_provider.dart';
import 'package:summer_camp/screens/home_screen.dart';

class RegistrationSuccessScreen extends StatefulWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  State<RegistrationSuccessScreen> createState() =>
      _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen> {
  final _screenshotController = ScreenshotController();

  Future<void> _shareQr(String childId) async {
    final imageBytes = await _screenshotController.capture();
    if (imageBytes == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/qr_$childId.png');
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'My Summer Camp 2026 QR Code - $childId');
  }

  @override
  Widget build(BuildContext context) {
    final child = context.watch<ChildProvider>().registeredChild;

    if (child == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Registration Successful'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Success Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF43A047).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF43A047).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Text('✅', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    'Registration Complete!',
                    style: GoogleFonts.splineSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Show this QR code at camp entry',
                    style: GoogleFonts.splineSans(
                      fontSize: 13,
                      color: const Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Child Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEE6DF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Child Name', value: child.childName),
                  const Divider(height: 20),
                  _InfoRow(label: 'Camp ID', value: child.childId),
                  const Divider(height: 20),
                  _InfoRow(label: 'Age', value: '${child.age} years'),
                  const Divider(height: 20),
                  _InfoRow(label: 'Parent', value: child.parentName),
                  const Divider(height: 20),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // QR Code
            Screenshot(
              controller: _screenshotController,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEEE6DF)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFf97b06).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
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
                    const SizedBox(height: 12),
                    Text(
                      child.childId,
                      style: GoogleFonts.splineSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFf97b06),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Share Button
            ElevatedButton.icon(
              onPressed: () => _shareQr(child.childId),
              icon: const Icon(Icons.share_rounded),
              label: const Text('Share QR Code'),
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Back to Home'),
            ),

            const SizedBox(height: 24),
          ],
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
