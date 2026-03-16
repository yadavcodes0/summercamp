import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/child_provider.dart';
import 'package:summer_camp/providers/volunteer_provider.dart';
import 'package:summer_camp/screens/child_verification_screen.dart';
import 'package:summer_camp/screens/home_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scanController = MobileScannerController();
  bool _isProcessing = false;
  bool _isNavigatedAway = false;

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _isNavigatedAway) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() => _isProcessing = true);

    final campId = barcode!.rawValue!.trim();
    final provider = context.read<ChildProvider>();
    final found = await provider.fetchChildByCampId(campId);

    if (!mounted) return;

    if (found && provider.scannedChild != null) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _isNavigatedAway = true;
      });
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChildVerificationScreen()),
      );
      // Remount scanner after returning from Success/Verification, with a slight delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _isNavigatedAway = false);
      }
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Child not found. Invalid QR code.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Scan QR Code',
          style: GoogleFonts.splineSans(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await context.read<VolunteerProvider>().logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_isNavigatedAway)
            MobileScanner(controller: _scanController, onDetect: _onDetect)
          else
            Container(color: Colors.black),

          // Overlay
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFf97b06), width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Corner decorations
          ..._buildCorners(),

          // Bottom Info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
              child: Column(
                children: [
                  if (_isProcessing)
                    const CircularProgressIndicator(color: Color(0xFFf97b06))
                  else
                    Text(
                      'Align the QR code within the frame',
                      style: GoogleFonts.splineSans(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    return [];
  }
}
