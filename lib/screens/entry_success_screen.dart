import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/child_provider.dart';

class EntrySuccessScreen extends StatefulWidget {
  const EntrySuccessScreen({super.key});

  @override
  State<EntrySuccessScreen> createState() => _EntrySuccessScreenState();
}

class _EntrySuccessScreenState extends State<EntrySuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
    final name = child?.childName ?? '';
    final time = child?.entryTime != null
        ? _formatTime(child!.entryTime!)
        : _formatTime(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Check
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('✅', style: TextStyle(fontSize: 64)),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Entry Successful!',
                style: GoogleFonts.splineSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '$name has entered the camp 🎉',
                style: GoogleFonts.splineSans(
                  fontSize: 16,
                  color: const Color(0xFF555555),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time,
                        size: 16, color: Color(0xFF43A047)),
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

              const SizedBox(height: 60),

              ElevatedButton.icon(
                onPressed: () {
                  context.read<ChildProvider>().reset();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.qr_code_scanner),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
                ),
                label: const Text('Scan Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
