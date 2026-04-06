import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:summer_camp/screens/admin/admin_analytics_page.dart';
import 'package:summer_camp/screens/admin/admin_children_page.dart';
import 'package:summer_camp/screens/admin/admin_overview_page.dart';
import 'package:summer_camp/screens/admin/admin_volunteers_page.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;

  final _pages = const [
    AdminOverviewPage(),
    AdminChildrenPage(),
    AdminVolunteersPage(),
    AdminAnalyticsPage(),
  ];

  final _menuItems = const [
    _MenuItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _MenuItem(icon: Icons.child_care_rounded, label: 'Children'),
    _MenuItem(icon: Icons.people_rounded, label: 'Volunteers'),
    _MenuItem(icon: Icons.analytics_rounded, label: 'Analytics'),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ──
          Container(
            width: 240,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Logo / Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFf97b06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.forest_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kids Workshop',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Admin Panel',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white38,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Menu Items
                ...List.generate(_menuItems.length, (i) {
                  final item = _menuItems[i];
                  final isActive = _selectedIndex == i;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => _selectedIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFf97b06).withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: isActive
                                ? Border.all(
                                    color: const Color(
                                      0xFFf97b06,
                                    ).withOpacity(0.3),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 20,
                                color: isActive
                                    ? const Color(0xFFf97b06)
                                    : Colors.white38,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item.label,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isActive
                                      ? const Color(0xFFf97b06)
                                      : Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const Spacer(),

                // Footer
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Text(
                    '© 2026 Kids Workshop',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Main Content ──
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5FA),
              child: Column(
                children: [
                  // Top header
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          _menuItems[_selectedIndex].label,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formattedDate(),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(width: 20),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFf97b06),
                          child: Text(
                            'A',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Page Content
                  Expanded(child: _pages[_selectedIndex]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class _MenuItem {
  final IconData icon;
  final String label;

  const _MenuItem({required this.icon, required this.label});
}
