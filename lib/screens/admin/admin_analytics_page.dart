import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/providers/admin_dashboard_provider.dart';

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final children = provider.children;

    final male = children.where((c) => c.gender == 'Male').length;
    final female = children.where((c) => c.gender == 'Female').length;
    final other = children.length - male - female;

    final g1 = children.where((c) => c.age >= 5 && c.age <= 8).length;
    final g2 = children.where((c) => c.age >= 9 && c.age <= 12).length;
    final g3 = children.where((c) => c.age >= 13 && c.age <= 16).length;

    // Daily registrations (last 7 days)
    final now = DateTime.now();
    final dailyData = <String, int>{};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.day}/${day.month}';
      dailyData[key] = children
          .where((c) =>
              c.createdAt.day == day.day &&
              c.createdAt.month == day.month &&
              c.createdAt.year == day.year)
          .length;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Gender + Age ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ChartCard(
                  title: 'Gender Distribution',
                  child: SizedBox(
                    height: 260,
                    child: _GenderChart(
                        male: male, female: female, other: other),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _ChartCard(
                  title: 'Age Group Distribution',
                  child: SizedBox(
                    height: 260,
                    child: _AgeChart(g1: g1, g2: g2, g3: g3),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Row 2: Daily Registrations ──
          _ChartCard(
            title: 'Daily Registrations (Last 7 Days)',
            child: SizedBox(
              height: 280,
              child: _DailyLineChart(data: dailyData),
            ),
          ),

          const SizedBox(height: 20),

          // ── Summary Cards ──
          Row(
            children: [
              _SummaryCard(
                title: 'Entry Rate',
                value: children.isNotEmpty
                    ? '${(children.where((c) => c.entryStatus).length / children.length * 100).toStringAsFixed(1)}%'
                    : '0%',
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF43A047),
              ),
              const SizedBox(width: 16),
              _SummaryCard(
                title: 'Avg. Age',
                value: children.isNotEmpty
                    ? '${(children.map((c) => c.age).reduce((a, b) => a + b) / children.length).toStringAsFixed(1)} yrs'
                    : '0',
                icon: Icons.cake_rounded,
                color: const Color(0xFF5C6BC0),
              ),
              const SizedBox(width: 16),
              _SummaryCard(
                title: 'Total Today',
                value: '${children.where((c) => c.createdAt.day == now.day && c.createdAt.month == now.month).length}',
                icon: Icons.today_rounded,
                color: const Color(0xFFf97b06),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E))),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E))),
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF888888))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gender Pie Chart ──
class _GenderChart extends StatelessWidget {
  final int male, female, other;
  const _GenderChart(
      {required this.male, required this.female, required this.other});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(
            value: male.toDouble(),
            color: const Color(0xFFf97b06),
            title: 'Male\n$male',
            titleStyle: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
            radius: 70,
          ),
          PieChartSectionData(
            value: female.toDouble(),
            color: const Color(0xFF5C6BC0),
            title: 'Female\n$female',
            titleStyle: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
            radius: 70,
          ),
          if (other > 0)
            PieChartSectionData(
              value: other.toDouble(),
              color: const Color(0xFF888888),
              title: 'Other\n$other',
              titleStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
              radius: 70,
            ),
        ],
      ),
    );
  }
}

// ── Age Bar Chart ──
class _AgeChart extends StatelessWidget {
  final int g1, g2, g3;
  const _AgeChart({required this.g1, required this.g2, required this.g3});

  @override
  Widget build(BuildContext context) {
    final maxY = ([g1, g2, g3].reduce((a, b) => a > b ? a : b) + 5).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['5–8 yrs', '9–12 yrs', '13–16 yrs'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(labels[value.toInt()],
                      style: GoogleFonts.inter(
                          fontSize: 11, color: const Color(0xFF888888))),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}',
                  style: GoogleFonts.inter(
                      fontSize: 10, color: const Color(0xFF888888))),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: const Color(0xFFEEEEEE), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          _bar(0, g1.toDouble()),
          _bar(1, g2.toDouble()),
          _bar(2, g3.toDouble()),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: y,
        color: const Color(0xFFf97b06),
        width: 36,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    ]);
  }
}

// ── Daily Line Chart ──
class _DailyLineChart extends StatelessWidget {
  final Map<String, int> data;
  const _DailyLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxY =
        (entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 3)
            .toDouble();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i >= 0 && i < entries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(entries[i].key,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: const Color(0xFF888888))),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}',
                  style: GoogleFonts.inter(
                      fontSize: 10, color: const Color(0xFF888888))),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: const Color(0xFFEEEEEE), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(entries.length,
                (i) => FlSpot(i.toDouble(), entries[i].value.toDouble())),
            isCurved: true,
            color: const Color(0xFFf97b06),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 5,
                color: const Color(0xFFf97b06),
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFf97b06).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
