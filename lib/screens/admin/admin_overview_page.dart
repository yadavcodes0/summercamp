import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/admin_dashboard_provider.dart';

class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFf97b06)),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Text(
          'Error: ${provider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final stats = provider.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stat Cards ──
          Row(
            children: [
              _StatCard(
                title: 'Total Registrations',
                value: '${stats['totalRegistrations'] ?? 0}',
                icon: Icons.app_registration_rounded,
                color: const Color(0xFFf97b06),
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: 'Total Children',
                value: '${stats['totalChildren'] ?? 0}',
                icon: Icons.child_care_rounded,
                color: const Color(0xFF5C6BC0),
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: 'Total Volunteers',
                value: '${stats['totalVolunteers'] ?? 0}',
                icon: Icons.people_rounded,
                color: const Color(0xFF26A69A),
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: 'Entries Completed',
                value: '${stats['entriesCompleted'] ?? 0}',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF43A047),
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: 'Remaining',
                value: '${stats['remaining'] ?? 0}',
                icon: Icons.hourglass_bottom_rounded,
                color: const Color(0xFFEF5350),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Recent Entries + Charts ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent Entries Table
              Expanded(
                flex: 3,
                child: _CardContainer(
                  title: 'Recent Entries',
                  child: _RecentEntriesTable(entries: provider.recentEntries),
                ),
              ),
              const SizedBox(width: 16),

              // Charts
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _CardContainer(
                      title: 'Gender Distribution',
                      child: SizedBox(
                        height: 200,
                        child: _GenderPieChart(children: provider.children),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CardContainer(
                      title: 'Age Group Distribution',
                      child: SizedBox(
                        height: 200,
                        child: _AgeBarChart(children: provider.children),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card Container ──
class _CardContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Recent Entries Table ──
class _RecentEntriesTable extends StatelessWidget {
  final List entries;

  const _RecentEntriesTable({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No entries yet.',
          style: GoogleFonts.inter(color: const Color(0xFF888888)),
        ),
      );
    }

    return DataTable(
      headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F5FA)),
      columns: [
        DataColumn(
          label: Text(
            'Child Name',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Camp ID',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Branch',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Marked By',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Entry Time',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Status',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
      ],
      rows: entries.map<DataRow>((child) {
        final time = child.entryTime;
        final timeStr = time != null
            ? '${time.hour % 12 == 0 ? 12 : time.hour % 12}:${time.minute.toString().padLeft(2, '0')} ${time.hour < 12 ? 'AM' : 'PM'}'
            : '—';
        return DataRow(
          cells: [
            DataCell(
              Text(child.childName, style: GoogleFonts.inter(fontSize: 13)),
            ),
            DataCell(
              Text(
                child.childId,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFFf97b06),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataCell(
              Text(child.branchName ?? '—', style: GoogleFonts.inter(fontSize: 13)),
            ),
            DataCell(
              Text(child.markedByVolunteerName ?? '—', style: GoogleFonts.inter(fontSize: 13)),
            ),
            DataCell(Text(timeStr, style: GoogleFonts.inter(fontSize: 13))),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Entered',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF43A047),
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ── Gender Pie Chart ──
class _GenderPieChart extends StatelessWidget {
  final List children;

  const _GenderPieChart({required this.children});

  @override
  Widget build(BuildContext context) {
    final male = children.where((c) => c.gender == 'Male').length;
    final female = children.where((c) => c.gender == 'Female').length;
    final other = children.length - male - female;

    if (children.isEmpty) {
      return Center(
        child: Text(
          'No data',
          style: GoogleFonts.inter(color: const Color(0xFF888888)),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 30,
              sections: [
                PieChartSectionData(
                  value: male.toDouble(),
                  color: const Color(0xFFf97b06),
                  title: '$male',
                  titleStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  radius: 50,
                ),
                PieChartSectionData(
                  value: female.toDouble(),
                  color: const Color(0xFF5C6BC0),
                  title: '$female',
                  titleStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  radius: 50,
                ),
                if (other > 0)
                  PieChartSectionData(
                    value: other.toDouble(),
                    color: const Color(0xFF888888),
                    title: '$other',
                    titleStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    radius: 50,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendDot(color: const Color(0xFFf97b06), label: 'Male ($male)'),
            const SizedBox(height: 8),
            _LegendDot(
              color: const Color(0xFF5C6BC0),
              label: 'Female ($female)',
            ),
            if (other > 0) ...[
              const SizedBox(height: 8),
              _LegendDot(
                color: const Color(0xFF888888),
                label: 'Other ($other)',
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}

// ── Age Group Bar Chart ──
class _AgeBarChart extends StatelessWidget {
  final List children;

  const _AgeBarChart({required this.children});

  @override
  Widget build(BuildContext context) {
    final g1 = children.where((c) => c.age >= 5 && c.age <= 9).length;
    final g2 = children.where((c) => c.age >= 10 && c.age <= 14).length;
    final g3 = children.where((c) => c.age >= 15 && c.age <= 19).length;
    final g4 = children.where((c) => c.age >= 20 && c.age <= 25).length;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: ([g1, g2, g3, g4].reduce((a, b) => a > b ? a : b) + 5).toDouble(),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['5–9 yrs', '10–14 yrs', '15–19 yrs', '20-25 yrs'];
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[value.toInt()],
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF888888),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: const Color(0xFFEEEEEE), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          _barGroup(0, g1.toDouble()),
          _barGroup(1, g2.toDouble()),
          _barGroup(2, g3.toDouble()),
          _barGroup(3, g4.toDouble()),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFFf97b06),
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}
