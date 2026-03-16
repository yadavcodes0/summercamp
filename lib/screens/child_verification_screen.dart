import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/child_provider.dart';
import 'package:summer_camp/screens/entry_success_screen.dart';

class ChildVerificationScreen extends StatelessWidget {
  const ChildVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final child = context.watch<ChildProvider>().scannedChild;

    if (child == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final alreadyEntered = child.entryStatus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: alreadyEntered
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: alreadyEntered
                      ? const Color(0xFF43A047).withOpacity(0.4)
                      : const Color(0xFFf97b06).withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    alreadyEntered ? '⚠️' : '✅',
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alreadyEntered ? 'Already Entered' : 'Not Yet Entered',
                        style: GoogleFonts.splineSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: alreadyEntered
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE65100),
                        ),
                      ),
                      if (alreadyEntered && child.entryTime != null)
                        Text(
                          'Entered at: ${_formatTime(child.entryTime!)}',
                          style: GoogleFonts.splineSans(
                            fontSize: 12,
                            color: const Color(0xFF888888),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Child Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEE6DF)),
              ),
              child: Column(
                children: [
                  _InfoTile(
                    icon: '👦',
                    label: 'Child Name',
                    value: child.childName,
                  ),
                  const Divider(height: 20),
                  _InfoTile(
                    icon: '🎫',
                    label: 'Camp ID',
                    value: child.childId,
                    valueColor: const Color(0xFFf97b06),
                  ),
                  const Divider(height: 20),
                  _InfoTile(
                    icon: '🎂',
                    label: 'Age',
                    value: '${child.age} years',
                  ),
                  const Divider(height: 20),
                  _InfoTile(
                    icon: child.gender == 'Female' ? '👧' : '👦',
                    label: 'Gender',
                    value: child.gender ?? 'Not specified',
                  ),
                  const Divider(height: 20),
                  _InfoTile(
                    icon: '👨‍👩‍👦',
                    label: 'Parent',
                    value: child.parentName,
                  ),
                  const Divider(height: 20),
                  _InfoTile(
                    icon: '📱',
                    label: 'Phone',
                    value: child.phone,
                  ),
                ],
              ),
            ),

            const Spacer(),

            if (alreadyEntered)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '⚠️  This child has already been admitted. Do not allow re-entry.',
                  style: GoogleFonts.splineSans(
                    fontSize: 14,
                    color: const Color(0xFFE65100),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () async {
                  final provider = context.read<ChildProvider>();
                  final success = await provider.markEntry(child.childId);
                  if (!context.mounted) return;
                  if (success) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EntrySuccessScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed: ${provider.error}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Allow Entry'),
              ),

            const SizedBox(height: 16),
          ],
        ),
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

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF1A1A1A),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.splineSans(
                fontSize: 12,
                color: const Color(0xFF888888),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.splineSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
