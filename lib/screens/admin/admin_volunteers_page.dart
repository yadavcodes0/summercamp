import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/admin_dashboard_provider.dart';

class AdminVolunteersPage extends StatefulWidget {
  const AdminVolunteersPage({super.key});

  @override
  State<AdminVolunteersPage> createState() => _AdminVolunteersPageState();
}

class _AdminVolunteersPageState extends State<AdminVolunteersPage> {
  String _searchQuery = '';

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> volunteers) {
    if (_searchQuery.isEmpty) return volunteers;
    final q = _searchQuery.toLowerCase();
    return volunteers.where((v) {
      final name = (v['full_name'] ?? '').toString().toLowerCase();
      final phone = (v['phone_number'] ?? '').toString().toLowerCase();
      return name.contains(q) || phone.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final filtered = _filter(provider.volunteers);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by Name or Phone...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF999999),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF999999),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${filtered.length} volunteers',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 16),

          // Data Table
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F5FA)),
              columnSpacing: 24,
              columns: [
                _col('Full Name'),
                _col('Age'),
                _col('Gender'),
                _col('Phone'),
                _col('Email'),
                _col('Address'),
              ],
              rows: filtered.map((v) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        v['full_name'] ?? '—',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${v['age'] ?? '—'}',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        v['gender'] ?? '—',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        v['phone_number'] ?? '—',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        v['email_address'] ?? '—',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        v['address'] ?? '—',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  DataColumn _col(String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
