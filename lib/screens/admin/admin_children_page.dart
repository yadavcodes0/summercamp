import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/models/child_model.dart';
import 'package:summer_camp/providers/admin_dashboard_provider.dart';
import 'package:summer_camp/services/file_saver.dart';

class AdminChildrenPage extends StatefulWidget {
  const AdminChildrenPage({super.key});

  @override
  State<AdminChildrenPage> createState() => _AdminChildrenPageState();
}

class _AdminChildrenPageState extends State<AdminChildrenPage> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _genderFilter = 'All';

  List<ChildModel> _filter(List<ChildModel> children) {
    return children.where((c) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          c.childName.toLowerCase().contains(q) ||
          c.childId.toLowerCase().contains(q) ||
          c.phone.contains(q);

      final matchesStatus =
          _statusFilter == 'All' ||
          (_statusFilter == 'Entered' && c.entryStatus) ||
          (_statusFilter == 'Not Entered' && !c.entryStatus);

      final matchesGender = _genderFilter == 'All' || c.gender == _genderFilter;

      return matchesSearch && matchesStatus && matchesGender;
    }).toList();
  }

  void _exportCsv(List<ChildModel> data) {
    final header =
        'Child Name,Age,Gender,Branch,Camp ID,Parent,Phone,Address,Entry Status,Entry Time,Marked By\n';
    final rows = data
        .map((c) {
          return '${c.childName},${c.age},${c.gender ?? ''},${c.branchName ?? ''},${c.childId},${c.parentName},${c.phone},${c.address},${c.entryStatus ? 'Entered' : 'Not Entered'},${c.entryTime ?? ''},${c.markedByVolunteerName ?? ''}';
        })
        .join('\n');

    final csvContent = header + rows;
    FileSaver.saveFile('children_data.csv', csvContent);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final filtered = _filter(provider.children);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search + Filters + Export
          Row(
            children: [
              // Search
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by Name, Camp ID, or Phone...',
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
              const SizedBox(width: 12),
              _FilterDropdown(
                value: _statusFilter,
                items: const ['All', 'Entered', 'Not Entered'],
                onChanged: (v) => setState(() => _statusFilter = v!),
              ),
              const SizedBox(width: 8),
              _FilterDropdown(
                value: _genderFilter,
                items: const ['All', 'Male', 'Female'],
                onChanged: (v) => setState(() => _genderFilter = v!),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _exportCsv(filtered),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(
                  'Export CSV',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf97b06),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${filtered.length} records',
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
              columnSpacing: 20,
              columns: [
                _col('Child Name'),
                _col('Age'),
                _col('Gender'),
                _col('Branch'),
                _col('Camp ID'),
                _col('Parent'),
                _col('Phone'),
                _col('Status'),
                _col('Entry Time'),
                _col('Marked By'),
              ],
              rows: filtered.map((c) {
                final time = c.entryTime;
                final timeStr = time != null
                    ? '${time.hour % 12 == 0 ? 12 : time.hour % 12}:${time.minute.toString().padLeft(2, '0')} ${time.hour < 12 ? 'AM' : 'PM'}'
                    : '—';
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        c.childName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text('${c.age}', style: GoogleFonts.inter(fontSize: 13)),
                    ),
                    DataCell(
                      Text(
                        c.gender ?? '—',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        c.branchName ?? '—',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF66BB6A)),
                      ),
                    ),
                    DataCell(
                      Text(
                        c.childId,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFFf97b06),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        c.parentName,
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(c.phone, style: GoogleFonts.inter(fontSize: 13)),
                    ),
                    DataCell(_StatusBadge(entered: c.entryStatus)),
                    DataCell(
                      Text(timeStr, style: GoogleFonts.inter(fontSize: 13)),
                    ),
                    DataCell(
                      Text(
                        c.markedByVolunteerName ?? '—',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: c.markedByVolunteerName != null ? FontWeight.w500 : FontWeight.normal,
                          color: c.markedByVolunteerName != null ? const Color(0xFF5C6BC0) : const Color(0xFF999999),
                        ),
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

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: GoogleFonts.inter(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool entered;
  const _StatusBadge({required this.entered});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: entered
            ? const Color(0xFF43A047).withOpacity(0.1)
            : const Color(0xFFEF5350).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        entered ? 'Entered' : 'Not Entered',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: entered ? const Color(0xFF43A047) : const Color(0xFFEF5350),
        ),
      ),
    );
  }
}
