import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:summer_camp/models/child_model.dart';
import 'package:summer_camp/providers/child_provider.dart';

class ChildrenListScreen extends StatelessWidget {
  const ChildrenListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final children = context.watch<ChildProvider>().childrenList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Children'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tap on your child to view their QR code.',
              style: GoogleFonts.splineSans(
                fontSize: 14,
                color: const Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: children.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final child = children[index];
                  return _ChildCard(child: child);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildModel child;
  const _ChildCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showQrModal(context),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEE6DF)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFf97b06).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('👦', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.childName,
                      style: GoogleFonts.splineSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${child.childId}  •  Age ${child.age}',
                      style: GoogleFonts.splineSans(
                        fontSize: 13,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFf97b06).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: Color(0xFFf97b06),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQrModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QrBottomSheet(child: child),
    );
  }
}

class _QrBottomSheet extends StatelessWidget {
  final ChildModel child;
  const _QrBottomSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0x000ffddd),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            child.childName,
            style: GoogleFonts.splineSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            child.childId,
            style: GoogleFonts.splineSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFf97b06),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 16),
          Text(
            child.entryStatus ? '✅ Already Entered' : '⏳ Not Yet Entered',
            style: GoogleFonts.splineSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: child.entryStatus
                  ? const Color(0xFF43A047)
                  : const Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
